###############################################################################
#  03_sexo_genetico.R - ETAPA 03: pré-análise de sexo genético
#
#  Intenção (pedido do usuário, 06/10/2026): resgatar o sexo dos estudos que saíram da etapa 02
#  só por não terem sexo nos metadados. O sexo é lido na expressão de XIST (alto em mulheres)
#  e de genes do cromossomo Y (expressos só em homens).
#   1. Candidatos: estudo x tecido "sem sexo" com idade e status, e pelo menos min_sem_sexo_por_grupo
#      amostras sem sexo de 40-60 com DM2 e com ND (se o sexo não fosse o obstáculo, entrariam).
#   2. Expressão: matriz normalizada do GEO (series matrix) e anotação da plataforma (GPL).
#   3. Duas leituras independentes:
#      (a) dentro da amostra: percentil de XIST e dos genes Y entre todos os genes da amostra
#          (F = XIST alto e Y baixo; M = Y alto e XIST baixo). Funciona com um só sexo no estudo.
#      (b) entre amostras: escore z(Y) - z(XIST) e dois grupos por k-means, aceitos só se bem
#          separados (mesmo método do workflow_multi_estruturado).
#   4. Aceite: (a) e (b) concordam; com um só sexo no estudo, vale (a) se quase todas concordam.
#   5. Elegibilidade refeita com o sexo genético onde o declarado falta.
#
#  Entrada : output/02_metadados/{elegibilidade.csv, amostras.csv}, config/sexo_genetico.yaml
#  Saída   : output/03_sexo_genetico/{candidatos.csv, sexo_amostras.csv, resumo_estudos.csv,
#            elegibilidade_resgate.csv}, docs/figuras/sexo_genetico.png
###############################################################################

candidatos_sexo <- function(S, el) {
  m <- S$candidatos$min_sem_sexo_por_grupo
  x <- el[el$categoria %in% unlist(S$candidatos$categorias) & el$sem_sexo_40a60_T2D >= m & el$sem_sexo_40a60_ND >= m, ]
  x[order(-(x$sem_sexo_40a60_T2D + x$sem_sexo_40a60_ND)), ]
}

# Símbolo do gene a partir da anotação da plataforma (colunas variam entre plataformas)
simbolos_gpl <- function(fd) {
  nm <- names(fd)
  col <- nm[grepl("^(gene[ _.]?symbol|symbol|symbol v[0-9]+|ilmn_gene|genesymbol)$", nm, ignore.case = TRUE)][1]   # "Symbol v12": GPL10775
  if (!is.na(col)) return(gsub(" */// *", ";", trimws(as.character(fd[[col]]))))
  # gene_assignment (Affymetrix Gene/HTA/Clariom): "NM_x // SIMBOLO // ... /// NR_y // SIMBOLO2 // ..."
  # uma sonda pode listar vários genes: guarda todos (XIST não é sempre o primeiro na GPL6244)
  col <- nm[grepl("^gene_assignment$", nm, ignore.case = TRUE)][1]
  if (!is.na(col)) return(vapply(strsplit(as.character(fd[[col]]), " /// ", fixed = TRUE), function(blocos)
    paste(unique(trimws(vapply(strsplit(blocos, " // ", fixed = TRUE), function(z) if (length(z) >= 2) z[2] else "", ""))), collapse = ";"), ""))
  rep(NA_character_, nrow(fd))
}

# Matriz de expressão (sondas x GSM) e símbolos; uma série pode ter mais de uma plataforma
ler_matriz_geo <- function(S, gse) {
  op <- options(timeout = S$dados$timeout_seg); on.exit(options(op))
  es <- tryCatch(suppressMessages(GEOquery::getGEO(gse, GSEMatrix = TRUE, getGPL = TRUE, destdir = pasta(S$dados$pasta_cache))),
                 error = function(e) { log_msg("ETAPA 03 | %s: erro ao ler a matriz (%s)", gse, conditionMessage(e)); NULL })
  if (is.null(es)) return(NULL)
  lapply(es, function(e) list(ex = Biobase::exprs(e), simbolo = simbolos_gpl(Biobase::fData(e)), gpl = Biobase::annotation(e)))
}

# Leituras (a) e (b) para uma matriz
ler_sexo <- function(S, ex, simbolo) {
  G <- S$genes; R <- S$regras
  sem_dados <- colnames(ex)[colMeans(is.na(ex)) > 0.5]                 # amostra sem valores na matriz do GEO
  ex <- ex[, !colnames(ex) %in% sem_dados, drop = FALSE]
  ok <- stats::complete.cases(ex); ex <- ex[ok, , drop = FALSE]; simbolo <- simbolo[ok]
  if (max(ex, na.rm = TRUE) > 100) ex <- log2(pmax(ex, 0) + 1)          # escala linear -> log2
  tem_gene <- function(g) grepl(paste0("(^|;)", g, "(;|$)"), simbolo)
  y <- Filter(function(g) any(tem_gene(g)), unlist(G$cromossomo_y)); x <- Filter(function(g) any(tem_gene(g)), unlist(G$cromossomo_x))
  base <- data.frame(gsm = colnames(ex), genes_y = length(y), xist = length(x) > 0, sem_dados = FALSE)
  if (length(y) < G$min_genes_y) { base$sexo_a <- NA; base$sexo_b <- NA; base$p_xist <- NA; base$p_y <- NA; base$escore <- NA
    return(list(amostras = base, separacao = NA_real_, motivo = "genes de sexo insuficientes na plataforma")) }
  # (a) percentil dentro da amostra; gene com várias sondas: a sonda de maior valor
  pct <- apply(ex, 2, function(v) rank(v, ties.method = "average") / length(v))
  por_gene <- function(g) apply(pct[tem_gene(g), , drop = FALSE], 2, max)
  p_y <- apply(sapply(y, por_gene), 1, stats::median)
  if (length(x)) {
    p_x <- por_gene(x)
    a <- ifelse(p_x >= R$xist_alto & p_y <= R$y_nao_alto, "F", ifelse(p_y >= R$y_alto & p_x <= R$xist_nao_alto, "M", NA_character_))
  } else {                                                              # plataforma sem XIST: só Y
    p_x <- rep(NA_real_, ncol(ex))
    a <- ifelse(p_y >= R$y_so_alto, "M", ifelse(p_y <= R$y_so_baixo, "F", NA_character_))
  }
  # (b) escore entre amostras (log da sonda de maior média por gene)
  val <- function(g) { k <- which(tem_gene(g)); k <- k[which.max(rowMeans(ex[k, , drop = FALSE]))]; ex[k, ] }
  zz <- function(gs) rowMeans(scale(sapply(gs, val)), na.rm = TRUE)
  esc <- if (length(x)) zz(y) - zz(x) else zz(y)
  b <- rep(NA_character_, length(esc)); sep <- NA_real_
  if (length(unique(round(esc, 6))) >= 3) {
    km <- stats::kmeans(esc, centers = range(esc))
    dp <- sqrt(sum(km$withinss) / max(1, length(esc) - 2)); sep <- diff(range(km$centers)) / max(dp, 1e-6)
    if (sep >= R$separacao_min) b <- ifelse(km$cluster == which.max(km$centers), "M", "F")
  }
  base$p_xist <- round(p_x, 3); base$p_y <- round(p_y, 3); base$escore <- round(esc, 3); base$sexo_a <- a; base$sexo_b <- b
  if (length(sem_dados)) base <- rbind(base, data.frame(gsm = sem_dados, genes_y = length(y), xist = length(x) > 0, sem_dados = TRUE, p_xist = NA, p_y = NA, escore = NA, sexo_a = NA, sexo_b = NA))
  list(amostras = base, separacao = round(sep, 1), motivo = "")
}

# Decisão por estudo: concordância entre (a) e (b), ou (a) quase unânime quando há um só sexo
decidir_sexo <- function(S, s) {
  R <- S$regras; d <- s$amostras
  if (all(is.na(d$sexo_a)) && all(is.na(d$sexo_b))) { d$sexo_genetico <- NA_character_; return(list(amostras = d, decisao = "não avaliável", detalhe = s$motivo)) }
  dois <- any(!is.na(d$sexo_b))
  if (!d$xist[1]) {                                                     # sem XIST: só a leitura (b), validada a 96-99%
    if (dois) { d$sexo_genetico <- d$sexo_b
      return(list(amostras = d, decisao = "resgatado (dois sexos, só genes Y)", detalhe = sprintf("plataforma sem XIST; separação %.1f DP", s$separacao))) }
    d$sexo_genetico <- NA_character_
    return(list(amostras = d, decisao = "não resgatado", detalhe = sprintf("plataforma sem XIST e sem dois grupos (separação %.1f DP): um só sexo não é decidível só com Y", s$separacao)))
  }
  if (dois) {
    ambos <- !is.na(d$sexo_a) & !is.na(d$sexo_b); conc <- if (any(ambos)) mean(d$sexo_a[ambos] == d$sexo_b[ambos]) else NA
    if (!is.na(conc) && conc >= R$concordancia_min) {
      d$sexo_genetico <- ifelse(is.na(d$sexo_a) | d$sexo_a == d$sexo_b, d$sexo_b, NA)     # discordante fica sem sexo
      return(list(amostras = d, decisao = "resgatado (dois sexos)", detalhe = sprintf("separação %.1f DP; concordância (a)x(b) %.0f%%", s$separacao, 100 * conc)))
    }
    d$sexo_genetico <- NA_character_
    return(list(amostras = d, decisao = "não resgatado", detalhe = sprintf("leituras (a) e (b) discordam (concordância %.0f%%)", 100 * conc)))
  }
  tab <- table(d$sexo_a); dom <- names(tab)[which.max(tab)]; frac <- max(tab) / nrow(d)
  if (frac >= R$concordancia_min) {
    d$sexo_genetico <- ifelse(d$sexo_a %in% dom, dom, NA)
    return(list(amostras = d, decisao = sprintf("resgatado (um só sexo: %s)", dom), detalhe = sprintf("%.0f%% das amostras lidas como %s; sem dois grupos (separação %.1f DP)", 100 * frac, dom, s$separacao)))
  }
  d$sexo_genetico <- NA_character_
  list(amostras = d, decisao = "não resgatado", detalhe = sprintf("sem dois grupos e leitura (a) dividida (%s)", paste(sprintf("%s %d", names(tab), as.integer(tab)), collapse = ", ")))
}

# Processa os candidatos
sexo_genetico_estudos <- function(S, cand, so_gpl = NULL) {
  res <- list(); resumo <- list()
  for (g in unique(cand$gse)) {
    mats <- ler_matriz_geo(S, g)
    if (is.null(mats)) { resumo[[g]] <- data.frame(gse = g, gpl = NA, n = NA, genes_y = NA, xist = NA, separacao = NA, decisao = "não avaliável", detalhe = "matriz não lida"); next }
    if (!is.null(so_gpl)) mats <- Filter(function(m) m$gpl %in% so_gpl[cand$gse == g], mats)
    for (m in mats) {
      if (!ncol(m$ex) || all(is.na(m$ex))) { resumo[[paste(g, m$gpl)]] <- data.frame(gse = g, gpl = m$gpl, n = ncol(m$ex), genes_y = NA, xist = NA, separacao = NA, decisao = "não avaliável", detalhe = "matriz vazia no GEO"); next }
      s <- ler_sexo(S, m$ex, m$simbolo); dd <- decidir_sexo(S, s)
      dd$amostras$gse <- g; dd$amostras$gpl <- m$gpl; res[[paste(g, m$gpl)]] <- dd$amostras
      resumo[[paste(g, m$gpl)]] <- data.frame(gse = g, gpl = m$gpl, n = ncol(m$ex), genes_y = s$amostras$genes_y[1], xist = s$amostras$xist[1],
                                              separacao = s$separacao, decisao = dd$decisao, detalhe = dd$detalhe)
      log_msg("ETAPA 03 | %s %s: %s (%s)", g, m$gpl, dd$decisao, dd$detalhe)
    }
  }
  list(amostras = do.call(rbind, res), resumo = do.call(rbind, resumo))
}

# Validação: estudos COM sexo declarado nas plataformas dos candidatos (até n por plataforma)
estudos_validacao <- function(S, a, catalogo, gpls) {
  V <- S$validacao
  d <- a[a$humano & a$sexo %in% c("F", "M"), ]
  n <- stats::aggregate(cbind(F = d$sexo == "F", M = d$sexo == "M") ~ gse, data = d, FUN = sum)
  n <- n[n$F >= V$min_por_sexo & n$M >= V$min_por_sexo, ]
  pl <- catalogo$plataformas[match(n$gse, catalogo$gse)]
  n$gpl <- vapply(strsplit(pl, ";"), function(z) { z <- intersect(z, gpls); if (length(z)) z[1] else NA_character_ }, "")
  n <- n[!is.na(n$gpl), ]                                              # série com a plataforma de um candidato (só essa matriz é lida)
  n <- n[order(n$gpl, -(n$F + n$M)), ]
  do.call(rbind, lapply(split(n, n$gpl), function(x) utils::head(x, V$estudos_por_plataforma)))
}

acerto_validacao <- function(sx, a) {
  d <- merge(sx, a[, c("gsm", "sexo")], by = "gsm")
  do.call(rbind, lapply(split(d, d$gse), function(x) data.frame(
    gse = x$gse[1], gpl = x$gpl[1], n = nrow(x), declarado_F = sum(x$sexo == "F"), declarado_M = sum(x$sexo == "M"),
    atribuido = sum(!is.na(x$sexo_genetico)), acerto = round(mean(x$sexo_genetico[!is.na(x$sexo_genetico)] == x$sexo[!is.na(x$sexo_genetico)]), 3),
    acerto_a = round(mean(x$sexo_a[!is.na(x$sexo_a)] == x$sexo[!is.na(x$sexo_a)]), 3), cobertura_a = round(mean(!is.na(x$sexo_a)), 2))))
}

# Plataforma validada: pelo menos um estudo com sexo declarado e acerto >= acerto_min. Estudos de
# validação abaixo disso ficam listados no relatório (ex.: sexo declarado incoerente com XIST e Y).
plataformas_validadas <- function(S, acerto, gpls) {
  data.frame(gpl = gpls, estudos_validacao = vapply(gpls, function(g) sum(acerto$gpl == g), 1L),
             melhor_acerto = vapply(gpls, function(g) { x <- acerto$acerto[acerto$gpl == g & !is.na(acerto$acerto)]; if (length(x)) max(x) else NA_real_ }, 1),
             validada = vapply(gpls, function(g) any(acerto$gpl == g & !is.na(acerto$acerto) & acerto$acerto >= S$validacao$acerto_min), TRUE), row.names = NULL)
}

# Elegibilidade refeita com o sexo genético onde o declarado falta (reusa a regra da etapa 02)
elegibilidade_resgate <- function(M, a, sx, catalogo, cand) {
  a2 <- a[a$gse %in% cand$gse, ]
  k <- match(a2$gsm, sx$gsm); usa <- is.na(a2$sexo) & !is.na(k) & !is.na(sx$sexo_genetico[k])
  a2$sexo[usa] <- sx$sexo_genetico[k[usa]]; a2$sexo_fonte[usa] <- "sexo genético"
  E <- M$elegibilidade
  a2$mulher_40a60 <- a2$sexo %in% "F" & !is.na(a2$idade) & a2$idade >= E$janela_idade[1] & a2$idade < E$janela_idade[2] + 1
  r <- elegibilidade(M, a2, catalogo)
  r[paste(r$gse, r$tecido) %in% paste(cand$gse, cand$tecido), ]
}

# Figura: percentil de XIST x genes Y, uma cor por sexo atribuído
figura_sexo <- function(sx, arq) {
  pasta(dirname(arq)); gs <- unique(sx$gse)
  grDevices::png(arq, width = 1500, height = 420 * ceiling(length(gs) / 3), res = 150)
  op <- graphics::par(mfrow = c(ceiling(length(gs) / 3), 3), mar = c(4, 4, 2.5, 1)); on.exit({ graphics::par(op); grDevices::dev.off() })
  cor <- c(F = "#B03A6F", M = "#2E6DA4")
  for (g in gs) {
    d <- sx[sx$gse == g, ]
    cc <- ifelse(is.na(d$sexo_genetico), "grey60", cor[d$sexo_genetico])
    if (all(is.na(d$p_xist))) {                                         # plataforma sem XIST: escore dos genes Y
      o <- order(d$escore)
      graphics::plot(seq_along(o), d$escore[o], pch = 19, col = cc[o], xlab = "Amostras (ordenadas)", ylab = "Escore z dos genes Y", main = paste(g, "(sem XIST)"), cex.main = 1)
    } else {
      graphics::plot(d$p_xist, d$p_y, xlim = c(0, 1), ylim = c(0, 1), pch = 19, col = cc,
                     xlab = "Percentil de XIST na amostra", ylab = "Percentil dos genes Y (mediana)", main = g, cex.main = 1)
      graphics::abline(h = 0.5, v = 0.5, lty = 3, col = "grey70")
    }
  }
  graphics::legend("topright", c("F", "M", "sem sexo"), col = c(cor, "grey60"), pch = 19, bty = "n", cex = 0.8)
}
