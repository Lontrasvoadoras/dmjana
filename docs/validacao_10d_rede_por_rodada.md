# Validação da etapa 10d: ROC com a rede refeita em cada rodada

Gerado em 12/10/2026 12:36.

Em cada rodada, a rede de coexpressão é refeita sem o estudo (ou a parte) testado e sem o estudo externo; o módulo e os genes seguem a regra da etapa 10.

| Tecido | Tipo | Testado | Rede construída com | Módulo (genes) | Parecido com (etapa 06; Jaccard) | AUC (IC 95%) | AUC com a rede única |
|---|---|---|---|---|---|---|---:|
| ilhotas | deixar um estudo de fora | GSE41762 | GSE221156;GSE76895 | M23 (68) | M6 (0,03) | 0,67 (0,36 a 0,97) | 0,69 |
| ilhotas | deixar um estudo de fora | GSE221156 | GSE41762;GSE76895 | M7 (215) | M6 (0,48) | 0,62 (0,00 a 1,00) | 0,50 |
| ilhotas | deixar um estudo de fora | GSE76895 | GSE41762;GSE221156 | M11 (215) | M6 (0,34) | 1,00 (1,00 a 1,00) | 1,00 |
| ilhotas | deixar um estudo de fora | GSE86469 | GSE41762;GSE221156;GSE76895 | M6 (188) | M6 (1,00) | 1,00 (1,00 a 1,00) | 1,00 |
| musculo | deixar um estudo de fora | GSE18732 | GSE25462 | M2 (845) | M6 (0,01) | 0,50 (0,22 a 0,78) | 0,56 |
| musculo | deixar um estudo de fora | GSE25462 | GSE18732 | M8 (103) | M4 (0,10) | 0,67 (0,25 a 1,00) | 0,25 |
| musculo | externo | GSE21340 | GSE18732;GSE25462 | M4 (259) | M4 (1,00) | 0,53 (0,06 a 1,00) | 0,53 |
| sangue | deixar um estudo de fora | GSE184050 | GSE250283;GSE156993 | M1 (211) | NA (-) | 0,47 (0,20 a 0,75) | 0,46 |
| sangue | deixar um estudo de fora | GSE250283 | GSE184050;GSE156993 | M45 (32) | NA (-) | 0,25 (0,00 a 0,57) | 0,25 |
| sangue | deixar um estudo de fora | GSE249102 | GSE184050;GSE250283;GSE156993 | M8 (290) | NA (-) | 0,00 (0,00 a 0,00) | 0,00 |
| sangue | externo | GSE156993 | GSE184050;GSE250283 | M19 (49) | NA (-) | 0,70 (0,28 a 1,00) | 0,90 |
| sangue | externo | GSE189005 | GSE184050;GSE250283 | M19 (49) | NA (-) | 0,36 (0,00 a 0,77) | 0,28 |
| figado | validação cruzada (parte) | GSE130991 parte 1 | GSE130991 sem a parte 1 | M3 (784) | M6 (0,06) | 0,64 (0,46 a 0,83) | - |
| figado | validação cruzada (parte) | GSE130991 parte 2 | GSE130991 sem a parte 2 | M4 (491) | M6 (0,00) | 0,57 (0,36 a 0,78) | - |
| figado | validação cruzada (parte) | GSE130991 parte 3 | GSE130991 sem a parte 3 | M5 (335) | M6 (0,28) | 0,68 (0,51 a 0,85) | - |
| figado | validação cruzada (parte) | GSE130991 parte 4 | GSE130991 sem a parte 4 | M10 (52) | M6 (0,00) | 0,88 (0,76 a 0,99) | - |
| figado | validação cruzada (parte) | GSE130991 parte 5 | GSE130991 sem a parte 5 | M3 (636) | M6 (0,08) | 0,75 (0,57 a 0,92) | - |
| figado | validação cruzada (partes reunidas) | GSE130991 | partes de treino | NA (NA) | NA (-) | 0,69 (0,61 a 0,77) | 0,66 |
| figado | externo | GSE15653 | GSE130991 | M4 (556) | M15 (0,06) | 0,33 (0,00 a 0,84) | 0,50 |

| Tecido | AUC combinada com rede por rodada (IC 95%) | p | AUC combinada com a rede única | Rodadas com módulo parecido (Jaccard >= 0,3) com um selecionado |
|---|---|---:|---:|---|
| ilhotas | 0,70 (0,30 a 0,93) | 0,21 | 0,69 | 3/4 |
| musculo | 0,54 (0,00 a 1,00) | 0,77 | 0,44 | 0/2 |
| sangue | 0,39 (0,10 a 0,78) | 0,38 | 0,38 | 0/3 |
