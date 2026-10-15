###############################################################################
#  10_roc.R - ETAPA 10: curva ROC dos programas, deixando um estudo de fora (pedido do usuário, 09/10/2026)
#  Usa carregar_estudo / meta_tecido / p_exploratorio_tecido (etapa 05).
###############################################################################

# p usado na escolha dos genes no treino: Hartung-Knapp com 3+ estudos; efeito fixo com 2 (decisão de 08/10/2026);
# com 1 estudo, o próprio p do limma (meta_tecido devolve o p do estudo como "descoberta")
p_treino <- function(m, n) if (n == 2 && "p_fe" %in% names(m)) ifelse(is.na(m$p_fe), m$p, m$p_fe) else m$p

# escolha do módulo e dos genes só com os estudos de treino
escolher_programa <- function(OC, tec, treino, cores, efm, efg) {
  em <- efm[efm$gse %in% treino, ]; mm <- meta_tecido(split(em, em$gse), metodo = "hk")
  mm$p_t <- p_treino(mm, length(treino)); mm <- mm[mm$mesmo_sentido == mm$estudos & mm$estudos == length(treino), ]
  mod <- mm$id[which.min(mm$p_t)]
  genes_mod <- names(cores)[paste0("M", cores) == mod]
  ef <- lapply(efg[treino], function(e) e[e$id %in% genes_mod, ]); mg <- meta_tecido(ef, metodo = "hk")
  mg$p_t <- p_treino(mg, length(treino)); mg <- mg[mg$estudos == length(treino) & mg$mesmo_sentido == mg$estudos, ]; mg <- mg[order(mg$p_t), ]
  G <- OC$genes; sel <- mg[mg$p_t < G$p_max, ]
  regra <- sprintf("p < %.2f e mesmo sentido em todos os estudos de treino", G$p_max)
  if (nrow(sel) < G$min) { sel <- utils::head(mg, G$reserva); regra <- sprintf("menos de %d genes com p < %.2f: os %d de menor p no mesmo sentido", G$min, G$p_max, G$reserva) }
  sel <- utils::head(sel, G$max)
  list(modulo = mod, p_modulo = mm$p_t[mm$id == mod], genes = sel$id, sentido = sign(sel$g), regra = regra, universo = mg)
}

# escore de sentido fixo nas mulheres de 40-60 do estudo testado e AUC
escore_auc <- function(est, genes, sentido) {
  a <- est$am[est$am$mulher_40a60 %in% TRUE & est$am$status %in% c("T2D", "ND"), ]
  k <- genes %in% rownames(est$ex); genes <- genes[k]; sentido <- sentido[k]
  if (length(genes) == 0 || sum(a$status == "T2D") < 2 || sum(a$status == "ND") < 2) return(NULL)
  X <- est$ex[genes, a$coluna, drop = FALSE]; Z <- t(scale(t(X))); Z[!is.finite(Z)] <- 0
  up <- sentido > 0; dn <- sentido < 0
  s <- (if (any(up)) colMeans(Z[up, , drop = FALSE]) else 0) - (if (any(dn)) colMeans(Z[dn, , drop = FALSE]) else 0)
  y <- factor(a$status, levels = c("ND", "T2D"))
  r <- pROC::roc(y, s, levels = c("ND", "T2D"), direction = "<", quiet = TRUE)
  ci <- tryCatch(as.numeric(pROC::ci.auc(r, method = "delong")), error = function(e) c(NA, NA, NA))
  pw <- suppressWarnings(stats::wilcox.test(s[y == "T2D"], s[y == "ND"], alternative = "greater", exact = TRUE)$p.value)
  list(auc = as.numeric(pROC::auc(r)), ic_inf = max(0, ci[1]), ic_sup = min(1, ci[3]), p_wilcoxon = pw, n_T2D = sum(y == "T2D"), n_ND = sum(y == "ND"),
       genes_medidos = length(genes), sobem = sum(up), descem = sum(dn), roc = r, escore = data.frame(coluna = a$coluna, status = a$status, escore = s))
}

# nulo: conjuntos sorteados do mesmo tamanho, com o sentido tirado do treino (mesma regra do conjunto real)
auc_nula <- function(est, efg_treino, n, B, semente) {
  m <- meta_tecido(efg_treino, metodo = "hk"); m <- m[m$estudos == length(efg_treino) & m$id %in% rownames(est$ex), ]
  set.seed(semente)
  vapply(seq_len(B), function(b) { i <- sample(nrow(m), n); r <- escore_auc(est, m$id[i], sign(m$g[i])); if (is.null(r)) NA_real_ else r$auc }, 0)
}

# erro padrão da AUC (Hanley e McNeil, 1982), com a AUC afastada de 0 e 1 para não zerar a variância
ep_auc <- function(A, n1, n0) { A <- pmin(pmax(A, 0.5 / (n1 * n0)), 1 - 0.5 / (n1 * n0)); Q1 <- A / (2 - A); Q2 <- 2 * A^2 / (1 + A)
  sqrt((A * (1 - A) + (n1 - 1) * (Q1 - A^2) + (n0 - 1) * (Q2 - A^2)) / (n1 * n0)) }

# ---------------- validação cruzada DENTRO do estudo (tecido com 1 estudo principal; pedido do usuário, 10/10/2026) ----------------
# Com 1 estudo não há "deixar um estudo de fora". No GSE130991 (fígado, 146 x 58) as mulheres de 40-60 são divididas em
# k partes (estratificadas por status); em cada rodada, o modelo da etapa 05 é refeito só com as outras partes (treino),
# o módulo e os genes são escolhidos pela mesma regra e o escore é avaliado na parte escondida. Repetido com sorteios
# diferentes das partes. A rede não é refeita (foi construída sem o status de DM2).
dobras_estratificadas <- function(y, k, semente) {
  set.seed(semente); f <- integer(length(y))
  for (cl in unique(y)) { i <- which(y == cl); f[i] <- sample(rep_len(seq_len(k), length(i))) }
  f
}
alvo_cv <- function(est) est$am[est$am$mulher_40a60 %in% TRUE & est$am$status %in% c("T2D", "ND"), ]
ajuste_treino <- function(MC, est, Eg, cols_fora) {                     # modelo da etapa 05 sem as mulheres escondidas
  e <- est; e$am <- est$am[!est$am$coluna %in% cols_fora, ]; so <- identical(MC$modelo_principal, "so_F40a60")
  list(genes = ajustar(MC, e, so_alvo = so), mods = ajustar(MC, e, Y = Eg, metodo = "limma", so_alvo = so))
}
# fonte: "padrao" (regra da etapa 10, dentro do módulo de menor p), "modulo" ou "genoma" com k genes de menor p
selecao_estudo <- function(aj, cores, OC, fonte = "padrao", k = NA) {
  mod <- aj$mods$id[which.min(aj$mods$p)]; gm <- names(cores)[paste0("M", cores) == mod]
  m <- aj$genes; m <- m[order(m$p), ]; regra <- NA_character_
  if (fonte == "genoma") s <- utils::head(m, k)
  else if (fonte == "modulo") s <- utils::head(m[m$id %in% gm, ], k)
  else { G <- OC$genes; u <- m[m$id %in% gm, ]; s <- u[u$p < G$p_max, ]; regra <- sprintf("p < %.2f no treino", G$p_max)
    if (nrow(s) < G$min) { s <- utils::head(u, G$reserva); regra <- sprintf("menos de %d genes com p < %.2f: os %d de menor p", G$min, G$p_max, G$reserva) }
    s <- utils::head(s, G$max) }
  list(modulo = mod, genes = s$id, sentido = sign(s$g), regra = regra)
}
# AUC das partes escondidas juntas (escore z dentro de cada parte, como no estudo escondido do deixar-um-de-fora)
auc_reunida <- function(esc) {
  y <- factor(esc$status, levels = c("ND", "T2D")); r <- pROC::roc(y, esc$escore, levels = c("ND", "T2D"), direction = "<", quiet = TRUE)
  ci <- tryCatch(as.numeric(pROC::ci.auc(r, method = "delong")), error = function(e) c(NA, NA, NA))
  pw <- suppressWarnings(stats::wilcox.test(esc$escore[y == "T2D"], esc$escore[y == "ND"], alternative = "greater")$p.value)
  list(auc = as.numeric(pROC::auc(r)), ic_inf = ci[1], ic_sup = ci[3], p_wilcoxon = pw, n_T2D = sum(y == "T2D"), n_ND = sum(y == "ND"), roc = r)
}
parte <- function(est, cols) { e <- est; e$am <- est$am[est$am$coluna %in% cols, ]; e }
