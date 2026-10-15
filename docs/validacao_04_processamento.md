# Validação da etapa 04: obtenção e processamento dos dados de expressão

Gerado em 12/10/2026 12:17 a partir de `output/04_processamento/`. **Aprovar antes de seguir para a etapa 05.**

## 1. Resultado por estudo

| GSE | Tecido | Tipo | Fonte | Genes | Amostras | Mantidas | Sexo discordante | Discrepantes | Outras retiradas | Sexo genético | F 40–60 DM2/ND | Categoria |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---|---|---|
| GSE200678 | adiposo | contagens | GSE200678_Kallisto_visceral_AT_tissue_count.t | 13060 | 35 | 31 | 2 (6%) | 1 | 1 | resgatado (dois sexos, só genes Y) | 4/2 | pronto para a etapa 05 |
| GSE133666 | adiposo | cel | CEL de 18 amostras (GEO, por GSM) | 26021 | 18 | 17 | 0 (0%) | 1 | 0 | resgatado (um só sexo: F) | 4/3 | pronto para a etapa 05 |
| GSE198922 | adiposo | contagens_norm | GSE198922_processed.data.csv.gz | 18422 | 48 | 46 | 0 (0%) | 2 | 0 | resgatado (dois sexos) | 4/4 | pronto para a etapa 05 |
| GSE29226 | adiposo | illumina_bruto | GSE29226_non-normalized.txt.gz | 37804 | 24 | 24 | 0 (0%) | 0 | 0 | resgatado (um só sexo: F) | 2/2 | pronto para a etapa 05 |
| GSE130991 | figado | series_matrix | series matrix do GEO (matriz do autor) | 22615 | 578 | 564 | 11 (2%) | 3 | 0 | resgatado (dois sexos) | 146/58 | pronto para a etapa 05 |
| GSE15653 | figado | cel | CEL de 18 amostras (GEO, por GSM) | 12650 | 18 | 18 | 0 (0%) | 0 | 0 | resgatado (dois sexos) | 3/4 | pronto para a etapa 05 |
| GSE41762 | ilhotas | cel | CEL de 77 amostras (GEO, por GSM) | 18866 | 77 | 75 | 1 (1%) | 1 | 0 | resgatado (dois sexos, só genes Y) | 6/12 | pronto para a etapa 05 |
| GSE221156 | ilhotas | pseudobulk_h5ad | GSE221156_integrado_464a2c70.h5ad | 18990 | 34 | 34 | 0 (0%) | 0 | 0 | resgatado (dois sexos) | 2/4 | pronto para a etapa 05 |
| GSE76895 | ilhotas | cel | CEL de 68 amostras (GEO, por GSM) | 20826 | 68 | 66 | 1 (2%) | 1 | 0 | resgatado (dois sexos) | 2/6 | pronto para a etapa 05 |
| GSE86469 | ilhotas | pseudobulk_csv | GSE86469_GEO.islet.single.cell.processed.data | 15726 | 8 | 8 | 0 (0%) | 0 | 0 | resgatado (dois sexos) | 2/2 | pronto para a etapa 05 |
| GSE18732 | musculo | cel | CEL de 92 amostras (GEO, por GSM) | 20826 | 92 | 91 | 0 (0%) | 1 | 0 | resgatado (dois sexos) | 10/12 | pronto para a etapa 05 |
| GSE21340 | musculo | cel | CEL de 15 amostras (GEO, por GSM) | 5369 | 15 | 15 | 0 (-) | 0 | 0 | não avaliável | 3/5 | só sensibilidade (lote confundido com o grupo) |
| GSE25462 | musculo | cel | CEL de 50 amostras (GEO, por GSM) | 20826 | 50 | 48 | 1 (2%) | 1 | 0 | resgatado (dois sexos) | 3/8 | pronto para a etapa 05 |
| GSE184050 | sangue | contagens_norm | GSE184050_CCHC_T2D_DEseq2_normalized_count.tx | 24737 | 58 | 56 | 0 (0%) | 2 | 0 | resgatado (dois sexos) | 9/19 | pronto para a etapa 05 |
| GSE156993 | sangue | cel | CEL de 18 amostras (GEO, por GSM) | 20826 | 18 | 16 | 1 (6%) | 1 | 0 | resgatado (dois sexos) | 5/4 | pronto para a etapa 05 |
| GSE250283 | sangue | illumina_bruto | GSE250283_non_normalized.txt.gz | 33051 | 36 | 35 | 0 (0%) | 1 | 0 | resgatado (dois sexos) | 4/8 | pronto para a etapa 05 |
| GSE189005 | sangue | cel | CEL de 45 amostras (GEO, por GSM) | 24126 | 45 | 44 | 0 (0%) | 1 | 0 | resgatado (dois sexos) | 5/5 | só sensibilidade (lote confundido com o grupo) |
| GSE23561 | sangue | series_matrix | series matrix do GEO (matriz do autor) | 24284 | 17 | 16 | 0 (-) | 1 | 0 | não avaliável | 4/4 | pronto para a etapa 05 |
| GSE316126 | sangue | nanostring | RCC de 24 amostras (GEO, por GSM) | 748 | 24 | 23 | 0 (-) | 1 | 0 | não avaliável | 3/5 | análise dirigida (painel) |
| GSE249102 | sangue | agilent_bruto | arquivos Agilent de 8 amostras (GEO, por GSM) | 22682 | 8 | 8 | 0 (0%) | 0 | 0 | resgatado (dois sexos) | 2/2 | pronto para a etapa 05 |

## 2. Por tecido (prontos para a etapa 05)

| Tecido | Estudos | Doadoras DM2 40–60 | Doadoras ND 40–60 |
|---|---:|---:|---:|
| adiposo | 4 | 14 | 11 |
| figado | 2 | 149 | 62 |
| ilhotas | 4 | 12 | 24 |
| musculo | 2 | 13 | 20 |
| sangue | 5 | 24 | 37 |

## 3. Amostras retiradas

| GSE | Amostra | Sexo declarado | Sexo genético | Status | Idade | Motivo |
|---|---|---|---|---|---|---|
| GSE200678 | vis_17 | F | F | T2D | 53 | biblioteca pequena |
| GSE200678 | vis_23 | M | F | T2D | 72 | sexo genético discordante do declarado |
| GSE200678 | vis_137 | F | M | ND | 78 | sexo genético discordante do declarado |
| GSE200678 | vis_186 | F | F | ND | 73 | amostra discrepante (conectividade) |
| GSE133666 | GSM3914315 | F | F | ND | 48 | amostra discrepante (conectividade) |
| GSE198922 | 26_PRE | M | M | T2D | 53 | amostra discrepante (conectividade) |
| GSE198922 | 38_PRE | M | M | T2D | 62 | amostra discrepante (conectividade) |
| GSE130991 | GSM3758430 | M | M | T2D | 65 | amostra discrepante (conectividade) |
| GSE130991 | GSM3758442 | M | F | T2D | 43 | sexo genético discordante do declarado |
| GSE130991 | GSM3758533 | F | M | ND | 30 | sexo genético discordante do declarado |
| GSE130991 | GSM3758586 | M | F | T2D | 49 | sexo genético discordante do declarado |
| GSE130991 | GSM3758769 | F | M | T2D | 38 | sexo genético discordante do declarado |
| GSE130991 | GSM3758772 | F | F | ND | 32 | amostra discrepante (conectividade) |
| GSE130991 | GSM3759007 | F | M | ND | 33 | sexo genético discordante do declarado |
| GSE130991 | GSM3759062 | F | F | T2D | 54 | amostra discrepante (conectividade) |
| GSE130991 | GSM3759131 | F | M | T2D | 43 | sexo genético discordante do declarado |
| GSE130991 | GSM3759137 | F | M | T2D | 41 | sexo genético discordante do declarado |
| GSE130991 | GSM3759140 | F | M | ND | 53 | sexo genético discordante do declarado |
| GSE130991 | GSM3759141 | M | F | T2D | 39 | sexo genético discordante do declarado |
| GSE130991 | GSM3759142 | F | M | T2D | 55 | sexo genético discordante do declarado |
| GSE130991 | GSM3759144 | M | F | T2D | 61 | sexo genético discordante do declarado |
| GSE41762 | GSM1023682 | F | M | ND | 57 | sexo genético discordante do declarado |
| GSE41762 | GSM1023720 | F | F | ND | 49 | amostra discrepante (conectividade) |
| GSE76895 | GSM2040174 | M | M | ND | 54 | amostra discrepante (conectividade) |
| GSE76895 | GSM2040207 | M | F | T2D | 81 | sexo genético discordante do declarado |
| GSE18732 | GSM465319 | F | F | ND | 57 | amostra discrepante (conectividade) |
| GSE25462 | GSM624938 | F | F | ND | 45 | amostra discrepante (conectividade) |
| GSE25462 | GSM624955 | F | M | ND | 60 | sexo genético discordante do declarado |
| GSE184050 | case_sample_18 | F | F | T2D | 28 | amostra discrepante (conectividade) |
| GSE184050 | control_sample_10 | F | F | ND | 43 | amostra discrepante (conectividade) |
| GSE156993 | GSM4749821 | F | F | T2D | 57 | amostra discrepante (conectividade) |
| GSE156993 | GSM4749845 | M | F | ND | 36 | sexo genético discordante do declarado |
| GSE250283 | DMM00786 | M | M | T2D | 69 | amostra discrepante (conectividade) |
| GSE189005 | GSM5693110 | F | F | ND | 43 | amostra discrepante (conectividade) |
| GSE23561 | GSM577966 | F | NA | ND | 54 | amostra discrepante (conectividade) |
| GSE316126 | GSM9445181 | F | NA | ND | 53 | amostra discrepante (conectividade) |

## 4. Fonte e processamento de cada estudo

- **GSE200678** (contagens): GSE200678_Kallisto_visceral_AT_tissue_count.txt.gz. contagens brutas -> filterByExpr, TMM, log2-CPM (edgeR)
- **GSE133666** (cel): CEL de 18 amostras (GEO, por GSM). RMA (oligo, nível de gene); anotação hugene20sttranscriptcluster.db
- **GSE198922** (contagens_norm): GSE198922_processed.data.csv.gz. valores já normalizados pelo autor -> log2(x + 1); sem contagens brutas no GEO. Nota: matriz do autor
- **GSE29226** (illumina_bruto): GSE29226_non-normalized.txt.gz. neqc (limma: normexp com sondas negativas pelo p de detecção, quantis, log2); anotação da plataforma
- **GSE130991** (series_matrix): series matrix do GEO (matriz do autor). log2 (se linear) + quantis; anotação da plataforma. Nota: matriz do autor
- **GSE15653** (cel): CEL de 18 amostras (GEO, por GSM). RMA (oligo); anotação hgu133a.db
- **GSE41762** (cel): CEL de 77 amostras (GEO, por GSM). RMA (oligo, nível de gene); anotação hugene10sttranscriptcluster.db
- **GSE221156** (pseudobulk_h5ad): GSE221156_integrado_464a2c70.h5ad. pseudo-bulk: soma das contagens brutas de todas as células de cada doador (h5ad do CELLxGENE, que identifica o doador de cada célula) -> TMM, log2-CPM. Nota: os arquivos brutos do GEO juntam vários doadores por biblioteca; o h5ad traz o doador de cada célula
- **GSE76895** (cel): CEL de 68 amostras (GEO, por GSM). RMA (oligo); anotação hgu133plus2.db
- **GSE86469** (pseudobulk_csv): GSE86469_GEO.islet.single.cell.processed.data.RSEM.raw.expected.counts.csv.gz. pseudo-bulk: soma das contagens de todas as células de cada doador -> TMM, log2-CPM. Nota: 638 células ligadas a 8 doadores
- **GSE18732** (cel): CEL de 92 amostras (GEO, por GSM). RMA (oligo); anotação hgu133plus2.db
- **GSE21340** (cel): CEL de 15 amostras (GEO, por GSM). RMA (oligo); anotação hu6800.db
- **GSE25462** (cel): CEL de 50 amostras (GEO, por GSM). RMA (oligo); anotação hgu133plus2.db
- **GSE184050** (contagens_norm): GSE184050_CCHC_T2D_DEseq2_normalized_count.txt.gz. valores já normalizados pelo autor -> log2(x + 1); sem contagens brutas no GEO. Nota: matriz do autor
- **GSE156993** (cel): CEL de 18 amostras (GEO, por GSM). RMA (oligo); anotação hgu133plus2.db
- **GSE250283** (illumina_bruto): GSE250283_non_normalized.txt.gz. neqc (limma: normexp com sondas negativas pelo p de detecção, quantis, log2); anotação da plataforma
- **GSE189005** (cel): CEL de 45 amostras (GEO, por GSM). RMA (oligo); anotação clariomdhumantranscriptcluster.db
- **GSE23561** (series_matrix): series matrix do GEO (matriz do autor). log2 (se linear) + quantis; anotação da plataforma. Nota: matriz do autor
- **GSE316126** (nanostring): RCC de 24 amostras (GEO, por GSM). controles positivos + 20 genes de referência (médias geométricas), log2; 748 genes endógenos do painel. Nota: painel dirigido (D4)
- **GSE249102** (agilent_bruto): arquivos Agilent de 8 amostras (GEO, por GSM). normexp + quantis (limma), log2; sondas de controle retiradas; anotação da plataforma

Figura: `docs/figuras/pca_estudos.png` (vermelho = DM2, azul = sem diabetes; círculo = F, triângulo = M, aberto = sem sexo; X = retirada).

## 5. O que validar

1. Fonte e processamento de cada estudo (seção 4), em especial os que usam matriz do autor.
2. As amostras retiradas e os motivos (seção 3).
3. Estudos que perderam elegibilidade ou ficaram só para sensibilidade (seção 1, coluna Categoria).
