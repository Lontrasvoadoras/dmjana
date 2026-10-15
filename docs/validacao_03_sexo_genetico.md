# Validação da etapa 03: pré-análise de sexo genético

Gerado em 12/10/2026 12:16 a partir de `output/03_sexo_genetico/`. **Aprovar antes de seguir.**

## 1. Candidatos

Dos 131 estudo × tecido que saíram da etapa 02 por falta de sexo, **5** têm idade e status e pelo menos 2 amostras sem sexo de 40–60 anos com DM2 e sem diabetes. Nos demais o sexo não é o único obstáculo (falta idade ou status), e o sexo genético sozinho não os tornaria elegíveis.

| GSE | Tecido | Plataforma | Sem sexo 40–60 DM2 | Sem sexo 40–60 ND | Título |
|---|---|---|---:|---:|---|
| GSE59363 | musculo | GPL6244 | 12 | 15 | Effect of type 2 diabetes on transcriptional signatures during exercise and reco |
| GSE182120 | musculo | GPL17586 | 8 | 12 | Disrupted Circadian Oscillations in Type 2 Diabetes are Linked to Altered Rhythm |
| GSE19420 | musculo | GPL570 | 9 | 8 | Skeletal muscle mitochondrial dysfunction is secondary to T2DM |
| GSE128665 | adiposo | GPL23126 | 2 | 11 | Elevated Extra-cellular Matrix Signaling in Adipose Mesothelial Cells is Linked  |
| GSE43950 | sangue | GPL10379 | 6 | 2 | Gene expression profiling in endothelial precursor cells of patients protected f |

## 2. Método

- **Dados:** matriz normalizada publicada no GEO (series matrix) e anotação da plataforma. Para ler o sexo não é preciso reprocessar os arquivos brutos.
- **Leitura (a), dentro da amostra:** percentil de XIST e da mediana dos genes Y (RPS4Y1, DDX3Y, KDM5D, UTY, EIF1AY, USP9Y, ZFY, NLGN4Y) entre todos os genes da amostra. Mulher: XIST ≥ 0.90 e Y ≤ 0.70. Homem: Y ≥ 0.75 e XIST ≤ 0.85. Funciona mesmo se o estudo tiver um só sexo.
- **Leitura (b), entre amostras:** escore z(Y) − z(XIST) e dois grupos por k-means, aceitos só com separação ≥ 4 DP intragrupo (mesmo critério do workflow_multi_estruturado).
- **Aceite:** com XIST, (a) e (b) concordam em ≥ 90% das amostras; com um só sexo no estudo, vale (a) se ≥ 90% das amostras concordam. Sem XIST na plataforma, vale só (b) e um só sexo não é decidível.

## 3. Validação do método (estudos com sexo declarado nas mesmas plataformas)

| GSE | Plataforma | Amostras | Declaradas F/M | Com sexo atribuído | Acerto final | Acerto da leitura (a) | Cobertura de (a) |
|---|---|---:|---|---:|---:|---:|---:|
| GSE118230 | GPL17586 | 30 | 18/12 | 30 | 60% | 60% | 100% |
| GSE38642 | GPL6244 | 63 | 27/36 | 63 | 100% | 94% | 51% |
| GSE41762 | GPL6244 | 77 | 33/44 | 77 | 99% | 98% | 73% |
| GSE50397 | GPL6244 | 89 | 35/54 | 89 | 97% | 80% | 51% |
| GSE72462 | GPL17586 | 36 | 24/12 | 36 | 100% | 100% | 75% |
| GSE76894 | GPL570 | 206 | 104/102 | 206 | 100% | 100% | 64% |
| GSE76895 | GPL570 | 206 | 82/124 | 206 | 100% | 100% | 67% |
| GSE76896 | GPL570 | 412 | 186/226 | 412 | 100% | 100% | 59% |

| Plataforma | Estudos de validação | Melhor acerto | Validada |
|---|---:|---:|---|
| GPL6244 | 3 | 100% | sim |
| GPL17586 | 2 | 100% | sim |
| GPL570 | 3 | 100% | sim |
| GPL23126 | 0 | - | **não** |
| GPL10379 | 0 | - | **não** |

Figura: `docs/figuras/sexo_genetico_validacao.png` (cor = sexo declarado).

Estudos de validação com acerto abaixo do mínimo (mediana dos percentis por sexo declarado):

| GSE | Sexo declarado | Amostras | Percentil de XIST | Percentil de Y |
|---|---|---:|---:|---:|
| GSE118230 | F | 18 | 0.98 | 0.20 |
| GSE118230 | M | 12 | 0.98 | 0.19 |

Quando as declaradas M têm XIST alto e Y ausente, iguais às declaradas F, o mais provável é erro no sexo declarado (tecido masculino não tem esse perfil), e não erro do método.

## 4. Resultado nos candidatos

| GSE | Plataforma | Amostras | Genes Y | XIST | Separação (DP) | Decisão | F | M | Plataforma validada | Detalhe |
|---|---|---:|---:|---|---:|---|---:|---:|---|---|
| GSE59363 | GPL6244 | 42 | 8 | não |  2.5 | não resgatado | 0 | 0 | sim | plataforma sem XIST e sem dois grupos (separação 2.5 DP): um só sexo não é decidível só com Y |
| GSE182120 | GPL17586 | 49 | 8 | sim | 25.7 | resgatado (dois sexos) | 1 | 48 | sim | separação 25.7 DP; concordância (a)x(b) 100% |
| GSE19420 | GPL570 | 42 | 8 | sim |  2.7 | resgatado (um só sexo: M) | 0 | 42 | sim | 100% das amostras lidas como M; sem dois grupos (separação 2.7 DP) |
| GSE128665 | GPL23126 | 24 | 8 | sim |  2.9 | resgatado (um só sexo: F) | 24 | 0 | **não** | 100% das amostras lidas como F; sem dois grupos (separação 2.9 DP) |
| GSE43950 | GPL10379 | 14 | 8 | não |  4.8 | resgatado (dois sexos, só genes Y) | 6 | 8 | **não** | plataforma sem XIST; separação 4.8 DP |

Figura: `docs/figuras/sexo_genetico_candidatos.png`.

## 5. Elegibilidade com o sexo genético

| GSE | Tecido | Doadoras DM2 40–60 | Doadoras ND 40–60 | Categoria (só plataformas validadas) | Categoria (aceitando as não validadas) |
|---|---|---:|---:|---|---|
| GSE59363 | musculo | 0 | 0 | sem sexo: candidato ao sexo genético | sem sexo: candidato ao sexo genético |
| GSE182120 | musculo | 1 | 0 | poucas mulheres de 40-60 com DM2 e controles | poucas mulheres de 40-60 com DM2 e controles |
| GSE19420 | musculo | 0 | 0 | poucas mulheres de 40-60 com DM2 e controles | poucas mulheres de 40-60 com DM2 e controles |
| GSE128665 | adiposo | 2 | 11 | sem sexo: candidato ao sexo genético | elegivel |
| GSE43950 | sangue | 2 | 2 | sem sexo: candidato ao sexo genético | elegivel |

## 6. Achados e decisão do usuário

- **GSE43950** (sangue, CD34+ frescas; seria elegível com 2/2): o tipo de diabetes não é declarado. No artigo (Hazra et al., PLoS One 2013, PMID 24223881) o grupo do array tem 58,6 anos e 41,8 anos de diabetes (início por volta dos 17 anos) e 56,2 anos e 27,4 anos de diabetes: perfil de diabetes tipo 1. O artigo estuda tipo 1 e tipo 2 e não diz qual é o grupo do array. A regra da etapa 02 contou como DM2 porque o resumo da série não cita tipo 1. Recomendo marcar como AMBÍGUO (sai). A plataforma (GPL10379) também não tem estudo de validação e não tem XIST.
- **GSE128665** (adiposo; seria elegível com 2 DM2 e 11 controles): 24 de 24 amostras com XIST no percentil 0,99, todas mulheres. Mas (i) a plataforma GPL23126 não tem estudo de validação com matriz no GEO; (ii) as células mesoteliais foram isoladas de pacientes em cirurgia bariátrica e a série não diz se foram cultivadas; (iii) os controles são de baixa resistência à insulina e o grupo experimento mistura DM2 e alta resistência à insulina sem diabetes (só as 2 com DM2 contam como DM2). Decisão: aceitar como elegível?
- **GSE19420** (músculo): todos homens (genes Y no percentil 0,9 em 42/42); **GSE182120** (músculo): 48 homens e 1 mulher; **GSE59363** (músculo, GPL6244 sem XIST): um só grupo pelos genes Y, sexo não decidível (o título de amostras não ajuda). Nenhum dos três traz mulheres.
- **GSE118230** (validação, GPL17586): as 12 amostras declaradas como homens têm perfil feminino (XIST 0,98; Y 0,19), o que sugere erro no sexo declarado; não foi usado contra a plataforma, porque o GSE72462 na mesma plataforma acertou 100%.

**Decisão do usuário (06/10/2026): nenhum dos dois estudos foi aceito.**

| GSE | Tecido | Seria elegível com | Decisão | Motivo |
|---|---|---|---|---|
| GSE128665 | adiposo | 2 DM2 / 11 ND | não aceito | Plataforma (GPL23126) sem estudo de validação com dados no GEO; a série não informa se as células mesoteliais foram cultivadas após o isolamento; só 2 doadoras com DM2 de 40-60 anos, e o grupo experimento mistura DM2 com resistência à insulina sem diabetes. |
| GSE43950 | sangue | 2 DM2 / 2 ND | não aceito | Tipo de diabetes não declarado; no artigo (Hazra et al., PLoS One 2013, PMID 24223881) o grupo do array tem 58,6 anos de idade e 41,8 anos de diabetes (início por volta dos 17 anos), perfil de diabetes tipo 1. A plataforma (GPL10379) não tem XIST nem estudo de validação, e a separação dos sexos foi pequena (4,8 DP). |

Resultado final da etapa 03: **0 estudo(s) resgatado(s)**; os candidatos seguem fora da análise.

## 7. O que validar

1. A regra de aceite e os limiares (seção 2), conferidos na validação (seção 3).
2. Decisão sobre os candidatos em plataforma sem validação: tomada (seção 6, nenhum aceito).
3. Os estudos resgatados que passam a elegíveis entram na etapa de dados como os demais?
