###############################################################################
#  run_05_meta.R - executa a ETAPA 05 (efeito do DM2 por estudo e meta-análise por tecido)
#  Uso (a partir de workflow_dm_menopausa):
#     "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_05_meta.R
#  Saídas: output/05_meta/..., docs/figuras/meta_*.png, docs/validacao_05_meta.md, docs/etapa_05_meta.docx
###############################################################################
suppressPackageStartupMessages({ library(dplyr) })
for (f in c("R/00_utils.R", "R/05_meta.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
MC <- ler_config("config/meta.yaml")
options(vias_competitivo = !isFALSE(MC$vias$competitivo))       # escore de via competitivo (08/10/2026)
inv_all <- utils::read.csv("output/04_processamento/inventario.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
# análise principal: prontos na etapa 04, menos os excluídos do genoma inteiro (GSE23561);
# estudos com lote confundido com o grupo entram só na sensibilidade (decisões de 07/10/2026)
fora_genoma <- names(MC$excluir_genoma %||% list())
inv <- inv_all[inv_all$categoria == "pronto para a etapa 05" & !inv_all$gse %in% fora_genoma, ]
inv_conf <- inv_all[grepl("lote confundido", inv_all$categoria), ]
# contraste que não isola o DM2 (revisão de 08/10/2026): também só na sensibilidade
so_sens <- names(MC$so_sensibilidade %||% list())
inv_conf <- rbind(inv_conf, inv[inv$gse %in% so_sens, ]); inv <- inv[!inv$gse %in% so_sens, ]
motivo_sens <- function(g) if (isTRUE(MC$so_sensibilidade[[g]]$replicacao)) "replicação (fígado em dois níveis)" else if (g %in% so_sens) "só sensibilidade (contraste não isola o DM2)" else "só sensibilidade (lote confundido)" 
codif <- if (isTRUE(MC$so_codificantes)) genes_codificantes() else NULL
longo <- utils::read.csv("output/02_metadados/amostras_longo.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
bmi <- ler_bmi(longo); conj <- conjuntos_hallmark(MC)
d <- pasta("output", "05_meta")

# ---------------- 1. modelos por estudo (principal e sensibilidades) ----------------
analises <- c("principal", "imc", "todas_amostras", "composicao", "sem_lote", "idade")
alvos_am <- list()
alvo_principal <- identical(MC$modelo_principal, "so_F40a60")              # E1 (07/10/2026): só mulheres de 40-60
ef <- list(); ef_v <- list(); info <- list()
guarda <- function(L, a, tec, g, val) { if (is.null(L[[a]])) L[[a]] <- list(); if (is.null(L[[a]][[tec]])) L[[a]][[tec]] <- list(); L[[a]][[tec]][[g]] <- val; L }
for (g in c(inv$gse, inv_conf$gse)) {
  conf <- g %in% inv_conf$gse
  est <- carregar_estudo(g, inv_all, bmi, codif); tec <- est$tecido
  vias <- escores_vias(if (!is.null(est$cnt)) est$ex else est$ex, conj, MC$vias$min_genes)
  comp <- escores_composicao(est$ex, MC$composicao[[tec]])
  b <- est$am$bmi; usa_bmi <- sum(!is.na(b)) >= 0.8 * length(b)
  seguro <- function(expr, rotulo) tryCatch(expr, error = function(e) { log_msg("ETAPA 05 | %s %s: não ajustado (%s)", g, rotulo, conditionMessage(e)); NULL })
  roda <- function(..., so_alvo = alvo_principal) list(genes = seguro(ajustar(MC, est, ..., so_alvo = so_alvo), "genes"), vias = seguro(ajustar(MC, est, Y = vias, metodo = "limma", ..., so_alvo = so_alvo), "vias"))
  r <- if (conf) list(principal = roda()) else
       list(principal = roda(),
            imc = if (usa_bmi) roda(covar = cbind(imc = b)) else NULL,
            todas_amostras = roda(so_alvo = !alvo_principal),
            composicao = if (ncol(comp)) roda(covar = comp) else NULL,
            sem_lote = roda(lote = FALSE),
            idade = roda(covar = cbind(idade = est$am$idade)),
            # medicação (09/10/2026): covariável (estatina no GSE130991) ou retirada de amostras (controle em metformina no GSE18732)
            medicacao_cov = { mc <- MC$medicacao$covariavel[[g]]; if (is.null(mc)) NULL else {
              v <- longo$valor[longo$gse == g & longo$chave == mc$chave][match(est$am$gsm, longo$gsm[longo$gse == g & longo$chave == mc$chave])]
              roda(covar = stats::setNames(data.frame(as.numeric(v == mc$sim)), mc$nome)) } },
            medicacao_excl = { mx <- MC$medicacao$excluir[[g]]; if (is.null(mx)) NULL else {
              v <- longo$valor[longo$gse == g & longo$chave == mx$chave][match(est$am$gsm, longo$gsm[longo$gse == g & longo$chave == mx$chave])]
              sai <- v %in% mx$valor & est$am$status %in% mx$status; e0 <- est; e0$am <- e0$am[!sai, ]
              log_msg("ETAPA 05 | %s: sensibilidade sem %d amostra(s) (%s)", g, sum(sai), mx$nome)
              list(genes = seguro(ajustar(MC, e0, so_alvo = alvo_principal), "genes"), vias = seguro(ajustar(MC, e0, Y = vias, metodo = "limma", so_alvo = alvo_principal), "vias")) } })
  # estudo com lote confundido: guardado à parte (só sensibilidade)
  for (a in names(r)) if (!is.null(r[[a]]$genes)) {
    a2 <- if (conf) "confundido" else a
    ef <- guarda(ef, a2, tec, g, r[[a]]$genes); ef_v <- guarda(ef_v, a2, tec, g, r[[a]]$vias)
  }
  p <- r$principal$genes
  if (is.null(p) || is.null(r$principal$vias)) {                         # revisão de código (08/10/2026): antes, NULL aqui interrompia a etapa
    log_msg("ETAPA 05 | %s: sem ajuste viável no modelo principal; estudo fora da etapa", g); next }
  # balanço de idade e IMC entre DM2 e ND nas mulheres de 40-60 (A1, A2) e sanidade do estudo (P2)
  am_a <- est$am[est$am$mulher_40a60 %in% TRUE & est$am$status %in% c("T2D", "ND"), ]; am_a$tecido_estudo <- tec
  if (!conf) alvos_am[[g]] <- am_a
  med <- function(v, st) { x <- v[am_a$status == st]; if (all(is.na(x))) NA_real_ else round(mean(x, na.rm = TRUE), 1) }
  san <- sanidade(p$p)
  info[[g]] <- data.frame(gse = g, tecido = tec, tipo = est$tipo, metodo = p$metodo[1], doadores = length(unique(est$am$individuo)),
                          F40a60_T2D = p$n1[1], F40a60_ND = p$n2[1], genes = nrow(p), vias = nrow(r$principal$vias %||% data.frame()),
                          imc = usa_bmi, composicao = paste(colnames(comp), collapse = ";"),
                          uso = if (conf) motivo_sens(g) else "principal", lote_ajustado = isTRUE(p$lote_ajustado[1]),
                          genes_p05 = sum(p$p < 0.05), genes_fdr05 = sum(stats::p.adjust(p$p, "BH") < MC$fdr),
                          idade_T2D = med(am_a$idade, "T2D"), idade_ND = med(am_a$idade, "ND"), imc_T2D = med(am_a$bmi, "T2D"), imc_ND = med(am_a$bmi, "ND"),
                          frac_p05 = round(san[["frac_p05"]], 3), lambda = round(san[["lambda"]], 2),
                          alerta = if (san[["frac_p05"]] > MC$sanidade$frac_p05_max || san[["lambda"]] > MC$sanidade$lambda_max) "sinal fora do esperado (conferir lote/composição)" else "")
  info[[g]]$dif_idade <- round(info[[g]]$idade_T2D - info[[g]]$idade_ND, 1)
  escrever_csv(p, file.path(pasta(d, "estudos", g), "efeitos_genes.csv"))
  escrever_csv(r$principal$vias, file.path(d, "estudos", g, "efeitos_vias.csv"))
  log_msg("ETAPA 05 | %s (%s, %s): %d genes, %d vias; mulheres 40-60 DM2/ND %d/%d; p<0,05: %d genes", g, tec, p$metodo[1], nrow(p), nrow(r$principal$vias), p$n1[1], p$n2[1], sum(p$p < 0.05))
}
info <- do.call(rbind, info); escrever_csv(info, file.path(d, "estudos.csv"))
info_conf <- info[info$uso != "principal", ]; info <- info[info$uso == "principal", ]

# ---------------- 2. meta-análise por tecido ----------------
tecidos <- sort(unique(inv$tecido))
mg <- list(); mv <- list()
for (tec in tecidos) {
  mg[[tec]] <- meta_tecido(ef$principal[[tec]], metodo = MC$meta_metodo); mv[[tec]] <- meta_tecido(ef_v$principal[[tec]], metodo = MC$meta_metodo)
  mg[[tec]]$resposta_imediata <- mg[[tec]]$id %in% unlist(MC$genes_resposta_imediata)   # marcado, não retirado (08/10/2026)
  escrever_csv(mg[[tec]], file.path(pasta(d, tec), "meta_genes.csv")); escrever_csv(mv[[tec]], file.path(d, tec, "meta_vias.csv"))
}

# ---------------- 3. sensibilidades ----------------
vias_sens <- list()                                                       # resultado de cada sensibilidade nas vias (para as vias de interesse)
resumo_sens <- function(tec, nome, efs, efs_v, metodo = MC$meta_metodo) {
  if (length(efs) == 0) return(NULL)
  a <- meta_tecido(efs, metodo = metodo); b <- meta_tecido(efs_v, metodo = metodo); m0 <- mg[[tec]]; v0 <- mv[[tec]]
  vias_sens[[length(vias_sens) + 1]] <<- data.frame(tecido = tec, analise = nome, b[, c("id", "estudos", "g", "ic_inf", "ic_sup", "p", "fdr", "mesmo_sentido")])
  sig0 <- m0$id[m0$nivel == "replicado" & m0$fdr < MC$fdr]; sigv0 <- v0$id[v0$fdr < MC$fdr]
  comum <- intersect(m0$id[m0$nivel == "replicado"], a$id[a$nivel == "replicado"])
  data.frame(tecido = tec, analise = nome, estudos = length(efs),
             genes_replicados_fdr05 = sum(a$nivel == "replicado" & a$fdr < MC$fdr), genes_descoberta_fdr05 = sum(a$nivel == "descoberta" & a$fdr < MC$fdr),
             genes_principais_mantidos = if (length(sig0)) sprintf("%d/%d", sum(sig0 %in% a$id[a$fdr < MC$fdr]), length(sig0)) else "-",
             cor_g_genes = if (length(comum) > 10) round(stats::cor(m0$g[match(comum, m0$id)], a$g[match(comum, a$id)]), 2) else NA,
             vias_fdr05 = sum(b$fdr < MC$fdr), vias_principais_mantidas = if (length(sigv0)) sprintf("%d/%d", sum(sigv0 %in% b$id[b$fdr < MC$fdr]), length(sigv0)) else "-",
             vias_fdr05_lista = paste(sub("^HALLMARK_", "", b$id[b$fdr < MC$fdr]), collapse = "; "))
}
sens <- list()
for (tec in tecidos) {
  e0 <- ef$principal[[tec]]; v0 <- ef_v$principal[[tec]]
  sens[[length(sens) + 1]] <- resumo_sens(tec, "principal", e0, v0)
  if (length(e0) >= 2) for (g in names(e0)) sens[[length(sens) + 1]] <- resumo_sens(tec, paste("sem", g), e0[names(e0) != g], v0[names(v0) != g])
  aut <- inv$gse[inv$tecido == tec & inv$tipo %in% unlist(MC$matriz_autor)]
  if (length(aut) && length(setdiff(names(e0), aut))) sens[[length(sens) + 1]] <- resumo_sens(tec, "sem matrizes do autor", e0[!names(e0) %in% aut], v0[!names(v0) %in% aut])
  # medicação (09/10/2026): troca, no tecido, o estudo pelo seu ajuste/recorte de medicação e mantém os outros estudos
  for (a in c("medicacao_cov", "medicacao_excl")) if (length(ef[[a]][[tec]])) {
    e1 <- e0; v1 <- v0; for (g in names(ef[[a]][[tec]])) { e1[[g]] <- ef[[a]][[tec]][[g]]; if (!is.null(ef_v[[a]][[tec]][[g]])) v1[[g]] <- ef_v[[a]][[tec]][[g]] }
    sens[[length(sens) + 1]] <- resumo_sens(tec, sprintf("%s (%s)", if (a == "medicacao_cov") "ajuste por medicação" else "sem amostras por medicação",
                                                         paste(vapply(names(ef[[a]][[tec]]), function(g) (MC$medicacao$covariavel[[g]] %||% MC$medicacao$excluir[[g]])$nome, ""), collapse = ", ")), e1, v1) }
  for (a in c("todas_amostras", "imc", "composicao", "sem_lote")) if (length(ef[[a]][[tec]]))
    sens[[length(sens) + 1]] <- resumo_sens(tec, switch(a, imc = "ajuste por IMC (estudos com IMC)", todas_amostras = if (alvo_principal) "modelo com todas as amostras (variância também de homens e outras idades)" else "modelo só com mulheres de 40-60",
                                                        composicao = "ajuste por composição celular", sem_lote = "sem ajuste de lote"),
                                            ef[[a]][[tec]], ef_v[[a]][[tec]])
  if (length(ef$confundido[[tec]])) sens[[length(sens) + 1]] <- resumo_sens(tec, paste("com estudos só de sensibilidade (", paste(names(ef$confundido[[tec]]), collapse = ", "), ")"),
                                                                            c(e0, ef$confundido[[tec]]), c(v0, ef_v$confundido[[tec]]))
  # revisão de metodologia (07/10/2026)
  if (length(e0) >= 2) sens[[length(sens) + 1]] <- resumo_sens(tec, "DerSimonian-Laird (em vez de Hartung-Knapp)", e0, v0, metodo = "dl")
  if (length(ef$idade[[tec]])) sens[[length(sens) + 1]] <- resumo_sens(tec, "idade como covariável", ef$idade[[tec]], ef_v$idade[[tec]])
  ii <- info$gse[info$tecido == tec & !is.na(info$dif_idade) & abs(info$dif_idade) <= MC$idade_dif_max]
  if (length(ii) && length(ii) < length(e0)) sens[[length(sens) + 1]] <- resumo_sens(tec, sprintf("sem estudos com diferença de idade > %d anos", MC$idade_dif_max), e0[names(e0) %in% ii], v0[names(v0) %in% ii])
  i3 <- info$gse[info$tecido == tec & info$F40a60_T2D >= MC$min_por_grupo_sens & info$F40a60_ND >= MC$min_por_grupo_sens]
  if (length(i3) && length(i3) < length(e0)) sens[[length(sens) + 1]] <- resumo_sens(tec, sprintf("só estudos com >= %d x %d", MC$min_por_grupo_sens, MC$min_por_grupo_sens), e0[names(e0) %in% i3], v0[names(v0) %in% i3])
}
sens <- do.call(rbind, sens); escrever_csv(sens, file.path(d, "sensibilidades.csv"))
vias_sens <- do.call(rbind, vias_sens)
# medicação (09/10/2026): vias Hallmark do tecido sem e com ajuste/recorte por medicação, lado a lado
vm <- vias_sens[grepl("medicação", vias_sens$analise), ]
if (nrow(vm)) { base <- vias_sens[vias_sens$analise == "principal" & vias_sens$tecido %in% vm$tecido, ]
  cmp_med <- merge(base[, c("tecido", "id", "g", "p")], vm[, c("tecido", "analise", "id", "g", "p")], by = c("tecido", "id"), suffixes = c("_principal", "_medicacao"))
  cmp_med$mudou_sentido <- sign(cmp_med$g_principal) != sign(cmp_med$g_medicacao)
  escrever_csv(cmp_med[order(cmp_med$tecido, cmp_med$p_principal), ], file.path(d, "sensibilidade_medicacao_vias.csv")) }
# vias de interesse (M6): resultado na principal e em cada sensibilidade
vi <- do.call(rbind, lapply(names(MC$vias_interesse), function(tec) { ids <- unlist(MC$vias_interesse[[tec]]); x <- vias_sens[vias_sens$tecido == tec & vias_sens$id %in% ids, ]; x }))
escrever_csv(vi, file.path(d, "vias_interesse.csv"))
# sobreposição de doadoras por perfil entre estudos do mesmo tecido (M4)
sob <- sobreposicao_perfil(alvos_am); escrever_csv(sob, file.path(d, "sobreposicao_perfil.csv"))
# "deixar um de fora" detalhado para as vias com FDR < 0,10 (robustez de cada achado)
loo_vias <- do.call(rbind, lapply(tecidos, function(tec) {
  v0 <- mv[[tec]]; alvo <- v0$id[v0$fdr < MC$fdr_sugestivo]; e <- ef_v$principal[[tec]]
  if (!length(alvo) || length(e) < 2) return(NULL)
  do.call(rbind, lapply(names(e), function(g) { m <- meta_tecido(e[names(e) != g]); x <- m[match(alvo, m$id), ]
    data.frame(tecido = tec, via = alvo, sem = g, g = x$g, p = x$p, fdr = x$fdr, g_principal = v0$g[match(alvo, v0$id)], fdr_principal = v0$fdr[match(alvo, v0$id)]) }))
}))
if (!is.null(loo_vias)) escrever_csv(loo_vias, file.path(d, "vias_deixar_um_de_fora.csv"))

# ---------------- 4. poder ----------------
poder <- do.call(rbind, lapply(tecidos, function(tec) { x <- info[info$tecido == tec, ]
  data.frame(tecido = tec, estudos = nrow(x), T2D = sum(x$F40a60_T2D), ND = sum(x$F40a60_ND),
             # revisão de 08/10/2026: alfa do genoma = 0,05 / nº mediano de genes dos estudos do tecido (Bonferroni), em vez
             # de 1e-4 fixo; estimativa de planejamento (efeito fixo), não o poder efetivo do Hartung-Knapp com FDR
             alfa_genoma = signif(0.05 / stats::median(x$genes), 2),
             mde_nominal = round(mde(x$F40a60_T2D, x$F40a60_ND, 0.05, MC$poder), 2), mde_genoma = round(mde(x$F40a60_T2D, x$F40a60_ND, 0.05 / stats::median(x$genes), MC$poder), 2)) }))
escrever_csv(poder, file.path(d, "poder.csv"))

# ---------------- 5. NanoString (GSE316126): conferência com o sangue ----------------
nano <- NULL
if ("GSE316126" %in% inv_all$gse) {
  invn <- inv_all[inv_all$gse == "GSE316126", ]; en <- carregar_estudo("GSE316126", invn, bmi)
  rn <- ajustar(MC, en, metodo = "limma")
  if (!is.null(rn)) {
    s <- mg[["sangue"]]; k <- intersect(rn$id, s$id)
    nano <- data.frame(genes_painel = nrow(rn), em_comum = length(k), cor_g = round(stats::cor(rn$g[match(k, rn$id)], s$g[match(k, s$id)]), 2),
                       mesmo_sentido = round(mean(sign(rn$g[match(k, rn$id)]) == sign(s$g[match(k, s$id)])), 2),
                       genes_fdr05_painel = sum(stats::p.adjust(rn$p, "BH") < MC$fdr))
    escrever_csv(rn, file.path(pasta(d, "estudos", "GSE316126"), "efeitos_genes.csv")); escrever_csv(nano, file.path(d, "nanostring_sangue.csv"))
  }
}

# ---------------- 6. entre tecidos ----------------
vias_tab <- Reduce(function(x, y) merge(x, y, by = "id", all = TRUE), lapply(tecidos, function(tec) {
  x <- mv[[tec]][, c("id", "g", "fdr", "nivel", "estudos")]; names(x)[-1] <- paste(names(x)[-1], tec, sep = "_"); x }))
escrever_csv(vias_tab, file.path(d, "vias_por_tecido.csv"))
genes_rep <- do.call(rbind, lapply(tecidos, function(tec) { x <- mg[[tec]]; x <- x[x$fdr < MC$fdr_sugestivo, ]; if (nrow(x)) data.frame(tecido = tec, x[, c("id", "nivel", "estudos", "g", "fdr", "mesmo_sentido")]) }))
multi <- if (!is.null(genes_rep) && nrow(genes_rep)) { t <- table(genes_rep$id); genes_rep[genes_rep$id %in% names(t)[t >= 2], ] } else NULL
escrever_csv(if (is.null(genes_rep)) data.frame() else genes_rep, file.path(d, "genes_fdr10_por_tecido.csv"))

# ---------------- 7. figuras ----------------
pasta("docs", "figuras")
grDevices::png("docs/figuras/meta_vulcao.png", width = 1800, height = 900, res = 150)
op <- graphics::par(mfrow = c(2, 3), mar = c(4, 4, 2.5, 1))
for (tec in tecidos) {
  x <- mg[[tec]]; rep <- x$nivel == "replicado"
  cor <- ifelse(x$fdr < MC$fdr, "#B03A2E", ifelse(x$fdr < MC$fdr_sugestivo, "#E59866", "grey70"))
  graphics::plot(x$g, -log10(x$p), pch = ifelse(rep, 19, 1), cex = 0.4, col = cor, xlab = "Efeito do DM2 (g de Hedges)", ylab = "−log10(p)",
                 main = sprintf("%s (%d estudo%s)", tec, length(ef$principal[[tec]]), ifelse(length(ef$principal[[tec]]) > 1, "s", "")), cex.main = 1)
  graphics::abline(v = 0, col = "grey50", lty = 3)
}
graphics::plot.new(); graphics::legend("center", c("FDR < 0,05", "FDR < 0,10", "não significativo", "replicado (cheio)", "descoberta (vazio)"),
                                       col = c("#B03A2E", "#E59866", "grey70", "black", "black"), pch = c(19, 19, 19, 19, 1), bty = "n")
graphics::par(op); grDevices::dev.off()

M <- sapply(tecidos, function(tec) mv[[tec]]$g[match(sort(names(conj)), mv[[tec]]$id)]); rownames(M) <- sub("^HALLMARK_", "", sort(names(conj)))
Fq <- sapply(tecidos, function(tec) mv[[tec]]$fdr[match(sort(names(conj)), mv[[tec]]$id)])
o <- order(rowMeans(M, na.rm = TRUE)); M <- M[o, , drop = FALSE]; Fq <- Fq[o, , drop = FALSE]
lim <- max(abs(M), na.rm = TRUE); pal <- grDevices::colorRampPalette(c("#2166AC", "#F7F7F7", "#B2182B"))(101)
grDevices::png("docs/figuras/meta_vias.png", width = 1400, height = 2300, res = 150)
graphics::par(mar = c(5, 16, 3, 6))
graphics::image(seq_len(ncol(M)), seq_len(nrow(M)), t(M), col = pal, zlim = c(-lim, lim), axes = FALSE, xlab = "", ylab = "", main = "Vias Hallmark: efeito do DM2 (g) por tecido")
graphics::axis(1, seq_len(ncol(M)), colnames(M), las = 2, cex.axis = 0.9); graphics::axis(2, seq_len(nrow(M)), rownames(M), las = 1, cex.axis = 0.6)
for (i in seq_len(ncol(M))) for (j in seq_len(nrow(M))) { q <- Fq[j, i]; if (!is.na(q) && q < MC$fdr_sugestivo) graphics::text(i, j, if (q < MC$fdr) "**" else "*", cex = 0.8) }
graphics::mtext("** FDR < 0,05   * FDR < 0,10   (vermelho = maior no DM2; azul = menor)", side = 1, line = 4, cex = 0.7)
grDevices::dev.off()

# ---------------- 8. relatório ----------------
f2 <- function(x) formatC(x, format = "f", digits = 2, decimal.mark = ",")
fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
top_vias <- do.call(rbind, lapply(tecidos, function(tec) { x <- mv[[tec]]; x <- x[x$fdr < MC$fdr_sugestivo, ]; if (nrow(x)) data.frame(tecido = tec, x) }))
top_genes <- do.call(rbind, lapply(tecidos, function(tec) { x <- mg[[tec]]; x <- utils::head(x[x$fdr < MC$fdr_sugestivo, ], 15); if (nrow(x)) data.frame(tecido = tec, x) }))
cont <- do.call(rbind, lapply(tecidos, function(tec) { x <- mg[[tec]]; v <- mv[[tec]]
  data.frame(tecido = tec, estudos = length(ef$principal[[tec]]), genes = nrow(x), replicados = sum(x$nivel == "replicado"), descoberta = sum(x$nivel == "descoberta"),
             rep_fdr05 = sum(x$nivel == "replicado" & x$fdr < MC$fdr), rep_fdr10 = sum(x$nivel == "replicado" & x$fdr < MC$fdr_sugestivo),
             desc_fdr05 = sum(x$nivel == "descoberta" & x$fdr < MC$fdr), vias_fdr05 = sum(v$fdr < MC$fdr), vias_fdr10 = sum(v$fdr < MC$fdr_sugestivo)) }))
escrever_csv(cont, file.path(d, "resumo_tecidos.csv"))
linhas <- c(
  "# Validação da etapa 05: efeito do DM2 por estudo e meta-análise por tecido", "",
  sprintf("Gerado em %s a partir de `output/05_meta/`. **Aprovar antes de seguir.**", format(Sys.time(), "%d/%m/%Y %H:%M")), "",
  "## 1. Estudos no modelo", "",
  "Só genes codificantes de proteína; lote (data de leitura do array) como covariável quando há 2+ lotes (decisões do usuário de 07/10/2026).", "",
  "| GSE | Tecido | Método | Doadores | F 40–60 DM2/ND | Genes | Vias | IMC | Lote ajustado | Genes p < 0,05 | Genes FDR < 0,05 (estudo) |", "|---|---|---|---:|---|---:|---:|---|---|---:|---:|",
  sprintf("| %s | %s | %s | %d | %d/%d | %d | %d | %s | %s | %d | %d |", info$gse, info$tecido, info$metodo, info$doadores, info$F40a60_T2D, info$F40a60_ND, info$genes, info$vias,
          ifelse(info$imc, "sim", "não"), ifelse(info$lote_ajustado, "sim", "não"), info$genes_p05, info$genes_fdr05), "",
  sprintf("Só na sensibilidade: %s.", if (nrow(info_conf)) paste(sprintf("%s (%s; %s)", info_conf$gse, info_conf$tecido, sub("só sensibilidade ", "", info_conf$uso)), collapse = "; ") else "nenhum"),
  if (length(so_sens)) paste0("Contraste que não isola o DM2 (revisão de 08/10/2026): ", paste(sprintf("%s — %s", so_sens, vapply(so_sens, function(g) MC$so_sensibilidade[[g]]$motivo, "")), collapse = "; "), ".") else NULL,
  sprintf("Fora da análise do genoma inteiro: %s.", if (length(fora_genoma)) paste(sprintf("%s (%s)", fora_genoma, unlist(MC$excluir_genoma)), collapse = "; ") else "nenhum"), "",
  "### Balanço de idade e IMC (mulheres de 40–60) e sanidade de cada estudo", "",
  "Esperado sem efeito: ~5% dos genes com p < 0,05 e lambda perto de 1. Diferença de idade > 5 anos mistura DM2 e estado menopausal.", "",
  "| GSE | Tecido | Idade DM2 / ND | Diferença | IMC DM2 / ND | Genes p < 0,05 | λ | Alerta |", "|---|---|---|---:|---|---:|---:|---|",
  sprintf("| %s | %s | %s / %s | %s | %s / %s | %.0f%% | %s | %s |", info$gse, info$tecido, info$idade_T2D, info$idade_ND, ifelse(is.na(info$dif_idade), "-", sprintf("%+.1f", info$dif_idade)),
          ifelse(is.na(info$imc_T2D), "-", info$imc_T2D), ifelse(is.na(info$imc_ND), "-", info$imc_ND), 100 * info$frac_p05, info$lambda, info$alerta), "",
  "Meta-análise: Hartung-Knapp modificado (principal; recomendado com poucos estudos) e DerSimonian-Laird em sensibilidade (revisão de metodologia de 07/10/2026).", "",
  "## 2. Resumo por tecido", "",
  "| Tecido | Estudos | Genes | Replicados | Descoberta | Replicados FDR < 0,05 | Replicados FDR < 0,10 | Descoberta FDR < 0,05 | Vias FDR < 0,05 | Vias FDR < 0,10 |", "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %d | %d | %d | %d | %d | %d | %d | %d | %d |", cont$tecido, cont$estudos, cont$genes, cont$replicados, cont$descoberta, cont$rep_fdr05, cont$rep_fdr10, cont$desc_fdr05, cont$vias_fdr05, cont$vias_fdr10), "",
  "## 3. Poder (efeito mínimo detectável, 80%)", "",
  "| Tecido | Estudos | DM2/ND | g mínimo (p < 0,05) | g mínimo (escala do genoma) |", "|---|---:|---|---:|---:|",
  sprintf("| %s | %d | %d/%d | %s | %s |", poder$tecido, poder$estudos, poder$T2D, poder$ND, f2(poder$mde_nominal), f2(poder$mde_genoma)), "",
  "## 4. Vias com FDR < 0,10", "")
linhas <- c(linhas, if (!is.null(top_vias) && nrow(top_vias)) c("| Tecido | Via | Nível | Estudos | g (IC 95%) | I² | Mesmo sentido | FDR |", "|---|---|---|---:|---|---:|---|---:|",
  sprintf("| %s | %s | %s | %d | %s (%s a %s) | %s | %d/%d | %s |", top_vias$tecido, sub("^HALLMARK_", "", top_vias$id), top_vias$nivel, top_vias$estudos, f2(top_vias$g), f2(top_vias$ic_inf), f2(top_vias$ic_sup),
          ifelse(is.na(top_vias$I2), "-", sprintf("%.0f%%", 100 * top_vias$I2)), top_vias$mesmo_sentido, top_vias$estudos, fp(top_vias$fdr))) else "Nenhuma via com FDR < 0,10.", "",
  "Figura: `docs/figuras/meta_vias.png`.", "")
if (!is.null(loo_vias)) linhas <- c(linhas, "Robustez (deixar um estudo de fora) das vias com FDR < 0,10:", "",
  "| Tecido | Via | Sem o estudo | g | p | FDR | g / FDR na principal |", "|---|---|---|---:|---:|---:|---|",
  sprintf("| %s | %s | %s | %s | %s | %s | %s / %s |", loo_vias$tecido, sub("^HALLMARK_", "", loo_vias$via), loo_vias$sem, f2(loo_vias$g), fp(loo_vias$p), fp(loo_vias$fdr), f2(loo_vias$g_principal), fp(loo_vias$fdr_principal)), "")
linhas <- c(linhas, "## 5. Genes com FDR < 0,10 (até 15 por tecido)", "")
linhas <- c(linhas, if (!is.null(top_genes) && nrow(top_genes)) c("| Tecido | Gene | Nível | Estudos | g (IC 95%) | I² | Mesmo sentido | FDR |", "|---|---|---|---:|---|---:|---|---:|",
  sprintf("| %s | %s | %s | %d | %s (%s a %s) | %s | %d/%d | %s |", top_genes$tecido, top_genes$id, top_genes$nivel, top_genes$estudos, f2(top_genes$g), f2(top_genes$ic_inf), f2(top_genes$ic_sup),
          ifelse(is.na(top_genes$I2), "-", sprintf("%.0f%%", 100 * top_genes$I2)), top_genes$mesmo_sentido, top_genes$estudos, fp(top_genes$fdr))) else "Nenhum gene com FDR < 0,10.", "",
  "Figura: `docs/figuras/meta_vulcao.png`. Listas completas em `output/05_meta/<tecido>/meta_genes.csv`.", "",
  "## 6. Sensibilidades", "",
  "| Tecido | Análise | Estudos | Genes replicados FDR < 0,05 | Genes principais mantidos | Correlação dos g | Vias FDR < 0,05 | Vias principais mantidas | Vias |", "|---|---|---:|---:|---|---:|---:|---|---|",
  sprintf("| %s | %s | %d | %d | %s | %s | %d | %s | %s |", sens$tecido, sens$analise, sens$estudos, sens$genes_replicados_fdr05, sens$genes_principais_mantidos, ifelse(is.na(sens$cor_g_genes), "-", f2(sens$cor_g_genes)),
          sens$vias_fdr05, sens$vias_principais_mantidas, substr(sens$vias_fdr05_lista, 1, 120)), "")
if (!is.null(vi) && nrow(vi)) linhas <- c(linhas, "## 6b. Vias de interesse (hipóteses escolhidas depois de ver os dados da etapa 05)", "",
  "| Tecido | Via | Análise | Estudos | g (IC 95%) | Mesmo sentido | p | FDR |", "|---|---|---|---:|---|---|---:|---:|",
  sprintf("| %s | %s | %s | %d | %s (%s a %s) | %d/%d | %s | %s |", vi$tecido, sub("^HALLMARK_", "", vi$id), vi$analise, vi$estudos, f2(vi$g), f2(vi$ic_inf), f2(vi$ic_sup), vi$mesmo_sentido, vi$estudos, fp(vi$p), fp(vi$fdr)), "")
linhas <- c(linhas, "## 6c. Possível sobreposição de doadoras entre estudos (mesmo tecido, status, idade e IMC)", "",
  if (nrow(sob)) c("| Tecido | Status | Idade | IMC | Estudos | Doadoras |", "|---|---|---:|---|---|---|",
    unname(sapply(split(sob, sob$chave), function(x) sprintf("| %s | %s | %s | %s | %s | %s |", x$tecido[1], x$status[1], x$idade[1], ifelse(is.na(x$bmi[1]), "-", x$bmi[1]), paste(unique(x$gse), collapse = ", "), paste(x$individuo, collapse = "; "))))) else "Nenhuma.",
  "", "Só doadoras com idade e IMC conhecidos entram (revisão de 08/10/2026). Perfil idêntico não prova que é a mesma pessoa; é pista para conferir na fonte.", "")
if (!is.null(nano)) linhas <- c(linhas, "## 7. NanoString (GSE316126) x meta-análise do sangue", "",
  sprintf("%d genes do painel; %d em comum com o sangue; correlação dos g = %s; mesmo sentido em %.0f%%; %d genes com FDR < 0,05 no próprio painel.", nano$genes_painel, nano$em_comum, f2(nano$cor_g), 100 * nano$mesmo_sentido, nano$genes_fdr05_painel), "")
if (!is.null(multi) && nrow(multi)) linhas <- c(linhas, "## 8. Genes com FDR < 0,10 em mais de um tecido", "", "| Gene | Tecido | Nível | g | FDR |", "|---|---|---|---:|---:|",
  sprintf("| %s | %s | %s | %s | %s |", multi$id, multi$tecido, multi$nivel, f2(multi$g), fp(multi$fdr)), "")
linhas <- c(linhas, "## 9. O que validar", "", "1. Os resultados por tecido (seções 2, 4 e 5), lidos junto com o poder (seção 3).", "2. A robustez nas sensibilidades (seção 6): resultado que some ao tirar um estudo ou ao ajustar por IMC/composição deve ser tratado com cautela.",
  "3. Os resultados de descoberta (um estudo) são pistas, não confirmações. Em tecido com 2+ estudos, 'descoberta' é um gene medido em só 1 estudo (ex.: UQCRHL nas ilhotas, só no GSE221156): não é replicação.")
# genes de resposta imediata com p < 0,05 (marcados para discussão; decisão do usuário, 08/10/2026)
ieg <- do.call(rbind, lapply(tecidos, function(tec) { x <- mg[[tec]]; x <- x[x$resposta_imediata & x$p < 0.05, ]
  if (nrow(x)) data.frame(tecido = tec, gene = x$id, estudos = x$estudos, g = round(x$g, 2), p = signif(x$p, 2), mesmo_sentido = x$mesmo_sentido) }))
ieg_res <- do.call(rbind, lapply(tecidos, function(tec) { x <- mg[[tec]]; a <- x[x$resposta_imediata, ]
  data.frame(tecido = tec, medidos = nrow(a), p05 = sum(a$p < 0.05), maiores_dm2 = sum(a$g > 0), frac_p05_ieg = round(mean(a$p < 0.05), 3), frac_p05_demais = round(mean(x$p[!x$resposta_imediata] < 0.05), 3)) }))
escrever_csv(ieg_res, file.path(d, "resposta_imediata_resumo.csv")); if (!is.null(ieg)) escrever_csv(ieg, file.path(d, "resposta_imediata_p05.csv"))
linhas <- c(linhas, "", "## 10. Genes de resposta imediata (marcados para discussão)", "",
  "Genes que sobem em minutos com isquemia ou manuseio do tecido antes do congelamento (lista em config/meta.yaml). Ficam na análise; a marca serve para a discussão: se eles dominam os achados de um tecido, o sinal pode ser de coleta, não de DM2 (decisão do usuário, 08/10/2026).", "",
  "| Tecido | Medidos | p < 0,05 | Maiores no DM2 | Fração p < 0,05 (resposta imediata) | Fração p < 0,05 (demais genes) |", "|---|---:|---:|---:|---:|---:|",
  sprintf("| %s | %d | %d | %d | %.3f | %.3f |", ieg_res$tecido, ieg_res$medidos, ieg_res$p05, ieg_res$maiores_dm2, ieg_res$frac_p05_ieg, ieg_res$frac_p05_demais), "",
  if (!is.null(ieg)) c("| Tecido | Gene | Estudos | g | p | Mesmo sentido |", "|---|---|---:|---:|---:|---|", sprintf("| %s | %s | %d | %.2f | %s | %d/%d |", ieg$tecido, ieg$gene, ieg$estudos, ieg$g, fp(ieg$p), ieg$mesmo_sentido, ieg$estudos)) else "Nenhum com p < 0,05.")
writeLines(linhas, file.path(pasta("docs"), "validacao_05_meta.md"), useBytes = TRUE)
log_msg("ETAPA 05 | relatório de validação: docs/validacao_05_meta.md")
documentar_etapa_05(MC, info, cont, poder, top_vias, top_genes, sens, nano, multi, info_conf, fora_genoma, loo_vias, vi, sob, ieg_res = ieg_res, ieg = ieg)
