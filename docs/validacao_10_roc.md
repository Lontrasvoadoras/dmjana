# Validação da etapa 10: curva ROC dos programas

Gerado em 12/10/2026 12:29 a partir de `output/10_roc/`.

## 1. Deixar um estudo de fora (genes escolhidos sem o estudo testado)

| Tecido | Estudo testado | Módulo escolhido no treino | Genes (sobem/descem) | DM2/ND | AUC (IC 95%) | p (Wilcoxon) | AUC de genes sorteados (mediana; p95) | p vs genes sorteados |
|---|---|---|---|---|---|---:|---|---:|
| ilhotas | GSE41762 | M4 (≠ etapa 06) | 20 (20/0) | 6/12 | 0,69 (0,43 a 0,96) | 0,11 | 0,53; 0,75 | 0,12 |
| ilhotas | GSE221156 | M6 | 20 (20/0) | 2/4 | 0,50 (0,00 a 1,00) | 0,6 | 0,50; 0,88 | 0,53 |
| ilhotas | GSE76895 | M6 | 20 (20/0) | 2/6 | 1,00 (1,00 a 1,00) | 0,036 | 0,67; 1,00 | 0,077 |
| ilhotas | GSE86469 | M6 | 18 (18/0) | 2/2 | 1,00 (1,00 a 1,00) | 0,17 | 0,50; 1,00 | 0,15 |
| musculo | GSE18732 | M3 (≠ etapa 06) | 50 (50/0) | 10/12 | 0,56 (0,29 a 0,83) | 0,34 | 0,49; 0,65 | 0,25 |
| musculo | GSE25462 | M9 (≠ etapa 06) | 32 (0/32) | 3/8 | 0,25 (0,00 a 0,59) | 0,9 | 0,54; 0,88 | 0,93 |
| sangue | GSE184050 | M10 (≠ etapa 06) | 11 (2/9) | 9/19 | 0,46 (0,23 a 0,69) | 0,63 | 0,47; 0,65 | 0,56 |
| sangue | GSE250283 | M14 (≠ etapa 06) | 20 (11/9) | 4/8 | 0,25 (0,00 a 0,57) | 0,92 | 0,50; 0,78 | 0,92 |
| sangue | GSE249102 | M8 (≠ etapa 06) | 20 (0/20) | 2/2 | 0,00 (0,00 a 0,00) |   1 | 0,50; 1,00 |   1 |

## 2. AUC combinada (meta-análise das rodadas)

| Tecido | Estudos | AUC combinada (IC 95%) | p (Hartung-Knapp) | AUC efeito fixo | p (efeito fixo) | Estudos com AUC > 0,5 | Mesmo módulo da etapa 06 |
|---|---:|---|---:|---:|---:|---|---|
| ilhotas | 4 | 0,69 (0,29 a 0,92) | 0,23 | - | - | 3/4 | 3/4 |
| musculo | 2 | 0,44 (0,00 a 1,00) | 0,76 | 0,47 | 0,79 | 1/2 | 0/2 |
| sangue | 3 | 0,38 (0,10 a 0,77) | 0,36 | - | - | 0/3 | 0/3 |

## 2b. Tecido com 1 estudo (fígado): validação cruzada dentro do estudo

| Tecido | Estudo | Partes × repetições | DM2/ND | AUC mediana (IC 95%) | AUC mín.–máx. | p (Wilcoxon) | AUC de genes sorteados (mediana; p95) | p vs sorteados | Módulo mais escolhido |
|---|---|---|---|---|---|---:|---|---:|---|
| figado | GSE130991 | 5 × 10 | 146/58 | 0,64 (0,55 a 0,72) | 0,60–0,66 | 0,0014 | 0,57; 0,64 | 0,025 | M6 (28/50) |

## 3. Validação externa (treino com todos os estudos principais)

| Tecido | Estudo | Genes medidos | DM2/ND | AUC (IC 95%) | p (Wilcoxon) | p vs genes sorteados | Limitação |
|---|---|---:|---|---|---:|---:|---|
| musculo | GSE21340 | 8 | 3/5 | 0,53 (0,06 a 1,00) | 0,5 | 0,49 | lote confundido com o grupo; array antigo com ~5 mil genes |
| sangue | GSE156993 | 20 | 5/4 | 0,90 (0,67 a 1,00) | 0,032 | 0,038 | casos com DM2 + dislipidemia + periodontite x controles saudáveis (comorbidades não pareadas) |
| sangue | GSE189005 | 19 | 5/5 | 0,28 (0,00 a 0,68) | 0,89 | 0,75 | lote (data de leitura) confundido com o grupo: controles e DM2 lidos em datas diferentes |
| figado | GSE15653 | 50 | 3/4 | 0,50 (0,00 a 1,00) | 0,57 | 0,48 | estudo pequeno (3 x 4); controles misturam magras e obesas; replicação do fígado (dois níveis) |

## 4. Comparação com a AUC circular (otimista)

| Tecido | Estudo | AUC deixando o estudo de fora | AUC circular (genes escolhidos com o próprio estudo) |
|---|---|---:|---:|
| ilhotas | GSE221156 | 0,50 | 0,75 |
| ilhotas | GSE41762 | 0,69 | 0,62 |
| ilhotas | GSE76895 | 1,00 | 1,00 |
| ilhotas | GSE86469 | 1,00 | 1,00 |
| musculo | GSE18732 | 0,56 | 0,83 |
| musculo | GSE25462 | 0,25 | 1,00 |
| sangue | GSE184050 | 0,46 | 0,75 |
| sangue | GSE249102 | 0,00 | 1,00 |
| sangue | GSE250283 | 0,25 | 1,00 |

A AUC circular usa genes escolhidos olhando o próprio estudo e é otimista por construção; só serve para mostrar quanto a escolha 'enxerga' as respostas.
