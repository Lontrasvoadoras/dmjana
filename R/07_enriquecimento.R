###############################################################################
#  07_enriquecimento.R - ETAPA 07: enriquecimento (ORA dos módulos e GSEA pelo efeito do DM2)
#
#  Intenção (docs/intencao_06_redes.docx, aprovada em 07/10/2026):
#   7.1 ORA: o que cada módulo representa (genes do módulo x universo da rede), Hallmark, Reactome e GO BP
#   7.2 GSEA pré-ordenada pelo efeito do DM2 (g, mulheres de 40-60): em cada estudo e na meta-análise de
#       cada tecido; FDR dentro de cada coleção (e estudo/tecido). Independente da escolha dos módulos.
#   7.3 convergência: via com ORA significativa num módulo selecionado E na GSEA do tecido, no mesmo sentido
###############################################################################

conjuntos_colecoes <- function(RC) {
  lapply(RC$enriquecimento$colecoes, function(c0) {
    h <- tryCatch(msigdbr::msigdbr(species = "Homo sapiens", collection = c0$collection, subcollection = if (nzchar(c0$subcollection)) c0$subcollection else NULL),
                  error = function(e) msigdbr::msigdbr(species = "Homo sapiens", category = c0$collection, subcategory = if (nzchar(c0$subcollection)) c0$subcollection else NULL))
    split(h$gene_symbol, h$gs_name) })
}

# GSEA pré-ordenada (fgsea) de um vetor de efeitos nomeado por gene
gsea <- function(RC, efeito, conj) {
  E <- RC$enriquecimento; efeito <- efeito[!is.na(efeito) & !duplicated(names(efeito))]
  do.call(rbind, lapply(names(conj), function(cl) {
    set.seed(1)
    r <- suppressWarnings(fgsea::fgsea(conj[[cl]], stats = sort(efeito, decreasing = TRUE), minSize = E$tamanho_min, maxSize = E$tamanho_max))
    if (!nrow(r)) return(NULL)
    data.frame(colecao = cl, via = r$pathway, tamanho = r$size, NES = round(r$NES, 3), p = r$pval, fdr = r$padj,
               leading_edge = vapply(r$leadingEdge, function(z) paste(utils::head(z, 25), collapse = ";"), ""), stringsAsFactors = FALSE) }))
}

# ORA de uma lista de genes contra o universo
ora <- function(RC, genes, universo, conj) {
  E <- RC$enriquecimento
  do.call(rbind, lapply(names(conj), function(cl) {
    t2g <- utils::stack(conj[[cl]])[, c("ind", "values")]; names(t2g) <- c("term", "gene"); t2g <- t2g[t2g$gene %in% universo, ]
    r <- tryCatch(suppressMessages(clusterProfiler::enricher(genes, universe = universo, TERM2GENE = t2g, minGSSize = E$tamanho_min, maxGSSize = E$tamanho_max,
                                                            pvalueCutoff = 1, qvalueCutoff = 1, pAdjustMethod = "BH")), error = function(e) NULL)
    if (is.null(r) || !nrow(r@result)) return(NULL)
    x <- r@result
    data.frame(colecao = cl, via = x$ID, genes_na_lista = x$Count, razao = x$GeneRatio, p = x$pvalue, fdr = x$p.adjust, genes = gsub("/", ";", x$geneID), stringsAsFactors = FALSE) }))
}

# nível da GSEA de uma via no tecido
nivel_gsea <- function(RC, fdr) ifelse(fdr < RC$enriquecimento$fdr_gsea, "significativo", ifelse(fdr < RC$enriquecimento$fdr_gsea_exploratorio, "exploratório", ""))

# mapa das vias Hallmark: cor = g do escore de via (DM2 - sem diabetes); quadro = p < 0,05 (Hartung-Knapp; efeito fixo em tecido
# com 2 estudos; p do estudo no fígado); ** FDR < 0,05, * FDR < 0,10; NES da GSEA só como sinal (+/-) à direita da célula
figura_hallmark <- function(h, tecidos, RC, arq) {
  vs <- sort(unique(h$via)); pega <- function(campo) sapply(tecidos, function(t) { x <- h[h$tecido == t, ]; x[[campo]][match(vs, x$via)] })
  G <- pega("g"); Pp <- pega("p"); Pf <- if ("p_fe" %in% names(h)) pega("p_fe") else Pp; Fq <- pega("fdr"); N <- pega("NES")
  n_est <- vapply(tecidos, function(t) max(h$estudos[h$tecido == t], na.rm = TRUE), 0)
  for (j in seq_along(tecidos)) if (n_est[j] == 2) Pp[, j] <- ifelse(is.na(Pf[, j]), Pp[, j], Pf[, j])
  rownames(G) <- sub("^HALLMARK_", "", vs); o <- order(rowMeans(G, na.rm = TRUE)); G <- G[o, , drop = FALSE]; Pp <- Pp[o, , drop = FALSE]; Fq <- Fq[o, , drop = FALSE]; N <- N[o, , drop = FALSE]
  lim <- min(2, max(abs(G), na.rm = TRUE)); Gc <- pmax(pmin(G, lim), -lim); pal <- grDevices::colorRampPalette(c("#2166AC", "#F7F7F7", "#B2182B"))(101)
  grDevices::png(arq, width = 1400, height = 2300, res = 150); op <- graphics::par(mar = c(6, 16, 3, 2))
  graphics::image(seq_len(ncol(Gc)), seq_len(nrow(Gc)), t(Gc), col = pal, zlim = c(-lim, lim), axes = FALSE, xlab = "", ylab = "", main = "Vias Hallmark: efeito do DM2 pelo escore (g), mulheres de 40–60")
  graphics::axis(1, seq_len(ncol(Gc)), colnames(Gc), las = 2, cex.axis = 0.9); graphics::axis(2, seq_len(nrow(Gc)), rownames(Gc), las = 1, cex.axis = 0.6)
  for (i in seq_len(ncol(Gc))) for (j in seq_len(nrow(Gc))) {
    if (!is.na(Pp[j, i]) && Pp[j, i] < 0.05) graphics::rect(i - 0.48, j - 0.45, i + 0.48, j + 0.45, border = "black", lwd = 1.4)
    q <- Fq[j, i]; if (!is.na(q) && q < RC$teste$fdr_sugestivo) graphics::text(i, j, if (q < RC$teste$fdr) "**" else "*", cex = 0.8)
    if (!is.na(N[j, i])) graphics::text(i + 0.38, j, if (N[j, i] > 0) "+" else "−", cex = 0.45, col = "grey35") }
  graphics::mtext(sprintf("cor = g do escore (limite ±%.1f); quadro = p < 0,05; ** FDR < 0,05, * FDR < 0,10; +/− = sinal do NES da GSEA", lim), side = 1, line = 4.5, cex = 0.65)
  graphics::par(op); grDevices::dev.off(); arq
}

# ---------------- calibração empírica dos p das vias (revisão de 10/10/2026) ----------------
# Conjuntos de genes sorteados (tamanhos tirados das vias reais) passam pelo MESMO caminho das vias: escore competitivo,
# modelo da etapa 05 e meta-análise do tecido. O p de cada via é comparado com os sorteados de tamanho parecido (quintis).
nulo_vias_tecido <- function(MC, E, gses, tamanhos, B, semente) {
  set.seed(semente); univ <- unique(unlist(lapply(E[gses], function(e) rownames(e$ex))))
  tam <- sample(tamanhos, B, replace = TRUE); rs <- stats::setNames(lapply(tam, function(k) sample(univ, min(k, length(univ)))), sprintf("ALEATORIO_%05d", seq_len(B)))
  efs <- lapply(stats::setNames(gses, gses), function(g) { e <- E[[g]]; S <- escores_vias(e$ex, rs, MC$vias$min_genes)
    tryCatch(ajustar(MC, e, Y = S, metodo = "limma", so_alvo = identical(MC$modelo_principal, "so_F40a60")), error = function(x) NULL) })
  efs <- Filter(Negate(is.null), efs); m <- meta_tecido(efs, metodo = MC$meta_metodo)
  data.frame(id = m$id, tamanho = tam[match(m$id, names(rs))], p = m$p, p_fe = if ("p_fe" %in% names(m)) m$p_fe else NA_real_)
}
p_empirico <- function(p_obs, tam_obs, p_nulo, tam_nulo) {
  br <- unique(stats::quantile(tam_nulo, seq(0, 1, 0.2), na.rm = TRUE)); bo <- cut(tam_obs, br, include.lowest = TRUE); bn <- cut(tam_nulo, br, include.lowest = TRUE)
  vapply(seq_along(p_obs), function(i) { if (is.na(p_obs[i])) return(NA_real_); nn <- p_nulo[!is.na(bn) & !is.na(bo[i]) & bn == bo[i]]; if (sum(!is.na(nn)) < 50) nn <- p_nulo
    (1 + sum(nn <= p_obs[i], na.rm = TRUE)) / (1 + sum(!is.na(nn))) }, 0)
}
