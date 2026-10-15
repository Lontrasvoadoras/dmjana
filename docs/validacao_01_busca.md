# Validação da etapa 01: busca no GEO

Gerado em 12/10/2026 12:10 a partir de `output/01_busca/`. **Aprovar antes de seguir para a etapa 02 (metadados).**

## 1. Consultas (uma por tecido)

| Tecido | Séries encontradas |
|---|---:|
| ilhotas | 195 |
| musculo | 74 |
| adiposo | 140 |
| figado | 180 |
| sangue | 144 |
| osso | 23 |
| endometrio_ovario | 10 |
| mama | 23 |
| vasos | 159 |

Texto exato de cada consulta em `output/01_busca/consultas.csv`. Exemplo (ilhotas): `("type 2 diabetes" OR "type 2 diabetic" OR "diabetes mellitus type 2" OR "type II diabetes" OR "T2D" OR "T2DM" OR "non-insulin-dependent diabetes" OR "NIDDM" OR "diabetic") AND ("pancreatic islet" OR "islets" OR "beta cells" OR "beta-cells" OR "pancreas") AND "Homo sapiens"[Organism] AND gse[ETYP] AND ("Expression profiling by array"[DataSet Type] OR "Expression profiling by high throughput sequencing"[DataSet Type]) AND ("2000/01/01"[PDAT] : "3000"[PDAT])`

## 2. Triagem

- **695 séries únicas** (uma série pode aparecer em mais de um tecido).
- **Incluídas:** 415. **Para revisão manual:** 92. **Excluídas:** 188.

| Motivo de exclusão | Séries |
|---|---:|
| título fora do escopo (termo no título) | 81 |
| tecido fora do escopo no título (termo no título) | 70 |
| menos de 4 amostras | 37 |

## 3. Incluídas por tecido

| Tecido | Séries incluídas |
|---|---:|
| adiposo | 103 |
| endometrio_ovario | 5 |
| figado | 110 |
| ilhotas | 105 |
| mama | 8 |
| musculo | 64 |
| osso | 12 |
| sangue | 98 |
| vasos | 73 |

A mesma série conta em todos os tecidos em cuja consulta apareceu. O tecido real de cada amostra é lido na etapa 02.

## 4. Sensibilidade: estudos-semente (estudos já conhecidos com mulheres de 40–60)

A busca encontrou **13 de 13** sementes sem ajuda. As não encontradas indicam termos que faltam.

| Semente | Tecido | Encontrada pela busca | Triagem |
|---|---|---|---|
| GSE18732 | musculo | sim | incluido |
| GSE25462 | musculo | sim | incluido |
| GSE21340 | musculo | sim | incluido |
| GSE41762 | ilhotas | sim | incluido |
| GSE76894 | ilhotas | sim | incluido |
| GSE76895 | ilhotas | sim | incluido |
| GSE20966 | ilhotas | sim | incluido |
| GSE221156 | ilhotas | sim | revisar |
| GSE198922 | adiposo | sim | incluido |
| GSE15653 | figado | sim | incluido |
| GSE156993 | sangue | sim | incluido |
| GSE184050 | sangue | sim | incluido |
| GSE153315 | sangue | sim | incluido |

## 5. Comparação com a busca do workflow_multi_estruturado (5 tecidos)

- Incluídas nas duas: 211.
- Só nesta busca: 204 (sobretudo dos tecidos novos: osso, endométrio/ovário, mama, vasos).
- Só na anterior: 15 (GSE115421, GSE121344, GSE1322, GSE15932, GSE166047, GSE185011, GSE192889, GSE201908, GSE228662, GSE228665, GSE239512, GSE271708, GSE35764, GSE41332, GSE64998).

## 5b. Mudanças da auditoria de 06/10/2026

116 séries mudaram de triagem com as regras corrigidas (mesma busca):

| Mudança | Séries |
|---|---:|
| excluido → incluido | 67 |
| excluido → revisar | 49 |

| GSE | Antes | Agora | Motivo agora | Título |
|---|---|---|---|---|
| GSE101207 | excluido | revisar | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | High-throughput single cell transcriptome analysis and CRISPR screen identify ke |
| GSE102295 | excluido | incluido |  | Circulating Exosomal miR-20b-5p is Elevated in Type 2 Diabetes and Could Impair  |
| GSE102371 | excluido | incluido |  | Functional Genomics Analysis of Islets from Recent and Longstanding T1D Reveals  |
| GSE104120 | excluido | incluido |  | Expression analysis of BMP7 responsive P2RY1/ALK3 expressing progenitor like cel |
| GSE106181 | excluido | revisar | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Stable oxidative cytosine modifications accumulate in cardiac mesenchymal cells  |
| GSE106813 | excluido | incluido |  | Genome-wide analysis of PDX1 target genes in human pancreatic progenitors [expre |
| GSE118139 | excluido | incluido |  | Gene expression signatures for human non-diabetic (hND) islets and human type 2  |
| GSE119947 | excluido | incluido |  | Chromatin conformation dynamics are essential to control the transcription of IN |
| GSE121344 | excluido | revisar | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | A MAFG-lncRNA axis links systemic nutrient abundance to hepatic glucose metaboli |
| GSE121346 | excluido | revisar | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | A MAFG-lncRNA axis links systemic nutrient abundance to hepatic glucose metaboli |
| GSE123844 | excluido | incluido |  | Diabetes Remission Using Glucose-Responsive Insulin-Producing Human alpha-Cells |
| GSE124810 | excluido | incluido |  | Epigenetic modulation of β-cells by interferon-α via PNPT11-miR-26a-TET2 trigger |
| GSE125590 | excluido | incluido |  | Point mutations in the PDX1 transactivation domain impair human β-cell developme |
| GSE12793 | excluido | incluido |  | Analysis of Rosiglitazone therapy on adipose tissue in type 2 diabetic patients |
| GSE130208 | excluido | incluido |  | The Stearyl CoA desaturase is a gatekeeper that protects human ß cells against l |
| GSE132187 | excluido | incluido |  | Hyperglycemia acts in synergy with hypoxia to maintain the pro-inflammatory phen |
| GSE134901 | excluido | revisar | mais de uma espécie (Homo sapiens; Mus; Mus musculus): só as amostras humanas contam na etapa 02 | Nutrient regulation of the islet epigenome controls adaptive insulin secretion |
| GSE135356 | excluido | revisar | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | Stress-induced RNA–chromatin interactions promote endothelial dysfunction (scRNA |
| GSE136887 | excluido | incluido |  | scGOF-Seq using ND islets |
| GSE137766 | excluido | incluido |  | Perturb-Seq using T2D islets |
| GSE141126 | excluido | incluido |  | Transcriptome analysis-identified long noncoding RNA CRNDE in maintaining endoth |
| GSE150212 | excluido | revisar | célula única ou núcleo único (termo: single-nucleus): avaliar desenho por doador | Using single-nucleus RNA-sequencing to interrogate transcriptomic profiles of ar |
| GSE150724 | excluido | incluido |  | Generation of Human Islet Cell-Type-Specific Identity Genesets |
| GSE151588 | excluido | incluido |  | Identification of an Anti-diabetic, Orally Available Small Molecule that Regulat |
| GSE158001 | excluido | revisar | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | HyPR-seq: Single-cell quantification of chosen RNAs via hybridization and sequen |
| GSE158003 | excluido | revisar | mais de uma espécie (Mus musculus; Homo sapiens): só as amostras humanas contam na etapa 02 | HyPR-seq: Single-cell quantification of chosen RNAs via hybridization and sequen |
| GSE161989 | excluido | incluido |  | Adipocyte Precursor Cells from First Degree Relatives of type 2 diabetic patient |
| GSE162173 | excluido | revisar | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | lncRNA expression profile in placenta of diabetic macrosomia and normal birth we |
| GSE162837 | excluido | incluido |  | RNAsequencing of control and STAT3 knocked down transriptomes of EndoC cells |
| GSE163947 | excluido | revisar | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | MYCL-mediated in vivo reprogramming expands pancreatic insulin-producing cells t |
| GSE167589 | excluido | incluido |  | Integrin avb5 heterodimer is a specific marker of human pancreatic beta cells |
| GSE168437 | excluido | incluido |  | Expression data from peripheral blood mononuclear cells（PBMCs) in newly diagnose |
| GSE175735 | excluido | incluido |  | The effect of homocysteine on Human Aortic Endothelial Cells [RNA] |
| GSE176068 | excluido | revisar | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Hyperglycaemia induces trained immunity in macrophages and their precursors and  |
| GSE176171 | excluido | revisar | mais de uma espécie (Mus musculus; Homo sapiens): só as amostras humanas contam na etapa 02 | A single cell atlas of human adipose tissue |
| GSE177050 | excluido | incluido |  | Transcriptome analysis of liver from  subjects with normal glucose tolerance and |
| GSE180504 | excluido | incluido |  | Impaired bone fracture healing in type 2 diabetes is caused by defective functio |
| GSE182208 | excluido | incluido |  | Endothelial Phospholipase C gamma2 Improves Outcomes of Diabetic Ischemic Limb R |
| GSE185011 | excluido | revisar | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | The expression of mRNA and lncRNA in peripheral blood mononuclear cells (PBMCs)  |
| GSE185152 | excluido | revisar | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | The RANBP2/Importin-7-FOXO1 axis provides superior cold protection to aid islet  |
| GSE185749 | excluido | revisar | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Transcriptome-wide N6-methyladenine profiling in low input multiplex samples by  |
| GSE187349 | excluido | incluido |  | Transcriptional profiles of CD27 negative and positive MAIT cells from PBMC of d |
| GSE189007 | excluido | incluido |  | Gene-expression profiles of whole blood cells from a Han Chinese population with |
| GSE189538 | excluido | incluido |  | RNA-expression analysis on smooth muscle cells of diabetic donors after empaglif |
| GSE189923 | excluido | revisar | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | LncRNA expression profile and target gene prediction of calcification in human a |
| GSE194061 | excluido | incluido |  | Limited extent and consequences of pancreatic SARS-CoV-2 infection |
| GSE196797 | excluido | revisar | título cita outro tipo de dado (termo: microRNA); a série também é de expressão: confirmar | microRNA Expression in Normal and Diabetic Pancreatic Islets |
| GSE197399 | excluido | revisar | mais de uma espécie (Mus musculus; Homo sapiens): só as amostras humanas contam na etapa 02 | Redistribution of lamina-associated domains reshapes Foxa2 binding in developmen |
| GSE197955 | excluido | revisar | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | Vascular Regulation by Super Enhancer-Derived LINC00607 (scRNA-Seq) |
| GSE198906 | excluido | revisar | mais de uma espécie (Rattus norvegicus; Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Control of pancreatic islet function and glucose homeostasis by a novel microexo |
| GSE200044 | excluido | revisar | título cita outro tipo de dado (termo: ATAC); a série também é de expressão: confirmar | Single-cell multiome (ATAC and RNA) landscapes of human islets in normoglycemia, |
| GSE201105 | excluido | incluido |  | Effect of elevated glucose on gene expression during foam cell formation. |
| GSE202151 | excluido | revisar | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | LncRNA LYPLAL1-DT screening from type 2 diabetes with macrovascular complication |
| GSE202856 | excluido | incluido |  | Impaired angiogenesis in diabetic critical limb ischemia is mediated by a miR-13 |
| GSE204705 | excluido | incluido |  | Impaired angiogenesis in diabetic critical limb ischemia is mediated by a miR-13 |
| GSE210778 | excluido | revisar | título cita outro tipo de dado (termo: microRNA); a série também é de expressão: confirmar | MicroRNA-375 repression of Kruppel-like Factor 5 Improves Angiogenesis in Diabet |
| GSE21321 | excluido | revisar | título cita outro tipo de dado (termo: microRNA); a série também é de expressão: confirmar | Blood microRNA profiles and upregulation of hsa-miR-144 in males with type 2 dia |
| GSE213910 | excluido | incluido |  | 1α,25(OH)2D3 remodels γδ T cell metabolism and ameliorates insulin resistance |
| GSE218316 | excluido | revisar | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell transcriptomics of primary human pancreatic islet cells exposed to s |
| GSE229207 | excluido | revisar | título cita outro tipo de dado (termo: microRNA); a série também é de expressão: confirmar | Regulation of oxidative stress in endothelial cells exposed to high glucose by s |
| GSE233164 | excluido | incluido |  | Effect of high glucose on gene expression alteration in ARPE-19 cells |
| GSE234148 | excluido | revisar | mais de uma espécie (Mus musculus; Homo sapiens): só as amostras humanas contam na etapa 02 | Pharmacological HDAC inhibition impairs pancreatic β-cell function through a gen |
| GSE236139 | excluido | incluido |  | Magnesium promotes vascularized osseointegration in diabetic states |
| GSE239335 | excluido | incluido |  | Checkpoint Kinase 2 Controls Insulin Secretion and Glucose Homeostasis |
| GSE242555 | excluido | incluido |  | Illuminating the functions of understudied Fructosamine-3-kinase (FN3K) using a  |
| GSE246318 | excluido | revisar | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Decoding the immune checkpoint signatures in human atherosclerosis: implications |
| GSE248609 | excluido | revisar | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | Spatial Multiomics Reveals Metabolic Reprogramming and Calcification Characteris |
| GSE249277 | excluido | incluido |  | Gene expression of glucose homeostasis in a pancreas-liver microphysiological sy |
| GSE249310 | excluido | incluido |  | Harmine and Exendin-4 Combination Therapy Safely Expands Human Beta Cell Mass In |
| GSE249735 | excluido | incluido |  | An integrative approach zinc induced integrated stress response as a key driver  |
| GSE26168 | excluido | revisar | título cita outro tipo de dado (termo: miRNA); a série também é de expressão: confirmar | Type 2 Diabetes mellitus: mRNA and miRNA profiling |
| GSE264633 | excluido | incluido |  | LY6H is a specific marker of human pancreatic delta cells |
| GSE272114 | excluido | incluido |  | Dynamic chromatin accessibility and transcriptome changes following PDGF-BB trea |
| GSE277551 | excluido | revisar | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | HNF1A regulates a β-cell RNA splicing program that is disrupted in type 2 diabet |
| GSE278526 | excluido | revisar | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | A Transcriptional and Cellular Exploration of Obesity and Type-II Diabetes in Hu |
| GSE280401 | excluido | revisar | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Deciphering the Transcriptomic Landscape of Type 2 Diabetes: Insights from Bulk  |
| GSE281291 | excluido | revisar | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | Identification of lncRNA PRNCR1/miR-642a-5p/SSTR3 ceRNA network as novel biomark |
| GSE281902 | excluido | revisar | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Periosteum Signatures of Delayed Fracture Healing in Type 2 Diabetes at Single-C |
| GSE28384 | excluido | revisar | mais de uma espécie (Mus musculus; Homo sapiens): só as amostras humanas contam na etapa 02 | Amorfrutins are selective PPARγ agonists with potent antidiabetic properties |
| GSE289206 | excluido | incluido |  | G0S2 modulates normal vitreous-induced proliferation in endothelial cells [2] |
| GSE291008 | excluido | incluido |  | Activin A prevents hyper-responsiveness to VEGF in pathological blood vessels by |
| GSE291636 | excluido | revisar | mais de uma espécie (Mus musculus; Homo sapiens): só as amostras humanas contam na etapa 02 | RBBP6 orchestrates diabetic endothelial dysfunction viadisrupting JUNB-centric c |
| GSE298690 | excluido | revisar | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | Integrated transcriptome and single-cell sequencing analysis identify blood-panc |
| GSE303974 | excluido | incluido |  | Global Gene Expression  profiling of Whole Blood RNA of  Type 2 Diabetes (T2D) a |
| GSE305251 | excluido | incluido |  | Lactyl-HDAC1-Mediated Epigenetic Gating of Angiogenic Transcription via Metaboli |
| GSE307152 | excluido | incluido |  | Metabolic Adaptations to the Integrated Stress Response Enable TNBC Survival Upo |
| GSE307153 | excluido | incluido |  | Metabolic Adaptations to the Integrated Stress Response Enable TNBC Survival Upo |
| GSE309942 | excluido | revisar | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | Immunometabolic Endotypes Define Distinct Clinical Trajectories in Type 2 Diabet |
| GSE316326 | excluido | incluido |  | EZH2 inhibition via GSK-126 mitigates EndMT and atherosclerosis in diabetes: A t |
| GSE317209 | excluido | incluido |  | Mapping Endothelial-Macrophage Interactions in Diabetic Vasculature: Role of TRE |
| GSE326590 | excluido | incluido |  | NAT10-mediated N4-acetylcytidine modification drives RNA splicing of PML to alle |
| GSE331464 | excluido | incluido |  | ALKBH3 inhibition normalizes neovessels by reprogramming endothelial fate in dia |
| GSE333721 | excluido | incluido |  | A dish-to-biobank framework links β-cell nutrient-stress programs to genetic and |
| GSE338786 | excluido | incluido |  | Delay of Diabetic Cataract Progression by a Chemical Chaperone Trimethylamine N- |
| GSE36084 | excluido | incluido |  | Gene expression data from human lymphocytes |
| GSE3881 | excluido | incluido |  | Skeletal muscle and insulin regulated genes |
| GSE45777 | excluido | incluido |  | A stem cell model of diabetes due to glucokinase deficiency |
| GSE47060 | excluido | incluido |  | Expression data from human OC+BAP+ double positive versus OC-BAP- double negativ |
| GSE4901 | excluido | incluido |  | Effects of laughter on gene expression profiles patients with type 2 diabetes (T |
| GSE50005 | excluido | revisar | mais de uma espécie (Macaca mulatta; Homo sapiens): só as amostras humanas contam na etapa 02 | Resveratrol improves adipose insulin signaling and reduces the inflammatory resp |
| GSE51310 | excluido | incluido |  | Chromatin stretch enhancer states drive cell-specific gene regulation and harbor |
| GSE57928 | excluido | revisar | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Towards epigenetic understanding and therapy of insulin resistance by intranucle |
| GSE58249 | excluido | revisar | título cita outro tipo de dado (termo: methylation); a série também é de expressão: confirmar | Multi-Omic Integrated networks connect DNA methylation and miRNA with skeletal m |
| GSE58250 | excluido | revisar | título cita outro tipo de dado (termo: methylation); a série também é de expressão: confirmar | Multi-Omic Integrated networks connect DNA methylation and miRNA with skeletal m |
| GSE63887 | excluido | incluido |  | RNA-sequencing of healthy human skeletal myocytes |
| GSE64998 | excluido | revisar | título cita outro tipo de dado (termo: methylation); a série também é de expressão: confirmar | Altered DNA methylation of glycolytic and lipogenic genes in liver from obese an |
| GSE65058 | excluido | revisar | título cita outro tipo de dado (termo: methylation); a série também é de expressão: confirmar | Altered DNA methylation of glycolytic and lipogenic genes in liver from obese an |
| GSE66785 | excluido | incluido |  | Differential mRNA expression profile regulated by HNF4α in Hep3B cells |
| GSE67141 | excluido | incluido |  | High-throughput sequencing reveals key genes and immune homeostatic pathways act |
| GSE70365 | excluido | incluido |  | Effect of TDNC1 ectopic expression on global gene expression pattern |
| GSE73037 | excluido | revisar | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Cross-species Gene Expression Analysis Identifies a Novel Set of Genes Implicate |
| GSE76161 | excluido | incluido |  | Gene expression profiling in human precision-cut liver slices upon treatment wit |
| GSE76268 | excluido | revisar | título cita outro tipo de dado (termo: ATAC); a série também é de expressão: confirmar | Integration of ATAC-seq and RNA-seq Identifies Human Alpha Cell and Beta Cell Si |
| GSE77962 | excluido | incluido |  | Adipose tissue gene expression is differentially regulated with different rates  |
| GSE80714 | excluido | incluido |  | The beneficial effect of pterocarpan-rich extract from soybean leaf on metabolic |
| GSE98680 | excluido | revisar | título cita outro tipo de dado (termo: miRNA); a série também é de expressão: confirmar | mRNA/miRNA expression profiles of human primary adipocytes exposed to low doses  |

## 6. Séries incluídas

| GSE | Tecidos da busca | Amostras | Título |
|---|---|---:|---|
| GSE101931 | figado;sangue | 38 | Acute Exercise Bout Effects on GH and IGF1 in Prediabetic and Healthy African Americans |
| GSE102295 | musculo | 6 | Circulating Exosomal miR-20b-5p is Elevated in Type 2 Diabetes and Could Impair Insulin Action in Human Skelet |
| GSE102371 | ilhotas | 5 | Functional Genomics Analysis of Islets from Recent and Longstanding T1D Reveals the Need for Distinct Approach |
| GSE102633 | sangue | 22 | Metformin alters human host responses to Mycobacterium tuberculosis in-vitro and in healthy human subjects [Ex |
| GSE102677 | sangue | 44 | Metformin alters human host responses to Mycobacterium tuberculosis in-vitro and in healthy human subjects [PB |
| GSE103682 | figado;musculo | 16 | Short-term low calorie diet remodels skeletal muscle lipid profile and metabolic gene expression in obese adul |
| GSE104120 | ilhotas | 4 | Expression analysis of BMP7 responsive P2RY1/ALK3 expressing progenitor like cells within the human exocrine p |
| GSE104674 | adiposo | 48 | The diurnal rhythm of adipose tissue gene expression is reduced in obese patients with type 2 diabetes |
| GSE105167 | sangue | 11 | Diabetes Mellitus Drives Extracellular Vesicle Secretion and Promotes Increased Internalization by Circulating |
| GSE106148 | ilhotas | 8 | α Cell Function and Gene Expression Are Compromised in Type 1 Diabetes |
| GSE106737 | figado | 111 | Microarray analysis of liver biopsies at baseline and after one year follow up from 21 patients with histologi |
| GSE106800 | figado;musculo | 47 | Circadian misalignment induces fatty acid metabolism gene profiles and induces insulin resistance in human ske |
| GSE106813 | figado;ilhotas | 4 | Genome-wide analysis of PDX1 target genes in human pancreatic progenitors [expression profiling] |
| GSE108413 | ilhotas | 10 | Conventional and neo-antigenic peptides naturally processed and presented by beta cells are targeted by circul |
| GSE108971 | adiposo | 16 | Novel Atherogenic Pathways from the Differential Transcriptiome Analysis of Diabetic Epicardial Adipose Tissue |
| GSE109140 | figado | 12 | Valproic acid attenuates hyperglycemia induced complement and coagulation cascade gene expression |
| GSE111123 | figado;vasos | 18 | Methylglyoxal Down-Regulates the Expression of Cell Cycle Associated Genes and Activates the P53 Pathway in Hu |
| GSE114297 | ilhotas | 12 | Pseudotime Ordering of Single Human Beta-Cells Reveals States of Insulin Production and Unfolded Protein Respo |
| GSE115020 | adiposo | 52 | Culture of mature adipocytes under a permeable membrane and comparative analysis with different cell culture m |
| GSE115827 | adiposo;figado | 12 | RNA-seq data from human SGBS adipocytes differentiated with marine oxohexadecenoic acids |
| GSE116369 | ilhotas | 8 | Discovering human diabetes-risk gene function with genetics and physiological assays |
| GSE117454 | ilhotas | 39 | Diabetes Remission Using Glucose-Responsive Insulin-Producing Human α-Cells |
| GSE118139 | ilhotas | 4 | Gene expression signatures for human non-diabetic (hND) islets and human type 2 diabetes mellitus (hT2DM) isle |
| GSE118230 | ilhotas | 30 | Identification of early biological changes in palmitate-treated isolated human islets |
| GSE118280 | adiposo | 90 | Effects of temporal segmentation of meal composition on human adipose tissue transcriptome |
| GSE119296 | vasos | 38 | Whole genome transcriptomics of pre-access veins and hemodialysis arteriovenous fistula (AVF) samples from two |
| GSE119947 | figado;vasos | 4 | Chromatin conformation dynamics are essential to control the transcription of INK4/ARF locus |
| GSE120299 | ilhotas | 12 | Human Pancreatic Islets Expressing HNF1A Variant Have Defective β cell Transcriptional Regulatory Networks |
| GSE121 | musculo | 50 | Type 2 diabetes and insulin resistance |
| GSE121863 | ilhotas | 18 | HLA Class II analysis of human pancreatic beta cells |
| GSE123658 | sangue | 82 | Transimmunom whole blood RNA-seq data  from type 1 diabetic patients and healthy volunteers |
| GSE123844 | ilhotas | 4 | Diabetes Remission Using Glucose-Responsive Insulin-Producing Human alpha-Cells |
| GSE124810 | ilhotas | 6 | Epigenetic modulation of β-cells by interferon-α via PNPT11-miR-26a-TET2 triggers autoimmune diabetes [RNA-seq |
| GSE124811 | ilhotas | 12 | Epigenetic modulation of β-cells by interferon-α via PNPT11-miR-26a-TET2 triggers autoimmune diabetes |
| GSE125590 | figado;ilhotas | 4 | Point mutations in the PDX1 transactivation domain impair human β-cell development and function (mRNA microarr |
| GSE125769 | figado;ilhotas | 57 | Point mutations in the PDX1 transactivation domain impair human β-cell development and function (RNA-Seq) |
| GSE126101 | musculo | 12 | Skeletal muscle enhancer interactions identify genes controlling whole body metabolism in humans [RNA-seq] |
| GSE126169 | adiposo | 9 | MAIT cell RNA sequencing |
| GSE12643 | musculo | 20 | Transcription profiling of myotubes from patients with type 2 diabetes |
| GSE12793 | adiposo | 6 | Analysis of Rosiglitazone therapy on adipose tissue in type 2 diabetic patients |
| GSE12844 | musculo | 17 | Effect of rosiglitazone treatment on insulin sensitivity in type 2 diabetic patients skeletal muscle |
| GSE128665 | adiposo | 24 | Elevated Extra-cellular Matrix Signaling in Adipose Mesothelial Cells is Linked to Insulin Resistance in Obesi |
| GSE12894 | adiposo | 14 | Effect of rosiglitazone treatment on insulin sensitivity in adipose tissue of type 2 diabetic patients |
| GSE12895 | adiposo | 20 | Rosiglitazone effect on type 2 diabetic patients: adipose tissue |
| GSE129042 | adiposo;vasos | 15 | Identification of metabolically distinct adipocyte progenitor cells in human adipose tissues |
| GSE13015 | sangue | 106 | Genomic Transcriptional Profiling Identifies a Blood Biomarker Signature for the Diagnosis of Septicemic Melio |
| GSE130208 | ilhotas | 6 | The Stearyl CoA desaturase is a gatekeeper that protects human ß cells against lipotoxicity and maintains thei |
| GSE130991 | figado | 910 | Liver transcriptome of statin-treated patients |
| GSE131169 | adiposo | 23 | Transcriptomic and Chromatin accessibility profiling of functional brown adipocytes derived from human pluripo |
| GSE132187 | figado | 6 | Hyperglycemia acts in synergy with hypoxia to maintain the pro-inflammatory phenotype of macrophages |
| GSE133099 | adiposo | 18 | A transcriptomic analysis of primary mature adipocytes from lean, obese, and type 2 diabetic subjects: role of |
| GSE133666 | adiposo | 18 | Gene expression data from human omental adipose tissue |
| GSE134438 | adiposo;figado | 43 | A Novel Factor Associating with Hepatic Insulin Sensitivity in Humans with Nonalcoholic Fatty Liver Disease |
| GSE135155 | adiposo;vasos | 12 | Adipocyte serine uptake curbs ROS generation and visceral adiposity [Human] |
| GSE135357 | vasos | 32 | Stress-induced RNA–chromatin interactions promote endothelial dysfunction |
| GSE135776 | adiposo;vasos | 72 | Transcriptome profiling of subcutaneous and visceral adipose tissue from obese individuals |
| GSE135944 | ilhotas | 16 | SC-beta Cell in vivo Maturation |
| GSE136344 | musculo | 30 | Muscle transcriptomic profiling of chronological aging and metabolic syndrome in men |
| GSE136887 | ilhotas | 7 | scGOF-Seq using ND islets |
| GSE137317 | sangue | 74 | Metformin-induced alterations in peripheral blood cell trancriptome of healthy individuals |
| GSE13760 | mama;vasos | 21 | Gene expression profiling in arterial tissue from type 2 diabetic patients |
| GSE137766 | ilhotas | 4 | Perturb-Seq using T2D islets |
| GSE138781 | figado | 8 | The role of TCF7L2 rs290487 variant in hepatic glucose metabolism: an integrated analysis of clinical and mult |
| GSE139073 | figado;osso | 40 | Multi-Parameter Analysis of Biobanked Human Bone Marrow Stromal Cells Shows Little Influence for Donor Age and |
| GSE139929 | figado | 9 | Combined use of astragalus polysaccharide and berberine attenuates insulin resistance in IR-HepG2 cells via re |
| GSE141126 | vasos | 6 | Transcriptome analysis-identified long noncoding RNA CRNDE in maintaining endothelial cell proliferation, migr |
| GSE141309 | ilhotas | 14 | In vivo hyperglycemia exposure elicits distinct period-dependent effects on human pancreatic progenitor differ |
| GSE141432 | adiposo | 25 | Obese Insulin Resistant Humans with Compensatory Hyperinsulinemia Dissociate Lipolysis from Glycemia as Possib |
| GSE142153 | sangue | 40 | Human PBMCs: Healthy vs Diabetic nephropathy vs ESRD |
| GSE142385 | figado | 12 | A long noncoding RNA, LOC157273, is the effector transcript at the chromosome 8p23.1-PPP1R3B metabolic traits  |
| GSE143319 | adiposo;figado | 50 | Inhibition of Grb14, a negative modulator of insulin signaling,  improves glucose homeostasis without causing  |
| GSE143979 | musculo | 15 | Skeletal muscle regeneration is compromised in advanced diabetic peripheral neuropathy |
| GSE144414 | figado | 20 | A Critical Role of Hepatic GABA in The Metabolic Dysfunction and Hyperphagia of Obesity |
| GSE144605 | adiposo;figado;vasos | 12 | Gene expression profiles of human retinal microvascular pericytes (HRMVPC) and human lipoaspirate derived mese |
| GSE145284 | adiposo | 24 | The omentum of obese girls harbors small adipocytes and browning transcrips |
| GSE146028 | sangue | 37 | Comparison of Regulatory Type of Macrophages and PCMO Cells from perspective of RNAseq data. |
| GSE146108 | vasos | 15 | VEGF-B Signaling Impairs Endothelial Glucose Transcytosis via an LDLR-dependent Decrease in Membrane Cholester |
| GSE147598 | mama;vasos | 12 | Transcriptomic effects of insulin Lantus M1 on human internal mammary arteries |
| GSE14839 | ilhotas | 19 | Differences in gene expression in islets isolated from pancreata donated after Cardiac Death relative to Brain |
| GSE148896 | adiposo | 15 | Transcriptomic changes in response to modulation of long-non-coding RNA, LINC00473 |
| GSE149148 | ilhotas | 70 | Pancreatic progenitor epigenome maps prioritize type 2 diabetes risk genes with roles in development |
| GSE150119 | adiposo | 20 | Transcriptomic changes in response to modulation of long-non-coding RNA LINC00473 |
| GSE150724 | ilhotas | 6 | Generation of Human Islet Cell-Type-Specific Identity Genesets |
| GSE151588 | figado;ilhotas | 6 | Identification of an Anti-diabetic, Orally Available Small Molecule that Regulates TXNIP Expression and Glucag |
| GSE151683 | adiposo;sangue | 46 | DNA microarray analysis of blood before and after ingesting carotenoid-rich vegitable beverage for 8 weeks, a  |
| GSE152517 | adiposo;figado | 60 | Loss of G protein pathway suppressor 2 in human adipocytes triggers lipid remodeling through upregulation of A |
| GSE153315 | sangue | 30 | Transcriptome analysis of Newly Diagnosed Type 2 Diabetes Subjects identifies genes to predict Metformin drug  |
| GSE153391 | adiposo;figado | 9 | Expression data from adipocyte differentiation from diabetic adipose-derived stem cells (dADSC) treated with s |
| GSE153792 | sangue | 34 | Whole-blood transcriptome profiling reveals signatures of metformin and its therapeutic response |
| GSE153837 | sangue | 28 | Effects of oral-glucose load on the gene expression of peripheral blood mono-nuclear cells in Asian-Indian men |
| GSE156061 | sangue;vasos | 10 | Profiling of CD14+ monocytes from humans with Type diabetes and without diabetes [RNA-Seq] |
| GSE156109 | ilhotas | 12 | Combined transcriptome and proteome profiling of the pancreatic β-cell response to palmitate unveils key pathw |
| GSE156122 | sangue | 14 | Profiling of CD14+ monocytes from humans with Type diabetes and without diabetes |
| GSE156247 | adiposo;musculo | 36 | Comparative transcriptome analysis of human skeletal muscle in response to cold acclimation and exercise train |
| GSE156248 | adiposo;musculo | 14 | Comparative transcriptome analysis of human skeletal muscle in response to cold acclimation and exercise train |
| GSE156249 | musculo | 50 | Comparative transcriptome analysis of human skeletal muscle in response to cold acclimation and exercise train |
| GSE156340 | vasos | 8 | Stress-induced RNA–chromatin interactions promote endothelial dysfunction (RNA-seq) |
| GSE15653 | figado | 18 | Expression data from liver of obese (with or without type 2 diabetes) and lean human subjects. |
| GSE156993 | sangue | 30 | Transcriptomic analysis of peripheral blood mononuclear cells (PBMC) of patients with type 2 Diabetes Melittus |
| GSE157859 | sangue | 85 | Whole transcriptome sequencing of peripheral blood mononuclear cells from patients with COVID-19 |
| GSE15790 | adiposo | 40 | Preadipocytes of T2DM patients display an intrinsic gene expression profile of decreased differentiation capac |
| GSE159955 | adiposo | 21 | Changes in CIDEA expression associate with adipocytes size and functionality in adolescent obese girls |
| GSE159984 | figado;ilhotas | 131 | Persistent or Transient Human β-cell Dysfunction Induced by Metabolic Stress Associated with Specific Signatur |
| GSE161719 | musculo | 38 | Relationship between insulin sensitivity and gene expression in human skeletal muscle (Study A) |
| GSE161720 | musculo | 9 | Relationship between insulin sensitivity and gene expression in human skeletal muscle (Study B) |
| GSE161721 | musculo | 47 | Relationship between insulin sensitivity and gene expression in human skeletal muscle |
| GSE161749 | adiposo;musculo | 49 | Acute and long-term exercise adaptation of adipose tissue and skeletal muscle in humans: a matched transcripto |
| GSE161750 | adiposo;musculo | 48 | Acute and long-term exercise adaptation of adipose tissue and skeletal muscle in humans: a matched transcripto |
| GSE161989 | adiposo;sangue | 4 | Adipocyte Precursor Cells from First Degree Relatives of type 2 diabetic patients feature changes of hsa-mir-2 |
| GSE162135 | adiposo | 8 | Adipocyte Precursor Cells from First Degree Relatives of type 2 diabetic patients feature changes of hsa-mir-2 |
| GSE162689 | ilhotas | 59 | A histological and transcriptional characterization of the pancreatic acinar tissue in type 1 diabetes |
| GSE162837 | ilhotas | 6 | RNAsequencing of control and STAT3 knocked down transriptomes of EndoC cells |
| GSE16415 | adiposo | 10 | Genome wide gene expression profiling of visceral adipose tissue among Asian Indian diabetics |
| GSE164416 | ilhotas | 133 | Multi-omics profiling of living human pancreatic islet donors reveals heterogeneous beta cell trajectories tow |
| GSE164934 | adiposo;figado | 26 | Ayurvedic herbal preparation supplementation does not improve metabolic health in impaired glucose tolerance s |
| GSE165121 | ilhotas | 35 | Transcriptional analysis of islets of Langerhans from organ donors of different ages |
| GSE166467 | figado;musculo | 52 | mRNA expression data for human muscle cells from individuals with type 2 diabetes and controls |
| GSE166502 | figado;musculo | 52 | mRNA expression data throughout human muscle cell differentiation in individuals with type 2 diabetes and cont |
| GSE167250 | figado;ilhotas | 36 | Glucocorticoid signaling in pancreatic islets modulates gene regulatory programs and genetic risk of type 2 di |
| GSE167589 | ilhotas | 6 | Integrin avb5 heterodimer is a specific marker of human pancreatic beta cells |
| GSE168437 | sangue | 4 | Expression data from peripheral blood mononuclear cells（PBMCs) in newly diagnosed type 2 diabetes |
| GSE168705 | adiposo | 96 | Ten-hour time-restricted eating improves glycaemic control and alters transcriptomic profile in adipose tissue |
| GSE171352 | ilhotas | 14 | Autophagy regulates glucagon secretion via the beta2-adrenergic pathway |
| GSE172148 | ilhotas | 18 | RNA sequencing of control and PTPN2 knocked down transcriptomes in EndoC-    H1 cells with or without the trea |
| GSE173323 | endometrio_ovario | 36 | Transcriptomic Drivers of Differentiation, Maturation, and Polyploidy in Human Extravillous Trophoblast [RNA-s |
| GSE174475 | adiposo;figado;musculo;vasos | 43 | Epigenomic and Transcriptional Basis of Human Insulin Resistance |
| GSE174502 | adiposo | 18 | RNA Sequencing Facilitates Quantitative Analysis of Transcriptomes of adipose stem cells from diabetic, old an |
| GSE17556 | vasos | 18 | Thrombospondin-1: A Pro-Atherosclerotic Protein Augmented by Hyperglycemia |
| GSE175735 | figado;vasos | 6 | The effect of homocysteine on Human Aortic Endothelial Cells [RNA] |
| GSE175988 | figado;sangue | 20 | RNA-seq of diabetic and case control human peripheral blood mononuclear cells (PBMC) |
| GSE176216 | sangue | 48 | RNA-sequencing of IRF5+ and IRF5- circulating monocytes from patients with Type-2 Diabetes |
| GSE176324 | ilhotas | 12 | Modeling pancreatic beta cell senescence by induction of DNA double-strand breaks |
| GSE17635 | sangue;vasos | 32 | Folic acid supplementation normalizes the endothelial progenitor cell transcriptome of patients with type 1 di |
| GSE177050 | figado | 6 | Transcriptome analysis of liver from  subjects with normal glucose tolerance and steatosis<1  compared  to sub |
| GSE179455 | adiposo | 19 | Transcriptome analysis of Epicardial Adipose Tissue from obese, diabetic and lean individulas |
| GSE180504 | adiposo;osso | 6 | Impaired bone fracture healing in type 2 diabetes is caused by defective functions of skeletal progenitor cell |
| GSE181096 | figado | 12 | Rescue of insulin receptor condensates in insulin resistant cells |
| GSE181674 | ilhotas | 18 | Islet Sympathetic Innervation and Islet Neuropathology in Patients with Type 1 Diabetes |
| GSE182117 | figado;musculo | 186 | Disrupted Circadian Oscillations in Type 2 Diabetes are Linked to Altered Rhythmic Mitochondrial Metabolism in |
| GSE182120 | musculo | 49 | Disrupted Circadian Oscillations in Type 2 Diabetes are Linked to Altered Rhythmic Mitochondrial Metabolism in |
| GSE182121 | figado;musculo | 235 | Disrupted Circadian Oscillations in Type 2 Diabetes are Linked to Altered Rhythmic Mitochondrial Metabolism in |
| GSE182208 | vasos | 7 | Endothelial Phospholipase C gamma2 Improves Outcomes of Diabetic Ischemic Limb Rescue Following VEGF Therapy |
| GSE182923 | osso | 18 | Altered Human Alveolar Bone Gene Expression in Type 2 Diabetes |
| GSE183568 | ilhotas | 26 | Combinatorial transcription factor profiles predict mature and functional human islet α and β cells |
| GSE184016 | figado;ilhotas | 9 | Lipid droplets protect human β-cells from lipotoxic-induced stress and cell identity changes |
| GSE184050 | ilhotas;sangue | 116 | Novel diabetes gene discovery through comprehensive characterization and integrative analysis of longitudinal  |
| GSE18612 | adiposo;vasos | 13 | Expression profiles of epicardial and subcutaneous adipose tissue |
| GSE18732 | musculo | 118 | mRNA expression data from skeletal muscle of type 2 diabetes |
| GSE187349 | sangue | 6 | Transcriptional profiles of CD27 negative and positive MAIT cells from PBMC of diabetic obese patients |
| GSE188234 | musculo | 15 | TGF-β-induced miR143/145 influences differentiation, insulin signaling and exercise response in human skeletal |
| GSE189005 | sangue | 45 | RNA expression profiles of whole blood cells from a Han Chinese population with or without Type-2 Diabetes Mel |
| GSE189007 | sangue | 130 | Gene-expression profiles of whole blood cells from a Han Chinese population with or without Type-2 Diabetes Me |
| GSE189538 | vasos | 6 | RNA-expression analysis on smooth muscle cells of diabetic donors after empagliflozin treatment |
| GSE189849 | adiposo;sangue;vasos | 9 | RNA-seq of human adipose tissue macrophage subtypes in obesity |
| GSE190361 | figado;ilhotas | 10 | SPOCK2 controls the proliferation and function of immature pancreatic β-cells through MMP2. |
| GSE19136 | mama;vasos | 12 | Gene expression response to implanted drug (paclitaxel)-eluting or bare metal stents in denuded human LIMA art |
| GSE193510 | figado;sangue;vasos | 8 | A miR-125 / Sirtuin-7 pathway drives pro-calcific potential of myeloid cells in diabetic vascular disease |
| GSE193626 | sangue | 18 | Exploring the mechanism of Jiangtang Tiaozhi Recipe in the treatment of obese T2DM patients with dyslipidemia  |
| GSE194061 | ilhotas | 6 | Limited extent and consequences of pancreatic SARS-CoV-2 infection |
| GSE19420 | musculo | 42 | Skeletal muscle mitochondrial dysfunction is secondary to T2DM |
| GSE196387 | musculo | 27 | Skeletal muscle tissue RNA-Seq and RRBS in T2D, Obese and Active subjects |
| GSE19790 | sangue | 22 | Resolution of Type 2 Diabetes Following Bariatric Surgery is Associated with Changes in Whole Blood Gene Expre |
| GSE197954 | vasos | 10 | Vascular Regulation by Super Enhancer-Derived LINC00607 (bulk RNA-Seq) |
| GSE198809 | adiposo | 46 | Changes in subcutaneous white adipose tissue cellular composition and molecular programs underlie glucose into |
| GSE198922 | adiposo;musculo | 144 | Exercise-induced Crosstalk between Immune Cells and Adipocytes in Humans: Role of Oncostatin-M |
| GSE200678 | adiposo;figado | 35 | Hepatic senescence is associated with clinical progression of NAFLD/NASH: Role of BMP4 and its antagonist Grem |
| GSE201087 | sangue;vasos | 78 | Cardiovascular risk in patients with type 2 diabetes is associated with alteration of blood monocyte phenotype |
| GSE201105 | sangue | 6 | Effect of elevated glucose on gene expression during foam cell formation. |
| GSE202206 | ilhotas | 68 | PAX4 loss of function alters human endocrine cell development and influences diabetes risk [dateset 1] |
| GSE202295 | musculo;vasos | 111 | Distinctive exercise-induced inflammatory response and exerkine induction in skeletal muscle of people with ty |
| GSE202856 | vasos | 6 | Impaired angiogenesis in diabetic critical limb ischemia is mediated by a miR-130b-INHBA signaling axis [ische |
| GSE203264 | ilhotas | 164 | PAX4 loss of function alters human endocrine cell development and influences diabetes risk [dataset 2] |
| GSE204705 | vasos | 6 | Impaired angiogenesis in diabetic critical limb ischemia is mediated by a miR-130b-INHBA signaling axis [Human |
| GSE204706 | vasos | 12 | Impaired angiogenesis in diabetic critical limb ischemia is mediated by a miR-130b-INHBA signaling axis |
| GSE205853 | figado;ilhotas;vasos | 75 | Type 1 diabetes risk genes mediate pancreatic beta cell survival in response to proinflammatory cytokines |
| GSE205891 | adiposo;figado;musculo | 62 | Worksite-based intensive lifestyle therapy has profound cardiometabolic benefits in people with obesity and ty |
| GSE20966 | ilhotas | 20 | Gene expression profiles of beta-cell enriched tissue obtained by Laser Capture Microdissection from subjects  |
| GSE21340 | ilhotas;musculo | 20 | Human skeletal muscle - type 2 diabetes and family history positive individuals - Mexican American |
| GSE21342 | sangue | 56 | Maternal influences on the transmission of leukocyte gene expression profiles in population samples (mother an |
| GSE21345 | figado;sangue | 156 | Maternal influences on the transmission of leukocyte gene expression profiles in population samples |
| GSE213910 | adiposo;sangue | 6 | 1α,25(OH)2D3 remodels γδ T cell metabolism and ameliorates insulin resistance |
| GSE214764 | figado;ilhotas | 14 | Bioengineered pancreas-liver crosstalk in a microfluidic co-culture chip identifies human metabolic response s |
| GSE216679 | sangue | 40 | Reduced CD8 T cell exhaustion in DR4 risk subjects is selectively augmented with therapy [CD8s] |
| GSE216680 | sangue | 251 | Reduced CD8 T cell exhaustion in DR4 risk subjects is selectively augmented with therapy. |
| GSE220796 | vasos | 41 | Whole genome transcriptomics of pre-access veins and hemodialysis arteriovenous fistula (AVF) samples from two |
| GSE221521 | sangue | 193 | Influence of diabetic retinopathy on peripheral blood gene expression |
| GSE221787 | figado;ilhotas | 165 | CITEseq of lymphocytes from pancreatic lymph nodes, mesenteric lymph nodes, and spleen from 17 Human Pancreas  |
| GSE222009 | ilhotas | 15 | Genome-wide CRISPR screening identifies SEC31A as a regulator of alpha cell survival |
| GSE222883 | figado;osso;sangue | 18 | Periodontitis-induced inflammation: impacts of hyperglycemic microenvironment |
| GSE22309 | musculo | 110 | Expression data from human skeletal muscle |
| GSE224310 | adiposo;musculo | 151 | Acute versus long-term exercise adaptation of adipose tissue and skeletal muscle in humans: A matched transcri |
| GSE228267 | ilhotas | 108 | m6A RIP-seq for Cytokine-treated Islets and Beta-cells or T1D Islets |
| GSE228572 | vasos | 16 | Transcriptomic Alterations in Diabetic Aortic Endothelial Cells Following Low-Dose Radiation Exposure |
| GSE228909 | sangue | 16 | Canagliflozin impairs T-cell effector function via metabolic suppression in autoimmunity [Autoimmune Profiling |
| GSE228910 | sangue | 12 | Canagliflozin impairs T-cell effector function via metabolic suppression in autoimmunity [Metabolic Pathways] |
| GSE231509 | figado;ilhotas;musculo | 42 | Dysregulation of mixed meal-induced gene expression in skeletal muscle in obesity and type 2 diabetes |
| GSE233164 | vasos | 6 | Effect of high glucose on gene expression alteration in ARPE-19 cells |
| GSE23343 | figado | 17 | Expression data from human liver with or without type 2 diabetes |
| GSE23561 | sangue;vasos | 35 | Peripheral blood gene expression profiles in metabolic syndrome, coronary artery disease and type 2 diabetes |
| GSE236139 | osso;vasos | 6 | Magnesium promotes vascularized osseointegration in diabetic states |
| GSE236191 | vasos | 47 | Specific biological processes associated with T2D-induced left ventricular dysfunction in patients with aortic |
| GSE237338 | adiposo;figado;sangue;vasos | 14 | Fat-to-blood recirculation of partially dysfunctional PD-1+CD4 Tconv cells is associated with dysglycemia in h |
| GSE239335 | figado;ilhotas | 6 | Checkpoint Kinase 2 Controls Insulin Secretion and Glucose Homeostasis |
| GSE239381 | ilhotas | 20 | Beta cell-specific PAK1 enrichment ameliorates diet-induced glucose intolerance by promoting insulin biogenesi |
| GSE239382 | ilhotas | 22 | Beta cell-specific PAK1 enrichment ameliorates diet-induced glucose intolerance by promoting insulin biogenesi |
| GSE242338 | ilhotas | 13 | Paired box 6 gene delivery preserves beta cells and improves islet transplantation efficacy |
| GSE242555 | figado | 6 | Illuminating the functions of understudied Fructosamine-3-kinase (FN3K) using a multi-omics approach reveals n |
| GSE24290 | figado | 35 | Sural nerve of progressive and non-progressive diabetic neuropathy patients |
| GSE243112 | figado | 15 | Protein-truncating variants in BSN are associated with severe adult-onset obesity, type 2 diabetes and fatty l |
| GSE24422 | adiposo;figado;sangue;vasos | 24 | Effect of insulin on the stromal and adipocyte cells within hMSC derived adipocytes |
| GSE245948 | adiposo | 76 | A dynamic subcutaneous adipose transcriptome of human insulin resistance identifies a molecular predisposition |
| GSE246315 | sangue | 12 | Decoding the immune checkpoint signatures in human atherosclerosis: implications of type 2 diabetes and lipid- |
| GSE247275 | ilhotas | 12 | EZH2 Inhibitors Promote β-like Cell Regeneration in T1D Donor tissue |
| GSE247407 | figado | 30 | Induction ofsteatosis in primary human hepatocytes manifests into hepatic pathophysiology of metabolic dysfunc |
| GSE248610 | vasos | 12 | Spatial Multiomics Reveals Metabolic Reprogramming and Calcification Characteristics of Diabetic Macroangiopat |
| GSE248848 | figado | 16 | Mitochondrial Apolipoprotein MIC26 is a metabolic rheostat regulating central cellular fuel pathways |
| GSE249102 | sangue | 20 | Whole RNA profiling of Tuberculosis-diabetes comorbidity linked to diabetes with poor glycemic control |
| GSE249277 | figado;ilhotas | 6 | Gene expression of glucose homeostasis in a pancreas-liver microphysiological system |
| GSE249298 | adiposo | 30 | Subcutaneous adipose gene expression comparison between NW, OW, PT2, and T2D individuals |
| GSE249310 | ilhotas | 4 | Harmine and Exendin-4 Combination Therapy Safely Expands Human Beta Cell Mass In Vivo |
| GSE249735 | ilhotas | 4 | An integrative approach zinc induced integrated stress response as a key driver for β cell failure in human ty |
| GSE250283 | figado;sangue;vasos | 69 | Transcriptional profiles associated with coronary artery disease in Type 2 diabetes mellitus |
| GSE2508 | adiposo | 195 | Expression profiling in adipocytes of obese humans |
| GSE2510 | adiposo;vasos | 56 | Expression profiling in preadipocytes in obese Pima Indians/humans |
| GSE251645 | sangue;vasos | 18 | Methylglyoxal-derived nucleoside adducts drive vascular dysfunction in a RAGE-dependent manner |
| GSE251911 | ilhotas | 58 | Comparative Multi-omic Mapping of Human Pancreatic Islet Endoplasmic Reticulum and Cytokine Stress Responses P |
| GSE251913 | ilhotas | 92 | Comparative Multi-omic Mapping of Human Pancreatic Islet Endoplasmic Reticulum and Cytokine Stress Responses P |
| GSE25194 | adiposo;figado;mama;vasos | 304 | Expression profiles of human adipose tissue, adipocytes and stromal-vascular pellet cells from multiple body s |
| GSE253502 | sangue;vasos | 44 | Monocytes release pro-cathepsin D to drive blood-to-brain transcytosis in diabetes |
| GSE25462 | musculo | 50 | Increased SRF Transcriptional Activity is a Novel Signature of Insulin Resistance in Humans and Mice |
| GSE254732 | sangue | 215 | Inhibition of PCSK9 with evolocumab modulates lipoproteins and monocyte activation in high-risk ASCVD subjects |
| GSE254985 | figado;ilhotas | 9 | Human pancreatic islet responses to cytokine treatment |
| GSE255255 | ilhotas | 24 | Human pancreatic beta cell transcriptomes from donors with and without T1D |
| GSE25724 | ilhotas | 13 | Expression data from type 2 diabetic and non-diabetic isolated human islets |
| GSE261390 | ilhotas | 18 | CRISPR Screening Uncovers a Long-Range Enhancer for ONECUT1 in Pancreatic Differentiation and Links a Diabetes |
| GSE26244 | sangue | 54 | Expression data from cytoplasmic hybrid (cybrid) and rho0 cells |
| GSE262480 | adiposo;figado;ilhotas | 10 | Implicating type 2 diabetes effector genes in relevant metabolic cellular models using promoter-focused Captur |
| GSE262484 | adiposo;figado;ilhotas | 35 | Implicating type 2 diabetes effector genes in relevant metabolic cellular models using promoter-focused Captur |
| GSE262677 | adiposo | 36 | Expression data from from human differentiated primary adipocytes treated with GIP alone and in combination wi |
| GSE263644 | adiposo;figado;vasos | 40 | Cholesin Receptor Signalling is Active in Cardiovascular System-Associated Adipose Tissue and Correlates with  |
| GSE263852 | adiposo | 12 | Linc-ADAIN, A Human Adipose LincRNA Regulates Adipogenesis by Modulating KLF5 and IL-8 mRNA stability |
| GSE264633 | ilhotas | 6 | LY6H is a specific marker of human pancreatic delta cells |
| GSE267522 | figado | 12 | Lycorine attenuated proliferation and induced apoptosis on imatinib-resistant K562 cell by inhibiting autophag |
| GSE267813 | vasos | 8 | A KLF2-BMPER-Smad1/5 checkpoint regulates high fluid shear stress-mediated artery remodeling |
| GSE268273 | figado | 109 | Clinical and molecular characterization of steatotic liver disease in the setting of immune-mediated inflammat |
| GSE268360 | figado | 18 | Reduced ZMPSTE24 expression leads to prelamin accumulation and development of steatosis in MAFLD patients [RNA |
| GSE268904 | adiposo;vasos | 14 | Defining the vascular niche of human adipose tissue across metabolic conditions |
| GSE269540 | ilhotas | 168 | Aberrant TNF signaling in pancreatic lymph nodes of patients with Type 1 Diabetes |
| GSE270270 | sangue | 12 | B Cell Mechanisms Underlie IgG Glycan Alterations in Obesity |
| GSE271452 | figado;musculo | 30 | Shivering improves metabolic health in adults with overweight or obesity |
| GSE271700 | sangue | 73 | Transcriptome Changes and Metabolic Outcomes After Bariatric Surgery in Adults With Obesity and Type 2 Diabete |
| GSE272114 | adiposo;osso | 6 | Dynamic chromatin accessibility and transcriptome changes following PDGF-BB treatment of bone-marrow derived m |
| GSE272133 | musculo | 52 | Different effects of bariatric surgery on epigenetic plasticity in skeletal muscle of individuals with and wit |
| GSE273902 | sangue | 91 | Rapid and long-lasting remodelling of the blood transcriptome following bariatric surgery |
| GSE274826 | sangue | 9 | Hyperglycemia-triggered lipid peroxidation destabilizes STAT4 and impairs anti-viral Th1 responses in type 2 d |
| GSE275138 | ilhotas | 12 | Modulation of ER Stress in Human Type 1 Diabetic Islets Through Combined Use of Stress Inducer and Inhibitor T |
| GSE275368 | ilhotas | 24 | A ONECUT1 regulatory, non-coding region in pancreatic development and diabetes [RNA-seq] |
| GSE27545 | figado | 17 | A Systems Approach for Decoding Mitochondrial Retrograde Signaling Pathways |
| GSE275639 | sangue | 10 | Transcriptome analysis reveals the molecular mechanism of Baduanjin in improving type 2 diabetes |
| GSE277813 | musculo | 99 | VAV3 antagonizes Skeletal Muscle Disulfidptosis to maintain Glucose Homeostasis in Type 2 Diabetes |
| GSE278525 | adiposo;figado | 30 | A Transcriptional Atlas Defining Metabolically Healthy and Unhealthy Obesity in Human Adipose Tissue and Liver |
| GSE279804 | adiposo | 8 | High-Yield Extruded Nanovesicles from Adipose Stem Cells Promote High-quality Healing of Diabetic Wound throug |
| GSE280267 | ilhotas | 199 | Glycine Receptor Activity in β Cells Is Downregulated in Type 2 Diabetes and After High Glucose Culture |
| GSE281600 | ilhotas | 59 | Transcriptomic characterization of CD206- and CD206+ macrophages in human pancreatic islets and exocrine tissu |
| GSE282625 | ilhotas | 55 | PPDPF is not a key regulator of human pancreas development |
| GSE282850 | adiposo;figado;ilhotas;musculo | 15 | Functional dissection of metabolic trait-associated variants in steady state and stimulated human skeletal mus |
| GSE283452 | sangue | 89 | HUMAN ALVEOLAR MACROPHAGE FUNCTION IS IMPAIRED IN TUBERCULOSIS CONTACTS WITH DIABETES |
| GSE287198 | adiposo | 30 | Adipose tissue gene expression profiling  in women with overweight or obesity following early vs. late time-re |
| GSE287697 | sangue | 58 | Clazakizumab treatment effects on peripheral blood and kidney transcriptomes in chronic antibody-mediated reje |
| GSE289206 | vasos | 5 | G0S2 modulates normal vitreous-induced proliferation in endothelial cells [2] |
| GSE291008 | vasos | 6 | Activin A prevents hyper-responsiveness to VEGF in pathological blood vessels by perturbing trafficking of act |
| GSE29142 | ilhotas;sangue | 29 | Transcriptome profile of peripheral blood mononuclear cells in patients with type I diabetes and their first g |
| GSE29221 | musculo | 24 | Global Gene Expression Profiles of  Skeletal Muscle in Males with Type 2 Diabetes. |
| GSE29226 | adiposo | 24 | Global Gene Expression Profiles of Subcutaneous Adipose in Females with Type 2 Diabetes. |
| GSE29231 | adiposo | 24 | Global Gene Expression Profiles of  Visceral Adipose in Females with Type 2 Diabetes. |
| GSE293830 | adiposo | 18 | Insights into Intramuscular Adipose-Muscle Signaling in the Diabetic Lower Extremity |
| GSE296585 | vasos | 11 | RESTORATION OF NOX4 SIGNALLING REVERSES ENDOTHELIAL COLONY-FORMING CELL ANGIOGENIC DYSFUNCTION ASSOCIATED WITH |
| GSE29718 | adiposo | 20 | An early inflammatory gene profile in visceral adipose tissue in children |
| GSE298973 | vasos | 9 | Transcriptomic Profiling of HRMVPC and HRMEC Co-culture Under Normal and High Glucose Conditions |
| GSE29908 | sangue | 18 | Expression data from peripheral blood mononuclear cell in patients with type 1 diabetes before and after perip |
| GSE302658 | sangue | 205 | Evaluation of a novel chemokine receptor 2 (CCR2)-antagonist in painful diabetic polyneuropathy |
| GSE303974 | sangue | 6 | Global Gene Expression  profiling of Whole Blood RNA of  Type 2 Diabetes (T2D) and Azlzheimr's Disease (AD) Pa |
| GSE305251 | vasos | 6 | Lactyl-HDAC1-Mediated Epigenetic Gating of Angiogenic Transcription via Metabolic Reprogramming [RNA-seq] |
| GSE306825 | adiposo | 14 | Heterogeneity in  populations from subcutaneous abdominal and thigh adipose tissues of women |
| GSE307152 | mama | 6 | Metabolic Adaptations to the Integrated Stress Response Enable TNBC Survival Upon EZH2 Inhibition [PDX1915_pol |
| GSE307153 | mama | 6 | Metabolic Adaptations to the Integrated Stress Response Enable TNBC Survival Upon EZH2 Inhibition [PDX1915_rib |
| GSE307751 | ilhotas | 27 | The effect of MYT1 and ST18 transcription factor down-regulation on gene expression in human islet cells |
| GSE308252 | adiposo | 62 | Exercise intensity differentially modulates systemic molecular responses and predicted interorgan communicatio |
| GSE308785 | ilhotas | 12 | CHD3 and CHD4 coordinate gene expression programs to maintain β-cell function and identity in vivo |
| GSE309688 | sangue | 48 | Natural daylight during office hours improves glucose control and whole-body substrate metabolism |
| GSE309941 | sangue | 42 | Immunometabolic Endotypes Define Distinct Clinical Trajectories in Type 2 Diabetes [bulk RNA-seq] |
| GSE310214 | figado | 24 | DPP4 inhibition affects metabolism and inflammation associated pathways in hiPSC-derived steatotic HLCs |
| GSE310216 | figado | 12 | DPP4 inhibition affects metabolism and inflammation associated pathways in hiPSC-derived steatotic HLCs [Vilda |
| GSE310965 | ilhotas | 60 | Islet-Intrinsic Sex Differences in Inflammatory Signaling Contribute to Autoimmune Diabetes Susceptibility |
| GSE311535 | vasos | 12 | RNA-seq of human atherosclerotic carotid plaque tissue from diabetic patients |
| GSE312066 | endometrio_ovario;figado | 8 | A genetically encoded bifunctional enzyme that mitigates redox imbalance and lipotoxicity via engineered Gro3P |
| GSE312780 | adiposo;musculo | 34 | Blood-flow restriction resistance training improves skeletal muscle mitochondrial oxidative capacity and cardi |
| GSE314698 | figado;ilhotas;sangue | 83 | Pancreatic volume and immunological biomarkers predict checkpoint inhibitor-associated autoimmune diabetes in  |
| GSE315294 | figado | 9 | Chrysin alleviates cardiomyocyte ferroptosis of diabetic cardiomyopathy by modulating SCD1 |
| GSE316126 | sangue | 36 | Distinct immunometabolic signatures in peripheral blood mononuclear cells are linked to systemic inflammation  |
| GSE316326 | vasos | 7 | EZH2 inhibition via GSK-126 mitigates EndMT and atherosclerosis in diabetes: A translational epigenetic approa |
| GSE316801 | ilhotas | 12 | MiR-30d-5p modulation induces expression changes related to β-cell function, survival and regeneration |
| GSE316823 | ilhotas | 8 | Extracellular Vesicles from Cytokine-Treated Human Pancreatic Ductal Cells Enhance HLA Class I Expression in B |
| GSE317209 | sangue;vasos | 6 | Mapping Endothelial-Macrophage Interactions in Diabetic Vasculature: Role of TREM2 in Vascular Inflammation an |
| GSE317257 | sangue;vasos | 35 | Mapping Endothelial-Macrophage Interactions in Diabetic Vasculature: Role of TREM2 in Vascular Inflammation an |
| GSE32357 | adiposo;figado;musculo | 20 | Calorie restriction-like effects of 30 days of resveratrol supplementation on energy metabolism and metabolic  |
| GSE324084 | ilhotas | 58 | Transcriptomic analyses of human islets |
| GSE32512 | adiposo;figado | 204 | Hyperglycemia and a Common Variant of GCKR Are Associated with the Levels of Eight Amino Acids in 9,371 Finnis |
| GSE32575 | adiposo;sangue;vasos | 48 | Transcriptome analysis of circulating monocytes in obese patients before and three months after bariatric surg |
| GSE326582 | adiposo | 22 | Transcriptome profile of peripancreatic adipose tissue in pancreatitis |
| GSE326590 | adiposo | 6 | NAT10-mediated N4-acetylcytidine modification drives RNA splicing of PML to alleviate adipose-derived stem cel |
| GSE32874 | sangue | 25 | Personal Omics Profiling Reveals Dynamic Molecular Phenotypes and Actionable Medical Risks |
| GSE330098 | adiposo;figado;ilhotas;musculo | 108 | Multi-tissue microphysiological system captures integrated responses to nutritional overload and metabolic the |
| GSE331464 | figado;vasos | 6 | ALKBH3 inhibition normalizes neovessels by reprogramming endothelial fate in diabetic microvasculopathy |
| GSE333721 | ilhotas | 6 | A dish-to-biobank framework links β-cell nutrient-stress programs to genetic and dietary risk for Type 2 Diabe |
| GSE33536 | sangue | 9 | Expression data from human keratinocyte and PBMC-derived iPS cells |
| GSE338786 | figado | 6 | Delay of Diabetic Cataract Progression by a Chemical Chaperone Trimethylamine N-Oxide through Alleviating Unfo |
| GSE35411 | adiposo | 26 | Differential gene expression in adipose tissue from obese human subjects during weight loss and weight mainten |
| GSE35711 | sangue | 49 | Transcriptional Signatures as a Disease-Specific and Predictive Inflammatory Biomarker for Type 1 Diabetes [CF |
| GSE35725 | sangue | 114 | Transcriptional Signatures as a Disease-Specific and Predictive Inflammatory Biomarker for Type 1 Diabetes [T1 |
| GSE36084 | sangue | 4 | Gene expression data from human lymphocytes |
| GSE36403 | sangue | 25 | Profiles of Epigenetic Histone Post-translational Modifications at Type 1 Diabetes Susceptible Genes |
| GSE36847 | figado;mama | 32 | Distinct perturbation of the translatome by the anti-diabetic drug metformin |
| GSE36930 | sangue | 54 | Comparative transcriptomic profiling of peripheral blood mononuclear cells (PBMCs) isolated from patients in s |
| GSE37025 | sangue | 235 | Interleukin-1 receptor antagonist for recent-onset type 1 diabeties mellitus: a multicenter randomized, placeb |
| GSE37785 | musculo | 10 | Differential metabolic effects of insulin detemir versus NPH in patients with type 2 diabetes |
| GSE38396 | vasos | 8 | Dermal lymphatic endothelial cell response to type 2 diabetes [Homo sapiens] |
| GSE38447 | mama | 9 | Cell type-specific binding patterns reveal that TCF7L2 can be tethered to the genome by association with GATA3 |
| GSE38642 | figado;ilhotas | 63 | Expression data from human pancreatic islets |
| GSE3881 | musculo | 6 | Skeletal muscle and insulin regulated genes |
| GSE39825 | adiposo | 10 | A mutation in the c-Fos gene associated with congenital generalized lipodystrophy |
| GSE40234 | adiposo | 62 | Genetic Risk Factors for Type 2 Diabetes:  A Trans-Regulatory Genetic Architecture? |
| GSE4117 | sangue | 8 | Effects of laughter on gene expression profiles of patients with type 2 diabetes |
| GSE41762 | figado;ilhotas | 77 | Expression data from human pancreatic islets |
| GSE41767 | sangue | 114 | Chlorella ingestion and suppression of resistin gene expression in borderline diabetics: a randomized, placebo |
| GSE42432 | adiposo;figado;musculo | 18 | Effects of 30 days resveratrol supplementation on adipose tissue morphology and gene expression patterns in ob |
| GSE42902 | adiposo | 16 | FKBP5 expression in human adipose tissue increases following dexamethasone exposure and is associated with ins |
| GSE43950 | osso;sangue;vasos | 14 | Gene expression profiling in endothelial precursor cells of patients protected from microvascular complication |
| GSE44035 | figado;ilhotas | 10 | Gene expression from human pancreatic islet |
| GSE45777 | ilhotas | 5 | A stem cell model of diabetes due to glucokinase deficiency |
| GSE46262 | vasos | 20 | Studies on progenitor endothelial cells; exploring mechanisms for improvement of cardiovascular diseases |
| GSE46263 | vasos | 66 | Studies on mature endothelial cells; exploring  mechanisms for improvement of cardiovascular diseases |
| GSE47060 | osso;sangue;vasos | 6 | Expression data from human OC+BAP+ double positive versus OC-BAP- double negative cells |
| GSE4901 | sangue | 4 | Effects of laughter on gene expression profiles patients with type 2 diabetes (Tenri) |
| GSE50244 | ilhotas | 89 | Global transcriptomic analysis of human pancreatic islets reveals novel genes influencing glucose metabolism [ |
| GSE50397 | figado;ilhotas | 89 | Global transcriptomic analysis of human pancreatic islets reveals novel genes influencing glucose metabolism [ |
| GSE50892 | figado;osso;sangue;vasos | 17 | Expression data from kidney biopsies of liver disease patients |
| GSE5090 | adiposo;endometrio_ovario | 17 | PCOS patients vs control subjects |
| GSE51310 | ilhotas | 4 | Chromatin stretch enhancer states drive cell-specific gene regulation and harbor human disease risk variants ( |
| GSE53949 | ilhotas | 10 | RNA-sequencing identifies dysregulation of the human pancreatic islet transcriptome by the saturated fatty aci |
| GSE54279 | figado;ilhotas | 128 | Expression microarray analysis of human pancreatic islets reveals CD59 function |
| GSE54350 | adiposo;vasos | 12 | Genome wide analysis of Visceral adipose tissue CD14+ cells from Obese and obese diabetic subjects |
| GSE55650 | musculo | 23 | p38 MAPK activation upregulates pro-inflammatory pathways in skeletal muscle cells from insulin resistant type |
| GSE56886 | sangue;vasos | 8 | To evaluate the effect of Terminalia arjuna as an adjuvant therapy in subjects with stable coronary artery dis |
| GSE57896 | adiposo | 30 | White-to-brown metabolic conversion of human adipocytes by JAK inhibition |
| GSE59363 | musculo | 42 | Effect of type 2 diabetes on transcriptional signatures during exercise and recovery |
| GSE61142 | figado | 12 | Effects of the insulin degrading enzyme silencing on the transcriptome of HepG2 cells |
| GSE62524 | musculo | 12 | Change of metabolite profiles and gene transcription in subjects with high T2D risk by low ambulatory activity |
| GSE63887 | figado;musculo | 6 | RNA-sequencing of healthy human skeletal myocytes |
| GSE64605 | figado | 12 | Transcriptome profiles of differentiated hepatoma cells infected with oncogenic hepatitis C virus |
| GSE65221 | adiposo | 136 | Integrative network analysis reveals different pathophysiological mechanisms of insulin resistance among Cauca |
| GSE65561 | figado;osso;sangue | 18 | Expression data from MSC-treated monocytes |
| GSE66413 | ilhotas | 23 | Genome-Wide Gene Expression Profiles in the Pancreatic Lymph Nodes of At-Risk Autoantibody Positive Individual |
| GSE66785 | figado | 4 | Differential mRNA expression profile regulated by HNF4α in Hep3B cells |
| GSE67141 | sangue | 5 | High-throughput sequencing reveals key genes and immune homeostatic pathways activated in myeloid dendritic ce |
| GSE67279 | adiposo;figado | 40 | Fibroblast growth factor 21 is elevated in metabolically unhealthy obesity and affects lipid deposition, adipo |
| GSE67297 | adiposo;figado;musculo | 14 | Cold acclimation improves insulin sensitivity in patients with type 2 diabetes mellitus. |
| GSE67543 | ilhotas | 24 | Novel Observations from Next Generation RNA Sequencing of Highly Purified Human Adult and Fetal Islet Cell Sub |
| GSE6798 | endometrio_ovario;musculo | 29 | Reduced expression of mitochondrial oxidative metabolism genes in skeletal muscle of women with PCOS |
| GSE68049 | sangue | 189 | Canakinumab treatment for recent-onset type 1 diabeties mellitus: a multicenter randomized, placebo-controlled |
| GSE69528 | sangue | 138 | A Blood Transcriptional Diagnostic Assay for Septicemic Melioidosis |
| GSE70218 | musculo | 20 | Charaterization of the molecular impacts of one week high fructose diet in human skeletal muscle |
| GSE70365 | figado | 6 | Effect of TDNC1 ectopic expression on global gene expression pattern |
| GSE71416 | adiposo | 20 | Gene Expression Profiling in Omental Adipose Tissue of Morbidly Obese Diabetic African Americans |
| GSE7146 | figado;musculo | 24 | Effect of insulin infusion on human skeletal muscle |
| GSE71799 | sangue | 134 | Identification of molecular signatures of cystic fibrosis disease status using plasma-based functional genomic |
| GSE72462 | musculo | 36 | TGFβ contributes to impaired exercise response by suppression of mitochondrial key regulators in skeletal musc |
| GSE72492 | ilhotas | 23 | Gene expression in the pancreas of healthy control, auto-antibody positive, and type 1 diabetic subjects |
| GSE73034 | musculo | 28 | Human skeletal muscle gene expression analysis on Lean, obese insulin sensitive, obese insulin resistant and o |
| GSE73108 | adiposo | 12 | Gene expression analysis of subcutaneous and omental adipose tissue from obese, insulin-resistant women |
| GSE74782 | musculo | 17 | Near-whole-genome transcriptome analysis of gene expression in human skeletal muscle tissue at baseline in obe |
| GSE75062 | ilhotas | 59 | Discovery and validation of a gene expression profile for human islet integrity and transplant functionality |
| GSE76161 | figado | 6 | Gene expression profiling in human precision-cut liver slices upon treatment with the FXR agonist obeticholic  |
| GSE76894 | figado;ilhotas | 103 | Affymetrix profiling of IMIDIA biobank samples from organ donors and partially pancreatectomized patients [org |
| GSE76895 | figado;ilhotas | 103 | Affymetrix profiling of IMIDIA biobank samples from organ donors and partially pancreatectomized patients [par |
| GSE76896 | figado;ilhotas | 206 | Affymetrix profiling of IMIDIA biobank samples from organ donors and partially pancreatectomized patients |
| GSE77108 | figado;vasos | 30 | HDAC inhibitor SAHA reverses inflammatory gene expression in diabetic endothelial cells |
| GSE77337 | figado;musculo | 12 | Lysophosphatidylcholines activate PPARδ and protect human skeletal muscle cells from lipotoxicity |
| GSE77522 | vasos | 12 | Metformin reverses gene expression signautres in hyperglycaemics endothelial cells |
| GSE77962 | adiposo;figado | 152 | Adipose tissue gene expression is differentially regulated with different rates of weight loss in overweight a |
| GSE78721 | adiposo;osso | 130 | Genome–wide gene expression profile of adipocytes and infiltration macrophages obtained from abdominal (viscer |
| GSE80714 | sangue | 6 | The beneficial effect of pterocarpan-rich extract from soybean leaf on metabolic syndrome in overweight and ob |
| GSE8157 | endometrio_ovario;musculo | 43 | Gene expression profiling in skeletal muscle of PCOS after pioglitazone therapy |
| GSE81608 | ilhotas | 1600 | RNA Sequencing of Single Human Islet Cells Reveals Type 2 Diabetes Genes |
| GSE81965 | figado;musculo | 90 | RNA-sequencing of human skeletal myocytes from healthy, obese, and type 2 diabetic subjects |
| GSE83452 | figado | 231 | Expression data from liver of obese patients |
| GSE84821 | adiposo;figado;vasos | 14 | Microarray analysis of CD9high and CD9low progenitors isolated from omental adipose tissue of morbid obese ind |
| GSE85226 | adiposo;sangue | 17 | Impact of Visceral Fat Adiposity on Gene Expression Profile in Peripheral Blood Cells |
| GSE86298 | sangue | 24 | Effect of hyperglycemia on the transcriptional profile of primary human macrophages |
| GSE86611 | ilhotas | 20 | Genome-wide RNA-sequencing of human islets 48 hour after transduction with adenoviruses expressing either GFP  |
| GSE87000 | sangue | 28 | Healthy glucocorticoid receptor N363S SNP carriers and metabolic syndrome |
| GSE87005 | sangue | 40 | Transcriptomic profile in lymphomonocytes of healthy subjects identifies an early signature of insulin resista |
| GSE87295 | vasos | 10 | Comparative study of the transcriptome of HUVECs from infants born to mothers diagnosed with GDM and controls. |
| GSE87382 | adiposo | 24 | Dietary medium-chain saturated fatty acids induce gene expression of energy metabolism-related pathways in adi |
| GSE89972 | osso | 104 | Molecular phenotyping empowers drug discovery: a proof-of-concept study |
| GSE9006 | sangue | 234 | Gene expression in PBMCs from children with diabetes |
| GSE9105 | musculo | 36 | Effect of Acute Physiologic Hyperinsulinemia on Gene Expression in Human Skeletal Muscle in vivo |
| GSE92724 | vasos | 10 | Dermal endothelial cells of type 2 diabetic patients |
| GSE94155 | adiposo | 12 | A next generation sequencing based approach to identify extracellular vesicle mediated mRNA transfers between  |
| GSE95640 | adiposo | 382 | Transcriptome profiling from adipose tissue during low-caloric diet reveals predictors of long-term weight and |
| GSE95674 | adiposo;figado;musculo;sangue | 256 | Tissue-Specific and Genetic Regulation of Insulin Sensitivity-Associated Transcripts in African Americans [sub |
| GSE95675 | adiposo;figado;musculo;sangue | 255 | Tissue-Specific and Genetic Regulation of Insulin Sensitivity-Associated Transcripts in African Americans [ske |
| GSE97084 | musculo | 103 | Enhanced Protein Translation Underlies Improved Metabolic and Physical Adaptations to Different Exercise Train |
| GSE98583 | sangue;vasos | 18 | Global gene expression studies for coronary artery disease and its severity in North Indian population |
| GSE98603 | adiposo | 18 | Characterization of subcutaneous white adipose tissue gene expression profile in control and chronic kidney di |

## 7. Para revisão manual

| GSE | Amostras | Motivo | Título |
|---|---:|---|---|
| GSE101207 | 13 | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | High-throughput single cell transcriptome analysis and CRISPR screen identify key β cell-s |
| GSE106181 | 35 | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Stable oxidative cytosine modifications accumulate in cardiac mesenchymal cells from Type2 |
| GSE121344 | 12 | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | A MAFG-lncRNA axis links systemic nutrient abundance to hepatic glucose metabolism: Liver  |
| GSE121346 | 73 | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | A MAFG-lncRNA axis links systemic nutrient abundance to hepatic glucose metabolism. |
| GSE124742 | 8477 | célula única ou núcleo único (termo: single cell): avaliar desenho por doador | Pancreas single cell patch-seq links physiologic dysfunction in diabetes to transcriptomic |
| GSE129363 | 32 | célula única ou núcleo único (termo: single cell): avaliar desenho por doador | Single Cell RNASeq profiling of stromal vascular fraction from Subcutaneous and visceral a |
| GSE134901 | 131 | mais de uma espécie (Homo sapiens; Mus; Mus musculus): só as amostras humanas contam na etapa 02 | Nutrient regulation of the islet epigenome controls adaptive insulin secretion |
| GSE135356 | 6 | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | Stress-induced RNA–chromatin interactions promote endothelial dysfunction (scRNA-seq) |
| GSE136230 | 187 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell analysis of human adipose tissue |
| GSE150212 | 4 | célula única ou núcleo único (termo: single-nucleus): avaliar desenho por doador | Using single-nucleus RNA-sequencing to interrogate transcriptomic profiles of archived hum |
| GSE153855 | 11 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell RNAseq of human pancreatic islets from control and type 2 diabetes donors |
| GSE154126 | 1263 | célula única ou núcleo único (termo: single cell): avaliar desenho por doador | Single cell transcriptomics of human islet ontogeny defines the molecular basis of beta ce |
| GSE156341 | 10 | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | Stress-induced RNA–chromatin interactions promote endothelial dysfunction (scRNA-seq human |
| GSE158001 | 6 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | HyPR-seq: Single-cell quantification of chosen RNAs via hybridization and sequencing of DN |
| GSE158003 | 72 | mais de uma espécie (Mus musculus; Homo sapiens): só as amostras humanas contam na etapa 02 | HyPR-seq: Single-cell quantification of chosen RNAs via hybridization and sequencing of DN |
| GSE158055 | 284 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Large-scale single-cell analysis reveals critical immune characteristics of COVID-19 patie |
| GSE159759 | 69 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell  analysis  of  adipose tissue  T cells in diabetic persons with HIV  reveals h |
| GSE160473 | 8 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell chromatin accessibility identifies pancreatic islet cell type- and state-speci |
| GSE160474 | 15 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell chromatin accessibility identifies pancreatic islet cell type- and state-speci |
| GSE162173 | 8 | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | lncRNA expression profile in placenta of diabetic macrosomia and normal birth weight newbo |
| GSE163947 | 8 | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | MYCL-mediated in vivo reprogramming expands pancreatic insulin-producing cells to reverse  |
| GSE164875 | 640 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Extended data for pancreas single-cell patch-seq dataset in nondiabetic and T2D |
| GSE171153 | 110 | célula única ou núcleo único (termo: single cell): avaliar desenho por doador | Integration of human genetics with single cell accessible chromatin profiles across phenot |
| GSE176068 | 126 | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Hyperglycaemia induces trained immunity in macrophages and their precursors and promotes a |
| GSE176171 | 50 | mais de uma espécie (Mus musculus; Homo sapiens): só as amostras humanas contam na etapa 02 | A single cell atlas of human adipose tissue |
| GSE185011 | 25 | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | The expression of mRNA and lncRNA in peripheral blood mononuclear cells (PBMCs) of diabete |
| GSE185152 | 89 | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | The RANBP2/Importin-7-FOXO1 axis provides superior cold protection to aid islet transplant |
| GSE185749 | 14 | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Transcriptome-wide N6-methyladenine profiling in low input multiplex samples by a kit-free |
| GSE189923 | 6 | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | LncRNA expression profile and target gene prediction of calcification in human aortic smoo |
| GSE190447 | 12 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Long-term effects of Elastase inhibition on human islets at single-cell resolution |
| GSE195986 | 11 | célula única ou núcleo único (termo: single cell): avaliar desenho por doador | Single cell multi-omics analysis deconstructs diabetes-associated β-cell heterogeneity in  |
| GSE196797 | 14 | título cita outro tipo de dado (termo: microRNA); a série também é de expressão: confirmar | microRNA Expression in Normal and Diabetic Pancreatic Islets |
| GSE197399 | 61 | mais de uma espécie (Mus musculus; Homo sapiens): só as amostras humanas contam na etapa 02 | Redistribution of lamina-associated domains reshapes Foxa2 binding in development of NAFLD |
| GSE197955 | 6 | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | Vascular Regulation by Super Enhancer-Derived LINC00607 (scRNA-Seq) |
| GSE198906 | 25 | mais de uma espécie (Rattus norvegicus; Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Control of pancreatic islet function and glucose homeostasis by a novel microexon program  |
| GSE200044 | 40 | título cita outro tipo de dado (termo: ATAC); a série também é de expressão: confirmar | Single-cell multiome (ATAC and RNA) landscapes of human islets in normoglycemia, prediabet |
| GSE202151 | 12 | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | LncRNA LYPLAL1-DT screening from type 2 diabetes with macrovascular complication contribut |
| GSE210778 | 10 | título cita outro tipo de dado (termo: microRNA); a série também é de expressão: confirmar | MicroRNA-375 repression of Kruppel-like Factor 5 Improves Angiogenesis in Diabetic Critica |
| GSE21321 | 50 | título cita outro tipo de dado (termo: microRNA); a série também é de expressão: confirmar | Blood microRNA profiles and upregulation of hsa-miR-144 in males with type 2 diabetes mell |
| GSE214517 | 2785 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Smart-seq2 single-cell RNA sequencing of human pancreatic islets |
| GSE217837 | 10 | célula única ou núcleo único (termo: single cell): avaliar desenho por doador | Single Cell RNA / Single Nucleus RNA Sequencing Data of Human Pancreaitc Islet |
| GSE218316 | 5 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell transcriptomics of primary human pancreatic islet cells exposed to stress cond |
| GSE221156 | 54 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Dissecting cell-type specific pathophysiological changes in human type-2 diabetic pancreat |
| GSE223713 | 12 | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | Dynamic scRNA-seq of live human pancreatic slices reveals functional endocrine cell neogen |
| GSE229207 | 6 | título cita outro tipo de dado (termo: microRNA); a série também é de expressão: confirmar | Regulation of oxidative stress in endothelial cells exposed to high glucose by selected mi |
| GSE234148 | 24 | mais de uma espécie (Mus musculus; Homo sapiens): só as amostras humanas contam na etapa 02 | Pharmacological HDAC inhibition impairs pancreatic β-cell function through a genome-wide e |
| GSE243957 | 108 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell Analysis of Subcutaneous Fat Reveals Pro-fibrotic Cells that Correlate with Vi |
| GSE244515 | 27 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Uncovering systemic immunological modification by type 2 diabetes mellitus in periodontiti |
| GSE246318 | 49 | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Decoding the immune checkpoint signatures in human atherosclerosis: implications of type 2 |
| GSE248609 | 6 | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | Spatial Multiomics Reveals Metabolic Reprogramming and Calcification Characteristics of Di |
| GSE249089 | 84 | célula única ou núcleo único (termo: single-nucleus): avaliar desenho por doador | Single-nucleus RNA-sequencing of human subcutaneous adipose tissue biopsies from 84 Finnis |
| GSE251912 | 10 | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | Comparative Multi-omic Mapping of Human Pancreatic Islet Endoplasmic Reticulum and Cytokin |
| GSE255566 | 8 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell RNA sequencing of peripheral blood mononuclear cells reveals complex cellular  |
| GSE26168 | 60 | título cita outro tipo de dado (termo: miRNA); a série também é de expressão: confirmar | Type 2 Diabetes mellitus: mRNA and miRNA profiling |
| GSE263365 | 9 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell transcriptomics reveals a role for pancreatic duct cells as potential mediator |
| GSE266291 | 15 | célula única ou núcleo único (termo: single cell): avaliar desenho por doador | Single cell RNAseq profiling of Human Pancreatic Islets across sex |
| GSE267033 | 15 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell landscape of peripheral immune cells in MAFLD/MASH [scRNA-seq] |
| GSE268210 | 30 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell analysis of human PBMCs in healthy and type 2 diabetes populations: Dysregulat |
| GSE272294 | 24 | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | Decoding the immune checkpoint signatures in human atherosclerosis: implications of type 2 |
| GSE273597 | 33 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell multiome profiling reveals pancreas cell type-specific gene regulatory program |
| GSE275610 | 341 | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | scRNA-seq and snATAC-seq reveal differentiation trajectories of several pancreatic islet i |
| GSE277551 | 17 | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | HNF1A regulates a β-cell RNA splicing program that is disrupted in type 2 diabetes [RNA-se |
| GSE278526 | 4 | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | A Transcriptional and Cellular Exploration of Obesity and Type-II Diabetes in Human Adipos |
| GSE280401 | 4 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Deciphering the Transcriptomic Landscape of Type 2 Diabetes: Insights from Bulk RNA Sequen |
| GSE280402 | 16 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Deciphering the Transcriptomic Landscape of Type 2 Diabetes: Insights from Bulk RNA Sequen |
| GSE281291 | 6 | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | Identification of lncRNA PRNCR1/miR-642a-5p/SSTR3 ceRNA network as novel biomarkers in det |
| GSE281902 | 5 | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Periosteum Signatures of Delayed Fracture Healing in Type 2 Diabetes at Single-Cell Resolu |
| GSE282230 | 14 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell RNA Sequencing Uncovers Molecular Mechanisms of Human Pancreatic Islet Dysfunc |
| GSE28384 | 58 | mais de uma espécie (Mus musculus; Homo sapiens): só as amostras humanas contam na etapa 02 | Amorfrutins are selective PPARγ agonists with potent antidiabetic properties |
| GSE291636 | 73 | mais de uma espécie (Mus musculus; Homo sapiens): só as amostras humanas contam na etapa 02 | RBBP6 orchestrates diabetic endothelial dysfunction viadisrupting JUNB-centric chromatin t |
| GSE293428 | 18 | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | Mapping Endothelial-Macrophage Interactions in Diabetic Vasculature: Role of TREM2 in Vasc |
| GSE295708 | 18 | célula única ou núcleo único (termo: snRNA): avaliar desenho por doador | Selective remodelling of the adipose niche in obesity and weight loss [snRNA-Seq] |
| GSE298690 | 16 | título cita outro tipo de dado (termo: lncRNA); a série também é de expressão: confirmar | Integrated transcriptome and single-cell sequencing analysis identify blood-pancreas share |
| GSE309942 | 4 | célula única ou núcleo único (termo: scRNA): avaliar desenho por doador | Immunometabolic Endotypes Define Distinct Clinical Trajectories in Type 2 Diabetes [scRNA- |
| GSE342773 | 39 | célula única ou núcleo único (termo: single-nucleus): avaliar desenho por doador | Single-nucleus and bulk transcriptomic atlas of human visceral adipose tissue across metab |
| GSE50005 | 45 | mais de uma espécie (Macaca mulatta; Homo sapiens): só as amostras humanas contam na etapa 02 | Resveratrol improves adipose insulin signaling and reduces the inflammatory response in ad |
| GSE57928 | 24 | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Towards epigenetic understanding and therapy of insulin resistance by intranuclear insulin |
| GSE58249 | 34 | título cita outro tipo de dado (termo: methylation); a série também é de expressão: confirmar | Multi-Omic Integrated networks connect DNA methylation and miRNA with skeletal muscle plas |
| GSE58250 | 102 | título cita outro tipo de dado (termo: methylation); a série também é de expressão: confirmar | Multi-Omic Integrated networks connect DNA methylation and miRNA with skeletal muscle plas |
| GSE64998 | 21 | título cita outro tipo de dado (termo: methylation); a série também é de expressão: confirmar | Altered DNA methylation of glycolytic and lipogenic genes in liver from obese and type 2 d |
| GSE65058 | 45 | título cita outro tipo de dado (termo: methylation); a série também é de expressão: confirmar | Altered DNA methylation of glycolytic and lipogenic genes in liver from obese and type 2 d |
| GSE73037 | 40 | mais de uma espécie (Homo sapiens; Mus musculus): só as amostras humanas contam na etapa 02 | Cross-species Gene Expression Analysis Identifies a Novel Set of Genes Implicated in Human |
| GSE76268 | 23 | título cita outro tipo de dado (termo: ATAC); a série também é de expressão: confirmar | Integration of ATAC-seq and RNA-seq Identifies Human Alpha Cell and Beta Cell Signature Ge |
| GSE81076 | 18 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | A single-cell transcriptome atlas of the human pancreas |
| GSE81547 | 2544 | célula única ou núcleo único (termo: single cell): avaliar desenho por doador | Single cell transcriptome analysis of human pancreas reveals transcriptional signatures of |
| GSE83139 | 635 | célula única ou núcleo único (termo: single cell): avaliar desenho por doador | Single cell RNA-seq of human pancreatic endocrine cells from Juvenile, adult control and t |
| GSE86468 | 24 | célula única ou núcleo único (termo: single cell): avaliar desenho por doador | Single cell transcriptomics defines human islet cell signatures and reveals cell-type-spec |
| GSE86469 | 638 | célula única ou núcleo único (termo: single cell): avaliar desenho por doador | Single cell transcriptomics defines human islet cell signatures and reveals cell-type-spec |
| GSE86473 | 662 | célula única ou núcleo único (termo: single cell): avaliar desenho por doador | Single cell transcriptomics defines human islet cell signatures and reveals cell-type-spec |
| GSE97655 | 223 | célula única ou núcleo único (termo: single-cell): avaliar desenho por doador | Single-cell transcriptomics of East-Asian pancreatic islets cells |
| GSE98680 | 60 | título cita outro tipo de dado (termo: miRNA); a série também é de expressão: confirmar | mRNA/miRNA expression profiles of human primary adipocytes exposed to low doses of bisphen |
| GSE98887 | 9600 | mais de 2000 amostras: provável compilação ou célula única | BACH2 inhibition reverses β-cell failure in type 2 diabetes models |

## 8. Decisões já validadas

- 06/10/2026, escopo: tecidos = os 5 do projeto + osso, endométrio/ovário, mama e vasos; condição = só DM2 com controles; código escrito do zero.
- 06/10/2026, 1ª execução: termos específicos de DM2 acrescentados mantendo "diabetic"; tecido fora do escopo excluído pelo título só quando o título não cita um tecido de interesse; títulos com diabetes tipo 1 seguem para a etapa 02.
- 06/10/2026, auditoria das exclusões (depois do GSE200044 excluído por "ATAC"): termos de outro tipo de dado e séries com mais de uma espécie vão para revisão; "synthetic construct" e vírus não contam como espécie; espécies no título só como palavra exata; mínimo de 4 amostras. Busca mantida, triagem refeita.

## 9. O que validar

1. Os termos de DM2 e de cada tecido (seção 1 e `config/busca.yaml`) cobrem o que interessa?
2. As exclusões por termo do título (seção 2) estão corretas? Confira em `output/01_busca/catalogo.csv`, coluna `motivo`.
3. As sementes não encontradas (seção 4) pedem termo novo?
4. Os estudos de célula única para revisão (seção 7) devem seguir para a etapa 02?
5. Algum estudo conhecido falta (inclua em `input/estudos_semente.csv`)?
