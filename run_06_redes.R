###############################################################################
#  run_06_redes.R - executa a ETAPA 06 (redes de coexpressão) e gera o relatório
#  Uso (a partir de workflow_dm_menopausa):
#     "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_06_redes.R [tecido ...]
#  Requer as etapas 04 e 05. Saídas: output/06_redes/<tecido>/..., docs/figuras/redes_modulos.png,
#  docs/validacao_06_redes.md, docs/etapa_06_redes.docx
###############################################################################
suppressPackageStartupMessages({ library(dplyr); library(WGCNA) })
for (f in c("R/00_utils.R", "R/05_meta.R", "R/06_redes.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
WGCNA::enableWGCNAThreads(8)
MC <- ler_config("config/meta.yaml"); RC <- ler_config("config/redes.yaml")
inv_all <- utils::read.csv("output/04_processamento/inventario.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
est_todos <- utils::read.csv("output/05_meta/estudos.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8"); est05 <- est_todos[est_todos$uso == "principal", ]
# estudos só de sensibilidade cujo problema é só o contraste (rede: true) podem construir a rede (revisão de 08/10/2026)
so_rede <- names(Filter(function(x) isTRUE(x$rede), MC$so_sensibilidade %||% list()))
est_rede <- rbind(est05, est_todos[est_todos$gse %in% so_rede, ])
codif <- genes_codificantes()
tecidos <- if (length(commandArgs(TRUE))) commandArgs(TRUE) else sort(unique(est05$tecido))
if (toupper(Sys.getenv("SO_RELATORIO", "FALSE")) %in% c("TRUE", "1")) tecidos <- character()   # só relatório e documento, sem reconstruir as redes
d0 <- pasta("output", "06_redes")

for (tec in tecidos) {
  t0 <- Sys.time(); d <- pasta(d0, tec)
  gs <- est05$gse[est05$tecido == tec]                                  # estudos do teste (análise principal)
  gr <- est_rede$gse[est_rede$tecido == tec]                            # estudos que podem construir a rede
  E <- lapply(gr, function(g) carregar_estudo(g, inv_all, NULL, codif)); names(E) <- gr
  constr <- gr[est_rede$doadores[match(gr, est_rede$gse)] >= RC$rede$min_doadores]
  if (!length(constr)) { log_msg("ETAPA 06 | %s: nenhum estudo com >= %d doadores; sem rede", tec, RC$rede$min_doadores); next }
  # 6.1 rede de consenso
  exr <- lapply(constr, function(g) dados_rede(RC, E[[g]])); names(exr) <- constr
  lote_tirado <- sapply(exr, function(x) isTRUE(attr(x, "lote_tirado")))
  genes <- genes_rede(exr, RC$rede$max_genes)
  multi <- lapply(exr, function(x) list(data = t(x[genes, , drop = FALSE])))
  # cache da rede e da preservação (revisão de 08/10/2026): reaproveitado só com a mesma assinatura
  ass <- assinatura_rede(RC, constr, genes, exr); arq_rc <- file.path(d, "rede_cache.rds")
  rc0 <- if (file.exists(arq_rc)) readRDS(arq_rc) else NULL
  if (!is.null(rc0) && identical(rc0$assinatura, ass)) {
    pw <- rc0$pw; cores <- rc0$cores; pres <- rc0$pres; pres_falhou <- rc0$pres_falhou
    log_msg("ETAPA 06 | %s: rede e preservação reaproveitadas do cache (mesma assinatura: estudos, genes, expressão e parâmetros)", tec)
  } else {
    pw <- escolher_potencia(RC, multi)
    cores <- construir_rede(RC, multi, pw$potencia)
    # 6.2 preservação
    pres_falhou <- FALSE
    pres <- tryCatch(preservacao(RC, multi, cores), error = function(e) { log_msg("ETAPA 06 | %s: preservação FALHOU (%s); módulos bloqueados", tec, conditionMessage(e)); pres_falhou <<- TRUE; NULL })
    saveRDS(list(assinatura = ass, pw = pw, cores = cores, pres = pres, pres_falhou = pres_falhou), arq_rc)
  }
  log_msg("ETAPA 06 | %s: %d estudos de construção, %d genes, potência %d (%s), %d módulos", tec, length(constr), length(genes), pw$potencia, pw$criterio, length(setdiff(unique(cores), 0)))
  # 6.3 teste nas mulheres de 40-60 (eigengenes; mesmo modelo da etapa 05)
  efs <- list()
  for (g in gs) {
    Eg <- eigengenes_estudo(E[[g]]$ex[, E[[g]]$am$coluna, drop = FALSE], cores)
    # revisão de 11/10/2026: falha ou modelo não estimável fica registrado (antes virava NULL em silêncio)
    r <- tryCatch(ajustar(MC, E[[g]], Y = Eg, metodo = "limma", so_alvo = identical(MC$modelo_principal, "so_F40a60")),
                  error = function(e) { log_msg("ETAPA 06 | %s, %s: ajuste dos eigengenes FALHOU (%s); estudo fora do teste dos módulos", tec, g, conditionMessage(e)); NULL })
    if (is.null(r)) log_msg("ETAPA 06 | %s, %s: sem teste dos módulos (falha ou modelo não estimável); a sanidade acusa ERRO", tec, g) else efs[[g]] <- r
  }
  m <- meta_tecido(efs, metodo = MC$meta_metodo)
  tam <- table(cores); m$genes <- as.integer(tam[sub("^M", "", m$id)])
  # revisão de código (08/10/2026): falha no cálculo não vira "preservado"
  if (!is.null(pres)) {
    # preservado = Zsummary >= 2 em estudos suficientes para que, com a referência, o módulo esteja em >= min_estudos (08/10/2026)
    zmin <- tapply(pres$Zsummary, pres$modulo, min); zmax <- tapply(pres$Zsummary, pres$modulo, max)
    npres <- tapply(pres$Zsummary >= RC$preservacao$zsummary_min, pres$modulo, sum)
    m$Zsummary_min <- unname(zmin[m$id]); m$Zsummary_max <- unname(zmax[m$id]); m$estudos_preservado <- 1L + as.integer(npres[m$id])
    m$preservado <- m$estudos_preservado >= RC$preservacao$min_estudos
    m$preservacao_status <- ifelse(m$preservado %in% TRUE, sprintf("preservado em %d de %d estudos", m$estudos_preservado, length(multi)), "não preservado")
  } else if (pres_falhou) { m$Zsummary_min <- NA; m$preservado <- FALSE; m$preservacao_status <- "cálculo falhou (bloqueado)"
  } else { m$Zsummary_min <- NA; m$preservado <- NA; m$preservacao_status <- "não avaliável (1 estudo de construção)" }
  m$p_expl <- p_exploratorio_tecido(m, length(gs), RC); m$rotulo_expl <- rotulo_exploratorio(length(gs), RC)   # 2 estudos: efeito fixo (08/10/2026)
  m <- selecionar_modulos(RC, m); m$rotulo_expl <- NULL
  # influência de cada estudo no efeito de cada módulo (08/10/2026)
  inf <- influencia(efs, m$id, metodo = MC$meta_metodo)
  # 6.4 genes-chave
  k <- kme_genes(multi, cores)
  efg <- lapply(gs, function(g) { f <- file.path("output/05_meta/estudos", g, "efeitos_genes.csv"); if (file.exists(f)) utils::read.csv(f, stringsAsFactors = FALSE)[, c("id", "g")] })
  names(efg) <- gs
  sel <- m[nzchar(m$selecao), ]
  chave <- do.call(rbind, lapply(seq_len(nrow(sel)), function(i) {
    x <- k[k$modulo == sel$id[i] & k$kME_2 >= RC$genes_chave$kme_min, ]   # kME alto em >= 2 estudos (08/10/2026)
    if (!nrow(x)) return(NULL)
    sinal <- sign(sel$g[i])
    G <- sapply(efg, function(e) e$g[match(x$gene, e$id)]); G <- matrix(G, nrow = nrow(x))
    mesmo <- rowSums(sign(G) == sinal, na.rm = TRUE); medidos <- rowSums(!is.na(G))
    # mesmo sentido do módulo em todos os estudos; para módulo "≥ 2 estudos", em pelo menos 2 (08/10/2026)
    x <- x[if (sel$selecao[i] == "exploratório (≥ 2 estudos)") mesmo >= 2 else (mesmo == medidos & medidos >= 1), ]
    if (nrow(x)) data.frame(tecido = tec, modulo = sel$id[i], selecao = sel$selecao[i], sentido_modulo = ifelse(sinal > 0, "maior no DM2", "menor no DM2"), x[, c("gene", "kME_min", "kME_2")], resposta_imediata = x$gene %in% unlist(MC$genes_resposta_imediata)) }))
  hubs <- sapply(m$id, function(id) { x <- k[k$modulo == id, ]; paste(utils::head(x$gene[order(-x$kME_2)], 5), collapse = ", ") })
  m$genes_centrais <- unname(hubs)
  # saídas
  escrever_csv(k, file.path(d, "modulos_genes.csv")); escrever_csv(m, file.path(d, "meta_modulos.csv"))
  escrever_csv(do.call(rbind, lapply(names(efs), function(g) data.frame(gse = g, efs[[g]]))), file.path(d, "efeitos_modulos_estudos.csv"))
  if (!is.null(pres)) escrever_csv(pres, file.path(d, "preservacao.csv"))
  escrever_csv(if (is.null(inf)) data.frame() else inf, file.path(d, "influencia_modulos.csv"))
  escrever_csv(if (is.null(chave)) data.frame() else chave, file.path(d, "genes_chave.csv"))
  escrever_csv(data.frame(tecido = tec, estudos_construcao = paste(constr, collapse = ";"), estudos_teste = paste(names(efs), collapse = ";"),
                          lote_retirado = paste(constr[lote_tirado], collapse = ";"), genes_rede = length(genes), potencia = pw$potencia, r2 = pw$r2, criterio_potencia = pw$criterio,
                          modulos = nrow(m), preservados = sum(m$preservado %in% TRUE), preservacao = paste(unique(m$preservacao_status), collapse = "; "), significativos = sum(m$selecao == "significativo"),
                          sugestivos = sum(m$selecao == "sugestivo"), exploratorios = sum(startsWith(m$selecao, "exploratório")), genes_chave = if (is.null(chave)) 0L else nrow(chave)),
               file.path(d, "resumo.csv"))
  log_msg("ETAPA 06 | %s: %d módulos (%d preservados); selecionados: %d significativos, %d sugestivos, %d exploratórios; %d genes-chave (%.1f min)", tec, nrow(m), sum(m$preservado %in% TRUE),
          sum(m$selecao == "significativo"), sum(m$selecao == "sugestivo"), sum(startsWith(m$selecao, "exploratório")), if (is.null(chave)) 0L else nrow(chave), as.numeric(difftime(Sys.time(), t0, units = "mins")))
}

# ---------------- relatório (todos os tecidos já processados) ----------------
le <- function(f) if (file.exists(f) && file.size(f) > 5) utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8") else NULL
tt <- sort(unique(est05$tecido)); tt <- tt[file.exists(file.path(d0, tt, "resumo.csv"))]
resumo <- rbind_preenche(lapply(tt, function(t) le(file.path(d0, t, "resumo.csv"))))
mods <- rbind_preenche(lapply(tt, function(t) { x <- le(file.path(d0, t, "meta_modulos.csv")); if (!is.null(x)) data.frame(tecido = t, x) }))
chv <- rbind_preenche(lapply(tt, function(t) le(file.path(d0, t, "genes_chave.csv"))))
mods$selecao[is.na(mods$selecao)] <- ""                                    # campo vazio relido do CSV vira NA (NA passava em nzchar)
infl <- rbind_preenche(lapply(tt, function(t) { x <- le(file.path(d0, t, "influencia_modulos.csv")); s <- mods$id[mods$tecido == t & nzchar(mods$selecao)]
  if (!is.null(x) && length(s)) data.frame(tecido = t, x[x$id %in% s, ]) }))
escrever_csv(resumo, file.path(d0, "resumo_tecidos.csv")); escrever_csv(mods, file.path(d0, "modulos_todos.csv"))
# figura: efeito do DM2 (g, IC 95%) em cada módulo, por tecido
pasta("docs", "figuras"); nl <- ceiling(length(tt) / 3)
grDevices::png("docs/figuras/redes_modulos.png", width = 1800, height = 650 * nl, res = 150)
op <- graphics::par(mfrow = c(nl, 3), mar = c(4, 5, 2.5, 1))
for (t in tt) { x <- mods[mods$tecido == t, ]; x <- x[order(x$g), ]; y <- seq_len(nrow(x))
  cor <- ifelse(x$selecao == "significativo", "#B03A2E", ifelse(x$selecao == "sugestivo", "#E59866", ifelse(startsWith(x$selecao, "exploratório"), "#5D6D7E", "grey65")))
  graphics::plot(x$g, y, xlim = range(c(x$ic_inf, x$ic_sup, 0), na.rm = TRUE), pch = 19, col = cor, yaxt = "n", xlab = "Efeito do DM2 no módulo (g)", ylab = "", main = t, cex.main = 1)
  graphics::segments(x$ic_inf, y, x$ic_sup, y, col = cor); graphics::abline(v = 0, lty = 3); graphics::axis(2, y, x$id, las = 1, cex.axis = 0.7) }
graphics::par(op); grDevices::dev.off()
fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
linhas <- c("# Validação da etapa 06: redes de coexpressão (WGCNA)", "", sprintf("Gerado em %s a partir de `output/06_redes/`.", format(Sys.time(), "%d/%m/%Y %H:%M")), "",
  "## 1. Redes por tecido", "", "| Tecido | Estudos que constroem | Lote retirado | Genes | Potência | Módulos | Preservados | Significativos | Sugestivos | Exploratórios | Genes-chave |",
  "|---|---|---|---:|---|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %s | %s | %d | %d (%s) | %d | %d | %d | %d | %d | %d |", resumo$tecido, resumo$estudos_construcao, ifelse(is.na(resumo$lote_retirado) | !nzchar(resumo$lote_retirado), "-", resumo$lote_retirado),
          resumo$genes_rede, resumo$potencia, resumo$criterio_potencia, resumo$modulos, resumo$preservados, resumo$significativos, resumo$sugestivos, resumo$exploratorios, resumo$genes_chave), "",
  "## 2. Módulos (efeito do DM2 nas mulheres de 40–60, Hartung-Knapp)", "",
  "Testes: Hartung-Knapp (principal); Stouffer ponderado (soma a evidência); rOP r = 2 (efeito em pelo menos 2 estudos, mesmo sentido nos 2 mais fortes); heterogeneidade (Cochran Q).", "",
  "| Tecido | Módulo | Genes | Preservação | g (IC 95%) | p HK | FDR HK | p Stouffer | p rOP (≥ 2) | FDR rOP | p heterog. | Mesmo sentido | Seleção | Genes centrais |", "|---|---|---:|---|---|---:|---:|---:|---:|---:|---:|---|---|---|",
  sprintf("| %s | %s | %d | %s | %.2f (%.2f a %.2f) | %s | %s | %s | %s | %s | %s | %d/%d | %s | %s |", mods$tecido, mods$id, mods$genes, mods$preservacao_status, mods$g, mods$ic_inf, mods$ic_sup,
          fp(mods$p), fp(mods$fdr), fp(mods$p_stouffer), fp(mods$p_rop2), fp(mods$fdr_rop2), fp(mods$p_heterogeneidade), mods$mesmo_sentido, mods$estudos, ifelse(nzchar(mods$selecao), mods$selecao, "-"), mods$genes_centrais), "",
  "Figura: `docs/figuras/redes_modulos.png`.", "",
  "### Influência de cada estudo nos módulos selecionados", "",
  if (!is.null(infl) && nrow(infl)) c("| Tecido | Módulo | Estudo | g do estudo | Peso (%) | g sem o estudo | p sem o estudo | Inverte sentido | Muda conclusão (p < 0,05) |", "|---|---|---|---:|---:|---:|---:|---|---|",
    sprintf("| %s | %s | %s | %.2f | %.1f | %.2f | %s | %s | %s |", infl$tecido, infl$id, infl$estudo, infl$g_estudo, infl$peso_pct, infl$g_sem, fp(infl$p_sem), ifelse(infl$inverte_sentido, "sim", "não"), ifelse(infl$muda_conclusao, "sim", "não"))) else "Nenhum módulo selecionado.", "",
  "## 3. Genes-chave dos módulos selecionados", "",
  if (!is.null(chv) && nrow(chv)) c(sprintf("%d genes-chave. Lista completa em `output/06_redes/<tecido>/genes_chave.csv`.", nrow(chv)), "", "| Tecido | Módulo | Seleção | Sentido | Genes (kME mín. ≥ 0,7) |", "|---|---|---|---|---|",
    unname(sapply(split(chv, paste(chv$tecido, chv$modulo)), function(x) sprintf("| %s | %s | %s | %s | %s |", x$tecido[1], x$modulo[1], x$selecao[1], x$sentido_modulo[1], paste(utils::head(x$gene[order(-x$kME_min)], 30), collapse = ", "))))) else "Nenhum módulo selecionado.", "",
  "Com 2 a 4 estudos por tecido, o Hartung-Knapp só dá p < 0,05 com efeitos grandes e muito consistentes; a coluna DerSimonian-Laird mostra o p menos conservador para comparação.")
writeLines(linhas, file.path(pasta("docs"), "validacao_06_redes.md"), useBytes = TRUE)
log_msg("ETAPA 06 | relatório de validação: docs/validacao_06_redes.md")
documentar_etapa_06(RC, resumo, mods, chv)
