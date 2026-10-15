# workflow_dm_menopausa

Workflow escrito do zero (iniciado em 06/10/2026) para estudar o efeito do diabetes tipo 2 em **mulheres de 40 a 60 anos** (aproximação da transição menopausal), usando só bancos públicos do GEO que tenham essas mulheres.

**Regras de trabalho:**
- O workflow é construído por etapas, e cada etapa só começa depois que o usuário valida a anterior pelo relatório em `docs/validacao_NN_*.md`.
- Cada etapa gera um documento Word em `docs/etapa_NN_*.docx` com os pacotes usados (versão e motivo), as fontes de dados, os critérios de inclusão e exclusão (termos exatos), o resultado e as decisões validadas (`R/99_documentar.R`).

## Escopo (decisões de 06/10/2026)

- **Tecidos:** ilhotas, músculo esquelético, tecido adiposo, fígado e sangue, mais osso, endométrio e ovário, mama e vasos.
- **Condição:** só estudos com DM2 e controles não diabéticos.
- **Mulheres de 40–60 anos:** verificadas amostra a amostra na etapa 02. A busca não consegue filtrar idade nem sexo.

## Etapas

| Etapa | Arquivos | Situação |
|---|---|---|
| 01 Busca no GEO | `config/busca.yaml`, `R/01_busca.R`, `run_01_busca.R` → `output/01_busca/`, `docs/validacao_01_busca.md`, `docs/etapa_01_busca.docx` | Aprovada (06/10/2026); triagem corrigida pela auditoria de 06/10/2026, aguardando nova validação |
| 02 Metadados e elegibilidade (sexo, idade, status, tecido por amostra; doadoras de 40–60 por estudo) | `config/metadados.yaml`, `R/02_metadados.R`, `run_02_metadados.R`, `input/testes_regras.csv`, `input/curadoria.csv` → `output/02_metadados/`, `docs/validacao_02_metadados.md`, `docs/etapa_02_metadados.docx` | Aguardando validação |
| 03 Pré-análise de sexo genético (estudos sem sexo nos metadados) | `config/sexo_genetico.yaml`, `R/03_sexo_genetico.R`, `run_03_sexo_genetico.R` → `output/03_sexo_genetico/`, `docs/validacao_03_sexo_genetico.md`, `docs/etapa_03_sexo_genetico.docx` | Executada; nenhum estudo aceito (decisão de 06/10/2026), aguardando validação |
| 04 Obtenção e processamento dos dados de expressão + controle de qualidade | `config/processamento.yaml`, `R/04_processamento.R`, `run_04_processamento.R` → `output/04_processamento/`, `docs/validacao_04_processamento.md`, `docs/etapa_04_processamento.docx`; intenção: `docs/intencao_04_processamento.docx` | Aprovada (07/10/2026) |
| 05 Efeito do DM2 por estudo e meta-análise por tecido | `config/meta.yaml`, `R/05_meta.R`, `run_05_meta.R` → `output/05_meta/`, `docs/validacao_05_meta.md`, `docs/etapa_05_meta.docx`; intenção: `docs/intencao_05_meta.docx` | Aprovada (07/10/2026), com revisão de metodologia aplicada |
| 06 Redes de coexpressão (WGCNA) | `config/redes.yaml`, `R/06_redes.R`, `run_06_redes.R` → `output/06_redes/`, `docs/validacao_06_redes.md`, `docs/etapa_06_redes.docx`; intenção `docs/intencao_06_redes.docx` | Executada; refeita após as revisões de 08 e 10/10/2026 (kME em 2+ estudos, cache da rede, fígado com GSE130991 + GSE15653); validação formal pendente |
| 07 Enriquecimento (ORA dos módulos; vias por escore competitivo + Hartung-Knapp, p calibrado contra conjuntos sorteados; GSEA só para sentido e leading edge) | `R/07_enriquecimento.R`, `run_07_enriquecimento.R` → `output/07_enriquecimento/`, `docs/etapa_07_enriquecimento.docx` | Executada (calibração empírica em 10/10/2026); validação formal pendente |
| 08 Conectividade entre tecidos (STRING, OmniPath) e painel por programa | `R/08_painel.R`, `run_08_painel.R` → `output/08_painel/`, `docs/etapa_08_painel.docx` | Executada; validação formal pendente |
| 08b Replicação do fígado (GSE130991 descoberta → GSE15653) | `run_08b_replicacao_figado.R` → `output/08_painel/replicacao_figado_*.csv` | Executada (10/10/2026): não replicou |
| 09 Validação com célula única (pseudo-bulk por tipo celular; deconvolução NNLS das ilhotas) | `config/validacao.yaml`, `R/09_validacao_celula.R`, `run_09_validacao_celula.R` → `output/09_validacao_celula/`, `docs/etapa_09_validacao_celula.docx` | Executada (09/10/2026) |
| 10 Curva ROC: deixar um estudo de fora, validação externa e, no fígado (1 estudo), validação cruzada dentro do GSE130991 | `config/roc.yaml`, `R/10_roc.R`, `run_10_roc.R` → `output/10_roc/`, `docs/validacao_10_roc.md`, `docs/etapa_10_roc.docx` | Executada (validação cruzada do fígado em 10/10/2026). Avaliação condicionada à rede da etapa 06 (ver 10d) |
| 10b ROC com otimização aninhada e conjunto comum aos tecidos | `R/10b_roc_otimizada.R`, `run_10b_roc_otimizada.R` → `output/10_roc/otimizada_*.csv`, `docs/etapa_10b_roc_otimizada.docx` | Executada |
| 10c Painel das ilhotas na ROC (gene a gene e em outros tecidos) | `run_10c_painel_roc.R` → `output/10_roc/painel_roc_*.csv`, `docs/etapa_10c_painel_roc.docx` | Executada |
| 10d ROC com a rede refeita em cada rodada (sem o estudo/parte testado e sem os externos) | `run_10d_rede_por_rodada.R` → `output/10_roc/rede_por_rodada*.csv`, `docs/etapa_10d_rede_por_rodada.docx` | Nova (revisão de 11/10/2026) |
| Sanidade e comparabilidade | `config/sanidade.yaml`, `R/97_comparabilidade.R`, `R/98_sanidade.R`, `run_sanidade.R` → `output/sanidade/`, `docs/sanidade.docx` | Roda no fim de cada atualização; ERRO interrompe o `atualizar_documentos.sh` |
| Relatórios | `docs/relatorio_workflow.R`, `docs/relatorio_final.R` → Word; `docs/web/relatorio.html` (publicado como artefato; números escritos à mão, atualizar quando os resultados mudarem) | Atualizados em 11/10/2026 |

Revisões e decisões: `docs/revisao_metodologia_2026-10-07.md`, `docs/revisao_codigo_2026-10-08.md`, `docs/revisao_workflow_2026-10-08.md` (seções 1–9). Varreduras de resgate (idade em artigos, campos clínicos): `docs/varreduras/`.

## Rodar

Cada etapa: `"D:\R-4.4.3\bin\x64\Rscript.exe" --encoding=UTF-8 run_NN_*.R` (R 4.4.3; o 4.5.2 não tem os pacotes). Tudo, em ordem: `sh atualizar_documentos.sh`, que para na primeira falha (inclusive ERRO na sanidade). Cache dos dados brutos e das redes: `D:/dm_jana_cache/menopausa`.

Pacotes principais: rentrez, GEOquery, yaml, dplyr, limma, edgeR, WGCNA, fgsea, metafor (conferência), pROC, nnls, officer (Word).

## Glossário

Conceitos técnicos explicados em linguagem simples em `config/glossario.yaml` (pedido de 07/10/2026). Cada documento de etapa traz a seção "Conceitos técnicos" com os termos que usa; `docs/glossario.docx` reúne todos. Termo novo numa análise entra no glossário na mesma alteração.


## Atualizar documentos

Uma mudança numa etapa altera as seguintes. Depois de mudar a etapa N, gerar de novo os documentos da etapa N até a última; para todas: `sh atualizar_documentos.sh` (os documentos Word precisam estar fechados).
