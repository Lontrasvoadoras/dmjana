# Validação da etapa 02: metadados por amostra e elegibilidade

Gerado em 12/10/2026 12:12 a partir de `output/02_metadados/`. **Aprovar antes de seguir para a etapa 03.**

## 1. Leitura

- Séries lidas: **506** (incluídas e para revisão na etapa 01; 2 com mais de 5.000 amostras ficaram de fora).
- Sem amostras legíveis: 0.
- Amostras: **40.803**. Testes das regras: 61 de 61 corretos (`input/testes_regras.csv`).

## 2. Harmonização (todas as amostras humanas lidas)

| Campo | Reconhecido | Detalhe |
|---|---:|---|
| Sexo | 59% | F 9.604, M 14.076 |
| Idade | 32% | exata 12.929, ponto médio de faixa 2, faixa larga (sem idade) 20 |
| Status | 66% | AMBIGUO 104, EXCLUIR 848, INTERMEDIARIO 724, ND 13.857, T2D 10.869 |
| Tecido | 94% | adiposo 3.981, endometrio_ovario 8, figado 1.780, ilhotas 22.863, mama 19, musculo 2.735, osso 64, sangue 5.710, vasos 459 |
| Cultivadas (saem) | 3.542 | |
| Sob intervenção (saem) | 6.356 | |
| Aptas (ND/DM2, tecido de interesse, não cultivada, basal) | 21.702 | |
| Aptas e mulheres de 40–60 | 1.747 | DM2 1.060, ND 687 |

## 3. Estudos por categoria (estudo × tecido)

Regra: **elegível** se tem pelo menos 2 doadoras DM2 e 2 doadoras ND de 40–60 anos (doadoras únicas, não amostras). Os demais recebem o primeiro motivo que se aplica, nesta ordem.

| Categoria | Estudo × tecido |
|---|---:|
| elegivel | 20 |
| excluído por decisão do usuário | 6 |
| poucas mulheres de 40-60 com DM2 e controles | 30 |
| sem amostra apta em tecido de interesse | 9 |
| sem idade | 32 |
| sem sexo | 126 |
| sem sexo: candidato ao sexo genético | 5 |
| sem status ND/DM2 | 272 |
| SuperSeries: amostras já nas subséries | 7 |

## 4. Elegíveis

| GSE | Tecido | Doadoras DM2 40–60 | Doadoras ND 40–60 | Todas F (DM2/ND) | Todos M (DM2/ND) | Triagem 01 | Título |
|---|---|---:|---:|---|---|---|---|
| GSE200678 | adiposo | 5 | 2 | 11/12 | 3/9 | incluido | Hepatic senescence is associated with clinical progression of NAFLD/NASH: Role o |
| GSE133666 | adiposo | 4 | 4 | 9/9 | 0/0 | incluido | Gene expression data from human omental adipose tissue |
| GSE198922 | adiposo | 4 | 4 | 12/9 | 16/11 | incluido | Exercise-induced Crosstalk between Immune Cells and Adipocytes in Humans: Role o |
| GSE29226 | adiposo | 2 | 2 | 3/3 | 0/0 | incluido | Global Gene Expression Profiles of Subcutaneous Adipose in Females with Type 2 D |
| GSE130991 | figado | 150 | 59 | 212/197 | 127/42 | incluido | Liver transcriptome of statin-treated patients |
| GSE15653 | figado | 3 | 4 | 6/8 | 3/1 | incluido | Expression data from liver of obese (with or without type 2 diabetes) and lean h |
| GSE41762 | ilhotas | 6 | 14 | 9/24 | 11/33 | incluido | Expression data from human pancreatic islets |
| GSE221156 | ilhotas | 2 | 4 | 6/5 | 8/12 | revisar | Dissecting cell-type specific pathophysiological changes in human type-2 diabeti |
| GSE76895 | ilhotas | 2 | 6 | 13/16 | 23/16 | incluido | Affymetrix profiling of IMIDIA biobank samples from organ donors and partially p |
| GSE86469 | ilhotas | 2 | 2 | 2/2 | 1/3 | revisar | Single cell transcriptomics defines human islet cell signatures and reveals cell |
| GSE18732 | musculo | 10 | 13 | 12/18 | 33/29 | incluido | mRNA expression data from skeletal muscle of type 2 diabetes |
| GSE21340 | musculo | 3 | 5 | 4/7 | 1/3 | incluido | Human skeletal muscle - type 2 diabetes and family history positive individuals  |
| GSE25462 | musculo | 3 | 10 | 6/22 | 4/18 | incluido | Increased SRF Transcriptional Activity is a Novel Signature of Insulin Resistanc |
| GSE184050 | sangue | 9 | 20 | 20/28 | 5/5 | incluido | Novel diabetes gene discovery through comprehensive characterization and integra |
| GSE156993 | sangue | 6 | 4 | 7/4 | 5/2 | incluido | Transcriptomic analysis of peripheral blood mononuclear cells (PBMC) of patients |
| GSE250283 | sangue | 6 | 8 | 15/15 | 8/8 | incluido | Transcriptional profiles associated with coronary artery disease in Type 2 diabe |
| GSE189005 | sangue | 5 | 6 | 12/6 | 24/3 | incluido | RNA expression profiles of whole blood cells from a Han Chinese population with  |
| GSE23561 | sangue | 4 | 5 | 5/7 | 3/2 | incluido | Peripheral blood gene expression profiles in metabolic syndrome, coronary artery |
| GSE316126 | sangue | 3 | 6 | 5/8 | 7/4 | incluido | Distinct immunometabolic signatures in peripheral blood mononuclear cells are li |
| GSE249102 | sangue | 2 | 2 | 2/2 | 2/2 | incluido | Whole RNA profiling of Tuberculosis-diabetes comorbidity linked to diabetes with |

Elegíveis que repartem amostras (mesmas GSM) ou doadores (mesmo identificador) com outra série: decidir qual fica.

| GSE | Tecido | Amostras em comum com | Doadores em comum com |
|---|---|---|---|
| GSE86469 | ilhotas |  | GSE86468 (8) |
| GSE189005 | sangue | GSE189007 (45) |  |

Excluídos por decisão do usuário (`input/exclusoes.csv`):

- GSE38642 (ilhotas): Repete doadores de Lund do GSE41762; usuário manteve GSE41762
- GSE86468 (ilhotas): Mesmos 8 doadores (UNOS id) do GSE86469; usuário manteve GSE86469 (célula única, HPAP)
- GSE50244 (ilhotas): 67 dos 89 doadores são os mesmos do GSE41762 (Lund), confirmados pela expressão: o array GSE50397 dos mesmos doadores tem perfil centrado quase idêntico ao do GSE41762 (r 0,84-0,97; 2º melhor ~0,45) e sexo, IMC e HbA1c iguais (reavaliação de 12/10/2026; antes estimados em 79 só por sexo, idade +-1 e IMC, critério com coincidências ao acaso). Os 22 doadores novos têm só 3 mulheres de 40-60 (1 sem diabetes e 2 com HbA1c intermediária; nenhuma com DM2): estudo segue fora. Fica o GSE41762 (usuário 09/10/2026)
- GSE189007 (sangue): Os 45 CEL Clariom D (mRNA) são os mesmos arquivos do GSE189005 (mesmo nome e tamanho); as outras 85 amostras são arrays de miRNA e de promotores das mesmas pessoas. Mantido o GSE189005 (decisão D5 da etapa 04, aprovada pelo usuário; a contagem 14/12 que a motivou vinha de amostras de miRNA e promotores)
- GSE158055 (sangue): DM2 vem de comorbidities: diabetes em pacientes com COVID-19 e os controles são pessoas sem COVID; contraste confundido com a COVID; excluído pelo usuário
- GSE50397 (NA): Mesmos 89 doadores do GSE50244 (array); fica o GSE50244 (RNA-seq) (usuário 09/10/2026)

SuperSeries fora da contagem (amostras já nas subséries): GSE12895 (GSE12793;GSE12894); GSE76896 (GSE76894;GSE76895); GSE86473 (GSE86468;GSE86469); GSE156249 (GSE156247;GSE156248); GSE182121 (GSE182117;GSE182120); GSE161721 (GSE161719;GSE161720); GSE204706 (GSE202856;GSE204705).

### Por tecido

| Tecido | Estudos | Doadoras DM2 40–60 | Doadoras ND 40–60 |
|---|---:|---:|---:|
| adiposo | 4 | 15 | 12 |
| figado | 2 | 153 | 63 |
| ilhotas | 4 | 12 | 26 |
| musculo | 3 | 16 | 28 |
| sangue | 7 | 35 | 51 |

### Mudanças da auditoria de 06/10/2026

Antes da auditoria: 18 estudo × tecido elegíveis; agora: 20.

| Novo elegível | Tecido | DM2 40–60 | ND 40–60 | Triagem 01 | Motivo da revisão na etapa 01 | Título |
|---|---|---:|---:|---|---|---|
| GSE130991 | figado | 150 | 59 | incluido |  | Liver transcriptome of statin-treated patients |
| GSE250283 | sangue | 6 | 8 | incluido |  | Transcriptional profiles associated with coronary artery disease in Ty |
| GSE249102 | sangue | 2 | 2 | incluido |  | Whole RNA profiling of Tuberculosis-diabetes comorbidity linked to dia |

| Deixou de ser elegível | Tecido | Categoria agora |
|---|---|---|
| GSE171153 | ilhotas | poucas mulheres de 40-60 com DM2 e controles |

## 5. Quase elegíveis (candidatos a curadoria)

Estudos com mulheres e DM2/ND mas sem idade, ou com mulheres de 40–60 em só um grupo, ou com idade e status mas sem sexo (candidatos ao sexo genético na etapa de expressão).

| GSE | Tecido | Categoria | F 40–60 DM2/ND | F todas DM2/ND | Sem sexo 40–60 DM2/ND | Fração com idade | Título |
|---|---|---|---|---|---|---:|---|
| GSE108971 | adiposo | sem idade | 0/0 | 6/2 | 0/0 | 0.00 | Novel Atherogenic Pathways from the Differential Transcriptiome Analys |
| GSE128665 | adiposo | sem sexo: candidato ao sexo genético | 0/0 | 0/0 | 2/11 | 1.00 | Elevated Extra-cellular Matrix Signaling in Adipose Mesothelial Cells  |
| GSE141432 | adiposo | sem idade | 0/0 | 4/4 | 0/0 | 0.00 | Obese Insulin Resistant Humans with Compensatory Hyperinsulinemia Diss |
| GSE243957 | adiposo | sem idade | 0/0 | 8/7 | 0/0 | 0.00 | Single-cell Analysis of Subcutaneous Fat Reveals Pro-fibrotic Cells th |
| GSE263644 | adiposo | sem idade | 0/0 | 4/6 | 0/0 | 0.00 | Cholesin Receptor Signalling is Active in Cardiovascular System-Associ |
| GSE29231 | adiposo | poucas mulheres de 40-60 com DM2 e controles | 0/8 | 12/12 | 0/0 | 1.00 | Global Gene Expression Profiles of  Visceral Adipose in Females with T |
| GSE71416 | adiposo | sem idade | 0/0 | 10/5 | 0/0 | 0.00 | Gene Expression Profiling in Omental Adipose Tissue of Morbidly Obese  |
| GSE95674 | adiposo | poucas mulheres de 40-60 com DM2 e controles | 0/65 | 0/120 | 0/0 | 1.00 | Tissue-Specific and Genetic Regulation of Insulin Sensitivity-Associat |
| GSE23343 | figado | sem idade | 0/0 | 4/3 | 0/0 | 0.00 | Expression data from human liver with or without type 2 diabetes |
| GSE268273 | figado | sem idade | 0/0 | 20/32 | 0/0 | 0.00 | Clinical and molecular characterization of steatotic liver disease in  |
| GSE38642 | ilhotas | excluído por decisão do usuário | 3/14 | 4/23 | 0/0 | 1.00 | Expression data from human pancreatic islets |
| GSE76896 | ilhotas | SuperSeries: amostras já nas subséries | 3/21 | 19/62 | 0/0 | 1.00 | Affymetrix profiling of IMIDIA biobank samples from organ donors and p |
| GSE81608 | ilhotas | poucas mulheres de 40-60 com DM2 e controles | 2/1 | 3/5 | 0/0 | 1.00 | RNA Sequencing of Single Human Islet Cells Reveals Type 2 Diabetes Gen |
| GSE86468 | ilhotas | excluído por decisão do usuário | 2/2 | 2/2 | 0/0 | 1.00 | Single cell transcriptomics defines human islet cell signatures and re |
| GSE86473 | ilhotas | SuperSeries: amostras já nas subséries | 2/2 | 2/2 | 0/0 | 1.00 | Single cell transcriptomics defines human islet cell signatures and re |
| GSE171153 | ilhotas | poucas mulheres de 40-60 com DM2 e controles | 1/1 | 6/1 | 0/0 | 1.00 | Integration of human genetics with single cell accessible chromatin pr |
| GSE200044 | ilhotas | poucas mulheres de 40-60 com DM2 e controles | 1/1 | 6/1 | 0/0 | 1.00 | Single-cell multiome (ATAC and RNA) landscapes of human islets in norm |
| GSE76894 | ilhotas | poucas mulheres de 40-60 com DM2 e controles | 1/15 | 6/46 | 0/0 | 1.00 | Affymetrix profiling of IMIDIA biobank samples from organ donors and p |
| GSE120299 | ilhotas | poucas mulheres de 40-60 com DM2 e controles | 0/2 | 0/6 | 0/0 | 1.00 | Human Pancreatic Islets Expressing HNF1A Variant Have Defective β cell |
| GSE124742 | ilhotas | sem idade | 0/0 | 1721/1061 | 0/0 | 0.00 | Pancreas single cell patch-seq links physiologic dysfunction in diabet |
| GSE164875 | ilhotas | sem idade | 0/0 | 146/173 | 0/0 | 0.00 | Extended data for pancreas single-cell patch-seq dataset in nondiabeti |
| GSE231509 | musculo | poucas mulheres de 40-60 com DM2 e controles | 1/3 | 3/3 | 0/0 | 1.00 | Dysregulation of mixed meal-induced gene expression in skeletal muscle |
| GSE182120 | musculo | sem sexo: candidato ao sexo genético | 0/0 | 0/0 | 8/12 | 1.00 | Disrupted Circadian Oscillations in Type 2 Diabetes are Linked to Alte |
| GSE182121 | musculo | SuperSeries: amostras já nas subséries | 0/0 | 0/0 | 8/12 | 0.21 | Disrupted Circadian Oscillations in Type 2 Diabetes are Linked to Alte |
| GSE19420 | musculo | sem sexo: candidato ao sexo genético | 0/0 | 0/0 | 9/8 | 1.00 | Skeletal muscle mitochondrial dysfunction is secondary to T2DM |
| GSE272133 | musculo | sem idade | 0/0 | 8/13 | 0/0 | 0.00 | Different effects of bariatric surgery on epigenetic plasticity in ske |
| GSE59363 | musculo | sem sexo: candidato ao sexo genético | 0/0 | 0/0 | 12/15 | 1.00 | Effect of type 2 diabetes on transcriptional signatures during exercis |
| GSE63887 | musculo | poucas mulheres de 40-60 com DM2 e controles | 0/2 | 0/3 | 0/0 | 1.00 | RNA-sequencing of healthy human skeletal myocytes |
| GSE95675 | musculo | poucas mulheres de 40-60 com DM2 e controles | 0/61 | 0/115 | 0/0 | 0.98 | Tissue-Specific and Genetic Regulation of Insulin Sensitivity-Associat |
| GSE182923 | osso | sem idade | 0/0 | 4/7 | 0/0 | 0.00 | Altered Human Alveolar Bone Gene Expression in Type 2 Diabetes |
| GSE153315 | sangue | poucas mulheres de 40-60 com DM2 e controles | 9/1 | 13/4 | 0/0 | 1.00 | Transcriptome analysis of Newly Diagnosed Type 2 Diabetes Subjects ide |
| GSE189007 | sangue | excluído por decisão do usuário | 5/6 | 12/6 | 0/0 | 1.00 | Gene-expression profiles of whole blood cells from a Han Chinese popul |
| GSE13015 | sangue | sem status ND/DM2 | 4/1 | 5/2 | 0/0 | 1.00 | Genomic Transcriptional Profiling Identifies a Blood Biomarker Signatu |
| GSE158055 | sangue | excluído por decisão do usuário | 2/2 | 6/5 | 0/0 | 1.00 | Large-scale single-cell analysis reveals critical immune characteristi |
| GSE193626 | sangue | poucas mulheres de 40-60 com DM2 e controles | 2/0 | 3/0 | 0/0 | 1.00 | Exploring the mechanism of Jiangtang Tiaozhi Recipe in the treatment o |
| GSE185011 | sangue | sem status ND/DM2 | 0/0 | 0/0 | 3/0 | 1.00 | The expression of mRNA and lncRNA in peripheral blood mononuclear cell |
| GSE216680 | sangue | poucas mulheres de 40-60 com DM2 e controles | 0/34 | 0/71 | 0/0 | 1.00 | Reduced CD8 T cell exhaustion in DR4 risk subjects is selectively augm |
| GSE270270 | sangue | sem idade | 0/0 | 4/4 | 0/0 | 0.00 | B Cell Mechanisms Underlie IgG Glycan Alterations in Obesity |
| GSE273902 | sangue | sem idade | 0/0 | 8/8 | 0/0 | 0.00 | Rapid and long-lasting remodelling of the blood transcriptome followin |
| GSE280401 | sangue | sem idade | 0/0 | 2/2 | 0/0 | 0.00 | Deciphering the Transcriptomic Landscape of Type 2 Diabetes: Insights  |
| GSE280402 | sangue | sem idade | 0/0 | 4/4 | 0/0 | 0.00 | Deciphering the Transcriptomic Landscape of Type 2 Diabetes: Insights  |
| GSE43950 | sangue | sem sexo: candidato ao sexo genético | 0/0 | 0/0 | 6/2 | 0.93 | Gene expression profiling in endothelial precursor cells of patients p |
| GSE92724 | sangue | sem idade | 0/0 | 2/6 | 0/0 | 0.00 | Dermal endothelial cells of type 2 diabetic patients |
| GSE98583 | sangue | sem status ND/DM2 | 0/0 | 0/0 | 0/6 | 1.00 | Global gene expression studies for coronary artery disease and its sev |
| GSE220796 | vasos | poucas mulheres de 40-60 com DM2 e controles | 1/2 | 6/3 | 0/0 | 1.00 | Whole genome transcriptomics of pre-access veins and hemodialysis arte |

## 6. Chaves não usadas mais frequentes (podem esconder sexo, idade ou status)

| Chave | Estudos | Amostras | Exemplos de valor |
|---|---:|---:|---|
| cell line | 75 | 1617 | HepG2 cells / SGBS / HCT116 |
| bmi | 41 | 4116 | 25.24 / 31.25 / 20.7 |
| genotype | 37 | 1090 | PDX1C18R/C18R / PDX1-/+ / PDX1P33T/P33T |
| hba1c | 19 | 1250 | 5.7 / 5.2 / 5.9 |
| batch | 18 | 1312 | 1 / 2 / 3 |
| ethnicity | 11 | 2228 | C / H / AA |
|  | 10 | 189 | Only sedentary male subjects were recruited. Patients with type 2 diabetes were  |
| race | 10 | 1896 | Asian / Caucasian / Others |
| bmi (kg/m2) | 9 | 399 | 31 / 29 / 35 |
| chip antibody | 9 | 359 | Rabbit anti-H3K27ac / N/A / Rabbit anti-H3K4me1 |
| strain | 9 | 232 | THP-1 / culture:alone / culture:co |
| genotype/variation | 8 | 63 | WT Control / BCL11A knockdown / wild type |
| sample type | 8 | 756 | Fresh whole tissue / Packed D0 cells / Explant 1 week |
| diet | 7 | 263 | pre-diet / post-diet / HF_HC |
| sample id | 7 | 434 | H13 / H16_2 / H03 |
| replicate | 6 | 138 | Replicate 1 / Replicate 2 / Replicate 3 |
| weight | 6 | 353 | 113.3 / 118.5 / 118 |
| passage | 5 | 87 | Fresh Frozen / P5 / P6 |
| assay | 4 | 36 | Hi-C / iMARGI / scRNA-seq |
| library id | 4 | 149 | SLX-21197 / SLX-22979 / SLX-21198 |
| library type | 4 | 39 | Gene Expression (multiplexed) / Hashtag (multiplexed) / mRNA |
| passages | 4 | 62 | P4-7 / 5-9 / p4-p8 |
| sirna | 4 | 33 | Mock / Scramble / siRNA11 |
| tag | 4 | 262 | 2.18 / 1.67 / 1.87 |
| weight (kg) | 4 | 255 | 52.4 / 82.7 / 64.1 |
| body mass index (bmi) | 3 | 412 | 24.49 / 29.38 / 19.39 |
| celltype | 3 | 2545 | pancreatic islets / dropped / alpha |
| developmental stage | 3 | 131 | Definitive endoderm / Embryonic stem cell / Gut tube |
| fasting glucose (mmol/l) | 3 | 253 | 5.1782 / 5.16445 / 4.94415 |
| hdl | 3 | 179 | na / 49.0 / 40.0 |

Lista completa em `output/02_metadados/chaves.csv`.

## 7. O que validar

1. Mínimo por grupo = 2 doadoras DM2 e ND de 40–60 por estudo × tecido: **validado em 06/10/2026**.
2. Os elegíveis da seção 4 fazem sentido (tecido e números de doadoras)?
3. Os quase elegíveis da seção 5 merecem curadoria (idade em artigo ou tabela suplementar, linhas em `input/curadoria.csv`)?
4. Alguma chave da seção 6 deveria ser usada?
5. Estudos que vieram da revisão manual da etapa 01 (coluna Triagem 01 = revisar) e ficaram elegíveis: manter?

### Pontos que encontrei e recomendação

- **GSE249102** (sangue, novo depois da auditoria): estudo de tuberculose e diabetes; contam só os grupos DM2 sem TB e controles (TB e TB+DM2 ficam sem status). Mesma lógica do GSE158055, mas aqui o contraste não é confundido com a infecção.
- **GSE200044** (ilhotas, novo depois da auditoria): multiome ATAC + RNA; como o GSE171153, entra se a etapa de dados confirmar expressão por doador.
- **GSE171153** (ilhotas): série mista (cromatina por célula única + expressão); só a parte de expressão serve. Verificar na etapa de dados se há matriz de expressão por doador; se não houver, sai.
- Decidido em 06/10/2026: GSE158055 excluído (DM2 confundido com COVID-19); FH+ do GSE25462 ficam ND (descrição das amostras no GEO: "subject without diabetes").
- Decidido em 06/10/2026: mantidos GSE86469 (HPAP, célula única; sai GSE86468, mesmos doadores) e GSE41762 (Lund; sai GSE38642, doadores repetidos).
- **GSE23561 e GSE316126** (sangue): excluídos no workflow anterior por problemas nos dados (sexo genético não separou as amostras no GSE23561). Aqui seguem elegíveis pelos metadados; o controle de qualidade da expressão decide na etapa seguinte.
- **Curadoria aplicada** (`input/curadoria.csv`): sexo 0/1 do GSE18732; status pelo título em GSE18732, GSE25462 e GSE15653; GSE81965 marcado como cultivado (miócitos em cultura).
