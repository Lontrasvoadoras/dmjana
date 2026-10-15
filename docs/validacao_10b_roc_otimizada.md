# Validação da etapa 10b: curva ROC com otimização aninhada

Gerado em 12/10/2026 12:33.

Regras testadas: genes do módulo escolhido ou do genoma inteiro, com 10, 20, 50 ou 100 genes (8 regras). A regra é escolhida dentro do treino (deixar um estudo de fora interno) e avaliada no estudo escondido.

## 1. Por tecido

| Tecido | Estudo testado | Regra escolhida no treino | AUC otimizada (IC 95%) | AUC padrão (etapa 10) |
|---|---|---|---|---:|
| ilhotas | GSE221156 | módulo, 100 genes | 0,62 (0,00 a 1,00) | 0,50 |
| ilhotas | GSE41762 | módulo, 50 genes | 0,67 (0,36 a 0,97) | 0,69 |
| ilhotas | GSE76895 | módulo, 50 genes | 1,00 (1,00 a 1,00) | 1,00 |
| ilhotas | GSE86469 | genoma, 50 genes | 0,50 (0,00 a 1,00) | 1,00 |
| musculo | GSE18732 | módulo, 20 genes | 0,57 (0,30 a 0,85) | 0,56 |
| musculo | GSE25462 | módulo, 20 genes | 0,29 (0,00 a 0,63) | 0,25 |
| sangue | GSE184050 | genoma, 10 genes | 0,37 (0,15 a 0,59) | 0,46 |
| sangue | GSE249102 | módulo, 100 genes | 0,00 (0,00 a 0,00) | 0,00 |
| sangue | GSE250283 | módulo, 10 genes | 0,47 (0,07 a 0,87) | 0,25 |

| Tecido | AUC combinada otimizada (IC 95%) | p |
|---|---|---:|
| ilhotas | 0,65 (0,28 a 0,90) | 0,3 |
| musculo | 0,47 (0,00 a 1,00) | 0,88 |
| sangue | 0,39 (0,10 a 0,77) | 0,35 |

## 1b. Fígado: validação cruzada aninhada dentro do GSE130991

| Repetição | Regras escolhidas | AUC otimizada (IC 95%) | AUC padrão |
|---:|---|---|---:|
| 1 | genoma, 100 genes x3; genoma, 50 genes x1; módulo, 20 genes x1 | 0,74 (0,67 a 0,82) | 0,66 |
| 2 | genoma, 10 genes x1; genoma, 100 genes x1; genoma, 50 genes x2; módulo, 10 genes x1 | 0,69 (0,61 a 0,77) | 0,62 |
| 3 | genoma, 10 genes x1; genoma, 50 genes x4 | 0,75 (0,68 a 0,83) | 0,64 |
| 4 | genoma, 100 genes x2; genoma, 20 genes x1; genoma, 50 genes x2 | 0,74 (0,67 a 0,82) | 0,64 |
| 5 | genoma, 100 genes x2; genoma, 20 genes x1; genoma, 50 genes x2 | 0,72 (0,64 a 0,80) | 0,60 |
| 6 | genoma, 10 genes x2; genoma, 100 genes x2; genoma, 20 genes x1 | 0,71 (0,64 a 0,79) | 0,65 |
| 7 | genoma, 10 genes x1; genoma, 100 genes x3; genoma, 50 genes x1 | 0,73 (0,65 a 0,80) | 0,62 |
| 8 | genoma, 100 genes x3; genoma, 20 genes x1; genoma, 50 genes x1 | 0,72 (0,64 a 0,79) | 0,64 |
| 9 | genoma, 10 genes x1; genoma, 100 genes x4 | 0,75 (0,68 a 0,82) | 0,62 |
| 10 | genoma, 10 genes x1; genoma, 100 genes x2; genoma, 50 genes x2 | 0,73 (0,65 a 0,81) | 0,65 |

## 2. Conjunto comum a todos os tecidos (deixar um tecido de fora)

| Tecido testado | Estudo | Regra | AUC (IC 95%) |
|---|---|---|---|
| adiposo | GSE200678 | genoma, 50 genes | 0,50 (0,00 a 1,00) |
| adiposo | GSE133666 | genoma, 50 genes | 0,83 (0,46 a 1,00) |
| adiposo | GSE198922 | genoma, 50 genes | 0,81 (0,42 a 1,00) |
| adiposo | GSE29226 | genoma, 50 genes | 0,75 (0,06 a 1,00) |
| figado | GSE130991 | genoma, 20 genes | 0,66 (0,57 a 0,74) |
| ilhotas | GSE41762 | genoma, 10 genes | 0,56 (0,25 a 0,86) |
| ilhotas | GSE221156 | genoma, 10 genes | 0,00 (0,00 a 0,00) |
| ilhotas | GSE76895 | genoma, 10 genes | 0,33 (0,00 a 0,75) |
| ilhotas | GSE86469 | genoma, 10 genes | 0,50 (0,00 a 1,00) |
| musculo | GSE18732 | genoma, 100 genes | 0,65 (0,40 a 0,90) |
| musculo | GSE25462 | genoma, 100 genes | 0,88 (0,60 a 1,00) |
| sangue | GSE184050 | genoma, 50 genes | 0,53 (0,26 a 0,79) |
| sangue | GSE250283 | genoma, 50 genes | 0,66 (0,29 a 1,00) |
| sangue | GSE249102 | genoma, 50 genes | 0,50 (0,00 a 1,00) |

| Conjunto | AUC combinada (IC 95%) | p |
|---|---|---:|
| todos | 0,63 (0,56 a 0,70) | 0,0019 |
| adiposo | 0,73 (0,30 a 0,95) | 0,18 |
| figado | 0,66 (0,57 a 0,73) | 0,00043 |
| ilhotas | 0,46 (0,16 a 0,78) | 0,72 |
| musculo | 0,69 (0,00 a 1,00) | 0,35 |
| sangue | 0,56 (0,19 a 0,87) | 0,62 |

## 3. Conjuntos finais (regra escolhida e genes com todos os estudos)

- **figado** (genoma, 100 genes): SATB2↑, LGALS4↑, FAT1↑, WIPI1↑, DEFB1↑, ME1↑, ACADSB↓, MVK↑, PITPNA↑, FKBP1C↑, FNDC1↑, SQLE↑, ITGA6↑, SULF2↑, ACLY↑, CHI3L1↑, ORMDL2↑, CALR↑, NSDHL↑, RND2↓, SREBF2↑, POSTN↓, CYP2C19↓, ANO10↑, ALDOC↑, FASN↑, PON3↓, WNK1↑, ACSL4↑, ZMAT3↑, TTL↑, CETN2↑, PI4K2A↑, ATP6V0D1↑, CDK5RAP3↓, TNRC6C↓, CYP4F22↑, CAPNS1↑, MRAS↑, CFL1↑, RALGPS1↑, GNA12↑, STXBP1↑, HMGCS1↑, BSG↑, EBPL↓, CIRBP↓, SEC16A↑, RDH11↑, ENOSF1↓, ADAMTSL3↓, MMAB↑, UNC119↑, IP6K3↑, PEPD↑, SHBG↓, TP53I3↑, L3MBTL3↓, ERGIC1↑, CTSD↑, PELI2↓, NDRG2↓, MAP4↑, TKT↑, NUDT13↓, IPO13↑, XPC↓, ABCG2↓, IDI1↑, APOF↓, ADHFE1↓, GOLM1↑, MANF↑, HYOU1↑, SCUBE1↑, SCD↑, ATP9A↑, SLC16A10↓, IGFALS↓, ENTPD7↑, MTOR↑, C8A↓, MAMDC4↑, FLVCR1↑, TIAM1↓, OAT↓, PACSIN3↓, PLP2↑, CDNF↓, OR11A1↑, FN3KRP↓, SH2B3↑, NIPAL1↓, CSTB↑, CD82↓, MPV17L2↑, KRT8↑, MSN↑, DERL3↑, EMC8↑
- **ilhotas** (módulo, 50 genes): THBS2↑, PID1↑, RAB34↑, IL6↑, LTBP1↑, TCF21↑, TLE3↑, APOL3↑, PRELP↑, NR4A3↑, SH2B3↑, SLC16A1↑, IGFBP4↑, HYCC1↑, HGF↑, APOD↑, ZEB2↑, SLIT2↑, NT5E↑, PODN↑, ITGBL1↑, TGFB3↑, PTGDS↑, PDGFRA↑, INHBA↑, GFPT2↑, IL24↑, SMOX↑, HOXB6↑, COMP↑, IL18R1↑, MEDAG↑, STEAP1↑, DLL1↑, CAVIN3↑, GAS7↑, PMP22↑, PDE7B↑, PHLDB1↑, RASD2↑, PRRX1↑, THBS4↑, MOXD1↑, BNIP2↑, DDR2↑, DUSP6↑, GNG11↑, TIMP3↑, KCNE4↑, SLFN11↑
- **musculo** (genoma, 50 genes): OXNAD1↓, GON7↓, OR1J2↑, C14orf180↑, AP2B1↓, TSPAN6↓, TBPL1↓, ZMYND12↓, PDSS2↓, CYP46A1↑, MAN1B1↑, SCGB1D2↓, MRPS30↓, ATP6V0B↓, TIMM8A↓, PALM↑, WDR12↓, DNAH8↑, TEDC1↑, SFTPC↑, AGBL4↑, TMEM126A↓, PCED1A↑, REM1↑, FGGY↓, GSPT2↓, NSMCE1↓, BRI3BP↓, CDC25B↑, NGB↑, CALB2↑, GUF1↓, ABHD18↓, SLC25A25↓, PPP1R1C↓, MPC1↓, CHCHD7↓, SLC4A7↓, TRIML2↑, SLC26A2↓, COQ3↓, GPAT2↓, GPRC5D↑, PKD1↑, EIF2S1↓, C5orf63↓, TRABD↓, CADM1↓, SLC25A22↑, EEF1AKMT1↓
- **sangue** (genoma, 10 genes): GBP5↑, ACADSB↓, FHL1↓, KIF4A↓, TTF1↓, MOV10↑, BRIP1↓, FAH↓, PSMC1↓, EIF5B↓
- **todos os tecidos** (genoma, 50 genes): PPM1K↓, EPHA3↑, SIRT5↓, APOL3↑, IGFBP7↑, LDLR↑, ALDH6A1↓, GRAMD1C↓, PCID2↓, SLC7A6↑, PTPN3↓, PPM1E↓, SCAPER↓, CCT6B↓, LUM↑, ZZZ3↓, MEIS1↓, MANF↑, TUBD1↓, NBEAL2↑, NDUFA8↓, TRAPPC4↓, TM2D2↓, EMG1↓, ANKMY2↓, TFB1M↓, HCFC1↑, RORC↓, CADM1↓, LIAS↓, SENP8↓, ZNF157↓, PLCB4↓, PTK2↓, PAAF1↓, KLHL28↓, PTGR1↓, ZNF84↓, PLBD2↑, LOXL2↑, PLLP↓, TNFAIP3↑, NUDT7↓, PIGF↓, TMEM141↓, PLXNA1↑, ZFP92↑, SPOP↓, PCDHB12↑, ADAM12↑

A AUC honesta de cada conjunto final é a da otimização aninhada (seções 1 e 2), não a do conjunto aplicado aos mesmos dados.
