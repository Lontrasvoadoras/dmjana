# Revisão do workflow, dos métodos e do código (08/10/2026, 2ª rodada)

Pedido do usuário: "revisar todo o código, todas as decisões, buscar incoerências no workflow, nos métodos e nos códigos", considerando uma lista de achados enviada pelo usuário (itens marcados **[usuário]**). Cada achado foi conferido no código e nos dados antes da correção.

## 1. Prioridade alta

| # | Achado | Conferência | Ação |
|---|---|---|---|
| A1 | **[usuário]** O rOP não estava calibrado para "efeito em pelo menos 2 estudos": `pbeta(p_(2), 2, k−1)` supõe todos os estudos nulos. | Confirmado (`R/05_meta.R`, `meta_dl`). A nula é composta ("no máximo 1 estudo com efeito"); no pior caso um estudo tem p = 0 e o 2º menor p é o menor dos k − 1 nulos. | p = 1 − (1 − p₍₂₎)^(k−1), válido sob a nula composta. Com k = 2, p = maior p (os dois precisam ser significativos). |
| A2 | Quando os 2 estudos mais fortes discordavam no sinal, o rOP virava NA e saía da família do FDR (FDR otimista). | Achado desta revisão (`p.adjust` conta só os não-NA). | Discordância → p = 1, e o teste continua contando no FDR. |
| A3 | **[usuário]** GSE156993 não isola o DM2: todos os casos têm dislipidemia + periodontite (DL-P), e os controles são saudáveis. | Confirmado nos títulos ("T2DMpoorly-DL-P", "T2DMwell-DL-P" x "H"). O grupo pareado (DL-P sem DM2) tem 2 mulheres de 40–60 (40 e 42 anos) e não foi processado na etapa 04. | **Decisão do usuário:** fora da análise principal; só na sensibilidade "com estudos só de sensibilidade" (`config/meta.yaml: so_sensibilidade`). Como a rede não usa o status de DM2, o estudo continua ajudando a construir a rede de sangue (`rede: true`), mas não entra no teste dos módulos. A sensibilidade com controles DL-P não foi feita: exigiria reprocessar o estudo para 2 controles mais jovens que os casos. |
| A4 | **[usuário]** A etapa 06 estava desatualizada em relação à configuração e à etapa 05. | Confirmado e com causa estrutural: os genes-chave da etapa 06 usam os efeitos por gene da etapa 05, mas o modo "só relatório" (SO_RELATORIO) não recalculava nada. A verificação de datas também não listava a 05 como dependência da 06. | A rede e a preservação (a parte cara) ficam em cache com assinatura (estudos, genes, expressão, parâmetros); o teste dos módulos, a seleção, a influência e os genes-chave são **sempre** refeitos. `atualizar_documentos.sh` não usa mais SO_RELATORIO. A sanidade passou a listar a 05 como dependência da 06. Etapas 05 a 08 refeitas do zero. |

## 2. Prioridade média

| # | Achado | Conferência | Ação |
|---|---|---|---|
| M1 | **[usuário]** O único gene com FDR < 0,05 nas ilhotas (UQCRHL) é descoberta de 1 estudo (GSE221156: 2 x 4 mulheres, λ 2,6, 21% dos genes com p < 0,05), não replicação. | Confirmado; o relatório já o classificava como "descoberta". | O resumo e o Word da etapa 05 dizem explicitamente quantos genes com FDR < 0,05 são descobertas de 1 estudo em tecidos com 2+ estudos ("pistas, não replicações"), com o UQCRHL como exemplo. |
| M2 | **[usuário]** O tamanho de efeito e a sua incerteza vinham de aproximações diferentes: J usava os graus de liberdade moderados do limma, mas a variância de g usava 2(n1 + n2). Para UQCRHL, p = 2,5e-5 e IC de g de 2,5 a 10,7. | Confirmado. Este era também o ponto D2 da revisão anterior. | var(g) = (J × erro padrão do logFC no limma / s)² + g²/(2 df), com o mesmo df moderado do J. O 1º termo vem do próprio ajuste do limma, incluindo pesos do voom e o desbalanço do desenho com covariáveis. Uma 1ª versão com J²(1/n1 + 1/n2) deixava o GSE18732 (lote como covariável) ~20% mais preciso que o limma (|z de g| / |t| = 1,20); com o erro padrão do limma a razão fica perto de 1 em todos os estudos. O 2º termo (incerteza do desvio-padrão) é a única diferença que resta entre o IC de g e o p do limma, e pesa só com g grande e poucos graus de liberdade (ex.: UQCRHL). |
| M3 | **[usuário]** O "g mínimo na escala do genoma" usava α = 10⁻⁴ fixo e é uma aproximação de efeito fixo. | Confirmado (`run_05_meta.R`). | α = 0,05 / nº mediano de genes dos estudos do tecido (Bonferroni), mostrado na tabela; o texto diz que é estimativa de **planejamento**, não o poder efetivo (Hartung-Knapp com poucos estudos e FDR). |
| M4 | O Word da etapa 05 ainda dizia que a meta-análise principal era DerSimonian-Laird. | Achado desta revisão; o principal é Hartung-Knapp desde 07/10. | Texto corrigido (HK principal, DL sensibilidade, testes combinados ao lado). |
| M5 | Genes-chave exigiam kME ≥ 0,7 em **todos** os estudos de construção, enquanto a rede e a preservação exigem ≥ 2 estudos. | Achado desta revisão (incoerência com o pedido do usuário). | **Decisão do usuário:** kME ≥ 0,7 em pelo menos 2 estudos (coluna `kME_2` = 2º maior kME; com 2 estudos, continua sendo nos dois). |

## 3. Tabelas e verificações

| # | Achado | Ação |
|---|---|---|
| T1 | **[usuário]** A conferência com o metafor (diferença ~10⁻¹⁵) valida a álgebra, não as premissas. | Registrado; as premissas são tratadas em A1, M2 e nos testes nulos da sanidade (permutação, conjuntos aleatórios). |
| T2 | **[usuário]** A sobreposição de doadoras usava "?" quando faltava o IMC: as 20 linhas tinham IMC ausente, ou seja, só tecido + status + idade inteira coincidiam. | Só doadoras com idade **e** IMC conhecidos entram; o texto trata o resultado como pista para conferir na fonte. |
| T3 | **[usuário]** `string_entre_tecidos.csv` tinha cada par duas vezes (A–B e B–A) e não registrava os tecidos. | Uma linha por par de genes, com `tecidos_gene1` e `tecidos_gene2`; o relatório fala em "pares de genes únicos" (antes 53.302 linhas, 26.651 pares). Pares ligante–receptor também sem repetição. |
| T4 | Comentário desatualizado na convergência da etapa 07 ("GSEA FDR < 0,25"). | Corrigido para a regra atual (via selecionada pelo escore). |

## 4. Conferido sem problema

- Amostras repetidas da mesma pessoa: GSE184050 (baseline e follow-up) e GSE198922 (PRE, POST, REC) entram no modelo com uma amostra por pessoa (só a basal); n1/n2 = doadoras únicas.
- Outros contrastes: GSE15653 (fígado) compara DM2 obesas com controles magras e obesas (o IMC entra na sensibilidade); GSE25462 (músculo) inclui controles com história familiar de DM2. Ficam documentados como limitações, sem mudança.
- Nas redes, o lote é retirado antes da construção; no teste dos eigengenes, o lote entra como covariável, como na etapa 05.
- Os escores de via das etapas 05 e 07 usam a mesma função (competitiva) e as mesmas amostras.

## 5. Decisões do usuário nesta revisão

1. GSE156993 fora da análise principal (só sensibilidade); continua construindo a rede de sangue.
2. Genes-chave com kME ≥ 0,7 em pelo menos 2 estudos de construção.

## 6. Conferência depois das mudanças (reavaliação do código)

| # | Achado | Ação |
|---|---|---|
| R1 | Na 1ª versão da nova variância de g, a precisão batia com o limma em todos os estudos menos o GSE18732 (lote como covariável): \|g/ep\| / \|t\| = 1,20, ou seja, o estudo pesava ~20% a mais na meta-análise do músculo. | Erro padrão tirado do próprio ajuste do limma (inclui pesos do voom e desbalanço do desenho). Nova verificação na sanidade: a mediana de \|g/ep\| / \|t\| precisa ficar entre 0,85 e 1,15 em cada estudo. |
| R2 | As listas exploratórias de vias (p < 0,05 sem correção) não eram comparadas ao que o acaso produz (5% das vias testadas). | Os relatórios da etapa 07 e o relatório consolidado mostram "p < 0,05 observadas" e "esperadas ao acaso". Listas desse tamanho não são evidência por si; valem quando convergem com módulos e genes. |
| R3 | Faltava uma visão de conjunto do workflow em Word. | Novo `docs/relatorio_workflow.R` → `docs/relatorio_workflow.docx` (resumo, etapas 01–08, sanidade, limitações), gerado só a partir das saídas; incluído no fim de `atualizar_documentos.sh`. |

## 7. Decisões do usuário após a reavaliação (08/10/2026)

| # | Decisão | Implementação |
|---|---|---|
| U9 | Efeito fixo no nível exploratório de músculo e sangue (tecidos com 2 estudos): com o Hartung-Knapp (t com 1 g.l.) nenhum p < 0,05 era alcançável (menor p: 0,14 no músculo, 0,18 no sangue). | `meta_dl` calcula `g_fe` e `p_fe`; `config/redes.yaml: teste: efeito_fixo_2_estudos`. Etapas 06 e 07 rotulam "exploratório (efeito fixo, 2 estudos)"; na etapa 08 o critério de efeito consistente usa o efeito fixo nesses tecidos. O Hartung-Knapp continua sendo o teste principal (FDR). |
| U10 | Genes de resposta imediata (FOS, JUN, EGR1, BTG2, KLF9, PPP1R15A e afins) indicados como possível artefato de coleta, sem sair da análise. | Lista em `config/meta.yaml: genes_resposta_imediata`; coluna `resposta_imediata` em meta_genes (05), genes-chave (06) e candidatos (08); seção própria nos relatórios e no Word da etapa 05; resumo em `output/05_meta/resposta_imediata_resumo.csv`. Para a discussão posterior. |

## 8. Conferência de 10/10/2026 (workflow e código)

| # | Achado | Ação |
|---|---|---|
| C1 | No GSE130991, 17% dos conjuntos de genes sorteados davam p < 0,05 no escore de via (efeito global do DM2 no estudo); no GSE221156, 19%. | Calibração empírica do p das vias contra 2.000 conjuntos sorteados do mesmo tamanho (`config/redes.yaml: enriquecimento: calibracao_sorteios`), só para cima: p = max(paramétrico, empírico). FDR refeito por tecido × coleção × nível. Fígado: 0 vias no FDR; restam vias exploratórias. |
| C2 | A reclassificação do GSE130991 (em tratamento para diabetes = DM2) estava na curadoria, mas o estudo não tinha sido reprocessado na etapa 04 (rodada em SO_RELATORIO). | GSE130991 reprocessado (146 × 58 mulheres de 40–60). Nova verificação de sanidade (ERRO): status em amostras_qc igual ao da curadoria. |
| C3 | Fígado em dois níveis (decisão da pesquisadora): GSE130991 = descoberta; GSE15653 = replicação. | `run_08b_replicacao_figado.R`: módulos, vias e genes do GSE130991 comparados no GSE15653 — não replicou (vias e genes perto de 50% de concordância de sentido). |
| C4 | Medicação: estatina no GSE130991 (covariável) e metformina em controles do GSE18732 (exclusão). | Sensibilidades em `output/05_meta/sensibilidade_medicacao_vias.csv`; a estatina reduz à metade o efeito da via de homeostase do colesterol no fígado. |
| C5 | 16 amostras com sexo declarado discordante da expressão em 6 estudos (13 trocas claras, 3 ambíguas). | Figura `docs/figuras/sexo_discordantes.png` e tabela `output/04_processamento/sexo_discordantes.csv` (`docs/figura_sexo_discordantes.R`). |
| C6 | Limitações registradas: GSE250283 perde 10 amostras do GPL36360 (2 mulheres com DM2); sensibilidade com o grupo DMCAD pendente; detecção de doadoras repetidas no gerador da curadoria depende de uma saída da sanidade. | Nos relatórios (Word e web). |
| C7 | A curva ROC (etapas 10 e 10b) não avaliava o GSE130991: com 1 estudo, não há deixar-um-de-fora (apontado pela pesquisadora). | Validação cruzada dentro do estudo (5 partes estratificadas × 10 repetições; modelo, módulo e genes refeitos sem a parte testada): AUC 0,64 (0,55–0,72); genes sorteados 0,58 (p = 0,025). Otimização aninhada dentro do estudo: 0,73 (0,65–0,80), regra do genoma inteiro. `config/roc.yaml: validacao_cruzada`; saídas `output/10_roc/validacao_cruzada*.csv` e `otimizada_validacao_cruzada*.csv`. |
| C8 | Pergunta da pesquisadora (11/10/2026): outros estudos excluídos têm dados clínicos para deduzir o status, como o GSE130991? | Varredura das características de todas as amostras dos 487 estudos não elegíveis (HbA1c, glicemia, TOTG, insulina/HOMA, tratamento, diagnóstico escrito de outra forma), sem exigir status (`docs/varreduras/varre_clinico*.R`; saídas `output/02_metadados/varredura_clinica_*.csv`). Nenhum resgate novo: os únicos com HbA1c/glicemia em mulheres de 40–60 sem status são GSE50244/GSE50397 (já excluídos por doadores repetidos); GSE268273 (fígado, 52 mulheres) e GSE263644 (adiposo epicárdico, 10 mulheres) têm HbA1c mas não têm idade (nem no GEO nem nos arquivos suplementares); GSE231509 chega no máximo a 1 mulher com DM2; os demais "sem status" com mulheres de 40–60 não têm nenhum dado glicêmico (estudos de envelhecimento, dieta, exercício, COVID). |

## 9. Revisão externa de 11/10/2026 (aplicada em 12/10/2026)

| # | Achado | Ação |
|---|---|---|
| X1 | ROC transdutiva: a rede da etapa 06 inclui o estudo testado e os externos GSE156993 (sangue) e GSE15653 (fígado). | Texto da etapa 10, glossário e relatórios: "avaliação condicionada à rede". Nova etapa 10d (`run_10d_rede_por_rodada.R`): rede refeita em cada rodada só com o treino. Ilhotas 0,70 (era 0,69; módulo parecido com o M6 em 3/4 rodadas); músculo 0,54; sangue 0,39; fígado (validação cruzada) 0,69; externo GSE156993 cai de 0,90 para 0,70; GSE15653 0,33. Conclusões mantidas. |
| X2 | `atualizar_documentos.sh` não parava em falha. | `set -e`: para na primeira etapa que falhar, inclusive ERRO na sanidade. |
| X3 | Falha no ajuste dos eigengenes (etapa 06) virava NULL em silêncio. | `log_msg` com o erro; sanidade (ERRO) se algum estudo principal do tecido não tiver o teste dos módulos. |
| X4 | Sanidade sem as etapas 10b/10c. | Verificações novas (10b, 10c, validação cruzada do fígado, 10d): AUC/IC válidos, p em (0, 1], repetições e partes completas, cada mulher testada uma vez por repetição, estudo testado fora do treino e da rede. Sanidade: 1.449 verificações, 0 ERRO, 7 ALERTA. |
| X5 | Alertas reais nos dados. | Tabela dos alertas no relatório final (Tabela 2) e lista comentada na página web. |
| X6 | LEIAME desatualizado. | Etapas 06–10d, sanidade, relatórios e revisões atualizados. |

## 10. Reavaliação do GSE50244 (pedido da pesquisadora, 12/10/2026)

O critério de 09/10 (mesmo sexo, idade ±1 ano e IMC ±0,6, sem exigir pareamento 1:1) marcava 79 de 89 doadores como repetidos do GSE41762; com os dados do GSE41762 deslocados, ~25 doadores (p95 31) coincidem ao acaso, e 23 doadores tinham 2+ candidatos. Teste decisivo pela expressão: o GSE50397 é o array HuGene 1.0 ST dos mesmos 89 doadores (ligados ao GSE50244 por sexo, ano de nascimento, idade, IMC e HbA1c idênticos, 89/89), na mesma plataforma do GSE41762. Perfil centrado (5.000 sondas mais variáveis): 66 doadores com r 0,84–0,97 e margem ≥ 0,2 sobre o 2º melhor, pareamento 1:1, mais 1 (r 0,95, IMC e HbA1c idênticos) = **67 repetidos**; 22 doadores novos (r ≤ 0,69, metadados diferentes). Um dos repetidos (GSM1023682 no GSE41762) é declarado mulher no GSE41762 e homem no GSE50244; a etapa 04 já o tinha retirado por sexo genético masculino — confirmação independente. Entre os 22 novos há 3 mulheres de 40–60 (1 sem diabetes, 2 com HbA1c intermediária, nenhuma com DM2): o GSE50244 continua fora. Scripts: `docs/varreduras/reavaliar_GSE50244*.R`; saídas `output/02_metadados/reavaliacao_GSE50244_*.csv`; gerador da curadoria passa a usar a classificação por expressão.

## 11. Fígado: doença x remédio, e medicação nos artigos (pedido da pesquisadora, 12/10/2026)

Etapa 08c (`run_08c_figado_medicacao.R`), GSE130991, mulheres de 40–60: sem estatina (88 × 54) o sinal se mantém (M6 g 0,56; correlação dos g com o principal 0,94); DM2 sem tratamento × sem diabetes (23 × 58) não tem sinal (M6 g −0,05, p 0,85; colesterol −0,02; 4,9% dos genes com p < 0,05, igual ao acaso); tratadas × não tratadas (123 × 23) M6 g 0,54, e 0,71 (p 0,003) ajustando por estatina, HbA1c, glicemia e IMC; 0,65 só sem estatina; o M6 não acompanha a HbA1c dentro dos grupos. Conclusão: o sinal do fígado é, em grande parte, de DM2 tratada (remédio ou tempo de doença), não da hiperglicemia. Revisão dos artigos (Europe PMC) e do GEO em `input/medicacao_estudos.csv`: remédio por pessoa só no GSE130991 e no GSE18732; GSE18732 suspendeu o antidiabético 1 semana antes da biópsia; GSE25462 com DM2 sem remédio; demais desconhecidos. Conferido: GSE249102 (estudo de tuberculose) usa só os grupos DM2 e controle.
