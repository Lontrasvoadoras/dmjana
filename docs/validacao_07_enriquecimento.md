# Validação da etapa 07: enriquecimento

Gerado em 12/10/2026 12:24 a partir de `output/07_enriquecimento/`.

## 1. Vias por tecido (efeito do DM2 nas mulheres de 40–60)

Teste: escore por amostra em cada via, mesmo modelo e meta-análise (Hartung-Knapp) da etapa 05. A última coluna mostra quantas vias a GSEA pré-ordenada daria com FDR < 0,05: ela ignora a correlação entre genes e ficou inflada, por isso serve só para o sentido e os genes que puxam a via.

| Tecido | Coleção | Vias testadas | FDR < 0,05 | FDR < 0,10 | Exploratórias (p < 0,05 e todos os estudos no mesmo sentido) | p < 0,05 observadas | p < 0,05 esperadas ao acaso | GSEA pré-ordenada FDR < 0,05 (inflada) |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| adiposo | GO_BP | 5443 | 0 | 0 | 3 | 12 | 272 | 110 |
| adiposo | Hallmark | 50 | 0 | 0 | 0 | 0 | 2 | 19 |
| adiposo | Reactome | 1422 | 0 | 0 | 1 | 2 | 71 | 22 |
| figado | GO_BP | 5224 | 0 | 0 | 0 | 279 | 261 | 380 |
| figado | Hallmark | 50 | 0 | 0 | 0 | 6 | 2 | 33 |
| figado | Reactome | 1353 | 0 | 0 | 0 | 96 | 68 | 247 |
| ilhotas | GO_BP | 5445 | 0 | 0 | 58 | 69 | 272 | 675 |
| ilhotas | Hallmark | 50 | 0 | 0 | 0 | 0 | 2 | 26 |
| ilhotas | Reactome | 1415 | 0 | 0 | 6 | 9 | 71 | 193 |
| musculo | GO_BP | 5405 | 0 | 0 | 201 | 0 | 270 | 244 |
| musculo | Hallmark | 50 | 0 | 0 | 3 | 0 | 2 | 13 |
| musculo | Reactome | 1409 | 0 | 0 | 57 | 0 | 70 | 176 |
| sangue | GO_BP | 5399 | 0 | 0 | 0 | 5 | 270 | 53 |
| sangue | Hallmark | 50 | 0 | 0 | 0 | 0 | 2 | 4 |
| sangue | Reactome | 1406 | 0 | 0 | 0 | 1 | 70 | 40 |

Esperadas ao acaso = 5% das vias testadas. Listas exploratórias desse tamanho não são evidência por si; valem como hipóteses quando convergem com módulos e genes (revisão de 08/10/2026).

## 2. Vias selecionadas (até 8 por tecido e coleção)

| Tecido | Coleção | Via | g (IC 95%) | p | FDR | Nível | Estudos no mesmo sentido | NES (GSEA) |
|---|---|---|---|---:|---:|---|---|---:|
| adiposo | GO_BP | GOBP_ENDODERM_FORMATION | 1.43 (0.11 a 2.75) | 0,041 |   1 | exploratório | 4/4 | 2.34 |
| adiposo | GO_BP | GOBP_ORGAN_OR_TISSUE_SPECIFIC_IMMUNE_RESPONSE | 1.30 (0.02 a 2.59) | 0,048 |   1 | exploratório | 4/4 | 2.07 |
| adiposo | GO_BP | GOBP_POSITIVE_REGULATION_OF_SIGNAL_TRANSDUCTION_BY_P53_CLASS_MEDIATOR | 1.29 (0.00 a 2.57) | 0,05 |   1 | exploratório | 4/4 | 1.77 |
| adiposo | Reactome | REACTOME_FORMATION_OF_DEFINITIVE_ENDODERM | 1.36 (0.01 a 2.70) | 0,049 |   1 | exploratório | 4/4 | 1.61 |
| figado | GO_BP | GOBP_ORGANELLE_INHERITANCE | 0.72 (0.41 a 1.03) | 0,0023 | 0,77 | exploratório (1 estudo) | 1/1 | 1.64 |
| figado | GO_BP | GOBP_AMINE_METABOLIC_PROCESS | -0.57 (-0.88 a -0.26) | 0,0025 | 0,77 | exploratório (1 estudo) | 1/1 | -1.75 |
| figado | GO_BP | GOBP_NEGATIVE_REGULATION_OF_AUTOPHAGY | 0.62 (0.31 a 0.93) | 0,0025 | 0,77 | exploratório (1 estudo) | 1/1 | 1.73 |
| figado | GO_BP | GOBP_PRESYNAPTIC_ENDOCYTOSIS | 0.63 (0.32 a 0.94) | 0,0025 | 0,77 | exploratório (1 estudo) | 1/1 | 1.83 |
| figado | GO_BP | GOBP_RESPONSE_TO_ZINC_ION | -0.57 (-0.87 a -0.26) | 0,0025 | 0,77 | exploratório (1 estudo) | 1/1 | -2.00 |
| figado | GO_BP | GOBP_STEROL_BIOSYNTHETIC_PROCESS | 0.59 (0.28 a 0.90) | 0,0025 | 0,77 | exploratório (1 estudo) | 1/1 | 2.37 |
| figado | GO_BP | GOBP_SYNAPTIC_VESICLE_RECYCLING | 0.71 (0.40 a 1.02) | 0,0025 | 0,77 | exploratório (1 estudo) | 1/1 | 1.79 |
| figado | GO_BP | GOBP_NEGATIVE_REGULATION_OF_ESTABLISHMENT_OF_PROTEIN_LOCALIZATION | 0.69 (0.38 a 1.00) | 0,0025 | 0,77 | exploratório (1 estudo) | 1/1 | 1.68 |
| figado | Hallmark | HALLMARK_CHOLESTEROL_HOMEOSTASIS | 0.69 (0.38 a 1.00) | 0,0025 | 0,12 | exploratório (1 estudo) | 1/1 | 2.69 |
| figado | Hallmark | HALLMARK_MTORC1_SIGNALING | 0.52 (0.22 a 0.83) | 0,013 | 0,21 | exploratório (1 estudo) | 1/1 | 2.44 |
| figado | Hallmark | HALLMARK_P53_PATHWAY | 0.52 (0.21 a 0.83) | 0,013 | 0,21 | exploratório (1 estudo) | 1/1 | 1.82 |
| figado | Hallmark | HALLMARK_MYC_TARGETS_V2 | 0.43 (0.12 a 0.73) | 0,027 | 0,33 | exploratório (1 estudo) | 1/1 | 1.94 |
| figado | Hallmark | HALLMARK_UNFOLDED_PROTEIN_RESPONSE | 0.40 (0.10 a 0.71) | 0,045 | 0,33 | exploratório (1 estudo) | 1/1 | 2.01 |
| figado | Hallmark | HALLMARK_PI3K_AKT_MTOR_SIGNALING | 0.40 (0.09 a 0.70) | 0,05 | 0,33 | exploratório (1 estudo) | 1/1 | 1.57 |
| figado | Reactome | REACTOME_INDUCTION_OF_CELL_CELL_FUSION | 0.70 (0.39 a 1.01) | 0,0023 | 0,54 | exploratório (1 estudo) | 1/1 | - |
| figado | Reactome | REACTOME_SENESCENCE_ASSOCIATED_SECRETORY_PHENOTYPE_SASP | 0.57 (0.26 a 0.87) | 0,0025 | 0,54 | exploratório (1 estudo) | 1/1 | 1.60 |
| figado | Reactome | REACTOME_TNF_SIGNALING | 0.57 (0.26 a 0.87) | 0,0025 | 0,54 | exploratório (1 estudo) | 1/1 | 1.94 |
| figado | Reactome | REACTOME_RECEPTOR_TYPE_TYROSINE_PROTEIN_PHOSPHATASES | -0.73 (-1.04 a -0.42) | 0,0025 | 0,54 | exploratório (1 estudo) | 1/1 | -2.27 |
| figado | Reactome | REACTOME_ERKS_ARE_INACTIVATED | 0.64 (0.33 a 0.95) | 0,0047 | 0,54 | exploratório (1 estudo) | 1/1 | - |
| figado | Reactome | REACTOME_GAP_JUNCTION_DEGRADATION | 0.60 (0.29 a 0.91) | 0,0047 | 0,54 | exploratório (1 estudo) | 1/1 | - |
| figado | Reactome | REACTOME_COPI_DEPENDENT_GOLGI_TO_ER_RETROGRADE_TRAFFIC | 0.56 (0.25 a 0.86) | 0,005 | 0,54 | exploratório (1 estudo) | 1/1 | 2.08 |
| figado | Reactome | REACTOME_LATE_SARS_COV_2_INFECTION_EVENTS | 0.54 (0.24 a 0.85) | 0,005 | 0,54 | exploratório (1 estudo) | 1/1 | 1.96 |
| ilhotas | GO_BP | GOBP_REGULATION_OF_WNT_SIGNALING_PATHWAY_PLANAR_CELL_POLARITY_PATHWAY | 1.85 (0.59 a 3.12) | 0,019 | 0,89 | exploratório | 4/4 | - |
| ilhotas | GO_BP | GOBP_HEPATOCYTE_GROWTH_FACTOR_RECEPTOR_SIGNALING_PATHWAY | 1.37 (0.39 a 2.35) | 0,021 | 0,89 | exploratório | 4/4 | - |
| ilhotas | GO_BP | GOBP_NEGATIVE_REGULATION_OF_BONE_REMODELING | 1.58 (0.37 a 2.80) | 0,025 | 0,89 | exploratório | 4/4 | 2.05 |
| ilhotas | GO_BP | GOBP_POSITIVE_REGULATION_OF_MACROPHAGE_DIFFERENTIATION | 1.38 (0.32 a 2.43) | 0,026 | 0,89 | exploratório | 4/4 | 1.80 |
| ilhotas | GO_BP | GOBP_CHONDROCYTE_PROLIFERATION | 1.47 (0.34 a 2.61) | 0,026 | 0,89 | exploratório | 4/4 | 2.29 |
| ilhotas | GO_BP | GOBP_NEGATIVE_REGULATION_OF_STEM_CELL_PROLIFERATION | 1.41 (0.32 a 2.50) | 0,026 | 0,89 | exploratório | 4/4 | 2.16 |
| ilhotas | GO_BP | GOBP_IMMATURE_B_CELL_DIFFERENTIATION | 1.24 (0.26 a 2.21) | 0,027 | 0,89 | exploratório | 4/4 | 1.65 |
| ilhotas | GO_BP | GOBP_POSITIVE_REGULATION_OF_EXTRINSIC_APOPTOTIC_SIGNALING_PATHWAY_IN_ABSENCE_OF_LIGAND | 1.44 (0.30 a 2.58) | 0,028 | 0,89 | exploratório | 4/4 | - |
| ilhotas | Reactome | REACTOME_MET_ACTIVATES_RAP1_AND_RAC1 | 1.13 (0.21 a 2.05) | 0,03 | 0,98 | exploratório | 4/4 | - |
| ilhotas | Reactome | REACTOME_DEFECTS_IN_VITAMIN_AND_COFACTOR_METABOLISM | -1.39 (-2.54 a -0.24) | 0,031 | 0,98 | exploratório | 4/4 | -2.05 |
| ilhotas | Reactome | REACTOME_RUNX2_REGULATES_OSTEOBLAST_DIFFERENTIATION | 1.11 (0.09 a 2.14) | 0,04 | 0,98 | exploratório | 4/4 | 1.91 |
| ilhotas | Reactome | REACTOME_RUNX2_REGULATES_BONE_DEVELOPMENT | 0.95 (0.01 a 1.90) | 0,049 | 0,98 | exploratório | 4/4 | 1.93 |
| ilhotas | Reactome | REACTOME_CHONDROITIN_SULFATE_DERMATAN_SULFATE_METABOLISM | 1.18 (0.00 a 2.36) | 0,05 | 0,98 | exploratório | 4/4 | 1.94 |
| ilhotas | Reactome | REACTOME_PTK6_REGULATES_RHO_GTPASES_RAS_GTPASE_AND_MAP_KINASES | 0.95 (0.00 a 1.91) | 0,05 | 0,98 | exploratório | 4/4 | - |
| musculo | GO_BP | GOBP_MICROTUBULE_BASED_PROTEIN_TRANSPORT | 1.66 (-3.93 a 7.25) | 0,17 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | - |
| musculo | GO_BP | GOBP_PROTEIN_LOCALIZATION_TO_PRESYNAPSE | 1.76 (-4.26 a 7.78) | 0,17 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | - |
| musculo | GO_BP | GOBP_PROGESTERONE_METABOLIC_PROCESS | 1.57 (-4.26 a 7.40) | 0,18 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | 1.72 |
| musculo | GO_BP | GOBP_CYTOCHROME_COMPLEX_ASSEMBLY | -1.50 (-7.20 a 4.20) | 0,18 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | -2.54 |
| musculo | GO_BP | GOBP_NEGATIVE_REGULATION_OF_NEURON_PROJECTION_REGENERATION | 1.13 (-3.19 a 5.46) | 0,19 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | 1.39 |
| musculo | GO_BP | GOBP_RESPIRATORY_CHAIN_COMPLEX_IV_ASSEMBLY | -1.48 (-7.19 a 4.22) | 0,19 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | -2.39 |
| musculo | GO_BP | GOBP_REGULATION_OF_COLLATERAL_SPROUTING | 1.47 (-4.33 a 7.28) | 0,19 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | 1.84 |
| musculo | GO_BP | GOBP_MACROPHAGE_ACTIVATION_INVOLVED_IN_IMMUNE_RESPONSE | 1.29 (-3.87 a 6.45) | 0,19 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | 1.88 |
| musculo | Hallmark | HALLMARK_OXIDATIVE_PHOSPHORYLATION | -1.12 (-6.52 a 4.28) | 0,23 | 0,98 | exploratório (efeito fixo, 2 estudos) | 2/2 | -2.77 |
| musculo | Hallmark | HALLMARK_FATTY_ACID_METABOLISM | -0.86 (-6.22 a 4.50) | 0,29 | 0,98 | exploratório (efeito fixo, 2 estudos) | 2/2 | -1.62 |
| musculo | Hallmark | HALLMARK_MYOGENESIS | 0.73 (-3.91 a 5.36) | 0,3 | 0,98 | exploratório (efeito fixo, 2 estudos) | 2/2 | 2.01 |
| musculo | Reactome | REACTOME_STRIATED_MUSCLE_CONTRACTION | 1.60 (-3.65 a 6.85) | 0,16 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | 2.40 |
| musculo | Reactome | REACTOME_P2Y_RECEPTORS | 1.33 (-3.65 a 6.31) | 0,18 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | - |
| musculo | Reactome | REACTOME_BRANCHED_CHAIN_AMINO_ACID_CATABOLISM | -1.32 (-6.56 a 3.91) | 0,19 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | -1.92 |
| musculo | Reactome | REACTOME_MITOCHONDRIAL_TRNA_AMINOACYLATION | -1.42 (-7.07 a 4.23) | 0,19 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | -1.77 |
| musculo | Reactome | REACTOME_SYNTHESIS_OF_BILE_ACIDS_AND_BILE_SALTS_VIA_24_HYDROXYCHOLESTEROL | 1.10 (-3.37 a 5.57) | 0,2 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | - |
| musculo | Reactome | REACTOME_DEFECTIVE_B4GALT7_CAUSES_EDS_PROGEROID_TYPE | 1.36 (-4.18 a 6.90) | 0,2 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | 1.80 |
| musculo | Reactome | REACTOME_DERMATAN_SULFATE_BIOSYNTHESIS | 1.39 (-4.30 a 7.08) | 0,2 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | - |
| musculo | Reactome | REACTOME_SYNTHESIS_OF_GLYCOSYLPHOSPHATIDYLINOSITOL_GPI | -1.35 (-6.88 a 4.19) | 0,2 |   1 | exploratório (efeito fixo, 2 estudos) | 2/2 | -1.61 |

Figura: `docs/figuras/gsea_hallmark.png`.

## 3. O que cada módulo representa (ORA, FDR < 0,05)

| Tecido | Módulo | Genes | g (DM2, mulheres 40–60) | p | Seleção | Representa |
|---|---|---:|---:|---:|---|---|
| adiposo | M12 | 59 | 0.74 | 0,16 | - | TNFA_SIGNALING_VIA_NFKB / HEME_METABOLISM |
| adiposo | M4 | 960 | -0.68 | 0,19 | - | OXIDATIVE_PHOSPHORYLATION / ADIPOGENESIS |
| adiposo | M11 | 70 | 0.37 | 0,42 | - | NEUTROPHIL_DEGRANULATION |
| adiposo | M10 | 82 | -0.35 | 0,45 | - | TRNA_AMINOACYLATION |
| adiposo | M1 | 1147 | -0.30 | 0,5 | - | ADIPOGENESIS / FATTY_ACID_METABOLIC_PROCESS |
| adiposo | M8 | 136 | -0.32 | 0,58 | - | NUCLEAR_RECEPTOR_TRANSCRIPTION_PATHWAY / PI3K_AKT_SIGNALING_IN_CANCER |
| adiposo | M2 | 1089 | 0.22 | 0,62 | - | ALLOGRAFT_REJECTION / INTERFERON_GAMMA_RESPONSE |
| adiposo | M7 | 243 | 0.21 | 0,64 | - | - |
| adiposo | M9 | 111 | -0.20 | 0,65 | - | NONSENSE_MEDIATED_DECAY_NMD / EUKARYOTIC_TRANSLATION_ELONGATION |
| adiposo | M6 | 650 | -0.20 | 0,7 | - | OXIDATIVE_PHOSPHORYLATION / FATTY_ACID_METABOLISM |
| adiposo | M5 | 927 | -0.05 | 0,9 | - | KRAS_SIGNALING_DN / SNRNA_METABOLIC_PROCESS |
| adiposo | M3 | 1051 | 0.03 | 0,94 | - | EPITHELIAL_MESENCHYMAL_TRANSITION / ESTROGEN_RESPONSE_EARLY |
| figado | M6 | 238 | 0.42 | 0,0075 | sugestivo | OXIDATIVE_PHOSPHORYLATION / ADIPOGENESIS |
| figado | M15 | 54 | 0.39 | 0,011 | sugestivo | PROTEIN_SECRETION / ENDOPLASMIC_RETICULUM_TO_GOLGI_VESICLE_MEDIATED_TRANSPORT |
| figado | M10 | 110 | 0.19 | 0,23 | - | EPITHELIAL_MESENCHYMAL_TRANSITION / APOPTOSIS |
| figado | M5 | 256 | 0.16 | 0,3 | - | OXIDATIVE_PHOSPHORYLATION / MYC_TARGETS_V1 |
| figado | M13 | 70 | 0.12 | 0,43 | - | INTERFERON_GAMMA_RESPONSE / ALLOGRAFT_REJECTION |
| figado | M16 | 50 | 0.11 | 0,49 | - | - |
| figado | M14 | 59 | 0.07 | 0,66 | - | TRANSCRIPTION_OF_THE_HIV_GENOME / RNA_POLYMERASE_II_PRE_TRANSCRIPTION_EVENTS |
| figado | M9 | 185 | 0.06 | 0,69 | - | - |
| figado | M3 | 274 | 0.05 | 0,73 | - | DNA_RECOMBINATION / DNA_REPAIR |
| figado | M7 | 236 | 0.05 | 0,76 | - | - |
| figado | M11 | 88 | 0.03 | 0,85 | - | - |
| figado | M8 | 196 | -0.02 | 0,89 | - | KRAS_SIGNALING_DN / MYOGENESIS |
| figado | M2 | 326 | 0.02 | 0,91 | - | MYC_TARGETS_V1 / OXIDATIVE_PHOSPHORYLATION |
| figado | M4 | 270 | -0.01 | 0,93 | - | MYOGENESIS / KRAS_SIGNALING_DN |
| figado | M1 | 1124 | 0.00 | 0,99 | - | MYC_TARGETS_V1 / PROTEIN_SECRETION |
| figado | M12 | 73 | -0.00 |   1 | - | - |
| ilhotas | M6 | 188 | 1.27 | 0,05 | exploratório | EPITHELIAL_MESENCHYMAL_TRANSITION / TNFA_SIGNALING_VIA_NFKB |
| ilhotas | M4 | 264 | 0.90 | 0,09 | - | EPITHELIAL_MESENCHYMAL_TRANSITION / MYOGENESIS |
| ilhotas | M2 | 1930 | -0.57 | 0,22 | - | PANCREAS_BETA_CELLS / SPERMATOGENESIS |
| ilhotas | M10 | 147 | 0.44 | 0,3 | - | VASCULATURE_DEVELOPMENT / BLOOD_VESSEL_MORPHOGENESIS |
| ilhotas | M11 | 99 | 0.71 | 0,41 | - | SRP_DEPENDENT_COTRANSLATIONAL_PROTEIN_TARGETING_TO_MEMBRANE / EUKARYOTIC_TRANSLATION_INITIATION |
| ilhotas | M1 | 2290 | 0.42 | 0,43 | - | TNFA_SIGNALING_VIA_NFKB / INTERFERON_GAMMA_RESPONSE |
| ilhotas | M15 | 62 | 0.31 | 0,44 | - | KRAS_SIGNALING_DN / DEVELOPMENTAL_LINEAGE_OF_PANCREATIC_ACINAR_CELLS |
| ilhotas | M8 | 170 | -0.67 | 0,53 | - | POSTSYNAPSE_ASSEMBLY / POSTSYNAPSE_ORGANIZATION |
| ilhotas | M7 | 180 | -0.86 | 0,59 | - | MYC_TARGETS_V2 / MYC_TARGETS_V1 |
| ilhotas | M14 | 74 | -0.30 | 0,6 | - | G2M_CHECKPOINT / E2F_TARGETS |
| ilhotas | M3 | 765 | -0.42 | 0,68 | - | MITOTIC_SPINDLE / PROTEIN_SECRETION |
| ilhotas | M17 | 40 | -0.20 | 0,71 | - | ESTROGEN_RESPONSE_LATE / ESTROGEN_RESPONSE_EARLY |
| ilhotas | M12 | 99 | 0.41 | 0,72 | - | OXIDATIVE_PHOSPHORYLATION / MYC_TARGETS_V1 |
| ilhotas | M5 | 229 | 0.26 | 0,77 | - | MITOCHONDRION_ORGANIZATION |
| ilhotas | M16 | 53 | -0.09 | 0,82 | - | GLYCOSPHINGOLIPID_CATABOLISM / GLYCOSPHINGOLIPID_METABOLISM |
| ilhotas | M9 | 164 | -0.09 | 0,91 | - | GPCR_LIGAND_BINDING / SIGNALING_BY_GPCR |
| ilhotas | M13 | 83 | -0.01 | 0,99 | - | ALLOGRAFT_REJECTION / KRAS_SIGNALING_UP |
| musculo | M4 | 259 | -1.11 | 0,21 | exploratório (efeito fixo, 2 estudos) | OXIDATIVE_PHOSPHORYLATION / FATTY_ACID_METABOLISM |
| musculo | M6 | 243 | 0.83 | 0,3 | exploratório (efeito fixo, 2 estudos) | GPCR_LIGAND_BINDING / G_PROTEIN_COUPLED_RECEPTOR_SIGNALING_PATHWAY |
| musculo | M8 | 156 | -0.61 | 0,35 | - | - |
| musculo | M1 | 4153 | -0.63 | 0,39 | - | PROTEIN_SECRETION / MYC_TARGETS_V1 |
| musculo | M7 | 213 | -0.30 | 0,66 | - | EPITHELIAL_MESENCHYMAL_TRANSITION / COAGULATION |
| musculo | M13 | 47 | 0.35 | 0,68 | - | - |
| musculo | M2 | 861 | -0.49 | 0,71 | - | OXIDATIVE_PHOSPHORYLATION / ADIPOGENESIS |
| musculo | M10 | 134 | 0.41 | 0,71 | - | GPCR_LIGAND_BINDING / CLASS_A_1_RHODOPSIN_LIKE_RECEPTORS |
| musculo | M9 | 143 | -0.49 | 0,71 | - | - |
| musculo | M12 | 60 | 0.20 | 0,73 | - | MUSCLE_CONTRACTION / STRIATED_MUSCLE_CONTRACTION |
| musculo | M5 | 255 | -0.13 | 0,8 | - | - |
| musculo | M3 | 276 | 0.22 | 0,82 | - | MYOGENESIS |
| musculo | M11 | 119 | -0.16 | 0,86 | - | FORMATION_OF_THE_CORNIFIED_ENVELOPE / KERATINIZATION |
| sangue | M10 | 223 | -0.55 | 0,23 | - | B_CELL_ACTIVATION / B_CELL_RECEPTOR_SIGNALING_PATHWAY |
| sangue | M9 | 249 | -0.43 | 0,31 | - | - |
| sangue | M15 | 48 | -0.40 | 0,33 | - | PRODUCTION_OF_MOLECULAR_MEDIATOR_INVOLVED_IN_INFLAMMATORY_RESPONSE / CYTOKINE_PRODUCTION_INVOLVED_IN_INFLAMMATORY_RESPONSE |
| sangue | M8 | 290 | -0.35 | 0,39 | - | - |
| sangue | M5 | 499 | -0.31 | 0,43 | - | HEME_METABOLISM / HEMOSTASIS |
| sangue | M11 | 170 | 0.20 | 0,6 | - | MITOTIC_SPINDLE / REGULATION_OF_LEUKOCYTE_MEDIATED_IMMUNITY |
| sangue | M1 | 1153 | -0.16 | 0,66 | - | TNFA_SIGNALING_VIA_NFKB / COMPLEMENT |
| sangue | M6 | 360 | -0.16 | 0,7 | - | OXIDATIVE_PHOSPHORYLATION / MYC_TARGETS_V1 |
| sangue | M2 | 725 | -0.22 | 0,71 | - | MYC_TARGETS_V1 / OXIDATIVE_PHOSPHORYLATION |
| sangue | M7 | 344 | 0.23 | 0,76 | - | ALLOGRAFT_REJECTION / T_CELL_ACTIVATION |
| sangue | M16 | 40 | 0.12 | 0,83 | - | - |
| sangue | M4 | 525 | -0.07 | 0,84 | - | CHROMATIN_ORGANIZATION / CHROMATIN_ORGANIZATION |
| sangue | M14 | 58 | -0.11 | 0,85 | - | - |
| sangue | M13 | 60 | -0.01 | 0,97 | - | B_WICH_COMPLEX_POSITIVELY_REGULATES_RRNA_EXPRESSION |
| sangue | M3 | 698 | -0.01 | 0,98 | - | MITOTIC_SPINDLE_CHECKPOINT / RHO_GTPASES_ACTIVATE_FORMINS |
| sangue | M12 | 115 | -0.01 | 0,99 | - | INTERFERON_GAMMA_RESPONSE / INTERFERON_ALPHA_RESPONSE |

## 4. Vias convergentes (módulo selecionado + GSEA do tecido, mesmo sentido)

| Tecido | Módulo | Seleção do módulo | Coleção | Via | g da via | Nível da via |
|---|---|---|---|---|---:|---|
| figado | M6 | sugestivo | Reactome | REACTOME_ASPARAGINE_N_LINKED_GLYCOSYLATION | 0.42 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_TRANSFERRIN_ENDOCYTOSIS_AND_RECYCLING | 0.49 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_CELLULAR_RESPONSE_TO_CHEMICAL_STRESS | 0.41 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_ER_TO_GOLGI_ANTEROGRADE_TRANSPORT | 0.46 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_INSULIN_RECEPTOR_RECYCLING | 0.53 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_TRANSPORT_TO_THE_GOLGI_AND_SUBSEQUENT_MODIFICATION | 0.43 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_KEAP1_NFE2L2_PATHWAY | 0.46 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_GOLGI_TO_ER_RETROGRADE_TRANSPORT | 0.58 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_COPI_MEDIATED_ANTEROGRADE_TRANSPORT | 0.51 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_COPI_DEPENDENT_GOLGI_TO_ER_RETROGRADE_TRAFFIC | 0.56 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_AMINO_ACIDS_REGULATE_MTORC1 | 0.40 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_COPII_MEDIATED_VESICLE_TRANSPORT | 0.40 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_SIGNALING_BY_INSULIN_RECEPTOR | 0.44 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_PCP_CE_PATHWAY | 0.43 | exploratório (1 estudo) |
| figado | M6 | sugestivo | Reactome | REACTOME_IRE1ALPHA_ACTIVATES_CHAPERONES | 0.53 | exploratório (1 estudo) |
| figado | M6 | sugestivo | GO_BP | GOBP_NADH_METABOLIC_PROCESS | 0.49 | exploratório (1 estudo) |
| figado | M6 | sugestivo | GO_BP | GOBP_PYRIDINE_CONTAINING_COMPOUND_CATABOLIC_PROCESS | 0.42 | exploratório (1 estudo) |
| figado | M6 | sugestivo | GO_BP | GOBP_RETROGRADE_VESICLE_MEDIATED_TRANSPORT_GOLGI_TO_ENDOPLASMIC_RETICULUM | 0.51 | exploratório (1 estudo) |
| figado | M6 | sugestivo | GO_BP | GOBP_PYRUVATE_METABOLIC_PROCESS | 0.46 | exploratório (1 estudo) |
| figado | M6 | sugestivo | GO_BP | GOBP_NUCLEOSIDE_DIPHOSPHATE_CATABOLIC_PROCESS | 0.46 | exploratório (1 estudo) |
| figado | M15 | sugestivo | Reactome | REACTOME_ASPARAGINE_N_LINKED_GLYCOSYLATION | 0.42 | exploratório (1 estudo) |
| figado | M15 | sugestivo | Reactome | REACTOME_ER_TO_GOLGI_ANTEROGRADE_TRANSPORT | 0.46 | exploratório (1 estudo) |
| figado | M15 | sugestivo | Reactome | REACTOME_GOLGI_TO_ER_RETROGRADE_TRANSPORT | 0.58 | exploratório (1 estudo) |
| figado | M15 | sugestivo | Reactome | REACTOME_TRANSPORT_TO_THE_GOLGI_AND_SUBSEQUENT_MODIFICATION | 0.43 | exploratório (1 estudo) |
| figado | M15 | sugestivo | Reactome | REACTOME_COPI_MEDIATED_ANTEROGRADE_TRANSPORT | 0.51 | exploratório (1 estudo) |
| figado | M15 | sugestivo | Reactome | REACTOME_INTRA_GOLGI_AND_RETROGRADE_GOLGI_TO_ER_TRAFFIC | 0.42 | exploratório (1 estudo) |
| figado | M15 | sugestivo | Reactome | REACTOME_COPI_DEPENDENT_GOLGI_TO_ER_RETROGRADE_TRAFFIC | 0.56 | exploratório (1 estudo) |
| figado | M15 | sugestivo | Reactome | REACTOME_MHC_CLASS_II_ANTIGEN_PRESENTATION | 0.43 | exploratório (1 estudo) |
| figado | M15 | sugestivo | Reactome | REACTOME_UNFOLDED_PROTEIN_RESPONSE_UPR | 0.45 | exploratório (1 estudo) |
| figado | M15 | sugestivo | Reactome | REACTOME_IRE1ALPHA_ACTIVATES_CHAPERONES | 0.53 | exploratório (1 estudo) |
| figado | M15 | sugestivo | Reactome | REACTOME_GOLGI_ASSOCIATED_VESICLE_BIOGENESIS | 0.39 | exploratório (1 estudo) |
| figado | M15 | sugestivo | Reactome | REACTOME_COPII_MEDIATED_VESICLE_TRANSPORT | 0.40 | exploratório (1 estudo) |
| figado | M15 | sugestivo | GO_BP | GOBP_PROTEIN_TARGETING_TO_MEMBRANE | 0.46 | exploratório (1 estudo) |
| figado | M15 | sugestivo | GO_BP | GOBP_RETROGRADE_VESICLE_MEDIATED_TRANSPORT_GOLGI_TO_ENDOPLASMIC_RETICULUM | 0.51 | exploratório (1 estudo) |
| ilhotas | M6 | exploratório | GO_BP | GOBP_REGULATION_OF_COLLAGEN_METABOLIC_PROCESS | 1.24 | exploratório |
| ilhotas | M6 | exploratório | GO_BP | GOBP_COLLAGEN_BIOSYNTHETIC_PROCESS | 1.34 | exploratório |
| ilhotas | M6 | exploratório | GO_BP | GOBP_POSITIVE_REGULATION_OF_COLLAGEN_METABOLIC_PROCESS | 1.23 | exploratório |
| ilhotas | M6 | exploratório | GO_BP | GOBP_NEGATIVE_REGULATION_OF_EXTRINSIC_APOPTOTIC_SIGNALING_PATHWAY_VIA_DEATH_DOMAIN_RECEPTORS | 1.36 | exploratório |
| ilhotas | M6 | exploratório | GO_BP | GOBP_ENDOCARDIAL_CUSHION_FORMATION | 1.20 | exploratório |
| ilhotas | M6 | exploratório | GO_BP | GOBP_REGULATION_OF_MACROPHAGE_ACTIVATION | 1.27 | exploratório |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Hallmark | HALLMARK_OXIDATIVE_PHOSPHORYLATION | -1.12 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Hallmark | HALLMARK_FATTY_ACID_METABOLISM | -0.86 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Reactome | REACTOME_AEROBIC_RESPIRATION_AND_RESPIRATORY_ELECTRON_TRANSPORT | -1.09 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Reactome | REACTOME_RESPIRATORY_ELECTRON_TRANSPORT | -1.18 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Reactome | REACTOME_MITOCHONDRIAL_TRANSLATION | -1.30 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Reactome | REACTOME_CITRIC_ACID_CYCLE_TCA_CYCLE | -0.99 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Reactome | REACTOME_MITOCHONDRIAL_BIOGENESIS | -1.08 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Reactome | REACTOME_COMPLEX_I_BIOGENESIS | -1.18 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Reactome | REACTOME_COMPLEX_IV_ASSEMBLY | -1.16 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Reactome | REACTOME_TRANSLATION | -0.91 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Reactome | REACTOME_MITOCHONDRIAL_PROTEIN_IMPORT | -1.30 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Reactome | REACTOME_MITOCHONDRIAL_PROTEIN_DEGRADATION | -1.13 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Reactome | REACTOME_PROTEIN_LOCALIZATION | -1.04 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | Reactome | REACTOME_MITOCHONDRIAL_FATTY_ACID_BETA_OXIDATION | -1.05 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_CELLULAR_RESPIRATION | -1.14 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_AEROBIC_RESPIRATION | -1.06 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_ENERGY_DERIVATION_BY_OXIDATION_OF_ORGANIC_COMPOUNDS | -1.00 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_OXIDATIVE_PHOSPHORYLATION | -1.00 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_ELECTRON_TRANSPORT_CHAIN | -1.02 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_ATP_SYNTHESIS_COUPLED_ELECTRON_TRANSPORT | -1.06 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_PURINE_CONTAINING_COMPOUND_BIOSYNTHETIC_PROCESS | -0.87 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_MITOCHONDRIAL_GENE_EXPRESSION | -1.23 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_NUCLEOSIDE_PHOSPHATE_BIOSYNTHETIC_PROCESS | -0.93 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_MITOCHONDRION_ORGANIZATION | -1.21 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_PURINE_NUCLEOTIDE_BIOSYNTHETIC_PROCESS | -0.84 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_MITOCHONDRIAL_RESPIRATORY_CHAIN_COMPLEX_ASSEMBLY | -1.36 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_NUCLEOSIDE_TRIPHOSPHATE_BIOSYNTHETIC_PROCESS | -0.81 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_MITOCHONDRIAL_TRANSLATION | -1.21 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_NUCLEOTIDE_BIOSYNTHETIC_PROCESS | -0.91 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_RIBOSE_PHOSPHATE_BIOSYNTHETIC_PROCESS | -0.81 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_MITOCHONDRIAL_ELECTRON_TRANSPORT_NADH_TO_UBIQUINONE | -1.00 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_MITOCHONDRIAL_TRANSPORT | -0.94 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_CYTOCHROME_COMPLEX_ASSEMBLY | -1.50 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_INNER_MITOCHONDRIAL_MEMBRANE_ORGANIZATION | -1.32 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_NADH_DEHYDROGENASE_COMPLEX_ASSEMBLY | -1.11 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_RESPIRATORY_CHAIN_COMPLEX_IV_ASSEMBLY | -1.48 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_PROTEIN_IMPORT_INTO_MITOCHONDRIAL_MATRIX | -1.09 | exploratório (efeito fixo, 2 estudos) |
| musculo | M4 | exploratório (efeito fixo, 2 estudos) | GO_BP | GOBP_MITOCHONDRIAL_MEMBRANE_ORGANIZATION | -1.11 | exploratório (efeito fixo, 2 estudos) |
| musculo | M6 | exploratório (efeito fixo, 2 estudos) | Reactome | REACTOME_O_LINKED_GLYCOSYLATION | 0.87 | exploratório (efeito fixo, 2 estudos) |

Correção de 07/10/2026: a 1ª execução usou a GSEA pré-ordenada para a significância e deu milhares de vias com FDR < 0,05 (inflação por genes correlacionados); a significância passou a vir do escore por amostra.
