###############################################################################
#  98_sanidade.R - testes de sanidade das saídas (pedido do usuário, 08/10/2026)
#
#  Procura valores que não deveriam existir, por erro de código ou por confusão nos dados: NULL/NA onde a
#  coluna é obrigatória, infinitos, p fora de (0, 1], FDR menor que p, efeito fora do próprio intervalo,
#  contagens negativas, rótulos fora do conjunto permitido, IDs duplicados, colunas inteiras vazias ou
#  constantes (ex.: todos 0 ou todos 1) e incoerências entre colunas (ex.: "mulher de 40-60" com idade fora
#  da faixa). Cada verificação tem gravidade: ERRO (resultado não confiável; o script termina com falha)
#  ou ALERTA (conferir).
###############################################################################

.chk <- new.env()
.chk$t <- list()
verif <- function(etapa, arquivo, regra, n_viol, gravidade = "ERRO", exemplo = "") {
  .chk$t[[length(.chk$t) + 1]] <- data.frame(etapa = etapa, arquivo = arquivo, regra = regra, violacoes = as.integer(n_viol),
                                             gravidade = if (n_viol > 0) gravidade else "OK", exemplo = if (n_viol > 0) substr(paste(exemplo, collapse = "; "), 1, 150) else "",
                                             stringsAsFactors = FALSE)
}
le_s <- function(f) if (file.exists(f) && file.size(f) > 5) utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8", na.strings = c("NA", ""),
                                                                            colClasses = c(sexo = "character", sexo_genetico = "character")) else NULL
fora01 <- function(p) sum(!is.na(p) & (p <= 0 | p > 1))
naofin <- function(x) sum(!is.finite(x))

# colunas que podem ficar vazias ou constantes por natureza (não são alerta): lote em RNA-seq, biblioteca em
# arrays, motivo de retirada quando nada saiu, GSM no h5ad, sexo genético não avaliável, estatísticas entre
# estudos num tecido com 1 estudo, seleção quando nada foi selecionado, FDR todo igual a 1, nº de estudos
OPCIONAIS <- c("g_sem_todos_estudos", "estudos_todos", "g_fe", "p_fe", "p_expl", "g_sem_principal", "g_com_principal", "estudos_com_principal", "p_wilcoxon", "lote", "biblioteca", "motivo_retirada", "gsm", "sexo_genetico", "n_celulas", "I2", "tau2", "p_dl", "p_hk", "p_stouffer", "p_rop2",
               "p_heterogeneidade", "fdr_stouffer", "fdr_rop2", "Zsummary_min", "Zsummary_max", "estudos_preservado", "preservado", "selecao", "nivel", "NES",
               "leading_edge", "erro", "nota", "replicas_tecnicas", "alerta", "exclusao", "superserie_de", "motivo_01", "rotulo")
CONSTANTES_OK <- c("estudos_todos", "estudos_com", "estudos_com_principal", "estudos", "estudos_preservado", "mesmo_sentido", "fdr", "fdr_stouffer", "fdr_rop2", "vias", "sem_ligacao", "n1", "n2", "outras_retiradas", "discrepantes", "sexo_discordantes")
# verificações gerais de um data.frame: colunas totalmente vazias e colunas numéricas constantes
gerais <- function(etapa, arquivo, x, obrig = character(), chave = NULL, ignorar_constantes = character()) {
  if (is.null(x)) { verif(etapa, arquivo, "arquivo existe e não está vazio", 1, "ERRO"); return(invisible()) }
  for (c0 in intersect(obrig, names(x))) verif(etapa, arquivo, sprintf("coluna obrigatória '%s' sem NA", c0), sum(is.na(x[[c0]])), "ERRO", utils::head(which(is.na(x[[c0]])), 3))
  for (c0 in setdiff(obrig, names(x))) verif(etapa, arquivo, sprintf("coluna obrigatória '%s' existe", c0), 1, "ERRO")
  vaz <- setdiff(names(x)[vapply(x, function(v) all(is.na(v)), TRUE)], OPCIONAIS)
  verif(etapa, arquivo, "nenhuma coluna inteiramente vazia", length(vaz), "ALERTA", vaz)
  cst <- names(x)[vapply(x, function(v) is.numeric(v) && length(unique(stats::na.omit(v))) == 1 && sum(!is.na(v)) > 5, TRUE)]
  cst <- setdiff(cst, c(ignorar_constantes, CONSTANTES_OK))
  verif(etapa, arquivo, "nenhuma coluna numérica constante (ex.: tudo 0 ou tudo 1)", length(cst), "ALERTA", cst)
  if (!is.null(chave) && all(chave %in% names(x))) { k <- do.call(paste, x[chave]); verif(etapa, arquivo, sprintf("chave única (%s)", paste(chave, collapse = "+")), sum(duplicated(k)), "ERRO", utils::head(k[duplicated(k)], 3)) }
}

# efeitos por estudo (etapa 05/06/07): g, variância, p, tamanhos
efeitos <- function(etapa, arquivo, x) {
  gerais(etapa, arquivo, x, obrig = c("id", "g", "var_g", "p"), chave = "id", ignorar_constantes = c("n1", "n2"))
  if (is.null(x)) return(invisible())
  verif(etapa, arquivo, "g finito", naofin(x$g), "ERRO", x$id[!is.finite(x$g)])
  verif(etapa, arquivo, "variância de g finita e > 0", sum(!is.finite(x$var_g) | x$var_g <= 0), "ERRO")
  verif(etapa, arquivo, "p em (0, 1]", fora01(x$p), "ERRO")
  verif(etapa, arquivo, "n1 e n2 >= 2", sum(x$n1 < 2 | x$n2 < 2, na.rm = TRUE), "ERRO")
  verif(etapa, arquivo, "menos de 1% de p exatamente 1", as.integer(mean(x$p == 1, na.rm = TRUE) > 0.01), "ALERTA", sprintf("%.1f%%", 100 * mean(x$p == 1, na.rm = TRUE)))
  if ("t" %in% names(x)) { r <- stats::median(abs(x$g / sqrt(x$var_g)) / abs(x$t), na.rm = TRUE)   # revisão de 08/10/2026
    verif(etapa, arquivo, "precisão de g coerente com o limma (mediana |g/ep| / |t| entre 0,85 e 1,15)", as.integer(!is.finite(r) || r < 0.85 || r > 1.15), "ALERTA", sprintf("%.2f", r)) }
  verif(etapa, arquivo, "menos de 1% de g exatamente 0", as.integer(mean(x$g == 0, na.rm = TRUE) > 0.01), "ALERTA", sprintf("%.1f%%", 100 * mean(x$g == 0, na.rm = TRUE)))
}

# meta-análise (etapa 05/06/07)
meta <- function(etapa, arquivo, x) {
  gerais(etapa, arquivo, x, obrig = c("id", "g", "p", "fdr", "estudos", "mesmo_sentido"), chave = "id")
  if (is.null(x)) return(invisible())
  verif(etapa, arquivo, "g finito", naofin(x$g), "ERRO", x$id[!is.finite(x$g)])
  verif(etapa, arquivo, "p e FDR em (0, 1]", fora01(x$p) + fora01(x$fdr), "ERRO")
  verif(etapa, arquivo, "FDR >= p", sum(x$fdr < x$p - 1e-12, na.rm = TRUE), "ERRO", x$id[which(x$fdr < x$p - 1e-12)])
  verif(etapa, arquivo, "efeito dentro do próprio IC 95%", sum(x$g < x$ic_inf - 1e-9 | x$g > x$ic_sup + 1e-9, na.rm = TRUE), "ERRO")
  if ("I2" %in% names(x)) verif(etapa, arquivo, "I² em [0, 1]", sum(!is.na(x$I2) & (x$I2 < 0 | x$I2 > 1)), "ERRO")
  verif(etapa, arquivo, "estudos no mesmo sentido <= estudos", sum(x$mesmo_sentido > x$estudos, na.rm = TRUE), "ERRO")
  verif(etapa, arquivo, "replicado só com 2+ estudos", sum(x$nivel == "replicado" & x$estudos < 2, na.rm = TRUE), "ERRO")
  for (c0 in intersect(c("p_stouffer", "p_rop2", "p_heterogeneidade", "p_dl", "p_hk"), names(x))) verif(etapa, arquivo, sprintf("%s em (0, 1] quando presente", c0), fora01(x[[c0]]), "ERRO")
}

verificar_tudo <- function() {
  .chk$t <- list()
  # configurações legíveis (09/10/2026: um comentário dentro de {...} quebrou o processamento.yaml e etapas falharam)
  for (f in Sys.glob("config/*.yaml")) { ok <- tryCatch({ yaml::read_yaml(f); TRUE }, error = function(e) FALSE)
    verif("config", basename(f), "arquivo YAML legível", as.integer(!ok), "ERRO") }
  # ---------------- etapa 02 ----------------
  a <- le_s("output/02_metadados/amostras.csv")
  gerais("02", "amostras.csv", a, obrig = c("gse", "gsm", "individuo", "apta", "mulher_40a60"), chave = c("gse", "gsm"))
  if (!is.null(a)) {
    verif("02", "amostras.csv", "sexo em {F, M, vazio}", sum(!is.na(a$sexo) & !a$sexo %in% c("F", "M")), "ERRO", utils::head(unique(a$sexo[!a$sexo %in% c("F", "M", NA)]), 3))
    verif("02", "amostras.csv", "idade vazia ou entre 0 e 120", sum(!is.na(a$idade) & (a$idade <= 0 | a$idade >= 120)), "ERRO")
    verif("02", "amostras.csv", "status num conjunto permitido", sum(!is.na(a$status) & !a$status %in% c("ND", "T2D", "EXCLUIR", "INTERMEDIARIO", "AMBIGUO")), "ERRO")
    f <- a$mulher_40a60 %in% TRUE
    verif("02", "amostras.csv", "mulher_40a60 => sexo F e 40 <= idade < 61", sum(f & !(a$sexo %in% "F" & a$idade >= 40 & a$idade < 61)), "ERRO")
    verif("02", "amostras.csv", "apta => status ND/T2D, humana, basal, não cultivada", sum(a$apta %in% TRUE & !(a$status %in% c("ND", "T2D") & a$humano %in% TRUE & a$basal %in% TRUE & a$cultivado %in% FALSE)), "ERRO")
  }
  el <- le_s("output/02_metadados/elegibilidade.csv")
  gerais("02", "elegibilidade.csv", el, obrig = c("gse", "categoria"))
  if (!is.null(el)) {
    cn <- intersect(c("n_amostras", "n_aptas", "doadores_aptos", "F40a60_T2D", "F40a60_ND", "F_T2D", "F_ND", "M_T2D", "M_ND"), names(el))
    verif("02", "elegibilidade.csv", "contagens >= 0", sum(sapply(el[cn], function(v) sum(v < 0, na.rm = TRUE))), "ERRO")
    verif("02", "elegibilidade.csv", "elegível => >= 2 doadoras DM2 e ND de 40-60", sum(el$categoria == "elegivel" & (el$F40a60_T2D < 2 | el$F40a60_ND < 2)), "ERRO")
    fr <- intersect(c("frac_sexo", "frac_idade", "frac_status"), names(el))
    verif("02", "elegibilidade.csv", "frações em [0, 1]", sum(sapply(el[fr], function(v) sum(v < 0 | v > 1, na.rm = TRUE))), "ERRO")
  }
  # ---------------- etapa 04 ----------------
  inv <- le_s("output/04_processamento/inventario.csv")
  gerais("04", "inventario.csv", inv, obrig = c("gse", "categoria"), chave = "gse")
  if (!is.null(inv)) verif("04", "inventario.csv", "pronto para a etapa 05 => >= 2 doadoras DM2 e ND de 40-60", sum(inv$categoria == "pronto para a etapa 05" & (inv$F40a60_T2D < 2 | inv$F40a60_ND < 2)), "ERRO")
  for (g in inv$gse[is.na(inv$erro %||% NA)]) {
    d <- file.path("output/04_processamento", g); am <- le_s(file.path(d, "amostras_qc.csv"))
    gerais("04", paste0(g, "/amostras_qc.csv"), am, obrig = c("coluna", "mantida", "status"), chave = "coluna", ignorar_constantes = "n_celulas")
    if (is.null(am)) next
    if (!is.null(a) && "gsm" %in% names(am)) { st2 <- a$status[match(paste(g, am$gsm), paste(a$gse, a$gsm))]; dif <- !is.na(st2) & !is.na(am$status) & st2 != am$status
      verif("04", paste0(g, "/amostras_qc.csv"), "status igual ao da curadoria da etapa 02 (senão, reprocessar o estudo na etapa 04)", sum(dif), "ERRO", utils::head(am$gsm[dif], 3)) }
    verif("04", paste0(g, "/amostras_qc.csv"), "mantida <=> sem motivo de retirada", sum(am$mantida != is.na(am$motivo_retirada)), "ERRO")
    x <- readRDS(file.path(d, "expressao.rds")); ex <- x$expressao
    verif("04", paste0(g, "/expressao.rds"), "expressão sem NA/infinito", naofin(ex), "ERRO")
    verif("04", paste0(g, "/expressao.rds"), "genes sem nome duplicado", sum(duplicated(rownames(ex))), "ERRO", utils::head(rownames(ex)[duplicated(rownames(ex))], 3))
    verif("04", paste0(g, "/expressao.rds"), "colunas da expressão = amostras do controle de qualidade", length(setdiff(am$coluna, colnames(ex))), "ERRO", utils::head(setdiff(am$coluna, colnames(ex)), 3))
    verif("04", paste0(g, "/amostras_qc.csv"), "nome de coluna não é só número (seria lido como posição)", sum(grepl("^[0-9]+$", am$coluna)), "ERRO", utils::head(am$coluna[grepl("^[0-9]+$", am$coluna)], 3))
    verif("04", paste0(g, "/expressao.rds"), "nenhuma amostra constante", sum(apply(ex, 2, stats::sd) == 0), "ERRO")
    verif("04", paste0(g, "/expressao.rds"), "valores na escala log2 (entre -10 e 30)", sum(ex < -10 | ex > 30), "ALERTA", sprintf("faixa %.1f a %.1f", min(ex), max(ex)))
    if (!is.null(x$contagens)) verif("04", paste0(g, "/expressao.rds"), "contagens inteiras e >= 0", sum(x$contagens < 0 | x$contagens != round(x$contagens)), "ERRO")
  }
  # ---------------- etapa 05 ----------------
  est <- le_s("output/05_meta/estudos.csv")
  gerais("05", "estudos.csv", est, obrig = c("gse", "tecido", "uso"), chave = "gse")
  if (!is.null(est)) verif("05", "estudos.csv", "estudos com alerta de sanidade (sinal fora do esperado)", sum(!is.na(est$alerta)), "ALERTA", paste(est$gse[!is.na(est$alerta)], est$frac_p05[!is.na(est$alerta)]))
  for (g in est$gse) { efeitos("05", paste0("estudos/", g, "/efeitos_genes.csv"), le_s(file.path("output/05_meta/estudos", g, "efeitos_genes.csv")))
                       efeitos("05", paste0("estudos/", g, "/efeitos_vias.csv"), le_s(file.path("output/05_meta/estudos", g, "efeitos_vias.csv"))) }
  for (t in unique(est$tecido[est$uso == "principal"])) { meta("05", paste0(t, "/meta_genes.csv"), le_s(file.path("output/05_meta", t, "meta_genes.csv")))
                                                         meta("05", paste0(t, "/meta_vias.csv"), le_s(file.path("output/05_meta", t, "meta_vias.csv"))) }
  # ---------------- etapa 06 ----------------
  for (t in list.dirs("output/06_redes", full.names = FALSE, recursive = FALSE)) {
    m <- le_s(file.path("output/06_redes", t, "meta_modulos.csv")); if (is.null(m)) next
    meta("06", paste0(t, "/meta_modulos.csv"), m)
    m$selecao[is.na(m$selecao)] <- ""
    verif("06", paste0(t, "/meta_modulos.csv"), "seleção num conjunto permitido", sum(!m$selecao %in% c("", "significativo", "sugestivo", "exploratório", "exploratório (≥ 2 estudos)", "exploratório (1 estudo)", "exploratório (efeito fixo, 2 estudos)")), "ERRO", utils::head(unique(m$selecao), 3))
    verif("06", paste0(t, "/meta_modulos.csv"), "status de preservação preenchido", sum(is.na(m$preservacao_status %||% NA)), "ERRO")
    verif("06", paste0(t, "/meta_modulos.csv"), "módulo selecionado não pode estar 'não preservado'", sum(nzchar(m$selecao) & m$preservado %in% FALSE), "ERRO")
    verif("06", paste0(t, "/meta_modulos.csv"), "módulos com >= 30 genes", sum(m$genes < 30, na.rm = TRUE), "ERRO")
    k <- le_s(file.path("output/06_redes", t, "modulos_genes.csv"))
    gerais("06", paste0(t, "/modulos_genes.csv"), k, obrig = c("gene", "modulo"), chave = "gene")
    if (!is.null(k)) verif("06", paste0(t, "/modulos_genes.csv"), "kME em [-1, 1]", sum(!is.na(k$kME_min) & abs(k$kME_min) > 1 + 1e-9), "ERRO")
  }
  # ---------------- etapa 07 ----------------
  gt <- le_s("output/07_enriquecimento/gsea_tecidos.csv")
  gerais("07", "gsea_tecidos.csv", gt, obrig = c("tecido", "colecao", "via", "g", "p", "fdr"), chave = c("tecido", "colecao", "via"))
  if (!is.null(gt)) {
    gt$nivel[is.na(gt$nivel)] <- ""
    verif("07", "gsea_tecidos.csv", "nível num conjunto permitido", sum(!gt$nivel %in% c("", "significativo", "sugestivo", "exploratório", "exploratório (≥ 2 estudos)", "exploratório (1 estudo)", "exploratório (efeito fixo, 2 estudos)")), "ERRO")
    verif("07", "gsea_tecidos.csv", "p e FDR do escore em (0, 1]", fora01(gt$p) + fora01(gt$fdr), "ERRO")
    verif("07", "gsea_tecidos.csv", "FDR >= p", sum(gt$fdr < gt$p - 1e-12, na.rm = TRUE), "ERRO")
    verif("07", "gsea_tecidos.csv", "via selecionada em tecido com 2+ estudos tem 2+ estudos medidos", sum(nzchar(gt$nivel) & gt$nivel != "exploratório (1 estudo)" & gt$estudos < 2 & !gt$tecido %in% "figado"), "ERRO")
    verif("07", "gsea_tecidos.csv", "NES finito quando presente", sum(!is.na(gt$NES) & !is.finite(gt$NES)), "ERRO")
  }
  # ---------------- etapa 08 ----------------
  pc <- le_s("output/08_painel/candidatos.csv")
  gerais("08", "candidatos.csv", pc, obrig = c("tecido", "gene", "g", "pontos", "evidencia"), chave = c("tecido", "gene"))
  if (!is.null(pc)) {
    crit <- intersect(c("replicado", "gene_chave", "via_forte_ou_convergente", "ligacao_outro_tecido", "robusto_loo"), names(pc))
    verif("08", "candidatos.csv", "critérios sem NA", sum(sapply(pc[crit], function(v) sum(is.na(v)))), "ERRO")
    verif("08", "candidatos.csv", "pontos = soma dos critérios (0 a 5)", sum(pc$pontos != rowSums(pc[crit]) | pc$pontos < 0 | pc$pontos > 5), "ERRO")
    verif("08", "candidatos.csv", "replicado só com 2+ estudos", sum(pc$replicado %in% TRUE & pc$estudos < 2), "ERRO")
  }
  # ---------------- etapa 09 (validação com célula única; pedido do usuário, 08/10/2026) ----------------
  d9 <- "output/09_validacao_celula"
  if (dir.exists(d9)) {
    VC <- tryCatch(ler_config("config/validacao.yaml"), error = function(e) NULL); tipos9 <- names(VC$tipos)
    fr <- le_s(file.path(d9, "proporcoes_estimadas.csv"))
    gerais("09", "proporcoes_estimadas.csv", fr, obrig = c("gse", "coluna"), chave = c("gse", "coluna"))
    if (!is.null(fr)) { tc <- intersect(tipos9, names(fr)); M <- as.matrix(fr[tc])
      verif("09", "proporcoes_estimadas.csv", "proporções em [0, 1]", sum(M < -1e-9 | M > 1 + 1e-9, na.rm = TRUE), "ERRO")
      verif("09", "proporcoes_estimadas.csv", "proporções de cada amostra somam 1", sum(abs(rowSums(M) - 1) > 1e-3), "ERRO", utils::head(paste(fr$gse, fr$coluna)[abs(rowSums(M) - 1) > 1e-3], 3))
      verif("09", "proporcoes_estimadas.csv", "todos os estudos da deconvolução presentes", length(setdiff(unlist(VC$estudos_deconvolucao), fr$gse)), "ERRO", setdiff(unlist(VC$estudos_deconvolucao), fr$gse))
      for (g in unique(fr$gse)) { q <- le_s(file.path("output/04_processamento", g, "amostras_qc.csv")); if (is.null(q)) next
        verif("09", "proporcoes_estimadas.csv", sprintf("%s: amostras deconvoluídas = amostras mantidas na etapa 04", g), as.integer(sum(fr$gse == g) != sum(q$mantida %in% TRUE)), "ERRO", sprintf("%d x %d", sum(fr$gse == g), sum(q$mantida %in% TRUE))) }
      verif("09", "proporcoes_estimadas.csv", "nenhum tipo celular estimado como 0 em todas as amostras de um estudo", sum(sapply(split(fr[tc], fr$gse), function(x) sum(colSums(x) == 0))), "ALERTA") }
    vd <- le_s(file.path(d9, "deconvolucao_validacao.csv"))
    gerais("09", "deconvolucao_validacao.csv", vd, obrig = c("tipo", "correlacao"), chave = "tipo")
    if (!is.null(vd)) { for (t in intersect(c("estrelada", "beta", "alfa"), vd$tipo)) { r <- vd$correlacao[vd$tipo == t]
        verif("09", "deconvolucao_validacao.csv", sprintf("deconvolução confiável para %s (correlação com a composição verdadeira >= 0,6)", t), as.integer(is.na(r) || r < 0.6), "ALERTA", sprintf("%.2f", r)) }
      e <- vd$erro_medio_pp[vd$tipo == "estrelada"]
      verif("09", "deconvolucao_validacao.csv", "erro médio da estrelada <= 3 pontos percentuais", as.integer(length(e) && e > 3), "ALERTA", sprintf("%.1f", e))
      verif("09", "deconvolucao_validacao.csv", "médias estimada e verdadeira em [0, 100]", sum(vd$verdadeira_media < 0 | vd$verdadeira_media > 100 | vd$estimada_media < 0 | vd$estimada_media > 100), "ERRO") }
    cv <- le_s(file.path(d9, "composicao_verdadeira_GSE221156.csv"))
    gerais("09", "composicao_verdadeira_GSE221156.csv", cv, obrig = c("tipo", "DM2", "ND"), chave = "tipo")
    if (!is.null(cv)) verif("09", "composicao_verdadeira_GSE221156.csv", "composição de cada grupo soma 100%", sum(abs(c(sum(cv$DM2), sum(cv$ND)) - 100) > 0.6), "ERRO", sprintf("DM2 %.1f; ND %.1f", sum(cv$DM2), sum(cv$ND)))
    lc <- le_s(file.path(d9, "localizacao_genes.csv"))
    gerais("09", "localizacao_genes.csv", lc, obrig = c("gene", "tipo_maior"), chave = "gene")
    if (!is.null(lc)) { verif("09", "localizacao_genes.csv", "fração no tipo de maior expressão em (0, 1]", fora01(lc$frac_no_tipo_maior), "ERRO")
      verif("09", "localizacao_genes.csv", "tipo de maior expressão num tipo configurado", sum(!lc$tipo_maior %in% tipos9), "ERRO")
      verif("09", "localizacao_genes.csv", "CPM >= 0", sum(as.matrix(lc[intersect(tipos9, names(lc))]) < 0, na.rm = TRUE), "ERRO")
      pn <- le_s("output/08_painel/painel.csv"); pg <- if (!is.null(pn)) unique(pn$gene[pn$tecido == "ilhotas"]) else character()
      verif("09", "localizacao_genes.csv", "todos os genes do painel das ilhotas localizados", length(setdiff(pg, lc$gene)), "ALERTA", setdiff(pg, lc$gene)) }
    for (a in c("efeito_dentro_dos_tipos.csv", "modulo_dentro_dos_tipos.csv")) { x <- le_s(file.path(d9, a))
      gerais("09", a, x, obrig = c("tipo", "id", "g", "p"), chave = c("tipo", "id"), ignorar_constantes = c("n1", "n2"))
      if (!is.null(x)) { verif("09", a, "g finito e p em (0, 1]", naofin(x$g) + fora01(x$p), "ERRO"); verif("09", a, "n1 e n2 >= 2", sum(x$n1 < 2 | x$n2 < 2), "ERRO") } }
    meta("09", "composicao_meta.csv", le_s(file.path(d9, "composicao_meta.csv")))
    pa <- le_s(file.path(d9, "programa_ajustado_estudos.csv"))
    gerais("09", "programa_ajustado_estudos.csv", pa, obrig = c("gse", "modelo", "ajuste", "id", "g", "var_g", "p"), chave = c("gse", "modelo", "ajuste", "id"), ignorar_constantes = c("n1", "n2"))
    if (!is.null(pa)) { verif("09", "programa_ajustado_estudos.csv", "g finito, variância > 0 e p em (0, 1]", naofin(pa$g) + sum(!is.finite(pa$var_g) | pa$var_g <= 0) + fora01(pa$p), "ERRO")
      r <- stats::median(abs(pa$g / sqrt(pa$var_g)) / abs(pa$t), na.rm = TRUE)
      verif("09", "programa_ajustado_estudos.csv", "precisão de g coerente com o limma (mediana |g/ep| / |t| entre 0,85 e 1,15)", as.integer(!is.finite(r) || r < 0.85 || r > 1.15), "ALERTA", sprintf("%.2f", r)) }
    pm <- le_s(file.path(d9, "programa_ajustado_meta.csv"))
    gerais("09", "programa_ajustado_meta.csv", pm, obrig = c("modelo", "ajuste", "id", "g", "p"), chave = c("modelo", "ajuste", "id"))
    if (!is.null(pm)) verif("09", "programa_ajustado_meta.csv", "efeito dentro do próprio IC 95% e p em (0, 1]", sum(pm$g < pm$ic_inf - 1e-9 | pm$g > pm$ic_sup + 1e-9, na.rm = TRUE) + fora01(pm$p), "ERRO")
    sc <- le_s(file.path(d9, "programa_sem_e_com_ajuste.csv"))
    gerais("09", "programa_sem_e_com_ajuste.csv", sc, obrig = c("id", "g_sem", "g_com", "reducao_pct"), chave = "id")
    if (!is.null(sc)) { verif("09", "programa_sem_e_com_ajuste.csv", "redução = 1 - g com ajuste / g sem ajuste", sum(abs(round(100 * (1 - sc$g_com / sc$g_sem)) - sc$reducao_pct) > 1, na.rm = TRUE), "ERRO")
      if (!is.null(pm)) { a <- pm[pm$modelo == "variância com todas as amostras" & pm$ajuste == "sem ajuste (mesmos estudos)", ]
        verif("09", "programa_sem_e_com_ajuste.csv", "g sem ajuste = meta-análise correspondente", sum(abs(sc$g_sem - a$g[match(sc$id, a$id)]) > 1e-6, na.rm = TRUE), "ERRO") }
      verif("09", "programa_sem_e_com_ajuste.csv", "sem e com ajuste comparados nos mesmos estudos", sum(sc$estudos_com != pm$estudos[match(paste("variância com todas as amostras", "sem ajuste (mesmos estudos)", sc$id), paste(pm$modelo, pm$ajuste, pm$id))], na.rm = TRUE), "ERRO")
      verif("09", "programa_sem_e_com_ajuste.csv", "ajuste não inverte o sentido do programa", sum(sign(sc$g_sem) != sign(sc$g_com), na.rm = TRUE), "ALERTA", sc$id[which(sign(sc$g_sem) != sign(sc$g_com))]) }
  }
  # ---------------- etapa 10 (curva ROC; pedido do usuário, 09/10/2026) ----------------
  d10 <- "output/10_roc"
  if (dir.exists(d10)) {
    x <- le_s(file.path(d10, "deixar_um_de_fora.csv"))
    gerais("10", "deixar_um_de_fora.csv", x, obrig = c("tecido", "estudo_testado", "modulo"), chave = c("tecido", "estudo_testado"))
    if (!is.null(x)) { verif("10", "deixar_um_de_fora.csv", "AUC e IC em [0, 1] e IC contém a AUC", sum(!is.na(x$auc) & (x$auc < 0 | x$auc > 1 | x$ic_inf > x$auc + 1e-9 | x$ic_sup < x$auc - 1e-9)), "ERRO")
      verif("10", "deixar_um_de_fora.csv", "p (Wilcoxon e vs genes sorteados) em (0, 1]", fora01(x$p_wilcoxon) + fora01(x$p_nulo_genes), "ERRO")
      verif("10", "deixar_um_de_fora.csv", "estudo testado fora do treino", sum(mapply(function(s, t) s %in% strsplit(t, ";")[[1]], x$estudo_testado, x$treino)), "ERRO")
      verif("10", "deixar_um_de_fora.csv", "todas as rodadas avaliáveis", sum(is.na(x$auc)), "ALERTA", x$estudo_testado[is.na(x$auc)]) }
    m <- le_s(file.path(d10, "meta_auc.csv"))
    gerais("10", "meta_auc.csv", m, obrig = c("tecido", "auc_combinada", "p_hk"), chave = "tecido")
    if (!is.null(m)) verif("10", "meta_auc.csv", "AUC combinada e IC em [0, 1]", sum(m$auc_combinada < 0 | m$auc_combinada > 1 | m$ic_inf < 0 | m$ic_sup > 1, na.rm = TRUE), "ERRO")
    e <- le_s(file.path(d10, "validacao_externa.csv"))
    if (!is.null(e)) { gerais("10", "validacao_externa.csv", e, obrig = c("tecido", "estudo"), chave = c("tecido", "estudo"))
      ep <- le_s("output/05_meta/estudos.csv")
      verif("10", "validacao_externa.csv", "estudo externo não está na análise principal", sum(e$estudo %in% ep$gse[ep$uso == "principal"]), "ERRO", e$estudo[e$estudo %in% ep$gse[ep$uso == "principal"]])
      verif("10", "validacao_externa.csv", "AUC externa em [0, 1]", sum(!is.na(e$auc) & (e$auc < 0 | e$auc > 1)), "ERRO") }
  }
  # ---------------- revisão de 11/10/2026: etapa 06 (estudos testados), 10b, 10c e validação cruzada ----------------
  ep6 <- le_s("output/05_meta/estudos.csv")
  if (!is.null(ep6)) for (tec in unique(ep6$tecido[ep6$uso == "principal"])) {
    em <- le_s(file.path("output/06_redes", tec, "efeitos_modulos_estudos.csv")); if (is.null(em)) next
    esp <- ep6$gse[ep6$uso == "principal" & ep6$tecido == tec]; falt <- setdiff(esp, unique(em$gse))
    verif("06", paste0(tec, "/efeitos_modulos_estudos.csv"), "todos os estudos principais do tecido têm o teste dos módulos (falha de ajuste não some em silêncio)", length(falt), "ERRO", falt) }
  okauc <- function(a, i, s) sum(!is.na(a) & (a < 0 | a > 1 | (!is.na(i) & i > a + 1e-9) | (!is.na(s) & s < a - 1e-9)))
  if (dir.exists(d10)) {
    for (f in c("otimizada_deixar_um_de_fora.csv", "otimizada_todos_tecidos.csv", "painel_roc_estudos.csv", "validacao_cruzada_repeticoes.csv")) { x <- le_s(file.path(d10, f)); if (is.null(x)) next
      verif("10", f, "AUC e IC em [0, 1] e IC contém a AUC", okauc(x$auc, x$ic_inf, x$ic_sup), "ERRO"); verif("10", f, "p (Wilcoxon) em (0, 1]", fora01(x$p_wilcoxon), "ERRO") }
    for (f in c("otimizada_meta.csv", "otimizada_todos_tecidos_meta.csv", "painel_roc_meta.csv", "painel_roc_comparacao.csv")) { x <- le_s(file.path(d10, f)); if (is.null(x)) next
      verif("10", f, "AUC combinada e IC em [0, 1]", sum(!is.na(x$auc) & (x$auc < 0 | x$auc > 1 | x$ic_inf < 0 | x$ic_sup > 1)), "ERRO"); verif("10", f, "p em (0, 1]", fora01(x$p), "ERRO") }
    x <- le_s(file.path(d10, "otimizada_todos_tecidos.csv"))
    if (!is.null(x)) verif("10", "otimizada_todos_tecidos.csv", "todos os tecidos principais testados (deixar um tecido de fora)", length(setdiff(unique(ep6$tecido[ep6$uso == "principal"]), x$tecido_testado)), "ERRO")
    x <- le_s(file.path(d10, "otimizada_regras_internas.csv"))
    if (!is.null(x)) verif("10", "otimizada_regras_internas.csv", "AUC interna em [0, 1]", sum(!is.na(x$auc_interna) & (x$auc_interna < 0 | x$auc_interna > 1)), "ERRO")
    x <- le_s(file.path(d10, "painel_roc_genes_estudos.csv"))
    if (!is.null(x)) verif("10", "painel_roc_genes_estudos.csv", "AUC por gene em [0, 1]", sum(!is.na(x$auc) & (x$auc < 0 | x$auc > 1)), "ERRO")
    vp <- le_s(file.path(d10, "validacao_cruzada_partes.csv")); vr <- le_s(file.path(d10, "validacao_cruzada_repeticoes.csv")); OC <- tryCatch(ler_config("config/roc.yaml"), error = function(e) NULL)
    if (!is.null(vp) && !is.null(vr)) {
      vcfg <- OC$validacao_cruzada
      verif("10", "validacao_cruzada_repeticoes.csv", "número de repetições igual ao de config/roc.yaml", sum(table(vr$tecido) != vcfg$repeticoes), "ERRO")
      verif("10", "validacao_cruzada_partes.csv", "cada repetição tem todas as partes", sum(table(paste(vp$tecido, vp$repeticao)) != vcfg$dobras), "ERRO")
      s1 <- stats::aggregate(cbind(n_T2D, n_ND) ~ tecido + repeticao, vp, sum); s2 <- merge(s1, vr, by = c("tecido", "repeticao"), suffixes = c("_partes", ""))
      verif("10", "validacao_cruzada_partes.csv", "cada mulher testada uma vez por repetição (soma das partes = total)", sum(s2$n_T2D_partes != s2$n_T2D | s2$n_ND_partes != s2$n_ND), "ERRO")
      verif("10", "validacao_cruzada_partes.csv", "genes do escore >= mínimo do teste", sum(vp$genes < OC$min_genes_teste), "ERRO")
      verif("10", "validacao_cruzada_partes.csv", "módulo escolhido no treino é um módulo selecionado na etapa 06", sum(!vp$modulo_igual_etapa06), "ALERTA") }
    vo <- le_s(file.path(d10, "otimizada_validacao_cruzada_repeticoes.csv"))
    if (!is.null(vo)) { verif("10", "otimizada_validacao_cruzada_repeticoes.csv", "AUC e IC em [0, 1] e IC contém a AUC", okauc(vo$auc_otimizada, vo$ic_inf, vo$ic_sup), "ERRO")
      verif("10", "otimizada_validacao_cruzada_repeticoes.csv", "número de repetições igual ao de config/roc.yaml", sum(table(vo$tecido) != OC$validacao_cruzada$repeticoes), "ERRO") }
    x <- le_s(file.path(d10, "rede_por_rodada.csv"))
    if (!is.null(x)) { verif("10", "rede_por_rodada.csv", "AUC e IC em [0, 1] e IC contém a AUC", okauc(x$auc, x$ic_inf, x$ic_sup), "ERRO")
      verif("10", "rede_por_rodada.csv", "estudo testado fora da construção da rede da rodada", sum(mapply(function(s, t) s %in% strsplit(t, ";")[[1]], x$estudo_testado, x$construcao_rede)), "ERRO")
      verif("10", "rede_por_rodada.csv", "estudo testado fora do treino", sum(mapply(function(s, t) s %in% strsplit(t, ";")[[1]], x$estudo_testado, x$treino)), "ERRO") }
  }
  do.call(rbind, .chk$t)
}
