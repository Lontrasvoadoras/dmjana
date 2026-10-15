###############################################################################
#  run_08_painel.R - executa a ETAPA 08 (conectividade entre tecidos e painel) e gera o relatório
#  Uso: "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_08_painel.R
#  Requer as etapas 05, 06 e 07. Saídas: output/08_painel/*.csv, docs/figuras/painel_rede.png,
#  docs/validacao_08_painel.md, docs/etapa_08_painel.docx
###############################################################################
suppressPackageStartupMessages({ library(dplyr) })
for (f in c("R/00_utils.R", "R/05_meta.R", "R/08_painel.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
RC <- ler_config("config/redes.yaml"); P <- ler_config("config/processamento.yaml")
est05 <- utils::read.csv("output/05_meta/estudos.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8"); est05 <- est05[est05$uso == "principal", ]
tecidos <- sort(unique(est05$tecido)); d <- pasta("output", "08_painel")
le <- function(f) if (file.exists(f) && file.size(f) > 5) utils::read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8") else data.frame()

# 8.1 candidatos por tecido, com a origem de cada um
chave <- rbind_preenche(lapply(tecidos, function(t) le(file.path("output/06_redes", t, "genes_chave.csv"))))
conv <- le("output/07_enriquecimento/convergencia.csv"); gst <- le("output/07_enriquecimento/gsea_tecidos.csv")
# via selecionada pelo escore (etapa 07) cujo leading edge da GSEA tem NES no mesmo sinal do efeito (revisão de 08/10/2026)
# todos os estudos no mesmo sentido, exceto no nível "≥ 2 estudos" (por definição, nem todos concordam)
gs_ok <- gst[!is.na(gst$nivel) & nzchar(gst$nivel) & (gst$mesmo_sentido == gst$estudos | gst$nivel == "exploratório (≥ 2 estudos)") &
             !is.na(gst$leading_edge) & gst$leading_edge_coerente %in% TRUE, ]
expande <- function(df, origem) if (nrow(df)) do.call(rbind, lapply(seq_len(nrow(df)), function(i) {
  g <- if (is.na(df$leading_edge[i])) character() else strsplit(df$leading_edge[i], ";")[[1]]
  if (length(g)) data.frame(tecido = df$tecido[i], gene = g, origem = origem, via = df$via[i]) }))   # via sem leading edge: nada a expandir
cand <- rbind(if (nrow(chave)) data.frame(tecido = chave$tecido, gene = chave$gene, origem = "gene-chave de módulo", via = chave$modulo),
              expande(conv, "via convergente"), expande(gs_ok, "via selecionada no tecido (escore, todos os estudos no mesmo sentido)"))
if (is.null(cand) || !nrow(cand)) stop("ETAPA 08 | nenhum gene candidato (etapas 06 e 07 sem módulos ou vias selecionados)")
efeitos <- lapply(tecidos, function(t) { e <- lapply(est05$gse[est05$tecido == t], function(g) utils::read.csv(file.path("output/05_meta/estudos", g, "efeitos_genes.csv"), stringsAsFactors = FALSE))
  names(e) <- est05$gse[est05$tecido == t]; e }); names(efeitos) <- tecidos
meta <- lapply(tecidos, function(t) utils::read.csv(file.path("output/05_meta", t, "meta_genes.csv"), stringsAsFactors = FALSE)); names(meta) <- tecidos
cg <- cand %>% group_by(tecido, gene) %>% summarise(origens = paste(sort(unique(origem)), collapse = "; "), vias = paste(utils::head(unique(via), 3), collapse = "; "), .groups = "drop")
cg <- cg %>% rowwise() %>% mutate(g = meta[[tecido]]$g[match(gene, meta[[tecido]]$id)], p = meta[[tecido]]$p[match(gene, meta[[tecido]]$id)],
                                  estudos = meta[[tecido]]$estudos[match(gene, meta[[tecido]]$id)], mesmo_sentido = meta[[tecido]]$mesmo_sentido[match(gene, meta[[tecido]]$id)],
                                  p_fe = meta[[tecido]]$p_fe[match(gene, meta[[tecido]]$id)]) %>% ungroup()
cg <- cg[!is.na(cg$g), ]
log_msg("ETAPA 08 | %d candidatos (gene x tecido), %d genes únicos", nrow(cg), length(unique(cg$gene)))

# 8.2 STRING e 8.3 OmniPath
st <- tryCatch(string_interacoes(RC, cg$gene, P$cache), error = function(e) { log_msg("ETAPA 08 | STRING indisponível (%s)", conditionMessage(e)); NULL })
tec_de <- split(cg$tecido, cg$gene)
entre <- function(a, b) any(outer(tec_de[[a]] %||% character(), tec_de[[b]] %||% character(), "!="))
st_x <- if (!is.null(st) && nrow(st)) st[mapply(entre, st$gene1, st$gene2), ] else data.frame(gene1 = character(), gene2 = character(), score = numeric())
# revisão de 08/10/2026: o STRING devolve cada par nos dois sentidos (A-B e B-A); fica 1 linha por par de genes, com os tecidos
if (nrow(st_x)) { a <- pmin(st_x$gene1, st_x$gene2); b <- pmax(st_x$gene1, st_x$gene2); st_x$gene1 <- a; st_x$gene2 <- b
  st_x <- st_x[!duplicated(st_x[, c("gene1", "gene2")]), ]
  st_x$tecidos_gene1 <- vapply(st_x$gene1, function(g) paste(sort(unique(tec_de[[g]])), collapse = "+"), "")
  st_x$tecidos_gene2 <- vapply(st_x$gene2, function(g) paste(sort(unique(tec_de[[g]])), collapse = "+"), "") }
lr <- omnipath_ligrec(P$cache)
lr_x <- do.call(rbind, lapply(seq_len(nrow(lr)), function(i) { a <- cg[cg$gene == lr$ligante[i], ]; b <- cg[cg$gene == lr$receptor[i], ]
  if (!nrow(a) || !nrow(b)) return(NULL); pr <- expand.grid(ta = a$tecido, tb = b$tecido, stringsAsFactors = FALSE); pr <- pr[pr$ta != pr$tb, ]
  if (nrow(pr)) data.frame(ligante = lr$ligante[i], tecido_ligante = pr$ta, receptor = lr$receptor[i], tecido_receptor = pr$tb) }))
if (is.null(lr_x)) lr_x <- data.frame(ligante = character(), tecido_ligante = character(), receptor = character(), tecido_receptor = character())
escrever_csv(st_x, file.path(d, "string_entre_tecidos.csv")); escrever_csv(lr_x, file.path(d, "ligante_receptor_entre_tecidos.csv"))
lr_x <- unique(lr_x)
log_msg("ETAPA 08 | STRING: %d pares de genes únicos (candidatos de tecidos diferentes); OmniPath: %d pares ligante-receptor entre tecidos (ligante, receptor e tecidos únicos)", nrow(st_x), nrow(lr_x))

# 8.4 painel: pontos por gene x tecido
lig <- unique(c(st_x$gene1, st_x$gene2, lr_x$ligante, lr_x$receptor))
loo <- unlist(lapply(tecidos, function(t) { x <- cg$gene[cg$tecido == t]; if (length(x)) { r <- robusto_loo(efeitos[[t]], x, RC$painel$robusto_p_max %||% 0.10); stats::setNames(r, paste(t, names(r))) } }))
# D1 (decisão do usuário, 08/10/2026): ponto de via só para via forte (significativa/sugestiva) ou convergente;
# ponto de ligação só com candidato de tecido com 2+ estudos (o fígado, 1 estudo, não dá ponto aos outros)
forte <- gs_ok[gs_ok$nivel %in% c("significativo", "sugestivo"), ]
via_forte <- unique(c(if (nrow(conv)) { e <- expande(conv, "c"); if (!is.null(e)) paste(e$tecido, e$gene) }, if (nrow(forte)) { e <- expande(forte, "f"); if (!is.null(e)) paste(e$tecido, e$gene) }))
n_est <- table(est05$tecido)
arestas <- rbind(if (nrow(st_x)) data.frame(a = st_x$gene1, b = st_x$gene2), if (nrow(lr_x)) data.frame(a = lr_x$ligante, b = lr_x$receptor))
parceiros <- if (!is.null(arestas) && nrow(arestas)) split(c(arestas$b, arestas$a), c(arestas$a, arestas$b)) else list()
liga_multi <- mapply(function(t, g) { p <- parceiros[[g]]; if (is.null(p)) return(FALSE)
  tp <- unlist(tec_de[unique(p)]); any(tp != t & as.integer(n_est[tp]) >= 2) }, cg$tecido, cg$gene)
# efeito consistente: p < 0,05 (Hartung-Knapp; efeito fixo em tecido com 2 estudos, decisão do usuário de 08/10/2026) e todos no mesmo sentido
n_est_t <- as.integer(table(est05$tecido)[cg$tecido])
p_rep <- ifelse(n_est_t == 2 & isTRUE(RC$teste$efeito_fixo_2_estudos) & !is.na(cg$p_fe), cg$p_fe, cg$p)
cg$replicado <- cg$estudos >= 2 & cg$mesmo_sentido == cg$estudos & p_rep < 0.05
cg$resposta_imediata <- cg$gene %in% unlist(ler_config("config/meta.yaml")$genes_resposta_imediata)   # marcado para discussão (08/10/2026)
cg$gene_chave <- grepl("gene-chave", cg$origens)
cg$via_forte_ou_convergente <- paste(cg$tecido, cg$gene) %in% via_forte
cg$ligacao_outro_tecido <- unname(liga_multi)
cg$robusto_loo <- unname(loo[paste(cg$tecido, cg$gene)]) %in% TRUE
cg$pontos <- cg$replicado + cg$gene_chave + cg$via_forte_ou_convergente + cg$ligacao_outro_tecido + cg$robusto_loo
nivel_mod <- if (nrow(chave)) tapply(chave$selecao, chave$gene, function(z) z[1]) else character()
cg$evidencia <- ifelse(cg$gene %in% names(nivel_mod), unname(nivel_mod[cg$gene]), "exploratório")
cg$evidencia[cg$estudos == 1] <- "exploratório (1 estudo)"                 # gene de tecido com 1 estudo (08/10/2026)
cg$sentido <- ifelse(cg$g > 0, "maior no DM2", "menor no DM2")
painel <- cg[cg$pontos >= RC$painel$pontos_min, ]; painel <- painel[order(-painel$pontos, painel$p), ]
# programas (decisão do usuário, 08/10/2026): cada gene do painel vai para o módulo selecionado do seu tecido (etapa 06);
# genes fora de módulo selecionado formam o programa "vias" do tecido. Destaques = os mais centrais (kME) de cada programa.
rot <- le("output/07_enriquecimento/modulos_rotulados.csv")
km <- rbind_preenche(lapply(unique(painel$tecido), function(t) { k <- le(file.path("output/06_redes", t, "modulos_genes.csv")); if (nrow(k)) data.frame(tecido = t, k[, intersect(c("gene", "modulo", "kME_2"), names(k))]) }))
msel <- rbind_preenche(lapply(unique(painel$tecido), function(t) { m <- le(file.path("output/06_redes", t, "meta_modulos.csv")); if (nrow(m)) { m$selecao[is.na(m$selecao)] <- ""; m <- m[nzchar(m$selecao), ]; if (nrow(m)) data.frame(tecido = t, modulo = m$id, selecao_modulo = m$selecao, g_modulo = m$g, genes_modulo = m$genes) } }))
i <- match(paste(painel$tecido, painel$gene), paste(km$tecido, km$gene))
painel$modulo <- if (!is.null(km)) km$modulo[i] else NA; painel$kME_2 <- if (!is.null(km)) km$kME_2[i] else NA
em_sel <- !is.null(msel) & paste(painel$tecido, painel$modulo) %in% paste(msel$tecido, msel$modulo)
painel$programa <- ifelse(em_sel, paste(painel$tecido, painel$modulo), paste(painel$tecido, "(vias, fora de módulo selecionado)"))
painel <- painel[order(painel$programa, -ifelse(is.na(painel$kME_2), -Inf, painel$kME_2), -abs(painel$g)), ]
painel$destaque <- stats::ave(seq_len(nrow(painel)), painel$programa, FUN = seq_along) <= (RC$painel$genes_por_programa %||% 10)
progs <- do.call(rbind, lapply(split(painel, painel$programa), function(x) { t <- x$tecido[1]; mo <- x$modulo[1]
  r <- if (!is.null(rot) && nrow(rot)) rot$rotulo[rot$tecido == t & rot$id == mo] else character()
  ms <- if (!is.null(msel)) msel[msel$tecido == t & msel$modulo == mo, ] else NULL
  data.frame(programa = x$programa[1], tecido = t, modulo = if (startsWith(x$programa[1], paste(t, "("))) "-" else mo,
             vias_do_modulo = if (length(r) && !is.na(r[1])) gsub("_", " ", r[1]) else "-", selecao_modulo = if (NROW(ms)) ms$selecao_modulo[1] else "-",
             genes_no_modulo = if (NROW(ms)) ms$genes_modulo[1] else NA, genes_no_painel = nrow(x), maiores_dm2 = sum(x$g > 0), menores_dm2 = sum(x$g < 0),
             resposta_imediata = sum(x$resposta_imediata %in% TRUE), destaques = paste(x$gene[x$destaque], collapse = ", ")) }))
progs <- progs[order(progs$tecido, -progs$genes_no_painel), ]
escrever_csv(cg, file.path(d, "candidatos.csv")); escrever_csv(painel, file.path(d, "painel.csv")); escrever_csv(progs, file.path(d, "painel_programas.csv"))
log_msg("ETAPA 08 | painel por programa: %s", paste(sprintf("%s (%d genes)", progs$programa, progs$genes_no_painel), collapse = "; "))
log_msg("ETAPA 08 | painel: %d gene x tecido com >= %d pontos (%d genes únicos)", nrow(painel), RC$painel$pontos_min, length(unique(painel$gene)))

# figura: rede do painel (STRING e ligante-receptor entre tecidos)
cores_t <- c(adiposo = "#E69F00", figado = "#8C564B", ilhotas = "#009E73", musculo = "#CC79A7", sangue = "#D55E00")
ar <- rbind(if (nrow(st_x)) data.frame(a = st_x$gene1, b = st_x$gene2, tipo = "STRING"), if (nrow(lr_x)) data.frame(a = lr_x$ligante, b = lr_x$receptor, tipo = "ligante-receptor"))
if (!is.null(ar) && nrow(ar)) {
  ar <- unique(ar[ar$a %in% painel$gene | ar$b %in% painel$gene, ])
  if (nrow(ar)) { gph <- igraph::graph_from_data_frame(ar, directed = FALSE); v <- igraph::V(gph)$name
    tv <- sapply(v, function(x) paste(sort(unique(cg$tecido[cg$gene == x])), collapse = "+"))
    cv <- sapply(v, function(x) { t <- unique(cg$tecido[cg$gene == x]); if (length(t) == 1) cores_t[[t]] else "grey40" })
    grDevices::png("docs/figuras/painel_rede.png", width = 1800, height = 1500, res = 150); set.seed(1)
    plot(gph, vertex.color = cv, vertex.size = ifelse(v %in% painel$gene, 9, 5), vertex.label.cex = 0.6, vertex.label.color = "black",
         edge.color = ifelse(igraph::E(gph)$tipo == "STRING", "grey60", "#1F78B4"), edge.width = ifelse(igraph::E(gph)$tipo == "STRING", 1, 2.5), main = "Painel: ligações entre tecidos")
    graphics::legend("bottomleft", c(names(cores_t), "mais de um tecido", "STRING", "ligante–receptor"), col = c(cores_t, "grey40", "grey60", "#1F78B4"),
                     pch = c(rep(19, 6), NA, NA), lty = c(rep(NA, 6), 1, 1), lwd = c(rep(NA, 6), 1, 2.5), bty = "n", cex = 0.8)
    grDevices::dev.off() }
}

# ---------------- relatório ----------------
fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
rt <- cg %>% group_by(tecido) %>% summarise(candidatos = n(), replicado = sum(replicado), gene_chave = sum(gene_chave), via = sum(via_forte_ou_convergente),
                                             ligacao = sum(ligacao_outro_tecido), robusto = sum(robusto_loo), painel = sum(pontos >= RC$painel$pontos_min), .groups = "drop")
linhas <- c("# Validação da etapa 08: conectividade entre tecidos e painel", "", sprintf("Gerado em %s a partir de `output/08_painel/`.", format(Sys.time(), "%d/%m/%Y %H:%M")), "",
  "## 1. Candidatos por tecido e critérios", "", "| Tecido | Candidatos | Efeito replicado | Gene-chave de módulo | Via forte ou convergente | Ligação com tecido de 2+ estudos | Robusto a tirar um estudo | No painel |",
  "|---|---:|---:|---:|---:|---:|---:|---:|", sprintf("| %s | %d | %d | %d | %d | %d | %d | %d |", rt$tecido, rt$candidatos, rt$replicado, rt$gene_chave, rt$via, rt$ligacao, rt$robusto, rt$painel), "",
  sprintf("Painel = gene × tecido com pelo menos %d dos 5 pontos. Todos os genes são **exploratórios** quando não vêm de módulo significativo ou sugestivo.", RC$painel$pontos_min), "",
  "## 2. Painel por programa", "",
  "Os critérios não são independentes (um gene de módulo ganha juntos os pontos de efeito, gene-chave e via convergente), então o painel é lido por programa: o módulo selecionado de cada tecido, com os genes mais centrais (kME) em destaque. Lista completa na seção 2b e em output/08_painel/painel.csv (decisão do usuário, 08/10/2026).", "",
  if (nrow(progs)) c("| Programa | Vias do módulo | Seleção do módulo | Genes no painel | Maiores / menores no DM2 | Destaques (mais centrais) |", "|---|---|---|---:|---|---|",
    sprintf("| %s | %s | %s | %d | %d / %d | %s |", progs$programa, progs$vias_do_modulo, progs$selecao_modulo, progs$genes_no_painel, progs$maiores_dm2, progs$menores_dm2, progs$destaques)) else "Nenhum programa.", "",
  "### 2b. Lista completa (tabela suplementar)", "",
  if (nrow(painel)) c("| Gene | Tecido | Sentido | g | p | Estudos no mesmo sentido | Pontos | Evidência | Origem |", "|---|---|---|---:|---:|---|---:|---|---|",
    sprintf("| %s | %s | %s | %.2f | %s | %d/%d | %d | %s | %s |", painel$gene, painel$tecido, painel$sentido, painel$g, fp(painel$p), painel$mesmo_sentido, painel$estudos, painel$pontos, painel$evidencia, substr(painel$origens, 1, 80))) else "Nenhum gene atingiu a pontuação mínima.", "",
  "## 3. Ligações entre tecidos", "", sprintf("STRING (confiança ≥ %d): %d pares de genes únicos entre candidatos de tecidos diferentes (cada par contado uma vez; tecidos de cada gene em string_entre_tecidos.csv). OmniPath: %d pares ligante–receptor com ligante num tecido e receptor em outro.",
    RC$conectividade$string_score_min, nrow(st_x), nrow(lr_x)), "",
  if (nrow(lr_x)) c("| Ligante | Tecido do ligante | Receptor | Tecido do receptor |", "|---|---|---|---|", sprintf("| %s | %s | %s | %s |", lr_x$ligante, lr_x$tecido_ligante, lr_x$receptor, lr_x$tecido_receptor)) else "", "",
  "Figura: `docs/figuras/painel_rede.png`. Cada tecido vem de pessoas diferentes: as ligações são hipóteses de conhecimento prévio, não correlações observadas na mesma pessoa.")
writeLines(linhas, file.path(pasta("docs"), "validacao_08_painel.md"), useBytes = TRUE)
log_msg("ETAPA 08 | relatório de validação: docs/validacao_08_painel.md")
documentar_etapa_08(RC, rt, painel, st_x, lr_x, progs = progs)
