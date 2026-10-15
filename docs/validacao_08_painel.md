# Validação da etapa 08: conectividade entre tecidos e painel

Gerado em 15/10/2026 18:33 a partir de `output/08_painel/`.

## 1. Candidatos por tecido e critérios

| Tecido | Candidatos | Efeito replicado | Gene-chave de módulo | Via forte ou convergente | Ligação com tecido de 2+ estudos | Robusto a tirar um estudo | No painel |
|---|---:|---:|---:|---:|---:|---:|---:|
| adiposo | 58 | 1 | 0 | 0 | 56 | 0 | 0 |
| figado | 1772 | 0 | 58 | 275 | 1472 | 0 | 20 |
| ilhotas | 493 | 24 | 35 | 73 | 409 | 4 | 15 |
| musculo | 1587 | 453 | 75 | 333 | 894 | 0 | 106 |

Painel = gene × tecido com pelo menos 3 dos 5 pontos. Todos os genes são **exploratórios** quando não vêm de módulo significativo ou sugestivo.

## 2. Painel por programa

Os critérios não são independentes (um gene de módulo ganha juntos os pontos de efeito, gene-chave e via convergente), então o painel é lido por programa: o módulo selecionado de cada tecido, com os genes mais centrais (kME) em destaque. Lista completa na seção 2b e em output/08_painel/painel.csv (decisão do usuário, 08/10/2026).

| Programa | Vias do módulo | Seleção do módulo | Genes no painel | Maiores / menores no DM2 | Destaques (mais centrais) |
|---|---|---|---:|---|---|
| figado M6 | OXIDATIVE PHOSPHORYLATION / ADIPOGENESIS | sugestivo | 11 | 11 / 0 | YIF1A, COPE, P4HB, PSMD8, VCP, USE1, ENO1, ATP6V0B, CTSA, PGAM1 |
| figado M15 | PROTEIN SECRETION / ENDOPLASMIC RETICULUM TO GOLGI VESICLE MEDIATED TRANSPORT | sugestivo | 9 | 9 / 0 | COPB2, SEC24A, SEC23A, ACBD3, CLTC, ARF4, RAB6A, CANX, ARCN1 |
| ilhotas M6 | EPITHELIAL MESENCHYMAL TRANSITION / TNFA SIGNALING VIA NFKB | exploratório | 12 | 12 / 0 | THBS2, SLC16A1, ZEB2, SLIT2, RAB34, LTBP1, TGFB3, HGF, APOD, IL6 |
| ilhotas (vias, fora de módulo selecionado) | EPITHELIAL MESENCHYMAL TRANSITION / MYOGENESIS | - | 3 | 3 / 0 | PCOLCE, PEA15, ADAMTS3 |
| musculo (vias, fora de módulo selecionado) | OXIDATIVE PHOSPHORYLATION / ADIPOGENESIS | - | 64 | 1 / 63 | MPI, NDUFAF3, TFAM, MRPS35, HSD17B10, MAPK14, MMUT, APOO, PER2, NDUFA2 |
| musculo M4 | OXIDATIVE PHOSPHORYLATION / FATTY ACID METABOLISM | exploratório (efeito fixo, 2 estudos) | 41 | 0 / 41 | MRPL15, NDUFA8, SUCLG1, OXSM, NDUFAF4, TIMM23, CMC2, ECHDC1, NDUFB5, MRPL47 |
| musculo M6 | GPCR LIGAND BINDING / G PROTEIN COUPLED RECEPTOR SIGNALING PATHWAY | exploratório (efeito fixo, 2 estudos) | 1 | 1 / 0 | HNF4A |

### 2b. Lista completa (tabela suplementar)

| Gene | Tecido | Sentido | g | p | Estudos no mesmo sentido | Pontos | Evidência | Origem |
|---|---|---|---:|---:|---|---:|---|---|
| COPB2 | figado | maior no DM2 | 0.32 | 0,039 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| SEC24A | figado | maior no DM2 | 0.50 | 0,0015 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| SEC23A | figado | maior no DM2 | 0.27 | 0,083 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| ACBD3 | figado | maior no DM2 | 0.19 | 0,21 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| CLTC | figado | maior no DM2 | 0.35 | 0,026 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| ARF4 | figado | maior no DM2 | 0.53 | 0,00082 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| RAB6A | figado | maior no DM2 | 0.61 | 0,0001 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| CANX | figado | maior no DM2 | 0.39 | 0,012 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| ARCN1 | figado | maior no DM2 | 0.27 | 0,085 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| YIF1A | figado | maior no DM2 | 0.54 | 0,00057 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| COPE | figado | maior no DM2 | 0.53 | 0,00076 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| P4HB | figado | maior no DM2 | 0.45 | 0,0042 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| PSMD8 | figado | maior no DM2 | 0.36 | 0,021 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| VCP | figado | maior no DM2 | 0.48 | 0,0023 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| USE1 | figado | maior no DM2 | 0.28 | 0,072 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| ENO1 | figado | maior no DM2 | 0.38 | 0,015 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| ATP6V0B | figado | maior no DM2 | 0.20 | 0,19 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| CTSA | figado | maior no DM2 | 0.39 | 0,013 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| PGAM1 | figado | maior no DM2 | 0.42 | 0,0072 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| ATP6AP1 | figado | maior no DM2 | 0.21 | 0,17 | 1/1 | 3 | exploratório (1 estudo) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| PCOLCE | ilhotas | maior no DM2 | 1.42 | 0,048 | 4/4 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| PEA15 | ilhotas | maior no DM2 | 1.43 | 0,033 | 4/4 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| ADAMTS3 | ilhotas | maior no DM2 | 1.86 | 0,046 | 3/3 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| THBS2 | ilhotas | maior no DM2 | 1.69 | 0,021 | 4/4 | 4 | exploratório | gene-chave de módulo |
| SLC16A1 | ilhotas | maior no DM2 | 1.15 | 0,045 | 4/4 | 3 | exploratório | gene-chave de módulo |
| ZEB2 | ilhotas | maior no DM2 | 0.98 | 0,049 | 4/4 | 3 | exploratório | gene-chave de módulo; via selecionada no tecido (escore, todos os estudos no mes |
| SLIT2 | ilhotas | maior no DM2 | 1.43 | 0,05 | 4/4 | 3 | exploratório | gene-chave de módulo |
| RAB34 | ilhotas | maior no DM2 | 1.65 | 0,026 | 4/4 | 3 | exploratório | gene-chave de módulo |
| LTBP1 | ilhotas | maior no DM2 | 1.38 | 0,029 | 4/4 | 4 | exploratório | gene-chave de módulo |
| TGFB3 | ilhotas | maior no DM2 | 1.10 | 0,053 | 4/4 | 3 | exploratório | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| HGF | ilhotas | maior no DM2 | 1.20 | 0,048 | 4/4 | 4 | exploratório | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| APOD | ilhotas | maior no DM2 | 1.43 | 0,049 | 4/4 | 3 | exploratório | gene-chave de módulo; via selecionada no tecido (escore, todos os estudos no mes |
| IL6 | ilhotas | maior no DM2 | 1.51 | 0,027 | 4/4 | 4 | exploratório | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| IGFBP4 | ilhotas | maior no DM2 | 1.31 | 0,046 | 4/4 | 3 | exploratório | gene-chave de módulo |
| SH2B3 | ilhotas | maior no DM2 | 1.16 | 0,043 | 4/4 | 3 | exploratório | gene-chave de módulo; via selecionada no tecido (escore, todos os estudos no mes |
| MPI | musculo | menor no DM2 | -0.99 | 0,28 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| NDUFAF3 | musculo | menor no DM2 | -0.77 | 0,37 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| TFAM | musculo | menor no DM2 | -1.53 | 0,38 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| MRPS35 | musculo | menor no DM2 | -0.85 | 0,28 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| HSD17B10 | musculo | menor no DM2 | -0.83 | 0,43 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| MAPK14 | musculo | menor no DM2 | -0.97 | 0,26 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| MMUT | musculo | menor no DM2 | -0.98 | 0,24 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| APOO | musculo | menor no DM2 | -1.30 | 0,2 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| PER2 | musculo | menor no DM2 | -1.06 | 0,22 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| NDUFA2 | musculo | menor no DM2 | -0.80 | 0,32 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| PCCB | musculo | menor no DM2 | -1.26 | 0,21 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| CYC1 | musculo | menor no DM2 | -0.78 | 0,33 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| MED1 | musculo | menor no DM2 | -1.00 | 0,3 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| ALKBH1 | musculo | menor no DM2 | -1.01 | 0,29 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| PEX2 | musculo | menor no DM2 | -1.22 | 0,21 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| KARS1 | musculo | menor no DM2 | -0.91 | 0,27 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| ACADL | musculo | menor no DM2 | -0.91 | 0,26 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| EIF2S1 | musculo | menor no DM2 | -1.47 | 0,18 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| NDUFS8 | musculo | menor no DM2 | -0.85 | 0,24 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| PPARGC1A | musculo | menor no DM2 | -0.90 | 0,25 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| MTHFD1 | musculo | menor no DM2 | -1.34 | 0,2 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| FUNDC1 | musculo | menor no DM2 | -1.29 | 0,19 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| EIF4E | musculo | menor no DM2 | -1.08 | 0,2 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| COX10 | musculo | menor no DM2 | -1.34 | 0,34 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| AUH | musculo | menor no DM2 | -0.75 | 0,3 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| PEX3 | musculo | menor no DM2 | -1.22 | 0,21 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| ETFDH | musculo | menor no DM2 | -0.97 | 0,27 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| NDUFAF7 | musculo | menor no DM2 | -1.21 | 0,22 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| MRPS9 | musculo | menor no DM2 | -0.84 | 0,31 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| SOD2 | musculo | menor no DM2 | -0.80 | 0,27 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| PCCA | musculo | menor no DM2 | -0.82 | 0,29 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| NARS2 | musculo | menor no DM2 | -1.23 | 0,2 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| NNT | musculo | menor no DM2 | -0.85 | 0,28 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| PIK3CA | musculo | menor no DM2 | -1.37 | 0,47 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| PPARA | musculo | menor no DM2 | -0.78 | 0,27 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| CREB1 | musculo | menor no DM2 | -2.39 | 0,39 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| TBPL1 | musculo | menor no DM2 | -1.80 | 0,16 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| QRSL1 | musculo | menor no DM2 | -1.20 | 0,3 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| NDUFA11 | musculo | menor no DM2 | -1.19 | 0,21 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| HMGCS2 | musculo | menor no DM2 | -0.80 | 0,29 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| ACACA | musculo | menor no DM2 | -1.15 | 0,23 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| ETFB | musculo | menor no DM2 | -0.86 | 0,42 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| ADK | musculo | menor no DM2 | -0.79 | 0,44 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| RPL15 | musculo | menor no DM2 | -1.27 | 0,21 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| ALDH6A1 | musculo | menor no DM2 | -1.24 | 0,19 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| HAX1 | musculo | menor no DM2 | -1.18 | 0,21 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| PARL | musculo | menor no DM2 | -1.10 | 0,23 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| HDAC3 | musculo | menor no DM2 | -1.08 | 0,22 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| EIF3K | musculo | menor no DM2 | -1.02 | 0,29 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| ATP5PO | musculo | menor no DM2 | -0.99 | 0,24 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| TRIAP1 | musculo | menor no DM2 | -0.97 | 0,26 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| EMD | musculo | menor no DM2 | -0.96 | 0,25 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| EIF3H | musculo | menor no DM2 | -0.94 | 0,26 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| C1QBP | musculo | menor no DM2 | -0.94 | 0,27 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| MRPL58 | musculo | menor no DM2 | -0.93 | 0,27 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| GNPDA1 | musculo | menor no DM2 | -0.93 | 0,27 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| MRPL49 | musculo | menor no DM2 | -0.92 | 0,28 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| AMPD1 | musculo | menor no DM2 | -0.92 | 0,3 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| TFB1M | musculo | menor no DM2 | -0.89 | 0,32 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| MRPS11 | musculo | menor no DM2 | -0.88 | 0,28 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| ADA | musculo | menor no DM2 | -0.87 | 0,28 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| ADAMTS13 | musculo | maior no DM2 | 0.85 | 0,29 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| FH | musculo | menor no DM2 | -0.80 | 0,42 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| APEX1 | musculo | menor no DM2 | -0.79 | 0,3 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| MRPL15 | musculo | menor no DM2 | -1.37 | 0,2 | 2/2 | 4 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| NDUFA8 | musculo | menor no DM2 | -1.29 | 0,21 | 2/2 | 4 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| SUCLG1 | musculo | menor no DM2 | -0.97 | 0,26 | 2/2 | 4 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| OXSM | musculo | menor no DM2 | -1.17 | 0,23 | 2/2 | 4 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| NDUFAF4 | musculo | menor no DM2 | -1.31 | 0,2 | 2/2 | 4 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| TIMM23 | musculo | menor no DM2 | -0.95 | 0,27 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| CMC2 | musculo | menor no DM2 | -1.09 | 0,24 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| ECHDC1 | musculo | menor no DM2 | -0.88 | 0,31 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo |
| NDUFB5 | musculo | menor no DM2 | -0.59 | 0,37 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| MRPL47 | musculo | menor no DM2 | -1.03 | 0,26 | 2/2 | 4 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| PLGRKT | musculo | menor no DM2 | -1.19 | 0,2 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo |
| MRPS30 | musculo | menor no DM2 | -1.74 | 0,16 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| TMEM126A | musculo | menor no DM2 | -1.60 | 0,17 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| MCTS1 | musculo | menor no DM2 | -1.16 | 0,21 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo |
| TACO1 | musculo | menor no DM2 | -0.95 | 0,3 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| HCCS | musculo | menor no DM2 | -1.23 | 0,2 | 2/2 | 4 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| MRPL16 | musculo | menor no DM2 | -1.21 | 0,25 | 2/2 | 4 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| KGD4 | musculo | menor no DM2 | -0.92 | 0,26 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| SDHB | musculo | menor no DM2 | -0.55 | 0,39 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| MRPL36 | musculo | menor no DM2 | -1.00 | 0,24 | 2/2 | 4 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| MTHFD2L | musculo | menor no DM2 | -0.86 | 0,28 | 2/2 | 4 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| ATP5PB | musculo | menor no DM2 | -0.90 | 0,27 | 2/2 | 4 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| ATG5 | musculo | menor no DM2 | -1.32 | 0,23 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo |
| COQ3 | musculo | menor no DM2 | -1.44 | 0,18 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo |
| ATP5MC1 | musculo | menor no DM2 | -1.03 | 0,26 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| ZDHHC16 | musculo | menor no DM2 | -0.81 | 0,29 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo |
| CHCHD1 | musculo | menor no DM2 | -0.97 | 0,26 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| TIMMDC1 | musculo | menor no DM2 | -1.25 | 0,19 | 2/2 | 4 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo; via convergente; via selecionada no tecido (escore, todos  |
| SLC25A46 | musculo | menor no DM2 | -0.99 | 0,26 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| PRORP | musculo | menor no DM2 | -1.10 | 0,24 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| NDUFA9 | musculo | menor no DM2 | -0.92 | 0,28 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| GLUD1 | musculo | menor no DM2 | -1.07 | 0,24 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| TFB2M | musculo | menor no DM2 | -0.94 | 0,37 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| DECR1 | musculo | menor no DM2 | -1.06 | 0,24 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| NDUFS1 | musculo | menor no DM2 | -0.94 | 0,25 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| MCEE | musculo | menor no DM2 | -1.04 | 0,23 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| MRPS16 | musculo | menor no DM2 | -1.27 | 0,22 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| SLC25A5 | musculo | menor no DM2 | -1.04 | 0,41 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| ALDH3A2 | musculo | menor no DM2 | -0.79 | 0,26 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| ECI1 | musculo | menor no DM2 | -0.95 | 0,26 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| NMNAT3 | musculo | menor no DM2 | -1.13 | 0,22 | 2/2 | 3 | exploratório | via convergente; via selecionada no tecido (escore, todos os estudos no mesmo se |
| HNF4A | musculo | maior no DM2 | 1.12 | 0,21 | 2/2 | 3 | exploratório (efeito fixo, 2 estudos) | gene-chave de módulo |

## 3. Ligações entre tecidos

STRING (confiança ≥ 700): 16307 pares de genes únicos entre candidatos de tecidos diferentes (cada par contado uma vez; tecidos de cada gene em string_entre_tecidos.csv). OmniPath: 1010 pares ligante–receptor com ligante num tecido e receptor em outro.

| Ligante | Tecido do ligante | Receptor | Tecido do receptor |
|---|---|---|---|
| DLL1 | figado | NOTCH1 | ilhotas |
| DLL1 | musculo | NOTCH1 | ilhotas |
| DLL1 | figado | NOTCH1 | musculo |
| DLL1 | ilhotas | NOTCH1 | musculo |
| NOTCH1 | ilhotas | JAG1 | musculo |
| JAG1 | musculo | NOTCH1 | ilhotas |
| TGFA | figado | ERBB2 | musculo |
| SFRP2 | ilhotas | WNT4 | figado |
| SFRP2 | musculo | WNT4 | figado |
| SFRP1 | ilhotas | WNT4 | figado |
| SFRP2 | ilhotas | WNT1 | figado |
| SFRP2 | musculo | WNT1 | figado |
| SFRP1 | ilhotas | WNT1 | figado |
| IL6 | adiposo | IL6ST | ilhotas |
| IL6 | figado | IL6ST | ilhotas |
| DKK1 | adiposo | LRP6 | figado |
| DKK1 | musculo | LRP6 | figado |
| DKK1 | adiposo | LRP5 | musculo |
| WNT5A | ilhotas | FZD5 | figado |
| WNT5A | musculo | FZD5 | figado |
| WNT5A | musculo | FZD5 | ilhotas |
| CD28 | figado | CD86 | ilhotas |
| CD28 | musculo | CD86 | ilhotas |
| CD28 | figado | CD86 | musculo |
| CD86 | ilhotas | CD28 | figado |
| CD86 | musculo | CD28 | figado |
| CD86 | ilhotas | CD28 | musculo |
| NRG1 | figado | ERBB2 | musculo |
| IL4 | musculo | IL4R | ilhotas |
| TGFA | figado | EGFR | musculo |
| HGF | ilhotas | MET | figado |
| HGF | figado | MET | ilhotas |
| SHH | ilhotas | PTCH1 | musculo |
| WNT5A | ilhotas | ROR2 | figado |
| WNT5A | musculo | ROR2 | figado |
| LGALS9 | musculo | HAVCR2 | ilhotas |
| LGALS9 | ilhotas | HAVCR2 | musculo |
| JAG1 | musculo | NOTCH2 | ilhotas |
| NOTCH2 | ilhotas | JAG1 | musculo |
| TGFB1 | figado | ACVRL1 | ilhotas |
| TGFB1 | musculo | ACVRL1 | ilhotas |
| TGFB3 | ilhotas | TGFBR3 | figado |
| TGFB2 | ilhotas | TGFBR3 | figado |
| TGFB2 | musculo | TGFBR3 | figado |
| TGFB2 | figado | TGFBR1 | musculo |
| TGFB2 | ilhotas | TGFBR1 | musculo |
| ARF4 | figado | EGFR | musculo |
| WNT7A | musculo | FZD5 | figado |
| WNT7A | musculo | FZD5 | ilhotas |
| CCN3 | ilhotas | NOTCH1 | musculo |
| ROR2 | figado | FZD5 | ilhotas |
| CNTN1 | musculo | NOTCH2 | ilhotas |
| CNTN1 | musculo | NOTCH1 | ilhotas |
| WNT1 | figado | LRP5 | musculo |
| TGFB1 | ilhotas | TGFBR3 | figado |
| TGFB1 | musculo | TGFBR3 | figado |
| TGFB1 | figado | TGFBR1 | musculo |
| TGFB1 | ilhotas | TGFBR1 | musculo |
| DLL1 | figado | NOTCH2 | ilhotas |
| DLL1 | musculo | NOTCH2 | ilhotas |
| WNT5A | ilhotas | FZD4 | figado |
| WNT5A | musculo | FZD4 | figado |
| DLL4 | musculo | NOTCH1 | ilhotas |
| INHBA | ilhotas | ACVR2B | figado |
| BMP7 | ilhotas | ACVR2B | figado |
| BMP6 | ilhotas | ACVR2B | figado |
| BMP6 | musculo | ACVR2B | figado |
| MFAP5 | ilhotas | NOTCH1 | musculo |
| PDGFA | figado | PDGFRA | ilhotas |
| PDGFB | musculo | PDGFRA | ilhotas |
| FGF1 | ilhotas | FGFR1 | figado |
| FGF1 | figado | FGFR1 | ilhotas |
| FGF1 | ilhotas | FGFR2 | figado |
| FGF1 | figado | FGFR2 | musculo |
| FGF1 | ilhotas | FGFR2 | musculo |
| FGF2 | ilhotas | FGFR2 | figado |
| FGF2 | figado | FGFR2 | musculo |
| FGF2 | ilhotas | FGFR2 | musculo |
| FGF4 | musculo | FGFR2 | figado |
| FGF8 | musculo | FGFR2 | figado |
| FGF10 | musculo | FGFR2 | figado |
| EFNA1 | musculo | EPHA2 | ilhotas |
| EFNA1 | musculo | EPHA3 | figado |
| EFNA1 | musculo | EPHA3 | ilhotas |
| EFNA5 | musculo | EPHA3 | figado |
| EFNA5 | musculo | EPHA3 | ilhotas |
| GAS6 | figado | AXL | ilhotas |
| BTC | figado | EGFR | musculo |
| GDF5 | musculo | ACVR2B | figado |
| IL19 | figado | IL20RB | musculo |
| MFAP2 | ilhotas | NOTCH1 | musculo |
| TGFB1 | figado | ITGB8 | ilhotas |
| TGFB1 | musculo | ITGB8 | ilhotas |
| FGF22 | musculo | FGFR2 | figado |
| EPHB2 | musculo | EFNB2 | figado |
| EPHB2 | figado | EFNB2 | musculo |
| EFNB2 | musculo | EPHB2 | figado |
| EFNB2 | figado | EPHB2 | musculo |
| EFNB2 | musculo | EPHA3 | figado |
| EFNB2 | figado | EPHA3 | ilhotas |
| EFNB2 | musculo | EPHA3 | ilhotas |
| PROS1 | figado | AXL | ilhotas |
| C5 | figado | C5AR1 | musculo |
| CCL2 | musculo | CCR2 | ilhotas |
| CXCL12 | figado | CXCR4 | adiposo |
| CXCL12 | figado | CXCR4 | ilhotas |
| POMC | ilhotas | OPRD1 | musculo |
| EDN2 | musculo | EDNRA | figado |
| EDN2 | figado | EDNRA | ilhotas |
| EDN2 | musculo | EDNRA | ilhotas |
| RSPO3 | ilhotas | LGR4 | figado |
| RSPO3 | ilhotas | LGR5 | figado |
| POMC | ilhotas | OPRK1 | musculo |
| TAC1 | musculo | TACR2 | ilhotas |
| TAC1 | ilhotas | TACR2 | musculo |
| TAC3 | musculo | TACR2 | ilhotas |
| TAC1 | ilhotas | TACR3 | musculo |
| NMU | figado | NMUR1 | musculo |
| COL1A1 | ilhotas | ITGB1 | figado |
| COL1A1 | musculo | ITGB1 | figado |
| COL1A1 | figado | ITGB1 | ilhotas |
| COL1A1 | musculo | ITGB1 | ilhotas |
| VTN | musculo | ITGB1 | figado |
| VTN | musculo | ITGB1 | ilhotas |
| FGA | ilhotas | ITGB1 | figado |
| PDGFB | musculo | PDGFRB | ilhotas |
| CTSG | figado | F2RL1 | ilhotas |
| PRSS2 | musculo | F2RL1 | figado |
| PRSS2 | musculo | F2RL1 | ilhotas |
| NOG | ilhotas | GDF5 | musculo |
| BMP7 | ilhotas | ACVR1 | figado |
| F2 | figado | F2R | ilhotas |
| HMGB1 | figado | TLR4 | ilhotas |
| FGA | ilhotas | ITGAX | musculo |
| PLG | musculo | F2R | ilhotas |
| WNT11 | ilhotas | FZD3 | figado |
| WNT11 | musculo | FZD3 | figado |
| MIF | ilhotas | CD74 | figado |
| MIF | figado | CD74 | ilhotas |
| CTSG | figado | F2R | ilhotas |
| GNAS | figado | PTGIR | ilhotas |
| LIF | figado | IL6ST | ilhotas |
| WNT5A | ilhotas | FZD3 | figado |
| WNT5A | musculo | FZD3 | figado |
| S100A8 | musculo | TLR4 | ilhotas |
| WNT7A | musculo | LRP6 | figado |
| NOG | ilhotas | BMP4 | figado |
| TNFSF11 | ilhotas | TNFRSF11A | musculo |
| COL1A1 | figado | DDR2 | ilhotas |
| COL1A1 | musculo | DDR2 | ilhotas |
| IL1B | musculo | IL1RAP | figado |
| IL1B | figado | IL1RAP | ilhotas |
| IL1B | musculo | IL1RAP | ilhotas |
| IL1B | figado | IL1RAP | musculo |
| CSF1 | ilhotas | CSF1R | musculo |
| S100A9 | musculo | TLR4 | ilhotas |
| MSTN | musculo | ACVR2B | figado |
| CCN2 | ilhotas | LRP6 | figado |
| ADAM12 | musculo | SDC4 | figado |
| OSM | musculo | IL6ST | ilhotas |
| APOE | figado | SORL1 | musculo |
| RGMA | musculo | NEO1 | figado |
| GDF5 | musculo | BMPR1B | figado |
| GDF5 | musculo | BMPR1B | ilhotas |
| RSPO3 | ilhotas | SDC4 | figado |
| ANGPT1 | ilhotas | TIE1 | figado |
| F2 | figado | F2RL1 | ilhotas |
| EFNA5 | musculo | EPHA2 | ilhotas |
| F2 | figado | F2RL3 | musculo |
| LTBP1 | ilhotas | TGFB1 | figado |
| LTBP1 | ilhotas | TGFB1 | musculo |
| WNT2 | ilhotas | LRP6 | figado |
| BMP4 | figado | BMPR1A | musculo |
| ICAM1 | figado | ITGAX | ilhotas |
| ICAM1 | figado | ITGAX | musculo |
| ANXA1 | ilhotas | EGFR | musculo |
| ADAM12 | musculo | ITGB1 | figado |
| ADAM12 | figado | ITGB1 | ilhotas |
| ADAM12 | musculo | ITGB1 | ilhotas |
| PLXNA4 | musculo | SEMA6A | ilhotas |
| CALR | figado | ITGA3 | ilhotas |
| ICOSLG | figado | CD28 | musculo |
| C1QA | figado | CSPG4 | musculo |
| COL3A1 | musculo | DDR2 | ilhotas |
| DCN | figado | EGFR | musculo |
| DCN | ilhotas | EGFR | musculo |
| EFEMP1 | figado | EGFR | musculo |
| EFEMP1 | ilhotas | EGFR | musculo |
| EPHB2 | figado | EFNA5 | musculo |
| EFNA5 | musculo | EPHB2 | figado |
| FGF10 | musculo | FGFR1 | figado |
| FGF10 | musculo | FGFR1 | ilhotas |
| FGF16 | figado | FGFR1 | ilhotas |
| FGF2 | ilhotas | FGFR1 | figado |
| FGF2 | figado | FGFR1 | ilhotas |
| FGF20 | musculo | FGFR1 | figado |
| FGF20 | musculo | FGFR1 | ilhotas |
| FGF21 | figado | FGFR1 | ilhotas |
| FGF23 | figado | FGFR1 | ilhotas |
| FGF4 | musculo | FGFR1 | figado |
| FGF4 | musculo | FGFR1 | ilhotas |
| FGF8 | musculo | FGFR1 | figado |
| FGF8 | musculo | FGFR1 | ilhotas |
| FGF16 | figado | FGFR2 | musculo |
| FGF20 | musculo | FGFR2 | figado |
| APOE | musculo | LDLR | figado |
| APOE | figado | LDLR | ilhotas |
| APOE | musculo | LDLR | ilhotas |
| APOE | figado | LDLR | musculo |
| SOST | figado | LRP5 | musculo |
| DCN | ilhotas | MET | figado |
| DCN | figado | MET | ilhotas |
| DLL4 | musculo | NOTCH2 | ilhotas |
| FGF1 | ilhotas | NRP1 | figado |
| FGF2 | ilhotas | NRP1 | figado |
| FGF4 | musculo | NRP1 | figado |
| PLG | ilhotas | PLGRKT | musculo |
| SEMA6A | ilhotas | PLXNA4 | musculo |
| IL1RAP | ilhotas | PTPRD | figado |
| IL1RAP | musculo | PTPRD | figado |
| IL1RAP | figado | PTPRD | musculo |
| IL1RAP | ilhotas | PTPRD | musculo |
| LRFN4 | musculo | PTPRD | figado |
| LRFN4 | musculo | PTPRS | figado |
| APOE | musculo | SCARB1 | figado |
| HGF | figado | SDC1 | ilhotas |
| HGF | figado | SDC1 | musculo |
| HGF | ilhotas | SDC1 | musculo |
| FGF2 | figado | SDC1 | ilhotas |
| FGF2 | figado | SDC1 | musculo |
| FGF2 | ilhotas | SDC1 | musculo |
| MDK | ilhotas | SDC4 | figado |
| MDK | musculo | SDC4 | figado |
| FGF2 | ilhotas | SDC4 | figado |
| THBS1 | ilhotas | SDC4 | figado |
| THBS1 | musculo | SDC4 | figado |
| SPN | musculo | ICAM1 | figado |
| BGN | figado | TLR4 | ilhotas |
| HLA-F | musculo | VSIR | ilhotas |
| SEMA3F | musculo | NRP1 | figado |
| APOA1 | musculo | LDLR | figado |
| APOA1 | figado | LDLR | ilhotas |
| APOA1 | musculo | LDLR | ilhotas |
| APOA1 | figado | LDLR | musculo |
| TIMP1 | figado | CD63 | musculo |
| TGFB1 | ilhotas | ENG | figado |
| TGFB1 | musculo | ENG | figado |
| TGFB1 | figado | ENG | ilhotas |
| TGFB1 | musculo | ENG | ilhotas |
| TGFB1 | ilhotas | SMAD3 | figado |
| TGFB1 | musculo | SMAD3 | figado |
| TGFB1 | figado | SMAD3 | ilhotas |
| TGFB1 | musculo | SMAD3 | ilhotas |
| TGFB1 | ilhotas | ITGAV | figado |
| TGFB1 | musculo | ITGAV | figado |
| TGFB1 | ilhotas | ITGB1 | figado |
| TGFB1 | musculo | ITGB1 | figado |
| TGFB1 | figado | ITGB1 | ilhotas |
| TGFB1 | musculo | ITGB1 | ilhotas |
| TGFB1 | ilhotas | CAV1 | figado |
| TGFB1 | musculo | CAV1 | figado |
| TGFB1 | figado | CAV1 | ilhotas |
| TGFB1 | musculo | CAV1 | ilhotas |
| TGFB1 | figado | CXCR4 | adiposo |
| TGFB1 | ilhotas | CXCR4 | adiposo |
| TGFB1 | musculo | CXCR4 | adiposo |
| TGFB1 | figado | CXCR4 | ilhotas |
| TGFB1 | musculo | CXCR4 | ilhotas |
| COMP | ilhotas | ITGB1 | figado |
| COMP | musculo | ITGB1 | figado |
| COMP | musculo | ITGB1 | ilhotas |
| COMP | ilhotas | CD36 | figado |
| COMP | musculo | CD36 | figado |
| COMP | musculo | CD36 | ilhotas |
| HGF | ilhotas | ITGB1 | figado |
| HGF | figado | ITGB1 | ilhotas |
| SERPINE1 | ilhotas | PLAUR | figado |
| SERPINE1 | ilhotas | ITGAV | figado |
| C5 | figado | ADRA2A | musculo |
| COL1A1 | figado | ITGA5 | adiposo |
| COL1A1 | ilhotas | ITGA5 | adiposo |
| COL1A1 | musculo | ITGA5 | adiposo |
| COL1A1 | figado | FLT4 | musculo |
| COL1A1 | ilhotas | FLT4 | musculo |
| COL1A1 | ilhotas | CD36 | figado |
| COL1A1 | musculo | CD36 | figado |
| COL1A1 | figado | CD36 | ilhotas |
| COL1A1 | musculo | CD36 | ilhotas |
| COL1A1 | ilhotas | ITGA1 | figado |
| COL1A1 | musculo | ITGA1 | figado |
| IAPP | musculo | ADRB2 | figado |
| COL1A1 | ilhotas | ITGAV | figado |
| COL1A1 | musculo | ITGAV | figado |
| COL1A1 | ilhotas | ITGA2 | figado |
| COL1A1 | musculo | ITGA2 | figado |
| COL1A1 | figado | ITGA2 | musculo |
| COL1A1 | ilhotas | ITGA2 | musculo |
| VTN | musculo | ITGA5 | adiposo |
| VTN | musculo | ITGAV | figado |
| VTN | musculo | KDR | figado |
| VTN | musculo | PLAUR | figado |
| CXCL6 | figado | ADRA2A | musculo |
| APOC3 | figado | LDLR | ilhotas |
| APOC3 | figado | LDLR | musculo |
| IL4 | musculo | CD53 | figado |
| LTF | musculo | TFRC | figado |
| HRG | figado | FCGR1A | musculo |
| FGF23 | figado | FGFR2 | musculo |
| TGFB3 | ilhotas | ENG | figado |
| TGFB3 | ilhotas | ITGB1 | figado |
| TGFB3 | ilhotas | TGFBR1 | musculo |
| IAPP | figado | PTH1R | musculo |
| INHBA | ilhotas | ACVR1 | figado |
| INHBA | ilhotas | ENG | figado |
| INHBA | figado | ENG | ilhotas |
| INHBA | ilhotas | SMAD3 | figado |
| INHBA | figado | SMAD3 | ilhotas |
| INHBA | ilhotas | ACVR1B | figado |
| APOE | figado | LRP5 | musculo |
| APOE | figado | CHRNA4 | musculo |
| NCAN | musculo | SDC3 | ilhotas |
| LAMA5 | musculo | SDC1 | ilhotas |
| THBS1 | ilhotas | SCARB1 | figado |
| THBS1 | musculo | SCARB1 | figado |
| LAMA5 | musculo | ITGB1 | figado |
| LAMA5 | musculo | ITGB1 | ilhotas |
| LAMA5 | musculo | ITGA2 | figado |
| CRP | musculo | OLR1 | figado |
| LACRT | figado | SDC1 | ilhotas |
| LACRT | figado | SDC1 | musculo |
| LAMC1 | figado | ITGA7 | musculo |
| LAMC1 | figado | ITGB1 | ilhotas |
| LAMC1 | figado | ITGA2 | musculo |
| THBS1 | ilhotas | ITGA4 | adiposo |
| THBS1 | musculo | ITGA4 | adiposo |
| THBS1 | ilhotas | ITGA4 | figado |
| THBS1 | musculo | ITGA4 | figado |
| THBS1 | musculo | SDC1 | ilhotas |
| THBS1 | ilhotas | SDC1 | musculo |
| THBS1 | ilhotas | ITGB1 | figado |
| THBS1 | musculo | ITGB1 | figado |
| THBS1 | musculo | ITGB1 | ilhotas |
| THBS1 | ilhotas | LRP5 | musculo |
| THBS1 | ilhotas | CD36 | figado |
| THBS1 | musculo | CD36 | figado |
| THBS1 | musculo | CD36 | ilhotas |
| WNT5A | ilhotas | ADRB2 | figado |
| WNT5A | musculo | ADRB2 | figado |
| CDH1 | figado | EGFR | musculo |
| CDH1 | figado | LRP5 | musculo |
| CDH1 | figado | CDH2 | musculo |
| TIMP2 | musculo | ITGB1 | figado |
| TIMP2 | musculo | ITGB1 | ilhotas |
| IL1B | musculo | ADRB2 | figado |
| NMU | figado | ADRA2A | musculo |
| EGF | musculo | ADRB2 | figado |
| FGF2 | figado | SDC3 | ilhotas |
| FGF2 | figado | SDC3 | musculo |
| FGF2 | ilhotas | SDC3 | musculo |
| FGF2 | ilhotas | GPC4 | figado |
| FGF2 | figado | GPC4 | ilhotas |
| WNT5A | ilhotas | LDLR | figado |
| WNT5A | musculo | LDLR | figado |
| WNT5A | musculo | LDLR | ilhotas |
| WNT5A | ilhotas | LDLR | musculo |
| WNT5A | ilhotas | LRP5 | musculo |
| ICAM1 | figado | EGFR | musculo |
| ICAM1 | figado | CAV1 | ilhotas |
| ICAM1 | figado | ITGB2 | musculo |
| F13A1 | ilhotas | ITGA4 | adiposo |
| F13A1 | ilhotas | ITGA4 | figado |
| F13A1 | ilhotas | ITGB1 | figado |
| VCAN | figado | ITGA4 | adiposo |
| VCAN | ilhotas | ITGA4 | adiposo |
| VCAN | ilhotas | ITGA4 | figado |
| EGF | musculo | CAV1 | figado |
| EGF | musculo | CAV1 | ilhotas |
| VCAN | figado | EGFR | musculo |
| VCAN | ilhotas | EGFR | musculo |
| VCAN | ilhotas | ITGB1 | figado |
| VCAN | figado | ITGB1 | ilhotas |
| EGF | musculo | LDLR | figado |
| EGF | musculo | LDLR | ilhotas |
| GAL | ilhotas | ADRA2A | musculo |
| QDPR | figado | DYSF | musculo |
| AGRP | musculo | SDC3 | ilhotas |
| WNT1 | figado | FZD5 | ilhotas |
| VCAM1 | figado | ITGA4 | adiposo |
| VCAM1 | figado | ITGB1 | ilhotas |
| VCAM1 | figado | ITGB2 | musculo |
| ARPC5 | figado | LDLR | ilhotas |
| ARPC5 | figado | LDLR | musculo |
| MELTF | musculo | TFRC | figado |
| CSF2 | musculo | ITGB1 | figado |
| CSF2 | musculo | ITGB1 | ilhotas |
| SHH | musculo | GPC5 | ilhotas |
| COL1A2 | musculo | ITGB1 | figado |
| COL1A2 | figado | ITGB1 | ilhotas |
| COL1A2 | musculo | ITGB1 | ilhotas |
| COL1A2 | musculo | CD36 | figado |
| COL1A2 | figado | CD36 | ilhotas |
| COL1A2 | musculo | CD36 | ilhotas |
| HSP90B1 | musculo | TLR7 | ilhotas |
| HSP90B1 | musculo | TLR4 | ilhotas |
| COL6A2 | musculo | ITGB1 | figado |
| COL6A2 | musculo | ITGB1 | ilhotas |
| PCSK9 | musculo | LDLR | figado |
| PCSK9 | figado | LDLR | ilhotas |
| PCSK9 | musculo | LDLR | ilhotas |
| PCSK9 | figado | LDLR | musculo |
| IL12A | ilhotas | CD28 | figado |
| IL12A | ilhotas | CD28 | musculo |
| COL3A1 | musculo | ITGB1 | figado |
| COL3A1 | musculo | ITGB1 | ilhotas |
| FGB | ilhotas | ITGAM | figado |
| FGB | ilhotas | ITGB1 | figado |
| FGB | ilhotas | ITGB2 | musculo |
| FGA | ilhotas | ITGAM | figado |
| FGA | ilhotas | PLAUR | figado |
| FGA | ilhotas | ITGB2 | musculo |
| F2 | figado | THBD | ilhotas |
| PLG | ilhotas | ITGAM | figado |
| PLG | musculo | ITGAM | figado |
| PLG | ilhotas | ITGB1 | figado |
| PLG | musculo | ITGB1 | figado |
| PLG | musculo | ITGB1 | ilhotas |
| PLG | ilhotas | PLAUR | figado |
| PLG | musculo | PLAUR | figado |
| PLG | ilhotas | ITGB2 | musculo |
| LPL | figado | SDC1 | ilhotas |
| LPL | figado | SDC1 | musculo |
| GNAI2 | figado | LPAR3 | musculo |
| GNAI2 | figado | C5AR1 | musculo |
| GNAI2 | figado | F2R | ilhotas |
| GNAI2 | figado | CAV1 | ilhotas |
| GNAI2 | figado | TBXA2R | musculo |
| GNAI2 | figado | DRD2 | musculo |
| DRD2 | musculo | GNAI2 | figado |
| LAMA3 | adiposo | ITGB1 | figado |
| LAMA3 | adiposo | ITGB1 | ilhotas |
| LAMA3 | figado | ITGB1 | ilhotas |
| FBN1 | ilhotas | ITGB1 | figado |
| FBLN1 | ilhotas | ITGB1 | figado |
| COL7A1 | musculo | ITGB1 | figado |
| COL7A1 | musculo | ITGB1 | ilhotas |
| TAC4 | musculo | TACR2 | ilhotas |
| FGG | ilhotas | ITGB1 | figado |
| FGG | musculo | ITGB1 | figado |
| FGG | musculo | ITGB1 | ilhotas |
| FGG | ilhotas | ITGB2 | musculo |
| FGG | musculo | TLR4 | ilhotas |
| PTN | figado | SDC1 | ilhotas |
| PTN | figado | SDC1 | musculo |
| PTN | ilhotas | SDC1 | musculo |
| PTN | ilhotas | PTPRS | figado |
| PTN | figado | PTPRS | musculo |
| PTN | ilhotas | PTPRS | musculo |
| HMGB1 | figado | THBD | ilhotas |
| APOA4 | adiposo | LDLR | figado |
| APOA4 | musculo | LDLR | figado |
| APOA4 | adiposo | LDLR | ilhotas |
| APOA4 | figado | LDLR | ilhotas |
| APOA4 | musculo | LDLR | ilhotas |
| APOA4 | adiposo | LDLR | musculo |
| APOA4 | figado | LDLR | musculo |
| COL18A1 | musculo | ITGB1 | figado |
| COL18A1 | musculo | ITGB1 | ilhotas |
| COL18A1 | musculo | GPC4 | figado |
| COL18A1 | musculo | GPC4 | ilhotas |
| HP | musculo | ITGAM | figado |
| COL9A1 | musculo | ITGB1 | figado |
| COL9A1 | musculo | ITGB1 | ilhotas |
| F8 | ilhotas | LDLR | figado |
| F8 | ilhotas | LDLR | musculo |
| LAMC3 | musculo | ITGB1 | figado |
| LAMC3 | figado | ITGB1 | ilhotas |
| LAMC3 | musculo | ITGB1 | ilhotas |
| COL6A1 | adiposo | ITGB1 | figado |
| COL6A1 | musculo | ITGB1 | figado |
| COL6A1 | adiposo | ITGB1 | ilhotas |
| COL6A1 | musculo | ITGB1 | ilhotas |
| THBS2 | ilhotas | ITGA4 | adiposo |
| THBS2 | ilhotas | ITGA4 | figado |
| THBS2 | ilhotas | ITGB1 | figado |
| THBS2 | ilhotas | CD36 | figado |
| TGFB2 | ilhotas | ENG | figado |
| TGFB2 | musculo | ENG | figado |
| TGFB2 | figado | ENG | ilhotas |
| TGFB2 | musculo | ENG | ilhotas |
| CCN2 | ilhotas | ITGAM | figado |
| CCN2 | ilhotas | ITGB2 | musculo |
| APOA2 | figado | LDLR | ilhotas |
| APOA2 | figado | LDLR | musculo |
| COL11A1 | adiposo | ITGB1 | figado |
| COL11A1 | adiposo | ITGB1 | ilhotas |
| CD40LG | figado | ITGB2 | musculo |
| COL5A1 | adiposo | ITGB1 | figado |
| COL5A1 | ilhotas | ITGB1 | figado |
| COL5A1 | adiposo | ITGB1 | ilhotas |
| COL5A1 | figado | ITGB1 | ilhotas |
| SFTPD | musculo | TLR4 | ilhotas |
| MMP9 | musculo | ITGAM | figado |
| MMP9 | figado | ITGB2 | musculo |
| COL5A2 | adiposo | ITGB1 | figado |
| COL5A2 | adiposo | ITGB1 | ilhotas |
| COL5A2 | figado | ITGB1 | ilhotas |
| F10 | figado | ITGB2 | musculo |
| COL4A1 | musculo | ITGB1 | figado |
| COL4A1 | musculo | ITGB1 | ilhotas |
| FGF14 | musculo | FGFR2 | figado |
| FGF14 | musculo | FGFR1 | figado |
| FGF14 | musculo | FGFR1 | ilhotas |
| ACTR2 | figado | LDLR | ilhotas |
| ACTR2 | figado | LDLR | musculo |
| COL2A1 | musculo | ITGB1 | figado |
| COL2A1 | musculo | ITGB1 | ilhotas |
| LAMA1 | figado | ITGA7 | musculo |
| COL4A6 | musculo | ITGB1 | figado |
| COL4A6 | musculo | ITGB1 | ilhotas |
| SPP1 | figado | ITGA4 | adiposo |
| SPP1 | ilhotas | ITGA4 | adiposo |
| SPP1 | musculo | ITGA4 | adiposo |
| SPP1 | ilhotas | ITGA4 | figado |
| SPP1 | musculo | ITGA4 | figado |
| SPP1 | ilhotas | ITGB1 | figado |
| SPP1 | musculo | ITGB1 | figado |
| SPP1 | figado | ITGB1 | ilhotas |
| SPP1 | musculo | ITGB1 | ilhotas |
| CXCL12 | figado | ITGB1 | ilhotas |
| HSPA8 | musculo | LDLR | figado |
| HSPA8 | musculo | LDLR | ilhotas |
| BMP7 | ilhotas | BMPR1B | figado |
| CCN1 | ilhotas | ITGAM | figado |
| CCN1 | musculo | ITGAM | figado |
| HLA-B | musculo | CD3G | figado |
| LAMA2 | figado | ITGA7 | musculo |
| LAMA3 | adiposo | ITGA3 | ilhotas |
| LAMA3 | figado | ITGA3 | ilhotas |
| LAMA2 | figado | ITGA3 | ilhotas |
| LAMA1 | figado | ITGA3 | ilhotas |
| LAMC3 | figado | ITGA3 | ilhotas |
| LAMC3 | musculo | ITGA3 | ilhotas |
| THBS1 | musculo | ITGA3 | ilhotas |
| TIMP2 | musculo | ITGA3 | ilhotas |
| LAMB2 | figado | ITGA3 | ilhotas |
| LAMB2 | musculo | ITGA3 | ilhotas |
| LAMA5 | musculo | ITGA3 | ilhotas |
| LAMC1 | figado | ITGA3 | ilhotas |
| COL18A1 | musculo | ITGA3 | ilhotas |
| VTN | musculo | ITGA3 | ilhotas |
| HLA-G | musculo | CD4 | ilhotas |
| CXCL12 | figado | CD4 | ilhotas |
| SLPI | figado | CD4 | ilhotas |
| INHBA | ilhotas | TGFBR3 | figado |
| COL2A1 | musculo | TNFRSF10A | figado |
| LAMA1 | figado | ITGB8 | ilhotas |
| VTN | musculo | ITGB8 | ilhotas |
| COL4A1 | musculo | ITGB8 | ilhotas |
| GNAI2 | figado | OPRD1 | musculo |
| OPRD1 | musculo | GNAI2 | figado |
| HLA-B | musculo | CANX | figado |
| NGF | ilhotas | SORT1 | figado |
| BDNF | musculo | SORT1 | figado |
| LAMA1 | figado | NT5E | ilhotas |
| CALR | figado | HLA-F | musculo |
| COL1A2 | musculo | ITGAV | figado |
| COL4A6 | musculo | ITGAV | figado |
| SPP1 | ilhotas | ITGAV | figado |
| SPP1 | musculo | ITGAV | figado |
| PDGFB | ilhotas | ITGAV | figado |
| PDGFB | musculo | ITGAV | figado |
| ERBB2 | musculo | SEMA4D | figado |
| CCN1 | ilhotas | ITGAV | figado |
| CCN1 | musculo | ITGAV | figado |
| FGA | ilhotas | ITGAV | figado |
| FGB | ilhotas | ITGAV | figado |
| FBN1 | ilhotas | ITGAV | figado |
| COL4A1 | musculo | ITGAV | figado |
| IGFBP4 | ilhotas | LRP6 | figado |
| IGFBP4 | musculo | LRP6 | figado |
| PDGFA | figado | PDGFRB | ilhotas |
| COL1A2 | figado | FLT4 | musculo |
| CALR | figado | SCARF1 | musculo |
| BMP6 | ilhotas | ACVR1 | figado |
| BMP6 | musculo | ACVR1 | figado |
| GDF5 | musculo | ACVR1 | figado |
| TGFB2 | ilhotas | ACVR1 | figado |
| TGFB2 | musculo | ACVR1 | figado |
| GPC3 | ilhotas | CD81 | figado |
| GPC3 | musculo | CD81 | figado |
| COL18A1 | musculo | KDR | figado |
| GNAI2 | figado | ADRA2A | musculo |
| ADRA2A | musculo | GNAI2 | figado |
| CXCL12 | figado | ADRA2A | musculo |
| SEMA4D | figado | ERBB2 | musculo |
| BTC | figado | ERBB2 | musculo |
| FGF1 | figado | EGFR | musculo |
| FGF1 | ilhotas | EGFR | musculo |
| CAMP | adiposo | EGFR | musculo |
| VEGFA | figado | EGFR | musculo |
| APLN | ilhotas | ADRA2A | musculo |
| POMC | ilhotas | ADRA2A | musculo |
| CXCL10 | figado | ADRA2A | musculo |
| CXCL9 | figado | ADRA2A | musculo |
| ANXA1 | ilhotas | ADRA2A | musculo |
| COL4A6 | musculo | ITGA1 | figado |
| COL6A1 | adiposo | ITGA1 | figado |
| COL6A1 | musculo | ITGA1 | figado |
| COL5A1 | adiposo | ITGA1 | figado |
| COL5A1 | ilhotas | ITGA1 | figado |
| COL6A2 | musculo | ITGA1 | figado |
| COL2A1 | musculo | ITGA1 | figado |
| COL5A2 | adiposo | ITGA1 | figado |
| COL1A2 | musculo | ITGA1 | figado |
| COL4A1 | musculo | ITGA1 | figado |
| MDK | musculo | GPC2 | ilhotas |
| SPP1 | figado | ITGA5 | adiposo |
| SPP1 | ilhotas | ITGA5 | adiposo |
| SPP1 | musculo | ITGA5 | adiposo |
| CCN1 | ilhotas | ITGA5 | adiposo |
| CCN1 | musculo | ITGA5 | adiposo |
| FGA | ilhotas | ITGA5 | adiposo |
| FBN1 | ilhotas | ITGA5 | adiposo |
| ANGPT1 | ilhotas | ITGA5 | adiposo |
| COL18A1 | musculo | ITGA5 | adiposo |
| ANGPTL3 | figado | ITGA5 | adiposo |
| GNAI2 | figado | LHCGR | musculo |
| GNAS | figado | LHCGR | musculo |
| COL4A6 | musculo | ITGA2 | figado |
| LAMA2 | figado | ITGA2 | musculo |
| LAMA1 | figado | ITGA2 | musculo |
| LAMC3 | musculo | ITGA2 | figado |
| LAMC3 | figado | ITGA2 | musculo |
| COL6A1 | adiposo | ITGA2 | figado |
| COL6A1 | musculo | ITGA2 | figado |
| COL6A1 | adiposo | ITGA2 | musculo |
| COL11A1 | adiposo | ITGA2 | figado |
| COL11A1 | adiposo | ITGA2 | musculo |
| COL6A2 | musculo | ITGA2 | figado |
| COL2A1 | musculo | ITGA2 | figado |
| COL1A2 | musculo | ITGA2 | figado |
| COL1A2 | figado | ITGA2 | musculo |
| COL4A1 | musculo | ITGA2 | figado |
| COL7A1 | musculo | ITGA2 | figado |
| COL3A1 | musculo | ITGA2 | figado |
| PLG | ilhotas | F2RL1 | figado |
| PLG | musculo | F2RL1 | figado |
| PLG | musculo | F2RL1 | ilhotas |
| RIMS1 | musculo | SLC18A2 | figado |
| CALCA | ilhotas | ADRB2 | figado |
| POMC | ilhotas | ADRB2 | figado |
| HSPA8 | musculo | ADRB2 | figado |
| VIP | musculo | ADRB2 | figado |
| FSHB | musculo | ADRB2 | figado |
| GNAI2 | figado | P2RY12 | musculo |
| SEMA4D | musculo | MET | figado |
| SEMA4D | figado | MET | ilhotas |
| SEMA4D | musculo | MET | ilhotas |
| SEMA5A | musculo | MET | figado |
| SEMA5A | figado | MET | ilhotas |
| SEMA5A | musculo | MET | ilhotas |
| POMC | ilhotas | PTH1R | musculo |
| CALCA | ilhotas | PTH1R | musculo |
| CCN1 | ilhotas | CAV1 | figado |
| CCN1 | musculo | CAV1 | figado |
| CCN1 | musculo | CAV1 | ilhotas |
| PTGS2 | musculo | CAV1 | figado |
| PTGS2 | figado | CAV1 | ilhotas |
| PTGS2 | musculo | CAV1 | ilhotas |
| MMP12 | musculo | PLAUR | figado |
| MDK | musculo | SDC3 | ilhotas |
| MDK | ilhotas | SDC3 | musculo |
| LAMA2 | figado | RPSA | musculo |
| LAMA1 | figado | RPSA | musculo |
| LAMB2 | figado | RPSA | musculo |
| EDN2 | figado | KEL | musculo |
| VEGFA | figado | RET | musculo |
| BMP7 | ilhotas | ENG | figado |
| MEPE | musculo | PHEX | figado |
| MDK | musculo | SDC1 | ilhotas |
| MDK | ilhotas | SDC1 | musculo |
| SLIT2 | ilhotas | SDC1 | musculo |
| LAMA2 | figado | ITGB1 | ilhotas |
| LAMB2 | musculo | ITGB1 | figado |
| LAMB2 | figado | ITGB1 | ilhotas |
| LAMB2 | musculo | ITGB1 | ilhotas |
| MDK | ilhotas | ITGB1 | figado |
| MDK | musculo | ITGB1 | figado |
| MDK | musculo | ITGB1 | ilhotas |
| ANGPT1 | ilhotas | ITGB1 | figado |
| VEGFA | figado | ITGB1 | ilhotas |
| MDK | ilhotas | ITGA4 | adiposo |
| MDK | musculo | ITGA4 | adiposo |
| MDK | ilhotas | ITGA4 | figado |
| MDK | musculo | ITGA4 | figado |
| CCN1 | ilhotas | ITGB2 | musculo |
| SPON2 | ilhotas | ITGB2 | musculo |
| VEGFA | figado | SIRPA | ilhotas |
| SLIT2 | ilhotas | ROBO1 | figado |
| SLIT2 | ilhotas | DCC | musculo |
| RGMA | musculo | BMPR1B | figado |
| RGMA | musculo | BMPR1B | ilhotas |
| FGF21 | figado | FGFR2 | musculo |
| SPON2 | ilhotas | ITGAM | figado |
| PTN | figado | SDC3 | ilhotas |
| PTN | figado | SDC3 | musculo |
| PTN | ilhotas | SDC3 | musculo |
| TAX1BP3 | figado | ADGRB1 | musculo |
| PTGES2 | figado | PTGER2 | ilhotas |
| PTGIS | figado | PTGIR | ilhotas |
| SLITRK1 | figado | PTPRD | musculo |
| SLITRK1 | figado | PTPRS | musculo |
| SLITRK2 | figado | PTPRD | musculo |
| SLITRK2 | figado | PTPRS | musculo |
| SLITRK3 | figado | PTPRD | musculo |
| SLITRK5 | figado | PTPRS | musculo |
| SLITRK6 | musculo | PTPRS | figado |
| SLITRK6 | figado | PTPRS | musculo |
| DHCR24 | musculo | RORA | figado |
| UBASH3B | ilhotas | PPARA | figado |
| UBASH3B | ilhotas | PPARA | musculo |
| ANXA1 | ilhotas | DYSF | musculo |
| BMP6 | ilhotas | BMPR1B | figado |
| BMP6 | musculo | BMPR1B | figado |
| BMP6 | musculo | BMPR1B | ilhotas |
| BMP4 | figado | BMPR1B | ilhotas |
| BMP6 | ilhotas | BMPR1A | musculo |
| BMP7 | ilhotas | BMPR1A | musculo |
| CCN2 | ilhotas | ITGA5 | adiposo |
| COL5A1 | adiposo | SDC3 | ilhotas |
| COL5A1 | figado | SDC3 | ilhotas |
| COL5A1 | adiposo | SDC3 | musculo |
| COL5A1 | figado | SDC3 | musculo |
| COL5A1 | ilhotas | SDC3 | musculo |
| COL5A3 | musculo | SDC3 | ilhotas |
| CXCL10 | musculo | SDC4 | figado |
| FGB | ilhotas | ITGA5 | adiposo |
| FGG | ilhotas | ITGA5 | adiposo |
| FGG | musculo | ITGA5 | adiposo |
| FGG | ilhotas | ITGAV | figado |
| FGG | musculo | ITGAV | figado |
| GDF5 | musculo | ROR2 | figado |
| GNAI2 | figado | EDNRA | ilhotas |
| GNAI2 | figado | EGFR | musculo |
| HMGB1 | figado | SDC1 | ilhotas |
| HMGB1 | figado | SDC1 | musculo |
| LAMA1 | figado | ITGB1 | ilhotas |
| LAMA2 | figado | DAG1 | musculo |
| MMP9 | musculo | EPHB2 | figado |
| MMP9 | figado | EPHB2 | musculo |
| MYOC | ilhotas | FZD3 | figado |
| MYOC | ilhotas | FZD4 | figado |
| PLA2G10 | musculo | PLA2R1 | figado |
| RSPO3 | ilhotas | LRP6 | figado |
| WNT2 | ilhotas | FZD5 | figado |
| BMP6 | musculo | ACVRL1 | ilhotas |
| GDF3 | ilhotas | ACVR1B | figado |
| GDF3 | ilhotas | ACVR2B | figado |
| IL33 | ilhotas | IL1RAP | figado |
| IL33 | ilhotas | IL1RAP | musculo |
| LAMA1 | figado | DAG1 | musculo |
| LAMB2 | figado | DAG1 | musculo |
| LAMC1 | figado | DAG1 | musculo |
| WNT11 | ilhotas | FZD5 | figado |
| WNT11 | musculo | FZD5 | figado |
| WNT11 | musculo | FZD5 | ilhotas |
| COL1A1 | figado | SDC1 | ilhotas |
| COL1A1 | musculo | SDC1 | ilhotas |
| COL1A1 | figado | SDC1 | musculo |
| COL1A1 | ilhotas | SDC1 | musculo |
| THBS2 | ilhotas | SDC1 | musculo |
| DCN | ilhotas | TGFB1 | figado |
| DCN | figado | TGFB1 | ilhotas |
| DCN | figado | TGFB1 | musculo |
| DCN | ilhotas | TGFB1 | musculo |
| KL | figado | FGFR1 | ilhotas |
| COL1A2 | figado | SDC1 | ilhotas |
| COL1A2 | musculo | SDC1 | ilhotas |
| COL1A2 | figado | SDC1 | musculo |
| VEGFA | figado | EPHB2 | musculo |
| IGFBP3 | ilhotas | IGF1 | musculo |
| KLB | figado | FGFR1 | ilhotas |
| IGFBP4 | musculo | IGF1 | ilhotas |
| IGFBP4 | ilhotas | IGF1 | musculo |
| IGFBP5 | musculo | IGF1 | ilhotas |
| IGFBP5 | ilhotas | IGF1 | musculo |
| RSPO3 | ilhotas | WNT1 | figado |
| SFRP4 | figado | WNT7A | musculo |
| SFRP4 | ilhotas | WNT7A | musculo |
| SPARC | musculo | PDGFA | figado |
| SPARC | musculo | PDGFB | ilhotas |
| CD36 | figado | TLR4 | ilhotas |
| THBS1 | ilhotas | TGFB1 | figado |
| THBS1 | musculo | TGFB1 | figado |
| THBS1 | musculo | TGFB1 | ilhotas |
| THBS1 | ilhotas | TGFB1 | musculo |
| UBB | figado | TGFBR1 | musculo |
| UBC | figado | FGFR2 | musculo |
| UBC | figado | LDLR | ilhotas |
| UBC | figado | LDLR | musculo |
| UBB | figado | ERBB2 | musculo |
| UBC | figado | SMAD3 | ilhotas |
| PRSS2 | musculo | F2R | ilhotas |
| COL9A1 | musculo | SDC1 | ilhotas |
| TNR | musculo | SDC1 | ilhotas |
| IGFBP6 | musculo | IGF1 | ilhotas |
| COL9A1 | musculo | SDC4 | figado |
| TNR | musculo | SDC4 | figado |
| BMP4 | figado | ACVRL1 | ilhotas |
| GDF3 | ilhotas | BMPR1B | figado |
| GDF3 | ilhotas | BMPR1A | musculo |
| GDF3 | ilhotas | TGFBR1 | musculo |
| THBS1 | ilhotas | SIRPA | figado |
| THBS1 | musculo | SIRPA | figado |
| THBS1 | musculo | SIRPA | ilhotas |
| WNT11 | ilhotas | FZD4 | figado |
| WNT11 | musculo | FZD4 | figado |
| CTSG | figado | F2RL3 | musculo |
| PLG | ilhotas | F2RL3 | musculo |
| CTSG | figado | PARD3 | musculo |
| F2 | figado | PARD3 | musculo |
| PLG | ilhotas | PARD3 | musculo |
| COL2A1 | musculo | SDC1 | ilhotas |
| COL4A1 | musculo | SDC1 | ilhotas |
| COL4A2 | adiposo | SDC1 | ilhotas |
| COL4A2 | musculo | SDC1 | ilhotas |
| COL4A2 | adiposo | SDC1 | musculo |
| COL4A6 | musculo | SDC1 | ilhotas |
| COL6A1 | adiposo | SDC1 | ilhotas |
| COL6A1 | musculo | SDC1 | ilhotas |
| COL6A1 | adiposo | SDC1 | musculo |
| COL6A2 | musculo | SDC1 | ilhotas |
| COMP | musculo | SDC1 | ilhotas |
| COMP | ilhotas | SDC1 | musculo |
| COL1A1 | ilhotas | SDC4 | figado |
| COL1A1 | musculo | SDC4 | figado |
| COL1A2 | musculo | SDC4 | figado |
| COL2A1 | musculo | SDC4 | figado |
| COL4A1 | musculo | SDC4 | figado |
| COL4A2 | adiposo | SDC4 | figado |
| COL4A2 | musculo | SDC4 | figado |
| COL4A6 | musculo | SDC4 | figado |
| COL6A1 | adiposo | SDC4 | figado |
| COL6A1 | musculo | SDC4 | figado |
| COL6A2 | musculo | SDC4 | figado |
| THBS2 | ilhotas | SDC4 | figado |
| COMP | ilhotas | SDC4 | figado |
| COMP | musculo | SDC4 | figado |
| LAMA3 | adiposo | DAG1 | musculo |
| LAMA3 | figado | DAG1 | musculo |
| LAMC3 | figado | DAG1 | musculo |
| HLA-DOA | musculo | CD4 | ilhotas |
| HLA-DOB | musculo | CD4 | ilhotas |
| CYP11A1 | musculo | NR1H4 | figado |
| DHRS9 | musculo | PGR | figado |
| CYP17A1 | musculo | AR | figado |
| CYP17A1 | musculo | AR | ilhotas |
| HSD17B6 | musculo | NR1H4 | figado |
| CYP27B1 | musculo | VDR | ilhotas |
| DHCR24 | musculo | RORC | figado |
| UBASH3B | ilhotas | ESR1 | figado |
| UBASH3B | ilhotas | NR1I2 | figado |
| DHCR7 | figado | NR1H3 | ilhotas |
| SULT1E1 | musculo | PPARA | figado |
| SULT1E1 | musculo | PPARD | figado |
| SULT1E1 | musculo | PPARD | ilhotas |
| SULT2A1 | musculo | PPARA | figado |
| SULT2A1 | musculo | PPARD | figado |
| SULT2A1 | musculo | PPARD | ilhotas |
| SULT1A1 | musculo | PPARA | figado |
| SULT1A1 | figado | PPARA | musculo |
| SULT1A1 | musculo | PPARD | figado |
| SULT1A1 | figado | PPARD | ilhotas |
| SULT1A1 | musculo | PPARD | ilhotas |
| SRD5A1 | musculo | AR | figado |
| SRD5A1 | figado | AR | ilhotas |
| SRD5A1 | musculo | AR | ilhotas |
| SRD5A3 | figado | AR | ilhotas |
| CYP19A1 | ilhotas | ESR1 | figado |
| CYP19A1 | ilhotas | GPER1 | musculo |
| CYP19A1 | ilhotas | NR1I2 | figado |
| DDC | musculo | DRD1 | figado |
| DDC | musculo | DRD3 | figado |
| AKR1D1 | musculo | AR | figado |
| AKR1D1 | musculo | AR | ilhotas |
| HSD17B12 | figado | AR | ilhotas |
| HSD17B3 | musculo | AR | figado |
| HSD17B3 | musculo | AR | ilhotas |
| IL10 | ilhotas | SIRPG | musculo |
| LTF | musculo | GP9 | figado |
| TGFB1 | figado | CD109 | ilhotas |
| TGFB1 | musculo | CD109 | ilhotas |
| SFRP4 | ilhotas | WNT1 | figado |
| SFRP4 | musculo | WNT1 | figado |
| SFRP5 | ilhotas | WNT1 | figado |
| SFRP1 | ilhotas | WNT16 | figado |
| SFRP1 | ilhotas | WNT16 | musculo |
| SFRP2 | ilhotas | WNT16 | figado |
| SFRP2 | musculo | WNT16 | figado |
| SFRP2 | ilhotas | WNT16 | musculo |
| SFRP4 | ilhotas | WNT16 | figado |
| SFRP4 | musculo | WNT16 | figado |
| SFRP4 | figado | WNT16 | musculo |
| SFRP4 | ilhotas | WNT16 | musculo |
| SFRP5 | ilhotas | WNT16 | figado |
| SFRP5 | ilhotas | WNT16 | musculo |
| SFRP2 | musculo | WNT2 | ilhotas |
| SFRP4 | figado | WNT2 | ilhotas |
| SFRP4 | musculo | WNT2 | ilhotas |
| SFRP4 | ilhotas | WNT4 | figado |
| SFRP4 | musculo | WNT4 | figado |
| SFRP5 | ilhotas | WNT4 | figado |
| SFRP1 | ilhotas | WNT7A | musculo |
| SFRP2 | ilhotas | WNT7A | musculo |
| SFRP5 | ilhotas | WNT7A | musculo |
| SFRP1 | ilhotas | WNT9B | musculo |
| SFRP2 | ilhotas | WNT9B | musculo |
| SFRP4 | figado | WNT9B | musculo |
| SFRP4 | ilhotas | WNT9B | musculo |
| SFRP5 | ilhotas | WNT9B | musculo |
| MAPK1 | ilhotas | FGFR2 | figado |
| MAPK1 | figado | FGFR2 | musculo |
| MAPK1 | ilhotas | FGFR2 | musculo |
| UBC | figado | ERBB2 | musculo |
| UBB | figado | FGFR2 | musculo |
| UBB | figado | LDLR | ilhotas |
| UBB | figado | LDLR | musculo |
| UBB | figado | SMAD3 | ilhotas |
| UBB | figado | TLR4 | ilhotas |
| UBC | figado | TGFBR1 | musculo |
| UBC | figado | TLR4 | ilhotas |
| PORCN | figado | WNT16 | musculo |
| INHBA | ilhotas | TGFB1 | figado |
| INHBA | figado | TGFB1 | ilhotas |
| INHBA | figado | TGFB1 | musculo |
| INHBA | ilhotas | TGFB1 | musculo |
| DKK1 | adiposo | WNT16 | figado |
| DKK1 | musculo | WNT16 | figado |
| DKK1 | adiposo | WNT16 | musculo |
| PORCN | figado | WNT9B | musculo |
| LTBP1 | ilhotas | TGFB2 | figado |
| LTBP1 | ilhotas | TGFB2 | musculo |
| NOG | ilhotas | BMP6 | musculo |
| DCN | ilhotas | TGFB2 | figado |
| DCN | figado | TGFB2 | ilhotas |
| DCN | figado | TGFB2 | musculo |
| DCN | ilhotas | TGFB2 | musculo |
| INHBA | figado | TGFB3 | ilhotas |
| PORCN | figado | WNT2 | ilhotas |
| PORCN | figado | WNT7A | musculo |
| DKK1 | adiposo | WNT1 | figado |
| DKK1 | musculo | WNT1 | figado |
| DCN | figado | TGFB3 | ilhotas |
| INHBA | ilhotas | TGFB2 | figado |
| INHBA | figado | TGFB2 | ilhotas |
| INHBA | figado | TGFB2 | musculo |
| INHBA | ilhotas | TGFB2 | musculo |
| THBS1 | ilhotas | TGFB2 | figado |
| THBS1 | musculo | TGFB2 | figado |
| THBS1 | musculo | TGFB2 | ilhotas |
| THBS1 | ilhotas | TGFB2 | musculo |
| THBS1 | musculo | TGFB3 | ilhotas |
| INHBA | figado | GDF3 | ilhotas |
| IGFBP4 | ilhotas | WNT1 | figado |
| IGFBP4 | musculo | WNT1 | figado |
| RSPO4 | figado | WNT16 | musculo |
| RSPO3 | ilhotas | WNT16 | figado |
| RSPO3 | figado | WNT16 | musculo |
| RSPO3 | ilhotas | WNT16 | musculo |
| RSPO2 | figado | WNT16 | musculo |
| RSPO1 | figado | WNT16 | musculo |
| IGFBP4 | ilhotas | WNT16 | figado |
| IGFBP4 | musculo | WNT16 | figado |
| IGFBP4 | ilhotas | WNT16 | musculo |
| SERPINF1 | figado | WNT16 | musculo |
| SOST | figado | WNT16 | musculo |
| RSPO4 | figado | WNT2 | ilhotas |
| RSPO3 | figado | WNT2 | ilhotas |
| RSPO2 | figado | WNT2 | ilhotas |
| RSPO1 | figado | WNT2 | ilhotas |
| IGFBP4 | musculo | WNT2 | ilhotas |
| SERPINF1 | figado | WNT2 | ilhotas |
| DKK1 | adiposo | WNT2 | ilhotas |
| DKK1 | musculo | WNT2 | ilhotas |
| SOST | figado | WNT2 | ilhotas |
| RSPO3 | ilhotas | WNT4 | figado |
| IGFBP4 | ilhotas | WNT4 | figado |
| IGFBP4 | musculo | WNT4 | figado |
| DKK1 | adiposo | WNT4 | figado |
| DKK1 | musculo | WNT4 | figado |
| RSPO4 | figado | WNT7A | musculo |
| RSPO3 | figado | WNT7A | musculo |
| RSPO3 | ilhotas | WNT7A | musculo |
| RSPO2 | figado | WNT7A | musculo |
| RSPO1 | figado | WNT7A | musculo |
| IGFBP4 | ilhotas | WNT7A | musculo |
| SERPINF1 | figado | WNT7A | musculo |
| DKK1 | adiposo | WNT7A | musculo |
| SOST | figado | WNT7A | musculo |
| RSPO4 | figado | WNT9B | musculo |
| RSPO3 | figado | WNT9B | musculo |
| RSPO3 | ilhotas | WNT9B | musculo |
| RSPO2 | figado | WNT9B | musculo |
| RSPO1 | figado | WNT9B | musculo |
| IGFBP4 | ilhotas | WNT9B | musculo |
| SERPINF1 | figado | WNT9B | musculo |
| DKK1 | adiposo | WNT9B | musculo |
| SOST | figado | WNT9B | musculo |
| KLB | figado | FGFR2 | musculo |
| AGRP | musculo | POMC | ilhotas |

Figura: `docs/figuras/painel_rede.png`. Cada tecido vem de pessoas diferentes: as ligações são hipóteses de conhecimento prévio, não correlações observadas na mesma pessoa.
