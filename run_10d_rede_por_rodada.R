###############################################################################
#  run_10d_rede_por_rodada.R - ETAPA 10d: curva ROC com a REDE refeita em cada rodada (revisão de 11/10/2026)
#  Uso: "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_10d_rede_por_rodada.R [tecido ...]
#  Na etapa 10 a rede da etapa 06 é construída uma vez, com todos os estudos de construção; o estudo testado (ou o
#  estudo externo GSE156993/GSE15653) pode ter ajudado a definir os módulos. A rede não usa o status de DM2 (não há
#  vazamento de rótulo), mas a avaliação fica condicionada a essa rede. Aqui, em cada rodada, a rede é refeita SÓ com
#  os estudos (ou, no fígado, as mulheres) de treino; o módulo, os genes e o escore seguem a mesma regra da etapa 10.
#  Saídas: output/10_roc/rede_por_rodada*.csv, docs/validacao_10d_rede_por_rodada.md, docs/etapa_10d_rede_por_rodada.docx
#  Cache das redes por rodada: D:/dm_jana_cache/menopausa/rede_por_rodada/ (chave = assinatura dos dados e parâmetros)
###############################################################################
suppressPackageStartupMessages(library(WGCNA))
for (f in c("R/00_utils.R", "R/05_meta.R", "R/06_redes.R", "R/10_roc.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
WGCNA::enableWGCNAThreads(8)
MC <- ler_config("config/meta.yaml"); RC <- ler_config("config/redes.yaml"); OC <- ler_config("config/roc.yaml")
inv_all <- utils::read.csv("output/04_processamento/inventario.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
est_todos <- utils::read.csv("output/05_meta/estudos.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8"); est05 <- est_todos[est_todos$uso == "principal", ]
so_rede <- names(Filter(function(x) isTRUE(x$rede), MC$so_sensibilidade %||% list())); est_rede <- rbind(est05, est_todos[est_todos$gse %in% so_rede, ])
codif <- if (isTRUE(MC$so_codificantes)) genes_codificantes() else NULL
d <- pasta("output", "10_roc"); dc <- pasta(file.path(Sys.getenv("CACHE_MENOPAUSA", "D:/dm_jana_cache/menopausa"), "rede_por_rodada"))
le <- function(f) if (file.exists(f) && file.size(f) > 5) utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8") else NULL
f2 <- function(x, k = 2) ifelse(is.na(x), "-", formatC(x, format = "f", digits = k, decimal.mark = ","))
fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
so <- identical(MC$modelo_principal, "so_F40a60")

# rede só com os estudos (objetos de carregar_estudo, já recortados) de construção da rodada; cache pela assinatura
rede_rodada <- function(Econ, rotulo) {
  exr <- lapply(Econ, function(e) dados_rede(RC, e)); genes <- genes_rede(exr, RC$rede$max_genes)
  ass <- assinatura_rede(RC, names(Econ), genes, exr); arq <- file.path(dc, paste0(rotulo, ".rds"))
  if (file.exists(arq)) { x <- readRDS(arq); if (identical(x$assinatura, ass)) return(x) }
  multi <- lapply(exr, function(x) list(data = t(x[genes, , drop = FALSE]))); pw <- escolher_potencia(RC, multi)
  cores <- construir_rede(RC, multi, pw$potencia); x <- list(assinatura = ass, cores = cores, potencia = pw$potencia)
  saveRDS(x, arq); log_msg("ETAPA 10d | rede %s: %d estudos, potência %d, %d módulos", rotulo, length(Econ), pw$potencia, length(setdiff(unique(cores), 0))); x
}
efm_estudos <- function(E, gs, cores) do.call(rbind, lapply(gs, function(g) {           # efeito do DM2 nos eigengenes da rede da rodada
  Eg <- eigengenes_estudo(E[[g]]$ex[, E[[g]]$am$coluna, drop = FALSE], cores)
  r <- tryCatch(ajustar(MC, E[[g]], Y = Eg, metodo = "limma", so_alvo = so), error = function(e) { log_msg("ETAPA 10d | %s: ajuste dos eigengenes FALHOU (%s)", g, conditionMessage(e)); NULL })
  if (!is.null(r)) data.frame(gse = g, r) }))
# módulo da rodada mais parecido com um módulo selecionado na etapa 06 (Jaccard dos genes)
parecido <- function(genes_mod, cores06, sel06) {
  if (!length(sel06)) return(c(NA, NA))
  j <- vapply(sel06, function(m) { g6 <- names(cores06)[paste0("M", cores06) == m]; length(intersect(genes_mod, g6)) / length(union(genes_mod, g6)) }, 0)
  c(names(which.max(j)), round(max(j), 2)) }

tecs <- if (length(commandArgs(TRUE))) commandArgs(TRUE) else unlist(OC$tecidos)
linhas <- list()
for (tec in tecs) {
  gs <- est05$gse[est05$tecido == tec]; gr <- est_rede$gse[est_rede$tecido == tec]
  constr <- gr[est_rede$doadores[match(gr, est_rede$gse)] >= RC$rede$min_doadores]
  E <- lapply(stats::setNames(gr, gr), function(g) carregar_estudo(g, inv_all, NULL, codif))
  efg <- lapply(stats::setNames(gs, gs), function(g) le(file.path("output/05_meta/estudos", g, "efeitos_genes.csv")))
  c06 <- readRDS(file.path("output/06_redes", tec, "rede_cache.rds"))$cores
  m06 <- le(file.path("output/06_redes", tec, "meta_modulos.csv")); m06$selecao[is.na(m06$selecao)] <- ""; sel06 <- m06$id[nzchar(m06$selecao)]
  orig <- le(file.path(d, "deixar_um_de_fora.csv")); ext0 <- le(file.path(d, "validacao_externa.csv"))
  registra <- function(tipo, s, treino, con, pr, cores, r, auc_original) {
    gm <- names(cores)[paste0("M", cores) == pr$modulo]; pa <- parecido(gm, c06, sel06)
    linhas[[length(linhas) + 1]] <<- data.frame(tecido = tec, tipo = tipo, estudo_testado = s, treino = paste(treino, collapse = ";"), construcao_rede = paste(con, collapse = ";"),
      modulos_rede = length(setdiff(unique(cores), 0)), modulo = pr$modulo, genes_modulo = length(gm), parecido_etapa06 = pa[1], jaccard_etapa06 = as.numeric(pa[2]),
      genes = if (is.null(r)) 0 else r$genes_medidos, n_T2D = if (is.null(r)) NA else r$n_T2D, n_ND = if (is.null(r)) NA else r$n_ND,
      auc = if (is.null(r)) NA else round(r$auc, 3), ic_inf = if (is.null(r)) NA else round(r$ic_inf, 3), ic_sup = if (is.null(r)) NA else round(r$ic_sup, 3),
      p_wilcoxon = if (is.null(r)) NA else signif(r$p_wilcoxon, 3), auc_rede_unica = auc_original)
    log_msg("ETAPA 10d | %s, %s %s: rede de %s; módulo %s (%d genes; parecido com %s da etapa 06, Jaccard %s); AUC %s (rede única: %s)", tec, tipo, s, paste(con, collapse = "+"),
            pr$modulo, length(gm), pa[1], pa[2], f2(linhas[[length(linhas)]]$auc), f2(auc_original)) }
  if (length(gs) >= 2) {
    # deixar um estudo de fora, com a rede sem o estudo testado
    for (s in gs) {
      treino <- setdiff(gs, s); con <- setdiff(constr, s)
      if (!length(con)) { log_msg("ETAPA 10d | %s, %s: nenhum estudo de construção sem o testado", tec, s); next }
      rr <- rede_rodada(E[con], sprintf("%s_sem_%s", tec, s)); efm <- efm_estudos(E, treino, rr$cores)
      pr <- escolher_programa(OC, tec, treino, rr$cores, efm, efg); r <- escore_auc(E[[s]], pr$genes, pr$sentido)
      registra("deixar um estudo de fora", s, treino, con, pr, rr$cores, r, orig$auc[orig$tecido == tec & orig$estudo_testado == s][1])
    }
  } else {
    # 1 estudo (fígado): validação cruzada (1ª repetição da etapa 10) com a rede refeita só com as mulheres de treino
    g1 <- gs; a <- alvo_cv(E[[g1]]); f <- dobras_estratificadas(a$status, OC$validacao_cruzada$dobras, OC$semente); esc <- list(); vp <- le(file.path(d, "validacao_cruzada_repeticoes.csv"))
    for (k in seq_len(OC$validacao_cruzada$dobras)) {
      fora <- a$coluna[f == k]; et <- E[[g1]]; et$am <- et$am[!et$am$coluna %in% fora, ]
      rr <- rede_rodada(stats::setNames(list(et), g1), sprintf("%s_%s_parte%d", tec, g1, k))
      Eg <- eigengenes_estudo(E[[g1]]$ex[, E[[g1]]$am$coluna, drop = FALSE], rr$cores); aj <- ajuste_treino(MC, E[[g1]], Eg, fora); pr <- selecao_estudo(aj, rr$cores, OC)
      r <- escore_auc(parte(E[[g1]], fora), pr$genes, pr$sentido); esc[[k]] <- r$escore
      registra("validação cruzada (parte)", sprintf("%s parte %d", g1, k), sprintf("%s sem a parte %d", g1, k), sprintf("%s sem a parte %d", g1, k), pr, rr$cores, r, NA)
    }
    ar <- auc_reunida(do.call(rbind, esc))
    linhas[[length(linhas) + 1]] <- data.frame(tecido = tec, tipo = "validação cruzada (partes reunidas)", estudo_testado = g1, treino = "partes de treino", construcao_rede = "partes de treino", modulos_rede = NA,
      modulo = NA, genes_modulo = NA, parecido_etapa06 = NA, jaccard_etapa06 = NA, genes = NA, n_T2D = ar$n_T2D, n_ND = ar$n_ND, auc = round(ar$auc, 3), ic_inf = round(ar$ic_inf, 3), ic_sup = round(ar$ic_sup, 3),
      p_wilcoxon = signif(ar$p_wilcoxon, 3), auc_rede_unica = vp$auc[vp$tecido == tec & vp$repeticao == 1][1])
    log_msg("ETAPA 10d | %s: validação cruzada com rede por parte: AUC %.2f (rede única, mesma divisão: %s)", tec, ar$auc, f2(linhas[[length(linhas)]]$auc_rede_unica))
  }
  # externos: rede sem o estudo externo (só os estudos principais de construção)
  for (s in unlist(OC$externos[[tec]])) {
    con <- setdiff(intersect(constr, gs), s); if (!length(con)) next
    rr <- rede_rodada(E[con], sprintf("%s_principais", tec)); efm <- efm_estudos(E, gs, rr$cores)
    pr <- if (length(gs) >= 2) escolher_programa(OC, tec, gs, rr$cores, efm, efg) else { aj <- list(genes = efg[[gs]], mods = efm[efm$gse == gs, ]); selecao_estudo(aj, rr$cores, OC) }
    ee <- carregar_estudo(s, inv_all, NULL, codif); r <- escore_auc(ee, pr$genes, pr$sentido); if (!is.null(r) && r$genes_medidos < OC$min_genes_teste) r <- NULL
    registra("externo", s, gs, con, pr, rr$cores, r, ext0$auc[ext0$tecido == tec & ext0$estudo == s][1])
  }
}
x <- do.call(rbind, linhas)
lo <- x[x$tipo == "deixar um estudo de fora" & !is.na(x$auc), ]
met <- do.call(rbind, lapply(split(lo, lo$tecido), function(z) {
  A <- pmin(pmax(z$auc, 0.5 / (z$n_T2D * z$n_ND)), 1 - 0.5 / (z$n_T2D * z$n_ND)); G <- matrix(stats::qlogis(A), 1); rownames(G) <- "AUC"
  V <- matrix((ep_auc(z$auc, z$n_T2D, z$n_ND) / (A * (1 - A)))^2, 1); m <- meta_dl(G, V, matrix(pmin(1, 2 * z$p_wilcoxon), 1), "hk", matrix(z$n_T2D + z$n_ND, 1))
  o <- le(file.path(d, "meta_auc.csv"))
  data.frame(tecido = z$tecido[1], estudos = nrow(z), auc = round(stats::plogis(m$g), 3), ic_inf = round(stats::plogis(m$ic_inf), 3), ic_sup = round(stats::plogis(m$ic_sup), 3), p = signif(m$p, 3),
             auc_rede_unica = o$auc_combinada[o$tecido == z$tecido[1]][1], parecidos_com_selecionado = sprintf("%d/%d", sum(z$jaccard_etapa06 >= 0.3, na.rm = TRUE), nrow(z))) }))
escrever_csv(x, file.path(d, "rede_por_rodada.csv")); escrever_csv(met, file.path(d, "rede_por_rodada_meta.csv"))

linhas_md <- c("# Validação da etapa 10d: ROC com a rede refeita em cada rodada", "", sprintf("Gerado em %s.", format(Sys.time(), "%d/%m/%Y %H:%M")), "",
  "Em cada rodada, a rede de coexpressão é refeita sem o estudo (ou a parte) testado e sem o estudo externo; o módulo e os genes seguem a regra da etapa 10.", "",
  "| Tecido | Tipo | Testado | Rede construída com | Módulo (genes) | Parecido com (etapa 06; Jaccard) | AUC (IC 95%) | AUC com a rede única |", "|---|---|---|---|---|---|---|---:|",
  sprintf("| %s | %s | %s | %s | %s (%s) | %s (%s) | %s (%s a %s) | %s |", x$tecido, x$tipo, x$estudo_testado, x$construcao_rede, x$modulo, x$genes_modulo, x$parecido_etapa06, f2(x$jaccard_etapa06),
          f2(x$auc), f2(x$ic_inf), f2(x$ic_sup), f2(x$auc_rede_unica)), "",
  "| Tecido | AUC combinada com rede por rodada (IC 95%) | p | AUC combinada com a rede única | Rodadas com módulo parecido (Jaccard >= 0,3) com um selecionado |", "|---|---|---:|---:|---|",
  sprintf("| %s | %s (%s a %s) | %s | %s | %s |", met$tecido, f2(met$auc), f2(met$ic_inf), f2(met$ic_sup), fp(met$p), f2(met$auc_rede_unica), met$parecidos_com_selecionado))
writeLines(linhas_md, file.path(pasta("docs"), "validacao_10d_rede_por_rodada.md"), useBytes = TRUE)
gravar_docx(Filter(Negate(is.null), list(
  list(tipo = "p", texto = sprintf("Gerado em %s a partir de output/10_roc/rede_por_rodada*.csv.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
  list(tipo = "h2", texto = "1. Por que esta etapa"),
  list(tipo = "p", texto = "Revisão de 11/10/2026: na etapa 10 a rede de coexpressão (etapa 06) é construída uma vez, com todos os estudos de construção, e reaproveitada em todas as rodadas. O estudo testado, e os estudos externos GSE156993 (sangue) e GSE15653 (fígado), podem ter ajudado a definir quais módulos existem. A rede não usa o status de DM2, então não há vazamento de rótulo, mas a avaliação da etapa 10 é condicionada a essa rede (transdutiva), não uma validação totalmente independente. Aqui a rede é refeita em cada rodada só com o treino."),
  list(tipo = "b", itens = c("Deixar um estudo de fora (ilhotas, músculo, sangue): rede com os estudos de construção menos o testado; com 1 estudo restante, rede de 1 estudo (sem consenso).",
                             "Fígado: validação cruzada (mesma divisão da 1ª repetição da etapa 10), com a rede refeita só com as mulheres de treino do GSE130991 (as outras amostras do estudo entram; as da parte testada não).",
                             "Externos: rede só com os estudos principais de construção (sem o externo).",
                             "Módulo, genes e escore: mesma regra da etapa 10. 'Parecido com': módulo selecionado na etapa 06 com mais genes em comum (Jaccard).")),
  list(tipo = "h2", texto = "2. Rodadas"),
  list(tipo = "tabela", df = data.frame(Tecido = x$tecido, Tipo = x$tipo, Testado = x$estudo_testado, `Rede com` = x$construcao_rede, `Módulo (genes)` = ifelse(is.na(x$modulo), "-", sprintf("%s (%s)", x$modulo, x$genes_modulo)),
                                        `Parecido (Jaccard)` = ifelse(is.na(x$parecido_etapa06), "-", sprintf("%s (%s)", x$parecido_etapa06, f2(x$jaccard_etapa06))), `AUC (IC 95%)` = sprintf("%s (%s a %s)", f2(x$auc), f2(x$ic_inf), f2(x$ic_sup)),
                                        `AUC rede única` = f2(x$auc_rede_unica), check.names = FALSE)),
  list(tipo = "h2", texto = "3. AUC combinada"),
  list(tipo = "tabela", df = data.frame(Tecido = met$tecido, `Rede por rodada (IC 95%)` = sprintf("%s (%s a %s)", f2(met$auc), f2(met$ic_inf), f2(met$ic_sup)), p = fp(met$p), `Rede única` = f2(met$auc_rede_unica),
                                        `Módulo parecido com o selecionado` = met$parecidos_com_selecionado, check.names = FALSE)),
  list(tipo = "h2", texto = "4. Arquivos"),
  list(tipo = "b", itens = c("Execução: run_10d_rede_por_rodada.R (funções de R/06_redes.R e R/10_roc.R).", "Saídas: output/10_roc/rede_por_rodada.csv e rede_por_rodada_meta.csv; validação docs/validacao_10d_rede_por_rodada.md; cache das redes em D:/dm_jana_cache/menopausa/rede_por_rodada/.")))),
  "docs/etapa_10d_rede_por_rodada.docx", "Etapa 10d — Curva ROC com a rede refeita em cada rodada", etapa = "10")
