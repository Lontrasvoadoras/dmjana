###############################################################################
#  09_validacao_celula.R - ETAPA 09: validação do programa das ilhotas com célula única (pedido do usuário, 08/10/2026)
#   9.1 pseudo-bulk por doadora x tipo celular (h5ad do GSE221156)
#   9.2 deconvolução (NNLS) dos estudos de ilhotas com referência de célula única; efeito ajustado pela composição
#  Usa carregar_estudo / ajustar / meta_tecido (etapa 05) e eigengenes_estudo (etapa 06).
###############################################################################

h5_cat <- function(f, campo) { g <- paste0("/obs/", campo)
  tryCatch({ cod <- rhdf5::h5read(f, paste0(g, "/codes")); cat <- rhdf5::h5read(f, paste0(g, "/categories")); as.character(cat[cod + 1]) },
           error = function(e) as.vector(rhdf5::h5read(f, g))) }

# soma das contagens brutas por doadora x tipo celular (lida em blocos, como na etapa 04)
pseudobulk_por_tipo <- function(VC) {
  f <- VC$h5ad; base <- if ("raw" %in% rhdf5::h5ls(f, recursive = FALSE)$name) "/raw" else ""
  doador <- h5_cat(f, "donor_id"); anot <- h5_cat(f, VC$campo_tipo)
  mapa <- unlist(lapply(names(VC$tipos), function(t) stats::setNames(rep(t, length(VC$tipos[[t]])), unlist(VC$tipos[[t]]))))
  tipo <- unname(mapa[anot])
  grupo <- ifelse(is.na(tipo), NA, paste(doador, tipo, sep = "|"))
  genes <- tryCatch(as.character(rhdf5::h5read(f, paste0(base, "/var/feature_name/categories"))[rhdf5::h5read(f, paste0(base, "/var/feature_name/codes")) + 1]),
                    error = function(e) as.character(rhdf5::h5read(f, paste0(base, "/var/_index"))))
  indptr <- as.numeric(rhdf5::h5read(f, paste0(base, "/X/indptr")))
  gg <- factor(grupo); ng <- length(genes); nk <- nlevels(gg)
  pb <- Matrix::sparseMatrix(i = integer(), j = integer(), x = numeric(), dims = c(ng, nk))   # soma esparsa (memória)
  blocos <- split(seq_along(doador), ceiling(seq_along(doador) / 20000))
  for (b in blocos) {
    i0 <- indptr[min(b)] + 1; i1 <- indptr[max(b) + 1]
    idx <- rhdf5::h5read(f, paste0(base, "/X/indices"), index = list(i0:i1)); val <- rhdf5::h5read(f, paste0(base, "/X/data"), index = list(i0:i1))
    linha <- rep(b, diff(indptr[c(b, max(b) + 1)])); j <- as.integer(gg[linha]); ok <- !is.na(j)
    pb <- pb + Matrix::sparseMatrix(i = as.integer(idx[ok]) + 1, j = j[ok], x = as.numeric(val[ok]), dims = c(ng, nk))
  }
  pb <- as.matrix(pb); dimnames(pb) <- list(genes, levels(gg))
  rhdf5::h5closeAll()
  pb <- soma_por_simbolo(round(pb), genes)
  col <- data.frame(coluna = colnames(pb), doador = sub("\\|.*", "", colnames(pb)), tipo = sub(".*\\|", "", colnames(pb)),
                    n_celulas = as.integer(table(gg)[colnames(pb)]), stringsAsFactors = FALSE)
  # células por doadora (todas as anotadas, para a composição verdadeira)
  comp <- as.data.frame.matrix(table(doador[!is.na(tipo)], tipo[!is.na(tipo)]))
  list(cnt = pb, col = col, comp = comp)
}

# referência: CPM médio por tipo (todas as doadoras somadas) e marcadores específicos
referencia_tipos <- function(VC, P) {
  por_tipo <- sapply(unique(P$col$tipo), function(t) rowSums(P$cnt[, P$col$tipo == t, drop = FALSE]))
  cpm <- t(t(por_tipo) / colSums(por_tipo)) * 1e6
  M <- VC$marcadores
  mk <- lapply(colnames(cpm), function(t) { o <- cpm[, setdiff(colnames(cpm), t), drop = FALSE]; r <- log2((cpm[, t] + 1) / (apply(o, 1, max) + 1))
    g <- names(r)[cpm[, t] >= M$cpm_min & r >= M$log2_razao_min]; utils::head(g[order(-r[g])], M$por_tipo) })
  names(mk) <- colnames(cpm)
  ncel <- tapply(P$col$n_celulas, P$col$tipo, sum)
  list(cpm = cpm, marcadores = mk, rna_por_celula = colSums(por_tipo) / as.numeric(ncel[colnames(por_tipo)]))
}

# deconvolução NNLS: y (escala linear, normalizado como CPM sobre todos os genes) ~ CPM dos tipos nos marcadores.
# Os coeficientes são a fração do RNA de cada tipo; divididos pelo RNA por célula de cada tipo (contagens / células na
# referência) viram fração de CÉLULAS, comparável com a contagem de células do h5ad.
deconvoluir <- function(Y, ref) {
  g <- intersect(unique(unlist(ref$marcadores)), rownames(Y)); R <- ref$cpm[g, , drop = FALSE]
  Yc <- sweep(Y, 2, colSums(Y), "/") * 1e6
  Fr <- t(apply(Yc[g, , drop = FALSE], 2, function(y) { b <- nnls::nnls(R, y)$x; b <- b / ref$rna_por_celula[colnames(R)]; b / max(sum(b), 1e-12) }))
  colnames(Fr) <- colnames(R); attr(Fr, "marcadores_usados") <- length(g); Fr
}
