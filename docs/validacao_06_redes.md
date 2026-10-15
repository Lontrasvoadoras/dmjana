# Validação da etapa 06: redes de coexpressão (WGCNA)

Gerado em 12/10/2026 12:20 a partir de `output/06_redes/`.

## 1. Redes por tecido

| Tecido | Estudos que constroem | Lote retirado | Genes | Potência | Módulos | Preservados | Significativos | Sugestivos | Exploratórios | Genes-chave |
|---|---|---|---:|---|---:|---:|---:|---:|---:|---:|
| adiposo | GSE200678;GSE133666;GSE198922 | - | 8000 | 12 (R² livre de escala) | 12 | 12 | 0 | 0 | 0 | 0 |
| figado | GSE130991;GSE15653 | GSE15653 | 8000 | 18 (R² livre de escala) | 16 | 16 | 0 | 2 | 0 | 58 |
| ilhotas | GSE41762;GSE221156;GSE76895 | GSE41762;GSE76895 | 8000 | 16 (R² livre de escala) | 17 | 17 | 0 | 0 | 1 | 35 |
| musculo | GSE18732;GSE25462 | GSE18732;GSE25462 | 8000 | 12 (R² < 0.80 em algum estudo: potência padrão da WGCNA para n = 48) | 13 | 13 | 0 | 0 | 2 | 75 |
| sangue | GSE184050;GSE250283;GSE156993 | GSE156993 | 8000 | 16 (R² livre de escala) | 16 | 15 | 0 | 0 | 0 | 0 |

## 2. Módulos (efeito do DM2 nas mulheres de 40–60, Hartung-Knapp)

Testes: Hartung-Knapp (principal); Stouffer ponderado (soma a evidência); rOP r = 2 (efeito em pelo menos 2 estudos, mesmo sentido nos 2 mais fortes); heterogeneidade (Cochran Q).

| Tecido | Módulo | Genes | Preservação | g (IC 95%) | p HK | FDR HK | p Stouffer | p rOP (≥ 2) | FDR rOP | p heterog. | Mesmo sentido | Seleção | Genes centrais |
|---|---|---:|---|---|---:|---:|---:|---:|---:|---:|---|---|---|
| adiposo | M12 | 59 | preservado em 3 de 3 estudos | 0.74 (-0.53 a 2.01) | 0,16 | 0,84 | 0,059 | 0,63 |   1 | 0,4 | 3/4 | - | KLF9, ZFAND5, TIPARP, ERRFI1, SLC19A2 |
| adiposo | M4 | 960 | preservado em 3 de 3 estudos | -0.68 (-1.97 a 0.61) | 0,19 | 0,84 | 0,092 | 0,83 |   1 | 0,44 | 3/4 | - | FABP4, ETFB, GPX4, MPC2, MTARC1 |
| adiposo | M11 | 70 | preservado em 2 de 3 estudos | 0.37 (-0.89 a 1.64) | 0,42 | 0,84 | 0,33 | 0,93 |   1 | 0,63 | 3/4 | - | PGK1, GALM, SGPP1, ATP6V1A, PLEKHO2 |
| adiposo | M10 | 82 | preservado em 2 de 3 estudos | -0.35 (-1.62 a 0.92) | 0,45 | 0,84 | 0,4 | 0,89 |   1 | 0,72 | 3/4 | - | ZMPSTE24, PPIL1, LGALS8, PPP1CC, GALNT1 |
| adiposo | M1 | 1147 | preservado em 3 de 3 estudos | -0.30 (-1.57 a 0.97) | 0,5 | 0,84 | 0,45 | 0,89 |   1 | 0,7 | 2/4 | - | YWHAG, ITPK1, INPP5K, MTCH2, DHDDS |
| adiposo | M8 | 136 | preservado em 3 de 3 estudos | -0.32 (-1.98 a 1.34) | 0,58 | 0,84 | 0,36 |   1 |   1 | 0,18 | 2/4 | - | ACSS3, SIK2, NET1, EIF4EBP2, ACVR1C |
| adiposo | M2 | 1089 | preservado em 3 de 3 estudos | 0.22 (-1.05 a 1.50) | 0,62 | 0,84 | 0,6 |   1 |   1 | 0,5 | 2/4 | - | DOCK2, FYB1, DOK2, TYROBP, LCP2 |
| adiposo | M7 | 243 | preservado em 2 de 3 estudos | 0.21 (-1.06 a 1.48) | 0,64 | 0,84 | 0,61 |   1 |   1 | 0,78 | 2/4 | - | HSPG2, TNRC18, FURIN, NOTCH1, PKD1 |
| adiposo | M9 | 111 | preservado em 3 de 3 estudos | -0.20 (-1.46 a 1.07) | 0,65 | 0,84 | 0,63 | 0,97 |   1 | 0,9 | 3/4 | - | RPL32, RPL31, RPS5, RPL35A, RPS21 |
| adiposo | M6 | 650 | preservado em 3 de 3 estudos | -0.20 (-1.67 a 1.28) | 0,7 | 0,84 | 0,59 |   1 |   1 | 0,27 | 2/4 | - | GHITM, ADH5, TFB2M, VAMP7, DNAJA2 |
| adiposo | M5 | 927 | preservado em 3 de 3 estudos | -0.05 (-1.32 a 1.21) | 0,9 | 0,94 | 0,92 |   1 |   1 | 0,86 | 3/4 | - | MCTP2, ISYNA1, ZDHHC15, EXOSC8, DPY19L3 |
| adiposo | M3 | 1051 | preservado em 3 de 3 estudos | 0.03 (-1.24 a 1.30) | 0,94 | 0,94 | 0,96 |   1 |   1 | 0,82 | 2/4 | - | CDON, GLI3, SULF1, ITPR3, CLDN1 |
| figado | M6 | 238 | preservado em 2 de 2 estudos | 0.42 (0.11 a 0.72) | 0,0075 | 0,091 | - | - | - | - | 1/1 | sugestivo | YIF1A, COPE, IDH3G, P4HB, PPP1CA |
| figado | M15 | 54 | preservado em 2 de 2 estudos | 0.39 (0.09 a 0.70) | 0,011 | 0,091 | - | - | - | - | 1/1 | sugestivo | COPB2, SEC24A, COPB1, SEC23A, SSR1 |
| figado | M10 | 110 | preservado em 2 de 2 estudos | 0.19 (-0.12 a 0.49) | 0,23 |   1 | - | - | - | - | 1/1 | - | FBLN5, PMP22, COL6A3, DPT, C7 |
| figado | M5 | 256 | preservado em 2 de 2 estudos | 0.16 (-0.14 a 0.47) | 0,3 |   1 | - | - | - | - | 1/1 | - | PSMD6, TXNL1, CDC123, STRAP, PPP2CA |
| figado | M13 | 70 | preservado em 2 de 2 estudos | 0.12 (-0.18 a 0.43) | 0,43 |   1 | - | - | - | - | 1/1 | - | IQGAP1, IFI16, EVI2B, SH3BGRL, GLIPR1 |
| figado | M16 | 50 | preservado em 2 de 2 estudos | 0.11 (-0.20 a 0.41) | 0,49 |   1 | - | - | - | - | 1/1 | - | NUP155, RAB2A, CHM, NBAS, YARS2 |
| figado | M14 | 59 | preservado em 2 de 2 estudos | 0.07 (-0.24 a 0.37) | 0,66 |   1 | - | - | - | - | 1/1 | - | RPP30, ERCC4, TPP2, SUPT16H, DDX10 |
| figado | M9 | 185 | preservado em 2 de 2 estudos | 0.06 (-0.24 a 0.37) | 0,69 |   1 | - | - | - | - | 1/1 | - | MRPL28, MFSD10, CHMP1A, DGKZ, ACTR1B |
| figado | M3 | 274 | preservado em 2 de 2 estudos | 0.05 (-0.25 a 0.36) | 0,73 |   1 | - | - | - | - | 1/1 | - | UTP20, ZCCHC4, MTAP, NEK1, PIK3C3 |
| figado | M7 | 236 | preservado em 2 de 2 estudos | 0.05 (-0.26 a 0.35) | 0,76 |   1 | - | - | - | - | 1/1 | - | GUK1, AURKAIP1, PUF60, FIS1, NDUFS7 |
| figado | M11 | 88 | preservado em 2 de 2 estudos | 0.03 (-0.27 a 0.33) | 0,85 |   1 | - | - | - | - | 1/1 | - | CDKL3, GART, CAMKMT, DIS3, DNAJC16 |
| figado | M8 | 196 | preservado em 2 de 2 estudos | -0.02 (-0.33 a 0.28) | 0,89 |   1 | - | - | - | - | 1/1 | - | KCNN1, RABL6, KIF18B, MUC5AC, GFRA4 |
| figado | M2 | 326 | preservado em 2 de 2 estudos | 0.02 (-0.29 a 0.32) | 0,91 |   1 | - | - | - | - | 1/1 | - | CRBN, GOSR1, TNPO1, LRPPRC, NOL11 |
| figado | M4 | 270 | preservado em 2 de 2 estudos | -0.01 (-0.32 a 0.29) | 0,93 |   1 | - | - | - | - | 1/1 | - | ARHGAP33, CARD10, MAPK8IP2, IZUMO4, GRIN1 |
| figado | M1 | 1124 | preservado em 2 de 2 estudos | 0.00 (-0.30 a 0.31) | 0,99 |   1 | - | - | - | - | 1/1 | - | CUL5, SACM1L, DMXL1, ORC4, GNPAT |
| figado | M12 | 73 | preservado em 2 de 2 estudos | -0.00 (-0.30 a 0.30) |   1 |   1 | - | - | - | - | 1/1 | - | SRPK3, MAPK11, XRCC3, COL9A2, AQP5 |
| ilhotas | M6 | 188 | preservado em 3 de 3 estudos | 1.27 (0.00 a 2.53) | 0,05 | 0,77 | 0,00024 | 0,072 |   1 | 0,32 | 4/4 | exploratório | PRRX1, SLFN11, SPON1, FBLN1, CCDC80 |
| ilhotas | M4 | 264 | preservado em 3 de 3 estudos | 0.90 (-0.26 a 2.05) | 0,09 | 0,77 | 0,014 | 0,56 |   1 | 0,75 | 4/4 | - | BGN, COL6A3, FBN1, COL15A1, SPARC |
| ilhotas | M2 | 1930 | preservado em 3 de 3 estudos | -0.57 (-1.75 a 0.61) | 0,22 | 0,93 | 0,12 | 0,54 |   1 | 0,39 | 3/4 | - | PNMA2, DACH1, NRXN1, SH3GL2, EPB41L3 |
| ilhotas | M10 | 147 | preservado em 3 de 3 estudos | 0.44 (-0.69 a 1.57) | 0,3 | 0,93 | 0,18 | 0,64 |   1 | 0,72 | 3/4 | - | MMRN2, CDH5, PECAM1, TIE1, CLEC14A |
| ilhotas | M11 | 99 | preservado em 3 de 3 estudos | 0.71 (-1.64 a 3.06) | 0,41 | 0,93 | 0,12 | 0,72 |   1 | 0,067 | 3/4 | - | VAMP8, IMPDH2, RPL10, NOB1, RPL18A |
| ilhotas | M1 | 2290 | preservado em 3 de 3 estudos | 0.42 (-1.08 a 1.92) | 0,43 | 0,93 | 0,17 | 0,74 |   1 | 0,21 | 2/4 | - | PTPRK, TMEM63A, CLMN, ERBB2, ATP8B1 |
| ilhotas | M15 | 62 | preservado em 3 de 3 estudos | 0.31 (-0.82 a 1.44) | 0,44 | 0,93 | 0,33 | 0,69 |   1 | 0,62 | 2/4 | - | KLK1, CTRL, CTRC, PLA2G1B, CPA2 |
| ilhotas | M8 | 170 | preservado em 2 de 3 estudos | -0.67 (-3.69 a 2.34) | 0,53 | 0,93 | 0,13 |   1 |   1 | 0,03 | 3/4 | - | HES5, KLHL17, ZFPM1, CBARP, TCF15 |
| ilhotas | M7 | 180 | preservado em 3 de 3 estudos | -0.86 (-5.41 a 3.69) | 0,59 | 0,93 | 0,85 |   1 |   1 | 0,00021 | 3/4 | - | UTP20, HEATR1, XPO5, ZPR1, BYSL |
| ilhotas | M14 | 74 | preservado em 3 de 3 estudos | -0.30 (-1.93 a 1.32) | 0,6 | 0,93 | 0,4 |   1 |   1 | 0,19 | 2/4 | - | KNL1, CCNA2, TPX2, NUSAP1, PBK |
| ilhotas | M3 | 765 | preservado em 3 de 3 estudos | -0.42 (-3.30 a 2.46) | 0,68 | 0,93 | 0,36 |   1 |   1 | 0,031 | 2/4 | - | UBR2, TTC21B, MACF1, MON2, RNF20 |
| ilhotas | M17 | 40 | preservado em 3 de 3 estudos | -0.20 (-1.80 a 1.39) | 0,71 | 0,93 | 0,74 |   1 |   1 | 0,19 | 3/4 | - | EPS8L3, CEACAM6, TFF1, FAM3D, FOLR1 |
| ilhotas | M12 | 99 | preservado em 3 de 3 estudos | 0.41 (-2.91 a 3.73) | 0,72 | 0,93 | 0,51 |   1 |   1 | 0,02 | 1/4 | - | SNRPD2, ROMO1, COX7A2, LSM2, C12orf57 |
| ilhotas | M5 | 229 | preservado em 3 de 3 estudos | 0.26 (-2.36 a 2.88) | 0,77 | 0,93 | 0,77 |   1 |   1 | 0,014 | 2/4 | - | PRAF2, TCTA, LDOC1, RHBDD2, APBB1 |
| ilhotas | M16 | 53 | preservado em 3 de 3 estudos | -0.09 (-1.23 a 1.05) | 0,82 | 0,93 | 0,73 |   1 |   1 | 0,51 | 1/4 | - | GRN, PIGT, GPAA1, P4HTM, CTSA |
| ilhotas | M9 | 164 | preservado em 2 de 3 estudos | -0.09 (-3.17 a 2.98) | 0,91 | 0,97 | 0,69 |   1 |   1 | 0,076 | 2/3 | - | HES4, EXTL1, AMZ1, PNCK, NOXO1 |
| ilhotas | M13 | 83 | preservado em 3 de 3 estudos | -0.01 (-2.29 a 2.26) | 0,99 | 0,99 | 0,84 |   1 |   1 | 0,03 | 2/4 | - | LAPTM5, ITGB2, CD53, CD300A, EVI2B |
| musculo | M4 | 259 | preservado em 2 de 2 estudos | -1.11 (-6.05 a 3.82) | 0,21 | 0,86 | 0,0057 | 0,19 |   1 | 0,68 | 2/2 | exploratório (efeito fixo, 2 estudos) | MRPL15, NDUFA8, SUCLG1, OXSM, NDUFAF4 |
| musculo | M6 | 243 | preservado em 2 de 2 estudos | 0.83 (-4.46 a 6.12) | 0,3 | 0,86 | 0,049 | 0,4 |   1 | 0,62 | 2/2 | exploratório (efeito fixo, 2 estudos) | ISYNA1, HNF4A, SBNO2, TTC38, CTU2 |
| musculo | M8 | 156 | preservado em 2 de 2 estudos | -0.61 (-5.30 a 4.08) | 0,35 | 0,86 | 0,11 | 0,8 |   1 | 0,43 | 2/2 | - | ACAP1, SOX15, CIMAP1B, DLG4, ADAMTS10 |
| musculo | M1 | 4153 | preservado em 2 de 2 estudos | -0.63 (-6.16 a 4.90) | 0,39 | 0,86 | 0,16 | 0,37 |   1 | 0,76 | 2/2 | - | EXOC1, NUP133, FBXO28, SPTLC1, SEC63 |
| musculo | M7 | 213 | preservado em 2 de 2 estudos | -0.30 (-6.92 a 6.32) | 0,66 | 0,86 | 0,39 |   1 |   1 | 0,22 | 1/2 | - | ELOVL5, ANXA1, NOTCH2, ASAP2, ECM2 |
| musculo | M13 | 47 | preservado em 2 de 2 estudos | 0.35 (-7.92 a 8.63) | 0,68 | 0,86 | 0,29 |   1 |   1 | 0,13 | 1/2 | - | CDK13, ZNF160, CCDC152, FBXW12, ZNF721 |
| musculo | M2 | 861 | preservado em 2 de 2 estudos | -0.49 (-13.03 a 12.05) | 0,71 | 0,86 | 0,058 |   1 |   1 | 0,015 | 1/2 | - | MRPL4, RPUSD3, MECR, ERCC1, SLC35A4 |
| musculo | M10 | 134 | preservado em 2 de 2 estudos | 0.41 (-10.38 a 11.21) | 0,71 | 0,86 | 0,12 |   1 |   1 | 0,037 | 1/2 | - | CARMIL3, IGH, ARHGAP30, PDLIM4, TUT1 |
| musculo | M9 | 143 | preservado em 2 de 2 estudos | -0.49 (-13.34 a 12.36) | 0,71 | 0,86 | 0,059 |   1 |   1 | 0,013 | 1/2 | - | SHE, TES, CARD16, HIC1, TGS1 |
| musculo | M12 | 60 | preservado em 2 de 2 estudos | 0.20 (-5.48 a 5.88) | 0,73 | 0,86 | 0,64 | 0,94 |   1 | 0,77 | 2/2 | - | GPD2, UBE2E3, ASPH, SOS2, FGF13 |
| musculo | M5 | 255 | preservado em 2 de 2 estudos | -0.13 (-5.15 a 4.90) | 0,8 | 0,86 | 0,75 |   1 |   1 | 0,33 | 1/2 | - | KMT2D, KEAP1, FAM50A, LONP1, TADA3 |
| musculo | M3 | 276 | preservado em 2 de 2 estudos | 0.22 (-9.42 a 9.87) | 0,82 | 0,86 | 0,92 |   1 |   1 | 0,061 | 1/2 | - | TRIR, ADRM1, PNPLA6, PTOV1, TRIP10 |
| musculo | M11 | 119 | preservado em 2 de 2 estudos | -0.16 (-9.16 a 8.84) | 0,86 | 0,86 | 0,5 |   1 |   1 | 0,1 | 1/2 | - | EPOR, PSG5, GJB4, SNX32, GLP1R |
| sangue | M10 | 223 | preservado em 3 de 3 estudos | -0.55 (-1.92 a 0.82) | 0,23 | 0,99 | 0,09 | 0,53 |   1 | 0,6 | 3/3 | - | MS4A1, BANK1, KLHL14, CD19, TSPAN13 |
| sangue | M9 | 249 | preservado em 3 de 3 estudos | -0.43 (-1.80 a 0.94) | 0,31 | 0,99 | 0,18 | 0,68 |   1 | 0,62 | 3/3 | - | LEF1, CCR7, ABLIM1, CHMP7, MAL |
| sangue | M15 | 48 | preservado em 2 de 3 estudos | -0.40 (-1.78 a 0.97) | 0,33 | 0,99 | 0,21 | 0,46 |   1 | 0,54 | 3/3 | - | IL1R2, MANSC1, TNFRSF10C, MME, MGAM |
| sangue | M8 | 290 | não preservado | -0.35 (-1.72 a 1.02) | 0,39 | 0,99 | 0,26 | 0,63 |   1 | 0,43 | 2/3 | - | SLC19A3, NR2E1, ROBO4, ADAMTS4, PRDM6 |
| sangue | M5 | 499 | preservado em 3 de 3 estudos | -0.31 (-1.68 a 1.06) | 0,43 | 0,99 | 0,32 | 0,8 |   1 | 0,96 | 3/3 | - | PROS1, XK, PBX1, CMTM5, VCL |
| sangue | M11 | 170 | preservado em 3 de 3 estudos | 0.20 (-1.17 a 1.57) | 0,6 | 0,99 | 0,51 |   1 |   1 | 0,45 | 2/3 | - | MYH9, RNF40, ITGA5, LAMP1, UNC13D |
| sangue | M1 | 1153 | preservado em 3 de 3 estudos | -0.16 (-1.53 a 1.21) | 0,66 | 0,99 | 0,63 | 0,67 |   1 | 0,56 | 2/3 | - | GLT1D1, PLXNC1, PFKFB4, KIF13A, PTAFR |
| sangue | M6 | 360 | preservado em 3 de 3 estudos | -0.16 (-1.70 a 1.39) | 0,7 | 0,99 | 0,73 | 0,91 |   1 | 0,32 | 2/3 | - | NDUFA6, GTF2B, PRDX4, SEC61B, PSMA2 |
| sangue | M2 | 725 | preservado em 3 de 3 estudos | -0.22 (-2.43 a 1.99) | 0,71 | 0,99 | 0,76 |   1 |   1 | 0,19 | 1/3 | - | SACS, RPL37A, RPL35, ZNF92, EEF1G |
| sangue | M7 | 344 | preservado em 3 de 3 estudos | 0.23 (-2.59 a 3.06) | 0,76 | 0,99 | 0,32 |   1 |   1 | 0,075 | 2/3 | - | TGFBR3, AKNA, PPP2R2B, GFI1, PRSS23 |
| sangue | M16 | 40 | preservado em 2 de 3 estudos | 0.12 (-2.05 a 2.30) | 0,83 | 0,99 | 0,91 |   1 |   1 | 0,14 | 2/3 | - | MYBPC1, AGBL4, CYGB, SERINC2, GPR50 |
| sangue | M4 | 525 | preservado em 3 de 3 estudos | -0.07 (-1.44 a 1.30) | 0,84 | 0,99 | 0,83 |   1 |   1 | 0,68 | 2/3 | - | LENG8, SPTAN1, EP400, SAFB2, FOXK1 |
| sangue | M14 | 58 | preservado em 2 de 3 estudos | -0.11 (-2.20 a 1.98) | 0,85 | 0,99 | 0,62 |   1 |   1 | 0,16 | 2/3 | - | GATA2, NTRK1, EPAS1, SLC45A3, AKAP12 |
| sangue | M13 | 60 | preservado em 2 de 3 estudos | -0.01 (-1.38 a 1.36) | 0,97 | 0,99 | 0,98 |   1 |   1 | 0,57 | 2/3 | - | MYO1C, LCOR, HSD17B7, DAPP1, SLC25A16 |
| sangue | M3 | 698 | preservado em 3 de 3 estudos | -0.01 (-1.38 a 1.36) | 0,98 | 0,99 |   1 |   1 |   1 | 0,44 | 2/3 | - | RNPEPL1, STXBP2, MGRN1, TMEM127, ABCD1 |
| sangue | M12 | 115 | preservado em 3 de 3 estudos | -0.01 (-3.02 a 3.00) | 0,99 | 0,99 | 0,31 |   1 |   1 | 0,025 | 2/3 | - | GBP1, RSAD2, IFIT3, PARP9, STAT1 |

Figura: `docs/figuras/redes_modulos.png`.

### Influência de cada estudo nos módulos selecionados

| Tecido | Módulo | Estudo | g do estudo | Peso (%) | g sem o estudo | p sem o estudo | Inverte sentido | Muda conclusão (p < 0,05) |
|---|---|---|---:|---:|---:|---:|---|---|
| ilhotas | M6 | GSE41762 | 1.77 | 41.0 | 0.91 | 0,21 | não | sim |
| ilhotas | M6 | GSE221156 | 0.27 | 23.6 | 1.59 | 0,06 | não | sim |
| ilhotas | M6 | GSE76895 | 1.85 | 20.5 | 1.06 | 0,17 | não | sim |
| ilhotas | M6 | GSE86469 | 0.66 | 14.9 | 1.35 | 0,11 | não | sim |
| musculo | M4 | GSE18732 | -1.23 | 66.9 | -0.89 | 0,19 | não | não |
| musculo | M6 | GSE18732 | 0.99 | 61.9 | 0.56 | 0,4 | não | não |
| musculo | M4 | GSE25462 | -0.89 | 33.1 | -1.23 | 0,014 | não | sim |
| musculo | M6 | GSE25462 | 0.56 | 38.1 | 0.99 | 0,068 | não | não |

## 3. Genes-chave dos módulos selecionados

168 genes-chave. Lista completa em `output/06_redes/<tecido>/genes_chave.csv`.

| Tecido | Módulo | Seleção | Sentido | Genes (kME mín. ≥ 0,7) |
|---|---|---|---|---|
| figado | M15 | sugestivo | maior no DM2 | COPB2, SEC24A, COPB1, SEC23A, SSR1, ACBD3, TIMM17A, CLTC, PGM3, TPD52, ARF4, RAB6A, MORF4L2, TMED2, CANX, SEL1L, CCT6A, ARCN1, TRAM1, FAM98A, TMX2 |
| figado | M6 | sugestivo | maior no DM2 | YIF1A, COPE, IDH3G, P4HB, PPP1CA, PIGT, YIPF3, PSMD8, FIBP, DPP3, LRRC41, PPIB, PEMT, DHRS7B, MRPS11, VCP, USE1, TST, ACO2, GAPDH, ALG3, ENO1, COQ4, CRAT, SMPD1, ATP6V0B, ELAC2, POLR2E, CTSA, DDX56 |
| ilhotas | M6 | exploratório | maior no DM2 | PRRX1, SLC16A1, GFPT2, PDGFRA, ZEB2, RAB34, SLIT2, SMIM3, THBS2, DUSP6, PMP22, PTGER2, PTGDS, MEDAG, LTBP1, IGFBP4, IL6, TWIST2, KCNE4, SCARA3, GAS7, HGF, TGFB3, GNG11, MRGPRF, SH2B3, SPON1, CCDC80, NT5E, SLFN11 |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | menor no DM2 | MRPL15, NDUFA8, SUCLG1, OXSM, NDUFAF4, TIMM23, CMC2, MRPL13, IAH1, ECHDC1, NDUFB5, UCHL3, MRPL47, LSM1, PLGRKT, MRPS30, IMPA1, TMEM126A, MCTS1, MTERF3, TACO1, LYSET, GON7, DMAC2, IMMP1L, HCCS, COPRS, TIMM21, KGD4, MRPL16 |
| musculo | M6 | exploratório (efeito fixo, 2 estudos) | maior no DM2 | ISYNA1, HNF4A, SBNO2, TTC38, CTU2, CDKL5, ZNF296, DRC7, ACSL6, CCDC159, IGLON5, CALN1, SHISA7, CCDC102A, NOL12, ADAM12, HOXB1, BPIFA2, SS18 |

Com 2 a 4 estudos por tecido, o Hartung-Knapp só dá p < 0,05 com efeitos grandes e muito consistentes; a coluna DerSimonian-Laird mostra o p menos conservador para comparação.
