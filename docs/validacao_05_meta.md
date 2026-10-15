# Validação da etapa 05: efeito do DM2 por estudo e meta-análise por tecido

Gerado em 12/10/2026 12:19 a partir de `output/05_meta/`. **Aprovar antes de seguir.**

## 1. Estudos no modelo

Só genes codificantes de proteína; lote (data de leitura do array) como covariável quando há 2+ lotes (decisões do usuário de 07/10/2026).

| GSE | Tecido | Método | Doadores | F 40–60 DM2/ND | Genes | Vias | IMC | Lote ajustado | Genes p < 0,05 | Genes FDR < 0,05 (estudo) |
|---|---|---|---:|---|---:|---:|---|---|---:|---:|
| GSE200678 | adiposo | voom | 31 | 4/2 | 13351 | 50 | sim | não | 668 | 0 |
| GSE133666 | adiposo | limma | 17 | 4/3 | 17864 | 50 | sim | não | 575 | 0 |
| GSE198922 | adiposo | trend | 46 | 4/4 | 15250 | 50 | não | não | 1232 | 0 |
| GSE29226 | adiposo | limma | 6 | 2/2 | 14975 | 50 | não | não | 472 | 0 |
| GSE130991 | figado | trend | 564 | 146/58 | 16149 | 50 | sim | não | 2235 | 425 |
| GSE41762 | ilhotas | limma | 75 | 6/12 | 17357 | 50 | sim | sim | 1814 | 0 |
| GSE221156 | ilhotas | voom | 34 | 2/4 | 15315 | 50 | não | não | 3160 | 275 |
| GSE76895 | ilhotas | limma | 66 | 2/6 | 17312 | 50 | sim | não | 1214 | 3 |
| GSE86469 | ilhotas | voom | 8 | 2/2 | 14628 | 50 | não | não | 586 | 0 |
| GSE18732 | musculo | limma | 91 | 10/12 | 17312 | 50 | sim | sim | 1941 | 0 |
| GSE25462 | musculo | limma | 48 | 3/8 | 17312 | 50 | sim | não | 1338 | 0 |
| GSE184050 | sangue | trend | 56 | 9/19 | 14933 | 50 | não | não | 534 | 0 |
| GSE250283 | sangue | limma | 35 | 4/8 | 13629 | 50 | não | não | 648 | 0 |
| GSE249102 | sangue | limma | 8 | 2/2 | 16153 | 50 | não | não | 1405 | 0 |

Só na sensibilidade: GSE21340 (musculo; (lote confundido)); GSE189005 (sangue; (lote confundido)); GSE15653 (figado; replicação (fígado em dois níveis)); GSE156993 (sangue; (contraste não isola o DM2)).
Contraste que não isola o DM2 (revisão de 08/10/2026): GSE156993 — contraste DM2 + dislipidemia + periodontite x controles saudáveis (comorbidades não pareadas; o grupo pareado, dislipidemia + periodontite sem DM2, tem só 2 mulheres de 40-60 e não foi processado); GSE15653 — fígado em dois níveis: estudo pequeno (3 x 4) usado como replicação do GSE130991 (128 x 58), não como veto.
Fora da análise do genoma inteiro: GSE23561 (Matriz do autor com zeros na maioria das sondas: só 773 genes estimáveis).

### Balanço de idade e IMC (mulheres de 40–60) e sanidade de cada estudo

Esperado sem efeito: ~5% dos genes com p < 0,05 e lambda perto de 1. Diferença de idade > 5 anos mistura DM2 e estado menopausal.

| GSE | Tecido | Idade DM2 / ND | Diferença | IMC DM2 / ND | Genes p < 0,05 | λ | Alerta |
|---|---|---|---:|---|---:|---:|---|
| GSE200678 | adiposo | 49.8 / 51.5 | -1.7 | 37.7 / 34.5 | 5% | 1.25 |  |
| GSE133666 | adiposo | 57.2 / 45.3 | +11.9 | 46.3 / 47 | 3% | 0.82 |  |
| GSE198922 | adiposo | 56.2 / 56.5 | -0.3 | - / - | 8% | 1.39 |  |
| GSE29226 | adiposo | 49 / 57.5 | -8.5 | - / - | 3% | 0.77 |  |
| GSE130991 | figado | 50.3 / 48.2 | +2.1 | 48.2 / 41.9 | 14% | 1.52 | sinal fora do esperado (conferir lote/composição) |
| GSE41762 | ilhotas | 52.3 / 52 | +0.3 | 31.5 / 25.4 | 10% | 1.38 |  |
| GSE221156 | ilhotas | 51 / 54 | -3.0 | - / - | 21% | 2.6 | sinal fora do esperado (conferir lote/composição) |
| GSE76895 | ilhotas | 56.5 / 52.8 | +3.7 | 31.1 / 25.9 | 7% | 1.03 |  |
| GSE86469 | ilhotas | 48.5 / 54.5 | -6.0 | - / - | 4% | 1.01 |  |
| GSE18732 | musculo | 52.2 / 50 | +2.2 | 33.3 / 30.4 | 11% | 1.58 | sinal fora do esperado (conferir lote/composição) |
| GSE25462 | musculo | 52.7 / 47.4 | +5.3 | 36 / 26.2 | 8% | 1.44 |  |
| GSE184050 | sangue | 50.2 / 50.1 | +0.1 | - / - | 4% | 1.02 |  |
| GSE250283 | sangue | 52.8 / 53.5 | -0.7 | - / - | 5% | 1.09 |  |
| GSE249102 | sangue | 45 / 42.5 | +2.5 | - / - | 9% | 1.31 |  |

Meta-análise: Hartung-Knapp modificado (principal; recomendado com poucos estudos) e DerSimonian-Laird em sensibilidade (revisão de metodologia de 07/10/2026).

## 2. Resumo por tecido

| Tecido | Estudos | Genes | Replicados | Descoberta | Replicados FDR < 0,05 | Replicados FDR < 0,10 | Descoberta FDR < 0,05 | Vias FDR < 0,05 | Vias FDR < 0,10 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| adiposo | 4 | 19012 | 17860 | 1152 | 0 | 0 | 0 | 0 | 0 |
| figado | 1 | 16149 | 0 | 16149 | 0 | 0 | 425 | 3 | 9 |
| ilhotas | 4 | 18687 | 17672 | 1015 | 0 | 0 | 1 | 0 | 0 |
| musculo | 2 | 17312 | 17312 | 0 | 0 | 0 | 0 | 0 | 0 |
| sangue | 3 | 17602 | 15765 | 1837 | 0 | 0 | 0 | 0 | 0 |

## 3. Poder (efeito mínimo detectável, 80%)

| Tecido | Estudos | DM2/ND | g mínimo (p < 0,05) | g mínimo (escala do genoma) |
|---|---:|---|---:|---:|
| adiposo | 4 | 14/11 | 1,14 | 2,23 |
| figado | 1 | 146/58 | 0,43 | 0,85 |
| ilhotas | 4 | 12/24 | 1,00 | 1,97 |
| musculo | 2 | 13/20 | 1,01 | 2,00 |
| sangue | 3 | 15/29 | 0,90 | 1,76 |

## 4. Vias com FDR < 0,10

| Tecido | Via | Nível | Estudos | g (IC 95%) | I² | Mesmo sentido | FDR |
|---|---|---|---:|---|---:|---|---:|
| figado | CHOLESTEROL_HOMEOSTASIS | descoberta | 1 | 0,69 (0,38 a 1,00) | - | 1/1 | 0,00069 |
| figado | MTORC1_SIGNALING | descoberta | 1 | 0,52 (0,22 a 0,83) | - | 1/1 | 0,016 |
| figado | P53_PATHWAY | descoberta | 1 | 0,52 (0,21 a 0,83) | - | 1/1 | 0,016 |
| figado | MYC_TARGETS_V2 | descoberta | 1 | 0,43 (0,12 a 0,73) | - | 1/1 | 0,068 |
| figado | REACTIVE_OXYGEN_SPECIES_PATHWAY | descoberta | 1 | 0,42 (0,12 a 0,73) | - | 1/1 | 0,068 |
| figado | APICAL_SURFACE | descoberta | 1 | 0,41 (0,10 a 0,71) | - | 1/1 | 0,068 |
| figado | UNFOLDED_PROTEIN_RESPONSE | descoberta | 1 | 0,40 (0,10 a 0,71) | - | 1/1 | 0,068 |
| figado | PI3K_AKT_MTOR_SIGNALING | descoberta | 1 | 0,40 (0,09 a 0,70) | - | 1/1 | 0,069 |
| figado | UV_RESPONSE_UP | descoberta | 1 | 0,38 (0,08 a 0,69) | - | 1/1 | 0,079 |

Figura: `docs/figuras/meta_vias.png`.

## 5. Genes com FDR < 0,10 (até 15 por tecido)

| Tecido | Gene | Nível | Estudos | g (IC 95%) | I² | Mesmo sentido | FDR |
|---|---|---|---:|---|---:|---|---:|
| figado | SATB2 | descoberta | 1 | 0,99 (0,67 a 1,31) | - | 1/1 | 1,7e-05 |
| figado | LGALS4 | descoberta | 1 | 0,93 (0,62 a 1,25) | - | 1/1 | 5,6e-05 |
| figado | FAT1 | descoberta | 1 | 0,91 (0,60 a 1,23) | - | 1/1 | 6,5e-05 |
| figado | WIPI1 | descoberta | 1 | 0,91 (0,59 a 1,23) | - | 1/1 | 6,5e-05 |
| figado | DEFB1 | descoberta | 1 | 0,83 (0,51 a 1,14) | - | 1/1 | 0,00066 |
| figado | ME1 | descoberta | 1 | 0,82 (0,51 a 1,13) | - | 1/1 | 0,00066 |
| figado | ACADSB | descoberta | 1 | -0,82 (-1,13 a -0,50) | - | 1/1 | 0,00066 |
| figado | MVK | descoberta | 1 | 0,81 (0,50 a 1,13) | - | 1/1 | 0,00066 |
| figado | PITPNA | descoberta | 1 | 0,81 (0,50 a 1,13) | - | 1/1 | 0,00066 |
| figado | FKBP1C | descoberta | 1 | 0,80 (0,48 a 1,11) | - | 1/1 | 0,00089 |
| figado | FNDC1 | descoberta | 1 | 0,80 (0,48 a 1,11) | - | 1/1 | 0,00089 |
| figado | SQLE | descoberta | 1 | 0,78 (0,47 a 1,10) | - | 1/1 | 0,0012 |
| figado | ITGA6 | descoberta | 1 | 0,78 (0,47 a 1,09) | - | 1/1 | 0,0012 |
| figado | SULF2 | descoberta | 1 | 0,78 (0,47 a 1,09) | - | 1/1 | 0,0012 |
| figado | ACLY | descoberta | 1 | 0,78 (0,46 a 1,09) | - | 1/1 | 0,0012 |
| ilhotas | UQCRHL | descoberta | 1 | 6,57 (2,80 a 10,34) | - | 1/1 | 0,026 |

Figura: `docs/figuras/meta_vulcao.png`. Listas completas em `output/05_meta/<tecido>/meta_genes.csv`.

## 6. Sensibilidades

| Tecido | Análise | Estudos | Genes replicados FDR < 0,05 | Genes principais mantidos | Correlação dos g | Vias FDR < 0,05 | Vias principais mantidas | Vias |
|---|---|---:|---:|---|---:|---:|---|---|
| adiposo | principal | 4 | 0 | - | 1,00 | 0 | - |  |
| adiposo | sem GSE200678 | 3 | 0 | - | 0,89 | 0 | - |  |
| adiposo | sem GSE133666 | 3 | 0 | - | 0,88 | 0 | - |  |
| adiposo | sem GSE198922 | 3 | 0 | - | 0,83 | 0 | - |  |
| adiposo | sem GSE29226 | 3 | 0 | - | 0,90 | 0 | - |  |
| adiposo | sem matrizes do autor | 3 | 0 | - | 0,83 | 0 | - |  |
| adiposo | modelo com todas as amostras (variância também de homens e outras idades) | 4 | 0 | - | 0,96 | 0 | - |  |
| adiposo | sem ajuste de lote | 4 | 0 | - | 1,00 | 0 | - |  |
| adiposo | DerSimonian-Laird (em vez de Hartung-Knapp) | 4 | 1 | - | 1,00 | 0 | - |  |
| adiposo | sem estudos com diferença de idade > 5 anos | 2 | 0 | - | 0,78 | 0 | - |  |
| adiposo | só estudos com >= 3 x 3 | 2 | 0 | - | 0,78 | 0 | - |  |
| figado | principal | 1 | 0 | - | - | 3 | 3/3 | CHOLESTEROL_HOMEOSTASIS; MTORC1_SIGNALING; P53_PATHWAY |
| figado | ajuste por medicação (estatina) | 1 | 0 | - | - | 4 | 1/3 | P53_PATHWAY; UV_RESPONSE_UP; PI3K_AKT_MTOR_SIGNALING; REACTIVE_OXYGEN_SPECIES_PATHWAY |
| figado | modelo com todas as amostras (variância também de homens e outras idades) | 1 | 0 | - | - | 4 | 3/3 | CHOLESTEROL_HOMEOSTASIS; P53_PATHWAY; MTORC1_SIGNALING; MYC_TARGETS_V2 |
| figado | ajuste por IMC (estudos com IMC) | 1 | 0 | - | - | 1 | 1/3 | CHOLESTEROL_HOMEOSTASIS |
| figado | ajuste por composição celular | 1 | 0 | - | - | 9 | 3/3 | CHOLESTEROL_HOMEOSTASIS; MTORC1_SIGNALING; P53_PATHWAY; PI3K_AKT_MTOR_SIGNALING; REACTIVE_OXYGEN_SPECIES_PATHWAY; ADIPOG |
| figado | sem ajuste de lote | 1 | 0 | - | - | 3 | 3/3 | CHOLESTEROL_HOMEOSTASIS; MTORC1_SIGNALING; P53_PATHWAY |
| figado | com estudos só de sensibilidade ( GSE15653 ) | 2 | 0 | - | - | 0 | 0/3 |  |
| figado | idade como covariável | 1 | 0 | - | - | 3 | 3/3 | CHOLESTEROL_HOMEOSTASIS; MTORC1_SIGNALING; P53_PATHWAY |
| ilhotas | principal | 4 | 0 | - | 1,00 | 0 | - |  |
| ilhotas | sem GSE41762 | 3 | 0 | - | 0,87 | 0 | - |  |
| ilhotas | sem GSE221156 | 3 | 0 | - | 0,78 | 0 | - |  |
| ilhotas | sem GSE76895 | 3 | 0 | - | 0,88 | 0 | - |  |
| ilhotas | sem GSE86469 | 3 | 0 | - | 0,92 | 0 | - |  |
| ilhotas | modelo com todas as amostras (variância também de homens e outras idades) | 4 | 0 | - | 0,89 | 0 | - |  |
| ilhotas | ajuste por IMC (estudos com IMC) | 1 | 0 | - | - | 0 | - |  |
| ilhotas | ajuste por composição celular | 1 | 0 | - | - | 1 | - | EPITHELIAL_MESENCHYMAL_TRANSITION |
| ilhotas | sem ajuste de lote | 4 | 0 | - | 0,97 | 0 | - |  |
| ilhotas | DerSimonian-Laird (em vez de Hartung-Knapp) | 4 | 7 | - | 1,00 | 0 | - |  |
| ilhotas | idade como covariável | 1 | 0 | - | - | 3 | - | TGF_BETA_SIGNALING; MYC_TARGETS_V2; TNFA_SIGNALING_VIA_NFKB |
| ilhotas | sem estudos com diferença de idade > 5 anos | 3 | 0 | - | 0,92 | 0 | - |  |
| ilhotas | só estudos com >= 3 x 3 | 1 | 0 | - | - | 1 | - | TGF_BETA_SIGNALING |
| musculo | principal | 2 | 0 | - | 1,00 | 0 | - |  |
| musculo | sem GSE18732 | 1 | 0 | - | - | 0 | - |  |
| musculo | sem GSE25462 | 1 | 0 | - | - | 0 | - |  |
| musculo | sem amostras por medicação (controle sem diabetes em metformina) | 2 | 0 | - | 0,99 | 0 | - |  |
| musculo | modelo com todas as amostras (variância também de homens e outras idades) | 2 | 0 | - | 0,93 | 0 | - |  |
| musculo | ajuste por IMC (estudos com IMC) | 2 | 0 | - | 0,89 | 0 | - |  |
| musculo | ajuste por composição celular | 2 | 0 | - | 0,88 | 0 | - |  |
| musculo | sem ajuste de lote | 2 | 0 | - | 0,93 | 0 | - |  |
| musculo | com estudos só de sensibilidade ( GSE21340 ) | 3 | 0 | - | 0,97 | 0 | - |  |
| musculo | DerSimonian-Laird (em vez de Hartung-Knapp) | 2 | 0 | - | 1,00 | 0 | - |  |
| musculo | idade como covariável | 2 | 0 | - | 0,96 | 0 | - |  |
| musculo | sem estudos com diferença de idade > 5 anos | 1 | 0 | - | - | 0 | - |  |
| sangue | principal | 3 | 0 | - | 1,00 | 0 | - |  |
| sangue | sem GSE184050 | 2 | 0 | - | 0,81 | 0 | - |  |
| sangue | sem GSE250283 | 2 | 0 | - | 0,78 | 0 | - |  |
| sangue | sem GSE249102 | 2 | 0 | - | 0,76 | 0 | - |  |
| sangue | sem matrizes do autor | 2 | 0 | - | 0,81 | 0 | - |  |
| sangue | modelo com todas as amostras (variância também de homens e outras idades) | 3 | 0 | - | 0,93 | 0 | - |  |
| sangue | ajuste por composição celular | 2 | 0 | - | 0,55 | 0 | - |  |
| sangue | sem ajuste de lote | 3 | 0 | - | 1,00 | 0 | - |  |
| sangue | com estudos só de sensibilidade ( GSE189005, GSE156993 ) | 5 | 0 | - | 0,58 | 0 | - |  |
| sangue | DerSimonian-Laird (em vez de Hartung-Knapp) | 3 | 0 | - | 1,00 | 0 | - |  |
| sangue | idade como covariável | 2 | 0 | - | 0,76 | 0 | - |  |
| sangue | só estudos com >= 3 x 3 | 2 | 0 | - | 0,76 | 0 | - |  |

## 6b. Vias de interesse (hipóteses escolhidas depois de ver os dados da etapa 05)

| Tecido | Via | Análise | Estudos | g (IC 95%) | Mesmo sentido | p | FDR |
|---|---|---|---:|---|---|---:|---:|
| sangue | INTERFERON_ALPHA_RESPONSE | principal | 3 | 0,54 (-2,31 a 3,39) | 2/3 | 0,5 | 0,99 |
| sangue | INTERFERON_GAMMA_RESPONSE | principal | 3 | 0,44 (-2,35 a 3,24) | 2/3 | 0,57 | 0,99 |
| sangue | INTERFERON_ALPHA_RESPONSE | sem GSE184050 | 2 | 0,29 (-13,87 a 14,45) | 1/2 | 0,84 | 0,97 |
| sangue | INTERFERON_GAMMA_RESPONSE | sem GSE184050 | 2 | 0,08 (-12,18 a 12,34) | 1/2 | 0,95 | 0,97 |
| sangue | INTERFERON_ALPHA_RESPONSE | sem GSE250283 | 2 | 1,10 (-3,77 a 5,97) | 2/2 | 0,21 | 0,95 |
| sangue | INTERFERON_GAMMA_RESPONSE | sem GSE250283 | 2 | 1,05 (-3,79 a 5,89) | 2/2 | 0,22 | 0,95 |
| sangue | INTERFERON_ALPHA_RESPONSE | sem GSE249102 | 2 | 0,21 (-10,67 a 11,10) | 1/2 | 0,84 |   1 |
| sangue | INTERFERON_GAMMA_RESPONSE | sem GSE249102 | 2 | 0,18 (-11,11 a 11,48) | 1/2 | 0,87 |   1 |
| sangue | INTERFERON_ALPHA_RESPONSE | sem matrizes do autor | 2 | 0,29 (-13,87 a 14,45) | 1/2 | 0,84 | 0,97 |
| sangue | INTERFERON_GAMMA_RESPONSE | sem matrizes do autor | 2 | 0,08 (-12,18 a 12,34) | 1/2 | 0,95 | 0,97 |
| sangue | INTERFERON_ALPHA_RESPONSE | modelo com todas as amostras (variância também de homens e outras idades) | 3 | 0,51 (-2,42 a 3,43) | 2/3 | 0,54 |   1 |
| sangue | INTERFERON_GAMMA_RESPONSE | modelo com todas as amostras (variância também de homens e outras idades) | 3 | 0,39 (-2,49 a 3,27) | 2/3 | 0,62 |   1 |
| sangue | INTERFERON_ALPHA_RESPONSE | ajuste por composição celular | 2 | 0,62 (-3,34 a 4,58) | 2/2 | 0,3 | 0,99 |
| sangue | INTERFERON_GAMMA_RESPONSE | ajuste por composição celular | 2 | 0,59 (-3,41 a 4,60) | 1/2 | 0,31 | 0,99 |
| sangue | INTERFERON_ALPHA_RESPONSE | sem ajuste de lote | 3 | 0,54 (-2,31 a 3,39) | 2/3 | 0,5 | 0,99 |
| sangue | INTERFERON_GAMMA_RESPONSE | sem ajuste de lote | 3 | 0,44 (-2,35 a 3,24) | 2/3 | 0,57 | 0,99 |
| sangue | INTERFERON_ALPHA_RESPONSE | com estudos só de sensibilidade ( GSE189005, GSE156993 ) | 5 | 0,36 (-0,94 a 1,67) | 3/5 | 0,48 | 0,94 |
| sangue | INTERFERON_GAMMA_RESPONSE | com estudos só de sensibilidade ( GSE189005, GSE156993 ) | 5 | 0,25 (-1,24 a 1,75) | 3/5 | 0,66 | 0,94 |
| sangue | INTERFERON_ALPHA_RESPONSE | DerSimonian-Laird (em vez de Hartung-Knapp) | 3 | 0,54 (-0,76 a 1,84) | 2/3 | 0,42 | 0,97 |
| sangue | INTERFERON_GAMMA_RESPONSE | DerSimonian-Laird (em vez de Hartung-Knapp) | 3 | 0,44 (-0,83 a 1,72) | 2/3 | 0,5 | 0,97 |
| sangue | INTERFERON_ALPHA_RESPONSE | idade como covariável | 2 | 0,23 (-10,24 a 10,70) | 1/2 | 0,83 |   1 |
| sangue | INTERFERON_GAMMA_RESPONSE | idade como covariável | 2 | 0,20 (-10,80 a 11,20) | 1/2 | 0,85 |   1 |
| sangue | INTERFERON_ALPHA_RESPONSE | só estudos com >= 3 x 3 | 2 | 0,21 (-10,67 a 11,10) | 1/2 | 0,84 |   1 |
| sangue | INTERFERON_GAMMA_RESPONSE | só estudos com >= 3 x 3 | 2 | 0,18 (-11,11 a 11,48) | 1/2 | 0,87 |   1 |
| adiposo | TNFA_SIGNALING_VIA_NFKB | principal | 4 | 1,69 (-0,21 a 3,58) | 4/4 | 0,066 | 0,9 |
| adiposo | TNFA_SIGNALING_VIA_NFKB | sem GSE200678 | 3 | 1,57 (-1,91 a 5,04) | 3/3 | 0,19 | 0,91 |
| adiposo | TNFA_SIGNALING_VIA_NFKB | sem GSE133666 | 3 | 1,84 (-1,84 a 5,52) | 3/3 | 0,16 | 0,93 |
| adiposo | TNFA_SIGNALING_VIA_NFKB | sem GSE198922 | 3 | 1,22 (-0,96 a 3,40) | 3/3 | 0,14 | 0,97 |
| adiposo | TNFA_SIGNALING_VIA_NFKB | sem GSE29226 | 3 | 2,13 (-0,15 a 4,42) | 3/3 | 0,057 | 0,72 |
| adiposo | TNFA_SIGNALING_VIA_NFKB | sem matrizes do autor | 3 | 1,22 (-0,96 a 3,40) | 3/3 | 0,14 | 0,97 |
| adiposo | TNFA_SIGNALING_VIA_NFKB | modelo com todas as amostras (variância também de homens e outras idades) | 4 | 1,34 (0,09 a 2,59) | 4/4 | 0,042 | 0,92 |
| adiposo | TNFA_SIGNALING_VIA_NFKB | sem ajuste de lote | 4 | 1,69 (-0,21 a 3,58) | 4/4 | 0,066 | 0,9 |
| adiposo | TNFA_SIGNALING_VIA_NFKB | DerSimonian-Laird (em vez de Hartung-Knapp) | 4 | 1,69 (0,53 a 2,84) | 4/4 | 0,0043 | 0,21 |
| adiposo | TNFA_SIGNALING_VIA_NFKB | sem estudos com diferença de idade > 5 anos | 2 | 2,67 (-5,72 a 11,06) | 2/2 | 0,15 | 0,89 |
| adiposo | TNFA_SIGNALING_VIA_NFKB | só estudos com >= 3 x 3 | 2 | 2,19 (-9,28 a 13,67) | 2/2 | 0,25 | 0,82 |
| ilhotas | EPITHELIAL_MESENCHYMAL_TRANSITION | principal | 4 | 1,75 (-0,51 a 4,01) | 4/4 | 0,091 | 0,75 |
| ilhotas | EPITHELIAL_MESENCHYMAL_TRANSITION | sem GSE41762 | 3 | 1,99 (-2,44 a 6,43) | 3/3 | 0,19 | 0,86 |
| ilhotas | EPITHELIAL_MESENCHYMAL_TRANSITION | sem GSE221156 | 3 | 2,18 (-1,44 a 5,80) | 3/3 | 0,12 | 0,75 |
| ilhotas | EPITHELIAL_MESENCHYMAL_TRANSITION | sem GSE76895 | 3 | 1,17 (-0,58 a 2,93) | 3/3 | 0,1 | 0,86 |
| ilhotas | EPITHELIAL_MESENCHYMAL_TRANSITION | sem GSE86469 | 3 | 1,85 (-2,46 a 6,17) | 3/3 | 0,21 | 0,71 |
| ilhotas | EPITHELIAL_MESENCHYMAL_TRANSITION | modelo com todas as amostras (variância também de homens e outras idades) | 4 | 1,26 (0,17 a 2,35) | 4/4 | 0,035 | 0,61 |
| ilhotas | EPITHELIAL_MESENCHYMAL_TRANSITION | ajuste por IMC (estudos com IMC) | 1 | 1,79 (0,38 a 3,20) | 1/1 | 0,017 | 0,21 |
| ilhotas | EPITHELIAL_MESENCHYMAL_TRANSITION | ajuste por composição celular | 1 | 2,36 (0,94 a 3,78) | 1/1 | 0,00096 | 0,048 |
| ilhotas | EPITHELIAL_MESENCHYMAL_TRANSITION | sem ajuste de lote | 4 | 1,59 (-0,83 a 4,02) | 4/4 | 0,13 | 0,85 |
| ilhotas | EPITHELIAL_MESENCHYMAL_TRANSITION | DerSimonian-Laird (em vez de Hartung-Knapp) | 4 | 1,75 (0,48 a 3,03) | 4/4 | 0,0071 | 0,12 |
| ilhotas | EPITHELIAL_MESENCHYMAL_TRANSITION | idade como covariável | 1 | 1,24 (0,31 a 2,17) | 1/1 | 0,012 | 0,1 |
| ilhotas | EPITHELIAL_MESENCHYMAL_TRANSITION | sem estudos com diferença de idade > 5 anos | 3 | 1,85 (-2,46 a 6,17) | 3/3 | 0,21 | 0,71 |
| ilhotas | EPITHELIAL_MESENCHYMAL_TRANSITION | só estudos com >= 3 x 3 | 1 | 1,33 (0,26 a 2,40) | 1/1 | 0,018 | 0,11 |
| musculo | OXIDATIVE_PHOSPHORYLATION | principal | 2 | -1,12 (-6,52 a 4,28) | 2/2 | 0,23 | 0,98 |
| musculo | OXIDATIVE_PHOSPHORYLATION | sem GSE18732 | 1 | -1,04 (-2,36 a 0,27) | 1/1 | 0,13 | 0,6 |
| musculo | OXIDATIVE_PHOSPHORYLATION | sem GSE25462 | 1 | -1,18 (-2,26 a -0,10) | 1/1 | 0,038 | 0,86 |
| musculo | OXIDATIVE_PHOSPHORYLATION | sem amostras por medicação (controle sem diabetes em metformina) | 2 | -1,08 (-6,75 a 4,59) | 2/2 | 0,25 | 0,97 |
| musculo | OXIDATIVE_PHOSPHORYLATION | modelo com todas as amostras (variância também de homens e outras idades) | 2 | -0,76 (-4,89 a 3,37) | 2/2 | 0,26 |   1 |
| musculo | OXIDATIVE_PHOSPHORYLATION | ajuste por IMC (estudos com IMC) | 2 | -1,09 (-7,21 a 5,03) | 2/2 | 0,26 | 0,99 |
| musculo | OXIDATIVE_PHOSPHORYLATION | ajuste por composição celular | 2 | -1,14 (-7,75 a 5,47) | 2/2 | 0,27 | 0,95 |
| musculo | OXIDATIVE_PHOSPHORYLATION | sem ajuste de lote | 2 | -0,68 (-5,22 a 3,85) | 2/2 | 0,31 | 0,97 |
| musculo | OXIDATIVE_PHOSPHORYLATION | com estudos só de sensibilidade ( GSE21340 ) | 3 | -0,78 (-2,41 a 0,84) | 2/3 | 0,17 | 0,99 |
| musculo | OXIDATIVE_PHOSPHORYLATION | DerSimonian-Laird (em vez de Hartung-Knapp) | 2 | -1,12 (-1,96 a -0,29) | 2/2 | 0,0082 | 0,41 |
| musculo | OXIDATIVE_PHOSPHORYLATION | idade como covariável | 2 | -0,72 (-6,29 a 4,84) | 2/2 | 0,35 | 0,99 |
| musculo | OXIDATIVE_PHOSPHORYLATION | sem estudos com diferença de idade > 5 anos | 1 | -1,18 (-2,26 a -0,10) | 1/1 | 0,038 | 0,86 |

## 6c. Possível sobreposição de doadoras entre estudos (mesmo tecido, status, idade e IMC)

Nenhuma.

Só doadoras com idade e IMC conhecidos entram (revisão de 08/10/2026). Perfil idêntico não prova que é a mesma pessoa; é pista para conferir na fonte.

## 7. NanoString (GSE316126) x meta-análise do sangue

748 genes do painel; 728 em comum com o sangue; correlação dos g = -0,01; mesmo sentido em 47%; 0 genes com FDR < 0,05 no próprio painel.

## 9. O que validar

1. Os resultados por tecido (seções 2, 4 e 5), lidos junto com o poder (seção 3).
2. A robustez nas sensibilidades (seção 6): resultado que some ao tirar um estudo ou ao ajustar por IMC/composição deve ser tratado com cautela.
3. Os resultados de descoberta (um estudo) são pistas, não confirmações. Em tecido com 2+ estudos, 'descoberta' é um gene medido em só 1 estudo (ex.: UQCRHL nas ilhotas, só no GSE221156): não é replicação.

## 10. Genes de resposta imediata (marcados para discussão)

Genes que sobem em minutos com isquemia ou manuseio do tecido antes do congelamento (lista em config/meta.yaml). Ficam na análise; a marca serve para a discussão: se eles dominam os achados de um tecido, o sinal pode ser de coleta, não de DM2 (decisão do usuário, 08/10/2026).

| Tecido | Medidos | p < 0,05 | Maiores no DM2 | Fração p < 0,05 (resposta imediata) | Fração p < 0,05 (demais genes) |
|---|---:|---:|---:|---:|---:|
| adiposo | 46 | 6 | 40 | 0.130 | 0.003 |
| figado | 42 | 3 | 33 | 0.071 | 0.139 |
| ilhotas | 46 | 1 | 38 | 0.022 | 0.007 |
| musculo | 45 | 0 | 17 | 0.000 | 0.000 |
| sangue | 44 | 0 | 20 | 0.000 | 0.005 |

| Tecido | Gene | Estudos | g | p | Mesmo sentido |
|---|---|---:|---:|---:|---|
| adiposo | BTG2 | 4 | 1.65 | 0,031 | 4/4 |
| adiposo | KLF9 | 4 | 1.60 | 0,034 | 4/4 |
| adiposo | PPP1R15A | 4 | 1.51 | 0,035 | 4/4 |
| adiposo | EGR1 | 4 | 1.77 | 0,037 | 4/4 |
| adiposo | CCN2 | 3 | 2.49 | 0,042 | 3/3 |
| adiposo | CEBPD | 4 | 1.45 | 0,049 | 4/4 |
| figado | JUND | 1 | 0.46 | 0,0033 | 1/1 |
| figado | IER3 | 1 | 0.39 | 0,012 | 1/1 |
| figado | JUNB | 1 | 0.31 | 0,049 | 1/1 |
| ilhotas | NR4A3 | 4 | 1.15 | 0,042 | 4/4 |
