###############################################################################
#  run_08b_replicacao_figado.R - fígado em dois níveis (decisão do usuário, 09/10/2026, opção 2)
#  Descoberta: GSE130991 (análise principal do fígado, 1 estudo grande). Replicação: GSE15653 (3 x 4), mostrado à parte.
#  Para os módulos, vias e genes selecionados no estudo grande, mede o efeito no estudo de replicação (mesmo modelo da
#  etapa 05, só mulheres de 40-60) e a concordância de sentido (acaso = 50%, teste binomial).
#  Saídas: output/08_painel/replicacao_figado_*.csv, docs/validacao_08b_replicacao_figado.md, docs/etapa_08b_replicacao_figado.docx
###############################################################################
for (f in c("R/00_utils.R", "R/05_meta.R", "R/06_redes.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
MC <- ler_config("config/meta.yaml"); options(vias_competitivo = !isFALSE(MC$vias$competitivo))
inv_all <- utils::read.csv("output/04_processamento/inventario.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
codif <- if (isTRUE(MC$so_codificantes)) genes_codificantes() else NULL
le <- function(f) if (file.exists(f) && file.size(f) > 5) utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8") else NULL
f2 <- function(x, k = 2) ifelse(is.na(x), "-", formatC(x, format = "f", digits = k, decimal.mark = ","))
fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
desc <- "GSE130991"; repl <- "GSE15653"; d <- pasta("output", "08_painel")
E <- carregar_estudo(repl, inv_all, NULL, codif)
concord <- function(g1, g2) { ok <- !is.na(g1) & !is.na(g2); n <- sum(ok); k <- sum(sign(g1[ok]) == sign(g2[ok]))
  c(n = n, concordantes = k, frac = if (n) round(k / n, 3) else NA, p_binomial = if (n) signif(stats::binom.test(k, n, 0.5, alternative = "greater")$p.value, 3) else NA) }

# módulos: os selecionados no fígado (ou, se nenhum, os 5 de menor p) -> eigengene no GSE15653
mm <- le("output/06_redes/figado/meta_modulos.csv"); mm$selecao[is.na(mm$selecao)] <- ""
alvo_m <- if (any(nzchar(mm$selecao))) mm[nzchar(mm$selecao), ] else utils::head(mm[order(mm$p), ], 5)
cores <- readRDS("output/06_redes/figado/rede_cache.rds")$cores
Eg <- eigengenes_estudo(E$ex[, E$am$coluna, drop = FALSE], cores)   # todos os módulos: com 1 linha o limma não estima a variância
rm_ <- if (nrow(Eg)) tryCatch(ajustar(MC, E, Y = Eg, metodo = "limma", so_alvo = TRUE), error = function(e) NULL) else NULL
mod <- data.frame(modulo = alvo_m$id, selecao = ifelse(nzchar(alvo_m$selecao), alvo_m$selecao, "não selecionado (5 de menor p)"), genes = alvo_m$genes,
                  g_descoberta = round(alvo_m$g, 2), p_descoberta = signif(alvo_m$p, 3),
                  g_replicacao = round(rm_$g[match(alvo_m$id, rm_$id)], 2), p_replicacao = signif(rm_$p[match(alvo_m$id, rm_$id)], 3))
mod$mesmo_sentido <- sign(mod$g_descoberta) == sign(mod$g_replicacao)

# vias: as selecionadas no fígado (até 100 de menor p) -> escore no GSE15653
gt <- le("output/07_enriquecimento/gsea_tecidos.csv"); gt$nivel[is.na(gt$nivel)] <- ""
sv <- gt[gt$tecido == "figado" & nzchar(gt$nivel), ]; sv <- utils::head(sv[order(sv$p), ], 100)
cols <- list(Hallmark = c("H", ""), Reactome = c("C2", "CP:REACTOME"), GO_BP = c("C5", "GO:BP"))
conj <- unlist(lapply(names(cols), function(cl) { x <- tryCatch(msigdbr::msigdbr(species = "Homo sapiens", collection = cols[[cl]][1], subcollection = if (nzchar(cols[[cl]][2])) cols[[cl]][2] else NULL),
  error = function(e) msigdbr::msigdbr(species = "Homo sapiens", category = cols[[cl]][1], subcategory = if (nzchar(cols[[cl]][2])) cols[[cl]][2] else NULL))
  x <- x[x$gs_name %in% sv$via, ]; split(x$gene_symbol, x$gs_name) }), recursive = FALSE)
S <- escores_vias(E$ex, conj, MC$vias$min_genes)
rv <- if (nrow(S)) tryCatch(ajustar(MC, E, Y = S, metodo = "limma", so_alvo = TRUE), error = function(e) NULL) else NULL
via <- data.frame(colecao = sv$colecao, via = sv$via, nivel = sv$nivel, g_descoberta = round(sv$g, 2), p_descoberta = signif(sv$p, 3), fdr_descoberta = signif(sv$fdr, 3),
                  g_replicacao = round(rv$g[match(sv$via, rv$id)], 2), p_replicacao = signif(rv$p[match(sv$via, rv$id)], 3))
via$mesmo_sentido <- sign(via$g_descoberta) == sign(via$g_replicacao)

# genes: os de menor p no estudo grande (FDR < 0,05, até 500) -> efeito no GSE15653
gd <- le(file.path("output/05_meta/estudos", desc, "efeitos_genes.csv")); gr <- le(file.path("output/05_meta/estudos", repl, "efeitos_genes.csv"))
gd$fdr <- stats::p.adjust(gd$p, "BH"); top <- utils::head(gd[order(gd$p), ][gd$fdr[order(gd$p)] < 0.05, ], 500)
gen <- data.frame(gene = top$id, g_descoberta = round(top$g, 2), p_descoberta = signif(top$p, 3), fdr_descoberta = signif(top$fdr, 3),
                  g_replicacao = round(gr$g[match(top$id, gr$id)], 2), p_replicacao = signif(gr$p[match(top$id, gr$id)], 3))
gen$mesmo_sentido <- sign(gen$g_descoberta) == sign(gen$g_replicacao)
res <- rbind(data.frame(nivel = "módulos", t(concord(mod$g_descoberta, mod$g_replicacao))), data.frame(nivel = "vias", t(concord(via$g_descoberta, via$g_replicacao))),
             data.frame(nivel = "genes (FDR < 0,05)", t(concord(gen$g_descoberta, gen$g_replicacao))))
escrever_csv(mod, file.path(d, "replicacao_figado_modulos.csv")); escrever_csv(via, file.path(d, "replicacao_figado_vias.csv"))
escrever_csv(gen, file.path(d, "replicacao_figado_genes.csv")); escrever_csv(res, file.path(d, "replicacao_figado_resumo.csv"))
log_msg("ETAPA 08b | fígado em dois níveis: %s", paste(sprintf("%s %s/%s concordantes (p %s)", res$nivel, res$concordantes, res$n, fp(res$p_binomial)), collapse = "; "))

et <- utils::read.csv("output/05_meta/estudos.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
nd <- et[et$gse == desc, ]; nr <- et[et$gse == repl, ]
linhas <- c("# Fígado em dois níveis: descoberta (GSE130991) e replicação (GSE15653)", "", sprintf("Gerado em %s.", format(Sys.time(), "%d/%m/%Y %H:%M")), "",
  sprintf("Descoberta: %s, %d mulheres de 40–60 com DM2 e %d sem diabetes. Replicação: %s, %d e %d. Decisão do usuário (09/10/2026): o estudo pequeno não veta o grande; é mostrado à parte.", desc, nd$F40a60_T2D, nd$F40a60_ND, repl, nr$F40a60_T2D, nr$F40a60_ND), "",
  "## Resumo da replicação (concordância de sentido; acaso = 50%)", "", "| Nível | Testados | Mesmo sentido | Fração | p (binomial) |", "|---|---:|---:|---:|---:|",
  sprintf("| %s | %s | %s | %s | %s |", res$nivel, res$n, res$concordantes, f2(as.numeric(res$frac)), fp(as.numeric(res$p_binomial))), "",
  "## Módulos", "", "| Módulo | Seleção | Genes | g descoberta (p) | g replicação (p) | Mesmo sentido |", "|---|---|---:|---|---|---|",
  sprintf("| %s | %s | %d | %s (%s) | %s (%s) | %s |", mod$modulo, mod$selecao, mod$genes, f2(mod$g_descoberta), fp(mod$p_descoberta), f2(mod$g_replicacao), fp(mod$p_replicacao), ifelse(mod$mesmo_sentido, "sim", "não")), "",
  "## Vias (até 20 de menor p na descoberta)", "", "| Via | Nível | g descoberta (FDR) | g replicação (p) | Mesmo sentido |", "|---|---|---|---|---|",
  { v <- utils::head(via, 20); sprintf("| %s | %s | %s (%s) | %s (%s) | %s |", v$via, v$nivel, f2(v$g_descoberta), fp(v$fdr_descoberta), f2(v$g_replicacao), fp(v$p_replicacao), ifelse(v$mesmo_sentido, "sim", "não")) })
writeLines(linhas, file.path(pasta("docs"), "validacao_08b_replicacao_figado.md"), useBytes = TRUE)
gravar_docx(list(
  list(tipo = "p", texto = sprintf("Gerado em %s a partir de output/08_painel/replicacao_figado_*.csv.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
  list(tipo = "h2", texto = "1. Desenho"),
  list(tipo = "p", texto = sprintf("Decisão do usuário (09/10/2026, opção 2): o fígado é analisado em dois níveis. A descoberta é o %s (%d mulheres de 40–60 com DM2 e %d sem diabetes), tratado como análise principal de 1 estudo grande. O %s (%d e %d) discordava dele (correlação das vias −0,15) e, pela regra 'mesmo sentido em todos os estudos', vetava qualquer achado; ele passa a ser estudo de replicação, mostrado à parte. Ele também ajuda a construir a rede do fígado, que não usa o status de DM2.", desc, nd$F40a60_T2D, nd$F40a60_ND, repl, nr$F40a60_T2D, nr$F40a60_ND)),
  list(tipo = "h2", texto = "2. Resumo da replicação"),
  list(tipo = "tabela", df = data.frame(`Nível` = res$nivel, Testados = res$n, `Mesmo sentido` = res$concordantes, `Fração` = f2(as.numeric(res$frac)), `p (binomial)` = fp(as.numeric(res$p_binomial)), check.names = FALSE),
       nota = "Concordância de sentido entre descoberta e replicação; acaso = 50%. Com 3 × 4 mulheres na replicação, o p de cada item isolado diz pouco: o que conta é a concordância do conjunto."),
  list(tipo = "h2", texto = "3. Módulos"),
  list(tipo = "tabela", df = data.frame(`Módulo` = mod$modulo, `Seleção` = mod$selecao, Genes = mod$genes, `g descoberta (p)` = sprintf("%s (%s)", f2(mod$g_descoberta), fp(mod$p_descoberta)),
                                        `g replicação (p)` = sprintf("%s (%s)", f2(mod$g_replicacao), fp(mod$p_replicacao)), `Mesmo sentido` = ifelse(mod$mesmo_sentido, "sim", "não"), check.names = FALSE)),
  list(tipo = "h2", texto = "4. Vias (20 de menor p na descoberta)"),
  { v <- utils::head(via, 20); list(tipo = "tabela", df = data.frame(Via = v$via, `Nível` = v$nivel, `g descoberta (FDR)` = sprintf("%s (%s)", f2(v$g_descoberta), fp(v$fdr_descoberta)),
                                                                     `g replicação (p)` = sprintf("%s (%s)", f2(v$g_replicacao), fp(v$p_replicacao)), `Mesmo sentido` = ifelse(v$mesmo_sentido, "sim", "não"), check.names = FALSE)) },
  list(tipo = "h2", texto = "5. Arquivos"),
  list(tipo = "b", itens = c("Execução: run_08b_replicacao_figado.R; configuração: config/meta.yaml (so_sensibilidade: GSE15653, replicacao: true).", "Saídas: output/08_painel/replicacao_figado_{modulos, vias, genes, resumo}.csv."))),
  "docs/etapa_08b_replicacao_figado.docx", "Etapa 08b — Fígado em dois níveis: descoberta e replicação", etapa = "08")
