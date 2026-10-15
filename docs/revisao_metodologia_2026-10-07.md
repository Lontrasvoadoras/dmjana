# Revisão da metodologia — etapas 01 a 05 (07/10/2026)

Pergunta do workflow: efeito do DM2 na expressão gênica de **mulheres de 40–60 anos** (proxy da transição menopausal), com dados públicos do GEO, por tecido.

Resultado atual (etapa 05, modelo só com mulheres de 40–60): nenhum gene replicado nem via com FDR < 0,05; tendências coerentes (interferon no sangue, NF-κB no adiposo, transição epitélio-mesênquima nas ilhotas, fosforilação oxidativa no músculo).

As verificações citadas abaixo foram feitas nos dados em 07/10/2026.

## 1. O que está sólido

- **Rastreabilidade:** busca registrada, cada exclusão com motivo, regras em arquivos de configuração e testadas (16 casos na triagem, 61 nas regras de metadados), curadoria manual com fonte, documento Word e glossário por etapa.
- **Unidade correta:** a contagem é por doadora, com réplicas técnicas promediadas, SuperSeries e ensaios que não são de mRNA fora, e pseudo-bulk por doador em célula única.
- **Sexo genético:** o método foi validado com o sexo declarado antes de ser usado (acerto de 97–100% nas plataformas validadas).
- **Integração:** não se juntam matrizes de plataformas diferentes nem se corrige lote entre estudos; combinam-se efeitos padronizados por tecido.
- **Leitura honesta do poder:** o efeito mínimo detectável é informado, resultados de um só estudo ficam como "descoberta", e há sensibilidades (deixar um de fora, sem matrizes do autor, lote, IMC, composição).

## 2. Problemas e riscos, por gravidade

### Alta: podem mudar a conclusão

| # | Problema | Evidência | Recomendação |
|---|---|---|---|
| A1 | **Idade desbalanceada dentro da faixa de 40–60.** Na transição menopausal, alguns anos mudam o estado hormonal; se as mulheres com DM2 são mais velhas, o "efeito do DM2" mistura doença e menopausa, justamente a variável de interesse. | Diferença média DM2 − ND: GSE133666 **+11,9 anos**, GSE29226 −8,5, GSE156993 +6,7, GSE86469 −6,0, GSE25462 +5,3, GSE15653 +4,8. | Relatar o balanço de idade por estudo; sensibilidade com idade contínua como covariável (onde os graus de liberdade permitirem) e sem os estudos com diferença > 5 anos. |
| A2 | **IMC desbalanceado (obesidade).** O DM2 vem com mais obesidade; no adiposo e no músculo, parte do "efeito do DM2" pode ser efeito da obesidade. | IMC DM2 × ND: GSE25462 36,0 × 26,2; GSE41762 31,5 × 25,4; GSE76895 31,1 × 25,9; GSE15653 49,2 × 43,9. IMC falta em 7 dos 14 estudos da análise principal; a sensibilidade com IMC perde estudos pela regra de graus de liberdade. | Manter como limitação explícita; na sensibilidade, usar IMC só onde houver ≥ 6 graus de liberdade e mostrar quais estudos entram. |
| A3 | **Meta-análise com poucos estudos (2 a 4) pelo método DerSimonian-Laird.** Com k pequeno, DL subestima a variação entre estudos e dá intervalos estreitos demais; a recomendação atual é o ajuste de Hartung-Knapp (HKSJ). | Com Hartung-Knapp: transição epitélio-mesênquima nas ilhotas p 0,012 → **0,10**; fosforilação oxidativa no músculo (k = 2) 0,046 → **0,30**; NF-κB no adiposo 0,009 → 0,048; interferon alfa no sangue 0,003 → 0,014. | Adotar Hartung-Knapp como principal (DL como sensibilidade). O sinal do interferon no sangue é o que melhor resiste. |
| A4 | **Estudos com 2 mulheres por grupo.** O efeito de um estudo 2 × 2 é muito instável; com o modelo só de mulheres de 40–60 sobram 2 graus de liberdade. | 6 dos 14 estudos têm 2 mulheres em algum grupo (GSE29226, GSE86469, GSE249102, GSE200678, GSE221156, GSE76895). | Sensibilidade só com estudos ≥ 3 × 3; manter o mínimo de 2 (decisão do usuário) na principal. |

### Média: enfraquecem ou limitam a interpretação

| # | Problema | Evidência | Recomendação |
|---|---|---|---|
| M1 | **Composição celular sem ajuste na análise principal.** Nas ilhotas, a fração de células beta cai no DM2; vias como transição epitélio-mesênquima podem refletir mais estroma/exócrino. No GSE86469 (Fluidigm C1) o pseudo-bulk soma células capturadas de forma não aleatória. | Sensibilidade de composição perde estudos pela regra de graus de liberdade (nas ilhotas sobra 1 estudo). | Interpretar vias das ilhotas como possivelmente compostas; considerar pseudo-bulk só de células beta no GSE221156 e no GSE86469 (sensibilidade já prevista na etapa 04, D3). |
| M2 | **Estudo de ilhotas não lido.** GSE124742 (patch-seq de ilhotas com doadores DM2, 8.477 células) ficou de fora pelo limite de 5.000 amostras da etapa 02, criado para não baixar séries de célula única gigantes. | GSE124742 e GSE98887 (este parece de modelos animais) não foram lidos. | Ler os metadados do GSE124742; se houver mulheres de 40–60 com DM2 e controles, entra como pseudo-bulk por doador. |
| M3 | **Status "sem diabetes" sem confirmação glicêmica.** Controles podem incluir pré-diabetes não declarado; medicação do DM2 (metformina, insulina) não é considerada e altera expressão (ex.: músculo, sangue). | Status vem do rótulo do GEO; HbA1c existe em poucos estudos. | Limitação explícita; onde houver HbA1c, sensibilidade retirando controles com HbA1c ≥ 5,7%. |
| M4 | **Independência entre estudos não verificável quando os identificadores diferem.** Bancos de ilhotas (IIDP, HPAP, Lund, IMIDIA) podem repetir doadores entre séries. | GSE86469 (UNOS) e GSE221156 (HPAP/SAMN) não têm IDs em comum, mas uma controle de 53 anos aparece nos dois com perfil compatível; GSE38642 × GSE41762 já tratado. | Conferir sobreposição por perfil (idade, sexo, IMC, status, centro) entre estudos do mesmo tecido. |
| M5 | **Lote só para arrays.** RNA-seq e matrizes do autor não têm data de processamento; confusão lote × grupo não é verificável neles. | 7 dos 14 estudos sem informação de lote. | Limitação explícita; usar a distribuição de p-valores por estudo como sinal indireto (ver P2). |
| M6 | **Múltiplos tecidos e vias.** O FDR é controlado dentro de cada tecido, não entre os 5 tecidos; procurar "a via que deu certo" em 5 × 50 testes aumenta falsos positivos. | — | Declarar as vias de interesse antes da etapa 06 (as quatro com tendência) e tratá-las como hipóteses a confirmar. |

### Processo

| # | Problema | Recomendação |
|---|---|---|
| P1 | Vários erros foram achados de forma reativa (termos "ATAC"/"rates", "DM2"/"CTRL" não reconhecidos, réplicas técnicas, ensaios de miRNA contados como pessoas, lote confundido, sobreajuste com covariáveis). Todos foram corrigidos e documentados, mas mostram que regras automáticas sobre metadados livres falham de formas imprevisíveis. | Manter auditorias a cada etapa; cada correção ganha caso de teste. |
| P2 | Faltam checagens de sanidade automáticas na etapa 05. | Por estudo: fração de genes com p < 0,05 (esperado ~5% sem efeito), histograma de p e inflação genômica (λ). Estudos muito fora do esperado (como o GSE189005, com 21%) são sinalizados automaticamente. |
| P3 | Proxy de menopausa por idade, sem estado menopausal, hormônios ou terapia hormonal. | Limitação de desenho, inevitável com o GEO; deve estar explícita na síntese. |
| P4 | A conectividade (z < −3) não age em estudos com até 10 amostras. | Limitação explícita (já no glossário). |

## 3. Recomendações antes da etapa 06 (em ordem)

1. **Hartung-Knapp como método principal da meta-análise** (A3).
2. **Tabela de balanço de idade e IMC por estudo** no relatório, e sensibilidades com idade como covariável e sem estudos com diferença de idade > 5 anos (A1, A2).
3. **Sensibilidade só com estudos ≥ 3 × 3** (A4).
4. **Checagens de sanidade por estudo** (fração de p < 0,05, λ) (P2).
5. **Ler o GSE124742** (M2).
6. **Conferir sobreposição de doadores por perfil** entre estudos do mesmo tecido (M4).
7. **Declarar as vias de interesse** antes da etapa 06 (M6).

## 4. Aplicação das recomendações (07/10/2026, aprovada pelo usuário)

| # | Recomendação | O que foi feito | Resultado |
|---|---|---|---|
| 1 | Hartung-Knapp | Principal: Hartung-Knapp modificado; DerSimonian-Laird virou sensibilidade (`config/meta.yaml: meta_metodo`). | Nenhuma via com FDR < 0,10 nos tecidos com 2+ estudos; todos os IC 95% das vias de interesse incluem 0. |
| 2 | Balanço de idade e IMC | Tabela por estudo no relatório e no Word; sensibilidades "idade como covariável" e "sem estudos com diferença de idade > 5 anos". | Diferenças de idade de −8,5 a +11,9 anos; IMC maior no DM2 em 5 de 7 estudos com IMC. As vias de interesse mantêm o sentido sem os estudos desbalanceados, sem significância. |
| 3 | Só estudos ≥ 3 × 3 | Sensibilidade nova. | Sobram 1–2 estudos por tecido; mesma direção, sem significância. |
| 4 | Checagens de sanidade | Fração de p < 0,05 e λ por estudo, com alerta automático. | Alertas: GSE221156 (21%, λ 2,6; pseudo-bulk 2 × 4) e GSE18732 (11%, λ 1,58). |
| 5 | GSE124742 | Lido na etapa 02 (`forcar_leitura`). | Sem doador nem idade por célula no GEO (só placa e poço); fica fora, recuperável só por curadoria a partir do artigo (PMID 32302527). |
| 6 | Sobreposição por perfil | Tabela de doadoras com tecido, status, idade e IMC idênticos entre estudos. | Sangue: coincidências entre coortes de países diferentes (sem IMC, idade inteira). Ilhotas: uma controle de 53 anos em GSE86469 e GSE221156, não confirmável. |
| 7 | Vias de interesse | Declaradas em `config/meta.yaml` (sangue: interferon alfa e gama; adiposo: NF-κB; ilhotas: transição epitélio-mesênquima; músculo: fosforilação oxidativa), marcadas como escolhidas depois de ver os dados. Tabela em todas as análises. | Todas mantêm o sentido em quase todas as sensibilidades; nenhuma é significativa com Hartung-Knapp. |
