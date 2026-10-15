###############################################################################
#  input/gerar_curadoria_resgate.R - curadoria dos estudos resgatados entre os "sem status" (decisão do usuário, 09/10/2026)
#  Gera as linhas de input/curadoria.csv (status por amostra, com motivo) e de input/exclusoes.csv.
#  Critérios (ADA): DM2 = HbA1c >= 6,5% ou glicemia de jejum >= 7,0 mmol/L; sem diabetes = HbA1c < 5,7% e (se houver)
#  glicemia < 5,6 mmol/L; entre esses limites = pré-diabetes (INTERMEDIARIO, fora da análise).
#  Uso (uma vez, a partir de workflow_dm_menopausa): Rscript --encoding=UTF-8 input/gerar_curadoria_resgate.R
###############################################################################
l <- utils::read.csv("output/02_metadados/amostras_longo.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
a <- utils::read.csv("output/02_metadados/amostras.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
val <- function(g, k) { x <- l[l$gse == g & l$campo == "carac" & tolower(l$chave) == k, ]; stats::setNames(suppressWarnings(as.numeric(x$valor)), x$gsm) }
ada <- function(h, gl = NULL) { gl <- if (is.null(gl)) rep(NA_real_, length(h)) else gl
  ifelse((!is.na(h) & h >= 6.5) | (!is.na(gl) & gl >= 7.0), "T2D",
         ifelse(!is.na(h) & h < 5.7 & (is.na(gl) | gl < 5.6), "ND", ifelse(is.na(h) & is.na(gl), NA, "INTERMEDIARIO"))) }
linhas <- list()
add <- function(gse, gsm, campo, valor, motivo) linhas[[length(linhas) + 1]] <<- data.frame(gse = unname(gse), gsm = unname(gsm), campo = campo, valor = unname(valor), motivo = motivo, row.names = NULL)

# GSE130991 (fígado): HbA1c e glicemia de jejum por amostra; estatina = medicação crônica, não intervenção do estudo
g <- "GSE130991"; x <- a[a$gse == g, ]
st <- ada(val(g, "hba1c (%)")[x$gsm], val(g, "fasting blood glucose (mmol/l)")[x$gsm])
# em tratamento para diabetes = DM2, qualquer que seja a HbA1c (ADA; correção de 09/10/2026: 18 mulheres de 40-60 tratadas,
# com HbA1c controlada < 6,5%, tinham ficado como pré-diabetes)
tr <- l[l$gse == g & l$campo == "carac" & l$chave == "diabetes treatment", ]; tratado <- x$gsm %in% tr$gsm[tolower(tr$valor) == "yes"]
mot <- ifelse(tratado & st != "T2D", "Em tratamento para diabetes ('diabetes treatment: Yes'): DM2 mesmo com HbA1c/glicemia controladas (ADA; correção de 09/10/2026)",
              "Status pelos exames da amostra (ADA: HbA1c e glicemia de jejum); resgate dos 'sem status', usuário 09/10/2026")
st[tratado] <- "T2D"
for (i in which(!is.na(st))) add(g, x$gsm[i], "status", st[i], mot[i])
add(g, "*", "basal", "TRUE", "'statin treatment' é medicação crônica registrada, não intervenção do estudo: amostras basais (usuário 09/10/2026)")

# GSE50244 (ilhotas, Lund): HbA1c por doador; doadores repetidos do GSE41762 (idade + sexo + IMC iguais) saem
g <- "GSE50244"; x <- a[a$gse == g, ]
st <- ada(val(g, "hba1c")[x$gsm])
# repetidos: mesmo sexo, idade com até 1 ano de diferença (os dois estudos calculam a idade em datas diferentes) e IMC
# a até 0,6; mais os pares de perfil quase idêntico achados pela sanidade (r centrado > 0,9). Revisão de 09/10/2026: o
# cruzamento por idade exata deixava passar doadores repetidos (7 pares com 1 ano de diferença)
p1 <- a[a$gse == g, c("gsm", "idade", "sexo")]; p1$bmi <- val(g, "bmi")[p1$gsm]
p2 <- a[a$gse == "GSE41762", c("gsm", "idade", "sexo")]; p2$bmi <- val("GSE41762", "bmi")[p2$gsm]
casa <- vapply(seq_len(nrow(p1)), function(i) any(p2$sexo == p1$sexo[i] & abs(p2$idade - p1$idade[i]) <= 1 & abs(p2$bmi - p1$bmi[i]) <= 0.6, na.rm = TRUE), TRUE)
dup <- if (file.exists("output/sanidade/possiveis_duplicados.csv")) utils::read.csv("output/sanidade/possiveis_duplicados.csv", stringsAsFactors = FALSE) else NULL
por_expr <- if (!is.null(dup)) unique(c(dup$amostra_b[dup$estudo_a == "GSE41762" & dup$estudo_b == g], dup$amostra_a[dup$estudo_b == "GSE41762" & dup$estudo_a == g])) else character()
rep41762 <- unique(c(p1$gsm[casa], por_expr))
# reavaliação de 12/10/2026 (docs/varreduras/reavaliar_GSE50244_*.R): o critério acima marcava 79 doadores, mas ~25 coincidem
# ao acaso; a expressão (GSE50397, mesmo array do GSE41762) confirma 67. Quando a reavaliação existe, ela manda.
f_re <- "output/02_metadados/reavaliacao_GSE50244_classes.csv"
if (file.exists(f_re)) { re <- utils::read.csv(f_re, stringsAsFactors = FALSE)
  rep41762 <- re$gsm_50244[re$classe == "repetido (expressão)" | (re$classe == "intermediário" & re$meta_bate %in% TRUE)] }
for (i in which(!is.na(st))) add(g, x$gsm[i], "status", if (x$gsm[i] %in% rep41762) "EXCLUIR" else st[i],
                                 if (x$gsm[i] %in% rep41762) "Doador repetido do GSE41762 (Lund), confirmado pela expressão no GSE50397 (mesmo array) e por sexo, IMC e HbA1c: fica só no GSE41762 (reavaliação de 12/10/2026)"
                                 else "Status pela HbA1c do doador (ADA); resgate dos 'sem status', usuário 09/10/2026")

# GSE250283 (sangue): grupos do estudo; DM2 com doença coronariana fora da análise principal
g <- "GSE250283"
add(g, "carac:sample group=Healthy", "status", "ND", "Grupo 'Healthy' do estudo (usuário 09/10/2026)")
add(g, "carac:sample group=DMnoCAD", "status", "T2D", "Grupo 'DMnoCAD' (DM2 sem doença coronariana; usuário 09/10/2026)")
add(g, "carac:sample group=DMCAD", "status", "EXCLUIR", "Grupo 'DMCAD' (DM2 com doença coronariana): fora da análise principal, previsto para sensibilidade (usuário 09/10/2026)")

cu <- do.call(rbind, linhas)
f <- "input/curadoria.csv"; atual <- utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
atual <- atual[!atual$gse %in% c("GSE130991", "GSE50244", "GSE250283"), ]
utils::write.csv(rbind(atual, cu), f, row.names = FALSE, fileEncoding = "UTF-8")
ex <- utils::read.csv("input/exclusoes.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
if (!"GSE50397" %in% ex$gse) { ex <- rbind(ex, data.frame(gse = "GSE50397", motivo = "Mesmos 89 doadores do GSE50244 (array); fica o GSE50244 (RNA-seq) (usuário 09/10/2026)", decisao = "09/10/2026"))
  utils::write.csv(ex, "input/exclusoes.csv", row.names = FALSE, fileEncoding = "UTF-8") }
cat(sprintf("curadoria: %d linhas novas (GSE130991 %d, GSE50244 %d [%d repetidos do GSE41762], GSE250283 3)\n", nrow(cu), sum(cu$gse == "GSE130991"), sum(cu$gse == "GSE50244"), length(rep41762)))
