###############################################################################
#  run_10c_painel_roc.R - ETAPA 10c: o conjunto do painel das ilhotas na curva ROC (pedido do usuário, 09/10/2026)
#  Compara o conjunto fixo do painel (genes das ilhotas da etapa 08) com as outras regras da etapa 10/10b:
#   (a) ilhotas, deixando um estudo de fora: só os genes do painel que passam (p < 0,05 e mesmo sentido) nos outros estudos
#   (b) ilhotas, conjunto inteiro nos mesmos estudos: CIRCULAR (os genes foram escolhidos com eles), só para comparação
#   (c) outros tecidos: teste independente (genes escolhidos nas ilhotas)
#   (d) AUC de cada gene do painel em cada estudo (sentido fixo: maior no DM2)
#  Nulo: conjuntos sorteados do mesmo tamanho, com o sentido tirado da meta-análise do próprio tecido.
###############################################################################
for (f in c("R/00_utils.R", "R/05_meta.R", "R/10_roc.R", "R/10b_roc_otimizada.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
MC <- ler_config("config/meta.yaml"); OC <- ler_config("config/roc.yaml")
inv_all <- utils::read.csv("output/04_processamento/inventario.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
est05 <- utils::read.csv("output/05_meta/estudos.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8"); prin <- est05[est05$uso == "principal", ]
codif <- if (isTRUE(MC$so_codificantes)) genes_codificantes() else NULL
d <- pasta("output", "10_roc")
le <- function(f) if (file.exists(f) && file.size(f) > 5) utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8") else NULL
f2 <- function(x, k = 2) ifelse(is.na(x), "-", formatC(x, format = "f", digits = k, decimal.mark = ","))
fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
pan <- le("output/08_painel/painel.csv"); pg <- pan[pan$tecido == "ilhotas", ]; genes <- pg$gene; sentido <- sign(pg$g)
efg <- lapply(stats::setNames(prin$gse, prin$gse), function(g) le(file.path("output/05_meta/estudos", g, "efeitos_genes.csv")))
E <- lapply(stats::setNames(prin$gse, prin$gse), function(g) carregar_estudo(g, inv_all, NULL, codif))
combina <- function(x) { x <- x[!is.na(x$auc), ]; if (!nrow(x)) return(data.frame(estudos = 0, auc = NA, ic_inf = NA, ic_sup = NA, p = NA))
  A <- pmin(pmax(x$auc, 0.5 / (x$n_T2D * x$n_ND)), 1 - 0.5 / (x$n_T2D * x$n_ND)); G <- matrix(stats::qlogis(A), 1); rownames(G) <- "AUC"
  V <- matrix((ep_auc(x$auc, x$n_T2D, x$n_ND) / (A * (1 - A)))^2, 1); P <- matrix(pmin(1, 2 * x$p_wilcoxon), 1)
  m <- meta_dl(G, V, P, "hk", matrix(x$n_T2D + x$n_ND, 1)); data.frame(estudos = nrow(x), auc = round(stats::plogis(m$g), 3), ic_inf = round(stats::plogis(m$ic_inf), 3), ic_sup = round(stats::plogis(m$ic_sup), 3), p = signif(m$p, 3)) }
linha <- function(analise, tec, s, gs, sn, nul = TRUE) { r <- escore_auc(E[[s]], gs, sn); if (is.null(r) || r$genes_medidos < 3) return(NULL)
  pn <- NA; if (nul) { tg <- prin$gse[prin$tecido == tec]; nv <- auc_nula(E[[s]], efg[tg], r$genes_medidos, 500, OC$semente); pn <- round((1 + sum(nv >= r$auc, na.rm = TRUE)) / (1 + sum(!is.na(nv))), 3) }
  data.frame(analise = analise, tecido = tec, estudo = s, genes_medidos = r$genes_medidos, n_T2D = r$n_T2D, n_ND = r$n_ND, auc = round(r$auc, 3), ic_inf = round(r$ic_inf, 3), ic_sup = round(r$ic_sup, 3),
             p_wilcoxon = signif(r$p_wilcoxon, 3), p_vs_sorteados = pn, genes = paste(gs[gs %in% rownames(E[[s]]$ex)], collapse = ";")) }

res <- list(); ilh <- prin$gse[prin$tecido == "ilhotas"]
for (s in ilh) {                                                      # (a) deixando um estudo de fora, dentro do painel
  tr <- setdiff(ilh, s); m <- meta_tecido(lapply(efg[tr], function(e) e[e$id %in% genes, ]), metodo = "hk")
  ok <- m$id[m$estudos == length(tr) & m$mesmo_sentido == m$estudos & m$p < 0.05]; if (length(ok) < 3) ok <- utils::head(m$id[m$estudos == length(tr) & m$mesmo_sentido == m$estudos][order(m$p[m$estudos == length(tr) & m$mesmo_sentido == m$estudos])], 5)
  res[[length(res) + 1]] <- linha("painel, deixando o estudo de fora", "ilhotas", s, ok, sign(m$g[match(ok, m$id)]))
  res[[length(res) + 1]] <- linha("painel inteiro (circular)", "ilhotas", s, genes, sentido, nul = FALSE) }
for (s in prin$gse[prin$tecido != "ilhotas"]) res[[length(res) + 1]] <- linha("painel das ilhotas em outro tecido (independente)", prin$tecido[prin$gse == s], s, genes, sentido)
res <- do.call(rbind, res)
met <- do.call(rbind, lapply(split(res, paste(res$analise, res$tecido)), function(x) data.frame(analise = x$analise[1], tecido = x$tecido[1], combina(x))))
# comparação com as outras regras (ilhotas)
p10 <- le("output/10_roc/meta_auc.csv"); p10b <- le("output/10_roc/otimizada_meta.csv"); pt <- le("output/10_roc/otimizada_todos_tecidos_meta.csv")
cmp <- rbind(data.frame(conjunto = "Regra padrão: módulo, 20 genes (etapa 10)", auc = p10$auc_combinada[p10$tecido == "ilhotas"], ic_inf = p10$ic_inf[p10$tecido == "ilhotas"], ic_sup = p10$ic_sup[p10$tecido == "ilhotas"], p = p10$p_hk[p10$tecido == "ilhotas"], honesta = "sim"),
             data.frame(conjunto = "Regra otimizada no treino (etapa 10b)", auc = p10b$auc[p10b$tecido == "ilhotas"], ic_inf = p10b$ic_inf[p10b$tecido == "ilhotas"], ic_sup = p10b$ic_sup[p10b$tecido == "ilhotas"], p = p10b$p[p10b$tecido == "ilhotas"], honesta = "sim"),
             data.frame(conjunto = "Conjunto comum a todos os tecidos (tecido de fora)", auc = pt$auc[pt$tecido == "ilhotas"], ic_inf = pt$ic_inf[pt$tecido == "ilhotas"], ic_sup = pt$ic_sup[pt$tecido == "ilhotas"], p = pt$p[pt$tecido == "ilhotas"], honesta = "sim"),
             data.frame(conjunto = "Painel, deixando o estudo de fora", met[met$analise == "painel, deixando o estudo de fora" & met$tecido == "ilhotas", c("auc", "ic_inf", "ic_sup", "p")], honesta = "sim"),
             data.frame(conjunto = "Painel inteiro nos mesmos estudos (circular)", met[met$analise == "painel inteiro (circular)", c("auc", "ic_inf", "ic_sup", "p")], honesta = "não (otimista)"))
# (d) AUC de cada gene em cada estudo (sentido = o do painel)
ga <- do.call(rbind, lapply(prin$gse, function(s) do.call(rbind, lapply(seq_along(genes), function(i) { r <- escore_auc(E[[s]], genes[i], sentido[i]); if (is.null(r) || r$genes_medidos == 0) return(NULL)
  data.frame(gene = genes[i], tecido = prin$tecido[prin$gse == s], estudo = s, auc = round(r$auc, 3)) }))))
gsum <- do.call(rbind, lapply(split(ga, ga$gene), function(x) { i <- x[x$tecido == "ilhotas", ]; o <- x[x$tecido != "ilhotas", ]
  data.frame(gene = x$gene[1], auc_media_ilhotas = round(mean(i$auc), 2), ilhotas_auc_maior_0.5 = sprintf("%d/%d", sum(i$auc > 0.5), nrow(i)), auc_media_outros_tecidos = round(mean(o$auc), 2), outros_auc_maior_0.5 = sprintf("%d/%d", sum(o$auc > 0.5), nrow(o))) }))
gsum <- gsum[order(-gsum$auc_media_ilhotas), ]
escrever_csv(res, file.path(d, "painel_roc_estudos.csv")); escrever_csv(met, file.path(d, "painel_roc_meta.csv")); escrever_csv(cmp, file.path(d, "painel_roc_comparacao.csv"))
escrever_csv(ga, file.path(d, "painel_roc_genes_estudos.csv")); escrever_csv(gsum, file.path(d, "painel_roc_genes.csv"))
log_msg("ETAPA 10c | painel das ilhotas (%d genes): deixando um estudo de fora AUC %s; circular %s; outros tecidos: %s", length(genes),
        f2(cmp$auc[4]), f2(cmp$auc[5]), paste(sprintf("%s %s", met$tecido[grepl("outro", met$analise)], f2(met$auc[grepl("outro", met$analise)])), collapse = "; "))

# figura: mapa de calor da AUC de cada gene em cada estudo
ords <- prin$gse[order(prin$tecido != "ilhotas", prin$tecido)]; M <- matrix(NA, length(gsum$gene), length(ords), dimnames = list(gsum$gene, ords))
for (i in seq_len(nrow(ga))) M[ga$gene[i], ga$estudo[i]] <- ga$auc[i]
grDevices::png("docs/figuras/painel_roc_genes.png", width = 1900, height = 1050, res = 160); op <- graphics::par(mar = c(7.5, 6, 3, 6))
pal <- grDevices::hcl.colors(40, "Blue-Red 3")
graphics::image(seq_along(ords), seq_len(nrow(M)), t(M[nrow(M):1, , drop = FALSE]), zlim = c(0, 1), col = pal, axes = FALSE, xlab = "", ylab = "", main = "AUC de cada gene do painel das ilhotas em cada estudo (sentido: maior no DM2)")
graphics::axis(1, seq_along(ords), sprintf("%s\n%s", ords, prin$tecido[match(ords, prin$gse)]), las = 2, cex.axis = 0.62, tick = FALSE, padj = 0.5)
graphics::axis(2, seq_len(nrow(M)), rev(rownames(M)), las = 1, cex.axis = 0.75, tick = FALSE)
for (i in seq_len(nrow(M))) for (j in seq_along(ords)) { v <- M[nrow(M) - i + 1, j]; if (!is.na(v)) graphics::text(j, i, sprintf("%.2f", v), cex = 0.5, col = if (abs(v - 0.5) > 0.3) "white" else "black") }
graphics::abline(v = sum(prin$tecido == "ilhotas") + 0.5, lwd = 2); graphics::par(op); grDevices::dev.off()
