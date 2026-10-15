###############################################################################
#  run_03_sexo_genetico.R - executa a ETAPA 03 (pré-análise de sexo genético) e gera o relatório
#  Uso (a partir de workflow_dm_menopausa):
#     "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_03_sexo_genetico.R
#  Requer a etapa 02 (output/02_metadados/). Matrizes e anotações do GEO ficam em cache/geo_matriz/.
#  Saídas: output/03_sexo_genetico/*.csv, docs/figuras/sexo_genetico*.png,
#          docs/validacao_03_sexo_genetico.md e docs/etapa_03_sexo_genetico.docx
###############################################################################
suppressPackageStartupMessages({ library(dplyr) })
for (f in c("R/00_utils.R", "R/02_metadados.R", "R/03_sexo_genetico.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
S <- ler_config("config/sexo_genetico.yaml"); M <- ler_config("config/metadados.yaml")
el <- utils::read.csv("output/02_metadados/elegibilidade.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
a <- utils::read.csv("output/02_metadados/amostras.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8", na.strings = c("NA", ""))   # campo vazio = sem informação
catalogo <- utils::read.csv("output/01_busca/catalogo.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")

# 1. candidatos
cand <- candidatos_sexo(S, el)
cand$gpl <- catalogo$plataformas[match(cand$gse, catalogo$gse)]
n_sem_sexo <- sum(el$categoria %in% unlist(S$candidatos$categorias))
log_msg("ETAPA 03 | %d estudo x tecido sem sexo; %d candidatos (com idade, status e amostras de 40-60 nos dois grupos)", n_sem_sexo, nrow(cand))

# 2-3. validação do método em estudos com sexo declarado nas mesmas plataformas
gpls <- unique(unlist(strsplit(cand$gpl, ";")))
val <- estudos_validacao(S, a, catalogo, gpls)
rv <- sexo_genetico_estudos(S, val, so_gpl = val$gpl)
acerto <- acerto_validacao(rv$amostras, a)
pv <- plataformas_validadas(S, acerto, gpls)

# 3-4. candidatos
rc <- sexo_genetico_estudos(S, cand)
sx <- rc$amostras; sx$plataforma_validada <- pv$validada[match(sx$gpl, pv$gpl)]
res <- rc$resumo; res$plataforma_validada <- pv$validada[match(res$gpl, pv$gpl)]
res$F <- vapply(paste(res$gse, res$gpl), function(k) sum(sx$sexo_genetico[paste(sx$gse, sx$gpl) == k] %in% "F"), 1L)
res$M <- vapply(paste(res$gse, res$gpl), function(k) sum(sx$sexo_genetico[paste(sx$gse, sx$gpl) == k] %in% "M"), 1L)

# 5. elegibilidade: (i) só plataformas validadas; (ii) aceitando também as não validadas
sx_ok <- sx; sx_ok$sexo_genetico[!sx_ok$plataforma_validada] <- NA
e1 <- elegibilidade_resgate(M, a, sx_ok, catalogo, cand); e2 <- elegibilidade_resgate(M, a, sx, catalogo, cand)
er <- data.frame(gse = cand$gse, tecido = cand$tecido, gpl = cand$gpl,
                 plataforma_validada = pv$validada[match(cand$gpl, pv$gpl)],
                 decisao = res$decisao[match(cand$gse, res$gse)],
                 F40a60_T2D = e2$F40a60_T2D[match(paste(cand$gse, cand$tecido), paste(e2$gse, e2$tecido))],
                 F40a60_ND = e2$F40a60_ND[match(paste(cand$gse, cand$tecido), paste(e2$gse, e2$tecido))],
                 categoria_validado = e1$categoria[match(paste(cand$gse, cand$tecido), paste(e1$gse, e1$tecido))],
                 categoria_se_aceito = e2$categoria[match(paste(cand$gse, cand$tecido), paste(e2$gse, e2$tecido))],
                 titulo = cand$titulo)

# decisão final do usuário: estudos não aceitos saem com o motivo registrado na configuração
na <- unlist(S$nao_aceitos %||% list())
er$decisao_usuario <- ifelse(er$gse %in% names(na), "não aceito", "")
er$motivo_usuario <- ifelse(er$gse %in% names(na), unname(na[er$gse]), "")
er$categoria_final <- ifelse(er$gse %in% names(na), "excluído por decisão do usuário", er$categoria_validado)
d <- pasta("output", "03_sexo_genetico")
escrever_csv(cand, file.path(d, "candidatos.csv")); escrever_csv(sx, file.path(d, "sexo_amostras.csv"))
escrever_csv(res, file.path(d, "resumo_estudos.csv")); escrever_csv(er, file.path(d, "elegibilidade_resgate.csv"))
escrever_csv(rv$amostras, file.path(d, "validacao_amostras.csv")); escrever_csv(acerto, file.path(d, "validacao_acerto.csv"))
figura_sexo(sx, "docs/figuras/sexo_genetico_candidatos.png")
vfig <- merge(rv$amostras, a[!duplicated(a$gsm), c("gsm", "sexo")], by = "gsm"); vfig$sexo_genetico <- vfig$sexo   # cor = sexo declarado
figura_sexo(vfig[!is.na(vfig$p_xist), ], "docs/figuras/sexo_genetico_validacao.png")
log_msg("ETAPA 03 | %d candidato(s) passam a elegíveis (plataformas validadas); %d se aceitas as não validadas",
        sum(er$categoria_validado == "elegivel", na.rm = TRUE), sum(er$categoria_se_aceito == "elegivel", na.rm = TRUE))

# achados da revisão dos candidatos (leitura dos metadados e dos artigos, 06/10/2026)
achados <- c(
  "**GSE43950** (sangue, CD34+ frescas; seria elegível com 2/2): o tipo de diabetes não é declarado. No artigo (Hazra et al., PLoS One 2013, PMID 24223881) o grupo do array tem 58,6 anos e 41,8 anos de diabetes (início por volta dos 17 anos) e 56,2 anos e 27,4 anos de diabetes: perfil de diabetes tipo 1. O artigo estuda tipo 1 e tipo 2 e não diz qual é o grupo do array. A regra da etapa 02 contou como DM2 porque o resumo da série não cita tipo 1. Recomendo marcar como AMBÍGUO (sai). A plataforma (GPL10379) também não tem estudo de validação e não tem XIST.",
  "**GSE128665** (adiposo; seria elegível com 2 DM2 e 11 controles): 24 de 24 amostras com XIST no percentil 0,99, todas mulheres. Mas (i) a plataforma GPL23126 não tem estudo de validação com matriz no GEO; (ii) as células mesoteliais foram isoladas de pacientes em cirurgia bariátrica e a série não diz se foram cultivadas; (iii) os controles são de baixa resistência à insulina e o grupo experimento mistura DM2 e alta resistência à insulina sem diabetes (só as 2 com DM2 contam como DM2). Decisão: aceitar como elegível?",
  "**GSE19420** (músculo): todos homens (genes Y no percentil 0,9 em 42/42); **GSE182120** (músculo): 48 homens e 1 mulher; **GSE59363** (músculo, GPL6244 sem XIST): um só grupo pelos genes Y, sexo não decidível (o título de amostras não ajuda). Nenhum dos três traz mulheres.",
  "**GSE118230** (validação, GPL17586): as 12 amostras declaradas como homens têm perfil feminino (XIST 0,98; Y 0,19), o que sugere erro no sexo declarado; não foi usado contra a plataforma, porque o GSE72462 na mesma plataforma acertou 100%.")

# ---------------- relatório de validação ----------------
pc <- function(x) ifelse(is.na(x), "-", sprintf("%.0f%%", 100 * x))
linhas <- c(
  "# Validação da etapa 03: pré-análise de sexo genético", "",
  sprintf("Gerado em %s a partir de `output/03_sexo_genetico/`. **Aprovar antes de seguir.**", format(Sys.time(), "%d/%m/%Y %H:%M")), "",
  "## 1. Candidatos", "",
  sprintf("Dos %d estudo × tecido que saíram da etapa 02 por falta de sexo, **%d** têm idade e status e pelo menos %d amostras sem sexo de 40–60 anos com DM2 e sem diabetes. Nos demais o sexo não é o único obstáculo (falta idade ou status), e o sexo genético sozinho não os tornaria elegíveis.",
          n_sem_sexo, nrow(cand), S$candidatos$min_sem_sexo_por_grupo), "",
  "| GSE | Tecido | Plataforma | Sem sexo 40–60 DM2 | Sem sexo 40–60 ND | Título |", "|---|---|---|---:|---:|---|",
  sprintf("| %s | %s | %s | %d | %d | %s |", cand$gse, cand$tecido, cand$gpl, cand$sem_sexo_40a60_T2D, cand$sem_sexo_40a60_ND, substr(gsub("[|]", "/", cand$titulo), 1, 80)), "",
  "## 2. Método", "",
  "- **Dados:** matriz normalizada publicada no GEO (series matrix) e anotação da plataforma. Para ler o sexo não é preciso reprocessar os arquivos brutos.",
  sprintf("- **Leitura (a), dentro da amostra:** percentil de XIST e da mediana dos genes Y (%s) entre todos os genes da amostra. Mulher: XIST ≥ %.2f e Y ≤ %.2f. Homem: Y ≥ %.2f e XIST ≤ %.2f. Funciona mesmo se o estudo tiver um só sexo.",
          paste(unlist(S$genes$cromossomo_y), collapse = ", "), S$regras$xist_alto, S$regras$y_nao_alto, S$regras$y_alto, S$regras$xist_nao_alto),
  sprintf("- **Leitura (b), entre amostras:** escore z(Y) − z(XIST) e dois grupos por k-means, aceitos só com separação ≥ %d DP intragrupo (mesmo critério do workflow_multi_estruturado).", S$regras$separacao_min),
  sprintf("- **Aceite:** com XIST, (a) e (b) concordam em ≥ %.0f%% das amostras; com um só sexo no estudo, vale (a) se ≥ %.0f%% das amostras concordam. Sem XIST na plataforma, vale só (b) e um só sexo não é decidível.", 100 * S$regras$concordancia_min, 100 * S$regras$concordancia_min), "",
  "## 3. Validação do método (estudos com sexo declarado nas mesmas plataformas)", "",
  "| GSE | Plataforma | Amostras | Declaradas F/M | Com sexo atribuído | Acerto final | Acerto da leitura (a) | Cobertura de (a) |", "|---|---|---:|---|---:|---:|---:|---:|",
  sprintf("| %s | %s | %d | %d/%d | %d | %s | %s | %s |", acerto$gse, acerto$gpl, acerto$n, acerto$declarado_F, acerto$declarado_M, acerto$atribuido, pc(acerto$acerto), pc(acerto$acerto_a), pc(acerto$cobertura_a)), "",
  "| Plataforma | Estudos de validação | Melhor acerto | Validada |", "|---|---:|---:|---|",
  sprintf("| %s | %d | %s | %s |", pv$gpl, pv$estudos_validacao, pc(pv$melhor_acerto), ifelse(pv$validada, "sim", "**não**")), "",
  "Figura: `docs/figuras/sexo_genetico_validacao.png` (cor = sexo declarado).", "")
bx <- acerto[!is.na(acerto$acerto) & acerto$acerto < S$validacao$acerto_min, ]
if (nrow(bx)) {
  q <- merge(rv$amostras[rv$amostras$gse %in% bx$gse, ], a[!duplicated(a$gsm), c("gsm", "sexo")], by = "gsm")
  q <- q %>% group_by(gse, sexo) %>% summarise(n = n(), p_xist = round(stats::median(p_xist), 2), p_y = round(stats::median(p_y), 2), .groups = "drop")
  linhas <- c(linhas, "Estudos de validação com acerto abaixo do mínimo (mediana dos percentis por sexo declarado):", "",
              "| GSE | Sexo declarado | Amostras | Percentil de XIST | Percentil de Y |", "|---|---|---:|---:|---:|",
              sprintf("| %s | %s | %d | %.2f | %.2f |", q$gse, q$sexo, q$n, q$p_xist, q$p_y), "",
              "Quando as declaradas M têm XIST alto e Y ausente, iguais às declaradas F, o mais provável é erro no sexo declarado (tecido masculino não tem esse perfil), e não erro do método.", "")
}
linhas <- c(linhas, "## 4. Resultado nos candidatos", "",
  "| GSE | Plataforma | Amostras | Genes Y | XIST | Separação (DP) | Decisão | F | M | Plataforma validada | Detalhe |", "|---|---|---:|---:|---|---:|---|---:|---:|---|---|",
  sprintf("| %s | %s | %d | %d | %s | %s | %s | %d | %d | %s | %s |", res$gse, res$gpl, res$n, res$genes_y, ifelse(res$xist, "sim", "não"), ifelse(is.na(res$separacao), "-", format(res$separacao)),
          res$decisao, res$F, res$M, ifelse(res$plataforma_validada, "sim", "**não**"), res$detalhe), "",
  "Figura: `docs/figuras/sexo_genetico_candidatos.png`.", "",
  "## 5. Elegibilidade com o sexo genético", "",
  "| GSE | Tecido | Doadoras DM2 40–60 | Doadoras ND 40–60 | Categoria (só plataformas validadas) | Categoria (aceitando as não validadas) |", "|---|---|---:|---:|---|---|",
  sprintf("| %s | %s | %d | %d | %s | %s |", er$gse, er$tecido, er$F40a60_T2D, er$F40a60_ND, er$categoria_validado, er$categoria_se_aceito), "",
  "## 6. Achados e decisão do usuário", "",
  paste0("- ", achados), "",
  "**Decisão do usuário (06/10/2026): nenhum dos dois estudos foi aceito.**", "",
  "| GSE | Tecido | Seria elegível com | Decisão | Motivo |", "|---|---|---|---|---|",
  sprintf("| %s | %s | %d DM2 / %d ND | %s | %s |", er$gse[nzchar(er$decisao_usuario)], er$tecido[nzchar(er$decisao_usuario)], er$F40a60_T2D[nzchar(er$decisao_usuario)], er$F40a60_ND[nzchar(er$decisao_usuario)], er$decisao_usuario[nzchar(er$decisao_usuario)], er$motivo_usuario[nzchar(er$decisao_usuario)]), "",
  sprintf("Resultado final da etapa 03: **%d estudo(s) resgatado(s)**; os candidatos seguem fora da análise.", sum(er$categoria_final == "elegivel", na.rm = TRUE)), "",
  "## 7. O que validar", "",
  "1. A regra de aceite e os limiares (seção 2), conferidos na validação (seção 3).",
  "2. Decisão sobre os candidatos em plataforma sem validação: tomada (seção 6, nenhum aceito).",
  "3. Os estudos resgatados que passam a elegíveis entram na etapa de dados como os demais?")
writeLines(linhas, file.path(pasta("docs"), "validacao_03_sexo_genetico.md"), useBytes = TRUE)
log_msg("ETAPA 03 | relatório de validação: docs/validacao_03_sexo_genetico.md")

documentar_etapa_03(S, cand, n_sem_sexo, acerto, pv, res, er, achados)
