###############################################################################
#  08_painel.R - ETAPA 08: conectividade entre tecidos e painel de genes de interesse
#
#  Intenção (docs/intencao_06_redes.docx, aprovada em 07/10/2026):
#   8.1 candidatos por tecido: genes-chave dos módulos selecionados (etapa 06) e leading edge (GSEA) das vias
#       convergentes e das vias selecionadas no tecido pelo escore (etapa 07: significativa, sugestiva ou
#       exploratória com 2+ estudos, todos no mesmo sentido), só quando o NES tem o mesmo sinal do efeito
#   8.2 STRING (v12, confiança >= 700): interações entre candidatos de tecidos diferentes
#   8.3 OmniPath ligante-receptor: ligante candidato num tecido e receptor candidato em outro
#   8.4 painel: pontos por gene (critérios definidos antes de rodar), robustez a deixar um estudo de fora
#  Cada tecido vem de pessoas diferentes: a ligação entre tecidos é por conhecimento prévio, não por
#  correlação de expressão na mesma pessoa.
###############################################################################

# pares ligante-receptor do OmniPath (conjunto ligrecextra) pela API web; a função intercell_network do
# OmnipathR 3.14 falhou ao ler uma página interna (07/10/2026)
omnipath_ligrec <- function(cache) {
  f <- file.path(pasta(cache), "omnipath_ligrec.tsv")
  if (!file.exists(f) || file.size(f) < 1000) utils::download.file("https://omnipathdb.org/interactions?datasets=ligrecextra&genesymbols=yes&organisms=9606", f, quiet = TRUE, mode = "wb")
  x <- utils::read.delim(f, stringsAsFactors = FALSE)
  unique(data.frame(ligante = x$source_genesymbol, receptor = x$target_genesymbol))
}

# interações STRING entre os genes candidatos
string_interacoes <- function(RC, genes, cache) {
  sdb <- STRINGdb::STRINGdb$new(version = RC$conectividade$string_versao, species = 9606, score_threshold = RC$conectividade$string_score_min,
                                network_type = "full", input_directory = pasta(cache, "string"))
  mp <- suppressWarnings(sdb$map(data.frame(gene = unique(genes)), "gene", removeUnmappedRows = TRUE))
  it <- sdb$get_interactions(unique(mp$STRING_id))
  it <- it[it$combined_score >= RC$conectividade$string_score_min, ]
  data.frame(gene1 = mp$gene[match(it$from, mp$STRING_id)], gene2 = mp$gene[match(it$to, mp$STRING_id)], score = it$combined_score)
}

# robustez a deixar um estudo de fora: o sinal do efeito combinado (Hartung-Knapp) não muda em nenhuma retirada
# robusto (D1, decisão do usuário de 08/10/2026): ao tirar cada estudo, o sentido se mantém E p < p_max
robusto_loo <- function(efs, genes, p_max = 0.10) {
  if (length(efs) < 3) return(stats::setNames(rep(NA, length(genes)), genes))   # com 2 estudos, tirar um deixa só 1
  full <- meta_tecido(efs, metodo = "hk"); s0 <- sign(full$g[match(genes, full$id)])
  ok <- sapply(names(efs), function(g) { m <- meta_tecido(efs[names(efs) != g], metodo = "hk"); i <- match(genes, m$id); sign(m$g[i]) == s0 & m$p[i] < p_max })
  stats::setNames(apply(matrix(ok, nrow = length(genes)), 1, function(z) all(z %in% TRUE)), genes)
}
