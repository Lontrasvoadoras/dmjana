# Varredura: estudos não elegíveis com campos clínicos que permitam deduzir o status DM2/ND (pergunta do usuário, 11/10/2026)
setwd("C:/Users/ihope/OneDrive/Área de Trabalho/DM jana/workflow_dm_menopausa")
le <- function(f) utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8", na.strings = c("NA", ""))
el <- le("output/02_metadados/elegibilidade.csv"); am <- le("output/02_metadados/amostras.csv"); lo <- le("output/02_metadados/amostras_longo.csv")
nao <- el[el$categoria != "elegivel", ]
lo <- lo[lo$gse %in% nao$gse & lo$campo == "carac", ]
k <- tolower(lo$chave); v <- tolower(lo$valor)
pad <- list(
  hba1c   = "hba1c|a1c|hb1ac|glycated|glycosylated|haemoglobin a|hemoglobin a",
  glicemia = "glucose|glycemia|glycaemia|fpg|fbg|fasting.*(gluc|sugar)|blood sugar",
  totg    = "ogtt|2h|2-h|120 ?min|oral glucose",
  insulina = "insulin|homa|matsuda|clamp|m-value|gir",
  tratamento = "metformin|sulfonyl|glibencl|gliclaz|glipiz|glimepir|insulin treat|antidiabet|hypoglyc|diabetes medic|dm medic|oad|sglt|dpp|glp-?1|pioglit|treatment|medication|drug",
  diabetes_outro = "diabet|t2d|t2dm|dm2|niddm|glucose tolerance|igt|ifg|prediab|dysglyc|glycemic status|glucose status")
mk <- sapply(pad, function(p) grepl(p, k) | (grepl(p, v) & !grepl("^(treatment|agent|protocol|time|stimul)", k)))
lo$tipo <- apply(mk, 1, function(z) paste(names(pad)[z], collapse = "+"))
x <- lo[nzchar(lo$tipo), ]
# por estudo: chaves encontradas, amostras com o campo, mulheres 40-60 (declaradas) e amostras com sexo/idade
res <- do.call(rbind, lapply(split(x, x$gse), function(d) {
  a <- am[am$gse == d$gse[1], ]; ap <- a[a$apta %in% TRUE, ]
  ch <- unique(d$chave); exem <- vapply(ch, function(c) paste(utils::head(unique(d$valor[d$chave == c]), 3), collapse = " | "), "")
  data.frame(gse = d$gse[1], categoria = nao$categoria[nao$gse == d$gse[1]], tecido = nao$tecido[nao$gse == d$gse[1]], n_aptas = nrow(ap),
             com_campo = length(unique(d$gsm[d$gsm %in% ap$gsm])), tipos = paste(sort(unique(unlist(strsplit(d$tipo, "\\+")))), collapse = ","),
             F40a60 = sum(ap$mulher_40a60 %in% TRUE), com_sexo = sum(!is.na(ap$sexo)), com_idade = sum(!is.na(ap$idade)),
             chaves = paste(sprintf("%s [%s]", ch, substr(exem, 1, 60)), collapse = " ;; "), titulo = substr(nao$titulo[nao$gse == d$gse[1]], 1, 70))
}))
res <- res[order(-(res$F40a60 > 0), -res$F40a60, -res$com_campo), ]
utils::write.csv(res, "output/02_metadados/varredura_clinica_estudos.csv", row.names = FALSE, fileEncoding = "UTF-8")
cat("estudos não elegíveis:", nrow(nao), "; com algum campo clínico:", nrow(res), "\n")
print(table(res$categoria))
options(width = 250)
print(res[res$com_campo > 0, c("gse", "categoria", "tecido", "n_aptas", "com_campo", "tipos", "F40a60", "com_sexo", "com_idade")], row.names = FALSE)
