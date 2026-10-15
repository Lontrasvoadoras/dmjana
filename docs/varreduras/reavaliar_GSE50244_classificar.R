# Classificação final (12/10/2026): GSE50397 (array) -> GSE50244 (RNA-seq, mesmos doadores) e repetição no GSE41762
setwd("C:/Users/ihope/OneDrive/Área de Trabalho/DM jana/workflow_dm_menopausa")
dd <- commandArgs(TRUE)[1]
meta <- function(g) {
  L <- readLines(gzfile(file.path(dd, paste0(g, "_series_matrix.txt.gz"))))
  gsm <- gsub('"', "", strsplit(L[grepl("^!Sample_geo_accession", L)], "\t")[[1]][-1])
  ch <- L[grepl("^!Sample_characteristics_ch1", L)]; out <- data.frame(gsm = gsm, stringsAsFactors = FALSE)
  for (z in ch) { v <- gsub('"', "", strsplit(z, "\t")[[1]][-1]); for (j in seq_along(v)) if (grepl(":", v[j])) { k <- tolower(trimws(sub(":.*", "", v[j]))); if (!k %in% names(out)) out[[k]] <- NA; out[[k]][j] <- trimws(sub("^[^:]*:", "", v[j])) } }
  out }
m97 <- meta("GSE50397"); m41 <- meta("GSE41762")
ex <- utils::read.csv("output/02_metadados/reavaliacao_GSE50244_expressao.csv", stringsAsFactors = FALSE)[, 1:5]
lo <- utils::read.csv("output/02_metadados/amostras_longo.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
x <- lo[lo$gse == "GSE50244" & lo$campo == "carac", ]; m44 <- stats::reshape(x[, c("gsm", "chave", "valor")], idvar = "gsm", timevar = "chave", direction = "wide"); names(m44) <- sub("^valor\\.", "", tolower(names(m44)))
num <- function(z) suppressWarnings(as.numeric(z))
# GSE50397 -> GSE50244: sexo, ano de nascimento, idade, IMC e HbA1c iguais
k97 <- with(m97, paste(tolower(substr(gender, 1, 1)), `year of birth`, age, num(bmi), num(hba1c)))
k44 <- with(m44, paste(tolower(substr(gender, 1, 1)), `year of birth`, age, num(bmi), num(hba1c)))
ex$gsm_50244 <- m44$gsm[match(k97[match(ex$gsm_50397, m97$gsm)], k44)]
cat("GSE50397 ligados ao GSE50244 por metadados idênticos:", sum(!is.na(ex$gsm_50244)), "de", nrow(ex), "; ligações repetidas:", sum(duplicated(stats::na.omit(ex$gsm_50244))), "\n")
# classe: repetido = r >= 0,8 e >= 0,2 acima do 2º melhor, par 1:1; novo = r < 0,5; intermediário = resto
ex$margem <- ex$r_melhor - ex$r_segundo
ex$classe <- ifelse(ex$r_melhor >= 0.8 & ex$margem >= 0.2, "repetido (expressão)", ifelse(ex$r_melhor < 0.5, "novo (expressão)", "intermediário"))
dupb <- ex$melhor_41762[ex$classe == "repetido (expressão)"]; cat("pares repetidos 1:1?", !any(duplicated(dupb)), "\n")
# metadados do par no GSE41762
ex$sexo_41762 <- m41$sex[match(ex$melhor_41762, m41$gsm)]; ex$idade_41762 <- num(m41$age[match(ex$melhor_41762, m41$gsm)]); ex$bmi_41762 <- num(m41$bmi[match(ex$melhor_41762, m41$gsm)]); ex$hba1c_41762 <- num(m41$hba1c[match(ex$melhor_41762, m41$gsm)])
i <- match(ex$gsm_50397, m97$gsm); ex$sexo <- m97$gender[i]; ex$idade <- num(m97$age[i]); ex$bmi <- num(m97$bmi[i]); ex$hba1c <- num(m97$hba1c[i])
ex$meta_bate <- tolower(substr(ex$sexo, 1, 1)) == tolower(substr(ex$sexo_41762, 1, 1)) & abs(ex$idade - ex$idade_41762) <= 1 & abs(ex$bmi - ex$bmi_41762) <= 0.6
print(table(ex$classe, metadados_batem = ex$meta_bate, useNA = "ifany"))
cat("\nintermediários:\n"); options(width = 250); print(ex[ex$classe == "intermediário", c("gsm_50397", "gsm_50244", "melhor_41762", "r_melhor", "r_segundo", "sexo", "sexo_41762", "idade", "idade_41762", "bmi", "bmi_41762", "hba1c", "hba1c_41762")], row.names = FALSE)
# comparação com a exclusão atual (curadoria)
cu <- utils::read.csv("input/curadoria.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8"); cu <- cu[cu$gse == "GSE50244" & cu$campo == "status", ]
ex$excluido_hoje <- ex$gsm_50244 %in% cu$amostra[cu$valor == "EXCLUIR"]
cat("\nexclusão atual x classe por expressão:\n"); print(table(ex$classe, excluido_hoje = ex$excluido_hoje))
# mulheres de 40-60 e status ADA entre os não repetidos
am <- utils::read.csv("output/02_metadados/amostras.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
ex$idade44 <- num(m44$age[match(ex$gsm_50244, m44$gsm)]); ex$sexo44 <- m44$gender[match(ex$gsm_50244, m44$gsm)]; ex$hba1c44 <- num(m44$hba1c[match(ex$gsm_50244, m44$gsm)])
ex$ada <- ifelse(ex$hba1c44 >= 6.5, "T2D", ifelse(ex$hba1c44 < 5.7, "ND", "intermediário"))
w <- ex[tolower(ex$sexo44) == "female" & ex$idade44 >= 40 & ex$idade44 <= 60, ]
cat("\nmulheres de 40-60 no GSE50244:", nrow(w), "\n"); print(table(w$classe, w$ada, useNA = "ifany"))
utils::write.csv(ex, "output/02_metadados/reavaliacao_GSE50244_classes.csv", row.names = FALSE, fileEncoding = "UTF-8")
