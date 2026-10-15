# Reavaliação por expressão (12/10/2026): GSE50397 (array HuGene 1.0 ST dos mesmos 89 doadores do GSE50244) x GSE41762
# (mesma plataforma). Mesmo doador => perfil centrado quase idêntico e muito acima do 2º melhor par.
# Uso: Rscript reavaliar_GSE50244_expressao.R <pasta com os series_matrix>
setwd("C:/Users/ihope/OneDrive/Área de Trabalho/DM jana/workflow_dm_menopausa")
dd <- commandArgs(TRUE)[1]
ler <- function(g) {
  L <- readLines(gzfile(file.path(dd, paste0(g, "_series_matrix.txt.gz"))))
  i0 <- grep("^!series_matrix_table_begin", L); i1 <- grep("^!series_matrix_table_end", L)
  X <- utils::read.delim(text = L[(i0 + 1):(i1 - 1)], row.names = 1, check.names = FALSE); X <- as.matrix(X)
  ch <- L[grepl("^!Sample_characteristics_ch1", L)]
  meta <- do.call(cbind, lapply(ch, function(z) { v <- gsub('"', "", strsplit(z, "\t")[[1]][-1]); k <- sub(":.*", "", v[1]); stats::setNames(list(sub("^[^:]*: *", "", v)), tolower(k)) }))
  meta <- as.data.frame(lapply(meta, unlist), stringsAsFactors = FALSE); meta$gsm <- colnames(X); list(X = X, meta = meta) }
a <- ler("GSE50397"); b <- ler("GSE41762")
p <- intersect(rownames(a$X), rownames(b$X)); cat("sondas em comum:", length(p), "\n")
A <- a$X[p, ]; B <- b$X[p, ]
v <- apply(cbind(A, B), 1, stats::var); p2 <- names(sort(v, decreasing = TRUE))[1:5000]          # sondas mais variáveis
cen <- function(M) M - rowMeans(M)
R <- stats::cor(cen(A[p2, ]), cen(B[p2, ]))                                                     # 89 x 77, centrado dentro de cada estudo
r1 <- apply(R, 1, max); j1 <- apply(R, 1, which.max); r2 <- apply(R, 1, function(z) sort(z, decreasing = TRUE)[2])
# idênticos? diferença absoluta média nas sondas comuns, no melhor par (valores na escala do autor)
mad1 <- vapply(seq_len(nrow(R)), function(i) mean(abs(A[, i] - B[, j1[i]]), na.rm = TRUE), 0)
res <- data.frame(gsm_50397 = colnames(A), melhor_41762 = colnames(B)[j1], r_melhor = round(r1, 3), r_segundo = round(r2, 3), dif_media_abs = round(mad1, 3))
# metadados para conferir e para ligar ao GSE50244
m <- a$meta; res <- cbind(res, m[match(res$gsm_50397, m$gsm), setdiff(names(m), "gsm"), drop = FALSE])
mb <- b$meta; names(mb) <- paste0(names(mb), "_41762"); res <- cbind(res, mb[match(res$melhor_41762, mb$gsm_41762), setdiff(names(mb), "gsm_41762"), drop = FALSE])
res <- res[order(-res$r_melhor), ]
utils::write.csv(res, "output/02_metadados/reavaliacao_GSE50244_expressao.csv", row.names = FALSE, fileEncoding = "UTF-8")
options(width = 250)
cat("\ndistribuição do melhor r (centrado):\n"); print(summary(res$r_melhor)); cat("2º melhor:\n"); print(summary(res$r_segundo))
cat("\nr_melhor > 0,8:", sum(res$r_melhor > 0.8), "; 0,5-0,8:", sum(res$r_melhor > 0.5 & res$r_melhor <= 0.8), "; <= 0,5:", sum(res$r_melhor <= 0.5), "\n")
cat("melhor par usado por mais de um doador do GSE50397:", sum(duplicated(res$melhor_41762[res$r_melhor > 0.5])), "\n")
cat("dif. média absoluta no melhor par: mín", min(res$dif_media_abs), "mediana", stats::median(res$dif_media_abs), "\n")
print(utils::head(res[, 1:min(12, ncol(res))], 8)); print(utils::tail(res[, 1:min(12, ncol(res))], 8))
