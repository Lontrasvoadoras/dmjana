# Por estudo não elegível: mulheres de 40-60 aptas SEM status DM2/ND, e quantas delas têm HbA1c / glicemia / tratamento
setwd("C:/Users/ihope/OneDrive/Área de Trabalho/DM jana/workflow_dm_menopausa")
le <- function(f) utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8", na.strings = c("NA", ""))
el <- le("output/02_metadados/elegibilidade.csv"); am <- le("output/02_metadados/amostras.csv"); lo <- le("output/02_metadados/amostras_longo.csv")
nao <- el[el$categoria != "elegivel", ]
lo <- lo[lo$gse %in% nao$gse & lo$campo == "carac", ]; k <- tolower(lo$chave)
num <- suppressWarnings(as.numeric(sub(",", ".", sub("^[^0-9.-]*([0-9.,]+).*", "\\1", lo$valor))))
hb <- lo[grepl("hba1c|a1c|hb1ac|glycated|glycosylated", k) & !is.na(num), ]; hb$v <- num[grepl("hba1c|a1c|hb1ac|glycated|glycosylated", k) & !is.na(num)]
gl <- lo[grepl("glucose|glycemia|glycaemia|fpg|fbg", k) & !grepl("ogtt|2h|2-h|120", k) & !is.na(num), ]; gl$v <- num[grepl("glucose|glycemia|glycaemia|fpg|fbg", k) & !grepl("ogtt|2h|2-h|120", k) & !is.na(num)]
tr <- lo[grepl("metformin|sulfonyl|insulin treat|antidiabet|diabetes medic|medication|treatment|drug", k), ]
a <- am[am$gse %in% nao$gse & am$humano %in% TRUE & am$ensaio_expressao %in% TRUE & !am$cultivado %in% TRUE & am$basal %in% TRUE & !is.na(am$tecido), ]   # SEM exigir status
a$hba1c <- hb$v[match(a$gsm, hb$gsm)]; a$glic <- gl$v[match(a$gsm, gl$gsm)]; a$trat <- tr$valor[match(a$gsm, tr$gsm)]
a$hb_ch <- hb$chave[match(a$gsm, hb$gsm)]; a$gl_ch <- gl$chave[match(a$gsm, gl$gsm)]
# HbA1c em mmol/mol (> 20) -> %; glicemia em mg/dL (> 30) -> mmol/L
a$hb_pct <- ifelse(!is.na(a$hba1c) & a$hba1c > 20, a$hba1c / 10.929 + 2.15, a$hba1c)
a$gl_mmol <- ifelse(!is.na(a$glic) & a$glic > 30, a$glic / 18, a$glic)
a$ada <- ifelse((!is.na(a$hb_pct) & a$hb_pct >= 6.5) | (!is.na(a$gl_mmol) & a$gl_mmol >= 7), "T2D",
         ifelse((is.na(a$hb_pct) | a$hb_pct < 5.7) & (is.na(a$gl_mmol) | a$gl_mmol < 5.6) & (!is.na(a$hb_pct) | !is.na(a$gl_mmol)), "ND",
         ifelse(!is.na(a$hb_pct) | !is.na(a$gl_mmol), "intermediario", NA)))
w <- a[a$mulher_40a60 %in% TRUE, ]
res <- do.call(rbind, lapply(split(w, w$gse), function(d) data.frame(gse = d$gse[1], categoria = nao$categoria[nao$gse == d$gse[1]][1], tecido = paste(unique(d$tecido), collapse = "/"), F40a60 = nrow(d),
  F_T2D = sum(d$status %in% "T2D"), F_ND = sum(d$status %in% "ND"), F_outro_status = sum(!d$status %in% c("T2D", "ND")), status_outros = paste(utils::head(unique(d$status_texto[!d$status %in% c("T2D", "ND")]), 3), collapse = " | "),
  com_hba1c = sum(!is.na(d$hba1c)), com_glic = sum(!is.na(d$glic)), com_trat = sum(!is.na(d$trat)),
  ada_T2D = sum(d$ada %in% "T2D"), ada_ND = sum(d$ada %in% "ND"), ada_inter = sum(d$ada %in% "intermediario"),
  sem_status_resgataveis_T2D = sum(!d$status %in% c("T2D", "ND") & d$ada %in% "T2D"), sem_status_resgataveis_ND = sum(!d$status %in% c("T2D", "ND") & d$ada %in% "ND"),
  indiv = length(unique(d$individuo)))))
res <- res[order(-(res$com_hba1c + res$com_glic), -res$F40a60), ]
options(width = 260); print(res, row.names = FALSE)
utils::write.csv(res, "output/02_metadados/varredura_clinica_mulheres_40a60.csv", row.names = FALSE, fileEncoding = "UTF-8")
# estudos com HbA1c/glicemia mas sem sexo ou sem idade (resgate exigiria sexo genético ou idade do artigo)
x <- a[(!is.na(a$hba1c) | !is.na(a$glic)), ]
s2 <- do.call(rbind, lapply(split(x, x$gse), function(d) data.frame(gse = d$gse[1], categoria = nao$categoria[nao$gse == d$gse[1]][1], tecido = d$tecido[1], com_valor = nrow(d), indiv = length(unique(d$individuo)),
  sem_sexo = sum(is.na(d$sexo)), F = sum(d$sexo %in% "F"), sem_idade = sum(is.na(d$idade)), F_sem_idade = sum(d$sexo %in% "F" & is.na(d$idade)),
  ada_T2D = sum(d$ada %in% "T2D"), ada_ND = sum(d$ada %in% "ND"), chave = paste(unique(c(d$hb_ch, d$gl_ch)), collapse = "; "))))
cat("\n--- todos os estudos não elegíveis com HbA1c ou glicemia (qualquer sexo/idade) ---\n"); print(s2[order(-s2$com_valor), ], row.names = FALSE)
