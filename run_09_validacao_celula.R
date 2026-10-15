###############################################################################
#  run_09_validacao_celula.R - ETAPA 09: validação do programa das ilhotas com célula única
#  Uso: "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_09_validacao_celula.R
#  Requer as etapas 04 a 08. Saídas: output/09_validacao_celula/*.csv, docs/figuras/validacao_*.png,
#  docs/validacao_09_celula.md, docs/etapa_09_validacao_celula.docx
###############################################################################
suppressPackageStartupMessages({ library(dplyr) })
for (f in c("R/00_utils.R", "R/04_processamento.R", "R/05_meta.R", "R/06_redes.R", "R/09_validacao_celula.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
MC <- ler_config("config/meta.yaml"); RC <- ler_config("config/redes.yaml"); VC <- ler_config("config/validacao.yaml"); P0 <- ler_config("config/processamento.yaml")
options(vias_competitivo = !isFALSE(MC$vias$competitivo))
inv_all <- utils::read.csv("output/04_processamento/inventario.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
codif <- if (isTRUE(MC$so_codificantes)) genes_codificantes() else NULL
d <- pasta("output", "09_validacao_celula"); pasta("docs", "figuras")
le <- function(f) if (file.exists(f) && file.size(f) > 5) utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8") else NULL
f2 <- function(x, k = 2) ifelse(is.na(x), "-", formatC(x, format = "f", digits = k, decimal.mark = ","))
fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))

# genes do programa das ilhotas: painel (etapa 08) + genes do módulo M6 com kME alto
pan <- le("output/08_painel/painel.csv"); pan <- pan[pan$tecido == "ilhotas", ]
rede <- readRDS("output/06_redes/ilhotas/rede_cache.rds"); cores <- rede$cores
msel <- le("output/06_redes/ilhotas/meta_modulos.csv"); msel$selecao[is.na(msel$selecao)] <- ""; mod_prog <- msel$id[nzchar(msel$selecao)]
if (!length(mod_prog)) {   # nenhum módulo selecionado (09/10/2026): usa o módulo onde caem mais genes do painel das ilhotas
  mods_p <- paste0("M", cores[intersect(pan$gene, names(cores))]); mods_p <- mods_p[mods_p != "M0"]
  if (length(mods_p)) { mod_prog <- names(sort(table(mods_p), decreasing = TRUE))[1]; log_msg("ETAPA 09 | nenhum módulo selecionado nas ilhotas; usado o %s, que reúne mais genes do painel", mod_prog) } }
prog_genes <- unique(pan$gene)
log_msg("ETAPA 09 | programa das ilhotas: módulo(s) %s; %d genes do painel", paste(mod_prog, collapse = ", "), length(prog_genes))

# ---------------- 9.1 pseudo-bulk por doadora x tipo celular ----------------
arq_c <- file.path(P0$cache, "pb_tipo_GSE221156.rds")
ass <- unname(tools::md5sum(VC$h5ad)); P <- if (file.exists(arq_c)) readRDS(arq_c) else NULL
if (is.null(P) || !identical(P$assinatura, list(ass, VC$tipos))) { P <- pseudobulk_por_tipo(VC); P$assinatura <- list(ass, VC$tipos); saveRDS(P, arq_c) }
qc <- le(file.path("output/04_processamento", VC$gse_referencia, "amostras_qc.csv"))
P$col$individuo <- paste0(VC$gse_referencia, ":", P$col$doador)
P$col <- cbind(P$col, qc[match(P$col$individuo, qc$individuo), c("sexo", "idade", "status", "mulher_40a60", "mantida")])
log_msg("ETAPA 09 | pseudo-bulk por tipo: %d doadoras x tipos, %d tipos, %d células", ncol(P$cnt), length(unique(P$col$tipo)), sum(P$col$n_celulas))
ref <- referencia_tipos(VC, P)

# 9.1a onde os genes do programa são expressos (CPM médio por tipo, todas as doadoras)
loc <- ref$cpm[intersect(prog_genes, rownames(ref$cpm)), , drop = FALSE]
loc_tab <- data.frame(gene = rownames(loc), round(loc, 1), tipo_maior = colnames(loc)[apply(loc, 1, which.max)],
                      frac_no_tipo_maior = round(apply(loc, 1, function(v) max(v) / sum(v)), 2), check.names = FALSE)
escrever_csv(loc_tab, file.path(d, "localizacao_genes.csv"))

# 9.1b composição verdadeira nas mulheres de 40-60 (DM2 x ND)
comp <- P$comp / rowSums(P$comp); comp$individuo <- paste0(VC$gse_referencia, ":", rownames(comp))
comp <- merge(comp, qc[, c("individuo", "sexo", "idade", "status", "mulher_40a60", "mantida")], by = "individuo")
cm <- comp[comp$mulher_40a60 %in% TRUE & comp$status %in% c("T2D", "ND") & comp$mantida %in% TRUE, ]
tipos <- names(VC$tipos)
comp_tab <- data.frame(tipo = tipos, DM2 = sapply(tipos, function(t) round(100 * mean(cm[[t]][cm$status == "T2D"]), 1)), ND = sapply(tipos, function(t) round(100 * mean(cm[[t]][cm$status == "ND"]), 1)),
                       p_wilcoxon = sapply(tipos, function(t) suppressWarnings(stats::wilcox.test(cm[[t]][cm$status == "T2D"], cm[[t]][cm$status == "ND"])$p.value)), row.names = NULL)
escrever_csv(comp_tab, file.path(d, "composicao_verdadeira_GSE221156.csv"))

# 9.1c efeito do DM2 dentro de cada tipo (voom; contraste mulheres 40-60 DM2 x ND; variância com todas as doadoras do tipo)
dentro <- list(); mod_tipo <- list()
for (t in tipos) {
  cc <- P$col[P$col$tipo == t & P$col$n_celulas >= VC$min_celulas_tipo & P$col$mantida %in% TRUE & P$col$status %in% c("T2D", "ND"), ]
  if (sum(cc$mulher_40a60 %in% TRUE & cc$status == "T2D") < 2 || sum(cc$mulher_40a60 %in% TRUE & cc$status == "ND") < 2) { log_msg("ETAPA 09 | %s: menos de 2 mulheres de 40-60 por grupo com >= %d células", t, VC$min_celulas_tipo); next }
  cnt <- P$cnt[, cc$coluna, drop = FALSE]; if (!is.null(codif)) cnt <- cnt[rownames(cnt) %in% codif, , drop = FALSE]
  am <- data.frame(coluna = cc$coluna, individuo = cc$individuo, sexo = cc$sexo, idade = cc$idade, status = cc$status, mulher_40a60 = cc$mulher_40a60, lote = NA_character_)
  est <- list(gse = VC$gse_referencia, tecido = "ilhotas", tipo = "pseudobulk_h5ad", am = am, cnt = cnt, ex = edgeR::cpm(cnt, log = TRUE, prior.count = 1))
  r <- tryCatch(ajustar(MC, est, metodo = "voom", so_alvo = FALSE), error = function(e) { log_msg("ETAPA 09 | %s: %s", t, conditionMessage(e)); NULL })
  if (!is.null(r)) { x <- r[r$id %in% prog_genes, ]; if (nrow(x)) dentro[[t]] <- data.frame(tipo = t, x[, c("id", "g", "p", "n1", "n2")]) }
  # escore de cada módulo da rede das ilhotas dentro do tipo
  ex <- est$ex[rowMeans(est$ex) > 1, , drop = FALSE]; z <- t(scale(t(ex))); z <- z[stats::complete.cases(z), , drop = FALSE]
  S <- t(sapply(split(names(cores), cores), function(g) { g <- intersect(g, rownames(z)); if (length(g) >= 10) colMeans(z[g, , drop = FALSE]) else rep(NA_real_, ncol(z)) }))
  rownames(S) <- paste0("M", rownames(S)); S <- S[rownames(S) != "M0" & stats::complete.cases(S), , drop = FALSE]; colnames(S) <- colnames(ex)
  rm_ <- tryCatch(ajustar(MC, est, Y = S, metodo = "limma", so_alvo = FALSE), error = function(e) NULL)
  if (!is.null(rm_)) mod_tipo[[t]] <- data.frame(tipo = t, rm_[rm_$id %in% mod_prog, c("id", "g", "p", "n1", "n2")])
}
dentro <- do.call(rbind, dentro); mod_tipo <- do.call(rbind, mod_tipo)
if (!is.null(dentro)) escrever_csv(dentro, file.path(d, "efeito_dentro_dos_tipos.csv"))
if (!is.null(mod_tipo)) escrever_csv(mod_tipo, file.path(d, "modulo_dentro_dos_tipos.csv"))

# ---------------- 9.2 deconvolução ----------------
# validação no próprio GSE221156: pseudo-bulk total (soma dos tipos) x composição verdadeira
tot <- sapply(split(P$col$coluna, P$col$doador), function(cl) rowSums(P$cnt[, cl, drop = FALSE]))
Fv <- deconvoluir(tot, ref); verd <- as.matrix(P$comp[rownames(Fv), colnames(Fv)]); verd <- verd / rowSums(verd)
val <- data.frame(tipo = colnames(Fv), verdadeira_media = round(100 * colMeans(verd), 1), estimada_media = round(100 * colMeans(Fv), 1),
                  correlacao = round(sapply(colnames(Fv), function(t) suppressWarnings(stats::cor(Fv[, t], verd[, t]))), 2),
                  erro_medio_pp = round(100 * colMeans(abs(Fv - verd)), 1), row.names = NULL)
escrever_csv(val, file.path(d, "deconvolucao_validacao.csv"))
log_msg("ETAPA 09 | deconvolução validada no GSE221156 (%d marcadores): correlação estrelada %.2f, beta %.2f, alfa %.2f", attr(Fv, "marcadores_usados"),
        val$correlacao[val$tipo == "estrelada"], val$correlacao[val$tipo == "beta"], val$correlacao[val$tipo == "alfa"])

fr_est <- list(); comp_est <- list(); ajus <- list()
Yprog <- function(est, am) { Eg <- eigengenes_estudo(est$ex[, am$coluna, drop = FALSE], cores); Eg <- Eg[rownames(Eg) %in% mod_prog, , drop = FALSE]
  G <- est$ex[intersect(prog_genes, rownames(est$ex)), am$coluna, drop = FALSE]; rbind(Eg, G) }
for (g in unlist(VC$estudos_deconvolucao)) {
  est <- carregar_estudo(g, inv_all, NULL, codif)
  Y <- if (!is.null(est$cnt)) est$cnt else 2^est$ex
  Fr <- deconvoluir(Y[, est$am$coluna, drop = FALSE], ref); fr_est[[g]] <- data.frame(gse = g, coluna = rownames(Fr), round(Fr, 4), check.names = FALSE)
  # composição DM2 x ND nas mulheres de 40-60 (mesmo modelo da etapa 05, sobre as proporções em %)
  Yc <- t(100 * Fr); Yc <- Yc[apply(Yc, 1, stats::sd) > 0, , drop = FALSE]
  comp_est[[g]] <- tryCatch(ajustar(MC, est, Y = Yc, metodo = "limma", so_alvo = TRUE), error = function(e) NULL)
  # programa (eigengene do módulo + genes do painel) sem e com ajuste pela proporção de células estreladas
  Yp <- Yprog(est, est$am); cov <- Fr[est$am$coluna, unlist(VC$ajuste_tipos), drop = FALSE]
  for (so in c(TRUE, FALSE)) for (aj in c(FALSE, TRUE)) {
    r <- tryCatch(ajustar(MC, est, Y = Yp, metodo = "limma", so_alvo = so, covar = if (aj) cov else NULL), error = function(e) NULL)
    if (!is.null(r)) ajus[[length(ajus) + 1]] <- data.frame(gse = g, modelo = if (so) "só mulheres 40-60" else "variância com todas as amostras", ajuste = if (aj) "com proporção de estreladas" else "sem ajuste", r[, c("id", "g", "var_g", "p", "n1", "n2", "logFC", "t")], metodo = "limma")
  }
}
fr_est <- do.call(rbind, fr_est); escrever_csv(fr_est, file.path(d, "proporcoes_estimadas.csv"))
ajus <- do.call(rbind, ajus); escrever_csv(ajus, file.path(d, "programa_ajustado_estudos.csv"))
# comparação justa (revisão de 08/10/2026): "sem ajuste" nos MESMOS estudos em que o ajuste foi possível (o GSE86469, com
# 8 amostras, não tem graus de liberdade para a covariável); o "sem ajuste" com todos os estudos fica como referência
for (mo in unique(ajus$modelo)) { com <- unique(ajus$gse[ajus$modelo == mo & ajus$ajuste == "com proporção de estreladas"])
  x <- ajus[ajus$modelo == mo & ajus$ajuste == "sem ajuste" & ajus$gse %in% com, ]; if (nrow(x)) { x$ajuste <- "sem ajuste (mesmos estudos)"; ajus <- rbind(ajus, x) } }
estudos_ajuste <- tapply(ajus$gse[ajus$ajuste == "com proporção de estreladas"], ajus$modelo[ajus$ajuste == "com proporção de estreladas"], function(z) paste(sort(unique(z)), collapse = ", "))
# meta-análise (Hartung-Knapp) da composição e do programa, sem e com ajuste
comp_meta <- meta_tecido(Filter(Negate(is.null), comp_est), metodo = MC$meta_metodo)
escrever_csv(comp_meta, file.path(d, "composicao_meta.csv"))
prog_meta <- do.call(rbind, lapply(split(ajus, paste(ajus$modelo, ajus$ajuste)), function(x) { efs <- split(x, x$gse); m <- meta_tecido(efs, metodo = MC$meta_metodo)
  data.frame(modelo = x$modelo[1], ajuste = x$ajuste[1], m[, c("id", "estudos", "g", "ic_inf", "ic_sup", "p", "mesmo_sentido")]) }))
escrever_csv(prog_meta, file.path(d, "programa_ajustado_meta.csv"))

# ---------------- figuras ----------------
grDevices::png("docs/figuras/validacao_deconvolucao.png", width = 1800, height = 900, res = 160); op <- graphics::par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))
graphics::plot(100 * verd, 100 * Fv[, colnames(verd)], pch = 16, col = grDevices::adjustcolor(rep(seq_along(colnames(verd)), each = nrow(verd)), 0.7), xlab = "Proporção verdadeira (% de células)", ylab = "Proporção estimada (%)",
               main = "Deconvolução testada no GSE221156"); graphics::abline(0, 1, lty = 2, col = "grey40")
graphics::legend("topleft", colnames(verd), col = seq_along(colnames(verd)), pch = 16, cex = 0.7, bty = "n")
al <- do.call(rbind, lapply(unique(fr_est$gse), function(g) { e <- carregar_estudo(g, inv_all, NULL, NULL); a <- e$am[e$am$mulher_40a60 %in% TRUE & e$am$status %in% c("T2D", "ND"), ]
  f <- fr_est[fr_est$gse == g, ]; data.frame(gse = g, status = a$status, estrelada = 100 * f$estrelada[match(a$coluna, f$coluna)]) }))
al$grp <- factor(paste(al$gse, al$status), levels = unlist(lapply(unique(al$gse), function(g) paste(g, c("ND", "T2D")))))
graphics::boxplot(estrelada ~ grp, data = al, las = 2, cex.axis = 0.6, xlab = "", ylab = "Células estreladas estimadas (%)", main = "Estreladas: DM2 x ND (mulheres 40–60)",
                  col = rep(c("grey85", "#E8A3A3"), length(unique(al$gse))), border = "grey30", outline = FALSE)
graphics::stripchart(estrelada ~ grp, data = al, vertical = TRUE, add = TRUE, pch = 16, cex = 0.6, method = "jitter", col = "grey20")
graphics::par(op); grDevices::dev.off()
if (nrow(loc)) { z <- t(scale(t(log2(loc + 1)))); grDevices::png("docs/figuras/validacao_localizacao.png", width = 1500, height = 120 + 55 * nrow(z), res = 160)
  op <- graphics::par(mar = c(6, 6, 2, 1)); graphics::image(seq_len(ncol(z)), seq_len(nrow(z)), t(z), col = grDevices::hcl.colors(40, "Blues 3", rev = TRUE), axes = FALSE, xlab = "", ylab = "",
                                                            main = "Onde os genes do programa são expressos (z do log2 CPM)")
  graphics::axis(1, seq_len(ncol(z)), colnames(z), las = 2, cex.axis = 0.8, tick = FALSE); graphics::axis(2, seq_len(nrow(z)), rownames(z), las = 2, cex.axis = 0.75, tick = FALSE)
  graphics::par(op); grDevices::dev.off() }

# ---------------- relatório ----------------
pm <- function(mo, aj, id) { x <- prog_meta[prog_meta$modelo == mo & prog_meta$ajuste == aj & prog_meta$id == id, ]; if (nrow(x)) x else NULL }
cmp <- do.call(rbind, lapply(c(mod_prog, prog_genes), function(id) { a <- pm("variância com todas as amostras", "sem ajuste (mesmos estudos)", id); b <- pm("variância com todas as amostras", "com proporção de estreladas", id); a4 <- pm("variância com todas as amostras", "sem ajuste", id)
  a0 <- pm("só mulheres 40-60", "sem ajuste (mesmos estudos)", id); b0 <- pm("só mulheres 40-60", "com proporção de estreladas", id)
  data.frame(id = id, g_sem_todos_estudos = a4$g %||% NA, estudos_todos = a4$estudos %||% NA, g_sem = a$g %||% NA, p_sem = a$p %||% NA, g_com = b$g %||% NA, p_com = b$p %||% NA, estudos_com = b$estudos %||% NA,
             g_sem_principal = a0$g %||% NA, g_com_principal = b0$g %||% NA, estudos_com_principal = b0$estudos %||% NA) }))
cmp$reducao_pct <- round(100 * (1 - cmp$g_com / cmp$g_sem))
escrever_csv(cmp, file.path(d, "programa_sem_e_com_ajuste.csv"))
cs <- comp_meta[match(tipos, comp_meta$id), ]
linhas <- c("# Validação da etapa 09: programa das ilhotas com célula única", "", sprintf("Gerado em %s a partir de `output/09_validacao_celula/`.", format(Sys.time(), "%d/%m/%Y %H:%M")), "",
  "## 1. Onde os genes do programa são expressos (GSE221156, CPM médio por tipo, todas as doadoras)", "",
  "| Gene | Tipo com maior expressão | Fração nesse tipo |", "|---|---|---:|", sprintf("| %s | %s | %.2f |", loc_tab$gene, loc_tab$tipo_maior, loc_tab$frac_no_tipo_maior), "",
  "## 2. Composição verdadeira (GSE221156, mulheres de 40–60, % de células)", "",
  "| Tipo | DM2 | ND | p (Wilcoxon) |", "|---|---:|---:|---:|", sprintf("| %s | %.1f | %.1f | %s |", comp_tab$tipo, comp_tab$DM2, comp_tab$ND, fp(comp_tab$p_wilcoxon)), "",
  "## 3. Efeito do DM2 dentro de cada tipo celular (GSE221156)", "",
  if (!is.null(mod_tipo)) c("| Tipo | Módulo | g | p | DM2/ND |", "|---|---|---:|---:|---|", sprintf("| %s | %s | %.2f | %s | %d/%d |", mod_tipo$tipo, mod_tipo$id, mod_tipo$g, fp(mod_tipo$p), mod_tipo$n1, mod_tipo$n2)) else "Sem tipos testáveis.", "",
  "## 4. Deconvolução: teste no GSE221156 (composição conhecida)", "",
  "| Tipo | Verdadeira (%) | Estimada (%) | Correlação | Erro médio (pp) |", "|---|---:|---:|---:|---:|", sprintf("| %s | %.1f | %.1f | %s | %.1f |", val$tipo, val$verdadeira_media, val$estimada_media, f2(val$correlacao), val$erro_medio_pp), "",
  "## 5. Composição estimada DM2 x ND (meta-análise dos estudos de ilhotas, mulheres de 40–60)", "",
  "| Tipo | Estudos | g (IC 95%) | p | Mesmo sentido |", "|---|---:|---|---:|---|", sprintf("| %s | %d | %.2f (%.2f a %.2f) | %s | %d/%d |", cs$id, cs$estudos, cs$g, cs$ic_inf, cs$ic_sup, fp(cs$p), cs$mesmo_sentido, cs$estudos), "",
  "## 6. Programa sem e com ajuste pela proporção de células estreladas (meta-análise)", "",
  "| Módulo/gene | g sem ajuste | p | g com ajuste | p | Redução do efeito |", "|---|---:|---:|---:|---:|---:|",
  sprintf("| %s | %s | %s | %s | %s | %s%% |", cmp$id, f2(cmp$g_sem), fp(cmp$p_sem), f2(cmp$g_com), fp(cmp$p_com), cmp$reducao_pct), "",
  sprintf("Modelo com a variância estimada em todas as amostras do estudo (o contraste continua sendo só mulheres de 40–60, DM2 × ND), para haver graus de liberdade para a covariável. Sem e com ajuste comparados nos MESMOS estudos (%s); o GSE86469 (8 amostras) não comporta a covariável. Na tabela CSV, g_sem_todos_estudos traz o efeito sem ajuste com os 4 estudos.", estudos_ajuste[["variância com todas as amostras"]] %||% "-"))
writeLines(linhas, file.path(pasta("docs"), "validacao_09_celula.md"), useBytes = TRUE)
log_msg("ETAPA 09 | relatório: docs/validacao_09_celula.md")

blocos <- list(
  list(tipo = "p", texto = sprintf("Gerado em %s a partir de config/validacao.yaml e output/09_validacao_celula/.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
  list(tipo = "h2", texto = "1. Objetivo"),
  list(tipo = "p", texto = "Validar o programa estromal das ilhotas (módulo M6 e genes do painel) com os dados de célula única (pedido do usuário, 08/10/2026). Os estudos de célula única concordavam pouco com os arrays no efeito do DM2, e o pseudo-bulk de todas as células não separa duas explicações: (a) os genes mudam DENTRO das células; (b) a amostra tem mais células estromais (composição). Dois métodos: pseudo-bulk por tipo celular no GSE221156 e deconvolução dos estudos de ilhotas com referência de célula única."),
  list(tipo = "h2", texto = "2. Métodos e decisões"),
  list(tipo = "b", itens = c(
    sprintf("Pseudo-bulk por doadora × tipo celular: soma das contagens brutas das células de cada tipo (anotação '%s' do h5ad do CELLxGENE, agrupada em %d tipos: %s). Doadora × tipo com menos de %d células fica fora do teste daquele tipo.", VC$campo_tipo, length(tipos), paste(tipos, collapse = ", "), VC$min_celulas_tipo),
    "Efeito dentro de cada tipo: voom, contraste DM2 × ND só nas mulheres de 40–60; a variância usa todas as doadoras do tipo (como a sensibilidade 'todas as amostras' da etapa 05), porque só há 2 × 4 mulheres de 40–60.",
    sprintf("Referência da deconvolução: CPM de cada tipo somando todas as doadoras; marcadores = genes com CPM ≥ %d no tipo e pelo menos %dx o maior dos outros tipos (até %d por tipo).", VC$marcadores$cpm_min, 2^VC$marcadores$log2_razao_min, VC$marcadores$por_tipo),
    "Deconvolução por mínimos quadrados não negativos (NNLS): a expressão de cada amostra (escala linear, normalizada como CPM) é explicada como mistura dos perfis dos tipos; os coeficientes (fração do RNA) são divididos pelo RNA por célula de cada tipo para virar fração de células.",
    "O método foi testado antes no próprio GSE221156, somando os tipos de cada doadora e comparando a composição estimada com a contagem real de células.",
    sprintf("Composição DM2 × ND: mesmo modelo e meta-análise (Hartung-Knapp) da etapa 05, sobre as proporções estimadas, nos estudos %s.", paste(unlist(VC$estudos_deconvolucao), collapse = ", ")),
    sprintf("Efeito ajustado: eigengene do módulo e genes do painel com e sem a proporção de %s como covariável; meta-análise dos dois.", paste(unlist(VC$ajuste_tipos), collapse = ", ")))),
  list(tipo = "h2", texto = "3. Onde os genes do programa são expressos"),
  list(tipo = "tabela", df = data.frame(Gene = loc_tab$gene, `Tipo com maior expressão` = loc_tab$tipo_maior, `Fração nesse tipo` = f2(loc_tab$frac_no_tipo_maior), check.names = FALSE)),
  if (file.exists("docs/figuras/validacao_localizacao.png")) list(tipo = "img", arq = "docs/figuras/validacao_localizacao.png", largura = 6, altura = min(8, 0.6 + 0.33 * nrow(loc))) else list(tipo = "p", texto = ""),
  list(tipo = "h2", texto = "4. Composição verdadeira no GSE221156 (mulheres de 40–60)"),
  list(tipo = "tabela", df = data.frame(Tipo = comp_tab$tipo, `DM2 (%)` = f2(comp_tab$DM2, 1), `ND (%)` = f2(comp_tab$ND, 1), `p (Wilcoxon)` = fp(comp_tab$p_wilcoxon), check.names = FALSE),
       nota = "2 mulheres com DM2 e 4 sem diabetes: descritivo."),
  list(tipo = "h2", texto = "5. Efeito do DM2 dentro de cada tipo celular"),
  if (!is.null(mod_tipo)) list(tipo = "tabela", df = data.frame(Tipo = mod_tipo$tipo, `Módulo` = mod_tipo$id, g = f2(mod_tipo$g), p = fp(mod_tipo$p), `DM2/ND` = sprintf("%d/%d", mod_tipo$n1, mod_tipo$n2), check.names = FALSE)) else list(tipo = "p", texto = "Sem tipos testáveis."),
  list(tipo = "h2", texto = "6. Deconvolução: teste no GSE221156"),
  list(tipo = "tabela", df = data.frame(Tipo = val$tipo, `Verdadeira (%)` = f2(val$verdadeira_media, 1), `Estimada (%)` = f2(val$estimada_media, 1), `Correlação` = f2(val$correlacao), `Erro médio (pp)` = f2(val$erro_medio_pp, 1), check.names = FALSE)),
  list(tipo = "img", arq = "docs/figuras/validacao_deconvolucao.png", largura = 6.5, altura = 3.25, nota = "Esquerda: composição estimada × verdadeira no GSE221156 (linha = igualdade). Direita: proporção estimada de células estreladas por estudo, DM2 × ND, nas mulheres de 40–60."),
  list(tipo = "h2", texto = "7. Composição estimada DM2 × ND (estudos de ilhotas)"),
  list(tipo = "tabela", df = data.frame(Tipo = cs$id, Estudos = cs$estudos, `g (IC 95%)` = sprintf("%s (%s a %s)", f2(cs$g), f2(cs$ic_inf), f2(cs$ic_sup)), p = fp(cs$p), `Mesmo sentido` = sprintf("%d/%d", cs$mesmo_sentido, cs$estudos), check.names = FALSE)),
  list(tipo = "h2", texto = "8. Programa sem e com ajuste pela proporção de células estreladas"),
  list(tipo = "tabela", df = data.frame(`Módulo/gene` = cmp$id, `g sem ajuste` = f2(cmp$g_sem), p = fp(cmp$p_sem), `g com ajuste` = f2(cmp$g_com), `p ` = fp(cmp$p_com), `Redução do efeito` = paste0(cmp$reducao_pct, "%"), check.names = FALSE),
       nota = sprintf("Meta-análise (Hartung-Knapp) nos MESMOS estudos sem e com ajuste (%s; o GSE86469, com 8 amostras, não comporta a covariável); modelo com a variância estimada em todas as amostras de cada estudo (o contraste continua sendo mulheres de 40–60, DM2 × ND). Redução grande = o efeito é em boa parte composição (mais células estreladas).", estudos_ajuste[["variância com todas as amostras"]] %||% "-")),
  list(tipo = "h2", texto = "9. Arquivos"),
  list(tipo = "b", itens = c("Código: R/09_validacao_celula.R; execução: run_09_validacao_celula.R; configuração: config/validacao.yaml.",
                             "Saídas: output/09_validacao_celula/{localizacao_genes, composicao_verdadeira_GSE221156, efeito_dentro_dos_tipos, modulo_dentro_dos_tipos, deconvolucao_validacao, proporcoes_estimadas, composicao_meta, programa_ajustado_estudos, programa_ajustado_meta, programa_sem_e_com_ajuste}.csv.",
                             "Figuras: docs/figuras/validacao_deconvolucao.png, validacao_localizacao.png. Validação: docs/validacao_09_celula.md.")))
gravar_docx(Filter(Negate(is.null), blocos), "docs/etapa_09_validacao_celula.docx", "Etapa 09 — Validação do programa das ilhotas com célula única", etapa = "09")
