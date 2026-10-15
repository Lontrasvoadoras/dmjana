###############################################################################
#  run_02_metadados.R - executa a ETAPA 02 (metadados e elegibilidade) e gera o relatório
#  Uso (a partir de workflow_dm_menopausa):
#     "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_02_metadados.R
#  Requer a etapa 01 aprovada (output/01_busca/catalogo.csv). O texto de cada série fica em
#  cache/geo/, então reexecutar não baixa de novo.
#  Saídas: output/02_metadados/*.csv, docs/validacao_02_metadados.md e docs/etapa_02_metadados.docx
#  (para aprovação do usuário antes da etapa 03).
###############################################################################
suppressPackageStartupMessages({ library(dplyr) })
for (f in c("R/00_utils.R", "R/02_metadados.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
M <- ler_config("config/metadados.yaml")
catalogo <- utils::read.csv("output/01_busca/catalogo.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")

# 0. regras testadas antes de tudo: falha em qualquer caso interrompe a etapa
testes <- testar_regras(M)
escrever_csv(testes, "output/02_metadados/testes_regras.csv")
if (!all(testes$ok)) stop(sprintf("ETAPA 02 | %d caso(s) de teste das regras falharam; ver output/02_metadados/testes_regras.csv", sum(!testes$ok)))
log_msg("ETAPA 02 | testes das regras: %d de %d corretos", sum(testes$ok), nrow(testes))

# 1-5. leitura, harmonização, elegibilidade
lido <- ler_metadados(M, catalogo)
a <- harmonizar(M, lido$longo, catalogo)
el <- elegibilidade(M, a, catalogo)

# chaves das características: quantas amostras, e a que campo cada uma foi atribuída
car <- lido$longo[lido$longo$campo == "carac", ]; kl <- tolower(car$chave)
usa <- function(rx, ex = NULL) grepl(rx, kl, perl = TRUE) & (if (is.null(ex)) TRUE else !grepl(ex, kl, perl = TRUE))
car$uso <- dplyr::case_when(usa(M$sexo$chave) ~ "sexo", usa(M$idade$chave, M$idade$excluir_chave) ~ "idade",
                            usa(M$status$chave, M$status$excluir_chave) ~ "status", usa(M$tecido$chave) ~ "tecido",
                            usa(M$intervencao$chave) ~ "intervenção", usa(M$doador$chave, M$doador$excluir_chave) ~ "doador", TRUE ~ "não usada")
chaves <- car %>% count(chave_min = tolower(chave), uso, name = "amostras") %>%
  left_join(car %>% group_by(chave_min = tolower(chave)) %>% summarise(estudos = n_distinct(gse), exemplo = paste(utils::head(unique(valor), 3), collapse = " | "), .groups = "drop"), by = "chave_min") %>%
  arrange(desc(estudos))

d <- pasta("output", "02_metadados")
escrever_csv(lido$longo, file.path(d, "amostras_longo.csv"))
escrever_csv(a[, setdiff(names(a), "carac_texto")], file.path(d, "amostras.csv"))
escrever_csv(el, file.path(d, "elegibilidade.csv"))
escrever_csv(chaves, file.path(d, "chaves.csv"))
log_msg("ETAPA 02 | %d amostras de %d séries; %d estudo x tecido elegíveis", nrow(a), length(unique(a$gse)), sum(el$categoria == "elegivel"))

# ---------------- relatório de validação ----------------
n0 <- function(x) formatC(x, big.mark = ".", decimal.mark = ",", format = "d")
pct <- function(x) sprintf("%.0f%%", 100 * mean(x))
eleg <- el[el$categoria == "elegivel", ]
linhas <- c(
  "# Validação da etapa 02: metadados por amostra e elegibilidade",
  "",
  sprintf("Gerado em %s a partir de `output/02_metadados/`. **Aprovar antes de seguir para a etapa 03.**", format(Sys.time(), "%d/%m/%Y %H:%M")),
  "",
  "## 1. Leitura",
  "",
  sprintf("- Séries lidas: **%d** (incluídas e para revisão na etapa 01; %d com mais de %s amostras ficaram de fora).", length(unique(a$gse)),
          sum(catalogo$triagem %in% c("incluido", "revisar") & catalogo$n_amostras > M$download$max_amostras), n0(M$download$max_amostras)),
  sprintf("- Sem amostras legíveis: %d%s.", length(lido$falhas), if (length(lido$falhas)) paste0(" (", paste(lido$falhas, collapse = ", "), ")") else ""),
  sprintf("- Amostras: **%s**. Testes das regras: %d de %d corretos (`input/testes_regras.csv`).", n0(nrow(a)), sum(testes$ok), nrow(testes)),
  "",
  "## 2. Harmonização (todas as amostras humanas lidas)",
  "",
  "| Campo | Reconhecido | Detalhe |", "|---|---:|---|")
h <- a[a$humano, ]
linhas <- c(linhas,
  sprintf("| Sexo | %s | F %s, M %s |", pct(!is.na(h$sexo)), n0(sum(h$sexo %in% "F")), n0(sum(h$sexo %in% "M"))),
  sprintf("| Idade | %s | exata %s, ponto médio de faixa %s, faixa larga (sem idade) %s |", pct(!is.na(h$idade)), n0(sum(h$idade_tipo %in% "exata")), n0(sum(h$idade_tipo %in% "faixa_ponto_medio")), n0(sum(h$idade_tipo %in% "faixa_larga"))),
  sprintf("| Status | %s | %s |", pct(!is.na(h$status)), paste(sprintf("%s %s", names(table(h$status)), n0(as.integer(table(h$status)))), collapse = ", ")),
  sprintf("| Tecido | %s | %s |", pct(!is.na(h$tecido)), paste(sprintf("%s %s", names(table(h$tecido)), n0(as.integer(table(h$tecido)))), collapse = ", ")),
  sprintf("| Cultivadas (saem) | %s | |", n0(sum(h$cultivado))),
  sprintf("| Sob intervenção (saem) | %s | |", n0(sum(!h$basal))),
  sprintf("| Aptas (ND/DM2, tecido de interesse, não cultivada, basal) | %s | |", n0(sum(h$apta))),
  sprintf("| Aptas e mulheres de 40–60 | %s | DM2 %s, ND %s |", n0(sum(h$apta & h$mulher_40a60)), n0(sum(h$apta & h$mulher_40a60 & h$status == "T2D")), n0(sum(h$apta & h$mulher_40a60 & h$status == "ND"))),
  "",
  "## 3. Estudos por categoria (estudo × tecido)",
  "",
  sprintf("Regra: **elegível** se tem pelo menos %d doadoras DM2 e %d doadoras ND de %d–%d anos (doadoras únicas, não amostras). Os demais recebem o primeiro motivo que se aplica, nesta ordem.",
          M$elegibilidade$min_por_grupo, M$elegibilidade$min_por_grupo, M$elegibilidade$janela_idade[1], M$elegibilidade$janela_idade[2]),
  "", "| Categoria | Estudo × tecido |", "|---|---:|")
ct <- table(factor(el$categoria, levels = unique(c("elegivel", sort(unique(el$categoria))))))
linhas <- c(linhas, sprintf("| %s | %d |", names(ct), as.integer(ct)), "",
  "## 4. Elegíveis", "",
  "| GSE | Tecido | Doadoras DM2 40–60 | Doadoras ND 40–60 | Todas F (DM2/ND) | Todos M (DM2/ND) | Triagem 01 | Título |",
  "|---|---|---:|---:|---|---|---|---|",
  sprintf("| %s | %s | %d | %d | %d/%d | %d/%d | %s | %s |", eleg$gse, eleg$tecido, eleg$F40a60_T2D, eleg$F40a60_ND, eleg$F_T2D, eleg$F_ND, eleg$M_T2D, eleg$M_ND,
          eleg$triagem_01, substr(gsub("\\|", "/", eleg$titulo), 1, 80)), "")
sob <- eleg[nzchar(eleg$sobreposicao) | nzchar(eleg$mesmos_doadores), ]
if (nrow(sob)) linhas <- c(linhas, "Elegíveis que repartem amostras (mesmas GSM) ou doadores (mesmo identificador) com outra série: decidir qual fica.", "",
  "| GSE | Tecido | Amostras em comum com | Doadores em comum com |", "|---|---|---|---|",
  sprintf("| %s | %s | %s | %s |", sob$gse, sob$tecido, sob$sobreposicao, sob$mesmos_doadores), "")
ex <- el[el$categoria == "excluído por decisão do usuário", ]
if (nrow(ex)) linhas <- c(linhas, "Excluídos por decisão do usuário (`input/exclusoes.csv`):", "", sprintf("- %s (%s): %s", ex$gse, ex$tecido, ex$exclusao), "")
ss <- el[el$categoria == "SuperSeries: amostras já nas subséries", ]
if (nrow(ss)) linhas <- c(linhas, sprintf("SuperSeries fora da contagem (amostras já nas subséries): %s.", paste(sprintf("%s (%s)", ss$gse, ss$superserie_de), collapse = "; ")), "")
tt <- eleg %>% group_by(tecido) %>% summarise(estudos = n(), T2D = sum(F40a60_T2D), ND = sum(F40a60_ND), .groups = "drop")
linhas <- c(linhas, "### Por tecido", "", "| Tecido | Estudos | Doadoras DM2 40–60 | Doadoras ND 40–60 |", "|---|---:|---:|---:|",
            sprintf("| %s | %d | %d | %d |", tt$tecido, tt$estudos, tt$T2D, tt$ND), "")
# comparação com a execução anterior à auditoria de 06/10/2026
ant_arq <- "output/antes_auditoria/elegibilidade_02.csv"
if (file.exists(ant_arq)) {
  e0 <- utils::read.csv(ant_arq, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
  k0 <- paste(e0$gse, e0$tecido)[e0$categoria == "elegivel"]; k1 <- paste(eleg$gse, eleg$tecido)
  novos <- eleg[!k1 %in% k0, ]; saiu <- e0[e0$categoria == "elegivel" & !paste(e0$gse, e0$tecido) %in% k1, ]
  saiu$agora <- el$categoria[match(paste(saiu$gse, saiu$tecido), paste(el$gse, el$tecido))]
  linhas <- c(linhas, "### Mudanças da auditoria de 06/10/2026", "",
              sprintf("Antes da auditoria: %d estudo × tecido elegíveis; agora: %d.", length(k0), nrow(eleg)), "")
  if (nrow(novos)) linhas <- c(linhas, "| Novo elegível | Tecido | DM2 40–60 | ND 40–60 | Triagem 01 | Motivo da revisão na etapa 01 | Título |", "|---|---|---:|---:|---|---|---|",
    sprintf("| %s | %s | %d | %d | %s | %s | %s |", novos$gse, novos$tecido, novos$F40a60_T2D, novos$F40a60_ND, novos$triagem_01, novos$motivo_01, substr(gsub("[|]", "/", novos$titulo), 1, 70)), "")
  if (nrow(saiu)) linhas <- c(linhas, "| Deixou de ser elegível | Tecido | Categoria agora |", "|---|---|---|", sprintf("| %s | %s | %s |", saiu$gse, saiu$tecido, ifelse(is.na(saiu$agora), "-", saiu$agora)), "")
}
# quase elegíveis: valem curadoria
quase <- el[el$categoria != "elegivel" & !is.na(el$tecido) & (el$F40a60_T2D + el$F40a60_ND >= 2 | el$sem_sexo_40a60_T2D + el$sem_sexo_40a60_ND >= 2 |
             (el$frac_idade < M$elegibilidade$min_frac_campo & el$F_T2D >= 2 & el$F_ND >= 2)), ]
if (nrow(quase)) linhas <- c(linhas, "## 5. Quase elegíveis (candidatos a curadoria)", "",
  "Estudos com mulheres e DM2/ND mas sem idade, ou com mulheres de 40–60 em só um grupo, ou com idade e status mas sem sexo (candidatos ao sexo genético na etapa de expressão).", "",
  "| GSE | Tecido | Categoria | F 40–60 DM2/ND | F todas DM2/ND | Sem sexo 40–60 DM2/ND | Fração com idade | Título |", "|---|---|---|---|---|---|---:|---|",
  sprintf("| %s | %s | %s | %d/%d | %d/%d | %d/%d | %.2f | %s |", quase$gse, quase$tecido, quase$categoria, quase$F40a60_T2D, quase$F40a60_ND, quase$F_T2D, quase$F_ND,
          quase$sem_sexo_40a60_T2D, quase$sem_sexo_40a60_ND, quase$frac_idade, substr(gsub("\\|", "/", quase$titulo), 1, 70)), "")
nu <- chaves[chaves$uso == "não usada", ]; nu <- utils::head(nu[order(-nu$estudos), ], 30)
linhas <- c(linhas, "## 6. Chaves não usadas mais frequentes (podem esconder sexo, idade ou status)", "",
  "| Chave | Estudos | Amostras | Exemplos de valor |", "|---|---:|---:|---|",
  sprintf("| %s | %d | %d | %s |", nu$chave_min, nu$estudos, nu$amostras, substr(gsub("\\|", "/", nu$exemplo), 1, 80)), "",
  "Lista completa em `output/02_metadados/chaves.csv`.", "",
  "## 7. O que validar", "",
  sprintf("1. Mínimo por grupo = %d doadoras DM2 e ND de 40–60 por estudo × tecido: **validado em 06/10/2026**.", M$elegibilidade$min_por_grupo),
  "2. Os elegíveis da seção 4 fazem sentido (tecido e números de doadoras)?",
  "3. Os quase elegíveis da seção 5 merecem curadoria (idade em artigo ou tabela suplementar, linhas em `input/curadoria.csv`)?",
  "4. Alguma chave da seção 6 deveria ser usada?",
  "5. Estudos que vieram da revisão manual da etapa 01 (coluna Triagem 01 = revisar) e ficaram elegíveis: manter?",
  "",
  "### Pontos que encontrei e recomendação",
  "",
  "- **GSE249102** (sangue, novo depois da auditoria): estudo de tuberculose e diabetes; contam só os grupos DM2 sem TB e controles (TB e TB+DM2 ficam sem status). Mesma lógica do GSE158055, mas aqui o contraste não é confundido com a infecção.",
  "- **GSE200044** (ilhotas, novo depois da auditoria): multiome ATAC + RNA; como o GSE171153, entra se a etapa de dados confirmar expressão por doador.",
  "- **GSE171153** (ilhotas): série mista (cromatina por célula única + expressão); só a parte de expressão serve. Verificar na etapa de dados se há matriz de expressão por doador; se não houver, sai.",
  "- Decidido em 06/10/2026: GSE158055 excluído (DM2 confundido com COVID-19); FH+ do GSE25462 ficam ND (descrição das amostras no GEO: \"subject without diabetes\").",
  "- Decidido em 06/10/2026: mantidos GSE86469 (HPAP, célula única; sai GSE86468, mesmos doadores) e GSE41762 (Lund; sai GSE38642, doadores repetidos).",
  "- **GSE23561 e GSE316126** (sangue): excluídos no workflow anterior por problemas nos dados (sexo genético não separou as amostras no GSE23561). Aqui seguem elegíveis pelos metadados; o controle de qualidade da expressão decide na etapa seguinte.",
  "- **Curadoria aplicada** (`input/curadoria.csv`): sexo 0/1 do GSE18732; status pelo título em GSE18732, GSE25462 e GSE15653; GSE81965 marcado como cultivado (miócitos em cultura).")
writeLines(linhas, file.path(pasta("docs"), "validacao_02_metadados.md"), useBytes = TRUE)
log_msg("ETAPA 02 | relatório de validação: docs/validacao_02_metadados.md")

documentar_etapa_02(M, a, el, testes, lido)
