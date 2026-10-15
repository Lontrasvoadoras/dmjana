###############################################################################
#  docs/figura_sexo_discordantes.R - amostras com sexo declarado discordante do sexo pela expressão (pedido do usuário, 10/10/2026)
#  Para cada estudo com discordância: XIST x média dos genes do Y (z dentro do estudo), cor = sexo declarado,
#  discordantes destacadas e identificadas. Saídas: docs/figuras/sexo_discordantes.png, output/04_processamento/sexo_discordantes.csv
###############################################################################
source("R/00_utils.R", encoding = "UTF-8")
inv <- utils::read.csv("output/04_processamento/inventario.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8")
gy <- c("RPS4Y1", "DDX3Y", "KDM5D", "UTY", "EIF1AY", "USP9Y", "ZFY", "NLGN4Y", "TXLNGY")
cor_s <- c(F = "#C2185B", M = "#1565C0"); cinza <- "#9E9E9E"
dados <- list(); tab <- list()
for (g in inv$gse) {
  f <- file.path("output/04_processamento", g, "amostras_qc.csv"); if (!file.exists(f)) next
  q <- utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8", colClasses = c(sexo = "character", sexo_genetico = "character"))
  if (!"sexo_discordante" %in% names(q) || !any(q$sexo_discordante %in% TRUE)) next
  x <- readRDS(file.path("output/04_processamento", g, "expressao.rds")); ex <- x$expressao
  ex <- ex[, intersect(q$coluna, colnames(ex)), drop = FALSE]; q <- q[match(colnames(ex), q$coluna), ]
  z <- function(v) (v - mean(v)) / stats::sd(v)
  y <- intersect(gy, rownames(ex)); xs <- if ("XIST" %in% rownames(ex)) z(ex["XIST", ]) else rep(NA_real_, ncol(ex))
  ys <- if (length(y)) z(colMeans(t(apply(ex[y, , drop = FALSE], 1, z)))) else rep(NA_real_, ncol(ex))
  dados[[g]] <- data.frame(gse = g, tecido = inv$tecido[inv$gse == g], coluna = q$coluna, gsm = q$gsm, sexo = q$sexo, sexo_genetico = q$sexo_genetico,
                           disc = q$sexo_discordante %in% TRUE, f4060 = q$mulher_40a60 %in% TRUE, status = q$status, idade = q$idade, xist = xs, ygenes = ys, n_y = length(y))
  d <- dados[[g]][dados[[g]]$disc, ]
  tab[[g]] <- data.frame(estudo = g, tecido = d$tecido, amostra = d$gsm, sexo_declarado = d$sexo, sexo_pela_expressao = d$sexo_genetico, idade = d$idade, status = d$status,
                         mulher_40a60_declarada = d$f4060, xist_z = round(d$xist, 2), genes_y_z = round(d$ygenes, 2))
}
tab <- do.call(rbind, tab); escrever_csv(tab, "output/04_processamento/sexo_discordantes.csv")
nd <- length(dados); nc <- 3; nl <- ceiling(nd / nc)
grDevices::png("docs/figuras/sexo_discordantes.png", width = 1900, height = 640 * nl + 120, res = 160)
op <- graphics::par(mfrow = c(nl, nc), mar = c(4.2, 4.2, 3.2, 1), oma = c(3, 0, 0, 0))
for (g in names(dados)) { x <- dados[[g]]
  if (all(is.na(x$xist))) {   # sem XIST medido: genes do Y por sexo declarado (faixa)
    set.seed(1); yy <- ifelse(x$sexo %in% "F", 1, ifelse(x$sexo %in% "M", 2, 1.5)) + stats::runif(nrow(x), -0.18, 0.18)
    graphics::plot(x$ygenes, yy, type = "n", yaxt = "n", ylim = c(0.6, 2.4), xlim = range(x$ygenes, na.rm = TRUE) + c(0, 0.45 * diff(range(x$ygenes, na.rm = TRUE))), xlab = "Genes do cromossomo Y (z)", ylab = "", main = sprintf("%s · %s · %d de %d discordantes (sem XIST)", g, x$tecido[1], sum(x$disc), nrow(x)), cex.main = 0.95)
    graphics::axis(2, 1:2, c("declarado F", "declarado M"), las = 1, cex.axis = 0.8); graphics::abline(v = 0, col = "grey88")
    n0 <- !x$disc; graphics::points(x$ygenes[n0], yy[n0], pch = 16, cex = 0.9, col = grDevices::adjustcolor(ifelse(x$sexo[n0] %in% names(cor_s), cor_s[x$sexo[n0]], cinza), 0.55))
    graphics::points(x$ygenes[x$disc], yy[x$disc], pch = 21, cex = 2.1, lwd = 2.2, col = "black", bg = cor_s[x$sexo[x$disc]])
    graphics::points(x$ygenes[x$disc & x$f4060], yy[x$disc & x$f4060], pch = 4, cex = 1.3, lwd = 2, col = "white")
    graphics::text(x$ygenes[x$disc], yy[x$disc], labels = sprintf("%s
%s→%s, %s", x$gsm[x$disc], x$sexo[x$disc], x$sexo_genetico[x$disc], x$idade[x$disc]), pos = 4, cex = 0.55, offset = 0.7)
    next }
  ok <- !is.na(x$xist) & !is.na(x$ygenes)
  graphics::plot(x$ygenes[ok], x$xist[ok], type = "n", xlim = range(x$ygenes[ok]) + c(0, 0.45 * diff(range(x$ygenes[ok]))), xlab = "Genes do cromossomo Y (z)", ylab = "XIST (z)",
                 main = sprintf("%s · %s · %d de %d discordantes", g, x$tecido[1], sum(x$disc), nrow(x)), cex.main = 0.95)
  graphics::abline(h = 0, v = 0, col = "grey88")
  n <- !x$disc & ok; graphics::points(x$ygenes[n], x$xist[n], pch = 16, cex = 0.9, col = grDevices::adjustcolor(ifelse(x$sexo[n] %in% names(cor_s), cor_s[x$sexo[n]], cinza), 0.55))
  dd <- x$disc & ok
  graphics::points(x$ygenes[dd], x$xist[dd], pch = 21, cex = 2.1, lwd = 2.2, col = "black", bg = ifelse(x$sexo[dd] %in% names(cor_s), cor_s[x$sexo[dd]], cinza))
  graphics::points(x$ygenes[dd & x$f4060], x$xist[dd & x$f4060], pch = 4, cex = 1.3, lwd = 2, col = "white")
  graphics::text(x$ygenes[dd], x$xist[dd], labels = sprintf("%s\n%s→%s, %s", x$gsm[dd], x$sexo[dd], x$sexo_genetico[dd], ifelse(is.na(x$idade[dd]), "?", x$idade[dd])), pos = 4, cex = 0.55, offset = 0.7) }
graphics::par(fig = c(0, 1, 0, 1), oma = c(0, 0, 0, 0), mar = c(0, 0, 0, 0), new = TRUE); graphics::plot(0, 0, type = "n", bty = "n", xaxt = "n", yaxt = "n")
graphics::legend("bottom", c("declarado feminino", "declarado masculino", "discordante (contorno preto; cor = declarado)", "discordante declarada mulher de 40–60 (×)"),
                 pch = c(16, 16, 21, 4), col = c(cor_s, "black", "black"), pt.bg = c(NA, NA, "grey80", NA), pt.cex = c(1, 1, 1.6, 1.1), horiz = TRUE, bty = "n", cex = 0.75, xpd = TRUE)
graphics::par(op); grDevices::dev.off()
log_msg("figura de sexo discordante: %d estudos, %d amostras", nd, nrow(tab))
