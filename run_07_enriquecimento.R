###############################################################################
#  run_07_enriquecimento.R - executa a ETAPA 07 (enriquecimento) e gera o relatório
#  Uso: "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_07_enriquecimento.R
#  Requer as etapas 05 e 06. Saídas: output/07_enriquecimento/*.csv, docs/figuras/gsea_hallmark.png,
#  docs/validacao_07_enriquecimento.md, docs/etapa_07_enriquecimento.docx
###############################################################################
suppressPackageStartupMessages({ library(dplyr) })
for (f in c("R/00_utils.R", "R/05_meta.R", "R/07_enriquecimento.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
RC <- ler_config("config/redes.yaml"); MC <- ler_config("config/meta.yaml")
options(vias_competitivo = !isFALSE(MC$vias$competitivo))       # escore de via competitivo (08/10/2026)
inv_all <- utils::read.csv("output/04_processamento/inventario.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
est05 <- utils::read.csv("output/05_meta/estudos.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8"); est05 <- est05[est05$uso == "principal", ]
tecidos <- sort(unique(est05$tecido)); conj <- conjuntos_colecoes(RC)
d <- pasta("output", "07_enriquecimento")
log_msg("ETAPA 07 | coleções: %s", paste(sprintf("%s (%d conjuntos)", names(conj), lengths(conj)), collapse = ", "))

# 7.2 GSEA por estudo e por tecido (ordem = g das mulheres de 40-60, etapa 05)
# cache da GSEA (lenta: ~9.400 conjuntos x 19 listas); apagar output/07_enriquecimento/cache_gsea.rds para refazer
arq_cache <- file.path(d, "cache_gsea.rds")
# revisão de código (08/10/2026): o cache só vale se as entradas forem as mesmas (efeitos dos genes, parâmetros, coleções)
entradas <- c(file.path("output/05_meta/estudos", est05$gse, "efeitos_genes.csv"), file.path("output/05_meta", tecidos, "meta_genes.csv"))
f_ass <- tempfile(); saveRDS(list(md5 = unname(tools::md5sum(entradas)), par = RC$enriquecimento, conj = lapply(conj, function(x) lapply(x, sort))), f_ass)
assinatura <- unname(tools::md5sum(f_ass)); unlink(f_ass)
cg0 <- if (file.exists(arq_cache)) readRDS(arq_cache) else NULL
if (!is.null(cg0) && identical(cg0$assinatura, assinatura)) { gs_est <- cg0$gs_est; gs_tec <- cg0$gs_tec; log_msg("ETAPA 07 | GSEA: cache válido reutilizado") } else {
gs_est <- do.call(rbind, lapply(est05$gse, function(g) { e <- utils::read.csv(file.path("output/05_meta/estudos", g, "efeitos_genes.csv"), stringsAsFactors = FALSE)
  r <- gsea(RC, stats::setNames(e$g, e$id), conj); if (!is.null(r)) data.frame(tecido = est05$tecido[est05$gse == g], gse = g, r) }))
gs_tec <- do.call(rbind, lapply(tecidos, function(tec) { m <- utils::read.csv(file.path("output/05_meta", tec, "meta_genes.csv"), stringsAsFactors = FALSE)
  r <- gsea(RC, stats::setNames(m$g, m$id), conj); if (!is.null(r)) data.frame(tecido = tec, estudos = length(est05$gse[est05$tecido == tec]), r) }))
saveRDS(list(assinatura = assinatura, gs_est = gs_est, gs_tec = gs_tec), arq_cache) }
names(gs_tec)[names(gs_tec) %in% c("p", "fdr")] <- c("p_gsea", "fdr_gsea")
# Significância (correção de 07/10/2026): a GSEA pré-ordenada trata genes da mesma via como independentes e
# ficou inflada (até 38 de 50 vias Hallmark com FDR < 0,05 em estudos com 2 x 6 mulheres). O teste das vias
# passa a ser o escore por amostra + o mesmo modelo e a mesma meta-análise da etapa 05 (respeita a correlação
# entre genes); a GSEA fica para o sentido (NES) e os genes que puxam a via (leading edge).
codif <- genes_codificantes()
E07 <- lapply(stats::setNames(est05$gse, est05$gse), function(g) carregar_estudo(g, inv_all, NULL, codif))   # carregados uma vez (10/10/2026)
sc_est <- lapply(est05$gse, function(g) { est <- E07[[g]]
  lapply(conj, function(cj) { S <- escores_vias(est$ex, cj, MC$vias$min_genes); ajustar(MC, est, Y = S, metodo = "limma", so_alvo = identical(MC$modelo_principal, "so_F40a60")) }) })
names(sc_est) <- est05$gse
sc_tec <- do.call(rbind, lapply(tecidos, function(tec) do.call(rbind, lapply(names(conj), function(cl) {
  efs <- lapply(est05$gse[est05$tecido == tec], function(g) sc_est[[g]][[cl]]); names(efs) <- est05$gse[est05$tecido == tec]; efs <- Filter(Negate(is.null), efs)
  m <- meta_tecido(efs, metodo = MC$meta_metodo); data.frame(tecido = tec, colecao = cl, via = m$id, g = m$g, ic_inf = m$ic_inf, ic_sup = m$ic_sup, p = m$p, fdr = m$fdr,
                                                            estudos = m$estudos, mesmo_sentido = m$mesmo_sentido, p_stouffer = m$p_stouffer, p_rop2 = m$p_rop2, fdr_rop2 = m$fdr_rop2,
                                                            p_heterogeneidade = m$p_heterogeneidade, p_fe = m$p_fe) }))))
# calibração empírica (revisão de 10/10/2026): p e p_fe paramétricos guardados; p, p_fe e FDR passam a ser os empíricos
tam_via <- unlist(lapply(names(conj), function(cl) stats::setNames(lengths(conj[[cl]]), paste(cl, names(conj[[cl]])))))
sc_tec$tamanho <- unname(tam_via[paste(sc_tec$colecao, sc_tec$via)])
sc_tec$p_parametrico <- sc_tec$p; sc_tec$p_fe_parametrico <- sc_tec$p_fe; sc_tec$fdr_parametrico <- sc_tec$fdr; sc_tec$p_empirico <- NA_real_
for (tec in tecidos) { gses <- est05$gse[est05$tecido == tec]; k <- sc_tec$tecido == tec
  nul <- nulo_vias_tecido(MC, E07, gses, sc_tec$tamanho[k][!is.na(sc_tec$tamanho[k])], RC$enriquecimento$calibracao_sorteios %||% 2000, RC$enriquecimento$calibracao_semente %||% 1)
  # só corrige PARA CIMA: p final = maior entre paramétrico e empírico. Conjuntos sorteados não têm a coexpressão das vias
  # reais; onde o paramétrico já é conservador (sorteados com p < 0,05 abaixo de 5%), o empírico ficaria liberal demais
  sc_tec$p_empirico[k] <- p_empirico(sc_tec$p_parametrico[k], sc_tec$tamanho[k], nul$p, nul$tamanho)
  sc_tec$p[k] <- pmax(sc_tec$p_parametrico[k], sc_tec$p_empirico[k], na.rm = TRUE)
  if (any(!is.na(nul$p_fe))) sc_tec$p_fe[k] <- pmax(sc_tec$p_fe_parametrico[k], p_empirico(sc_tec$p_fe_parametrico[k], sc_tec$tamanho[k], nul$p_fe, nul$tamanho), na.rm = TRUE)
  log_msg("ETAPA 07 | calibração %s: %d conjuntos sorteados; p < 0,05 entre os sorteados %.3f (esperado 0,05)", tec, nrow(nul), mean(nul$p < 0.05, na.rm = TRUE)) }
ev <- ifelse(sc_tec$estudos >= 2, "rep", "desc")
sc_tec$fdr <- stats::ave(sc_tec$p, sc_tec$tecido, sc_tec$colecao, ev, FUN = function(z) stats::p.adjust(z, "BH"))
gs_tec <- merge(sc_tec, gs_tec[, setdiff(names(gs_tec), "estudos")], by = c("tecido", "colecao", "via"), all.x = TRUE)
gs_tec$nivel <- ifelse(gs_tec$fdr < RC$teste$fdr, "significativo", ifelse(gs_tec$fdr < RC$teste$fdr_sugestivo, "sugestivo",
                  ifelse(gs_tec$p < RC$teste$p_exploratorio & gs_tec$mesmo_sentido == gs_tec$estudos, "exploratório", "")))
# em tecido com 2+ estudos, via medida em 1 só estudo é descoberta, não replicação: não é selecionada
# ("todos os estudos no mesmo sentido" seria trivial com 1 estudo); o fígado (1 estudo) é todo descoberta
n_tec <- table(est05$tecido)
gs_tec$evidencia <- ifelse(gs_tec$estudos >= 2, "replicado", "descoberta")
gs_tec$nivel[as.integer(n_tec[gs_tec$tecido]) >= 2 & gs_tec$estudos < 2] <- ""
# o nível "exploratório" (todos os estudos no mesmo sentido) exige 2+ estudos: com 1 estudo a concordância é trivial (777 vias passavam).
# No fígado (1 estudo), as vias com p < 0,05 entram logo abaixo como "exploratório (1 estudo)" (pedido do usuário, 08/10/2026); ~5% delas se esperam ao acaso
gs_tec$nivel[gs_tec$nivel == "exploratório" & gs_tec$estudos < 2] <- ""
# tecido com exatamente 2 estudos (músculo, sangue): nível exploratório pelo efeito fixo (decisão do usuário, 08/10/2026)
if (isTRUE(RC$teste$efeito_fixo_2_estudos)) { k2 <- as.integer(n_tec[gs_tec$tecido]) == 2 & gs_tec$estudos == 2
  gs_tec$nivel[k2 & gs_tec$nivel == "exploratório"] <- ""
  gs_tec$nivel[k2 & !nzchar(gs_tec$nivel) & !is.na(gs_tec$p_fe) & gs_tec$p_fe < RC$teste$p_exploratorio & gs_tec$mesmo_sentido == gs_tec$estudos] <- "exploratório (efeito fixo, 2 estudos)" }
# efeito em pelo menos 2 estudos (rOP r = 2), quando a via não foi selecionada pelos critérios acima (08/10/2026)
gs_tec$nivel[!nzchar(gs_tec$nivel) & !is.na(gs_tec$fdr_rop2) & gs_tec$fdr_rop2 < RC$teste$fdr_rop2] <- "exploratório (≥ 2 estudos)"
# tecido com 1 estudo (fígado): p < 0,05 vira "exploratório (1 estudo)" (pedido do usuário, 08/10/2026)
gs_tec$nivel[as.integer(n_tec[gs_tec$tecido]) == 1 & !nzchar(gs_tec$nivel) & gs_tec$p < RC$teste$p_exploratorio] <- "exploratório (1 estudo)"
gs_tec$nivel[is.na(gs_tec$nivel)] <- ""                                    # via sem FDR/p (NA) não é selecionada
# consistência: em quantos estudos do tecido o NES tem o mesmo sinal do tecido
gs_tec$estudos_mesmo_sentido <- gs_tec$mesmo_sentido                   # concordância do efeito pelo escore (teste principal)
# concordância do NES da GSEA entre os estudos do tecido (transparência; revisão de 08/10/2026)
gs_tec$estudos_mesmo_sentido_nes <- mapply(function(tec, cl, v, nes) { if (is.na(nes)) return(NA_integer_)
  x <- gs_est[gs_est$tecido == tec & gs_est$colecao == cl & gs_est$via == v, ]; sum(sign(x$NES) == sign(nes)) }, gs_tec$tecido, gs_tec$colecao, gs_tec$via, gs_tec$NES)
# o leading edge só representa a via se o NES tiver o mesmo sinal do efeito pelo escore
gs_tec$leading_edge_coerente <- !is.na(gs_tec$NES) & sign(gs_tec$NES) == sign(gs_tec$g)
escrever_csv(gs_est, file.path(d, "gsea_estudos.csv")); escrever_csv(gs_tec, file.path(d, "gsea_tecidos.csv"))
log_msg("ETAPA 07 | vias por tecido: %d; escore FDR < 0,05: %d, < 0,10: %d, exploratórias: %d (GSEA pré-ordenada, otimista: FDR < 0,05 em %d)", nrow(gs_tec),
        sum(gs_tec$nivel == "significativo"), sum(gs_tec$nivel == "sugestivo"), sum(startsWith(gs_tec$nivel, "exploratório")), sum(gs_tec$fdr_gsea < 0.05, na.rm = TRUE))

# 7.1 ORA de todos os módulos preservados (descrição); os selecionados alimentam a convergência
mods <- rbind_preenche(lapply(tecidos, function(tec) { f <- file.path("output/06_redes", tec, "meta_modulos.csv"); if (file.exists(f)) data.frame(tecido = tec, utils::read.csv(f, stringsAsFactors = FALSE)) }))
mods$selecao[is.na(mods$selecao)] <- ""                                    # campo vazio lido como NA (NA passava em nzchar)
ora_m <- do.call(rbind, lapply(seq_len(nrow(mods)), function(i) {
  if (mods$preservado[i] %in% FALSE) return(NULL)                        # não preservado / falhou; "não avaliável" (fígado) é descrito
  if (is.na(mods$selecao[i])) mods$selecao[i] <<- ""
  k <- utils::read.csv(file.path("output/06_redes", mods$tecido[i], "modulos_genes.csv"), stringsAsFactors = FALSE)
  r <- ora(RC, k$gene[k$modulo == mods$id[i]], k$gene, conj)
  if (!is.null(r)) data.frame(tecido = mods$tecido[i], modulo = mods$id[i], selecao = mods$selecao[i], sentido_modulo = ifelse(mods$g[i] > 0, "maior no DM2", "menor no DM2"), r) }))
escrever_csv(ora_m, file.path(d, "ora_modulos.csv"))
# rótulo de cada módulo: via Hallmark mais enriquecida (ou Reactome, se não houver)
rot <- ora_m %>% filter(fdr < RC$enriquecimento$fdr_ora) %>% arrange(tecido, modulo, colecao != "Hallmark", p) %>% group_by(tecido, modulo) %>%
  summarise(rotulo = paste(utils::head(sub("^(HALLMARK|REACTOME|GOBP)_", "", via), 2), collapse = " / "), .groups = "drop")
mods$rotulo <- rot$rotulo[match(paste(mods$tecido, mods$id), paste(rot$tecido, rot$modulo))]
escrever_csv(mods, file.path(d, "modulos_rotulados.csv"))

# 7.3 convergência: ORA (FDR < 0,05) num módulo selecionado + via selecionada no tecido pelo escore (qualquer nível), mesmo sentido
conv <- ora_m %>% filter(!is.na(selecao), nzchar(selecao), fdr < RC$enriquecimento$fdr_ora) %>%
  inner_join(gs_tec %>% filter(nzchar(nivel)) %>% select(tecido, colecao, via, g_via = g, fdr_via = fdr, nivel_via = nivel, NES, leading_edge),
             by = c("tecido", "colecao", "via")) %>%
  filter((g_via > 0) == (sentido_modulo == "maior no DM2"), !is.na(NES), sign(NES) == sign(g_via))
escrever_csv(conv, file.path(d, "convergencia.csv"))
log_msg("ETAPA 07 | módulos descritos: %d; vias convergentes: %d", length(unique(paste(ora_m$tecido, ora_m$modulo))), nrow(conv))

# figura: vias Hallmark por tecido (revisão de 09/10/2026). A cor é o efeito do DM2 pelo ESCORE de via (g, o teste do workflow),
# que fica perto de 0 quando não há efeito. Antes a cor era o NES da GSEA pré-ordenada, que por construção nunca fica perto
# de 0 (conjuntos sorteados dão NES ~ +-0,8): o mapa ficava todo colorido e homogêneo, sem distinguir vias com e sem efeito.
figura_hallmark(gs_tec[gs_tec$colecao == "Hallmark", ], tecidos, RC, "docs/figuras/gsea_hallmark.png")

# ---------------- relatório ----------------
fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
res <- gs_tec %>% group_by(tecido, colecao) %>% summarise(vias = n(), fdr05 = sum(nivel == "significativo"), fdr25 = sum(nivel == "sugestivo"), explor = sum(nivel %in% c("exploratório", "exploratório (efeito fixo, 2 estudos)")), explor2 = sum(nivel == "exploratório (≥ 2 estudos)"), explor1 = sum(nivel == "exploratório (1 estudo)"), p05 = sum(p < 0.05, na.rm = TRUE), acaso = round(0.05 * sum(!is.na(p))),   # esperado ao acaso (revisão de 08/10/2026)
                                                                
                                                           gsea_inflada = sum(fdr_gsea < 0.05, na.rm = TRUE), .groups = "drop")
top <- gs_tec %>% filter(nzchar(nivel)) %>% arrange(tecido, p) %>% group_by(tecido, colecao) %>% slice_head(n = 8) %>% ungroup()
linhas <- c("# Validação da etapa 07: enriquecimento", "", sprintf("Gerado em %s a partir de `output/07_enriquecimento/`.", format(Sys.time(), "%d/%m/%Y %H:%M")), "",
  "## 1. Vias por tecido (efeito do DM2 nas mulheres de 40–60)", "",
  "Teste: escore por amostra em cada via, mesmo modelo e meta-análise (Hartung-Knapp) da etapa 05. A última coluna mostra quantas vias a GSEA pré-ordenada daria com FDR < 0,05: ela ignora a correlação entre genes e ficou inflada, por isso serve só para o sentido e os genes que puxam a via.", "",
  "| Tecido | Coleção | Vias testadas | FDR < 0,05 | FDR < 0,10 | Exploratórias (p < 0,05 e todos os estudos no mesmo sentido) | p < 0,05 observadas | p < 0,05 esperadas ao acaso | GSEA pré-ordenada FDR < 0,05 (inflada) |", "|---|---|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %s | %d | %d | %d | %d | %d | %d | %d |", res$tecido, res$colecao, res$vias, res$fdr05, res$fdr25, res$explor, res$p05, res$acaso, res$gsea_inflada), "",
  "Esperadas ao acaso = 5% das vias testadas. Listas exploratórias desse tamanho não são evidência por si; valem como hipóteses quando convergem com módulos e genes (revisão de 08/10/2026).", "",
  "## 2. Vias selecionadas (até 8 por tecido e coleção)", "",
  if (nrow(top)) c("| Tecido | Coleção | Via | g (IC 95%) | p | FDR | Nível | Estudos no mesmo sentido | NES (GSEA) |", "|---|---|---|---|---:|---:|---|---|---:|",
    sprintf("| %s | %s | %s | %.2f (%.2f a %.2f) | %s | %s | %s | %d/%d | %s |", top$tecido, top$colecao, top$via, top$g, top$ic_inf, top$ic_sup, fp(top$p), fp(top$fdr), top$nivel, top$mesmo_sentido, top$estudos,
            ifelse(is.na(top$NES), "-", sprintf("%.2f", top$NES)))) else "Nenhuma.", "",
  "Figura: `docs/figuras/gsea_hallmark.png`.", "",
  "## 3. O que cada módulo representa (ORA, FDR < 0,05)", "",
  "| Tecido | Módulo | Genes | g (DM2, mulheres 40–60) | p | Seleção | Representa |", "|---|---|---:|---:|---:|---|---|",
  sprintf("| %s | %s | %d | %.2f | %s | %s | %s |", mods$tecido, mods$id, mods$genes, mods$g, fp(mods$p), ifelse(nzchar(mods$selecao), mods$selecao, "-"), ifelse(is.na(mods$rotulo), "-", mods$rotulo)), "",
  "## 4. Vias convergentes (módulo selecionado + GSEA do tecido, mesmo sentido)", "",
  if (nrow(conv)) c("| Tecido | Módulo | Seleção do módulo | Coleção | Via | g da via | Nível da via |", "|---|---|---|---|---|---:|---|",
    sprintf("| %s | %s | %s | %s | %s | %.2f | %s |", conv$tecido, conv$modulo, conv$selecao, conv$colecao, conv$via, conv$g_via, conv$nivel_via)) else "Nenhuma via convergente (não há módulo selecionado ou as vias dos módulos selecionados não aparecem na GSEA do tecido).", "",
  "Correção de 07/10/2026: a 1ª execução usou a GSEA pré-ordenada para a significância e deu milhares de vias com FDR < 0,05 (inflação por genes correlacionados); a significância passou a vir do escore por amostra.")
writeLines(linhas, file.path(pasta("docs"), "validacao_07_enriquecimento.md"), useBytes = TRUE)
log_msg("ETAPA 07 | relatório de validação: docs/validacao_07_enriquecimento.md")
documentar_etapa_07(RC, conj, res, top, mods, conv)
