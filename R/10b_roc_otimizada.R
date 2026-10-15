###############################################################################
#  10b_roc_otimizada.R - ETAPA 10b: otimização ANINHADA do conjunto de genes da curva ROC (pedido do usuário, 09/10/2026)
#  "Otimizar" a AUC escolhendo o conjunto nos mesmos dados em que ela é medida dá AUC alta quase garantida. Aqui a regra
#  de escolha dos genes (fonte x tamanho) é escolhida DENTRO do treino (deixar um estudo de fora interno) e só depois
#  avaliada no estudo escondido (deixar um estudo de fora externo). Para "todos os tecidos", o mesmo com um TECIDO
#  inteiro escondido. Usa meta_tecido (05), escore_auc / ep_auc / p_treino (10_roc.R).
###############################################################################

.memo <- new.env()
# meta-análise dos estudos de treino (memorizada por conjunto de estudos e universo de genes)
meta_treino <- function(treino, efg, univ = NULL, chave_univ = "genoma") {
  k <- paste(c(sort(treino), chave_univ), collapse = "|")
  if (!is.null(.memo[[k]])) return(.memo[[k]])
  ef <- lapply(efg[treino], function(e) if (is.null(univ)) e else e[e$id %in% univ, ])
  m <- meta_tecido(ef, metodo = "hk"); m$p_t <- p_treino(m, length(treino)); .memo[[k]] <- m; m
}

# genes escolhidos por uma regra (fonte = "modulo" ou "genoma"; k genes) só com os estudos de treino
genes_por_regra <- function(fonte, k, treino, efg, cores = NULL, efm = NULL, frac_medido = 1) {
  n <- length(treino); mod <- NA_character_; univ <- NULL
  if (fonte == "modulo") {
    em <- efm[efm$gse %in% treino, ]; mm <- meta_tecido(split(em, em$gse), metodo = "hk"); mm$p_t <- p_treino(mm, n)
    mm <- mm[mm$mesmo_sentido == mm$estudos & mm$estudos == n, ]; if (!nrow(mm)) return(NULL)
    mod <- mm$id[which.min(mm$p_t)]; univ <- names(cores)[paste0("M", cores) == mod]
  }
  m <- meta_treino(treino, efg, univ, if (is.null(univ)) "genoma" else mod)
  if (frac_medido >= 1) m <- m[m$estudos == n & m$mesmo_sentido == m$estudos, ] else m <- m[m$estudos >= ceiling(frac_medido * n) & m$mesmo_sentido >= ceiling(0.8 * m$estudos), ]
  m <- m[order(m$p_t), ]; s <- utils::head(m, k)
  if (!nrow(s)) return(NULL)
  list(genes = s$id, sentido = sign(s$g), modulo = mod)
}

# AUC de uma regra num conjunto de estudos de teste (média das AUCs dos estudos avaliáveis)
auc_regra <- function(regra, treino, teste, efg, E, cores, efm, min_genes, frac_medido = 1) {
  sel <- genes_por_regra(regra$fonte, regra$k, treino, efg, cores, efm, frac_medido); if (is.null(sel)) return(NA_real_)
  a <- vapply(teste, function(s) { r <- escore_auc(E[[s]], sel$genes, sel$sentido); if (is.null(r) || r$genes_medidos < min_genes) NA_real_ else r$auc }, 0)
  mean(a, na.rm = TRUE)
}
