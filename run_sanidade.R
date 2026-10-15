###############################################################################
#  run_sanidade.R - testes de sanidade de todas as saídas (etapas 02 a 10) e comparabilidade dos dados
#  Uso: "D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_sanidade.R
#       SANIDADE_RAPIDA=1 pula as permutações e os conjuntos aleatórios (config/sanidade.yaml: completa)
#  Saídas: output/sanidade/*.csv, docs/figuras/comparabilidade_*.png, docs/sanidade.md, docs/sanidade.docx.
#  Termina com falha (código 1) se houver alguma verificação com gravidade ERRO.
###############################################################################
for (f in c("R/00_utils.R", "R/05_meta.R", "R/97_comparabilidade.R", "R/98_sanidade.R", "R/99_documentar.R")) source(f, encoding = "UTF-8")
MC <- ler_config("config/meta.yaml"); SC <- ler_config("config/sanidade.yaml")
options(vias_competitivo = !isFALSE(MC$vias$competitivo))       # escore de via competitivo (08/10/2026)
completa <- isTRUE(SC$completa) && !nzchar(Sys.getenv("SANIDADE_RAPIDA"))
ds <- pasta("output", "sanidade")

# 1. formato (etapas 02-08)
invisible(verificar_tudo())
# 2. comparabilidade e conteúdo
dados <- carregar_todos(MC)
C <- comparabilidade(SC, MC, dados)
figs <- figuras_comparabilidade(C, dados$L)
S <- sanidade_conteudo(SC, MC, dados, C)
MF <- sanidade_meta(SC, dados)
N <- if (completa) sanidade_nulos(SC, MC, dados) else NULL
X <- sanidade_execucao(SC, MC, dados)
v <- do.call(rbind, .chk$t)

escrever_csv(v, file.path(ds, "verificacoes.csv"))
escrever_csv(C$amostras, file.path(ds, "genes_por_amostra.csv")); escrever_csv(C$estudos, file.path(ds, "genes_por_estudo.csv"))
escrever_csv(C$pares, file.path(ds, "similaridade_estudos.csv")); escrever_csv(C$resumo, file.path(ds, "similaridade_resumo.csv"))
escrever_csv(C$cobertura, file.path(ds, "cobertura_tecidos.csv")); escrever_csv(C$identidade, file.path(ds, "identidade_tecido.csv"))
escrever_csv(S$balanco, file.path(ds, "balanco_confusores.csv")); if (NROW(S$duplicados)) escrever_csv(S$duplicados, file.path(ds, "possiveis_duplicados.csv"))
escrever_csv(S$marcadas, file.path(ds, "amostras_outro_tecido.csv")); escrever_csv(MF, file.path(ds, "conferencia_metafor.csv")); escrever_csv(X, file.path(ds, "datas_saidas.csv"))
if (!is.null(N)) escrever_csv(N, file.path(ds, "nulos_permutacao.csv"))

res <- table(factor(v$gravidade, levels = c("OK", "ALERTA", "ERRO")))
log_msg("SANIDADE | %d verificações: %d OK, %d ALERTA, %d ERRO (%s)", nrow(v), res[["OK"]], res[["ALERTA"]], res[["ERRO"]], if (completa) "completa" else "rápida")
pr <- v[v$gravidade != "OK", ]; pr <- pr[order(pr$gravidade != "ERRO", pr$etapa), ]
por_etapa <- stats::aggregate(cbind(OK = v$gravidade == "OK", ALERTA = v$gravidade == "ALERTA", ERRO = v$gravidade == "ERRO") ~ etapa, data = v, FUN = sum)

# ---------------- textos de leitura ----------------
`%|%` <- function(a, b) if (!length(a) || !nzchar(a)) b else a
rs <- C$resumo; dentro <- rs[rs$tipo == "dentro do tecido", ]; entre <- rs[rs$tipo == "entre tecidos", ]
leitura <- c(
  sprintf("Genes medidos por estudo: %d a %d (codificantes); genes detectados por amostra: mediana de %d a %d entre os estudos.",
          min(C$estudos$genes_medidos), max(C$estudos$genes_medidos), round(min(C$estudos$mediana_detectados_amostra)), round(max(C$estudos$mediana_detectados_amostra))),
  sprintf("Perfil de expressão: correlação média dentro do tecido %.2f a %.2f; entre tecidos %.2f a %.2f. Dentro > entre indica que os estudos de um tecido são comparáveis entre si.",
          min(dentro$cor_perfil), max(dentro$cor_perfil), min(entre$cor_perfil), max(entre$cor_perfil)),
  sprintf("Efeito do DM2: correlação média dos g dentro do tecido %s; entre tecidos %.2f a %.2f. Perto de 0 = os estudos não concordam no sinal do DM2 gene a gene (esperado com N pequeno e muita confusão em humanos).",
          paste(sprintf("%s %.2f", dentro$comparacao, dentro$cor_efeito_dm2), collapse = ", "), min(entre$cor_efeito_dm2, na.rm = TRUE), max(entre$cor_efeito_dm2, na.rm = TRUE)),
  sprintf("Concordância de sentido entre genes com p < 0,05 nos dois estudos (acaso = 0,50): dentro do tecido %s; entre tecidos %.2f a %.2f.",
          paste(sprintf("%s %.2f", dentro$comparacao, dentro$concordancia_sentido_p05), collapse = ", "), min(entre$concordancia_sentido_p05, na.rm = TRUE), max(entre$concordancia_sentido_p05, na.rm = TRUE)),
  sprintf("Cobertura: genes medidos em todos os estudos do tecido / em algum: %s.", paste(sprintf("%s %.0f%%", C$cobertura$tecido, 100 * C$cobertura$frac_em_todos), collapse = ", ")))
if (!is.null(N)) leitura <- c(leitura, sprintf("Permutação dos rótulos: fração de p < 0,05 sob o acaso, média %.3f (esperado ~0,05). Estudos com sinal do DM2 acima do acaso (p empírico < 0,05): %s.",
                                               mean(N$frac_p05_nulo_media, na.rm = TRUE), paste(N$gse[N$p_empirico < 0.05], collapse = ", ") %|% "nenhum"))

tab_md <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                        apply(df, 1, function(r) paste0("| ", paste(gsub("[|]", "/", r), collapse = " | "), " |")))
linhas <- c("# Testes de sanidade e comparabilidade dos dados", "",
  sprintf("Gerado em %s a partir de `output/` (sanidade %s). Verificações: %d; OK %d; ALERTA %d; ERRO %d.", format(Sys.time(), "%d/%m/%Y %H:%M"), if (completa) "completa" else "rápida", nrow(v), res[["OK"]], res[["ALERTA"]], res[["ERRO"]]), "",
  tab_md(por_etapa), "", "## Problemas (ERRO = resultado não confiável; ALERTA = conferir)", "",
  if (nrow(pr)) tab_md(data.frame(Gravidade = pr$gravidade, Etapa = pr$etapa, Arquivo = pr$arquivo, Regra = pr$regra, `Ocorrências` = pr$violacoes, Exemplo = pr$exemplo, check.names = FALSE)) else "Nenhum.", "",
  "## Decisões do usuário sobre alertas", "", paste0("- ", vapply(SC$decisoes_usuario, function(d) sprintf("**%s** (%s): %s", d$regra, paste(d$amostras, collapse = ", "), d$decisao), "")), "",
  if (NROW(S$marcadas)) c("### Amostras com marcadores de outro tecido", "", tab_md(S$marcadas), "") else NULL,
  if (NROW(S$duplicados)) c("### Pares de amostras com perfil quase idêntico", "", tab_md(S$duplicados), "") else NULL,
  "## Comparabilidade dos dados", "", paste("-", leitura), "",
  "### Genes resgatados por estudo", "", tab_md(C$estudos[, c("gse", "tecido", "tipo", "uso", "amostras", "mulheres_40a60_modelo", "genes_brutos", "genes_medidos", "genes_analisados_05", "genes_detectados_estudo", "mediana_detectados_amostra", "min_detectados_amostra", "amostras_baixa_deteccao")]), "",
  "![Genes por amostra](figuras/comparabilidade_deteccao.png)", "",
  "### Similaridade dentro e entre tecidos", "", tab_md(C$resumo), "", tab_md(C$cobertura), "",
  "![Perfil](figuras/comparabilidade_perfil.png)", "", "![Jaccard](figuras/comparabilidade_jaccard.png)", "", "![Efeito](figuras/comparabilidade_efeito.png)", "",
  "### Identidade do tecido (percentil médio dos marcadores)", "", tab_md(C$identidade), "",
  if (!is.null(N)) c("### Nulos: permutação dos rótulos e conjuntos aleatórios", "", tab_md(N), "") else NULL,
  "### Conferência com o metafor", "", tab_md(MF), "", "### Datas das saídas", "", tab_md(X))
writeLines(linhas, file.path(pasta("docs"), "sanidade.md"), useBytes = TRUE)

gravar_docx(c(list(
  list(tipo = "p", texto = sprintf("Gerado em %s. Testes automáticos das saídas das etapas 02 a 10 e da comparabilidade dos dados (pedidos do usuário, 08/10/2026). Sanidade %s.", format(Sys.time(), "%d/%m/%Y %H:%M"), if (completa) "completa (com permutações)" else "rápida")),
  list(tipo = "h2", texto = "Resumo"),
  list(tipo = "p", texto = sprintf("%d verificações: %d OK, %d ALERTA (conferir) e %d ERRO (resultado não confiável).", nrow(v), res[["OK"]], res[["ALERTA"]], res[["ERRO"]])),
  list(tipo = "tabela", df = por_etapa),
  list(tipo = "h2", texto = "O que é verificado"),
  list(tipo = "b", itens = c("Formato: NA em coluna obrigatória, infinitos, p ou FDR fora de (0, 1], FDR menor que p, efeito fora do próprio IC, I² fora de [0, 1], contagens negativas, kME fora de [-1, 1], rótulos fora do conjunto, duplicados, colunas vazias ou constantes (tudo 0 ou tudo 1).",
                             "Coerência: mulher de 40–60 com sexo F e idade na faixa; elegível com 2+ doadoras por grupo; replicado só com 2+ estudos; módulo selecionado preservado; pontos do painel = soma dos critérios; n do modelo = doadoras mantidas no controle de qualidade.",
                             "Controles biológicos: sexo pela expressão (XIST acima dos genes do Y nas mulheres do modelo); identidade do tecido pelos marcadores; controles positivos do DM2 nas ilhotas (SLC2A2, ARG2, IAPP, PPP1R1A menores no DM2).",
                             "Nulos estatísticos: rótulos DM2/ND sorteados (o modelo deve dar ~5% de p < 0,05); conjuntos de genes aleatórios no escore de via.",
                             "Conferência independente: a meta-análise refeita com o pacote metafor em genes sorteados; invariantes (Hartung-Knapp nunca menos conservador que DL; I² coerente com o Q; 1 estudo = o próprio estudo; pesos somam 100%).",
                             "Armadilhas de dados humanos do GEO: símbolos corrompidos pelo Excel e aliases antigos; amostras com perfil quase idêntico (doador duplicado); desbalanço de idade, IMC e composição celular entre DM2 e ND.",
                             "Execução: saídas mais velhas que as entradas de que dependem; mesmo ajuste repetido dá o mesmo resultado; versões dos pacotes em output/sanidade/sessao_R.txt.")),
  list(tipo = "h2", texto = "Problemas encontrados"),
  if (nrow(pr)) list(tipo = "tabela", df = data.frame(Gravidade = pr$gravidade, Etapa = pr$etapa, Arquivo = pr$arquivo, Regra = pr$regra, `Ocorrências` = pr$violacoes, Exemplo = pr$exemplo, check.names = FALSE))
  else list(tipo = "p", texto = "Nenhum."),
  list(tipo = "h2", texto = "Decisões do usuário sobre alertas"),
  list(tipo = "b", itens = vapply(SC$decisoes_usuario, function(d) sprintf("%s (%s): %s", d$regra, paste(d$amostras, collapse = ", "), d$decisao), "")),
  if (NROW(S$marcadas)) list(tipo = "tabela", df = S$marcadas, nota = "Amostras cujos marcadores mais expressos são de outro tecido.") else list(tipo = "p", texto = ""),
  if (NROW(S$duplicados)) list(tipo = "tabela", df = S$duplicados, nota = "Pares de amostras com perfil quase idêntico; idade ou sexo diferentes descartam o mesmo doador.") else list(tipo = "p", texto = ""),
  list(tipo = "h2", texto = "Comparabilidade dos dados"),
  list(tipo = "p", texto = "Pergunta: os estudos que juntamos olham para dados comparáveis? Medimos quantos genes cada amostra e cada estudo resgata, quantos genes os estudos têm em comum e quão parecidos são os perfis de expressão e os efeitos do DM2, dentro de cada tecido e entre tecidos."),
  list(tipo = "b", itens = leitura),
  list(tipo = "h3", texto = "Genes resgatados por estudo"),
  list(tipo = "tabela", df = C$estudos[, c("gse", "tecido", "tipo", "amostras", "mulheres_40a60_modelo", "genes_medidos", "genes_analisados_05", "genes_detectados_estudo", "mediana_detectados_amostra", "amostras_baixa_deteccao")]),
  list(tipo = "img", arq = figs[["deteccao"]], largura = 6.5, altura = 3.8),
  list(tipo = "h3", texto = "Similaridade dentro e entre tecidos"),
  list(tipo = "tabela", df = C$resumo), list(tipo = "tabela", df = C$cobertura),
  list(tipo = "img", arq = figs[["perfil"]], largura = 6.3, altura = 5.5),
  list(tipo = "img", arq = figs[["jaccard"]], largura = 6.3, altura = 5.5),
  list(tipo = "img", arq = figs[["efeito"]], largura = 6.3, altura = 5.5),
  list(tipo = "h3", texto = "Identidade do tecido (percentil médio dos marcadores)"),
  list(tipo = "tabela", df = C$identidade)),
  if (!is.null(N)) list(list(tipo = "h3", texto = "Nulos: permutação dos rótulos e conjuntos aleatórios"), list(tipo = "tabela", df = N)) else list(),
  list(list(tipo = "h3", texto = "Conferência com o metafor"), list(tipo = "tabela", df = MF),
       list(tipo = "h3", texto = "Datas das saídas"), list(tipo = "tabela", df = X))),
  "docs/sanidade.docx", "Testes de sanidade e comparabilidade", etapa = "sanidade")
if (res[["ERRO"]] > 0) { message("SANIDADE: há verificações com ERRO; ver docs/sanidade.md"); quit(status = 1) }
