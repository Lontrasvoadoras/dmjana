# Validação da etapa 09: programa das ilhotas com célula única

Gerado em 12/10/2026 12:27 a partir de `output/09_validacao_celula/`.

## 1. Onde os genes do programa são expressos (GSE221156, CPM médio por tipo, todas as doadoras)

| Gene | Tipo com maior expressão | Fração nesse tipo |
|---|---|---:|
| PCOLCE | estrelada | 0.91 |
| PEA15 | endotelial | 0.48 |
| ADAMTS3 | estrelada | 0.51 |
| THBS2 | estrelada | 0.98 |
| SLC16A1 | estrelada | 0.55 |
| ZEB2 | imune | 0.65 |
| SLIT2 | estrelada | 0.85 |
| RAB34 | estrelada | 0.64 |
| LTBP1 | estrelada | 0.80 |
| TGFB3 | estrelada | 0.92 |
| HGF | estrelada | 0.73 |
| APOD | estrelada | 0.93 |
| IL6 | estrelada | 0.93 |
| IGFBP4 | estrelada | 0.50 |
| SH2B3 | endotelial | 0.41 |

## 2. Composição verdadeira (GSE221156, mulheres de 40–60, % de células)

| Tipo | DM2 | ND | p (Wilcoxon) |
|---|---:|---:|---:|
| beta | 36.3 | 49.2 | 0,13 |
| alfa | 33.2 | 25.7 | 0,53 |
| delta | 3.6 | 5.6 | 0,27 |
| PP | 4.6 | 1.8 | 0,53 |
| ductal | 9.1 | 7.8 |   1 |
| acinar | 5.5 | 4.9 | 0,8 |
| estrelada | 5.1 | 3.0 | 0,53 |
| endotelial | 1.9 | 1.4 | 0,53 |
| imune | 0.5 | 0.6 | 0,8 |

## 3. Efeito do DM2 dentro de cada tipo celular (GSE221156)

| Tipo | Módulo | g | p | DM2/ND |
|---|---|---:|---:|---|
| beta | M6 | 0.90 | 0,3 | 2/4 |
| alfa | M6 | -1.33 | 0,13 | 2/4 |
| delta | M6 | -0.98 | 0,26 | 2/4 |
| ductal | M6 | -1.73 | 0,049 | 2/4 |
| acinar | M6 | -1.23 | 0,16 | 2/4 |
| estrelada | M6 | -1.39 | 0,11 | 2/4 |
| endotelial | M6 | -1.75 | 0,047 | 2/4 |

## 4. Deconvolução: teste no GSE221156 (composição conhecida)

| Tipo | Verdadeira (%) | Estimada (%) | Correlação | Erro médio (pp) |
|---|---:|---:|---:|---:|
| acinar | 5.8 | 5.9 | 0,89 | 1.7 |
| alfa | 30.6 | 31.0 | 0,77 | 5.9 |
| beta | 39.5 | 38.1 | 0,89 | 6.6 |
| delta | 4.2 | 4.2 | 0,89 | 0.8 |
| ductal | 10.7 | 10.6 | 0,93 | 2.0 |
| endotelial | 1.8 | 2.1 | 0,40 | 1.4 |
| estrelada | 4.9 | 4.8 | 0,74 | 2.0 |
| imune | 0.8 | 1.5 | -0,00 | 1.5 |
| PP | 1.8 | 1.8 | 0,96 | 0.4 |

## 5. Composição estimada DM2 x ND (meta-análise dos estudos de ilhotas, mulheres de 40–60)

| Tipo | Estudos | g (IC 95%) | p | Mesmo sentido |
|---|---:|---|---:|---|
| beta | 4 | -1.70 (-4.77 a 1.37) | 0,18 | 4/4 |
| alfa | 4 | 0.77 (-3.26 a 4.80) | 0,59 | 3/4 |
| delta | 4 | -0.51 (-1.70 a 0.68) | 0,27 | 3/4 |
| PP | 4 | 0.42 (-0.63 a 1.48) | 0,29 | 3/4 |
| ductal | 3 | 0.50 (-1.24 a 2.25) | 0,34 | 2/3 |
| acinar | 4 | 0.12 (-0.99 a 1.23) | 0,76 | 3/4 |
| estrelada | 4 | 0.64 (-0.46 a 1.74) | 0,16 | 4/4 |
| endotelial | 4 | 0.52 (-0.91 a 1.94) | 0,33 | 3/4 |
| imune | 3 | 0.25 (-1.98 a 2.47) | 0,68 | 2/3 |

## 6. Programa sem e com ajuste pela proporção de células estreladas (meta-análise)

| Módulo/gene | g sem ajuste | p | g com ajuste | p | Redução do efeito |
|---|---:|---:|---:|---:|---:|
| M6 | 1,05 | 0,11 | 0,71 | 0,24 | 33% |
| PCOLCE | 1,00 | 0,12 | 0,53 | 0,16 | 47% |
| PEA15 | 1,08 | 0,11 | 0,98 | 0,12 | 9% |
| ADAMTS3 | 1,19 | 0,22 | 1,14 | 0,19 | 4% |
| THBS2 | 1,46 | 0,06 | 0,97 | 0,11 | 34% |
| SLC16A1 | 0,76 | 0,17 | 0,48 | 0,3 | 36% |
| ZEB2 | 0,84 | 0,13 | 0,48 | 0,21 | 43% |
| SLIT2 | 1,18 | 0,12 | 0,79 | 0,27 | 33% |
| RAB34 | 1,09 | 0,096 | 0,83 | 0,12 | 24% |
| LTBP1 | 1,03 | 0,086 | 0,74 | 0,099 | 28% |
| TGFB3 | 0,83 | 0,16 | 0,62 | 0,21 | 26% |
| HGF | 0,85 | 0,14 | 0,62 | 0,2 | 27% |
| APOD | 1,29 | 0,081 | 1,24 | 0,079 | 4% |
| IL6 | 1,56 | 0,058 | 1,50 | 0,058 | 4% |
| IGFBP4 | 0,84 | 0,14 | 0,54 | 0,19 | 36% |
| SH2B3 | 0,74 | 0,17 | 0,58 | 0,3 | 23% |

Modelo com a variância estimada em todas as amostras do estudo (o contraste continua sendo só mulheres de 40–60, DM2 × ND), para haver graus de liberdade para a covariável. Sem e com ajuste comparados nos MESMOS estudos (GSE221156, GSE41762, GSE76895); o GSE86469 (8 amostras) não comporta a covariável. Na tabela CSV, g_sem_todos_estudos traz o efeito sem ajuste com os 4 estudos.
