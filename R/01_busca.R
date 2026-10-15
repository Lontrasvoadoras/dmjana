###############################################################################
#  01_busca.R - ETAPA 01: busca sistemática de estudos de DM2 no GEO
#
#  Intenção: encontrar TODOS os estudos públicos de expressão gênica com DM2 e controles nos
#  tecidos de interesse, registrando cada consulta (PRISMA-S) e o motivo de cada exclusão.
#  A busca não sabe a idade nem o sexo das amostras: a restrição a mulheres de 40-60 anos
#  é feita na etapa 02, amostra a amostra.
#
#  Passos:
#   1. Uma consulta por tecido: (termos de DM2) AND (termos do tecido) AND humano AND
#      série (gse) AND tipo de dado de expressão AND data mínima (E-utilities, banco gds).
#   2. Resumo de cada série (título, resumo, plataforma, n de amostras, espécies, PubMed).
#   3. Estudos-semente (input/estudos_semente.csv) entram sempre e medem a sensibilidade.
#   4. Triagem pelo título (limites de palavra): exclusão com motivo; termos de célula única
#      vão para revisão manual em vez de excluídos. Tecido fora do escopo (retina, rim, pele,
#      câncer...) só exclui quando o título não cita também um tecido de interesse (decisão de
#      06/10/2026: um estudo de PBMC de pacientes com nefropatia diabética é sangue e fica).
#
#  Entrada : config/busca.yaml, input/estudos_semente.csv
#  Saída   : output/01_busca/{consultas.csv, catalogo.csv, revisar.csv}
###############################################################################

# Consulta de um tecido no formato do E-utilities
montar_consulta <- function(cfg, termos_tecido) {
  B <- cfg$busca
  q <- function(x) paste0("(", paste(sprintf('"%s"', x), collapse = " OR "), ")")
  paste0(q(B$termos_doenca), " AND ", q(termos_tecido),
         sprintf(' AND "%s"[Organism] AND gse[ETYP]', B$organismo),
         " AND (", paste(sprintf('"%s"[DataSet Type]', B$tipos_dado), collapse = " OR "), ")",
         sprintf(' AND ("%s"[PDAT] : "3000"[PDAT])', B$data_publicacao_min))
}

# Executa uma consulta e devolve os IDs (UIDs do gds) e o total
executar_consulta <- function(cfg, consulta) {
  Sys.sleep(cfg$busca$pausa_seg)
  r <- rentrez::entrez_search(db = cfg$busca$base, term = consulta, retmax = cfg$busca$max_resultados_por_consulta)
  list(ids = r$ids, total = as.integer(r$count))
}

# Resumos das séries em blocos de 200 UIDs (campos do GEO DataSets)
resumir_series <- function(cfg, ids) {
  if (!length(ids)) return(data.frame())
  blocos <- split(ids, ceiling(seq_along(ids) / 200))
  do.call(rbind, lapply(blocos, function(b) {
    Sys.sleep(cfg$busca$pausa_seg)
    s <- rentrez::entrez_summary(db = cfg$busca$base, id = b)
    if (inherits(s, "esummary")) s <- list(s)
    do.call(rbind, lapply(s, function(x) data.frame(
      uid = as.character(x$uid), gse = x$accession, titulo = x$title, resumo = substr(x$summary %||% "", 1, 1500),
      tipo_dado = paste(x$gdstype, collapse = "; "), especies = paste(unique(x$taxon), collapse = "; "),
      n_amostras = as.integer(x$n_samples %||% NA), plataformas = paste0("GPL", unlist(strsplit(as.character(x$gpl %||% ""), ";")), collapse = ";"),
      data_publicacao = x$pdat %||% NA, pubmed = paste(unlist(x$pubmedids), collapse = ";"),
      arquivos_suplementares = x$suppfile %||% NA, stringsAsFactors = FALSE)))
  }))
}

# Triagem pelo título e pelas espécies: exclusão com motivo; revisão para célula única, outro tipo
# de dado no título, série humana com parte em outra espécie e séries muito grandes.
# Auditoria de 06/10/2026: termos de tipo de dado e mistura de espécies deixaram de excluir (a etapa 02
# lê os metadados e conta só amostras humanas); espécies no título casam só como palavra exata.
triar <- function(cfg, cat) {
  T <- cfg$triagem
  sens <- unlist(T$sensivel_maiusculas)
  achou <- function(txt, termos, ci = TRUE, plural = TRUE) {
    if (!length(termos)) return(rep(NA_character_, length(txt)))
    vapply(txt, function(t) { for (k in termos) if (grepl(regex_termos(k, plural), t, ignore.case = ci, perl = TRUE)) return(k); NA_character_ }, "", USE.NAMES = FALSE)
  }
  com_sens <- function(termos) dplyr::coalesce(achou(cat$titulo, setdiff(termos, sens), TRUE), achou(cat$titulo, intersect(termos, sens), FALSE))
  termo_exc <- dplyr::coalesce(achou(cat$titulo, unlist(T$especies_titulo), TRUE, plural = FALSE), com_sens(unlist(T$excluir_titulo)))
  # tecido fora do escopo, a menos que o título também cite um tecido de interesse
  fora <- achou(cat$titulo, unlist(T$tecido_fora_escopo), TRUE)
  alvos <- setdiff(unique(unlist(cfg$tecidos)), unlist(T$tecido_generico))   # genéricos não salvam
  cita_alvo <- !is.na(achou(cat$titulo, alvos, TRUE))
  fora[cita_alvo] <- NA
  termo_cel <- achou(cat$titulo, unlist(T$revisar_titulo), TRUE)
  termo_dado <- com_sens(unlist(T$outro_tipo_dado_titulo))
  # espécies reais (sem sondas de controle: "synthetic construct", vírus)
  esp <- vapply(strsplit(cat$especies, ";\\s*"), function(x) { x <- trimws(x); paste(x[!grepl(paste(unlist(T$especies_ignorar), collapse = "|"), x, ignore.case = TRUE)], collapse = "; ") }, "")
  cat$especies_reais <- esp
  humana <- grepl("Homo sapiens", esp); mista <- humana & grepl(";", esp)
  cat$termo_triagem <- dplyr::coalesce(termo_exc, fora, termo_dado, termo_cel)
  cat$motivo <- dplyr::case_when(
    !humana ~ "amostras não humanas",
    !grepl("Expression profiling", cat$tipo_dado) ~ "não é perfil de expressão",
    cat$n_amostras < T$n_min_amostras ~ sprintf("menos de %d amostras", T$n_min_amostras),
    !is.na(termo_exc) & !cat$semente ~ sprintf("título fora do escopo (termo: %s)", termo_exc),
    !is.na(fora) & !cat$semente ~ sprintf("tecido fora do escopo no título (termo: %s)", fora),
    TRUE ~ NA_character_)
  rev <- dplyr::case_when(
    !is.na(termo_dado) ~ sprintf("título cita outro tipo de dado (termo: %s); a série também é de expressão: confirmar", termo_dado),
    mista ~ sprintf("mais de uma espécie (%s): só as amostras humanas contam na etapa 02", esp),
    !is.na(termo_cel) ~ sprintf("célula única ou núcleo único (termo: %s): avaliar desenho por doador", termo_cel),
    cat$n_amostras > T$n_max_amostras ~ sprintf("mais de %d amostras: provável compilação ou célula única", T$n_max_amostras),
    TRUE ~ NA_character_)
  cat$triagem <- dplyr::case_when(!is.na(cat$motivo) ~ "excluido", !is.na(rev) ~ "revisar", TRUE ~ "incluido")
  cat$motivo[cat$triagem == "revisar"] <- rev[cat$triagem == "revisar"]
  cat
}

# Casos de teste da triagem (input/testes_triagem.csv): título e espécies -> triagem esperada
testar_triagem <- function(cfg, arq = "input/testes_triagem.csv") {
  t <- utils::read.csv(arq, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
  x <- data.frame(gse = sprintf("T%02d", seq_len(nrow(t))), titulo = t$titulo, especies = t$especies,
                  tipo_dado = "Expression profiling by array", n_amostras = t$n_amostras, semente = FALSE, stringsAsFactors = FALSE)
  r <- triar(cfg, x)
  t$obtido <- r$triagem; t$motivo_obtido <- r$motivo; t$ok <- t$obtido == t$esperado
  t
}

# Refaz só a triagem sobre a busca já salva (mesmas séries e mesma data de consulta)
retriar <- function(cfg, arq_semente = "input/estudos_semente.csv") {
  d <- "output/01_busca"
  cat0 <- utils::read.csv(file.path(d, "catalogo.csv"), stringsAsFactors = FALSE, fileEncoding = "UTF-8", colClasses = c(uid = "character", pubmed = "character"))
  cat0 <- cat0[, setdiff(names(cat0), c("termo_triagem", "motivo", "triagem", "especies_reais"))]
  cat <- triar(cfg, cat0)
  log_msg("ETAPA 01 | triagem refeita sobre a busca salva: %d incluídas, %d para revisar, %d excluídas", sum(cat$triagem == "incluido"), sum(cat$triagem == "revisar"), sum(cat$triagem == "excluido"))
  list(consultas = utils::read.csv(file.path(d, "consultas.csv"), stringsAsFactors = FALSE, fileEncoding = "UTF-8"),
       catalogo = cat[order(cat$triagem, cat$gse), ], sementes = utils::read.csv(arq_semente, stringsAsFactors = FALSE, fileEncoding = "UTF-8"))
}

# Busca completa: consultas por tecido + sementes + triagem
buscar <- function(cfg, arq_semente = "input/estudos_semente.csv") {
  consultas <- list(); por_tecido <- list()
  for (t in names(cfg$tecidos)) {
    q <- montar_consulta(cfg, unlist(cfg$tecidos[[t]]))
    r <- executar_consulta(cfg, q)
    log_msg("ETAPA 01 | %-17s %4d séries (%d recuperadas)", t, r$total, length(r$ids))
    consultas[[t]] <- data.frame(tecido = t, consulta = q, data_consulta = format(Sys.time(), "%Y-%m-%d %H:%M"),
                                 n_resultados = r$total, n_recuperados = length(r$ids))
    por_tecido[[t]] <- data.frame(uid = r$ids, tecido = rep(t, length(r$ids)))
  }
  consultas <- do.call(rbind, consultas); pt <- do.call(rbind, por_tecido)
  # resumo das séries (um UID pode aparecer em vários tecidos)
  res <- resumir_series(cfg, unique(pt$uid))
  tec <- tapply(pt$tecido, pt$uid, function(x) paste(sort(unique(x)), collapse = ";"))
  res$tecidos_busca <- unname(tec[res$uid])                       # tecidos em cuja consulta a série apareceu
  # sementes: entram sempre (busca própria pelo acesso)
  sem <- utils::read.csv(arq_semente, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
  res$semente <- res$gse %in% sem$gse
  faltam <- setdiff(sem$gse, res$gse)
  if (length(faltam)) {
    ids_sem <- unlist(lapply(faltam, function(g) { Sys.sleep(cfg$busca$pausa_seg); rentrez::entrez_search(db = "gds", term = sprintf("%s[ACCN] AND gse[ETYP]", g))$ids }))
    rs <- resumir_series(cfg, ids_sem)
    if (nrow(rs)) { rs$tecidos_busca <- sem$tecido[match(rs$gse, sem$gse)]; rs$semente <- TRUE; res <- rbind(res, rs) }
  }
  res$encontrado_pela_busca <- !(res$gse %in% faltam)
  log_msg("ETAPA 01 | %d séries únicas; sementes: %d de %d encontradas pela busca", nrow(res), sum(sem$gse %in% res$gse[res$encontrado_pela_busca]), nrow(sem))
  cat <- triar(cfg, res)
  log_msg("ETAPA 01 | triagem: %d incluídas, %d para revisar, %d excluídas", sum(cat$triagem == "incluido"), sum(cat$triagem == "revisar"), sum(cat$triagem == "excluido"))
  list(consultas = consultas, catalogo = cat[order(cat$triagem, cat$gse), ], sementes = sem)
}

salvar_busca <- function(b) {
  d <- pasta("output", "01_busca")
  c(escrever_csv(b$consultas, file.path(d, "consultas.csv")),
    escrever_csv(b$catalogo, file.path(d, "catalogo.csv")),
    escrever_csv(b$catalogo[b$catalogo$triagem == "revisar", c("gse", "titulo", "n_amostras", "tecidos_busca", "motivo")], file.path(d, "revisar.csv")))
}
