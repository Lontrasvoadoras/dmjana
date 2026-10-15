###############################################################################
#  run_01_busca.R - executa a ETAPA 01 (busca) e gera o relatório de validação
#  Uso (a partir de workflow_dm_menopausa):
#     "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_01_busca.R
#  Saídas: output/01_busca/*.csv e docs/validacao_01_busca.md (para aprovação do usuário
#  antes da etapa 02).
###############################################################################
suppressPackageStartupMessages({ library(dplyr) })
for (f in c("R/00_utils.R", "R/01_busca.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
cfg <- ler_config("config/busca.yaml")
# testes da triagem antes de tudo: falha interrompe a etapa
testes <- testar_triagem(cfg)
escrever_csv(testes, "output/01_busca/testes_triagem.csv")
if (!all(testes$ok)) stop(sprintf("ETAPA 01 | %d caso(s) de teste da triagem falharam; ver output/01_busca/testes_triagem.csv", sum(!testes$ok)))
log_msg("ETAPA 01 | testes da triagem: %d de %d corretos", sum(testes$ok), nrow(testes))
# NOVA_BUSCA=TRUE refaz as consultas no GEO; por padrão a triagem é refeita sobre a busca salva
# (mantém as séries e a data da consulta de 06/10/2026; auditoria de 06/10/2026)
nova <- toupper(Sys.getenv("NOVA_BUSCA", "FALSE")) == "TRUE" || !file.exists("output/01_busca/catalogo.csv")
b <- if (nova) buscar(cfg) else retriar(cfg)
salvar_busca(b)

# ---------------- relatório de validação ----------------
cat <- b$catalogo; sem <- b$sementes
n0 <- function(x) formatC(x, big.mark = ".", decimal.mark = ",", format = "d")
linhas <- c(
  "# Validação da etapa 01: busca no GEO",
  "",
  sprintf("Gerado em %s a partir de `output/01_busca/`. **Aprovar antes de seguir para a etapa 02 (metadados).**", format(Sys.time(), "%d/%m/%Y %H:%M")),
  "",
  "## 1. Consultas (uma por tecido)",
  "",
  "| Tecido | Séries encontradas |", "|---|---:|",
  sprintf("| %s | %s |", b$consultas$tecido, n0(b$consultas$n_resultados)),
  "",
  sprintf("Texto exato de cada consulta em `output/01_busca/consultas.csv`. Exemplo (ilhotas): `%s`", b$consultas$consulta[1]),
  "",
  "## 2. Triagem",
  "",
  sprintf("- **%s séries únicas** (uma série pode aparecer em mais de um tecido).", n0(nrow(cat))),
  sprintf("- **Incluídas:** %d. **Para revisão manual:** %d. **Excluídas:** %d.", sum(cat$triagem == "incluido"), sum(cat$triagem == "revisar"), sum(cat$triagem == "excluido")),
  "",
  "| Motivo de exclusão | Séries |", "|---|---:|")
mot <- sort(table(sub(" \\(termo: .*", " (termo no título)", cat$motivo[cat$triagem == "excluido"])), decreasing = TRUE)
linhas <- c(linhas, sprintf("| %s | %d |", names(mot), as.integer(mot)), "")
tt <- table(unlist(strsplit(cat$tecidos_busca[cat$triagem == "incluido"], ";")))
linhas <- c(linhas, "## 3. Incluídas por tecido", "", "| Tecido | Séries incluídas |", "|---|---:|",
            sprintf("| %s | %d |", names(tt), as.integer(tt)), "",
            "A mesma série conta em todos os tecidos em cuja consulta apareceu. O tecido real de cada amostra é lido na etapa 02.", "")
# sensibilidade
sem$encontrada <- sem$gse %in% cat$gse[cat$encontrado_pela_busca]
sem$triagem <- cat$triagem[match(sem$gse, cat$gse)]
linhas <- c(linhas, "## 4. Sensibilidade: estudos-semente (estudos já conhecidos com mulheres de 40–60)", "",
            sprintf("A busca encontrou **%d de %d** sementes sem ajuda. As não encontradas indicam termos que faltam.", sum(sem$encontrada), nrow(sem)), "",
            "| Semente | Tecido | Encontrada pela busca | Triagem |", "|---|---|---|---|",
            sprintf("| %s | %s | %s | %s |", sem$gse, sem$tecido, ifelse(sem$encontrada, "sim", "**não**"), sem$triagem), "")
# comparação com a busca do workflow anterior
ant <- "../workflow_multi_estruturado/output/01_busca/catalogo_estudos.csv"
if (file.exists(ant)) {
  a <- utils::read.csv(ant, fileEncoding = "UTF-8"); a_inc <- a$gse[a$triagem == "incluido"]
  novo_inc <- cat$gse[cat$triagem == "incluido"]
  so_novo <- setdiff(novo_inc, a_inc); so_ant <- setdiff(a_inc, novo_inc)
  linhas <- c(linhas, "## 5. Comparação com a busca do workflow_multi_estruturado (5 tecidos)", "",
              sprintf("- Incluídas nas duas: %d.", length(intersect(novo_inc, a_inc))),
              sprintf("- Só nesta busca: %d (sobretudo dos tecidos novos: osso, endométrio/ovário, mama, vasos).", length(so_novo)),
              sprintf("- Só na anterior: %d%s.", length(so_ant), if (length(so_ant)) paste0(" (", paste(utils::head(so_ant, 15), collapse = ", "), if (length(so_ant) > 15) ", …" else "", ")") else ""), "")
}
# comparação com a triagem anterior à auditoria
ant_arq <- "output/antes_auditoria/catalogo_01.csv"
if (file.exists(ant_arq)) {
  a0 <- utils::read.csv(ant_arq, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
  mud <- merge(a0[, c("gse", "triagem", "motivo")], cat[, c("gse", "triagem", "motivo", "titulo")], by = "gse", suffixes = c("_antes", "_agora"))
  mud <- mud[mud$triagem_antes != mud$triagem_agora, ]
  tm <- table(paste(mud$triagem_antes, "→", mud$triagem_agora))
  linhas <- c(linhas, "## 5b. Mudanças da auditoria de 06/10/2026", "",
              sprintf("%d séries mudaram de triagem com as regras corrigidas (mesma busca):", nrow(mud)), "",
              "| Mudança | Séries |", "|---|---:|", sprintf("| %s | %d |", names(tm), as.integer(tm)), "",
              "| GSE | Antes | Agora | Motivo agora | Título |", "|---|---|---|---|---|",
              sprintf("| %s | %s | %s | %s | %s |", mud$gse, mud$triagem_antes, mud$triagem_agora, ifelse(is.na(mud$motivo_agora), "", gsub("[|]", "/", mud$motivo_agora)), substr(gsub("[|]", "/", mud$titulo), 1, 80)), "")
}
inc <- cat[cat$triagem == "incluido", ]
linhas <- c(linhas, "## 6. Séries incluídas", "", "| GSE | Tecidos da busca | Amostras | Título |", "|---|---|---:|---|",
            sprintf("| %s | %s | %d | %s |", inc$gse, inc$tecidos_busca, inc$n_amostras, substr(gsub("\\|", "/", inc$titulo), 1, 110)), "")
rev <- cat[cat$triagem == "revisar", ]
if (nrow(rev)) linhas <- c(linhas, "## 7. Para revisão manual", "", "| GSE | Amostras | Motivo | Título |", "|---|---:|---|---|",
                           sprintf("| %s | %d | %s | %s |", rev$gse, rev$n_amostras, rev$motivo, substr(gsub("\\|", "/", rev$titulo), 1, 90)), "")
linhas <- c(linhas, "## 8. Decisões já validadas",
            "",
            "- 06/10/2026, escopo: tecidos = os 5 do projeto + osso, endométrio/ovário, mama e vasos; condição = só DM2 com controles; código escrito do zero.",
            "- 06/10/2026, 1ª execução: termos específicos de DM2 acrescentados mantendo \"diabetic\"; tecido fora do escopo excluído pelo título só quando o título não cita um tecido de interesse; títulos com diabetes tipo 1 seguem para a etapa 02.",
            "- 06/10/2026, auditoria das exclusões (depois do GSE200044 excluído por \"ATAC\"): termos de outro tipo de dado e séries com mais de uma espécie vão para revisão; \"synthetic construct\" e vírus não contam como espécie; espécies no título só como palavra exata; mínimo de 4 amostras. Busca mantida, triagem refeita.",
            "")
linhas <- c(linhas, "## 9. O que validar",
            "",
            "1. Os termos de DM2 e de cada tecido (seção 1 e `config/busca.yaml`) cobrem o que interessa?",
            "2. As exclusões por termo do título (seção 2) estão corretas? Confira em `output/01_busca/catalogo.csv`, coluna `motivo`.",
            "3. As sementes não encontradas (seção 4) pedem termo novo?",
            "4. Os estudos de célula única para revisão (seção 7) devem seguir para a etapa 02?",
            "5. Algum estudo conhecido falta (inclua em `input/estudos_semente.csv`)?")
writeLines(linhas, file.path(pasta("docs"), "validacao_01_busca.md"), useBytes = TRUE)
log_msg("ETAPA 01 | relatório de validação: docs/validacao_01_busca.md")

# documento Word da etapa (pacotes, motivos, critérios de inclusão e exclusão)
documentar_etapa_01(cfg, b)
