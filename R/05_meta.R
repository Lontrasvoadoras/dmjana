###############################################################################
#  05_meta.R - ETAPA 05: efeito do DM2 por estudo e meta-análise por tecido
#
#  Intenção (validada em 07/10/2026; decisões E1-E9 em config/meta.yaml): cada estudo é analisado
#  sozinho (os dados de tecnologias diferentes não são juntados); o efeito do DM2 em mulheres de
#  40-60 vira um tamanho de efeito padronizado (g de Hedges) por gene e por via; os estudos de
#  cada tecido são combinados por meta-análise de efeitos aleatórios. Nível de evidência:
#  descoberta (1 estudo) ou replicado (2+ estudos), com FDR separado em cada nível.
#
#  Entrada : output/04_processamento/{inventario.csv, <GSE>/expressao.rds, <GSE>/amostras_qc.csv}
#  Saída   : output/05_meta/...
###############################################################################

# ---------------- dados de um estudo ----------------
# símbolos de genes codificantes de proteína (org.Hs.eg.db; decisão do usuário de 07/10/2026)
genes_codificantes <- function() {
  x <- suppressMessages(AnnotationDbi::select(org.Hs.eg.db::org.Hs.eg.db, keys = AnnotationDbi::keys(org.Hs.eg.db::org.Hs.eg.db, "ENTREZID"),
                                              keytype = "ENTREZID", columns = c("SYMBOL", "GENETYPE")))
  unique(x$SYMBOL[x$GENETYPE %in% "protein-coding"])
}
carregar_estudo <- function(gse, inv, bmi = NULL, codificantes = NULL) {
  d <- file.path("output", "04_processamento", gse)
  am <- utils::read.csv(file.path(d, "amostras_qc.csv"), stringsAsFactors = FALSE, fileEncoding = "UTF-8", na.strings = c("NA", ""),
                        colClasses = c(sexo = "character", sexo_genetico = "character"))
  am <- am[am$mantida, ]
  x <- readRDS(file.path(d, "expressao.rds"))
  if (!is.null(x$expressao_por_doador)) {                               # réplicas técnicas: um perfil por doador
    am <- am[!duplicated(am$individuo), ]; am$coluna <- am$individuo
    ex <- x$expressao_por_doador[, am$coluna, drop = FALSE]; cnt <- NULL
  } else {
    ex <- x$expressao[, am$coluna, drop = FALSE]
    cnt <- if (!is.null(x$contagens)) x$contagens[, am$coluna, drop = FALSE] else NULL
  }
  am$bmi <- if (!is.null(bmi)) unname(bmi[as.character(am$gsm)]) else NA_real_   # gsm vazio (h5ad) vira lógico
  if (!"lote" %in% names(am)) am$lote <- NA_character_
  am$lote <- as.character(am$lote)
  if (!is.null(codificantes)) { ex <- ex[rownames(ex) %in% codificantes, , drop = FALSE]; if (!is.null(cnt)) cnt <- cnt[rownames(cnt) %in% codificantes, , drop = FALSE] }
  list(gse = gse, tecido = inv$tecido[inv$gse == gse], tipo = inv$tipo[inv$gse == gse], am = am, ex = ex, cnt = cnt)
}

# IMC por amostra (etapa 02), quando existe
ler_bmi <- function(longo) {
  x <- longo[longo$campo == "carac" & grepl("bmi|body mass", tolower(longo$chave)), ]
  v <- suppressWarnings(as.numeric(sub(",", ".", sub("^([0-9.,]+).*", "\\1", x$valor))))
  stats::setNames(v, x$gsm)[!is.na(v) & v > 10 & v < 90]
}

# grupos de médias: status x (mulher 40-60 / outra mulher / homem / sexo desconhecido)
grupos <- function(am, todas_mulheres = FALSE) {
  faixa <- ifelse(am$sexo %in% "F", if (todas_mulheres) "F" else ifelse(am$mulher_40a60 %in% TRUE, "F40a60", "Foutras"),
                  ifelse(am$sexo %in% "M", "M", "S"))
  factor(paste(am$status, faixa, sep = "_"))
}

# escore de composição celular (média dos z dos marcadores de cada tipo)
escores_composicao <- function(ex, marc) {
  z <- t(scale(t(ex)))
  s <- sapply(marc, function(g) { g <- intersect(unlist(g), rownames(z)); if (length(g) >= 2) colMeans(z[g, , drop = FALSE], na.rm = TRUE) else rep(NA_real_, ncol(z)) })
  s <- s[, colSums(is.na(s)) == 0, drop = FALSE]; s
}

# ---------------- modelo e tamanho de efeito ----------------
# Ajusta um estudo e devolve, por linha (gene ou via): logFC, g, variância de g, p, n1, n2
# so_alvo = TRUE: modelo só com as mulheres de 40-60 (sensibilidade pedida pelo usuário em 07/10/2026)
ajustar <- function(MC, est, Y = NULL, todas_mulheres = FALSE, covar = NULL, metodo = NULL, lote = isTRUE(MC$ajuste_lote), so_alvo = FALSE) {
  if (so_alvo) { k <- est$am$mulher_40a60 %in% TRUE & est$am$status %in% c("T2D", "ND"); est$am <- est$am[k, ]
    if (!is.null(covar)) covar <- as.matrix(covar)[k, , drop = FALSE] }
  am <- est$am; gr <- grupos(am, todas_mulheres)
  # lote (data de leitura) como covariável quando há 2+ lotes conhecidos; se o modelo não comportar, sai sem lote
  lote_usado <- FALSE; gl_min <- MC$min_gl_covariaveis %||% 6
  if (lote && all(!is.na(am$lote)) && length(unique(am$lote)) >= 2) {
    L <- stats::model.matrix(~ factor(am$lote))[, -1, drop = FALSE]; colnames(L) <- paste0("lote", seq_len(ncol(L)))
    D <- cbind(stats::model.matrix(~ 0 + gr), L, if (!is.null(covar)) as.matrix(covar))
    if (qr(D[stats::complete.cases(D), , drop = FALSE])$rank == ncol(D) && sum(stats::complete.cases(D)) - ncol(D) >= gl_min) { covar <- cbind(if (!is.null(covar)) as.matrix(covar), L); lote_usado <- TRUE }
  }
  alvo <- if (todas_mulheres) c("T2D_F", "ND_F") else c("T2D_F40a60", "ND_F40a60")
  ok <- rep(TRUE, nrow(am))
  if (!is.null(covar)) { covar <- as.matrix(covar); ok <- stats::complete.cases(covar) }
  am <- am[ok, ]; gr <- droplevels(gr[ok]); if (!is.null(covar)) covar <- covar[ok, , drop = FALSE]
  n1 <- length(unique(am$individuo[gr == alvo[1]])); n2 <- length(unique(am$individuo[gr == alvo[2]]))
  if (n1 < 2 || n2 < 2) return(NULL)
  design <- stats::model.matrix(~ 0 + gr); colnames(design) <- levels(gr)
  design0 <- design                                                     # só os grupos: base da padronização do efeito
  if (!is.null(covar)) { design <- cbind(design, covar); if (qr(design)$rank < ncol(design)) return(NULL)
    if (nrow(design) - ncol(design) < gl_min) return(NULL) }             # covariável sem graus de liberdade suficientes: estudo fica fora dessa análise
  if (nrow(design) - ncol(design) < 2) return(NULL)
  cm <- limma::makeContrasts(contrasts = paste(alvo, collapse = " - "), levels = design)
  metodo <- metodo %||% (if (est$tipo %in% unlist(MC$metodo$voom) && !is.null(est$cnt) && is.null(Y)) "voom" else if (est$tipo %in% unlist(MC$metodo$limma_trend) && is.null(Y)) "trend" else "limma")
  if (metodo == "voom") {
    dg <- edgeR::DGEList(est$cnt[, am$coluna, drop = FALSE]); k <- edgeR::filterByExpr(dg, design = design)
    dg <- edgeR::calcNormFactors(dg[k, , keep.lib.sizes = FALSE]); Y <- limma::voom(dg, design)
  } else {
    Y <- if (is.null(Y)) est$ex[, am$coluna, drop = FALSE] else Y[, am$coluna, drop = FALSE]
    # genes sem variação ou com mais da metade das amostras no valor mínimo (ex.: matriz do autor com
    # valores < 1 que viram 0 no log, GSE23561) não são estimáveis e quebram a moderação da variância
    vmin <- apply(Y, 1, function(z) mean(z <= min(z) + 1e-8))
    Y <- Y[apply(Y, 1, stats::sd) > 0 & vmin <= 0.5, , drop = FALSE]
  }
  fit <- limma::eBayes(limma::contrasts.fit(limma::lmFit(Y, design), cm), trend = metodo == "trend")
  lfc <- fit$coefficients[, 1]
  # padronização pelo desvio-padrão dos grupos SEM covariáveis (mesmas amostras): com covariáveis o desvio-padrão
  # residual encolhe e inflaria g (correção de 07/10/2026; o g deve ser comparável entre estudos)
  # voom (revisão de código de 08/10/2026): com os pesos de precisão o desvio-padrão residual fica ~1 e não é o da
  # expressão; a padronização usa a expressão em log2-CPM SEM pesos (antes, o g desses estudos ficava 2-4x menor)
  fit0 <- if (metodo == "voom") limma::eBayes(limma::lmFit(Y$E, design0), trend = TRUE)
          else if (ncol(design) > ncol(design0)) limma::eBayes(limma::lmFit(Y, design0), trend = metodo == "trend") else fit
  s <- sqrt(fit0$s2.post); df <- fit0$df.total
  J <- 1 - 3 / (4 * pmax(df, 2) - 1)                                    # correção de Hedges para amostras pequenas
  g <- J * lfc / s
  # variância de g (revisão de 08/10/2026): o 1º termo é o erro padrão do logFC do PRÓPRIO ajuste do limma
  # (sqrt(s2.post) x stdev.unscaled, que inclui pesos do voom e o desbalanço do desenho com covariáveis como lote),
  # levado à escala de g; o 2º termo é a incerteza do desvio-padrão com os mesmos graus de liberdade do J.
  # Sem covariáveis nem pesos, o 1º termo é J²(1/n1 + 1/n2) e g / sqrt(1º termo) = t moderado. Antes era
  # 1/n1 + 1/n2 + g²/(2(n1 + n2)): com 2 x 4 mulheres e g = 6,6 o IC (2,5 a 10,7) não correspondia ao p do limma, e
  # no GSE18732 (lote como covariável) o estudo pesava ~20% a mais do que a precisão que o limma lhe dá.
  se_lfc <- sqrt(fit$s2.post) * fit$stdev.unscaled[, 1]
  v <- (J * se_lfc / s)^2 + g^2 / (2 * pmax(df, 2))
  data.frame(id = names(lfc), logFC = lfc, g = g, var_g = v, t = fit$t[, 1], p = fit$p.value[, 1], n1 = n1, n2 = n2, metodo = metodo, lote_ajustado = lote_usado, stringsAsFactors = FALSE)
}

# ---------------- vias (Hallmark) ----------------
conjuntos_hallmark <- function(MC) {
  h <- tryCatch(msigdbr::msigdbr(species = "Homo sapiens", collection = MC$vias$colecao),
                error = function(e) msigdbr::msigdbr(species = "Homo sapiens", category = MC$vias$colecao))
  split(h$gene_symbol, h$gs_name)
}
# competitivo = TRUE (decisão do usuário, 08/10/2026): o escore de cada amostra é descontado da média dos z de
# todos os genes da amostra, para que um deslocamento global (composição, qualidade) não pareça efeito de via
escores_vias <- function(ex, conj, min_genes, competitivo = isTRUE(getOption("vias_competitivo", TRUE))) {
  z <- t(scale(t(ex))); z <- z[stats::complete.cases(z), , drop = FALSE]
  s <- t(sapply(conj, function(g) { g <- intersect(g, rownames(z)); if (length(g) >= min_genes) colMeans(z[g, , drop = FALSE]) else stats::setNames(rep(NA_real_, ncol(z)), colnames(z)) }))   # NA com nomes: sem eles o sapply perdia as colunas
  if (competitivo) s <- sweep(s, 2, colMeans(z), "-")
  s[stats::complete.cases(s), , drop = FALSE]
}

# ---------------- meta-análise (DerSimonian-Laird, vetorizada) ----------------
# G, V: matrizes linhas x estudos (NA onde o gene não foi medido); P: p de cada estudo
# metodo = "hk": Hartung-Knapp (variância do efeito combinado pela dispersão observada, teste t com k-1 g.l.;
#   versão modificada com q* = max(1, q), que nunca é menos conservadora que DL). Recomendada com poucos
#   estudos (revisão de metodologia de 07/10/2026, item A3). metodo = "dl": DerSimonian-Laird com teste z.
# Testes combinados (pedido do usuário, 08/10/2026), ao lado do Hartung-Knapp:
#   Stouffer ponderado com sinal: z_i = sinal(g_i) * qnorm(1 - p_i/2), peso sqrt(n_i); soma a evidência dos estudos
#   rOP (r = 2): testa "efeito em pelo menos 2 estudos" (não exige todos). Revisão de 08/10/2026: a nula é composta
#     ("no máximo 1 estudo tem efeito"); no pior caso um estudo tem efeito (p = 0) e o 2º menor p é o menor dos k - 1
#     nulos, p = 1 - (1 - p_(2))^(k - 1). A versão anterior, pbeta(p_(2), 2, k - 1), supunha todos nulos e era otimista.
#     Se os 2 estudos mais fortes discordam no sinal, p = 1 (antes NA, o que tirava o teste da família do FDR)
#   Cochran Q: p da heterogeneidade entre os estudos
meta_dl <- function(G, V, P, metodo = "hk", N = NULL) {
  k <- rowSums(!is.na(G)); m <- !is.na(G)
  w <- 1 / V; w[!m] <- 0; Gz <- G; Gz[!m] <- 0
  sw <- rowSums(w); mu_f <- rowSums(w * Gz) / sw
  Q <- rowSums(w * (Gz - mu_f)^2 * m); C <- sw - rowSums(w^2) / sw
  tau2 <- ifelse(k >= 2, pmax(0, (Q - (k - 1)) / C), 0)
  ws <- 1 / (V + tau2); ws[!m] <- 0
  mu <- rowSums(ws * Gz) / rowSums(ws); se <- sqrt(1 / rowSums(ws))
  p_dl <- 2 * stats::pnorm(-abs(mu / se))
  q <- rowSums(ws * (Gz - mu)^2 * m) / pmax(k - 1, 1); se_hk <- sqrt(pmax(1, q) / rowSums(ws))
  p_hk <- ifelse(k >= 2, 2 * stats::pt(-abs(mu / se_hk), pmax(k - 1, 1)), NA_real_)
  hk <- metodo == "hk"
  p_meta <- if (hk) p_hk else p_dl
  meia <- if (hk) stats::qt(0.975, pmax(k - 1, 1)) * se_hk else 1.96 * se
  # descoberta (1 estudo): efeito e p do próprio estudo (teste do limma)
  p1 <- apply(ifelse(m, P, NA), 1, function(z) z[!is.na(z)][1])
  meia <- ifelse(k >= 2, meia, 1.96 * se)
  r <- data.frame(id = rownames(G), estudos = k, nivel = ifelse(k >= 2, "replicado", "descoberta"), g = mu, ic_inf = mu - meia, ic_sup = mu + meia,
                  p = ifelse(k >= 2, p_meta, p1), I2 = ifelse(k >= 2 & Q > 0, pmax(0, (Q - (k - 1)) / Q), NA_real_), tau2 = ifelse(k >= 2, tau2, NA_real_),
                  mesmo_sentido = rowSums(sign(G) == sign(mu), na.rm = TRUE), p_dl = ifelse(k >= 2, p_dl, NA_real_), p_hk = p_hk, stringsAsFactors = FALSE)
  # testes combinados
  Pz <- ifelse(m, pmin(pmax(P, 1e-300), 1), NA); Zs <- sign(G) * stats::qnorm(1 - Pz / 2)
  W <- if (is.null(N)) matrix(1, nrow(G), ncol(G)) else sqrt(N); W[!m] <- 0; Zs[!m] <- 0
  r$p_stouffer <- ifelse(k >= 2, 2 * stats::pnorm(-abs(rowSums(W * Zs) / sqrt(rowSums(W^2)))), NA_real_)
  r$p_rop2 <- vapply(seq_len(nrow(G)), function(i) { if (k[i] < 2) return(NA_real_)
    pi <- P[i, m[i, ]]; gi <- G[i, m[i, ]]; o <- order(pi)[1:2]
    if (sign(gi[o[1]]) != sign(gi[o[2]])) return(1)                      # os 2 mais fortes discordam: não é "efeito em 2 estudos"
    1 - (1 - pi[o[2]])^(k[i] - 1) }, 1)                                  # calibrado para a nula composta (08/10/2026)
  r$p_heterogeneidade <- ifelse(k >= 2, stats::pchisq(Q, pmax(k - 1, 1), lower.tail = FALSE), NA_real_)
  # efeito fixo (inverso da variância): base do nível exploratório em tecidos com 2 estudos (decisão do usuário, 08/10/2026)
  r$g_fe <- ifelse(k >= 2, mu_f, NA_real_)
  r$p_fe <- ifelse(k >= 2, 2 * stats::pnorm(-abs(mu_f) * sqrt(sw)), NA_real_)
  r$fdr <- NA_real_; r$fdr_stouffer <- NA_real_; r$fdr_rop2 <- NA_real_
  for (nv in unique(r$nivel)) { i <- r$nivel == nv; r$fdr[i] <- stats::p.adjust(r$p[i], "BH")
    r$fdr_stouffer[i] <- stats::p.adjust(r$p_stouffer[i], "BH"); r$fdr_rop2[i] <- stats::p.adjust(r$p_rop2[i], "BH") }
  r
}

# Influência de cada estudo (pedido do usuário, 08/10/2026): peso na meta-análise de efeitos aleatórios, efeito e
# p sem o estudo (Hartung-Knapp), e se a retirada muda o sentido ou a conclusão (p < 0,05)
influencia <- function(efs, ids, metodo = "hk") {
  if (length(efs) < 2 || !length(ids)) return(NULL)
  full <- meta_tecido(efs, metodo = metodo); full <- full[match(ids, full$id), ]
  G <- sapply(efs, function(e) e$g[match(ids, e$id)]); V <- sapply(efs, function(e) e$var_g[match(ids, e$id)])
  G <- matrix(G, nrow = length(ids)); V <- matrix(V, nrow = length(ids))
  ws <- 1 / (V + ifelse(is.na(full$tau2), 0, full$tau2)); ws[is.na(G)] <- 0; peso <- ws / rowSums(ws)
  do.call(rbind, lapply(seq_along(efs), function(j) {
    m <- if (length(efs) >= 2) meta_tecido(efs[-j], metodo = metodo) else NULL
    x <- if (!is.null(m)) m[match(ids, m$id), ] else NULL
    data.frame(id = ids, estudo = names(efs)[j], g_estudo = G[, j], peso_pct = round(100 * peso[, j], 1), g_todos = full$g, p_todos = full$p,
               g_sem = if (!is.null(x)) x$g else NA, p_sem = if (!is.null(x)) x$p else NA,
               inverte_sentido = if (!is.null(x)) sign(x$g) != sign(full$g) else NA,
               muda_conclusao = if (!is.null(x)) (full$p < 0.05) != (x$p < 0.05) else NA, stringsAsFactors = FALSE) }))
}

# junta os efeitos dos estudos de um tecido em matrizes e faz a meta-análise
meta_tecido <- function(efs, col_id = "id", metodo = "hk") {
  ids <- sort(unique(unlist(lapply(efs, `[[`, col_id))))
  mk <- function(campo) sapply(efs, function(e) e[[campo]][match(ids, e[[col_id]])])
  G <- matrix(mk("g"), length(ids)); V <- matrix(mk("var_g"), length(ids)); P <- matrix(mk("p"), length(ids)); L <- matrix(mk("logFC"), length(ids))
  N <- if (all(c("n1", "n2") %in% names(efs[[1]]))) matrix(mk("n1"), length(ids)) + matrix(mk("n2"), length(ids)) else NULL
  rownames(G) <- ids; colnames(G) <- names(efs)
  r <- meta_dl(G, V, P, metodo, N)
  r$logFC_medio <- rowMeans(L, na.rm = TRUE)
  r$estudos_lista <- apply(!is.na(G), 1, function(z) paste(names(efs)[z], collapse = ";"))
  r[order(r$nivel != "replicado", r$p), ]
}

# efeito mínimo detectável (g) com o poder pedido, a partir dos n de cada estudo (efeito fixo)
mde <- function(n1, n2, alfa, poder) (stats::qnorm(1 - alfa / 2) + stats::qnorm(poder)) * sqrt(1 / sum(1 / (1 / n1 + 1 / n2)))

# ---------------- checagens de sanidade e balanço (revisão de metodologia de 07/10/2026) ----------------
# fração de genes com p < 0,05 (sem efeito ~5%) e inflação genômica lambda (mediana do qui-quadrado / 0,455)
sanidade <- function(p) c(frac_p05 = mean(p < 0.05), lambda = stats::median(stats::qchisq(1 - p, 1)) / stats::qchisq(0.5, 1))

# doadoras com perfil idêntico (tecido, status, idade, IMC) em estudos diferentes do mesmo tecido
# revisão de 08/10/2026: só doadoras COM IMC entram (sem IMC, a chave era só tecido + status + idade inteira e as
# coincidências eram esperadas); o resultado é pista para conferir na fonte, não prova de sobreposição
sobreposicao_perfil <- function(lista_am) {
  x <- do.call(rbind, lapply(names(lista_am), function(g) { a <- lista_am[[g]]
    data.frame(gse = g, tecido = a$tecido_estudo[1], individuo = a$individuo, status = a$status, idade = a$idade, bmi = round(a$bmi, 1)) }))
  x <- x[!is.na(x$bmi) & !is.na(x$idade), ]
  x$chave <- paste(x$tecido, x$status, x$idade, x$bmi)
  d <- x[x$chave %in% x$chave[duplicated(x$chave)], ]
  ks <- names(which(tapply(d$gse, d$chave, function(z) length(unique(z))) > 1)); d <- d[d$chave %in% ks, ]
  d[order(d$chave), ]
}

# p usado no nível EXPLORATÓRIO (decisão do usuário, 08/10/2026): em tecido com exatamente 2 estudos o Hartung-Knapp
# (t com 1 g.l.) não alcança p < 0,05; usa-se o efeito fixo. Nos demais, o próprio p (Hartung-Knapp).
p_exploratorio_tecido <- function(m, n_estudos_tecido, RC) {
  if (n_estudos_tecido == 2 && isTRUE(RC$teste$efeito_fixo_2_estudos) && "p_fe" %in% names(m)) ifelse(is.na(m$p_fe), m$p, m$p_fe) else m$p
}
rotulo_exploratorio <- function(n_estudos_tecido, RC) if (n_estudos_tecido == 2 && isTRUE(RC$teste$efeito_fixo_2_estudos)) "exploratório (efeito fixo, 2 estudos)" else "exploratório"
