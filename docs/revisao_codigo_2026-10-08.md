# Revisão de código — etapas 01 a 08 (08/10/2026)

Pedido do usuário: "revisar o código antes de seguir". Inclui os quatro achados de uma tabela de revisão enviada pelo usuário, conferidos no código.

## 1. Problemas encontrados e corrigidos

| # | Severidade | Onde | Problema | Impacto | Correção |
|---|---|---|---|---|---|
| C1 | Alta | `R/05_meta.R`, `ajustar()` (voom) | Nos estudos com voom (GSE200678, GSE221156, GSE86469), o g era padronizado pelo desvio-padrão residual ponderado do voom, que fica perto de 1 (os pesos são o inverso da variância), e não pelo desvio-padrão real da expressão (0,28–0,62). | g desses 3 estudos 2–4 vezes menor que o correto; peso e efeito subestimados nas meta-análises de adiposo e ilhotas (etapas 05 e 08). Redes (06) e escores de via (07) não são afetados (usam limma sem pesos). | Padronização pela expressão em log2-CPM sem pesos (`lmFit(Y$E, design0)`). Conferido: desvio-padrão usado 0,65 / 0,32 / 0,80 contra real 0,59 / 0,28 / 0,62. |
| C2 | Alta (relatório) | `run_06_redes.R` (relatório) e `R/99_documentar.R` | A coluna de seleção dos módulos, relida do CSV, vinha como NA, e NA passa em `nzchar()`. | O Word da etapa 06 dizia "110 módulos selecionados (NA significativos…)"; o certo era 1. Os resultados gravados estavam certos. | NA convertido em vazio antes de contar e mostrar. |
| C3 | Média | `R/06_redes.R`, `selecionar_modulos()` | O nível exploratório ("p < 0,05 e todos os estudos no mesmo sentido") não exigia 2+ estudos; com 1 estudo (fígado) a concordância é trivial. | Sem efeito nesta execução (nenhum módulo do fígado com p < 0,05); inconsistente com a regra da etapa 07. | Exploratório exige 2+ estudos. |
| T1 | Alta | `run_07_enriquecimento.R`, `run_08_painel.R`, `R/08_painel.R`, Word da etapa 08 | (tabela do usuário) Depois que a significância das vias passou para o escore, o painel usava o nível do escore, mas o código e o Word ainda descreviam a regra antiga (GSEA com FDR < 0,25). Além disso, o leading edge da GSEA era usado mesmo quando o NES tinha sinal oposto ao efeito pelo escore (genes do lado errado). | Genes do leading edge podiam entrar no painel puxando a via no sentido contrário; descrição incoerente com o código. | Leading edge só com NES no mesmo sinal do efeito (`leading_edge_coerente`); concordância do NES entre estudos registrada à parte; regra reescrita no código e no Word. |
| T2 | Alta | `run_06_redes.R` | (tabela do usuário) Falha no cálculo da preservação virava "todos preservados"; a mesma saída era usada para 1 estudo de construção. | Sem efeito nesta execução (nenhuma falha registrada no log), mas uma falha futura deixaria módulos avançarem como validados. | Três estados: "preservado / não preservado", "não avaliável (1 estudo de construção)" e "cálculo falhou (bloqueado)"; falha bloqueia o módulo. |
| T3 | Média | `run_07_enriquecimento.R` | (tabela do usuário) Cache da GSEA reutilizado só pela existência do arquivo. | Mudanças nos efeitos, conjuntos ou parâmetros podiam se misturar a resultados antigos (nesta rodada o cache foi apagado à mão). | Cache com assinatura (md5) das entradas: efeitos dos genes, meta-análises, parâmetros e coleções; refeito se algo mudar. |
| T4 | Média | `run_05_meta.R` | (tabela do usuário) Se o ajuste do modelo principal falhasse num estudo, `NULL` seguia e a etapa parava ao ler `p$p`. | Um estudo inviável interromperia a etapa inteira. | Estudo sem ajuste viável é registrado no log e pulado. |

## 2. Pontos de desenho (não são erros de código; pedem decisão)

| # | Onde | Observação | Proposta |
|---|---|---|---|
| D1 | Painel (etapa 08) | Os critérios são permissivos por construção: todo candidato vindo de via ganha o ponto "via" (é a razão de ele estar na lista); "robusto a tirar um estudo" só confere o sinal (78 de 81 candidatos das ilhotas o ganham); "ligação com outro tecido" pode vir de genes do fígado, que só têm evidência de um estudo. Um candidato das ilhotas já começa com 2 pontos. | Endurecer: robustez = sinal mantido e p < 0,10 em cada retirada; ligação só com candidatos de tecidos com 2+ estudos; ponto de via só para via significativa/sugestiva ou convergente. |
| D2 | `R/05_meta.R`, correção de Hedges | J usa os graus de liberdade moderados do limma (que incluem a informação emprestada de todos os genes), e não n1 + n2 − 2. Com 2 × 2 mulheres, J fica perto de 1 em vez de ~0,57. | Defensável (a variância moderada tem mais graus de liberdade), mas vale registrar; alternativa conservadora: J com n1 + n2 − 2. |

## 3. Verificações sem problema

- Pesos e escala: limma comum (arrays, escores, eigengenes) usa o desvio-padrão real (GSE41762: 0,28 usado × 0,27 real).
- Lote retirado antes da rede preservando status e sexo; teste dos módulos com o mesmo modelo da etapa 05.
- Sinal dos eigengenes alinhado à média de expressão do módulo em cada estudo (comparável entre estudos).
- Nomes das colunas da GSEA (p, fdr) mapeados na ordem certa ao renomear.

## 4. Acréscimos pedidos pelo usuário (08/10/2026)

| # | Pedido | Implementação |
|---|---|---|
| U1 | Testes de sanidade no fluxo (NULL, NA, 0/1 ou valores que não deveriam existir) | `R/98_sanidade.R` e `run_sanidade.R`: ~1.000 verificações nas saídas das etapas 02 a 08 (valores impossíveis, rótulos fora do conjunto, duplicados, colunas vazias ou constantes, coerência entre colunas). ERRO faz a execução falhar; ALERTA vai para `docs/sanidade.md` e `docs/sanidade.docx`. Roda no fim de `atualizar_documentos.sh`. |
| U2 | Redes e módulos presentes em pelo menos 2 estudos (não em todos) | Consenso pelo quantil (n − 2)/(n − 1) da força das ligações (2º maior valor entre os estudos); módulo preservado = Zsummary ≥ 2 em estudos que, com a referência, somem 2 ou mais. |
| U3 | Testes que combinem os estudos e mostrem a influência de cada um | Stouffer ponderado com sinal, rOP (r = 2, "efeito em pelo menos 2 estudos"), p de heterogeneidade (Cochran Q) em todas as meta-análises; tabela de influência (peso, efeito e p sem cada estudo, inversão de sentido, mudança de conclusão). Novo nível "exploratório (≥ 2 estudos)" para módulos e vias. |
| U4 | Seguir com tecidos de 1 estudo, marcados como exploratórios de 1 estudo | Fígado: módulos e vias com p < 0,05 entram como "exploratório (1 estudo)"; genes do painel desse tecido levam o mesmo rótulo. |
| U5 | Sanidade completa e comparabilidade dos dados (genes resgatados por amostra e por estudo, similaridade dos genes por tecido e entre tecidos) | `R/97_comparabilidade.R`, `config/sanidade.yaml`: genes detectados (CPM ≥ 1; arrays acima do fundo dos genes do Y nas mulheres), Jaccard dos genes, correlação dos perfis e dos efeitos do DM2, concordância de sentido entre genes com p < 0,05; controles biológicos (sexo, identidade do tecido, controles positivos nas ilhotas); permutação dos rótulos e conjuntos aleatórios; conferência com o metafor; N, símbolos do Excel/aliases, duplicados, balanço de confusores (SMD), saídas desatualizadas, reprodutibilidade. Saídas em `output/sanidade/` e no Word da sanidade. |
| U6 | Escore de via competitivo (achado da sanidade completa) | Em GSE221156, GSE18732 e GSE25462, 49–80% dos conjuntos de genes sorteados davam p < 0,05 (deslocamento global com o DM2), e 91% das vias exploratórias novas das ilhotas subiam no DM2. O escore passou a descontar a média de todos os genes da amostra (`config/meta.yaml: vias: competitivo`); etapas 05–08 refeitas. |
| U7 | Painel mais rígido (D1) | Ponto de via só para via significativa/sugestiva ou convergente; ponto de ligação só com candidato de tecido com 2+ estudos; robustez = sentido mantido e p < 0,10 em cada retirada. Antes, quase todo candidato das ilhotas ganhava 3 pontos (painel de 36 → 1.265 genes com os níveis novos). |
| U8 | Decisões sobre alertas | GSE29226 ND2/ND3 não são duplicados (65 e 60 anos; regra de duplicados confere idade e sexo). GSE198922 11_PRE, 4_PRE e 46_PRE mantidas com nota de possível contaminação por músculo (fora do modelo principal). |
