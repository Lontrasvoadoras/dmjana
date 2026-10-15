###############################################################################
#  run_04_processamento.R - executa a ETAPA 04 (obtenção e processamento) e gera o relatório
#  Uso (a partir de workflow_dm_menopausa):
#     "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_04_processamento.R [GSE ...]
#  Sem argumentos processa todos os estudos de config/processamento.yaml que estão elegíveis na
#  etapa 02; com argumentos, só esses (o inventário junta o que já estiver salvo).
#  Arquivos brutos em D:/dm_jana_cache/menopausa (cache; não baixa de novo).
###############################################################################
suppressPackageStartupMessages({ library(dplyr); library(Biobase); library(oligo) })
for (f in c("R/00_utils.R", "R/02_metadados.R", "R/03_sexo_genetico.R", "R/04_processamento.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
P <- ler_config("config/processamento.yaml"); S <- ler_config("config/sexo_genetico.yaml")
# "F" sozinho numa coluna vira FALSE no read.csv: colunas de sexo sempre como texto
le <- function(arq) { cc <- c(sexo = "character", sexo_genetico = "character", sexo_h5ad = "character")
  h <- names(utils::read.csv(arq, nrows = 1, check.names = FALSE, fileEncoding = "UTF-8"))
  utils::read.csv(arq, stringsAsFactors = FALSE, fileEncoding = "UTF-8", na.strings = c("NA", ""), colClasses = cc[names(cc) %in% h]) }
a <- le("output/02_metadados/amostras.csv"); longo <- le("output/02_metadados/amostras_longo.csv"); el <- le("output/02_metadados/elegibilidade.csv")
eleg <- unique(el$gse[el$categoria == "elegivel"])
fora_config <- setdiff(eleg, names(P$estudos))
if (length(fora_config)) stop("estudos elegíveis sem plano em config/processamento.yaml: ", paste(fora_config, collapse = ", "))
alvo <- if (length(commandArgs(TRUE))) commandArgs(TRUE) else intersect(names(P$estudos), eleg)
if (toupper(Sys.getenv("SO_RELATORIO", "FALSE")) == "TRUE") alvo <- character()   # refaz só inventário, figura e documentos
# SO_LOTE=TRUE: acrescenta o lote (data de leitura) às saídas já processadas, sem reprocessar
if (toupper(Sys.getenv("SO_LOTE", "FALSE")) == "TRUE") {
  alvo <- character()
  for (g in intersect(names(P$estudos), eleg)) {
    f <- file.path("output/04_processamento", g, "amostras_qc.csv"); if (!file.exists(f)) next
    am <- le(f); tipo <- P$estudos[[g]]$tipo
    am$lote <- if (tipo %in% c("cel", "agilent_bruto")) data_leitura(P, g, tipo, am$gsm) else NA_character_
    escrever_csv(am, f)
    m <- am[am$mantida, ]; cl <- confusao_lote(m$lote, m$status); r <- le(file.path("output/04_processamento", g, "resumo.csv"))
    r$lotes <- cl[["lotes"]]; r$lote_v_cramer <- round(cl[["v_cramer"]], 2); r$lote_frac_mista <- round(cl[["frac_mista"]], 2)
    escrever_csv(r, file.path("output/04_processamento", g, "resumo.csv"))
    log_msg("ETAPA 04 | %s: lote %s (V de Cramér %s; %s%% em lotes mistos)", g, cl[["lotes"]], round(cl[["v_cramer"]], 2), round(100 * cl[["frac_mista"]]))
  }
}

d <- pasta("output", "04_processamento")
for (g in alvo) {
  t0 <- Sys.time(); log_msg("ETAPA 04 | %s: início (%s)", g, P$estudos[[g]]$tipo)
  x <- tryCatch(processar_estudo(P, S, g, a, longo), error = function(e) { log_msg("ETAPA 04 | %s: ERRO %s", g, conditionMessage(e)); NULL })
  if (is.null(x)) { escrever_csv(data.frame(gse = g, erro = "falha no processamento (ver logs/workflow.log)"), file.path(pasta(d, g), "erro.csv")); next }
  unlink(file.path(d, g, "erro.csv"))
  inv <- salvar_estudo(g, x); escrever_csv(inv, file.path(d, g, "resumo.csv"))
  log_msg("ETAPA 04 | %s: %d genes, %d/%d amostras mantidas, mulheres 40-60 DM2/ND %d/%d (%.1f min)", g, inv$genes, inv$mantidas, inv$amostras, inv$F40a60_T2D, inv$F40a60_ND,
          as.numeric(difftime(Sys.time(), t0, units = "mins")))
}

# ---------------- inventário (todos os estudos salvos) ----------------
inv <- dplyr::bind_rows(lapply(eleg, function(g) {
  f <- file.path(d, g, "resumo.csv"); e <- file.path(d, g, "erro.csv")
  if (file.exists(f)) le(f) else data.frame(gse = g, tecido = el$tecido[el$gse == g][1], tipo = P$estudos[[g]]$tipo %||% NA, erro = if (file.exists(e)) "falha" else "não processado")
}))
inv$categoria <- dplyr::case_when(!is.na(inv$erro %||% NA) ~ "falha no processamento",
                                  inv$uso %in% "dirigido" ~ "análise dirigida (painel)",
                                  inv$so_sensibilidade %in% TRUE ~ "só sensibilidade (sexo discordante)",
                                  (inv$lote_v_cramer %||% NA) > P$qc$lote_v_cramer_max & (inv$lote_frac_mista %||% NA) < P$qc$lote_frac_mista_min ~ "só sensibilidade (lote confundido com o grupo)",
                                  inv$F40a60_T2D >= 2 & inv$F40a60_ND >= 2 ~ "pronto para a etapa 05",
                                  TRUE ~ "perdeu elegibilidade no controle de qualidade")
escrever_csv(inv, file.path(d, "inventario.csv"))

# ---------------- figuras: PCA por estudo (status e sexo) ----------------
ok <- inv$gse[is.na(inv$erro %||% NA)]
if (length(ok)) {
  pasta("docs", "figuras"); nl <- ceiling(length(ok) / 4)
  grDevices::png("docs/figuras/pca_estudos.png", width = 1800, height = 430 * nl, res = 150)
  op <- graphics::par(mfrow = c(nl, 4), mar = c(4, 4, 2.5, 1))
  for (g in ok) {
    ex <- readRDS(file.path(d, g, "expressao.rds"))$expressao; am <- le(file.path(d, g, "amostras_qc.csv"))
    falta <- setdiff(am$coluna, colnames(ex))                            # 09/10/2026: não derruba a figura; registra
    if (length(falta)) { log_msg("ETAPA 04 | %s: %d coluna(s) do controle de qualidade sem expressão na figura (%s)", g, length(falta), paste(utils::head(falta, 3), collapse = ", ")); am <- am[am$coluna %in% colnames(ex), ] }
    if (nrow(am) < 3) next
    p <- pca_estudo(ex[, am$coluna, drop = FALSE])
    graphics::plot(p$x, col = ifelse(am$status == "T2D", "#C0392B", "#2E86C1"), pch = ifelse(am$sexo %in% "F", 19, ifelse(am$sexo %in% "M", 17, 1)),
                   cex = ifelse(am$mantida, 1, 1.6), xlab = sprintf("PC1 (%.0f%%)", 100 * p$ve[1]), ylab = sprintf("PC2 (%.0f%%)", 100 * p$ve[2]), main = g, cex.main = 1)
    if (any(!am$mantida)) graphics::points(p$x[!am$mantida, , drop = FALSE], pch = 4, cex = 2)
  }
  graphics::par(op); grDevices::dev.off()
}

# ---------------- relatório de validação ----------------
pr <- inv[is.na(inv$erro %||% NA), ]
linhas <- c(
  "# Validação da etapa 04: obtenção e processamento dos dados de expressão", "",
  sprintf("Gerado em %s a partir de `output/04_processamento/`. **Aprovar antes de seguir para a etapa 05.**", format(Sys.time(), "%d/%m/%Y %H:%M")), "",
  "## 1. Resultado por estudo", "",
  "| GSE | Tecido | Tipo | Fonte | Genes | Amostras | Mantidas | Sexo discordante | Discrepantes | Outras retiradas | Sexo genético | F 40–60 DM2/ND | Categoria |",
  "|---|---|---|---|---:|---:|---:|---:|---:|---:|---|---|---|",
  sprintf("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |", inv$gse, inv$tecido, inv$tipo, ifelse(is.na(inv$fonte), "-", substr(inv$fonte, 1, 45)),
          ifelse(is.na(inv$genes), "-", inv$genes), ifelse(is.na(inv$amostras), "-", inv$amostras), ifelse(is.na(inv$mantidas), "-", inv$mantidas),
          ifelse(is.na(inv$sexo_discordantes), "-", sprintf("%d (%s)", inv$sexo_discordantes, ifelse(is.na(inv$frac_discordancia), "-", sprintf("%.0f%%", 100 * inv$frac_discordancia)))),
          ifelse(is.na(inv$discrepantes), "-", inv$discrepantes), ifelse(is.na(inv$outras_retiradas), "-", inv$outras_retiradas),
          ifelse(is.na(inv$sexo_genetico), "-", inv$sexo_genetico), ifelse(is.na(inv$F40a60_T2D), "-", sprintf("%d/%d", inv$F40a60_T2D, inv$F40a60_ND)), inv$categoria), "",
  "## 2. Por tecido (prontos para a etapa 05)", "")
pt <- pr[pr$categoria == "pronto para a etapa 05", ]
if (nrow(pt)) { tt <- pt %>% group_by(tecido) %>% summarise(estudos = n(), T2D = sum(F40a60_T2D), ND = sum(F40a60_ND), .groups = "drop")
  linhas <- c(linhas, "| Tecido | Estudos | Doadoras DM2 40–60 | Doadoras ND 40–60 |", "|---|---:|---:|---:|", sprintf("| %s | %d | %d | %d |", tt$tecido, tt$estudos, tt$T2D, tt$ND), "") }
ret <- do.call(rbind, lapply(pr$gse, function(g) { am <- le(file.path(d, g, "amostras_qc.csv")); am <- am[!am$mantida, ]
  if (nrow(am)) data.frame(gse = g, coluna = am$coluna, sexo = am$sexo, sexo_genetico = am$sexo_genetico, status = am$status, idade = am$idade, motivo = am$motivo_retirada) }))
linhas <- c(linhas, "## 3. Amostras retiradas", "")
if (!is.null(ret) && nrow(ret)) linhas <- c(linhas, "| GSE | Amostra | Sexo declarado | Sexo genético | Status | Idade | Motivo |", "|---|---|---|---|---|---|---|",
  sprintf("| %s | %s | %s | %s | %s | %s | %s |", ret$gse, ret$coluna, ret$sexo, ret$sexo_genetico, ret$status, ret$idade, ret$motivo), "") else linhas <- c(linhas, "Nenhuma.", "")
linhas <- c(linhas, "## 4. Fonte e processamento de cada estudo", "",
  sprintf("- **%s** (%s): %s. %s%s", pr$gse, pr$tipo, pr$fonte, pr$processamento, ifelse(is.na(pr$nota) | !nzchar(pr$nota), "", paste0(". Nota: ", pr$nota))), "",
  "Figura: `docs/figuras/pca_estudos.png` (vermelho = DM2, azul = sem diabetes; círculo = F, triângulo = M, aberto = sem sexo; X = retirada).", "",
  "## 5. O que validar", "",
  "1. Fonte e processamento de cada estudo (seção 4), em especial os que usam matriz do autor.",
  "2. As amostras retiradas e os motivos (seção 3).",
  "3. Estudos que perderam elegibilidade ou ficaram só para sensibilidade (seção 1, coluna Categoria).")
writeLines(linhas, file.path(pasta("docs"), "validacao_04_processamento.md"), useBytes = TRUE)
log_msg("ETAPA 04 | relatório de validação: docs/validacao_04_processamento.md")
documentar_etapa_04(P, inv, ret)
