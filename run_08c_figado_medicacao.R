###############################################################################
#  run_08c_figado_medicacao.R - fígado (GSE130991): efeito do DM2 separado do efeito dos remédios (pedido do usuário, 12/10/2026)
#  Uso: "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_08c_figado_medicacao.R
#  Contrastes nas mulheres de 40-60 (mesmo modelo da etapa 05; módulos da rede da etapa 06; vias com o escore competitivo
#  e a calibração contra conjuntos sorteados da etapa 07):
#   C0 principal: DM2 x sem diabetes (todas)
#   C1 DM2 SEM tratamento para diabetes x sem diabetes (DM2 definido só por HbA1c/glicemia): efeito da doença sem remédio de DM2
#   C2 sem estatina nos dois grupos: efeito do DM2 sem a estatina
#   C3 DM2 tratada x DM2 não tratada: assinatura do tratamento (misturada com a gravidade; só para marcar genes suspeitos)
#  Saídas: output/08_painel/figado_medicacao_*.csv, docs/validacao_08c_figado_medicacao.md, docs/etapa_08c_figado_medicacao.docx
###############################################################################
suppressPackageStartupMessages(library(WGCNA))
for (f in c("R/00_utils.R", "R/05_meta.R", "R/06_redes.R", "R/07_enriquecimento.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
MC <- ler_config("config/meta.yaml"); RC <- ler_config("config/redes.yaml")
inv_all <- utils::read.csv("output/04_processamento/inventario.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
lo <- utils::read.csv("output/02_metadados/amostras_longo.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
g <- "GSE130991"; d <- pasta("output", "08_painel"); so <- identical(MC$modelo_principal, "so_F40a60")
f2 <- function(x, k = 2) ifelse(is.na(x), "-", formatC(x, format = "f", digits = k, decimal.mark = ","))
fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
est <- carregar_estudo(g, inv_all, NULL, genes_codificantes())
cl <- function(k) { x <- lo[lo$gse == g & lo$campo == "carac" & lo$chave == k, ]; x$valor[match(est$am$gsm, x$gsm)] }
est$am$trat_dm <- !is.na(cl("diabetes treatment")); est$am$estatina <- cl("statin treatment") %in% "Statin"
est$am$hba1c <- suppressWarnings(as.numeric(cl("hba1c (%)"))); est$am$fpg <- suppressWarnings(as.numeric(cl("fasting blood glucose (mmol/l)"))); est$am$bmi <- suppressWarnings(as.numeric(cl("bmi")))
alvo <- est$am$mulher_40a60 %in% TRUE & est$am$status %in% c("T2D", "ND")
contrastes <- list(
  C0 = list(nome = "DM2 x sem diabetes (principal)", st = function(a) a$status),
  C1 = list(nome = "DM2 sem tratamento x sem diabetes", st = function(a) ifelse(a$status == "T2D" & a$trat_dm, NA, a$status)),
  C2 = list(nome = "DM2 sem estatina x sem diabetes sem estatina", st = function(a) ifelse(a$estatina, NA, a$status)),
  C3 = list(nome = "DM2 tratada x DM2 não tratada", st = function(a) ifelse(a$status == "T2D", ifelse(a$trat_dm, "T2D", "ND"), NA)),
  C3a = list(nome = "C3 ajustado por estatina, HbA1c, glicemia de jejum e IMC", st = function(a) ifelse(a$status == "T2D", ifelse(a$trat_dm, "T2D", "ND"), NA),
             cv = function(a) cbind(estatina = as.numeric(a$estatina), hba1c = a$hba1c, glicemia = a$fpg, imc = a$bmi)),
  C3b = list(nome = "C3 só em mulheres sem estatina", st = function(a) ifelse(a$estatina, NA, ifelse(a$status == "T2D", ifelse(a$trat_dm, "T2D", "ND"), NA))))
versao <- function(cx) { e <- est; e$am$status <- cx$st(est$am); e }       # as outras amostras do estudo mantêm o status (só entram fora do so_alvo)

# insumos comuns: eigengenes (rede da etapa 06), escores de via (etapa 07) e conjuntos sorteados (calibração)
cores <- readRDS("output/06_redes/figado/rede_cache.rds")$cores
Eg <- eigengenes_estudo(est$ex[, est$am$coluna, drop = FALSE], cores)
m06 <- utils::read.csv("output/06_redes/figado/meta_modulos.csv", stringsAsFactors = FALSE); m06$selecao[is.na(m06$selecao)] <- ""; sel06 <- m06$id[nzchar(m06$selecao)]
conj <- conjuntos_colecoes(RC); S <- lapply(conj, function(cj) escores_vias(est$ex, cj, MC$vias$min_genes))
tam_via <- lapply(conj, lengths)
B <- RC$enriquecimento$calibracao_sorteios %||% 2000; set.seed(RC$enriquecimento$calibracao_semente %||% 1)
tam <- sample(unlist(tam_via), B, replace = TRUE); rs <- stats::setNames(lapply(tam, function(k) sample(rownames(est$ex), min(k, nrow(est$ex)))), sprintf("ALEATORIO_%05d", seq_len(B)))
Snul <- escores_vias(est$ex, rs, MC$vias$min_genes)

res_g <- list(); res_m <- list(); res_v <- list(); resumo <- list()
for (k in names(contrastes)) {
  cx <- contrastes[[k]]; e <- versao(cx); a <- e$am[alvo & e$am$status %in% c("T2D", "ND"), ]
  cv <- if (!is.null(cx$cv)) cx$cv(est$am) else NULL
  gn <- ajustar(MC, e, so_alvo = so, covar = cv); md <- ajustar(MC, e, Y = Eg, metodo = "limma", so_alvo = so, covar = cv)
  gn$fdr <- stats::p.adjust(gn$p, "BH"); md$fdr <- stats::p.adjust(md$p, "BH")
  vi <- do.call(rbind, lapply(names(S), function(c0) { r <- ajustar(MC, e, Y = S[[c0]], metodo = "limma", so_alvo = so, covar = cv); r$colecao <- c0; r$tamanho <- unname(tam_via[[c0]][r$id]); r }))
  nu <- ajustar(MC, e, Y = Snul, metodo = "limma", so_alvo = so, covar = cv); nu$tamanho <- tam[match(nu$id, names(rs))]
  vi$p_parametrico <- vi$p; vi$p_empirico <- p_empirico(vi$p, vi$tamanho, nu$p, nu$tamanho); vi$p <- pmax(vi$p_parametrico, vi$p_empirico, na.rm = TRUE)
  vi$fdr <- stats::ave(vi$p, vi$colecao, FUN = function(z) stats::p.adjust(z, "BH"))
  res_g[[k]] <- data.frame(contraste = k, gn[, c("id", "g", "var_g", "p", "fdr", "n1", "n2")])
  res_m[[k]] <- data.frame(contraste = k, md[, c("id", "g", "var_g", "p", "fdr")], selecionado_etapa06 = md$id %in% sel06)
  res_v[[k]] <- data.frame(contraste = k, vi[, c("colecao", "id", "g", "p_parametrico", "p_empirico", "p", "fdr")])
  hb <- function(st) stats::median(a$hba1c[a$status == st], na.rm = TRUE)
  resumo[[k]] <- data.frame(contraste = k, descricao = cx$nome, n_T2D = gn$n1[1], n_ND = gn$n2[1], hba1c_T2D = hb("T2D"), hba1c_ND = hb("ND"),
    estatina_T2D = sum(a$estatina[a$status == "T2D"]), estatina_ND = sum(a$estatina[a$status == "ND"]),
    genes_fdr05 = sum(gn$fdr < 0.05), genes_p05 = round(mean(gn$p < 0.05), 3), sorteados_p05 = round(mean(nu$p_parametrico %||% nu$p < 0.05), 3),
    vias_fdr10 = sum(vi$fdr < 0.10), vias_p05 = sum(vi$p < 0.05),
    M6_g = md$g[md$id == "M6"], M6_p = md$p[md$id == "M6"], M15_g = md$g[md$id == "M15"], M15_p = md$p[md$id == "M15"],
    colesterol_g = vi$g[vi$id == "HALLMARK_CHOLESTEROL_HOMEOSTASIS"], colesterol_p = vi$p[vi$id == "HALLMARK_CHOLESTEROL_HOMEOSTASIS"])
  log_msg("ETAPA 08c | %s (%s): %d x %d; genes FDR<0,05 %d; M6 g %.2f (p %.3g); M15 g %.2f (p %.3g); vias FDR<0,10 %d", k, cx$nome, gn$n1[1], gn$n2[1],
          resumo[[k]]$genes_fdr05, resumo[[k]]$M6_g, resumo[[k]]$M6_p, resumo[[k]]$M15_g, resumo[[k]]$M15_p, resumo[[k]]$vias_fdr10)
}
G <- do.call(rbind, res_g); M <- do.call(rbind, res_m); V <- do.call(rbind, res_v); R <- do.call(rbind, resumo)
# comparação com o principal: correlação dos g e quanto do sinal principal sobrevive sem remédio
gw <- stats::reshape(G[, c("contraste", "id", "g")], idvar = "id", timevar = "contraste", direction = "wide")
top <- G$id[G$contraste == "C0" & G$fdr < 0.05]
cmp <- do.call(rbind, lapply(c("C1", "C2", "C3"), function(k) { x <- G[G$contraste == k, ]; t0 <- G[G$contraste == "C0", ]; i <- match(top, x$id); j <- match(top, t0$id)
  data.frame(contraste = k, cor_g_todos = round(stats::cor(gw[[paste0("g.", k)]], gw$g.C0, use = "complete.obs"), 2),
             genes_principais = length(top), mesmo_sentido = sum(sign(x$g[i]) == sign(t0$g[j]), na.rm = TRUE), p05_mesmo_sentido = sum(sign(x$g[i]) == sign(t0$g[j]) & x$p[i] < 0.05, na.rm = TRUE),
             razao_g_mediana = round(stats::median(x$g[i] / t0$g[j], na.rm = TRUE), 2)) }))
# genes do sinal principal que também mudam com o tratamento (C3) no mesmo sentido: suspeitos de efeito do remédio
c3 <- G[G$contraste == "C3", ]; c0 <- G[G$contraste == "C0", ]; c1 <- G[G$contraste == "C1", ]
susp <- data.frame(id = top, g_principal = c0$g[match(top, c0$id)], g_sem_tratamento = c1$g[match(top, c1$id)], p_sem_tratamento = c1$p[match(top, c1$id)],
                   g_tratamento = c3$g[match(top, c3$id)], p_tratamento = c3$p[match(top, c3$id)])
susp$classe <- ifelse(susp$p_sem_tratamento < 0.05 & sign(susp$g_sem_tratamento) == sign(susp$g_principal), "mantém-se sem remédio de DM2",
               ifelse(susp$p_tratamento < 0.05 & sign(susp$g_tratamento) == sign(susp$g_principal), "suspeito de efeito do tratamento", "indefinido (perde força sem tratadas)"))
# o módulo acompanha a HbA1c dentro dos grupos? (gravidade glicêmica x tratamento)
kk <- list(`DM2 não tratadas + sem diabetes` = alvo & ((est$am$status == "T2D" & !est$am$trat_dm) | est$am$status == "ND"), `DM2 tratadas` = alvo & est$am$status == "T2D" & est$am$trat_dm)
corhb <- do.call(rbind, lapply(names(kk), function(n) do.call(rbind, lapply(sel06, function(m) { ct <- suppressWarnings(stats::cor.test(Eg[m, est$am$coluna[kk[[n]]]], est$am$hba1c[kk[[n]]], method = "spearman"))
  data.frame(grupo = n, modulo = m, rho = round(unname(ct$estimate), 2), p = signif(ct$p.value, 2), n = sum(kk[[n]] & !is.na(est$am$hba1c))) }))))
escrever_csv(corhb, file.path(d, "figado_medicacao_modulo_hba1c.csv"))
escrever_csv(R, file.path(d, "figado_medicacao_resumo.csv")); escrever_csv(cmp, file.path(d, "figado_medicacao_comparacao.csv"))
escrever_csv(G, file.path(d, "figado_medicacao_genes.csv")); escrever_csv(M, file.path(d, "figado_medicacao_modulos.csv")); escrever_csv(V, file.path(d, "figado_medicacao_vias.csv"))
escrever_csv(susp, file.path(d, "figado_medicacao_genes_principais.csv"))
vt <- function(k, n = 8) { x <- V[V$contraste == k & V$colecao == "Hallmark", ]; x <- x[order(x$p), ]; utils::head(x, n) }
print(R); print(cmp); print(table(susp$classe))

blocos <- list(
  list(tipo = "p", texto = sprintf("Gerado em %s. Pedido do usuário (12/10/2026): separar, no fígado, o efeito do DM2 do efeito dos remédios.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
  list(tipo = "h2", texto = "1. Por que"),
  list(tipo = "p", texto = "No GSE130991, 123 das 146 mulheres de 40–60 com DM2 estão em tratamento para diabetes e 58 usam estatina (contra 4 das 58 sem diabetes). Remédio e doença andam juntos: parte do 'efeito do DM2' pode ser efeito do remédio (a estatina já explicava metade do sinal do colesterol). O GEO informa, por paciente, se há tratamento para diabetes (sem a classe do remédio) e se há estatina (com o nome)."),
  list(tipo = "b", itens = c("C1 — DM2 sem tratamento × sem diabetes: o contraste mais limpo do efeito da doença sem remédio de diabetes (DM2 definido por HbA1c ≥ 6,5% ou glicemia de jejum ≥ 7,0 mmol/L).",
                             "C2 — sem estatina nos dois grupos.",
                             "C3 — DM2 tratada × DM2 não tratada: assinatura do tratamento, misturada com a gravidade (as tratadas têm HbA1c maior); usada só para marcar genes suspeitos.",
                             "Mesmo modelo da etapa 05, módulos da rede da etapa 06 e vias com o escore competitivo e a calibração contra 2.000 conjuntos sorteados da etapa 07.")),
  list(tipo = "h2", texto = "2. Resultados"),
  list(tipo = "tabela", df = data.frame(Contraste = R$descricao, `DM2/ND` = sprintf("%d/%d", R$n_T2D, R$n_ND), `HbA1c mediana DM2/ND` = sprintf("%s/%s", f2(R$hba1c_T2D, 1), f2(R$hba1c_ND, 1)),
                                        `Estatina DM2/ND` = sprintf("%d/%d", R$estatina_T2D, R$estatina_ND), `Genes FDR < 0,05` = R$genes_fdr05, `Vias FDR < 0,10` = R$vias_fdr10,
                                        `M6 g (p)` = sprintf("%s (%s)", f2(R$M6_g), fp(R$M6_p)), `M15 g (p)` = sprintf("%s (%s)", f2(R$M15_g), fp(R$M15_p)),
                                        `Colesterol g (p)` = sprintf("%s (%s)", f2(R$colesterol_g), fp(R$colesterol_p)), check.names = FALSE),
       nota = "g = efeito padronizado (o grupo citado primeiro menos o segundo). p das vias calibrado contra conjuntos sorteados. Com N menor (C1, C2), menos genes passam no FDR mesmo que o efeito se mantenha: comparar os g."),
  list(tipo = "tabela", df = data.frame(Contraste = cmp$contraste, `Correlação dos g com o principal (todos os genes)` = f2(cmp$cor_g_todos), `Genes FDR < 0,05 no principal` = cmp$genes_principais,
                                        `Mesmo sentido` = cmp$mesmo_sentido, `Mesmo sentido e p < 0,05` = cmp$p05_mesmo_sentido, `g / g principal (mediana)` = f2(cmp$razao_g_mediana), check.names = FALSE)),
  list(tipo = "tabela", df = as.data.frame(table(Classe = susp$classe)), nota = "Os genes com FDR < 0,05 no principal, classificados pelo que acontece sem remédio de DM2 (C1) e com o tratamento (C3)."),
  list(tipo = "tabela", df = data.frame(Grupo = corhb$grupo, `Módulo` = corhb$modulo, `rho com a HbA1c` = f2(corhb$rho), p = fp(corhb$p), n = corhb$n, check.names = FALSE),
       nota = "Se o módulo fosse gravidade glicêmica, acompanharia a HbA1c dentro dos grupos."),
  list(tipo = "h3", texto = "Leitura"),
  list(tipo = "b", itens = c("Sem estatina (C2) o sinal principal se mantém (módulos e genes); a estatina explica parte da via do colesterol, não os módulos.",
                             "Nas mulheres com DM2 sem tratamento (C1, DM2 só por exame, mais leve), os módulos M6 e M15 e a via do colesterol não diferem das sem diabetes, e o excesso global de p < 0,05 desaparece (igual ao acaso).",
                             "Entre as mulheres com DM2, as tratadas têm M6 e colesterol maiores que as não tratadas, e isso se mantém ajustando por estatina, HbA1c, glicemia e IMC (C3a) e só entre mulheres sem estatina (C3b); o M6 não acompanha a HbA1c dentro dos grupos.",
                             "Conclusão: o sinal do fígado no GSE130991 é, em grande parte, de DM2 TRATADA (remédio para diabetes ou algo ligado a ele, como mais tempo de doença), não da doença em si. O GEO não informa a classe do remédio (metformina, insulina etc.) nem o tempo de diabetes; com só 23 mulheres sem tratamento, um efeito pequeno da doença não pode ser descartado.")),
  list(tipo = "h3", texto = "Vias Hallmark mais fortes em cada contraste"),
  list(tipo = "tabela", df = do.call(rbind, lapply(names(contrastes), function(k) { x <- vt(k, 6); data.frame(Contraste = k, Via = sub("HALLMARK_", "", x$id), g = f2(x$g), `p calibrado` = fp(x$p), FDR = fp(x$fdr), check.names = FALSE) }))),
  list(tipo = "h2", texto = "3. Medicação nos estudos do workflow (artigos e GEO)"),
  list(tipo = "p", texto = "Revisão de 12/10/2026 dos artigos (texto completo no Europe PMC, quando aberto) e dos campos do GEO. A informação por pessoa só existe no GSE130991 e no GSE18732; nos demais, quando há, é por grupo ou ausente."),
  list(tipo = "tabela", df = { mz <- utils::read.csv("input/medicacao_estudos.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
    data.frame(Estudo = mz$gse, Tecido = mz$tecido, `Por pessoa` = mz$medicacao_por_pessoa, `No artigo` = mz$medicacao_no_artigo, `Implicação` = mz$implicacao, Fonte = mz$fonte, check.names = FALSE) }),
  list(tipo = "h2", texto = "4. Arquivos"),
  list(tipo = "b", itens = c("Execução: run_08c_figado_medicacao.R.", "Saídas: output/08_painel/figado_medicacao_{resumo, comparacao, genes, modulos, vias, genes_principais, modulo_hba1c}.csv; tabela de medicação curada: input/medicacao_estudos.csv.")))
gravar_docx(blocos, "docs/etapa_08c_figado_medicacao.docx", "Etapa 08c — Fígado: efeito do DM2 separado do efeito dos remédios (GSE130991)", etapa = "08")
writeLines(c("# Etapa 08c: fígado, DM2 x remédios (GSE130991)", "", utils::capture.output(print(R)), "", utils::capture.output(print(cmp)), "", utils::capture.output(print(table(susp$classe)))),
           "docs/validacao_08c_figado_medicacao.md", useBytes = TRUE)
