###############################################################################
#  04_processamento.R - ETAPA 04: obtenção e processamento dos dados de expressão
#
#  Intenção (validada em 06/10/2026, decisões D1-D7 em config/processamento.yaml): para cada estudo
#  elegível, uma matriz de expressão (genes x amostras, log2, símbolo oficial), com o mesmo
#  processamento para o mesmo tipo de dado e normalização dentro do estudo; controle de qualidade por
#  amostra (sexo genético, conectividade, biblioteca, células por doador) com o motivo de cada retirada.
#
#  Cada processador devolve list(ex, contagens, colunas, fonte, processamento, nota):
#    ex        : matriz log2 genes (símbolo) x colunas
#    contagens : contagens brutas (RNA-seq e pseudo-bulk) ou NULL, para o modelo da etapa 05
#    colunas   : data.frame(coluna, gsm, individuo) ligando cada coluna à amostra/doador
#
#  Entrada : output/02_metadados/{amostras.csv, amostras_longo.csv, elegibilidade.csv}, input/exclusoes.csv
#  Saída   : output/04_processamento/<GSE>/{expressao.rds, amostras_qc.csv}, output/04_processamento/inventario.csv
###############################################################################

# ---------------- download ----------------
baixar <- function(P, url, destino) {
  if (file.exists(destino) && file.size(destino) > 0) return(destino)
  pasta(dirname(destino)); op <- options(timeout = P$timeout_seg); on.exit(options(op))
  for (k in 1:3) {
    ok <- tryCatch(utils::download.file(url, destino, quiet = TRUE, mode = "wb") == 0, error = function(e) FALSE)
    if (ok && file.size(destino) > 0) return(destino)
    unlink(destino); Sys.sleep(3 * k)
  }
  stop("falha no download: ", url)
}
pasta_ftp <- function(acc, tipo = c("series", "samples")) {
  tipo <- match.arg(tipo)
  sprintf("https://ftp.ncbi.nlm.nih.gov/geo/%s/%snnn/%s/suppl/", tipo, sub("[0-9]{1,3}$", "", acc), acc)
}
# arquivo suplementar da série
arquivo_serie <- function(P, gse, nome) baixar(P, paste0(pasta_ftp(gse, "series"), nome), file.path(P$cache, gse, nome))
# arquivos suplementares de uma amostra (GSM) que casam com o padrão
arquivos_gsm <- function(P, gse, gsm, padrao) {
  Sys.sleep(P$pausa_seg)
  idx <- tryCatch(readLines(pasta_ftp(gsm, "samples"), warn = FALSE), error = function(e) character())
  nomes <- unique(regmatches(idx, regexpr(sprintf('(?<=href=")%s[^"/]*', gsm), idx, perl = TRUE)))
  nomes <- nomes[grepl(padrao, nomes, ignore.case = TRUE)]
  vapply(nomes, function(n) baixar(P, paste0(pasta_ftp(gsm, "samples"), n), file.path(P$cache, gse, "gsm", n)), "")
}

# ---------------- genes ----------------
# Uma linha por símbolo: sondas sem símbolo ou com mais de um gene saem; várias sondas -> maior média
colapsar_simbolo <- function(ex, simbolo) {
  ok <- !is.na(simbolo) & nzchar(simbolo) & !grepl(";|///| // |,", simbolo)
  ex <- ex[ok, , drop = FALSE]; simbolo <- simbolo[ok]
  o <- order(simbolo, -rowMeans(ex, na.rm = TRUE)); ex <- ex[o, , drop = FALSE]; simbolo <- simbolo[o]
  ex <- ex[!duplicated(simbolo), , drop = FALSE]; rownames(ex) <- simbolo[!duplicated(simbolo)]
  ex
}
# Símbolo de cada sonda pela anotação da plataforma, ligando pela coluna (ID, NAME, SPOT_ID) que mais coincide
simbolo_por_sonda <- function(tab, sondas) {
  cols <- intersect(c("ID", "NAME", "SPOT_ID", "ProbeName"), names(tab))
  k <- cols[which.max(vapply(cols, function(cl) sum(sondas %in% tab[[cl]]), 1))]
  simbolos_gpl(tab)[match(sondas, tab[[k]])]
}

# Ensembl (com ou sem versão) -> símbolo; símbolos já prontos passam direto
para_simbolo <- function(ids) {
  e <- sub("[.][0-9]+$", "", ids)
  if (mean(grepl("^ENSG", e)) < 0.5) return(ids)
  s <- suppressMessages(AnnotationDbi::mapIds(org.Hs.eg.db::org.Hs.eg.db, keys = unique(e), keytype = "ENSEMBL", column = "SYMBOL", multiVals = "first"))
  unname(s[e])
}
soma_por_simbolo <- function(cnt, simbolo) {
  ok <- !is.na(simbolo) & nzchar(simbolo); cnt <- cnt[ok, , drop = FALSE]
  r <- rowsum(cnt, simbolo[ok]); r
}

# Liga colunas de uma matriz suplementar às amostras (GSM): pelo próprio GSM, pelo título ou por um valor
# de característica igual ao nome da coluna
ligar_colunas <- function(cols, gse, a, longo) {
  x <- a[a$gse == gse, ]; l <- longo[longo$gse == gse & longo$campo == "carac", ]
  norm <- function(s) tolower(gsub("[^A-Za-z0-9]", "", s))
  gsm <- vapply(cols, function(cl) {
    if (cl %in% x$gsm) return(cl)
    k <- which(norm(x$titulo) == norm(cl)); if (length(k) == 1) return(x$gsm[k])
    k <- unique(l$gsm[norm(l$valor) == norm(cl)]); if (length(k) == 1) return(k)
    k <- which(startsWith(norm(x$titulo), norm(cl)) | startsWith(norm(cl), norm(x$titulo))); if (length(k) == 1) return(x$gsm[k])
    k <- which(endsWith(norm(x$titulo), norm(cl))); if (length(k) == 1) return(x$gsm[k])   # "visceral adipose tissue, vis_17" x "vis_17"
    NA_character_ }, "", USE.NAMES = FALSE)
  data.frame(coluna = cols, gsm = gsm, stringsAsFactors = FALSE)
}

# ---------------- processadores ----------------
proc_cel <- function(P, E, gse, gsms) {
  arqs <- unlist(lapply(gsms, function(g) { f <- arquivos_gsm(P, gse, g, "[.]cel([.]gz)?$"); if (length(f)) f[1] else NA_character_ }))
  names(arqs) <- gsms; arqs <- arqs[!is.na(arqs)]
  dat <- suppressMessages(suppressWarnings(oligo::read.celfiles(arqs, verbose = FALSE)))
  st <- inherits(dat, "GeneFeatureSet") || inherits(dat, "GeneExonFeatureSet")
  es <- if (st) oligo::rma(dat, target = "core") else oligo::rma(dat)
  ex <- Biobase::exprs(es); colnames(ex) <- names(arqs)
  pkg <- E$pacote_anotacao; suppressPackageStartupMessages(requireNamespace(pkg))
  simb <- suppressMessages(AnnotationDbi::mapIds(get(pkg, envir = asNamespace(pkg)), keys = rownames(ex), keytype = "PROBEID", column = "SYMBOL", multiVals = function(v) if (length(unique(v)) > 1) NA else v[1]))
  list(ex = colapsar_simbolo(ex, unname(simb[rownames(ex)])), contagens = NULL,
       colunas = data.frame(coluna = names(arqs), gsm = names(arqs)), fonte = sprintf("CEL de %d amostras (GEO, por GSM)", length(arqs)),
       processamento = sprintf("RMA (oligo%s); anotação %s", if (st) ", nível de gene" else "", pkg), nota = "")
}

proc_illumina_bruto <- function(P, E, gse, a, longo) {
  f <- arquivo_serie(P, gse, E$arquivo)
  l1 <- strsplit(readLines(gzfile(f), n = 1), intToUtf8(9))[[1]]                  # 1ª linha: GSM de cada amostra (quando existe)
  x <- utils::read.delim(gzfile(f), check.names = FALSE, stringsAsFactors = FALSE, skip = if (any(grepl("^GSM", l1))) 1 else 0)
  x <- x[, nzchar(names(x)) & !grepl("^V[0-9]+$|^[.][.][.]", names(x)) & colSums(!is.na(x)) > 0, drop = FALSE]
  scol <- grep("signal", names(x), ignore.case = TRUE); pcol <- grep("detection|pval", names(x), ignore.case = TRUE)
  if (!length(scol) && length(pcol)) scol <- pcol - 1L                   # formato "amostra | Detection Pval" (ex.: GSE250283, 09/10/2026)
  sinais <- as.matrix(x[, scol]); pv <- as.matrix(x[, pcol])
  nq <- limma::neqc(sinais, detection.p = pv)                            # matriz -> matriz log2
  gpl <- suppressMessages(GEOquery::getGEO(a$plataforma[a$gse == gse][1], destdir = pasta(P$cache, "gpl")))
  tab <- GEOquery::Table(gpl); simb <- simbolo_por_sonda(tab, x[[1]])
  ex <- nq
  gl <- l1[grepl("^GSM", l1)]
  colnames(ex) <- if (length(gl) == ncol(ex)) gl else names(x)[scol]
  lig <- ligar_colunas(colnames(ex), gse, a, longo)
  list(ex = colapsar_simbolo(ex, simb), contagens = NULL, colunas = lig, fonte = E$arquivo,
       processamento = "neqc (limma: normexp com sondas negativas pelo p de detecção, quantis, log2); anotação da plataforma", nota = "")
}

ler_tabela <- function(f) {
  if (grepl("[.]csv", f)) utils::read.csv(f, check.names = FALSE, stringsAsFactors = FALSE) else utils::read.delim(f, check.names = FALSE, stringsAsFactors = FALSE)
}
# separa coluna(s) de gene e colunas numéricas de amostras
matriz_de_tabela <- function(x) {
  num <- vapply(x, is.numeric, TRUE)
  if (!any(!num)) return(list(gene = rownames(x), m = as.matrix(x)))   # genes nos nomes das linhas
  gene <- x[[which(!num)[1]]]
  if (any(!num) && sum(!num) > 1) {                                     # várias colunas de texto: prefere a de símbolos
    cand <- which(!num); sc <- vapply(cand, function(k) mean(grepl("^[A-Z][A-Z0-9-]+$", x[[k]])), 1)
    gene <- x[[cand[which.max(sc)]]]
  }
  list(gene = gene, m = as.matrix(x[, num, drop = FALSE]))
}

proc_contagens <- function(P, E, gse, a, longo, normalizadas = FALSE) {
  f <- arquivo_serie(P, gse, E$arquivo); t <- matriz_de_tabela(ler_tabela(f))
  m <- t$m
  # escala "cpm" (09/10/2026): matriz do autor em proporções (ex.: GSE50244, TMM por comprimento ~0,006) -> CPM antes do log
  if (normalizadas && identical(E$escala, "cpm")) m <- sweep(m, 2, colSums(m, na.rm = TRUE), "/") * 1e6
  cnt <- soma_por_simbolo(if (normalizadas) m else round(m), para_simbolo(t$gene))
  lig <- ligar_colunas(colnames(cnt), gse, a, longo)
  if (normalizadas) return(list(ex = log2(cnt + 1), contagens = NULL, colunas = lig, fonte = E$arquivo,
                                processamento = "valores já normalizados pelo autor -> log2(x + 1); sem contagens brutas no GEO", nota = "matriz do autor"))
  list(ex = NULL, contagens = cnt, colunas = lig, fonte = E$arquivo, processamento = "contagens brutas -> filterByExpr, TMM, log2-CPM (edgeR)", nota = "")
}

# contagens -> log2-CPM com TMM, só nas colunas mantidas
log_cpm <- function(cnt, grupo = rep(1, ncol(cnt))) {
  d <- edgeR::DGEList(cnt); k <- edgeR::filterByExpr(d, group = grupo)
  d <- edgeR::calcNormFactors(d[k, , keep.lib.sizes = FALSE]); edgeR::cpm(d, log = TRUE)
}

proc_pseudobulk_csv <- function(P, E, gse, a, longo) {
  f <- arquivo_serie(P, gse, E$arquivo); t <- matriz_de_tabela(ler_tabela(f))
  cnt <- soma_por_simbolo(round(t$m), para_simbolo(t$gene))
  lig <- ligar_colunas(colnames(cnt), gse, a, longo)
  lig$individuo <- a$individuo[match(lig$gsm, a$gsm)]
  ok <- !is.na(lig$individuo)
  G <- Matrix::sparseMatrix(i = seq_len(sum(ok)), j = as.integer(factor(lig$individuo[ok])), x = 1)
  pb <- as.matrix(cnt[, ok] %*% G); colnames(pb) <- levels(factor(lig$individuo[ok]))
  ncel <- table(lig$individuo[ok])
  col <- data.frame(coluna = colnames(pb), gsm = vapply(colnames(pb), function(d) paste(lig$gsm[ok & lig$individuo == d], collapse = ";"), ""),
                    individuo = colnames(pb), n_celulas = as.integer(ncel[colnames(pb)]))
  list(ex = NULL, contagens = pb, colunas = col, fonte = E$arquivo,
       processamento = "pseudo-bulk: soma das contagens de todas as células de cada doador -> TMM, log2-CPM", nota = sprintf("%d células ligadas a %d doadores", sum(ok), ncol(pb)))
}

# h5ad (AnnData): soma das contagens brutas (raw/X, CSR células x genes) por doador, lida em blocos
h5_categoria <- function(f, campo) {
  g <- paste0("/obs/", campo); x <- rhdf5::h5ls(f, recursive = FALSE, datasetinfo = FALSE)
  cod <- rhdf5::h5read(f, paste0(g, "/codes")); cat <- rhdf5::h5read(f, paste0(g, "/categories"))
  as.character(cat[cod + 1])
}
proc_pseudobulk_h5ad <- function(P, E, gse) {
  f <- E$arquivo; base <- if ("raw" %in% rhdf5::h5ls(f, recursive = FALSE)$name) "/raw" else ""
  doador <- h5_categoria(f, "donor_id")
  obs <- data.frame(doador = doador, sexo = h5_categoria(f, "sex"), idade_txt = h5_categoria(f, "development_stage"), doenca = h5_categoria(f, "disease"))
  genes <- tryCatch(as.character(rhdf5::h5read(f, paste0(base, "/var/feature_name/categories"))[rhdf5::h5read(f, paste0(base, "/var/feature_name/codes")) + 1]),
                    error = function(e) as.character(rhdf5::h5read(f, paste0(base, "/var/_index"))))
  indptr <- as.numeric(rhdf5::h5read(f, paste0(base, "/X/indptr")))
  dd <- factor(doador); nd <- nlevels(dd); ng <- length(genes)
  pb <- matrix(0, ng, nd, dimnames = list(genes, levels(dd)))
  blocos <- split(seq_along(doador), ceiling(seq_along(doador) / 20000))
  for (b in blocos) {
    i0 <- indptr[min(b)] + 1; i1 <- indptr[max(b) + 1]
    idx <- rhdf5::h5read(f, paste0(base, "/X/indices"), index = list(i0:i1)); val <- rhdf5::h5read(f, paste0(base, "/X/data"), index = list(i0:i1))
    linha <- rep(b, diff(indptr[c(b, max(b) + 1)]))
    X <- Matrix::sparseMatrix(i = as.integer(idx) + 1, j = as.integer(dd[linha]), x = as.numeric(val), dims = c(ng, nd))
    pb <- pb + as.matrix(X)
  }
  rhdf5::h5closeAll()
  pb <- soma_por_simbolo(round(pb), genes)
  od <- obs[!duplicated(obs$doador), ]; od <- od[match(colnames(pb), od$doador), ]
  col <- data.frame(coluna = colnames(pb), gsm = NA_character_, individuo = paste0(gse, ":", colnames(pb)), n_celulas = as.integer(table(dd)[colnames(pb)]),
                    sexo_h5ad = ifelse(od$sexo == "female", "F", ifelse(od$sexo == "male", "M", NA)),
                    idade_h5ad = suppressWarnings(as.numeric(sub("-year-old.*", "", od$idade_txt))),
                    status_h5ad = ifelse(grepl("type 2 diabetes", od$doenca), "T2D", ifelse(od$doenca == "normal", "ND", NA)))
  list(ex = NULL, contagens = pb, colunas = col, fonte = basename(f),
       processamento = "pseudo-bulk: soma das contagens brutas de todas as células de cada doador (h5ad do CELLxGENE, que identifica o doador de cada célula) -> TMM, log2-CPM",
       nota = "os arquivos brutos do GEO juntam vários doadores por biblioteca; o h5ad traz o doador de cada célula")
}

proc_series_matrix <- function(P, E, gse) {
  es <- suppressMessages(GEOquery::getGEO(gse, GSEMatrix = TRUE, getGPL = TRUE, destdir = pasta(P$cache, gse)))[[1]]
  ex <- Biobase::exprs(es); ex <- ex[stats::complete.cases(ex), , drop = FALSE]
  if (max(ex, na.rm = TRUE) > 100) ex <- log2(pmax(ex, 1))
  ex <- limma::normalizeBetweenArrays(ex, method = "quantile")
  list(ex = colapsar_simbolo(ex, simbolos_gpl(Biobase::fData(es))), contagens = NULL, colunas = data.frame(coluna = colnames(ex), gsm = colnames(ex)),
       fonte = "series matrix do GEO (matriz do autor)", processamento = "log2 (se linear) + quantis; anotação da plataforma", nota = "matriz do autor")
}

proc_agilent_bruto <- function(P, E, gse, gsms, a) {
  arqs <- unlist(lapply(gsms, function(g) { f <- arquivos_gsm(P, gse, g, "[.]txt([.]gz)?$"); if (length(f)) f[1] else NA_character_ }))
  names(arqs) <- gsms; arqs <- arqs[!is.na(arqs)]
  rg <- limma::read.maimages(arqs, source = "agilent", green.only = TRUE, verbose = FALSE)
  bc <- limma::backgroundCorrect(rg, method = "normexp"); nm <- limma::normalizeBetweenArrays(bc, method = "quantile")
  ctrl <- if (!is.null(nm$genes$ControlType)) nm$genes$ControlType != 0 else rep(FALSE, nrow(nm))
  ex <- nm$E[!ctrl, , drop = FALSE]; colnames(ex) <- names(arqs)
  gpl <- suppressMessages(GEOquery::getGEO(a$plataforma[a$gse == gse][1], destdir = pasta(P$cache, "gpl"))); tab <- GEOquery::Table(gpl)
  simb <- simbolo_por_sonda(tab, nm$genes$ProbeName[!ctrl])
  list(ex = colapsar_simbolo(ex, simb), contagens = NULL, colunas = data.frame(coluna = names(arqs), gsm = names(arqs)),
       fonte = sprintf("arquivos Agilent de %d amostras (GEO, por GSM)", length(arqs)), processamento = "normexp + quantis (limma), log2; sondas de controle retiradas; anotação da plataforma", nota = "")
}

# NanoString RCC: contagens por gene; normalização por controles positivos (média geométrica) e genes de referência
ler_rcc <- function(f) {
  l <- readLines(f, warn = FALSE); i <- grep("<Code_Summary>", l) + 2; j <- grep("</Code_Summary>", l) - 1
  x <- utils::read.csv(text = l[i:j], header = FALSE, col.names = c("classe", "gene", "acesso", "contagem"), stringsAsFactors = FALSE); x
}
proc_nanostring <- function(P, E, gse, gsms) {
  arqs <- unlist(lapply(gsms, function(g) { f <- arquivos_gsm(P, gse, g, "[.]rcc([.]gz)?$"); if (length(f)) f[1] else NA_character_ }))
  names(arqs) <- gsms; arqs <- arqs[!is.na(arqs)]
  r <- lapply(arqs, ler_rcc); base <- r[[1]]
  m <- sapply(r, function(x) x$contagem[match(paste(base$classe, base$gene), paste(x$classe, x$gene))]); rownames(m) <- base$gene
  gm <- function(v) exp(mean(log(pmax(v, 1))))
  pos <- base$classe == "Positive"; hk <- base$classe == "Housekeeping"; end <- base$classe == "Endogenous"
  fp <- apply(m[pos, , drop = FALSE], 2, gm); fp <- mean(fp) / fp
  m1 <- sweep(m, 2, fp, "*"); fh <- apply(m1[hk, , drop = FALSE], 2, gm); fh <- mean(fh) / fh
  ex <- log2(pmax(sweep(m1[end, , drop = FALSE], 2, fh, "*"), 1))
  list(ex = ex, contagens = NULL, colunas = data.frame(coluna = names(arqs), gsm = names(arqs)), fonte = sprintf("RCC de %d amostras (GEO, por GSM)", length(arqs)),
       processamento = sprintf("controles positivos + %d genes de referência (médias geométricas), log2; %d genes endógenos do painel", sum(hk), sum(end)), nota = "painel dirigido (D4)")
}

# ---------------- lote de processamento (data de leitura do array) ----------------
# Decisão do usuário (07/10/2026, etapa 05): o GSE189005 tinha controles lidos em 2016-2018 e DM2 em 2018,
# confundindo lote e grupo. A data de leitura fica registrada por amostra e a confusão é medida por estudo.
data_leitura <- function(P, gse, tipo, gsm) {
  dir <- file.path(P$cache, gse, "gsm"); if (!dir.exists(dir)) return(rep(NA_character_, length(gsm)))
  f <- list.files(dir, full.names = TRUE); g0 <- regmatches(basename(f), regexpr("^GSM[0-9]+", basename(f)))
  le <- function(x) tryCatch({
    if (grepl("[.]cel", x, ignore.case = TRUE)) substr(affyio::read.celfile.header(x, info = "full")$ScanDate, 1, 10)
    else if (tipo == "agilent_bruto") { l <- readLines(gzfile(x), n = 3); tab <- intToUtf8(9); v <- strsplit(l[3], tab)[[1]]; h <- strsplit(l[2], tab)[[1]]
      d <- v[match("Scan_Date", h)]; format(as.Date(substr(d, 1, 10), "%m-%d-%Y")) }
    else NA_character_ }, error = function(e) NA_character_)
  vapply(gsm, function(g) { k <- which(g0 == g); if (length(k)) { r <- le(f[k[1]]); if (length(r) && nzchar(r)) r else NA_character_ } else NA_character_ }, "", USE.NAMES = FALSE)
}
# confusão lote x grupo (DM2/ND): V de Cramér e fração das amostras em lotes que têm os dois grupos
confusao_lote <- function(lote, status) {
  ok <- !is.na(lote) & status %in% c("T2D", "ND")
  if (sum(ok) < 4 || length(unique(lote[ok])) < 2) return(c(v_cramer = NA_real_, frac_mista = if (sum(ok) >= 4) 1 else NA_real_, lotes = length(unique(lote[ok]))))
  t <- table(lote[ok], status[ok]); mista <- rowSums(t > 0) == 2
  v <- sqrt(suppressWarnings(stats::chisq.test(t, correct = FALSE)$statistic) / sum(t))
  c(v_cramer = unname(v), frac_mista = sum(t[mista, ]) / sum(t), lotes = nrow(t))
}

# ---------------- controle de qualidade ----------------
conectividade_z <- function(ex, n_genes) {
  v <- apply(ex, 1, stats::var); top <- ex[order(v, decreasing = TRUE)[seq_len(min(n_genes, nrow(ex)))], ]
  A <- ((1 + stats::cor(top)) / 2)^2                                     # adjacência com sinal (Oldham et al. 2012)
  k <- colSums(A) - 1; as.numeric(scale(k))
}

qc_estudo <- function(P, S, r, am) {
  Q <- P$qc; ex <- r$ex; ex_sexo <- r$ex_sexo %||% ex
  am$sexo_genetico <- NA_character_; am$sexo_discordante <- FALSE; am$conectividade_z <- NA_real_
  # sexo genético (método validado na etapa 03)
  sg <- tryCatch({ s <- ler_sexo(S, ex_sexo, rownames(ex_sexo)); decidir_sexo(S, s) }, error = function(e) NULL)
  nota_sexo <- if (is.null(sg)) "sexo genético não avaliado" else sg$decisao
  if (!is.null(sg)) am$sexo_genetico <- sg$amostras$sexo_genetico[match(am$coluna, sg$amostras$gsm)]
  aval <- !is.na(am$sexo_genetico) & !is.na(am$sexo)
  am$sexo_discordante <- aval & am$sexo_genetico != am$sexo
  frac_disc <- if (any(aval)) mean(am$sexo_discordante[aval]) else NA_real_
  # biblioteca e células
  am$biblioteca <- if (!is.null(r$contagens)) colSums(r$contagens)[am$coluna] else NA_real_
  am$baixa_biblioteca <- !is.na(am$biblioteca) & am$biblioteca < Q$biblioteca_min
  nc <- if ("n_celulas" %in% names(am)) am$n_celulas else rep(NA_real_, nrow(am))
  am$poucas_celulas <- !is.na(nc) & nc < Q$celulas_min_por_doador
  # conectividade (sem as já retiradas)
  base <- !am$sexo_discordante & !am$baixa_biblioteca & !am$poucas_celulas
  if (sum(base) >= Q$min_amostras_conectividade) am$conectividade_z[base] <- conectividade_z(ex[, am$coluna[base], drop = FALSE], Q$genes_conectividade)
  am$discrepante <- !is.na(am$conectividade_z) & am$conectividade_z < Q$conectividade_z_min
  am$motivo_retirada <- dplyr::case_when(am$sexo_discordante ~ "sexo genético discordante do declarado", am$baixa_biblioteca ~ "biblioteca pequena",
                                         am$poucas_celulas ~ "poucas células no doador", am$discrepante ~ "amostra discrepante (conectividade)", TRUE ~ "")
  am$mantida <- am$motivo_retirada == ""
  list(amostras = am, nota_sexo = nota_sexo, frac_disc = frac_disc,
       so_sensibilidade = !is.na(frac_disc) && frac_disc > Q$sexo_discordancia_max)
}

# PCA de um estudo (para a figura)
pca_estudo <- function(ex, n = 5000) {
  v <- apply(ex, 1, stats::var); top <- ex[order(v, decreasing = TRUE)[seq_len(min(n, nrow(ex)))], ]
  p <- stats::prcomp(t(top), scale. = FALSE); ve <- p$sdev^2 / sum(p$sdev^2)
  list(x = p$x[, 1:2, drop = FALSE], ve = ve[1:2])
}

# ---------------- um estudo, do download ao controle de qualidade ----------------
processar_estudo <- function(P, S, gse, a, longo) {
  E <- P$estudos[[gse]]; aa <- a[a$gse == gse & a$apta, ]
  r <- switch(E$tipo,
    cel = proc_cel(P, E, gse, aa$gsm),
    illumina_bruto = proc_illumina_bruto(P, E, gse, a, longo),
    contagens = proc_contagens(P, E, gse, a, longo),
    contagens_norm = proc_contagens(P, E, gse, a, longo, normalizadas = TRUE),
    pseudobulk_csv = proc_pseudobulk_csv(P, E, gse, a, longo),
    pseudobulk_h5ad = proc_pseudobulk_h5ad(P, E, gse),
    series_matrix = proc_series_matrix(P, E, gse),
    agilent_bruto = proc_agilent_bruto(P, E, gse, aa$gsm, a),
    nanostring = proc_nanostring(P, E, gse, aa$gsm),
    stop("tipo desconhecido: ", E$tipo))
  col <- r$colunas
  # colunas com nome só numérico (ex.: GSE50244, títulos "1".."89"): viram o GSM, senão o CSV relido as trata como
  # números e a indexação ex[, coluna] passa a ser por POSIÇÃO (correção de 09/10/2026)
  if (all(grepl("^[0-9]+$", col$coluna)) && "gsm" %in% names(col) && !anyNA(col$gsm)) {
    if (!is.null(r$ex)) colnames(r$ex) <- col$gsm[match(colnames(r$ex), col$coluna)]
    if (!is.null(r$contagens)) colnames(r$contagens) <- col$gsm[match(colnames(r$contagens), col$coluna)]
    col$coluna <- col$gsm
  }
  # tabela de amostras (D1: todas as aptas do estudo)
  if (E$tipo == "pseudobulk_h5ad") {
    E2 <- ler_config("config/metadados.yaml")$elegibilidade
    am <- data.frame(coluna = col$coluna, gsm = NA_character_, individuo = col$individuo, n_celulas = col$n_celulas, sexo = col$sexo_h5ad,
                     idade = col$idade_h5ad, status = col$status_h5ad, tecido = a$tecido[a$gse == gse & a$apta][1], apta = col$status_h5ad %in% c("ND", "T2D"))
    am$mulher_40a60 <- am$sexo %in% "F" & !is.na(am$idade) & am$idade >= E2$janela_idade[1] & am$idade < E2$janela_idade[2] + 1
    am <- am[am$apta, ]
  } else if (E$tipo == "pseudobulk_csv") {
    am <- data.frame(coluna = col$coluna, gsm = col$gsm, individuo = col$individuo, n_celulas = col$n_celulas)
    pri <- function(campo) aa[[campo]][match(am$individuo, aa$individuo)]
    am$sexo <- pri("sexo"); am$idade <- pri("idade"); am$status <- pri("status"); am$tecido <- pri("tecido"); am$mulher_40a60 <- pri("mulher_40a60")
    am <- am[am$individuo %in% aa$individuo, ]
  } else {
    am <- col[!is.na(col$gsm) & col$gsm %in% aa$gsm, c("coluna", "gsm")]
    k <- match(am$gsm, aa$gsm)
    am$individuo <- aa$individuo[k]; am$sexo <- aa$sexo[k]; am$idade <- aa$idade[k]; am$status <- aa$status[k]; am$tecido <- aa$tecido[k]; am$mulher_40a60 <- aa$mulher_40a60[k]
  }
  sem_ligacao <- if (E$tipo %in% c("pseudobulk_h5ad")) 0L else sum(!aa$gsm %in% unlist(strsplit(stats::na.omit(col$gsm), ";")))
  # expressão das colunas mantidas
  if (!is.null(r$contagens)) {
    r$contagens <- r$contagens[, am$coluna, drop = FALSE]; r$ex <- log_cpm(r$contagens, am$status)
    # sexo genético sem o filtro de expressão (XIST e genes Y são expressos só em parte das amostras)
    r$ex_sexo <- edgeR::cpm(edgeR::calcNormFactors(edgeR::DGEList(r$contagens)), log = TRUE)
  }
  r$ex <- r$ex[, am$coluna, drop = FALSE]
  q <- qc_estudo(P, S, r, am)
  q$amostras$lote <- if (E$tipo %in% c("cel", "agilent_bruto")) data_leitura(P, gse, E$tipo, q$amostras$gsm) else NA_character_
  list(r = r, am = q$amostras, nota_sexo = q$nota_sexo, frac_disc = q$frac_disc, so_sensibilidade = q$so_sensibilidade, sem_ligacao = sem_ligacao, tipo = E$tipo, uso = E$uso %||% "genoma inteiro")
}

# Grava e resume um estudo
salvar_estudo <- function(gse, x) {
  d <- pasta("output", "04_processamento", gse)
  # réplicas técnicas (mesmo doador em várias colunas, ex.: GSE29226): média por doador entre as mantidas
  m0 <- x$am[x$am$mantida, ]; rep <- any(duplicated(m0$individuo))
  ex_doador <- if (rep) limma::avearrays(x$r$ex[, m0$coluna, drop = FALSE], ID = m0$individuo) else NULL
  saveRDS(list(expressao = x$r$ex, contagens = x$r$contagens, expressao_por_doador = ex_doador), file.path(d, "expressao.rds"))
  escrever_csv(x$am, file.path(d, "amostras_qc.csv"))
  m <- x$am[x$am$mantida, ]
  doad <- function(f) length(unique(m$individuo[f]))
  cl <- if ("lote" %in% names(m)) confusao_lote(m$lote, m$status) else c(v_cramer = NA, frac_mista = NA, lotes = NA)
  data.frame(gse = gse, tecido = x$am$tecido[1], tipo = x$tipo, uso = x$uso, fonte = x$r$fonte, processamento = x$r$processamento, nota = x$r$nota,
             genes = nrow(x$r$ex), amostras = nrow(x$am), sem_ligacao = x$sem_ligacao, mantidas = nrow(m),
             sexo_discordantes = sum(x$am$sexo_discordante), frac_discordancia = round(x$frac_disc, 3), discrepantes = sum(x$am$discrepante),
             outras_retiradas = sum(x$am$motivo_retirada %in% c("biblioteca pequena", "poucas células no doador")),
             sexo_genetico = x$nota_sexo, so_sensibilidade = x$so_sensibilidade,
             doadores = length(unique(m$individuo)), replicas_tecnicas = if (rep) "média por doador (expressao_por_doador)" else "",
             lotes = cl[["lotes"]], lote_v_cramer = round(cl[["v_cramer"]], 2), lote_frac_mista = round(cl[["frac_mista"]], 2),
             F40a60_T2D = doad(m$mulher_40a60 %in% TRUE & m$status == "T2D"), F40a60_ND = doad(m$mulher_40a60 %in% TRUE & m$status == "ND"),
             stringsAsFactors = FALSE)
}
