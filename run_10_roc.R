###############################################################################
#  run_10_roc.R - ETAPA 10: curva ROC dos programas (deixar um estudo de fora + validação externa)
#  Uso: "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_10_roc.R
#  Requer as etapas 04 a 08. Saídas: output/10_roc/*.csv, docs/figuras/roc_programas.png,
#  docs/validacao_10_roc.md, docs/etapa_10_roc.docx
###############################################################################
for (f in c("R/00_utils.R", "R/05_meta.R", "R/06_redes.R", "R/10_roc.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
MC <- ler_config("config/meta.yaml"); OC <- ler_config("config/roc.yaml")
inv_all <- utils::read.csv("output/04_processamento/inventario.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
est05 <- utils::read.csv("output/05_meta/estudos.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
codif <- if (isTRUE(MC$so_codificantes)) genes_codificantes() else NULL
d <- pasta("output", "10_roc"); pasta("docs", "figuras")
le <- function(f) if (file.exists(f) && file.size(f) > 5) utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8") else NULL
f2 <- function(x, k = 2) ifelse(is.na(x), "-", formatC(x, format = "f", digits = k, decimal.mark = ","))
fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
modulo_etapa06 <- function(tec) { m <- le(file.path("output/06_redes", tec, "meta_modulos.csv")); m$selecao[is.na(m$selecao)] <- ""; m$id[nzchar(m$selecao)] }

dobras <- list(); externa <- list(); circular <- list(); curvas <- list(); metas <- list(); dobras_cv <- list(); repet_cv <- list(); nulo_cv <- list()
for (tec in unlist(OC$tecidos)) {
  gs <- est05$gse[est05$tecido == tec & est05$uso == "principal"]
  cores <- readRDS(file.path("output/06_redes", tec, "rede_cache.rds"))$cores
  efm <- le(file.path("output/06_redes", tec, "efeitos_modulos_estudos.csv"))
  efg <- lapply(stats::setNames(gs, gs), function(g) le(file.path("output/05_meta/estudos", g, "efeitos_genes.csv")))
  E <- lapply(stats::setNames(gs, gs), function(g) carregar_estudo(g, inv_all, NULL, codif))
  mod06 <- modulo_etapa06(tec)
  # 10.1 deixar um estudo de fora
  for (s in if (length(gs) >= 2) gs else character()) {               # 1 estudo (fígado): só validação externa (09/10/2026)
    treino <- setdiff(gs, s); pr <- escolher_programa(OC, tec, treino, cores, efm[efm$gse %in% treino, ], efg)
    r <- escore_auc(E[[s]], pr$genes, pr$sentido)
    if (is.null(r) || r$genes_medidos < OC$min_genes_teste) { dobras[[length(dobras) + 1]] <- data.frame(tecido = tec, estudo_testado = s, treino = paste(treino, collapse = ";"), modulo = pr$modulo,
      modulo_igual_etapa06 = pr$modulo %in% mod06, genes = length(pr$genes), genes_medidos = if (is.null(r)) 0 else r$genes_medidos, auc = NA, nota = "não avaliável"); next }
    nul <- auc_nula(E[[s]], efg[treino], r$genes_medidos, OC$nulos_sorteios, OC$semente)
    dobras[[length(dobras) + 1]] <- data.frame(tecido = tec, estudo_testado = s, treino = paste(treino, collapse = ";"), modulo = pr$modulo, modulo_igual_etapa06 = pr$modulo %in% mod06,
      regra = pr$regra, genes = length(pr$genes), genes_medidos = r$genes_medidos, sobem = r$sobem, descem = r$descem, n_T2D = r$n_T2D, n_ND = r$n_ND,
      auc = round(r$auc, 3), ic_inf = round(r$ic_inf, 3), ic_sup = round(r$ic_sup, 3), p_wilcoxon = signif(r$p_wilcoxon, 3),
      auc_nula_mediana = round(stats::median(nul, na.rm = TRUE), 3), auc_nula_p95 = round(stats::quantile(nul, 0.95, na.rm = TRUE), 3),
      p_nulo_genes = round((1 + sum(nul >= r$auc, na.rm = TRUE)) / (1 + sum(!is.na(nul))), 4), genes_usados = paste(pr$genes, collapse = ";"), nota = "")
    curvas[[length(curvas) + 1]] <- list(tecido = tec, estudo = s, tipo = "deixar um estudo de fora", roc = r$roc)
    log_msg("ETAPA 10 | %s, testando %s (treino %s): módulo %s, %d genes, AUC %.2f (IC %.2f-%.2f), p nulo %.3f", tec, s, paste(treino, collapse = "+"), pr$modulo, r$genes_medidos, r$auc, r$ic_inf, r$ic_sup,
            dobras[[length(dobras)]]$p_nulo_genes)
  }
  # 10.1b 1 estudo (fígado): validação cruzada dentro do estudo (10/10/2026)
  if (length(gs) == 1) {
    g1 <- gs; VC <- OC$validacao_cruzada; a <- alvo_cv(E[[g1]]); Eg <- eigengenes_estudo(E[[g1]]$ex[, E[[g1]]$am$coluna, drop = FALSE], cores)
    for (rep in seq_len(VC$repeticoes)) {
      f <- dobras_estratificadas(a$status, VC$dobras, OC$semente + rep - 1); esc <- list(); nul <- list()
      for (k in seq_len(VC$dobras)) {
        fora <- a$coluna[f == k]; aj <- ajuste_treino(MC, E[[g1]], Eg, fora); pr <- selecao_estudo(aj, cores, OC)
        r <- escore_auc(parte(E[[g1]], fora), pr$genes, pr$sentido); esc[[k]] <- r$escore
        dobras_cv[[length(dobras_cv) + 1]] <- data.frame(tecido = tec, estudo = g1, repeticao = rep, parte = k, modulo = pr$modulo, modulo_igual_etapa06 = pr$modulo %in% mod06, regra = pr$regra,
          genes = r$genes_medidos, sobem = r$sobem, descem = r$descem, n_T2D = r$n_T2D, n_ND = r$n_ND, auc_parte = round(r$auc, 3), genes_usados = paste(pr$genes, collapse = ";"))
        if (rep == 1) {                                                # nulo: conjuntos sorteados do mesmo tamanho, sentido do treino
          u <- aj$genes[aj$genes$id %in% rownames(E[[g1]]$ex), ]; set.seed(OC$semente + k)
          nul[[k]] <- sapply(seq_len(VC$sorteios_nulo), function(b) { i <- sample(nrow(u), r$genes_medidos); escore_auc(parte(E[[g1]], fora), u$id[i], sign(u$g[i]))$escore$escore })
        }
      }
      ar <- auc_reunida(do.call(rbind, esc))
      repet_cv[[length(repet_cv) + 1]] <- data.frame(tecido = tec, estudo = g1, repeticao = rep, n_T2D = ar$n_T2D, n_ND = ar$n_ND, auc = round(ar$auc, 3), ic_inf = round(ar$ic_inf, 3), ic_sup = round(ar$ic_sup, 3),
                                                     p_wilcoxon = signif(ar$p_wilcoxon, 3))
      if (rep == 1) {
        st <- do.call(rbind, esc)$status; N <- do.call(rbind, nul)
        an <- apply(N, 2, function(s) as.numeric(pROC::auc(pROC::roc(factor(st, levels = c("ND", "T2D")), s, levels = c("ND", "T2D"), direction = "<", quiet = TRUE))))
        nulo_cv[[tec]] <- data.frame(tecido = tec, auc_nula_mediana = round(stats::median(an), 3), auc_nula_p95 = round(stats::quantile(an, 0.95), 3), p_nulo_genes = round((1 + sum(an >= ar$auc)) / (1 + length(an)), 4))
        curvas[[length(curvas) + 1]] <- list(tecido = tec, estudo = sprintf("%s VC", g1), tipo = "validação cruzada", roc = ar$roc)
      }
      log_msg("ETAPA 10 | %s, validação cruzada no %s, repetição %d: AUC %.2f (IC %.2f-%.2f)", tec, g1, rep, ar$auc, ar$ic_inf, ar$ic_sup)
    }
  }
  # circular (otimista, só para comparação): genes escolhidos com TODOS os estudos e testados neles mesmos
  pa <- escolher_programa(OC, tec, gs, cores, efm, efg)
  for (s in gs) { r <- escore_auc(E[[s]], pa$genes, pa$sentido); if (!is.null(r)) circular[[length(circular) + 1]] <- data.frame(tecido = tec, estudo = s, modulo = pa$modulo, auc_circular = round(r$auc, 3)) }
  # 10.2 validação externa: treino com todos os estudos principais
  for (s in unlist(OC$externos[[tec]])) {
    ee <- carregar_estudo(s, inv_all, NULL, codif); r <- escore_auc(ee, pa$genes, pa$sentido)
    if (is.null(r) || r$genes_medidos < OC$min_genes_teste) { externa[[length(externa) + 1]] <- data.frame(tecido = tec, estudo = s, modulo = pa$modulo, genes_medidos = if (is.null(r)) 0 else r$genes_medidos, auc = NA,
      limitacao = OC$limitacoes_externos[[s]] %||% "", nota = "não avaliável"); next }
    efg_all <- efg; nul <- auc_nula(ee, efg_all, r$genes_medidos, OC$nulos_sorteios, OC$semente)
    externa[[length(externa) + 1]] <- data.frame(tecido = tec, estudo = s, modulo = pa$modulo, genes = length(pa$genes), genes_medidos = r$genes_medidos, n_T2D = r$n_T2D, n_ND = r$n_ND,
      auc = round(r$auc, 3), ic_inf = round(r$ic_inf, 3), ic_sup = round(r$ic_sup, 3), p_wilcoxon = signif(r$p_wilcoxon, 3), auc_nula_mediana = round(stats::median(nul, na.rm = TRUE), 3),
      p_nulo_genes = round((1 + sum(nul >= r$auc, na.rm = TRUE)) / (1 + sum(!is.na(nul))), 4), limitacao = OC$limitacoes_externos[[s]] %||% "", nota = "")
    curvas[[length(curvas) + 1]] <- list(tecido = tec, estudo = s, tipo = "externo", roc = r$roc)
    log_msg("ETAPA 10 | %s, externo %s: AUC %.2f (IC %.2f-%.2f)", tec, s, r$auc, r$ic_inf, r$ic_sup)
  }
}
dob <- rbind_preenche(dobras); ext <- rbind_preenche(externa); cir <- rbind_preenche(circular)
# meta-análise das AUCs de "deixar um estudo de fora" (efeito = AUC - 0,5; erro padrão de Hanley e McNeil)
ok <- dob[!is.na(dob$auc), ]
met <- do.call(rbind, lapply(split(ok, ok$tecido), function(x) {
  # escala logit (revisão de 09/10/2026): mantém a AUC combinada e o IC entre 0 e 1; AUC afastada de 0 e 1 (0,5 / pares)
  A <- pmin(pmax(x$auc, 0.5 / (x$n_T2D * x$n_ND)), 1 - 0.5 / (x$n_T2D * x$n_ND)); L <- stats::qlogis(A)
  G <- matrix(L, 1); V <- matrix((ep_auc(x$auc, x$n_T2D, x$n_ND) / (A * (1 - A)))^2, 1); P <- matrix(pmin(1, 2 * x$p_wilcoxon), 1); N <- matrix(x$n_T2D + x$n_ND, 1); rownames(G) <- "AUC"
  m <- meta_dl(G, V, P, "hk", N); dois <- nrow(x) == 2                      # 2 estudos: efeito fixo (decisão de 08/10/2026)
  data.frame(tecido = x$tecido[1], estudos = nrow(x), auc_combinada = round(stats::plogis(m$g), 3), ic_inf = round(stats::plogis(m$ic_inf), 3), ic_sup = round(stats::plogis(m$ic_sup), 3),
             p_hk = signif(m$p, 3), auc_combinada_fe = if (dois) round(stats::plogis(m$g_fe), 3) else NA, p_fe = if (dois) signif(m$p_fe, 3) else NA, I2 = round(m$I2, 2),
             estudos_auc_maior_0.5 = sum(x$auc > 0.5), modulo_igual_etapa06 = sprintf("%d/%d", sum(x$modulo_igual_etapa06), nrow(x))) }))
escrever_csv(dob, file.path(d, "deixar_um_de_fora.csv")); escrever_csv(met, file.path(d, "meta_auc.csv"))
if (!is.null(ext)) escrever_csv(ext, file.path(d, "validacao_externa.csv")); escrever_csv(cir, file.path(d, "auc_circular.csv"))
# resumo da validação cruzada (1 estudo): mediana das repetições; IC e p de DeLong/Wilcoxon da repetição mediana
dcv <- rbind_preenche(dobras_cv); rcv <- rbind_preenche(repet_cv); vcr <- NULL
if (!is.null(rcv)) {
  vcr <- do.call(rbind, lapply(split(rcv, rcv$tecido), function(x) { i <- order(x$auc)[ceiling(nrow(x) / 2)]; dd <- dcv[dcv$tecido == x$tecido[1], ]; nu <- nulo_cv[[x$tecido[1]]]
    data.frame(tecido = x$tecido[1], estudo = x$estudo[1], dobras = max(dd$parte), repeticoes = nrow(x), n_T2D = x$n_T2D[1], n_ND = x$n_ND[1], auc_mediana = x$auc[i], ic_inf = x$ic_inf[i], ic_sup = x$ic_sup[i],
               auc_min = min(x$auc), auc_max = max(x$auc), p_wilcoxon = x$p_wilcoxon[i], auc_nula_mediana = nu$auc_nula_mediana, auc_nula_p95 = nu$auc_nula_p95, p_nulo_genes = nu$p_nulo_genes,
               modulo_mais_escolhido = names(sort(table(dd$modulo), decreasing = TRUE))[1], vezes_modulo = sprintf("%d/%d", max(table(dd$modulo)), nrow(dd)),
               modulo_igual_etapa06 = sprintf("%d/%d", sum(dd$modulo_igual_etapa06), nrow(dd)), genes_mediana = stats::median(dd$genes)) }))
  escrever_csv(dcv, file.path(d, "validacao_cruzada_partes.csv")); escrever_csv(rcv, file.path(d, "validacao_cruzada_repeticoes.csv")); escrever_csv(vcr, file.path(d, "validacao_cruzada.csv"))
}

# ---------------- figura ----------------
tt <- unlist(OC$tecidos); grDevices::png("docs/figuras/roc_programas.png", width = 2100, height = 760, res = 160)
op <- graphics::par(mfrow = c(1, length(tt)), mar = c(4.3, 4.3, 3, 1)); pal <- c("#1F77B4", "#D62728", "#2CA02C", "#9467BD", "#FF7F0E", "#8C564B")
for (tec in tt) { cv <- Filter(function(z) z$tecido == tec, curvas)
  graphics::plot(c(0, 1), c(0, 1), type = "n", xlab = "1 − especificidade", ylab = "Sensibilidade", main = if (any(met$tecido == tec)) sprintf("%s (AUC combinada %s)", tec, f2(met$auc_combinada[met$tecido == tec])) else if (!is.null(vcr) && any(vcr$tecido == tec)) sprintf("%s (validação cruzada %s)", tec, f2(vcr$auc_mediana[vcr$tecido == tec])) else sprintf("%s (só validação externa)", tec))
  graphics::abline(0, 1, lty = 3, col = "grey60")
  for (i in seq_along(cv)) { r <- cv[[i]]$roc; graphics::lines(1 - r$specificities, r$sensitivities, col = pal[(i - 1) %% length(pal) + 1], lwd = 2, lty = if (cv[[i]]$tipo == "externo") 2 else 1) }
  if (length(cv)) graphics::legend("bottomright", sprintf("%s%s (%s)", vapply(cv, `[[`, "", "estudo"), ifelse(vapply(cv, `[[`, "", "tipo") == "externo", " ext.", ""), f2(vapply(cv, function(z) as.numeric(pROC::auc(z$roc)), 0))),
                                   col = pal[(seq_along(cv) - 1) %% length(pal) + 1], lty = ifelse(vapply(cv, `[[`, "", "tipo") == "externo", 2, 1), lwd = 2, cex = 0.65, bty = "n") }
graphics::par(op); grDevices::dev.off()

# ---------------- relatório ----------------
cm <- merge(dob[, c("tecido", "estudo_testado", "auc")], cir, by.x = c("tecido", "estudo_testado"), by.y = c("tecido", "estudo"), all.x = TRUE)
linhas <- c("# Validação da etapa 10: curva ROC dos programas", "", sprintf("Gerado em %s a partir de `output/10_roc/`.", format(Sys.time(), "%d/%m/%Y %H:%M")), "",
  "## 1. Deixar um estudo de fora (genes escolhidos sem o estudo testado)", "",
  "| Tecido | Estudo testado | Módulo escolhido no treino | Genes (sobem/descem) | DM2/ND | AUC (IC 95%) | p (Wilcoxon) | AUC de genes sorteados (mediana; p95) | p vs genes sorteados |", "|---|---|---|---|---|---|---:|---|---:|",
  sprintf("| %s | %s | %s%s | %s | %s | %s | %s | %s | %s |", dob$tecido, dob$estudo_testado, dob$modulo, ifelse(dob$modulo_igual_etapa06, "", " (≠ etapa 06)"),
          ifelse(is.na(dob$auc), "-", sprintf("%d (%d/%d)", dob$genes_medidos, dob$sobem, dob$descem)), ifelse(is.na(dob$auc), "-", sprintf("%d/%d", dob$n_T2D, dob$n_ND)),
          ifelse(is.na(dob$auc), "não avaliável", sprintf("%s (%s a %s)", f2(dob$auc), f2(dob$ic_inf), f2(dob$ic_sup))), fp(dob$p_wilcoxon),
          ifelse(is.na(dob$auc), "-", sprintf("%s; %s", f2(dob$auc_nula_mediana), f2(dob$auc_nula_p95))), fp(dob$p_nulo_genes)), "",
  "## 2. AUC combinada (meta-análise das rodadas)", "",
  "| Tecido | Estudos | AUC combinada (IC 95%) | p (Hartung-Knapp) | AUC efeito fixo | p (efeito fixo) | Estudos com AUC > 0,5 | Mesmo módulo da etapa 06 |", "|---|---:|---|---:|---:|---:|---|---|",
  sprintf("| %s | %d | %s (%s a %s) | %s | %s | %s | %d/%d | %s |", met$tecido, met$estudos, f2(met$auc_combinada), f2(met$ic_inf), f2(met$ic_sup), fp(met$p_hk), f2(met$auc_combinada_fe), fp(met$p_fe),
          met$estudos_auc_maior_0.5, met$estudos, met$modulo_igual_etapa06), "",
  "## 2b. Tecido com 1 estudo (fígado): validação cruzada dentro do estudo", "",
  if (!is.null(vcr)) c("| Tecido | Estudo | Partes × repetições | DM2/ND | AUC mediana (IC 95%) | AUC mín.–máx. | p (Wilcoxon) | AUC de genes sorteados (mediana; p95) | p vs sorteados | Módulo mais escolhido |", "|---|---|---|---|---|---|---:|---|---:|---|",
    sprintf("| %s | %s | %d × %d | %d/%d | %s (%s a %s) | %s–%s | %s | %s; %s | %s | %s (%s) |", vcr$tecido, vcr$estudo, vcr$dobras, vcr$repeticoes, vcr$n_T2D, vcr$n_ND, f2(vcr$auc_mediana), f2(vcr$ic_inf), f2(vcr$ic_sup),
            f2(vcr$auc_min), f2(vcr$auc_max), fp(vcr$p_wilcoxon), f2(vcr$auc_nula_mediana), f2(vcr$auc_nula_p95), fp(vcr$p_nulo_genes), vcr$modulo_mais_escolhido, vcr$vezes_modulo)) else "Sem tecidos com 1 estudo.", "",
  "## 3. Validação externa (treino com todos os estudos principais)", "",
  if (!is.null(ext)) c("| Tecido | Estudo | Genes medidos | DM2/ND | AUC (IC 95%) | p (Wilcoxon) | p vs genes sorteados | Limitação |", "|---|---|---:|---|---|---:|---:|---|",
    sprintf("| %s | %s | %s | %s | %s | %s | %s | %s |", ext$tecido, ext$estudo, ext$genes_medidos, ifelse(is.na(ext$auc), "-", sprintf("%d/%d", ext$n_T2D, ext$n_ND)),
            ifelse(is.na(ext$auc), "não avaliável", sprintf("%s (%s a %s)", f2(ext$auc), f2(ext$ic_inf), f2(ext$ic_sup))), fp(ext$p_wilcoxon), fp(ext$p_nulo_genes), ext$limitacao)) else "Sem estudos externos.", "",
  "## 4. Comparação com a AUC circular (otimista)", "",
  "| Tecido | Estudo | AUC deixando o estudo de fora | AUC circular (genes escolhidos com o próprio estudo) |", "|---|---|---:|---:|",
  sprintf("| %s | %s | %s | %s |", cm$tecido, cm$estudo_testado, f2(cm$auc), f2(cm$auc_circular)), "",
  "A AUC circular usa genes escolhidos olhando o próprio estudo e é otimista por construção; só serve para mostrar quanto a escolha 'enxerga' as respostas.")
writeLines(linhas, file.path(pasta("docs"), "validacao_10_roc.md"), useBytes = TRUE)
log_msg("ETAPA 10 | relatório: docs/validacao_10_roc.md")

blocos <- list(
  list(tipo = "p", texto = sprintf("Gerado em %s a partir de config/roc.yaml e output/10_roc/.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
  list(tipo = "h2", texto = "1. Objetivo"),
  list(tipo = "p", texto = "Testar se os genes de cada programa (estroma das ilhotas, mitocôndria do músculo, módulos do fígado; no sangue, o módulo escolhido no treino) separam, em mulheres de 40–60 que NÃO ajudaram a escolhê-los, quem tem DM2 de quem não tem (curva ROC; pedido do usuário, 09/10/2026). É uma medida de reprodutibilidade em pessoas novas; não prova que o programa é causado pelo DM2 (um confusor também separaria os grupos) nem é um teste diagnóstico."),
  list(tipo = "h2", texto = "2. Métodos e decisões"),
  list(tipo = "b", itens = c(
    "Deixar um estudo de fora: em cada rodada, um estudo do tecido é escondido. Só com os outros (treino) escolhe-se de novo o módulo (o de menor p do efeito do DM2, com todos os estudos de treino no mesmo sentido) e os genes do módulo, pela regra fixa abaixo, com o sentido de cada gene. A rede em si não é refeita: foi construída uma vez, sem o status de DM2, com todos os estudos de construção (inclusive o estudo testado e, no sangue e no fígado, os externos GSE156993 e GSE15653). Não há vazamento de rótulo, mas a avaliação é CONDICIONADA a essa rede, não uma validação totalmente independente; a etapa 10d refaz a rede em cada rodada (revisão de 11/10/2026).",
    sprintf("Regra dos genes: p < %s no treino (Hartung-Knapp com 3+ estudos; efeito fixo com 2; p do próprio estudo com 1) e mesmo sentido em todos os estudos de treino; se forem menos de %d, os %d de menor p no mesmo sentido; no máximo %d.", f2(OC$genes$p_max), OC$genes$min, OC$genes$reserva, OC$genes$max),
    "Escore de sentido fixo, por mulher do estudo testado: média dos z dos genes que sobem no DM2 menos a média dos z dos que descem (z dentro do estudo). Nada é ajustado com os rótulos do estudo testado.",
    "AUC = probabilidade de uma mulher com DM2 sorteada ter escore maior que uma sem diabetes sorteada (0,5 = acaso; 1 = separação perfeita); IC 95% de DeLong; p de Wilcoxon exato (equivale a permutar os rótulos).",
    sprintf("Nulo de genes: %d conjuntos sorteados do mesmo tamanho, com sentido também tirado do treino; mostra que AUC se espera sem programa nenhum.", OC$nulos_sorteios),
    "AUC combinada: meta-análise das rodadas na escala logit (mantém a AUC entre 0 e 1; erro padrão de Hanley e McNeil; AUC de 0 ou 1 afastada por 0,5/pares), Hartung-Knapp e, com 2 estudos, também efeito fixo.",
    "Validação externa: treino com todos os estudos principais do tecido; teste nos estudos que ficaram só na sensibilidade, cada um com a sua limitação. Ilhotas não têm estudo externo; o painel NanoString de sangue mede só 1 gene do programa de interferon e não foi usado.",
    "Escopo: só mulheres de 40–60, DM2 × sem diabetes.")),
  list(tipo = "h2", texto = "3. Deixar um estudo de fora"),
  list(tipo = "tabela", df = data.frame(Tecido = dob$tecido, `Estudo testado` = dob$estudo_testado, `Módulo (treino)` = paste0(dob$modulo, ifelse(dob$modulo_igual_etapa06, "", " (≠ etapa 06)")),
                                        Genes = ifelse(is.na(dob$auc), "-", sprintf("%d (%d↑/%d↓)", dob$genes_medidos, dob$sobem, dob$descem)), `DM2/ND` = ifelse(is.na(dob$auc), "-", sprintf("%d/%d", dob$n_T2D, dob$n_ND)),
                                        `AUC (IC 95%)` = ifelse(is.na(dob$auc), "não avaliável", sprintf("%s (%s a %s)", f2(dob$auc), f2(dob$ic_inf), f2(dob$ic_sup))), `p Wilcoxon` = fp(dob$p_wilcoxon),
                                        `AUC genes sorteados (mediana)` = f2(dob$auc_nula_mediana), `p vs sorteados` = fp(dob$p_nulo_genes), check.names = FALSE)),
  list(tipo = "img", arq = "docs/figuras/roc_programas.png", largura = 6.5, altura = 2.4, nota = "Curvas ROC por tecido: linha cheia = estudo testado deixando-o de fora (no fígado, validação cruzada dentro do GSE130991, 1ª repetição); tracejada = estudo externo. Diagonal = acaso."),
  list(tipo = "h2", texto = "4. AUC combinada"),
  list(tipo = "tabela", df = data.frame(Tecido = met$tecido, Estudos = met$estudos, `AUC combinada (IC 95%)` = sprintf("%s (%s a %s)", f2(met$auc_combinada), f2(met$ic_inf), f2(met$ic_sup)), `p (HK)` = fp(met$p_hk),
                                        `AUC efeito fixo` = f2(met$auc_combinada_fe), `p (efeito fixo)` = fp(met$p_fe), `AUC > 0,5` = sprintf("%d/%d", met$estudos_auc_maior_0.5, met$estudos),
                                        `Mesmo módulo da etapa 06` = met$modulo_igual_etapa06, check.names = FALSE)),
  list(tipo = "h2", texto = "4b. Fígado: validação cruzada dentro do GSE130991"),
  list(tipo = "p", texto = "Com 1 estudo principal no fígado não há como deixar um estudo de fora (pedido do usuário, 10/10/2026: incluir o GSE130991 na curva ROC). As mulheres de 40–60 do GSE130991 foram divididas em 5 partes, estratificadas por status. Em cada rodada, o modelo da etapa 05 foi refeito sem a parte testada, o módulo e os genes foram escolhidos pela mesma regra do deixar-um-de-fora e o escore foi avaliado na parte escondida (z dentro da parte). As 5 partes reunidas dão uma AUC; o sorteio das partes foi repetido 10 vezes. A rede não é refeita: foi construída sem o status de DM2. Cuidado: as partes vêm do mesmo estudo (mesmo laboratório, mesma plataforma), então essa AUC é mais otimista que a de um estudo novo."),
  if (!is.null(vcr)) list(tipo = "tabela", df = data.frame(Estudo = vcr$estudo, `DM2/ND` = sprintf("%d/%d", vcr$n_T2D, vcr$n_ND), `AUC mediana das repetições (IC 95%)` = sprintf("%s (%s a %s)", f2(vcr$auc_mediana), f2(vcr$ic_inf), f2(vcr$ic_sup)),
                                                           `AUC mín.–máx.` = sprintf("%s–%s", f2(vcr$auc_min), f2(vcr$auc_max)), `p Wilcoxon` = fp(vcr$p_wilcoxon), `AUC genes sorteados (mediana; p95)` = sprintf("%s; %s", f2(vcr$auc_nula_mediana), f2(vcr$auc_nula_p95)),
                                                           `p vs sorteados` = fp(vcr$p_nulo_genes), `Módulo escolhido` = sprintf("%s em %s rodadas; módulo da etapa 06 em %s", vcr$modulo_mais_escolhido, vcr$vezes_modulo, vcr$modulo_igual_etapa06), check.names = FALSE),
                          nota = "Genes sorteados: conjuntos do mesmo tamanho, com o sentido tirado do treino. Eles já separam um pouco os grupos no GSE130991 porque o DM2 desloca o perfil inteiro nesse estudo; o programa precisa superar esse nível.") else NULL,
  list(tipo = "h2", texto = "5. Validação externa"),
  if (!is.null(ext)) list(tipo = "tabela", df = data.frame(Tecido = ext$tecido, Estudo = ext$estudo, `Genes medidos` = ext$genes_medidos, `DM2/ND` = ifelse(is.na(ext$auc), "-", sprintf("%d/%d", ext$n_T2D, ext$n_ND)),
                                                          `AUC (IC 95%)` = ifelse(is.na(ext$auc), "não avaliável", sprintf("%s (%s a %s)", f2(ext$auc), f2(ext$ic_inf), f2(ext$ic_sup))), `p Wilcoxon` = fp(ext$p_wilcoxon),
                                                          `p vs sorteados` = fp(ext$p_nulo_genes), `Limitação` = ext$limitacao, check.names = FALSE)) else list(tipo = "p", texto = "Sem estudos externos."),
  list(tipo = "h2", texto = "6. AUC circular (otimista, só para comparação)"),
  list(tipo = "tabela", df = data.frame(Tecido = cm$tecido, Estudo = cm$estudo_testado, `AUC deixando o estudo de fora` = f2(cm$auc), `AUC circular` = f2(cm$auc_circular), check.names = FALSE),
       nota = "AUC circular: genes escolhidos olhando o próprio estudo; otimista por construção. A diferença mostra quanto a escolha dos genes 'enxerga' as respostas."),
  list(tipo = "h2", texto = "7. Arquivos"),
  list(tipo = "b", itens = c("Código: R/10_roc.R; execução: run_10_roc.R; configuração: config/roc.yaml.",
                             "Saídas: output/10_roc/{deixar_um_de_fora, meta_auc, validacao_externa, auc_circular, validacao_cruzada, validacao_cruzada_repeticoes, validacao_cruzada_partes}.csv. Figura: docs/figuras/roc_programas.png. Validação: docs/validacao_10_roc.md.")))
gravar_docx(Filter(Negate(is.null), blocos), "docs/etapa_10_roc.docx", "Etapa 10 — Curva ROC dos programas (deixar um estudo de fora e validação externa)", etapa = "10")
