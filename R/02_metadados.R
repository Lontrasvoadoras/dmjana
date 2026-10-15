###############################################################################
#  02_metadados.R - ETAPA 02: metadados por amostra e elegibilidade (mulheres de 40-60 anos)
#
#  Intenção: decidir, amostra a amostra, quem é mulher de 40-60 anos com DM2 ou sem diabetes,
#  em tecido de interesse e em condição basal, e contar DOADORAS únicas por estudo e tecido.
#   1. Características de cada amostra (texto "brief" do GEO, uma requisição por série, em cache).
#   2. Formato longo: estudo, amostra, campo, chave, valor.
#   3. Harmonização por regras de config/metadados.yaml (nada fixo no código): sexo, idade
#      (faixas de até 5 anos viram o ponto médio), status (ordem EXCLUIR > INTERMEDIARIO >
#      ND/T2D/AMBIGUO > "diabetes" sem tipo), tecido, material (cultivado sai), condição basal
#      (amostra sob intervenção sai) e doador.
#   4. Curadoria manual (input/curadoria.csv) sobrescreve qualquer campo, com motivo.
#   5. Elegibilidade por estudo x tecido: >= min_por_grupo doadoras DM2 e ND de 40-60 anos;
#      senão, o motivo (sem status, sem sexo, sem idade, poucas mulheres de 40-60).
#
#  Entrada : output/01_busca/catalogo.csv (incluídos e para revisão), config/metadados.yaml,
#            input/curadoria.csv, input/testes_regras.csv
#  Saída   : output/02_metadados/{amostras_longo.csv, amostras.csv, elegibilidade.csv,
#            chaves.csv, testes_regras.csv}
###############################################################################

# ---------------- 1-2. download e formato longo ----------------
baixar_amostras <- function(M, gse) {
  op <- options(timeout = max(600, getOption("timeout"))); on.exit(options(op))
  arq <- file.path(pasta("cache", "geo"), paste0(gse, "_gsm.txt"))
  if (!file.exists(arq) || file.size(arq) < 200) {
    for (k in seq_len(M$download$tentativas)) {
      Sys.sleep(M$download$pausa_seg)
      ok <- tryCatch(utils::download.file(sprintf(M$download$url, gse), arq, quiet = TRUE, mode = "wb") == 0, error = function(e) FALSE)
      if (ok && file.size(arq) > 200 && any(grepl("^\\^SAMPLE", readLines(arq, n = 50, warn = FALSE)))) break
      unlink(arq); Sys.sleep(2 * k)
    }
  }
  if (!file.exists(arq)) return(NULL)
  ln <- readLines(arq, warn = FALSE, encoding = "UTF-8")
  ini <- grep("^\\^SAMPLE = ", ln); if (!length(ini)) return(NULL)
  fim <- c(ini[-1] - 1, length(ln))
  do.call(rbind, lapply(seq_along(ini), function(i) {
    b <- ln[ini[i]:fim[i]]; gsm <- sub("^\\^SAMPLE = ", "", b[1])
    pega <- function(tag) sub(paste0("^!", tag, " = "), "", grep(paste0("^!", tag, " = "), b, value = TRUE))
    car <- pega("Sample_characteristics_ch1")
    chave <- ifelse(grepl(":", car), trimws(sub(":.*", "", car)), "")
    valor <- ifelse(grepl(":", car), trimws(sub("^[^:]*:", "", car)), trimws(car))
    rbind(data.frame(gse = gse, gsm = gsm, campo = c("titulo", "fonte", "organismo", "plataforma", "tipo_amostra", "estrategia"), chave = "",
                     valor = c(paste(pega("Sample_title"), collapse = " "), paste(pega("Sample_source_name_ch1"), collapse = " "),
                               paste(pega("Sample_organism_ch1"), collapse = ";"), paste(pega("Sample_platform_id"), collapse = ";"),
                               paste(pega("Sample_type"), collapse = ";"), paste(pega("Sample_library_strategy"), collapse = ";"))),
          if (length(car)) data.frame(gse = gse, gsm = gsm, campo = "carac", chave = chave, valor = valor) else NULL)
  }))
}

# Título de cada plataforma (GPL), guardado em cache/geo/plataformas.csv
titulos_plataformas <- function(gpls, arq = "cache/geo/plataformas.csv") {
  t <- if (file.exists(arq)) utils::read.csv(arq, stringsAsFactors = FALSE, fileEncoding = "UTF-8") else data.frame(gpl = character(), titulo = character())
  falta <- setdiff(unique(unlist(strsplit(gpls, ";"))), t$gpl)
  for (g in falta) {
    Sys.sleep(0.4)
    x <- tryCatch({ s <- rentrez::entrez_search(db = "gds", term = sprintf("%s[ACCN] AND gpl[ETYP]", g)); rentrez::entrez_summary(db = "gds", id = s$ids[1])$title }, error = function(e) NA_character_)
    t <- rbind(t, data.frame(gpl = g, titulo = x))
  }
  if (length(falta)) escrever_csv(t, arq)
  vapply(gpls, function(p) paste(t$titulo[match(strsplit(p, ";")[[1]], t$gpl)], collapse = "; "), "")
}

# ---------------- 3. regras ----------------
tem <- function(rx, x) !is.na(x) & grepl(rx, tolower(x), perl = TRUE)

classificar_status <- function(S, texto, contexto_t1 = FALSE) {
  t <- tolower(ifelse(is.na(texto), "", texto)); contexto_t1 <- rep_len(contexto_t1, length(t))
  nd <- tem(S$nao_diabetico, t)
  t_sem_nd <- gsub(S$nao_diabetico, " ", t, perl = TRUE)          # "non-diabetic" não conta como DM2
  dm2 <- tem(S$dm2, t_sem_nd)
  sem_tipo <- tem(S$diabetes_sem_tipo, t_sem_nd)
  dplyr::case_when(
    !nzchar(trimws(t)) ~ NA_character_,
    tem(S$excluir, t) ~ "EXCLUIR",
    tem(S$intermediario, t) ~ "INTERMEDIARIO",
    nd & (dm2 | sem_tipo) ~ "AMBIGUO",
    nd ~ "ND",
    dm2 ~ "T2D",
    sem_tipo & !contexto_t1 ~ "T2D",
    sem_tipo & contexto_t1 ~ "AMBIGUO",
    TRUE ~ NA_character_)
}

# Uma chave de status por vez: chave que já é a pergunta "tem DM2?" com valor sim/não; senão, o valor
classificar_status_chave <- function(S, chave, valor, contexto_t1 = FALSE) {
  k <- tolower(chave); v <- tolower(trimws(valor))
  bin <- tem(S$chave_binaria, k) & !tem(S$chave_binaria_excluir, k)
  dplyr::case_when(bin & tem(S$sim, v) ~ "T2D", bin & tem(S$nao, v) ~ "ND",
                   bin & tem(S$excluir, k) ~ "EXCLUIR",
                   TRUE ~ classificar_status(S, valor, contexto_t1))
}

# Combina as classificações das várias chaves de uma amostra
combinar_status <- function(x) {
  x <- x[!is.na(x)]
  if (!length(x)) NA_character_ else if ("EXCLUIR" %in% x) "EXCLUIR" else if ("INTERMEDIARIO" %in% x) "INTERMEDIARIO"
  else if ("AMBIGUO" %in% x || all(c("ND", "T2D") %in% x)) "AMBIGUO" else x[1]
}

classificar_sexo <- function(X, v) {
  v <- tolower(trimws(v))
  f <- tem(X$feminino, v); m <- tem(X$masculino, v)
  dplyr::case_when(f & m ~ NA_character_, f ~ "F", m ~ "M", TRUE ~ NA_character_)   # "Male/Female" (pool misto) = sem sexo
}

# idade numérica; faixa "a-b" ou "a to b" com largura <= faixa_max vira o ponto médio
ler_idade <- function(I, v) {
  v <- tolower(trimws(v))
  out <- data.frame(idade = NA_real_, idade_tipo = NA_character_)[rep(1, length(v)), ]
  faixa <- regmatches(v, regexec("([0-9]+(\\.[0-9]+)?)\\s*(-|–|to)\\s*([0-9]+(\\.[0-9]+)?)", v))
  for (i in seq_along(v)) {
    if (is.na(v[i]) || !nzchar(v[i]) || grepl("^[<>]", v[i]) || grepl("month|week|day", v[i])) next
    f <- faixa[[i]]
    if (length(f) >= 5) {
      a <- as.numeric(f[2]); b <- as.numeric(f[5])
      if (b - a <= I$faixa_max_anos) { out$idade[i] <- (a + b) / 2; out$idade_tipo[i] <- "faixa_ponto_medio" } else out$idade_tipo[i] <- "faixa_larga"
    } else {
      n <- suppressWarnings(as.numeric(regmatches(v[i], regexpr("[0-9]+(\\.[0-9]+)?", v[i]))))
      if (length(n) && !is.na(n) && n > 0 && n < 120) { out$idade[i] <- n; out$idade_tipo[i] <- "exata" }
    }
  }
  out
}

mapear_tecido <- function(Tm, texto) {
  t <- tolower(texto)
  vapply(t, function(x) { for (k in names(Tm)) if (!is.na(x) && grepl(Tm[[k]], x, perl = TRUE)) return(k); NA_character_ }, "", USE.NAMES = FALSE)
}

# ---------------- 3-4. harmonização + curadoria ----------------
harmonizar <- function(M, longo, catalogo, arq_curadoria = "input/curadoria.csv") {
  car <- longo[longo$campo == "carac", ]; car$chave_l <- tolower(car$chave)
  base <- tidyr::pivot_wider(longo[longo$campo != "carac", c("gse", "gsm", "campo", "valor")], names_from = campo, values_from = valor)
  # primeiro valor de uma chave que casa com rx (e não com excluir)
  valor_de <- function(rx, excluir = NULL) {
    x <- car[grepl(rx, car$chave_l, perl = TRUE), ]
    if (!is.null(excluir)) x <- x[!grepl(excluir, x$chave_l, perl = TRUE), ]
    x <- x[!duplicated(x$gsm), ]; stats::setNames(x$valor, x$gsm)
  }
  todos_car <- tapply(paste(car$chave, car$valor, sep = ": "), car$gsm, paste, collapse = " | ")
  a <- base; a$carac_texto <- unname(todos_car[a$gsm])
  # sexo (chave; se faltar, título e fonte)
  sx <- valor_de(M$sexo$chave); a$sexo_bruto <- unname(sx[a$gsm])
  a$sexo <- classificar_sexo(M$sexo, a$sexo_bruto); a$sexo_fonte <- ifelse(is.na(a$sexo), NA, "característica")
  # idade
  id <- ler_idade(M$idade, unname(valor_de(M$idade$chave, M$idade$excluir_chave)[a$gsm]))
  a$idade <- id$idade; a$idade_tipo <- id$idade_tipo
  # status: cada chave de status classificada sozinha e combinada; sem resultado, título + fonte;
  # ainda sem, todos os valores das características
  ctx <- catalogo$gse[grepl(M$status$contexto_tipo1, tolower(paste(catalogo$titulo, catalogo$resumo)), perl = TRUE)]
  st <- car[grepl(M$status$chave, car$chave_l, perl = TRUE) & !grepl(M$status$excluir_chave, car$chave_l, perl = TRUE), ]
  st$cl <- classificar_status_chave(M$status, st$chave, st$valor, st$gse %in% ctx)
  st_cl <- tapply(st$cl, st$gsm, combinar_status); st_txt <- tapply(paste(st$chave, st$valor, sep = ": "), st$gsm, paste, collapse = " ; ")
  a$status <- unname(st_cl[a$gsm]); a$status_texto <- unname(st_txt[a$gsm]); a$status_fonte <- ifelse(is.na(a$status), NA, "característica de status")
  s2 <- classificar_status(M$status, paste(a$titulo, a$fonte), a$gse %in% ctx); k <- is.na(a$status) & !is.na(s2)
  a$status[k] <- s2[k]; a$status_fonte[k] <- "título/fonte"
  ou <- car[!grepl(M$status$excluir_chave, car$chave_l, perl = TRUE) & !grepl(M$status$chave_binaria_excluir, car$chave_l, perl = TRUE), ]
  ou_txt <- tapply(ou$valor, ou$gsm, paste, collapse = " ; ")             # só valores: "family history of diabetes: yes" não conta
  s3 <- classificar_status(M$status, unname(ou_txt[a$gsm]), a$gse %in% ctx); k <- is.na(a$status) & !is.na(s3)
  a$status[k] <- s3[k]; a$status_fonte[k] <- "outras características"
  # tecido: chaves de tecido + fonte
  tc <- car[grepl(M$tecido$chave, car$chave_l, perl = TRUE), ]; tc_txt <- tapply(tc$valor, tc$gsm, paste, collapse = " ; ")
  a$tecido_texto <- trimws(paste(ifelse(is.na(tc_txt[a$gsm]), "", tc_txt[a$gsm]), a$fonte))
  a$tecido <- mapear_tecido(M$tecido$mapa, a$tecido_texto)
  # material e condição basal
  a$cultivado <- tem(M$material$cultivado, gsub(M$material$cultivado_excecao, " ", tolower(paste(a$fonte, a$carac_texto, a$titulo)), perl = TRUE))
  iv <- car[grepl(M$intervencao$chave, car$chave_l, perl = TRUE) & !grepl(M$intervencao$excluir_chave, car$chave_l, perl = TRUE), ]
  iv <- iv[!is.na(iv$valor) & nzchar(trimws(iv$valor)), ]                 # valor vazio não é intervenção
  iv$basal <- tem(M$intervencao$basal, iv$valor)
  nb <- tapply(!iv$basal, iv$gsm, any); a$basal <- !(a$gsm %in% names(nb)[nb])
  # doador
  dd <- valor_de(M$doador$chave, M$doador$excluir_chave); a$individuo <- unname(dd[a$gsm])
  a$individuo <- ifelse(is.na(a$individuo) | !nzchar(a$individuo), a$gsm, paste(a$gse, a$individuo, sep = ":"))
  # curadoria manual (sobrescreve, na ordem do arquivo). Coluna gsm seleciona as amostras:
  #   "*" = todas do estudo; "GSM..." = uma; "titulo~<regex>" = título casa (sem maiúsculas);
  #   "carac:<chave>=<valor>" = característica com esse valor exato
  if (file.exists(arq_curadoria)) {
    cu <- utils::read.csv(arq_curadoria, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
    for (i in seq_len(nrow(cu))) {
      sel <- cu$gsm[i]
      k <- a$gse == cu$gse[i] & (
        if (sel == "*") TRUE
        else if (startsWith(sel, "titulo~")) grepl(sub("^titulo~", "", sel), a$titulo, ignore.case = TRUE, perl = TRUE)
        else if (startsWith(sel, "carac:")) {
          kv <- strsplit(sub("^carac:", "", sel), "=", fixed = TRUE)[[1]]
          a$gsm %in% car$gsm[car$gse == cu$gse[i] & car$chave_l == tolower(kv[1]) & car$valor == kv[2]]
        } else a$gsm == sel)
      if (!any(k)) log_msg("ETAPA 02 | curadoria linha %d (%s %s) não casou com nenhuma amostra", i, cu$gse[i], sel)
      if (any(k) && cu$campo[i] %in% names(a)) {
        a[[cu$campo[i]]][k] <- if (is.numeric(a[[cu$campo[i]]])) as.numeric(cu$valor[i]) else if (is.logical(a[[cu$campo[i]]])) as.logical(cu$valor[i]) else cu$valor[i]
        if (cu$campo[i] %in% c("sexo", "status")) a[[paste0(cu$campo[i], "_fonte")]][k] <- "curadoria"
      }
    }
  }
  E <- M$elegibilidade
  a$humano <- grepl("Homo sapiens", a$organismo)
  # ensaio de expressão de mRNA (correção de 06/10/2026, etapa 04: o GSE189007 tem as mesmas pessoas em
  # arrays de mRNA, miRNA e promotores, e o GSE200044 em RNA e ATAC; cada amostra contava como uma doadora)
  X <- M$ensaio; tit <- titulos_plataformas(unique(a$plataforma))
  a$plataforma_titulo <- unname(tit[a$plataforma])
  a$ensaio_expressao <- dplyr::case_when(
    a$tipo_amostra %in% unlist(X$tipos_array_expressao) ~ !grepl(X$plataforma_nao_expressao, tolower(a$plataforma_titulo), perl = TRUE),
    a$tipo_amostra == "SRA" ~ a$estrategia %in% unlist(X$estrategias_expressao),
    TRUE ~ FALSE)
  a$apta <- a$humano & a$ensaio_expressao & a$status %in% c("ND", "T2D") & !a$cultivado & a$basal & !is.na(a$tecido)
  a$mulher_40a60 <- a$sexo %in% "F" & !is.na(a$idade) & a$idade >= E$janela_idade[1] & a$idade < E$janela_idade[2] + 1
  a
}

# ---------------- 5. elegibilidade por estudo x tecido ----------------
# arq_exclusoes: decisões do usuário (gse, motivo, decisao); o estudo sai com o motivo registrado
elegibilidade <- function(M, a, catalogo, arq_exclusoes = "input/exclusoes.csv") {
  E <- M$elegibilidade
  doad <- function(x, filtro) length(unique(x$individuo[filtro]))
  r <- do.call(rbind, lapply(split(a, a$gse), function(x) {
    tecs <- sort(unique(stats::na.omit(x$tecido[x$apta])))
    if (!length(tecs)) tecs <- NA_character_
    do.call(rbind, lapply(tecs, function(t) {
      xt <- if (is.na(t)) x else x[x$tecido %in% t, ]
      ap <- xt$apta
      data.frame(gse = x$gse[1], tecido = t, n_amostras = nrow(xt), n_aptas = sum(ap), doadores_aptos = doad(xt, ap),
                 frac_sexo = round(mean(!is.na(xt$sexo)), 2), frac_idade = round(mean(!is.na(xt$idade)), 2),
                 frac_status = round(mean(xt$status %in% c("ND", "T2D")), 2),
                 F40a60_T2D = doad(xt, ap & xt$mulher_40a60 & xt$status == "T2D"), F40a60_ND = doad(xt, ap & xt$mulher_40a60 & xt$status == "ND"),
                 F_T2D = doad(xt, ap & xt$sexo %in% "F" & xt$status == "T2D"), F_ND = doad(xt, ap & xt$sexo %in% "F" & xt$status == "ND"),
                 M_T2D = doad(xt, ap & xt$sexo %in% "M" & xt$status == "T2D"), M_ND = doad(xt, ap & xt$sexo %in% "M" & xt$status == "ND"),
                 sem_sexo_40a60_T2D = doad(xt, ap & is.na(xt$sexo) & !is.na(xt$idade) & xt$idade >= E$janela_idade[1] & xt$idade < E$janela_idade[2] + 1 & xt$status == "T2D"),
                 sem_sexo_40a60_ND = doad(xt, ap & is.na(xt$sexo) & !is.na(xt$idade) & xt$idade >= E$janela_idade[1] & xt$idade < E$janela_idade[2] + 1 & xt$status == "ND"),
                 cultivadas = sum(xt$cultivado), nao_basais = sum(!xt$basal), stringsAsFactors = FALSE)
    }))
  }))
  # amostras repetidas entre séries: SuperSeries (todas as amostras já estão em subséries menores)
  # não conta; outras sobreposições ficam registradas para revisão
  gs <- split(a$gsm, a$gse)
  sobre <- lapply(names(gs), function(g) { o <- vapply(gs, function(y) length(intersect(gs[[g]], y)), 1L); o <- o[o > 0 & names(o) != g]; o })
  names(sobre) <- names(gs)
  sub_de <- vapply(names(gs), function(g) { o <- sobre[[g]]; subs <- names(o)[o == lengths(gs[names(o)]) & lengths(gs[names(o)]) < length(gs[[g]])]
    if (length(subs) && all(gs[[g]] %in% unlist(gs[subs]))) paste(subs, collapse = ";") else NA_character_ }, "")
  r$superserie_de <- unname(sub_de[r$gse])
  supers <- names(sub_de)[!is.na(sub_de)]
  r$sobreposicao <- vapply(r$gse, function(g) { o <- sobre[[g]]; o <- o[!names(o) %in% supers]; if (length(o)) paste(sprintf("%s (%d)", names(o), o), collapse = "; ") else "" }, "", USE.NAMES = FALSE)
  # mesmo doador em séries diferentes (identificador do doador igual, ex.: UNOS id do HPAP)
  dd <- unique(data.frame(gse = a$gse, id = sub("^GSE[0-9]+:", "", a$individuo))[a$individuo != a$gsm & a$apta, ])
  dd <- dd[grepl("[a-z]", dd$id, ignore.case = TRUE) & nchar(dd$id) >= 5, ]   # ids só numéricos ("1", "12") se repetem por acaso
  dd <- dd[dd$id %in% dd$id[duplicated(dd$id)], ]
  r$mesmos_doadores <- vapply(r$gse, function(g) { o <- table(dd$gse[dd$id %in% dd$id[dd$gse == g] & dd$gse != g]); o <- o[!names(o) %in% supers]
    if (length(o)) paste(sprintf("%s (%d)", names(o), as.integer(o)), collapse = "; ") else "" }, "", USE.NAMES = FALSE)
  ex <- if (file.exists(arq_exclusoes)) utils::read.csv(arq_exclusoes, stringsAsFactors = FALSE, fileEncoding = "UTF-8") else data.frame(gse = character(), motivo = character())
  r$exclusao <- ex$motivo[match(r$gse, ex$gse)]
  m <- E$min_por_grupo; f <- E$min_frac_campo
  r$categoria <- dplyr::case_when(
    r$gse %in% ex$gse ~ "excluído por decisão do usuário",
    !is.na(r$superserie_de) ~ "SuperSeries: amostras já nas subséries",
    r$F40a60_T2D >= m & r$F40a60_ND >= m ~ "elegivel",
    r$frac_status < f ~ "sem status ND/DM2",
    r$frac_sexo < f & r$sem_sexo_40a60_T2D >= m & r$sem_sexo_40a60_ND >= m ~ "sem sexo: candidato ao sexo genético",
    r$frac_sexo < f ~ "sem sexo",
    r$frac_idade < f ~ "sem idade",
    is.na(r$tecido) ~ "sem amostra apta em tecido de interesse",
    TRUE ~ "poucas mulheres de 40-60 com DM2 e controles")
  r$triagem_01 <- catalogo$triagem[match(r$gse, catalogo$gse)]
  r$motivo_01 <- ifelse(r$triagem_01 == "revisar", catalogo$motivo[match(r$gse, catalogo$gse)], "")
  r$titulo <- substr(catalogo$titulo[match(r$gse, catalogo$gse)], 1, 140)
  r[order(r$categoria != "elegivel", r$tecido, -r$F40a60_T2D), ]
}

# ---------------- testes das regras ----------------
testar_regras <- function(M, arq = "input/testes_regras.csv") {
  t <- utils::read.csv(arq, stringsAsFactors = FALSE, fileEncoding = "UTF-8", na.strings = character(0))
  obtido <- character(nrow(t))
  # status: "chave: valor" testa a regra por chave; sem ":", só o valor
  i <- t$campo == "status"; tem_k <- grepl(": ", t$texto[i])
  obtido[i] <- dplyr::coalesce(classificar_status_chave(M$status, ifelse(tem_k, sub(": .*", "", t$texto[i]), ""),
                                                        ifelse(tem_k, sub("^[^:]*: ", "", t$texto[i]), t$texto[i]), as.logical(t$contexto_tipo1[i])), "NA")
  i <- t$campo == "sexo"; obtido[i] <- dplyr::coalesce(classificar_sexo(M$sexo, t$texto[i]), "NA")
  i <- t$campo == "idade"; v <- ler_idade(M$idade, t$texto[i])$idade; obtido[i] <- ifelse(is.na(v), "NA", as.character(v))
  t$obtido <- obtido; t$ok <- t$obtido == t$esperado
  t
}

# ---------------- execução ----------------
ler_metadados <- function(M, catalogo) {
  alvo <- catalogo[catalogo$triagem %in% c("incluido", "revisar") & (catalogo$n_amostras <= M$download$max_amostras | catalogo$gse %in% unlist(M$download$forcar_leitura)), ]
  log_msg("ETAPA 02 | lendo as amostras de %d séries (%d acima de %d amostras ficam de fora)", nrow(alvo),
          sum(catalogo$triagem %in% c("incluido", "revisar") & catalogo$n_amostras > M$download$max_amostras), M$download$max_amostras)
  l <- lapply(seq_len(nrow(alvo)), function(i) {
    r <- tryCatch(baixar_amostras(M, alvo$gse[i]), error = function(e) { log_msg("ETAPA 02 | %s: ERRO %s", alvo$gse[i], conditionMessage(e)); NULL })
    if (i %% 50 == 0) log_msg("ETAPA 02 | %d de %d séries lidas", i, nrow(alvo))
    r
  })
  falhas <- alvo$gse[vapply(l, is.null, TRUE)]
  if (length(falhas)) log_msg("ETAPA 02 | sem amostras legíveis: %s", paste(falhas, collapse = ", "))
  list(longo = do.call(rbind, l), falhas = falhas)
}
