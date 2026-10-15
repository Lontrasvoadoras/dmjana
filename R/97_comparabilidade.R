###############################################################################
#  97_comparabilidade.R - comparabilidade dos dados e sanidade completa (pedido do usuário, 08/10/2026)
#
#  Pergunta: os estudos que juntamos olham para dados comparáveis?
#   - genes resgatados (detectados) por amostra e por estudo
#   - similaridade dos genes por tecido e entre tecidos: genes em comum (Jaccard), perfil de expressão
#     (correlação de Spearman dos perfis medianos) e efeito do DM2 (correlação dos g)
#  E testes de sanidade de conteúdo (não só de formato):
#   - controles biológicos: sexo pela expressão (XIST x genes do Y), identidade do tecido por marcadores,
#     controles positivos do DM2 nas ilhotas
#   - nulos estatísticos: permutação dos rótulos DM2/ND, conjuntos de genes aleatórios
#   - conferência independente da meta-análise com o pacote metafor; invariantes matemáticos
#   - rastreio do N, símbolos corrompidos (Excel) e aliases, doadores duplicados, balanço de confusores,
#     saídas desatualizadas, reprodutibilidade
#  Usa carregar_estudo / ajustar / escores_vias / meta_tecido (etapa 05) e verif() (98_sanidade.R).
###############################################################################

pct <- function(ex) apply(ex, 2, function(v) rank(v) / length(v))              # percentil dentro da amostra
smd <- function(x, grp) { a <- x[grp == "T2D"]; b <- x[grp == "ND"]; a <- a[!is.na(a)]; b <- b[!is.na(b)]
  if (length(a) < 2 || length(b) < 2) return(NA_real_); s <- sqrt((stats::var(a) + stats::var(b)) / 2); if (s == 0) return(NA_real_); (mean(a) - mean(b)) / s }

# carrega todos os estudos da etapa 05 (principal e sensibilidade), com as amostras mantidas
carregar_todos <- function(MC) {
  inv <- utils::read.csv("output/04_processamento/inventario.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
  est <- utils::read.csv("output/05_meta/estudos.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8", na.strings = c("NA", ""))
  codif <- if (isTRUE(MC$so_codificantes)) genes_codificantes() else NULL
  longo <- utils::read.csv("output/02_metadados/amostras_longo.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
  bmi <- ler_bmi(longo)
  L <- lapply(stats::setNames(est$gse, est$gse), function(g) { e <- carregar_estudo(g, inv, bmi, codif)
    e$brutos <- rownames(readRDS(file.path("output/04_processamento", g, "expressao.rds"))$expressao); e$uso <- est$uso[est$gse == g]; e })
  list(L = L, est = est, codif = codif)
}

# genes detectados por amostra
deteccao <- function(SC, e) {
  D <- SC$deteccao
  if (!is.null(e$cnt)) { cpm <- edgeR::cpm(e$cnt); return(list(det = cpm >= D$cpm_min, metodo = sprintf("CPM >= %g", D$cpm_min), fundo = NA_real_)) }
  ex <- e$ex; y <- intersect(D$genes_y, rownames(ex))
  mulheres <- e$am$coluna[e$am$sexo %in% "F" | e$am$sexo_genetico %in% "F"]
  if (length(y) >= 3 && length(mulheres) >= 1) {
    # percentil 95 de cada gene do Y nas mulheres; fundo = mediana entre os genes (robusta às sondas com
    # hibridização cruzada com o homólogo do X, ex.: RPS4Y1/RPS4X, EIF1AY/EIF1AX)
    fundo <- stats::median(apply(ex[y, mulheres, drop = FALSE], 1, stats::quantile, D$quantil_fundo, names = FALSE))
    return(list(det = ex > fundo, metodo = sprintf("acima do fundo dos genes do Y nas mulheres (%.2f)", fundo), fundo = fundo))
  }
  q <- apply(ex, 2, stats::quantile, D$quantil_sem_y)
  list(det = sweep(ex, 2, q, ">"), metodo = sprintf("acima do percentil %d da amostra (sem genes do Y)", round(100 * D$quantil_sem_y)), fundo = NA_real_)
}

comparabilidade <- function(SC, MC, dados) {
  L <- dados$L; tec <- vapply(L, `[[`, "", "tecido")
  # ---------------- por amostra ----------------
  am_tab <- list(); det_estudo <- list(); perfil <- list(); ident <- list()
  for (g in names(L)) { e <- L[[g]]; d <- deteccao(SC, e); P <- pct(e$ex)
    n_det <- colSums(d$det); med <- stats::median(n_det); md <- stats::mad(n_det)
    xs <- if (SC$gene_x %in% rownames(P)) P[SC$gene_x, ] else NA
    ys <- intersect(SC$deteccao$genes_y, rownames(P)); ys <- if (length(ys)) colMeans(P[ys, , drop = FALSE]) else NA
    mk <- sapply(SC$marcadores_tecido, function(m) { m <- intersect(m, rownames(P)); if (length(m) >= 2) colMeans(P[m, , drop = FALSE]) else rep(NA_real_, ncol(P)) })
    mk <- matrix(mk, ncol = length(SC$marcadores_tecido), dimnames = list(colnames(P), names(SC$marcadores_tecido)))
    topo <- apply(mk, 1, function(v) if (all(is.na(v))) NA_character_ else names(v)[which.max(v)])
    rmed <- apply(e$ex, 1, stats::median)
    am_tab[[g]] <- data.frame(gse = g, tecido = e$tecido, coluna = colnames(e$ex), individuo = e$am$individuo, sexo = e$am$sexo, status = e$am$status,
                              mulher_40a60 = e$am$mulher_40a60 %in% TRUE, genes_medidos = nrow(e$ex), genes_detectados = as.integer(n_det),
                              frac_detectados = round(n_det / nrow(e$ex), 3), baixa_deteccao = n_det < med - SC$deteccao$amostra_mad * md,
                              cor_perfil_estudo = round(apply(e$ex, 2, function(v) stats::cor(v, rmed, method = "spearman")), 3),
                              percentil_XIST = round(xs, 3), percentil_Y = round(ys, 3), tecido_por_marcadores = topo, stringsAsFactors = FALSE)
    det_estudo[[g]] <- rownames(d$det)[rowMeans(d$det) >= SC$deteccao$frac_amostras_gene]
    perfil[[g]] <- rank(rmed) / length(rmed)
    ident[[g]] <- data.frame(gse = g, tecido = e$tecido, metodo_deteccao = d$metodo, round(t(colMeans(mk, na.rm = TRUE)), 3), check.names = FALSE)
  }
  am_tab <- do.call(rbind, am_tab)
  # ---------------- por estudo ----------------
  efg <- lapply(names(L), function(g) le_s(file.path("output/05_meta/estudos", g, "efeitos_genes.csv"))); names(efg) <- names(L)
  sinon <- tryCatch(AnnotationDbi::keys(org.Hs.eg.db::org.Hs.eg.db, "ALIAS"), error = function(e) character())
  simb <- AnnotationDbi::keys(org.Hs.eg.db::org.Hs.eg.db, "SYMBOL")
  re_excel <- "^([0-9]{1,2}-(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)|(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)-[0-9]{1,2})$"
  est_tab <- do.call(rbind, lapply(names(L), function(g) { e <- L[[g]]; a <- am_tab[am_tab$gse == g, ]
    data.frame(gse = g, tecido = e$tecido, tipo = e$tipo, uso = e$uso, amostras = ncol(e$ex), mulheres_40a60_modelo = sum(a$mulher_40a60 & a$status %in% c("T2D", "ND")),
               genes_brutos = length(e$brutos), genes_medidos = nrow(e$ex), genes_analisados_05 = if (is.null(efg[[g]])) NA_integer_ else nrow(efg[[g]]),
               genes_detectados_estudo = length(det_estudo[[g]]), mediana_detectados_amostra = stats::median(a$genes_detectados),
               min_detectados_amostra = min(a$genes_detectados), amostras_baixa_deteccao = sum(a$baixa_deteccao),
               simbolos_excel = sum(grepl(re_excel, toupper(e$brutos))), simbolos_antigos = sum(!e$brutos %in% simb & e$brutos %in% sinon),
               frac_simbolos_antigos = round(mean(!e$brutos %in% simb & e$brutos %in% sinon), 4), stringsAsFactors = FALSE) }))
  # ---------------- similaridade entre estudos (pares) ----------------
  pares <- utils::combn(names(L), 2)
  sim <- do.call(rbind, lapply(seq_len(ncol(pares)), function(j) { a <- pares[1, j]; b <- pares[2, j]
    ma <- rownames(L[[a]]$ex); mb <- rownames(L[[b]]$ex); com <- intersect(ma, mb)
    ce <- c(NA, NA, 0)
    if (!is.null(efg[[a]]) && !is.null(efg[[b]])) { k <- intersect(efg[[a]]$id, efg[[b]]$id)
      ea <- efg[[a]][match(k, efg[[a]]$id), ]; eb <- efg[[b]][match(k, efg[[b]]$id), ]; s2 <- ea$p < 0.05 & eb$p < 0.05   # concordância de sentido entre genes com p < 0,05 nos dois (acaso = 0,5)
      if (length(k) >= 100) ce <- c(stats::cor(ea$g, eb$g, method = "spearman"), if (sum(s2) >= 10) mean(sign(ea$g[s2]) == sign(eb$g[s2])) else NA, sum(s2)) }
    data.frame(estudo_a = a, estudo_b = b, tecido_a = tec[a], tecido_b = tec[b], mesmo_tecido = tec[a] == tec[b], genes_comuns = length(com),
               jaccard_medidos = round(length(com) / length(union(ma, mb)), 3),
               jaccard_detectados = round(length(intersect(det_estudo[[a]], det_estudo[[b]])) / length(union(det_estudo[[a]], det_estudo[[b]])), 3),
               cor_perfil = round(stats::cor(perfil[[a]][com], perfil[[b]][com], method = "spearman"), 3), cor_efeito_dm2 = round(ce[1], 3),
               genes_p05_nos_dois = ce[3], concordancia_sentido_p05 = round(ce[2], 3), stringsAsFactors = FALSE) }))
  rownames(sim) <- NULL
  # resumo por tecido (dentro) e entre tecidos
  sim$par_tecidos <- ifelse(sim$mesmo_tecido, sim$tecido_a, paste(pmin(sim$tecido_a, sim$tecido_b), pmax(sim$tecido_a, sim$tecido_b), sep = " x "))
  res <- do.call(rbind, lapply(split(sim, sim$par_tecidos), function(x) data.frame(comparacao = x$par_tecidos[1], tipo = if (x$mesmo_tecido[1]) "dentro do tecido" else "entre tecidos", pares = nrow(x),
    jaccard_medidos = round(mean(x$jaccard_medidos), 3), jaccard_detectados = round(mean(x$jaccard_detectados), 3), cor_perfil = round(mean(x$cor_perfil), 3),
    cor_efeito_dm2 = round(mean(x$cor_efeito_dm2, na.rm = TRUE), 3), concordancia_sentido_p05 = round(mean(x$concordancia_sentido_p05, na.rm = TRUE), 3), stringsAsFactors = FALSE)))
  res <- res[order(res$tipo, res$comparacao), ]; rownames(res) <- NULL
  # vizinho mais parecido de cada estudo pelo perfil
  viz <- do.call(rbind, lapply(names(L), function(g) { x <- sim[sim$estudo_a == g | sim$estudo_b == g, ]
    o <- ifelse(x$estudo_a == g, x$estudo_b, x$estudo_a); i <- which.max(x$cor_perfil)
    data.frame(gse = g, tecido = tec[g], mais_parecido = o[i], tecido_mais_parecido = tec[o[i]], cor_perfil = x$cor_perfil[i], stringsAsFactors = FALSE) }))
  # cobertura dos genes no tecido: genes medidos em todos os estudos do tecido / em pelo menos um
  cob <- do.call(rbind, lapply(split(names(L), tec), function(gs) { u <- Reduce(union, lapply(L[gs], function(e) rownames(e$ex))); i <- Reduce(intersect, lapply(L[gs], function(e) rownames(e$ex)))
    data.frame(tecido = tec[gs[1]], estudos = length(gs), genes_em_algum = length(u), genes_em_todos = length(i), frac_em_todos = round(length(i) / length(u), 3)) }))
  list(amostras = am_tab, estudos = est_tab, pares = sim, resumo = res, vizinho = viz, cobertura = cob, identidade = do.call(rbind, ident), perfil = perfil, efg = efg)
}

# figuras: matrizes de similaridade entre estudos (ordenadas por tecido)
figuras_comparabilidade <- function(C, L) {
  dir.create("docs/figuras", showWarnings = FALSE, recursive = TRUE)
  tec <- vapply(L, `[[`, "", "tecido"); ord <- names(L)[order(tec, names(L))]
  mat <- function(col) { M <- matrix(NA_real_, length(ord), length(ord), dimnames = list(ord, ord)); diag(M) <- 1
    for (i in seq_len(nrow(C$pares))) { a <- C$pares$estudo_a[i]; b <- C$pares$estudo_b[i]; M[a, b] <- M[b, a] <- C$pares[[col]][i] }; M }
  desenha <- function(col, arq, titulo, lim, pal) {
    M <- mat(col); grDevices::png(arq, width = 1900, height = 1650, res = 200); op <- graphics::par(mar = c(9, 9, 3, 6))
    graphics::image(seq_along(ord), seq_along(ord), M, zlim = lim, col = pal, axes = FALSE, xlab = "", ylab = "", main = titulo)
    lab <- paste0(ord, " (", tec[ord], ")"); graphics::axis(1, seq_along(ord), lab, las = 2, cex.axis = 0.7, tick = FALSE); graphics::axis(2, seq_along(ord), lab, las = 2, cex.axis = 0.7, tick = FALSE)
    for (i in seq_along(ord)) for (j in seq_along(ord)) if (!is.na(M[i, j]) && i != j) graphics::text(i, j, sprintf("%.2f", M[i, j]), cex = 0.55, col = if (abs(M[i, j] - mean(lim)) > 0.35 * diff(lim)) "white" else "black")
    q <- cumsum(table(tec[ord])) + 0.5; graphics::abline(v = q, h = q, col = "grey30", lwd = 1.5)
    graphics::par(op); grDevices::dev.off(); arq }
  seqp <- grDevices::hcl.colors(60, "Blues 3", rev = TRUE); divp <- grDevices::hcl.colors(60, "Blue-Red 3")
  c(perfil = desenha("cor_perfil", "docs/figuras/comparabilidade_perfil.png", "Correlação dos perfis de expressão (Spearman)", c(0, 1), seqp),
    jaccard = desenha("jaccard_detectados", "docs/figuras/comparabilidade_jaccard.png", "Genes detectados em comum (Jaccard)", c(0, 1), seqp),
    efeito = desenha("cor_efeito_dm2", "docs/figuras/comparabilidade_efeito.png", "Correlação do efeito do DM2 (g) entre estudos", c(-0.5, 0.5), divp),
    deteccao = { a <- C$amostras; a$o <- factor(paste0(a$gse, " (", a$tecido, ")"), levels = unique(paste0(ord, " (", tec[ord], ")")))
      grDevices::png("docs/figuras/comparabilidade_deteccao.png", width = 1900, height = 1100, res = 200); op <- graphics::par(mar = c(9, 5, 3, 1))
      graphics::boxplot(genes_detectados ~ o, data = a, las = 2, cex.axis = 0.7, xlab = "", ylab = "genes detectados por amostra", main = "Genes resgatados por amostra", col = "grey85", border = "grey30", outline = TRUE)
      graphics::points(jitter(as.integer(a$o), 0.6), a$genes_detectados, pch = 16, cex = 0.4, col = ifelse(a$baixa_deteccao, "#C0392B", "#2C3E5080"))
      graphics::par(op); grDevices::dev.off(); "docs/figuras/comparabilidade_deteccao.png" })
}

# ---------------- testes de sanidade de conteúdo ----------------
sanidade_conteudo <- function(SC, MC, dados, C) {
  L <- dados$L; am <- C$amostras
  # controles biológicos
  mod <- am[am$mulher_40a60 & am$status %in% c("T2D", "ND") & !is.na(am$percentil_XIST) & !is.na(am$percentil_Y), ]
  ruim <- mod$percentil_Y > mod$percentil_XIST
  verif("controles", "expressão (etapa 04)", "mulheres do modelo com XIST acima dos genes do Y", sum(ruim), "ERRO", paste(mod$gse[ruim], mod$coluna[ruim]))
  idn <- C$identidade; top <- apply(idn[, names(SC$marcadores_tecido)], 1, function(v) names(v)[which.max(v)])
  verif("controles", "expressão (etapa 04)", "marcadores do próprio tecido são os mais expressos em cada estudo", sum(top != idn$tecido), "ERRO", paste(idn$gse, top)[top != idn$tecido])
  conferidas <- function(rg) unlist(lapply(Filter(function(d) d$regra == rg, SC$decisoes_usuario), `[[`, "amostras"))
  fora <- !is.na(am$tecido_por_marcadores) & am$tecido_por_marcadores != am$tecido
  ok_u <- fora & paste(am$gse, am$coluna, sep = ":") %in% conferidas("marcadores de outro tecido")
  verif("controles", "expressão (etapa 04)", "amostras com marcadores de outro tecido no topo (fora as conferidas pelo usuário)", sum(fora & !ok_u), "ALERTA", paste(am$gse[fora & !ok_u], am$coluna[fora & !ok_u], am$tecido_por_marcadores[fora & !ok_u]))
  marcadas <- am[fora, c("gse", "coluna", "individuo", "sexo", "status", "mulher_40a60", "tecido", "tecido_por_marcadores")]
  marcadas$decisao <- ifelse(ok_u[fora], "mantida por decisão do usuário (possível contaminação)", "a conferir")
  for (t in names(SC$controles_positivos)) { m <- le_s(file.path("output/05_meta", t, "meta_genes.csv")); if (is.null(m)) next
    x <- m[m$id %in% SC$controles_positivos[[t]], ]
    verif("controles", paste0(t, "/meta_genes.csv"), "controles positivos do DM2 no sentido esperado (menores no DM2)", as.integer(sum(x$g > 0) > nrow(x) / 2), "ALERTA", sprintf("%s g=%.2f", x$id, x$g)) }
  # sexo/tecido e comparabilidade
  verif("comparabilidade", "estudos", "estudo mais parecido (perfil) é do mesmo tecido", sum(C$vizinho$tecido != C$vizinho$tecido_mais_parecido), "ALERTA",
        with(C$vizinho[C$vizinho$tecido != C$vizinho$tecido_mais_parecido, ], paste(gse, "~", mais_parecido)))
  dj <- C$pares[C$pares$mesmo_tecido & C$pares$jaccard_medidos < SC$jaccard_min, ]
  verif("comparabilidade", "estudos", sprintf("genes medidos em comum entre estudos do mesmo tecido (Jaccard >= %.1f)", SC$jaccard_min), nrow(dj), "ALERTA", paste(dj$estudo_a, dj$estudo_b, dj$jaccard_medidos))
  verif("comparabilidade", "amostras", "amostras com poucos genes detectados (< mediana - 3 MAD do estudo)", sum(am$baixa_deteccao), "ALERTA", paste(am$gse, am$coluna)[am$baixa_deteccao])
  verif("comparabilidade", "estudos", "símbolos de gene corrompidos pelo Excel (ex.: 1-Sep)", sum(C$estudos$simbolos_excel), "ALERTA", paste(C$estudos$gse, C$estudos$simbolos_excel)[C$estudos$simbolos_excel > 0])
  verif("comparabilidade", "estudos", "símbolos antigos (aliases) perdidos > 2% dos genes", sum(C$estudos$frac_simbolos_antigos > 0.02), "ALERTA", paste(C$estudos$gse, C$estudos$frac_simbolos_antigos)[C$estudos$frac_simbolos_antigos > 0.02])
  # doadores duplicados (correlação dos perfis centrados por gene)
  cen <- lapply(L, function(e) { x <- e$ex - rowMeans(e$ex); v <- apply(x, 1, stats::var); x[order(-v)[seq_len(min(SC$genes_duplicado, nrow(x)))], , drop = FALSE] })
  dup <- list()
  for (g in names(cen)) { R <- stats::cor(cen[[g]]); R[lower.tri(R, TRUE)] <- NA; w <- which(R > SC$cor_duplicado, arr.ind = TRUE)
    if (nrow(w)) dup[[g]] <- data.frame(estudo_a = g, amostra_a = rownames(R)[w[, 1]], estudo_b = g, amostra_b = colnames(R)[w[, 2]], r = round(R[w], 3)) }
  tec <- vapply(L, `[[`, "", "tecido")
  for (t in unique(tec)) { gs <- names(L)[tec == t]; if (length(gs) < 2) next
    for (p in utils::combn(gs, 2, simplify = FALSE)) { k <- intersect(rownames(cen[[p[1]]]), rownames(cen[[p[2]]])); if (length(k) < 200) next
      a <- L[[p[1]]]$ex[k, ] - rowMeans(L[[p[1]]]$ex[k, ]); b <- L[[p[2]]]$ex[k, ] - rowMeans(L[[p[2]]]$ex[k, ]); R <- stats::cor(a, b); w <- which(R > SC$cor_duplicado, arr.ind = TRUE)
      if (nrow(w)) dup[[paste(p, collapse = "_")]] <- data.frame(estudo_a = p[1], amostra_a = rownames(R)[w[, 1]], estudo_b = p[2], amostra_b = colnames(R)[w[, 2]], r = round(R[w], 3)) } }
  dup <- do.call(rbind, dup)
  if (NROW(dup)) {   # idade ou sexo diferentes: não é a mesma pessoa (decisão do usuário, 08/10/2026)
    info <- do.call(rbind, lapply(names(L), function(g) data.frame(gse = g, coluna = L[[g]]$am$coluna, individuo = L[[g]]$am$individuo, idade = L[[g]]$am$idade, sexo = L[[g]]$am$sexo)))
    ia <- match(paste(dup$estudo_a, dup$amostra_a), paste(info$gse, info$coluna)); ib <- match(paste(dup$estudo_b, dup$amostra_b), paste(info$gse, info$coluna))
    dup$individuo_a <- info$individuo[ia]; dup$individuo_b <- info$individuo[ib]; dup$idade_a <- info$idade[ia]; dup$idade_b <- info$idade[ib]
    difere <- (!is.na(dup$idade_a) & !is.na(dup$idade_b) & abs(dup$idade_a - dup$idade_b) > 1) | (!is.na(info$sexo[ia]) & !is.na(info$sexo[ib]) & info$sexo[ia] != info$sexo[ib])
    dup$conclusao <- ifelse(difere, "idade ou sexo diferentes: não é a mesma pessoa", "possível doador duplicado: conferir") }
  n_dup <- if (NROW(dup)) sum(dup$conclusao != "idade ou sexo diferentes: não é a mesma pessoa") else 0
  verif("comparabilidade", "amostras", sprintf("pares com perfil quase idêntico (r centrado > %.2f) e mesma idade/sexo: possível doador duplicado", SC$cor_duplicado), n_dup, "ALERTA",
        if (n_dup) with(dup[dup$conclusao != "idade ou sexo diferentes: não é a mesma pessoa", ], paste(amostra_a, amostra_b, r)) else "")
  # balanço de confusores nas mulheres de 40-60 (DM2 x ND)
  bal <- do.call(rbind, lapply(names(L), function(g) { e <- L[[g]]; k <- e$am$mulher_40a60 %in% TRUE & e$am$status %in% c("T2D", "ND"); if (sum(k) < 4) return(NULL)
    comp <- escores_composicao(e$ex, MC$composicao[[e$tecido]]); gr <- e$am$status[k]
    v <- c(idade = smd(e$am$idade[k], gr), imc = smd(e$am$bmi[k], gr), stats::setNames(apply(comp[k, , drop = FALSE], 2, smd, gr), paste0("comp_", colnames(comp))))
    data.frame(gse = g, tecido = e$tecido, variavel = names(v), smd = round(v, 2), n_T2D = sum(gr == "T2D"), n_ND = sum(gr == "ND"), row.names = NULL) }))
  b2 <- bal[!is.na(bal$smd) & abs(bal$smd) > SC$smd_max, ]
  verif("confusao", "mulheres 40-60", sprintf("variáveis desbalanceadas entre DM2 e ND (|SMD| > %.1f)", SC$smd_max), nrow(b2), "ALERTA", paste(b2$gse, b2$variavel, b2$smd))
  # rastreio do N: n1/n2 da etapa 05 = mulheres de 40-60 no controle de qualidade
  for (g in names(L)) { f <- C$efg[[g]]; if (is.null(f)) next; a <- L[[g]]$am; k <- a$mulher_40a60 %in% TRUE
    n1 <- length(unique(a$individuo[k & a$status %in% "T2D"])); n2 <- length(unique(a$individuo[k & a$status %in% "ND"]))
    verif("05", paste0("estudos/", g, "/efeitos_genes.csv"), "n1/n2 = doadoras DM2/ND de 40-60 mantidas na etapa 04", as.integer(f$n1[1] != n1 || f$n2[1] != n2), "ERRO", sprintf("%d/%d x %d/%d", f$n1[1], f$n2[1], n1, n2)) }
  list(duplicados = dup, balanco = bal, marcadas = marcadas)
}

# conferência da meta-análise com o metafor e invariantes matemáticos
sanidade_meta <- function(SC, dados) {
  est <- dados$est; prin <- est[est$uso == "principal", ]; out <- list()
  for (t in unique(prin$tecido)) { m <- le_s(file.path("output/05_meta", t, "meta_genes.csv")); if (is.null(m)) next
    gs <- prin$gse[prin$tecido == t]; efs <- lapply(stats::setNames(gs, gs), function(g) le_s(file.path("output/05_meta/estudos", g, "efeitos_genes.csv")))
    a <- paste0(t, "/meta_genes.csv")
    if (length(gs) == 1) { e <- efs[[1]]; i <- match(m$id, e$id)
      verif("05", a, "1 estudo: meta igual ao próprio estudo (g e p)", sum(abs(m$g - e$g[i]) > 1e-9 | abs(m$p - e$p[i]) > 1e-9, na.rm = TRUE), "ERRO"); next }
    r <- m[m$estudos >= 2, ]
    verif("05", a, "Hartung-Knapp modificado nunca menos conservador que DL (p_hk >= p_dl)", sum(r$p_hk < r$p_dl - 1e-12, na.rm = TRUE), "ERRO", utils::head(r$id[which(r$p_hk < r$p_dl - 1e-12)], 3))
    lim <- stats::pchisq(r$estudos - 1, r$estudos - 1, lower.tail = FALSE)
    inc <- !is.na(r$I2) & !is.na(r$p_heterogeneidade) & r$I2 > 1e-6 & r$p_heterogeneidade > lim + 1e-9
    verif("05", a, "I² > 0 só quando Q > k - 1 (coerente com o p de heterogeneidade)", sum(inc), "ERRO")
    verif("05", a, "FDR >= p também para Stouffer e rOP", sum(r$fdr_stouffer < r$p_stouffer - 1e-12 | r$fdr_rop2 < r$p_rop2 - 1e-12, na.rm = TRUE), "ERRO")
    set.seed(SC$semente); ids <- sample(r$id, min(SC$metafor_genes, nrow(r)))
    d <- vapply(ids, function(id) { g <- sapply(efs, function(e) e$g[match(id, e$id)]); v <- sapply(efs, function(e) e$var_g[match(id, e$id)]); k <- !is.na(g)
      f1 <- metafor::rma(yi = g[k], vi = v[k], method = "DL", test = "adhoc"); f2 <- metafor::rma(yi = g[k], vi = v[k], method = "DL")
      x <- r[r$id == id, ]; c(abs(f1$beta[1] - x$g), abs(f1$pval - x$p_hk), abs(f2$pval - x$p_dl)) }, numeric(3))
    out[[t]] <- data.frame(tecido = t, genes = length(ids), dif_max_g = signif(max(d[1, ]), 2), dif_max_p_hk = signif(max(d[2, ]), 2), dif_max_p_dl = signif(max(d[3, ]), 2))
    verif("05", a, sprintf("meta-análise igual à do pacote metafor (%d genes sorteados)", length(ids)), sum(d[1, ] > 1e-6 | d[2, ] > SC$tolerancia_p | d[3, ] > SC$tolerancia_p), "ERRO",
          utils::head(ids[d[1, ] > 1e-6 | d[2, ] > SC$tolerancia_p | d[3, ] > SC$tolerancia_p], 3))
  }
  # influência: pesos somam 100% por resultado
  for (f in list.files("output/06_redes", "influencia_modulos.csv", recursive = TRUE, full.names = TRUE)) { x <- le_s(f); if (is.null(x)) next
    s <- tapply(x$peso_pct, x$id, sum, na.rm = TRUE)
    verif("06", sub("output/06_redes/", "", f), "pesos dos estudos somam 100% (± arredondamento)", sum(abs(s - 100) > 0.1 * table(x$id)[names(s)] + 0.1), "ERRO", names(s)[abs(s - 100) > 1]) }
  # módulos: soma dos tamanhos = genes fora do cinza
  for (t in list.dirs("output/06_redes", full.names = FALSE, recursive = FALSE)) { m <- le_s(file.path("output/06_redes", t, "meta_modulos.csv")); k <- le_s(file.path("output/06_redes", t, "modulos_genes.csv"))
    if (is.null(m) || is.null(k)) next
    verif("06", paste0(t, "/meta_modulos.csv"), "soma dos tamanhos dos módulos = genes fora do cinza", as.integer(sum(m$genes) != sum(k$modulo != "cinza (sem módulo)")), "ERRO", sprintf("%d x %d", sum(m$genes), sum(k$modulo != "cinza (sem módulo)"))) }
  # painel: gene existe no tecido e sentido coerente com o g da meta-análise
  pc <- le_s("output/08_painel/candidatos.csv")
  if (!is.null(pc)) { mg <- lapply(stats::setNames(unique(pc$tecido), unique(pc$tecido)), function(t) le_s(file.path("output/05_meta", t, "meta_genes.csv")))
    gm <- mapply(function(t, g) { x <- mg[[t]]; if (is.null(x)) NA else x$g[match(g, x$id)] }, pc$tecido, pc$gene)
    verif("08", "candidatos.csv", "gene do painel existe na meta-análise do seu tecido", sum(is.na(gm)), "ERRO", paste(pc$tecido, pc$gene)[is.na(gm)])
    verif("08", "candidatos.csv", "sentido do candidato = sinal do g da meta-análise", sum(!is.na(gm) & (sign(gm) != sign(pc$g) | (pc$sentido == "maior no DM2") != (pc$g > 0))), "ERRO") }
  do.call(rbind, out)
}

# nulos estatísticos: permutação dos rótulos e conjuntos de genes aleatórios
sanidade_nulos <- function(SC, MC, dados) {
  L <- dados$L[dados$est$gse[dados$est$uso == "principal"]]; conj <- conjuntos_hallmark(MC); tam <- lengths(conj)
  set.seed(SC$semente); res <- list()
  for (g in names(L)) { e <- L[[g]]; k <- which(e$am$mulher_40a60 %in% TRUE & e$am$status %in% c("T2D", "ND")); n1 <- sum(e$am$status[k] == "T2D")
    B <- min(SC$permutacoes, choose(length(k), n1) - 1); obs <- le_s(file.path("output/05_meta/estudos", g, "efeitos_genes.csv"))
    nul <- t(vapply(seq_len(B), function(b) { e2 <- e; repeat { s <- sample(e$am$status[k]); if (!identical(s, e$am$status[k])) break }
      e2$am$status[k] <- s; r <- tryCatch(ajustar(MC, e2, so_alvo = TRUE), error = function(x) NULL); if (is.null(r)) return(c(NA_real_, NA_real_)); sanidade(r$p) }, numeric(2)))
    # conjuntos aleatórios com os tamanhos dos Hallmark: fração com p < 0,05 (viés do escore de via)
    ra <- stats::setNames(lapply(seq_len(SC$conjuntos_aleatorios), function(i) sample(rownames(e$ex), sample(tam, 1))), paste0("ALEATORIO_", seq_len(SC$conjuntos_aleatorios)))   # nomes: sem eles o ajuste perde os ids
    sv <- escores_vias(e$ex, ra, MC$vias$min_genes); rv <- tryCatch(ajustar(MC, e, Y = sv, metodo = "limma", so_alvo = TRUE), error = function(x) NULL)
    ov <- le_s(file.path("output/05_meta/estudos", g, "efeitos_vias.csv"))
    res[[g]] <- data.frame(gse = g, tecido = e$tecido, n_T2D = n1, n_ND = length(k) - n1, permutacoes = B, frac_p05_observada = round(mean(obs$p < 0.05), 3),
                           frac_p05_nulo_media = round(mean(nul[, 1], na.rm = TRUE), 3), frac_p05_nulo_max = round(max(nul[, 1], na.rm = TRUE), 3),
                           p_empirico = round((1 + sum(nul[, 1] >= mean(obs$p < 0.05), na.rm = TRUE)) / (1 + sum(!is.na(nul[, 1]))), 3),
                           lambda_nulo_media = round(mean(nul[, 2], na.rm = TRUE), 2),
                           frac_p05_vias_hallmark = if (is.null(ov)) NA else round(mean(ov$p < 0.05), 3), frac_p05_conjuntos_aleatorios = if (is.null(rv)) NA else round(mean(rv$p < 0.05), 3))
    log_msg("SANIDADE | nulo %s: p<0,05 observado %.3f, permutado %.3f; conjuntos aleatórios %.3f", g, res[[g]]$frac_p05_observada, res[[g]]$frac_p05_nulo_media, res[[g]]$frac_p05_conjuntos_aleatorios)
  }
  res <- do.call(rbind, res)
  x <- res[!is.na(res$frac_p05_nulo_media) & res$frac_p05_nulo_media > SC$frac_p05_nulo_max, ]
  verif("05", "permutação dos rótulos", sprintf("modelo não inflado: p < 0,05 sob permutação <= %.2f", SC$frac_p05_nulo_max), nrow(x), "ALERTA", paste(x$gse, x$frac_p05_nulo_media))
  x <- res[!is.na(res$frac_p05_conjuntos_aleatorios) & res$frac_p05_conjuntos_aleatorios > SC$frac_aleatorios_max, ]
  verif("05", "conjuntos de genes aleatórios", sprintf("escore de via sem viés: conjuntos aleatórios com p < 0,05 <= %.2f", SC$frac_aleatorios_max), nrow(x), "ALERTA", paste(x$gse, x$frac_p05_conjuntos_aleatorios))
  res
}

# saídas desatualizadas: cada saída mais nova que as entradas de que depende; reprodutibilidade
sanidade_execucao <- function(SC, MC, dados) {
  mt <- function(f) { f <- Sys.glob(f); if (!length(f)) NA else max(file.mtime(f)) }
  mt_min <- function(f) { f <- Sys.glob(f); if (!length(f)) NA else min(file.mtime(f)) }
  dep <- list(list("04", "output/04_processamento/inventario.csv", c("output/02_metadados/amostras.csv")),
              list("05", "output/05_meta/estudos.csv", c("output/04_processamento/inventario.csv", "config/meta.yaml")),
              list("06", "output/06_redes/*/meta_modulos.csv", c("output/04_processamento/inventario.csv", "output/05_meta/estudos.csv", "config/redes.yaml")),   # genes-chave usam os efeitos da 05
              list("07", "output/07_enriquecimento/gsea_tecidos.csv", c("output/05_meta/estudos.csv", "output/06_redes/*/meta_modulos.csv", "config/redes.yaml")),
              list("08", "output/08_painel/candidatos.csv", c("output/07_enriquecimento/gsea_tecidos.csv", "output/06_redes/*/meta_modulos.csv")),
              list("09", "output/09_validacao_celula/programa_sem_e_com_ajuste.csv", c("output/08_painel/painel.csv", "output/06_redes/ilhotas/rede_cache.rds", "config/validacao.yaml")),
              list("10", "output/10_roc/meta_auc.csv", c("output/06_redes/*/meta_modulos.csv", "output/05_meta/estudos.csv", "config/roc.yaml")))
  tab <- do.call(rbind, lapply(dep, function(d) { s <- mt_min(d[[2]]); e <- vapply(d[[3]], function(f) as.numeric(mt(f)), 0)
    data.frame(etapa = d[[1]], saida = d[[2]], gerada_em = format(s, "%d/%m %H:%M"), entrada_mais_nova = names(e)[which.max(e)],
               entrada_em = format(as.POSIXct(max(e, na.rm = TRUE), origin = "1970-01-01"), "%d/%m %H:%M"), desatualizada = !is.na(s) && as.numeric(s) < max(e, na.rm = TRUE) - 60) }))
  verif("execucao", "datas das saídas", "nenhuma saída mais velha que as entradas de que depende", sum(tab$desatualizada), "ALERTA", paste(tab$etapa, "<", tab$entrada_mais_nova)[tab$desatualizada])
  g <- dados$est$gse[dados$est$uso == "principal"][1]; e <- dados$L[[g]]
  r1 <- ajustar(MC, e, so_alvo = TRUE); r2 <- ajustar(MC, e, so_alvo = TRUE)
  verif("execucao", g, "mesmo estudo ajustado duas vezes dá o mesmo resultado", as.integer(!isTRUE(all.equal(r1, r2))), "ERRO")
  writeLines(utils::capture.output(print(utils::sessionInfo())), file.path(pasta("output", "sanidade"), "sessao_R.txt"))
  tab
}
