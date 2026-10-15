# Reavaliação dos doadores "repetidos" GSE50244 x GSE41762 (pedido do usuário, 12/10/2026)
# 1) metadados: candidatos por doador (sexo, idade +-1, IMC +-0,6), pareamento 1:1, concordância da HbA1c e
#    taxa de coincidência ao acaso (doadores do GSE41762 embaralhados entre si)
setwd("C:/Users/ihope/OneDrive/Área de Trabalho/DM jana/workflow_dm_menopausa")
le <- function(f) utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8", na.strings = c("NA", ""))
lo <- le("output/02_metadados/amostras_longo.csv"); am <- le("output/02_metadados/amostras.csv")
val <- function(g, ch) { x <- lo[lo$gse == g & lo$campo == "carac" & tolower(lo$chave) == ch, ]; stats::setNames(suppressWarnings(as.numeric(x$valor)), x$gsm) }
tab <- function(g) { a <- am[am$gse == g, c("gsm", "idade", "sexo", "status")]; a$bmi <- val(g, "bmi")[a$gsm]; a$hba1c <- val(g, "hba1c")[a$gsm]; a }
A <- tab("GSE50244"); B <- tab("GSE41762")
cand <- function(A, B) lapply(seq_len(nrow(A)), function(i) which(B$sexo == A$sexo[i] & abs(B$idade - A$idade[i]) <= 1 & abs(B$bmi - A$bmi[i]) <= 0.6))
cc <- cand(A, B); nc <- lengths(cc)
cat("GSE50244:", nrow(A), "doadores; GSE41762:", nrow(B), "\n")
cat("com >= 1 candidato (critério atual):", sum(nc > 0), "; com 1 candidato:", sum(nc == 1), "; com 2+:", sum(nc > 1), "\n")
# critério estrito: idade e IMC exatos (arredondados a 0,1), mesmo sexo
estr <- vapply(seq_len(nrow(A)), function(i) sum(B$sexo == A$sexo[i] & abs(B$idade - A$idade[i]) < 0.5 & abs(B$bmi - A$bmi[i]) < 0.05, na.rm = TRUE), 0)
cat("idade e IMC idênticos:", sum(estr > 0), "\n")
# HbA1c nos pares candidatos
d <- do.call(rbind, lapply(seq_len(nrow(A)), function(i) if (length(cc[[i]])) data.frame(gsm_50244 = A$gsm[i], gsm_41762 = B$gsm[cc[[i]]], n_cand = length(cc[[i]]),
  idade_a = A$idade[i], idade_b = B$idade[cc[[i]]], bmi_a = A$bmi[i], bmi_b = B$bmi[cc[[i]]], hba1c_a = A$hba1c[i], hba1c_b = B$hba1c[cc[[i]]])))
d$hba1c_dif <- abs(d$hba1c_a - d$hba1c_b)
cat("pares candidatos:", nrow(d), "; com HbA1c nos dois:", sum(!is.na(d$hba1c_dif)), "; HbA1c igual (dif <= 0,1):", sum(d$hba1c_dif <= 0.1, na.rm = TRUE), "; dif > 0,3:", sum(d$hba1c_dif > 0.3, na.rm = TRUE), "\n")
# acaso: deslocar a idade do GSE41762 em +-5 a 10 anos (quebra as pessoas, mantém as distribuições)
set.seed(1); acaso <- replicate(200, { Bp <- B; Bp$idade <- Bp$idade + sample(c(-10:-5, 5:10), nrow(Bp), TRUE); sum(lengths(cand(A, Bp)) > 0) })
cat("acaso (idade deslocada): mediana", stats::median(acaso), "doadores com candidato (p95", stats::quantile(acaso, 0.95), ")\n")
utils::write.csv(d, "output/02_metadados/reavaliacao_GSE50244_pares.csv", row.names = FALSE, fileEncoding = "UTF-8")
