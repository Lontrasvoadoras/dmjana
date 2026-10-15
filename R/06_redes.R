###############################################################################
#  06_redes.R - ETAPA 06: redes de coexpressão (WGCNA) por tecido
#
#  Intenção (docs/intencao_06_redes.docx, aprovada em 07/10/2026; config/redes.yaml):
#   6.1 rede de consenso por tecido com TODAS as amostras aptas dos estudos com >= min_doadores (a rede
#       não usa o status de DM2); efeito do lote (data de leitura) retirado antes, preservando status e sexo (R8)
#   6.2 preservação dos módulos nos estudos de construção (Zsummary)
#   6.3 teste: eigengene de cada módulo, DM2 x sem diabetes SÓ nas mulheres de 40-60, mesmo modelo da etapa 05
#       (g de Hedges, Hartung-Knapp por tecido, FDR entre módulos); seleção significativo / sugestivo /
#       exploratório (opção B)
#   6.4 genes-chave: kME alto em pelo menos 2 estudos de construção (todos, se forem 2; revisão de 08/10/2026) e efeito
#       do DM2 no mesmo sentido do módulo
#
#  Usa as funções da etapa 05 (carregar_estudo, ajustar, meta_tecido, genes_codificantes).
###############################################################################

# expressão de um estudo para a rede: todas as amostras mantidas; lote retirado preservando status x sexo
dados_rede <- function(RC, est) {
  am <- est$am; ex <- est$ex[, am$coluna, drop = FALSE]
  lote_tirado <- FALSE
  if (isTRUE(RC$rede$remover_lote) && all(!is.na(am$lote)) && length(unique(am$lote)) >= 2) {
    grp <- factor(paste(am$status, ifelse(is.na(am$sexo), "S", am$sexo)))
    ex <- limma::removeBatchEffect(ex, batch = am$lote, design = stats::model.matrix(~ grp)); lote_tirado <- TRUE
  }
  attr(ex, "lote_tirado") <- lote_tirado
  ex
}

# genes da rede: comuns aos estudos de construção, ordenados pela média do posto de variância em cada estudo
genes_rede <- function(exs, n) {
  comuns <- Reduce(intersect, lapply(exs, rownames))
  pv <- sapply(exs, function(x) rank(-apply(x[comuns, , drop = FALSE], 1, stats::var)))
  comuns[order(rowMeans(as.matrix(pv)))][seq_len(min(n, length(comuns)))]
}

# potência: a menor com R² >= r2_min em TODOS os estudos; senão a recomendação da WGCNA pelo número de amostras
escolher_potencia <- function(RC, multi) {
  R <- RC$rede; pv <- unlist(R$potencias)
  r2 <- sapply(multi, function(x) { f <- suppressWarnings(WGCNA::pickSoftThreshold(x$data, powerVector = pv, networkType = R$tipo, corFnc = WGCNA::bicor,
                                                                                  corOptions = list(maxPOutliers = R$max_p_outliers), verbose = 0)$fitIndices)
                                     -sign(f$slope) * f$SFT.R.sq })
  r2 <- matrix(r2, nrow = length(pv)); minr2 <- apply(r2, 1, min)
  ok <- which(minr2 >= R$r2_min)
  if (length(ok)) return(list(potencia = pv[ok[1]], r2 = round(minr2[ok[1]], 2), criterio = "R² livre de escala"))
  n <- min(sapply(multi, function(x) nrow(x$data)))
  p <- if (n < 20) 18 else if (n < 30) 16 else if (n < 40) 14 else 12                 # tabela da FAQ da WGCNA (rede signed)
  list(potencia = p, r2 = round(minr2[match(p, pv)], 2), criterio = sprintf("R² < %.2f em algum estudo: potência padrão da WGCNA para n = %d", R$r2_min, n))
}

construir_rede <- function(RC, multi, potencia) {
  R <- RC$rede
  if (length(multi) == 1) {
    net <- WGCNA::blockwiseModules(multi[[1]]$data, power = potencia, networkType = R$tipo, TOMType = "signed", corType = "bicor", maxPOutliers = R$max_p_outliers,
                                   minModuleSize = R$min_modulo, deepSplit = R$deep_split, mergeCutHeight = R$merge_corte, maxBlockSize = R$max_genes + 1,
                                   numericLabels = TRUE, pamRespectsDendro = FALSE, saveTOMs = FALSE, verbose = 0)
  } else {
    q <- max(0, (length(multi) - R$consenso_min_estudos) / (length(multi) - 1))   # 2º maior entre os estudos (>= 2 estudos)
    net <- WGCNA::blockwiseConsensusModules(multi, power = potencia, networkType = R$tipo, TOMType = "signed", corType = "bicor", maxPOutliers = R$max_p_outliers, consensusQuantile = q,
                                            minModuleSize = R$min_modulo, deepSplit = R$deep_split, mergeCutHeight = R$merge_corte, maxBlockSize = R$max_genes + 1,
                                            numericLabels = TRUE, pamRespectsDendro = FALSE, saveConsensusTOMs = FALSE, verbose = 0)
  }
  cores <- net$colors; names(cores) <- colnames(multi[[1]]$data)
  cores
}

# eigengenes de um estudo (linhas = módulos, colunas = amostras); módulo com < 50% dos genes medidos fica de fora
eigengenes_estudo <- function(ex, cores) {
  mods <- setdiff(sort(unique(cores)), 0)
  E <- t(sapply(mods, function(m) { g <- intersect(names(cores)[cores == m], rownames(ex))
    if (length(g) < 0.5 * sum(cores == m) || length(g) < 5) return(rep(NA_real_, ncol(ex)))
    WGCNA::moduleEigengenes(t(ex[g, , drop = FALSE]), colors = rep(m, length(g)), excludeGrey = FALSE)$eigengenes[, 1] }))
  E <- matrix(E, nrow = length(mods), dimnames = list(paste0("M", mods), colnames(ex)))
  E[stats::complete.cases(E), , drop = FALSE]
}

# preservação: estudo de referência (o maior) x cada outro estudo de construção
preservacao <- function(RC, multi, cores) {
  if (length(multi) < 2) return(NULL)
  P <- RC$preservacao; ref <- which.max(sapply(multi, function(x) nrow(x$data)))
  do.call(rbind, lapply(setdiff(seq_along(multi), ref), function(k) {
    mp <- WGCNA::modulePreservation(list(ref = multi[[ref]], teste = multi[[k]]), list(ref = cores), referenceNetworks = 1, networkType = RC$rede$tipo,
                                    corFnc = "bicor", nPermutations = P$permutacoes, maxModuleSize = P$max_tamanho_modulo, randomSeed = 1, quickCor = 1, verbose = 0)
    z <- mp$preservation$Z$ref.ref$inColumnsAlsoPresentIn.teste
    data.frame(modulo = paste0("M", rownames(z)), referencia = names(multi)[ref], teste = names(multi)[k], tamanho = z$moduleSize, Zsummary = round(z$Zsummary.pres, 2))
  }))
}

# nível de seleção dos módulos de um tecido (definido antes de rodar)
selecionar_modulos <- function(RC, m) {
  T <- RC$teste
  m$selecao <- ifelse(!is.na(m$fdr) & m$fdr < T$fdr, "significativo", ifelse(!is.na(m$fdr) & m$fdr < T$fdr_sugestivo, "sugestivo", ""))
  if (!any(nzchar(m$selecao))) {                                       # opção B: nenhum módulo com FDR < 0,10 no tecido
    pe <- m$p_expl %||% m$p; rot <- m$rotulo_expl[1] %||% "exploratório"   # tecido com 2 estudos: efeito fixo (08/10/2026)
    m$selecao <- ifelse(pe < T$p_exploratorio & m$mesmo_sentido == m$estudos & m$estudos >= 2, rot,   # todos os estudos (2+)
                 ifelse(!is.na(m$fdr_rop2) & m$fdr_rop2 < T$fdr_rop2, "exploratório (≥ 2 estudos)",               # efeito em pelo menos 2 estudos (08/10/2026)
                 ifelse(m$estudos == 1 & m$p < T$p_exploratorio, "exploratório (1 estudo)", "")))                   # tecido com 1 estudo (fígado; pedido do usuário, 08/10/2026)
  }
  m$selecao[m$preservado %in% FALSE] <- ""                             # não preservado ou cálculo falhou: não segue
  # preservação não avaliável (1 estudo de construção, ex.: fígado) segue, rotulada "exploratório (1 estudo)" quando p < 0,05
  m
}

# kME de cada gene com o eigengene do seu módulo, em cada estudo de construção
kme_genes <- function(multi, cores) {
  mods <- setdiff(sort(unique(cores)), 0)
  K <- sapply(names(multi), function(s) { x <- multi[[s]]$data
    ME <- WGCNA::moduleEigengenes(x, colors = cores, excludeGrey = TRUE)$eigengenes
    v <- rep(NA_real_, length(cores)); names(v) <- names(cores)
    for (m in mods) { g <- names(cores)[cores == m]; v[g] <- as.numeric(WGCNA::cor(x[, g, drop = FALSE], ME[, paste0("ME", m)], use = "p")) }
    v })
  K <- matrix(K, ncol = length(multi), dimnames = list(names(cores), names(multi)))
  # kME_2 = 2º maior kME entre os estudos (com 1 estudo, o próprio; com 2, o menor): gene-chave com kME alto em pelo menos
  # 2 estudos, coerente com a rede de consenso em >= 2 estudos (decisão do usuário, revisão de 08/10/2026)
  k2 <- apply(K, 1, function(z) { z <- sort(z, decreasing = TRUE); if (length(z) >= 2) z[2] else z[1] })
  data.frame(gene = names(cores), modulo = ifelse(cores == 0, "cinza (sem módulo)", paste0("M", cores)), kME_min = round(apply(K, 1, min), 3), kME_2 = round(k2, 3), round(K, 3), check.names = FALSE)
}

# assinatura da rede (revisão de 08/10/2026): estudos de construção, genes, expressão usada e parâmetros da rede e da
# preservação. Com a mesma assinatura, a rede e a preservação (a parte cara) são reaproveitadas do cache; o teste dos
# módulos, a seleção, a influência e os genes-chave são SEMPRE refeitos (dependem da etapa 05 e da config de teste)
assinatura_rede <- function(RC, constr, genes, exr) {
  f <- tempfile(); saveRDS(list(constr = constr, genes = genes, rede = RC$rede, preservacao = RC$preservacao,
                                ex = lapply(exr, function(x) round(x[genes, , drop = FALSE], 4))), f)
  a <- unname(tools::md5sum(f)); unlink(f); a
}
