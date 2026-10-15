###############################################################################
#  run_10b_roc_otimizada.R - ETAPA 10b: curva ROC com otimização aninhada do conjunto de genes
#  Uso: "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_10b_roc_otimizada.R
#  Requer a etapa 10. Saídas: output/10_roc/otimizada_*.csv, docs/figuras/roc_otimizada.png,
#  docs/validacao_10b_roc_otimizada.md, docs/etapa_10b_roc_otimizada.docx
###############################################################################
for (f in c("R/00_utils.R", "R/05_meta.R", "R/06_redes.R", "R/10_roc.R", "R/10b_roc_otimizada.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
MC <- ler_config("config/meta.yaml"); OC <- ler_config("config/roc.yaml")
inv_all <- utils::read.csv("output/04_processamento/inventario.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
est05 <- utils::read.csv("output/05_meta/estudos.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8"); prin <- est05[est05$uso == "principal", ]
codif <- if (isTRUE(MC$so_codificantes)) genes_codificantes() else NULL
d <- pasta("output", "10_roc")
le <- function(f) if (file.exists(f) && file.size(f) > 5) utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8") else NULL
f2 <- function(x, k = 2) ifelse(is.na(x), "-", formatC(x, format = "f", digits = k, decimal.mark = ","))
fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
regras <- expand.grid(fonte = c("modulo", "genoma"), k = c(10, 20, 50, 100), stringsAsFactors = FALSE)
regras$nome <- sprintf("%s, %d genes", ifelse(regras$fonte == "modulo", "módulo", "genoma"), regras$k)
padrao <- which(regras$fonte == "modulo" & regras$k == 20)                    # regra da etapa 10 (sem otimização)

efg <- lapply(stats::setNames(prin$gse, prin$gse), function(g) le(file.path("output/05_meta/estudos", g, "efeitos_genes.csv")))
E <- lapply(stats::setNames(prin$gse, prin$gse), function(g) carregar_estudo(g, inv_all, NULL, codif))
combina <- function(x) { x <- x[!is.na(x$auc), ]; if (!nrow(x)) return(NULL)
  A <- pmin(pmax(x$auc, 0.5 / (x$n_T2D * x$n_ND)), 1 - 0.5 / (x$n_T2D * x$n_ND))
  G <- matrix(stats::qlogis(A), 1); V <- matrix((ep_auc(x$auc, x$n_T2D, x$n_ND) / (A * (1 - A)))^2, 1); P <- matrix(pmin(1, 2 * x$p_wilcoxon), 1); rownames(G) <- "AUC"
  m <- meta_dl(G, V, P, "hk", matrix(x$n_T2D + x$n_ND, 1)); data.frame(estudos = nrow(x), auc = round(stats::plogis(m$g), 3), ic_inf = round(stats::plogis(m$ic_inf), 3), ic_sup = round(stats::plogis(m$ic_sup), 3), p = signif(m$p, 3)) }

# ---------------- 1. por tecido: deixar um estudo de fora, com a regra escolhida dentro do treino ----------------
dob <- list(); inner <- list(); final <- list(); cv_ot <- list()
for (tec in unlist(OC$tecidos)) {
  gs <- prin$gse[prin$tecido == tec]
  cores <- readRDS(file.path("output/06_redes", tec, "rede_cache.rds"))$cores; efm <- le(file.path("output/06_redes", tec, "efeitos_modulos_estudos.csv"))
  if (length(gs) == 1) {                                                # 1 estudo (fígado): validação cruzada aninhada dentro do estudo (10/10/2026)
    g1 <- gs; VC <- OC$validacao_cruzada; a <- alvo_cv(E[[g1]]); Eg <- eigengenes_estudo(E[[g1]]$ex[, E[[g1]]$am$coluna, drop = FALSE], cores)
    auc_interna <- function(cols_treino, semente) {                    # AUC de cada regra por validação cruzada interna (só o treino)
      at <- a[a$coluna %in% cols_treino, ]; fi <- dobras_estratificadas(at$status, VC$dobras, semente); esc <- rep(list(list()), nrow(regras))
      for (j in seq_len(VC$dobras)) { fora_i <- c(setdiff(a$coluna, cols_treino), at$coluna[fi == j]); aj <- ajuste_treino(MC, E[[g1]], Eg, fora_i)
        for (i in seq_len(nrow(regras))) { sl <- selecao_estudo(aj, cores, OC, regras$fonte[i], regras$k[i]); esc[[i]][[j]] <- escore_auc(parte(E[[g1]], at$coluna[fi == j]), sl$genes, sl$sentido)$escore } }
      vapply(esc, function(e) auc_reunida(do.call(rbind, e))$auc, 0) }
    for (rep in seq_len(VC$repeticoes)) {
      f <- dobras_estratificadas(a$status, VC$dobras, OC$semente + rep - 1); e_ot <- list(); e_pd <- list(); esc_regra <- character()
      for (k in seq_len(VC$dobras)) {
        fora <- a$coluna[f == k]; ai <- auc_interna(setdiff(a$coluna, fora), OC$semente + 100 * rep + k); i <- if (all(is.na(ai))) padrao else which.max(ai)
        inner[[length(inner) + 1]] <- data.frame(tecido = tec, estudo_testado = sprintf("%s rep %d parte %d", g1, rep, k), regra = regras$nome, auc_interna = round(ai, 3))
        aj <- ajuste_treino(MC, E[[g1]], Eg, fora); te <- parte(E[[g1]], fora)
        so <- selecao_estudo(aj, cores, OC, regras$fonte[i], regras$k[i]); sp <- selecao_estudo(aj, cores, OC)
        e_ot[[k]] <- escore_auc(te, so$genes, so$sentido)$escore; e_pd[[k]] <- escore_auc(te, sp$genes, sp$sentido)$escore; esc_regra[k] <- regras$nome[i]
      }
      ro <- auc_reunida(do.call(rbind, e_ot)); rp <- auc_reunida(do.call(rbind, e_pd))
      cv_ot[[length(cv_ot) + 1]] <- data.frame(tecido = tec, estudo = g1, repeticao = rep, regras_escolhidas = paste(names(table(esc_regra)), table(esc_regra), sep = " x", collapse = "; "),
        n_T2D = ro$n_T2D, n_ND = ro$n_ND, auc_otimizada = round(ro$auc, 3), ic_inf = round(ro$ic_inf, 3), ic_sup = round(ro$ic_sup, 3), p_wilcoxon = signif(ro$p_wilcoxon, 3), auc_padrao = round(rp$auc, 3))
      log_msg("ETAPA 10b | %s, validação cruzada aninhada no %s, repetição %d: AUC otimizada %.2f, padrão %.2f (regras: %s)", tec, g1, rep, ro$auc, rp$auc, cv_ot[[length(cv_ot)]]$regras_escolhidas)
    }
    ai <- auc_interna(a$coluna, OC$semente); i <- if (all(is.na(ai))) padrao else which.max(ai)  # conjunto final: regra por validação cruzada com todas as mulheres
    aj <- ajuste_treino(MC, E[[g1]], Eg, character()); sl <- selecao_estudo(aj, cores, OC, regras$fonte[i], regras$k[i])
    final[[tec]] <- data.frame(conjunto = tec, regra = regras$nome[i], modulo = sl$modulo, gene = sl$genes, sentido = ifelse(sl$sentido > 0, "maior no DM2", "menor no DM2"))
    next
  }
  escolhe <- function(treino) {                                        # regra escolhida só com o treino (deixar um de fora interno)
    if (length(treino) < 2) return(list(i = padrao, nota = "1 estudo de treino: sem otimização interna (regra padrão da etapa 10)", aucs = NULL))
    a <- vapply(seq_len(nrow(regras)), function(i) mean(vapply(treino, function(s) auc_regra(regras[i, ], setdiff(treino, s), s, efg, E, cores, efm, OC$min_genes_teste), 0), na.rm = TRUE), 0)
    list(i = if (all(is.na(a))) padrao else which.max(a), nota = "regra escolhida por deixar um estudo de fora dentro do treino", aucs = a) }
  for (s in gs) {
    treino <- setdiff(gs, s); ch <- escolhe(treino); rg <- regras[ch$i, ]
    if (!is.null(ch$aucs)) inner[[length(inner) + 1]] <- data.frame(tecido = tec, estudo_testado = s, regra = regras$nome, auc_interna = round(ch$aucs, 3))
    sel <- genes_por_regra(rg$fonte, rg$k, treino, efg, cores, efm); r <- if (is.null(sel)) NULL else escore_auc(E[[s]], sel$genes, sel$sentido)
    dob[[length(dob) + 1]] <- data.frame(tecido = tec, estudo_testado = s, regra = rg$nome, nota = ch$nota, genes_medidos = if (is.null(r)) 0 else r$genes_medidos,
                                         n_T2D = if (is.null(r)) NA else r$n_T2D, n_ND = if (is.null(r)) NA else r$n_ND, auc = if (is.null(r) || r$genes_medidos < OC$min_genes_teste) NA else round(r$auc, 3),
                                         ic_inf = if (is.null(r)) NA else round(r$ic_inf, 3), ic_sup = if (is.null(r)) NA else round(r$ic_sup, 3), p_wilcoxon = if (is.null(r)) NA else signif(r$p_wilcoxon, 3))
    log_msg("ETAPA 10b | %s, testando %s: regra '%s' (%s), AUC %s", tec, s, rg$nome, if (is.null(ch$aucs)) "sem otimização" else "otimizada no treino", f2(dob[[length(dob)]]$auc))
  }
  # conjunto final do tecido: regra escolhida com todos os estudos (deixar um de fora entre eles) e genes com todos os estudos
  ch <- escolhe(gs); rg <- regras[ch$i, ]; sel <- genes_por_regra(rg$fonte, rg$k, gs, efg, cores, efm)
  final[[tec]] <- data.frame(conjunto = tec, regra = rg$nome, modulo = sel$modulo, gene = sel$genes, sentido = ifelse(sel$sentido > 0, "maior no DM2", "menor no DM2"))
}
dob <- do.call(rbind, dob); inner <- do.call(rbind, inner)
cvo <- if (length(cv_ot)) do.call(rbind, cv_ot) else NULL
cvo_res <- if (!is.null(cvo)) do.call(rbind, lapply(split(cvo, cvo$tecido), function(x) { i <- order(x$auc_otimizada)[ceiling(nrow(x) / 2)]
  data.frame(tecido = x$tecido[1], estudo = x$estudo[1], repeticoes = nrow(x), auc_otimizada_mediana = x$auc_otimizada[i], ic_inf = x$ic_inf[i], ic_sup = x$ic_sup[i], p_wilcoxon = x$p_wilcoxon[i],
             auc_otimizada_min = min(x$auc_otimizada), auc_otimizada_max = max(x$auc_otimizada), auc_padrao_mediana = stats::median(x$auc_padrao)) })) else NULL
met <- do.call(rbind, lapply(split(dob, dob$tecido), function(x) data.frame(tecido = x$tecido[1], combina(x))))

# ---------------- 2. todos os tecidos: deixar um TECIDO de fora ----------------
tt <- unique(prin$tecido); frac <- 0.8                                 # gene medido em >= 80% dos estudos de treino, sentido em >= 80%
regras_p <- regras[regras$fonte == "genoma", ]
escolhe_p <- function(tec_treino) {
  if (length(tec_treino) < 2) return(1)
  a <- vapply(seq_len(nrow(regras_p)), function(i) mean(vapply(tec_treino, function(t) auc_regra(regras_p[i, ], prin$gse[prin$tecido %in% setdiff(tec_treino, t)], prin$gse[prin$tecido == t], efg, E, NULL, NULL, OC$min_genes_teste, frac), 0), na.rm = TRUE), 0)
  if (all(is.na(a))) 1 else which.max(a) }
pan <- list()
for (t in tt) {
  tr <- setdiff(tt, t); i <- escolhe_p(tr); rg <- regras_p[i, ]; sel <- genes_por_regra("genoma", rg$k, prin$gse[prin$tecido %in% tr], efg, frac_medido = frac)
  for (s in prin$gse[prin$tecido == t]) { r <- if (is.null(sel)) NULL else escore_auc(E[[s]], sel$genes, sel$sentido)
    pan[[length(pan) + 1]] <- data.frame(tecido_testado = t, estudo = s, regra = rg$nome, genes_medidos = if (is.null(r)) 0 else r$genes_medidos, n_T2D = if (is.null(r)) NA else r$n_T2D, n_ND = if (is.null(r)) NA else r$n_ND,
                                         auc = if (is.null(r) || r$genes_medidos < OC$min_genes_teste) NA else round(r$auc, 3), ic_inf = if (is.null(r)) NA else round(r$ic_inf, 3), ic_sup = if (is.null(r)) NA else round(r$ic_sup, 3),
                                         p_wilcoxon = if (is.null(r)) NA else signif(r$p_wilcoxon, 3)) }
  log_msg("ETAPA 10b | todos os tecidos, testando %s: regra '%s' escolhida com %s", t, rg$nome, paste(tr, collapse = "+"))
}
pan <- do.call(rbind, pan)
pan_met <- rbind(data.frame(tecido = "todos", combina(pan)), do.call(rbind, lapply(split(pan, pan$tecido_testado), function(x) { cb <- combina(x); if (!is.null(cb)) data.frame(tecido = x$tecido_testado[1], cb) })))
ip <- escolhe_p(tt); sel <- genes_por_regra("genoma", regras_p$k[ip], prin$gse, efg, frac_medido = frac)
final[["todos os tecidos"]] <- data.frame(conjunto = "todos os tecidos", regra = regras_p$nome[ip], modulo = NA, gene = sel$genes, sentido = ifelse(sel$sentido > 0, "maior no DM2", "menor no DM2"))
fin <- do.call(rbind, final)
escrever_csv(dob, file.path(d, "otimizada_deixar_um_de_fora.csv")); escrever_csv(inner, file.path(d, "otimizada_regras_internas.csv")); escrever_csv(met, file.path(d, "otimizada_meta.csv"))
escrever_csv(pan, file.path(d, "otimizada_todos_tecidos.csv")); escrever_csv(pan_met, file.path(d, "otimizada_todos_tecidos_meta.csv")); escrever_csv(fin, file.path(d, "otimizada_conjuntos_finais.csv"))
if (!is.null(cvo)) { escrever_csv(cvo, file.path(d, "otimizada_validacao_cruzada_repeticoes.csv")); escrever_csv(cvo_res, file.path(d, "otimizada_validacao_cruzada.csv")) }

# ---------------- figura: AUC padrão (etapa 10) x otimizada aninhada, por estudo ----------------
p10 <- le("output/10_roc/deixar_um_de_fora.csv"); cmp <- merge(p10[, c("tecido", "estudo_testado", "auc")], dob[, c("tecido", "estudo_testado", "auc", "regra")], by = c("tecido", "estudo_testado"), suffixes = c("_padrao", "_otimizada"))
escrever_csv(cmp, file.path(d, "otimizada_comparacao.csv"))
grDevices::png("docs/figuras/roc_otimizada.png", width = 1700, height = 820, res = 160); op <- graphics::par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))
cl <- c(ilhotas = "#0f6e74", musculo = "#a2442d", sangue = "#7b3f8c", adiposo = "#4d6a2e", figado = "#7a6a1f")
graphics::plot(cmp$auc_padrao, cmp$auc_otimizada, xlim = c(0, 1), ylim = c(0, 1), pch = 16, cex = 1.4, col = cl[cmp$tecido], xlab = "AUC — regra padrão (etapa 10)", ylab = "AUC — regra otimizada no treino", main = "Por tecido, deixando um estudo de fora")
graphics::abline(0, 1, lty = 2, col = "grey50"); graphics::abline(h = 0.5, v = 0.5, lty = 3, col = "grey70"); graphics::legend("bottomright", names(cl)[names(cl) %in% cmp$tecido], col = cl[names(cl) %in% cmp$tecido], pch = 16, bty = "n", cex = 0.8)
pp <- pan[!is.na(pan$auc), ]; o <- order(pp$tecido_testado, pp$auc)
graphics::plot(pp$auc[o], seq_along(o), xlim = c(0, 1), pch = 16, col = cl[pp$tecido_testado[o]], yaxt = "n", ylab = "", xlab = "AUC", main = "Conjunto comum, deixando um tecido de fora")
graphics::segments(pp$ic_inf[o], seq_along(o), pp$ic_sup[o], seq_along(o), col = cl[pp$tecido_testado[o]]); graphics::abline(v = 0.5, lty = 2, col = "grey50")
graphics::axis(2, seq_along(o), pp$estudo[o], las = 1, cex.axis = 0.6); graphics::par(op); grDevices::dev.off()

# ---------------- relatório ----------------
linhas <- c("# Validação da etapa 10b: curva ROC com otimização aninhada", "", sprintf("Gerado em %s.", format(Sys.time(), "%d/%m/%Y %H:%M")), "",
  "Regras testadas: genes do módulo escolhido ou do genoma inteiro, com 10, 20, 50 ou 100 genes (8 regras). A regra é escolhida dentro do treino (deixar um estudo de fora interno) e avaliada no estudo escondido.", "",
  "## 1. Por tecido", "", "| Tecido | Estudo testado | Regra escolhida no treino | AUC otimizada (IC 95%) | AUC padrão (etapa 10) |", "|---|---|---|---|---:|",
  sprintf("| %s | %s | %s | %s (%s a %s) | %s |", cmp$tecido, cmp$estudo_testado, cmp$regra, f2(cmp$auc_otimizada), f2(dob$ic_inf[match(paste(cmp$tecido, cmp$estudo_testado), paste(dob$tecido, dob$estudo_testado))]),
          f2(dob$ic_sup[match(paste(cmp$tecido, cmp$estudo_testado), paste(dob$tecido, dob$estudo_testado))]), f2(cmp$auc_padrao)), "",
  "| Tecido | AUC combinada otimizada (IC 95%) | p |", "|---|---|---:|", sprintf("| %s | %s (%s a %s) | %s |", met$tecido, f2(met$auc), f2(met$ic_inf), f2(met$ic_sup), fp(met$p)), "",
  "## 1b. Fígado: validação cruzada aninhada dentro do GSE130991", "",
  if (!is.null(cvo)) c("| Repetição | Regras escolhidas | AUC otimizada (IC 95%) | AUC padrão |", "|---:|---|---|---:|", sprintf("| %d | %s | %s (%s a %s) | %s |", cvo$repeticao, cvo$regras_escolhidas, f2(cvo$auc_otimizada), f2(cvo$ic_inf), f2(cvo$ic_sup), f2(cvo$auc_padrao))) else "Sem tecidos com 1 estudo.", "",
  "## 2. Conjunto comum a todos os tecidos (deixar um tecido de fora)", "", "| Tecido testado | Estudo | Regra | AUC (IC 95%) |", "|---|---|---|---|",
  sprintf("| %s | %s | %s | %s (%s a %s) |", pan$tecido_testado, pan$estudo, pan$regra, f2(pan$auc), f2(pan$ic_inf), f2(pan$ic_sup)), "",
  "| Conjunto | AUC combinada (IC 95%) | p |", "|---|---|---:|", sprintf("| %s | %s (%s a %s) | %s |", pan_met$tecido, f2(pan_met$auc), f2(pan_met$ic_inf), f2(pan_met$ic_sup), fp(pan_met$p)), "",
  "## 3. Conjuntos finais (regra escolhida e genes com todos os estudos)", "", sapply(split(fin, fin$conjunto), function(x) sprintf("- **%s** (%s): %s", x$conjunto[1], x$regra[1], paste(sprintf("%s%s", x$gene, ifelse(x$sentido == "maior no DM2", "↑", "↓")), collapse = ", "))), "",
  "A AUC honesta de cada conjunto final é a da otimização aninhada (seções 1 e 2), não a do conjunto aplicado aos mesmos dados.")
writeLines(linhas, file.path(pasta("docs"), "validacao_10b_roc_otimizada.md"), useBytes = TRUE)
gravar_docx(Filter(Negate(is.null), list(
  list(tipo = "p", texto = sprintf("Gerado em %s a partir de output/10_roc/otimizada_*.csv.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
  list(tipo = "h2", texto = "1. Objetivo e cuidado"),
  list(tipo = "p", texto = "Pedido do usuário (09/10/2026): otimizar o conjunto de genes da curva ROC e procurar o conjunto que melhor separa DM2 de sem diabetes em todos os tecidos. Escolher o conjunto pela maior AUC nos mesmos dados em que ela é medida dá AUC alta quase garantida; por isso a otimização é ANINHADA: a regra (fonte e tamanho) é escolhida deixando um estudo de fora dentro do treino e só depois avaliada no estudo escondido. Para todos os tecidos, um tecido inteiro é escondido."),
  list(tipo = "b", itens = c("Regras: genes do módulo escolhido no treino ou do genoma inteiro, com 10, 20, 50 ou 100 genes, ordenados pelo p do treino e com o mesmo sentido em todos os estudos de treino.",
                             "Tecidos com 2 estudos (músculo): com 1 estudo de treino não há como escolher a regra por dentro; usa-se a regra padrão da etapa 10 (módulo, 20 genes).",
                             "Tecido com 1 estudo (fígado, GSE130991): validação cruzada aninhada dentro do estudo (seção 2b).",
                             "Conjunto comum: genes do genoma medidos em pelo menos 80% dos estudos de treino e com o mesmo sentido em pelo menos 80% deles.")),
  list(tipo = "h2", texto = "2. Por tecido"),
  list(tipo = "tabela", df = data.frame(Tecido = cmp$tecido, `Estudo testado` = cmp$estudo_testado, `Regra (treino)` = cmp$regra, `AUC otimizada` = f2(cmp$auc_otimizada), `AUC padrão` = f2(cmp$auc_padrao), check.names = FALSE)),
  list(tipo = "tabela", df = data.frame(Tecido = met$tecido, `AUC combinada otimizada (IC 95%)` = sprintf("%s (%s a %s)", f2(met$auc), f2(met$ic_inf), f2(met$ic_sup)), p = fp(met$p), check.names = FALSE)),
  list(tipo = "img", arq = "docs/figuras/roc_otimizada.png", largura = 6.5, altura = 3.1, nota = "Esquerda: AUC de cada estudo testado com a regra padrão × com a regra otimizada no treino. Direita: conjunto comum, deixando um tecido inteiro de fora."),
  list(tipo = "h2", texto = "2b. Fígado: validação cruzada aninhada dentro do GSE130991"),
  list(tipo = "p", texto = "Com 1 estudo, a otimização usa partes do GSE130991 (10/10/2026): em cada uma das 5 partes externas, a regra é escolhida por uma validação cruzada interna de 5 partes feita só com as outras 4, e depois os genes são escolhidos com as 4 e testados na parte externa. Repetido 10 vezes. A AUC padrão é a da mesma divisão com a regra da etapa 10 (módulo de menor p, genes com p < 0,05)."),
  if (!is.null(cvo_res)) list(tipo = "tabela", df = data.frame(Estudo = cvo_res$estudo, Repetições = cvo_res$repeticoes, `AUC otimizada mediana (IC 95%)` = sprintf("%s (%s a %s)", f2(cvo_res$auc_otimizada_mediana), f2(cvo_res$ic_inf), f2(cvo_res$ic_sup)),
                                                               `AUC otimizada mín.–máx.` = sprintf("%s–%s", f2(cvo_res$auc_otimizada_min), f2(cvo_res$auc_otimizada_max)), p = fp(cvo_res$p_wilcoxon), `AUC padrão (mediana)` = f2(cvo_res$auc_padrao_mediana), check.names = FALSE)) else NULL,
  if (!is.null(cvo)) list(tipo = "tabela", df = data.frame(Repetição = cvo$repeticao, `Regras escolhidas nas 5 partes` = cvo$regras_escolhidas, `AUC otimizada` = f2(cvo$auc_otimizada), `AUC padrão` = f2(cvo$auc_padrao), check.names = FALSE)) else NULL,
  list(tipo = "h2", texto = "3. Conjunto comum a todos os tecidos"),
  list(tipo = "tabela", df = data.frame(`Tecido testado` = pan$tecido_testado, Estudo = pan$estudo, Regra = pan$regra, `AUC (IC 95%)` = sprintf("%s (%s a %s)", f2(pan$auc), f2(pan$ic_inf), f2(pan$ic_sup)), check.names = FALSE)),
  list(tipo = "tabela", df = data.frame(Conjunto = pan_met$tecido, `AUC combinada (IC 95%)` = sprintf("%s (%s a %s)", f2(pan_met$auc), f2(pan_met$ic_inf), f2(pan_met$ic_sup)), p = fp(pan_met$p), check.names = FALSE)),
  list(tipo = "h2", texto = "4. Conjuntos finais"),
  list(tipo = "tabela", df = do.call(rbind, lapply(split(fin, fin$conjunto), function(x) data.frame(Conjunto = x$conjunto[1], Regra = x$regra[1], Genes = paste(sprintf("%s%s", x$gene, ifelse(x$sentido == "maior no DM2", "↑", "↓")), collapse = ", ")))),
       nota = "Genes escolhidos com todos os estudos pela regra que venceu no deixar-um-de-fora. A AUC honesta é a das seções 2 e 3."),
  list(tipo = "h2", texto = "5. Arquivos"),
  list(tipo = "b", itens = c("Código: R/10b_roc_otimizada.R; execução: run_10b_roc_otimizada.R.", "Saídas: output/10_roc/otimizada_*.csv; figura docs/figuras/roc_otimizada.png; validação docs/validacao_10b_roc_otimizada.md.")))),
  "docs/etapa_10b_roc_otimizada.docx", "Etapa 10b — Curva ROC com otimização aninhada do conjunto de genes", etapa = "10")
