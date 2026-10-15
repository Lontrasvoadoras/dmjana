###############################################################################
#  99_documentar.R - documento Word de cada etapa (pedido do usuário, 06/10/2026)
#
#  Cada etapa gera docs/etapa_NN_<nome>.docx com: objetivo, pacotes usados (versão e motivo),
#  fontes de dados, critérios de inclusão e de exclusão (termos exatos), resultado da execução,
#  decisões validadas e arquivos de saída. Termos, contagens e versões vêm da configuração, das
#  saídas e do próprio R, para o documento nunca divergir do código.
###############################################################################

# Tabela de pacotes: nome, versão instalada, onde é usado e por quê
tabela_pacotes <- function(pacotes) {
  data.frame(Pacote = names(pacotes),
             `Versão` = vapply(names(pacotes), function(p) if (p == "R") paste(R.version$major, R.version$minor, sep = ".")
                             else tryCatch(as.character(utils::packageVersion(p)), error = function(e) "não instalado"), ""),
             `Uso e motivo` = unname(unlist(pacotes)), check.names = FALSE, stringsAsFactors = FALSE)
}

# Conceitos técnicos de uma etapa (config/glossario.yaml; pedido do usuário de 07/10/2026)
glossario <- function(etapa = NULL, arq = "config/glossario.yaml") {
  g <- yaml::read_yaml(arq)$termos
  g <- Filter(function(t) is.null(etapa) || any(etapa %in% unlist(t$etapas)), g)
  data.frame(Termo = vapply(g, `[[`, "", "termo"), `O que é` = vapply(g, `[[`, "", "explicacao"),
             Etapas = vapply(g, function(t) paste(unlist(t$etapas), collapse = ", "), ""), check.names = FALSE, stringsAsFactors = FALSE)
}

# Monta o .docx a partir de uma lista de blocos: list(tipo = "h1"|"h2"|"p"|"b"|"tabela"|"img", ...).
# Com etapa = "NN", acrescenta ao final a seção "Conceitos técnicos" com os termos do glossário dessa etapa.
gravar_docx <- function(blocos, arq, titulo, etapa = NULL) {
  if (!is.null(etapa)) {
    gl <- glossario(etapa)
    if (nrow(gl)) blocos <- c(blocos, list(list(tipo = "h2", texto = "Conceitos técnicos"),
      list(tipo = "p", texto = "Explicação, em linguagem simples, dos termos técnicos usados nesta etapa (glossário completo em docs/glossario.docx)."),
      list(tipo = "tabela", df = gl[, c("Termo", "O que é")])))
  }
  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, titulo, style = "heading 1")
  for (b in blocos) {
    doc <- switch(b$tipo,
      h2 = officer::body_add_par(doc, b$texto, style = "heading 2"),
      h3 = officer::body_add_par(doc, b$texto, style = "heading 3"),
      p  = officer::body_add_par(doc, b$texto, style = "Normal"),
      b  = Reduce(function(d, t) officer::body_add_par(d, paste0("• ", t), style = "Normal"), b$itens, doc),
      img = {
        d2 <- officer::body_add_img(doc, b$arq, width = b$largura %||% 6.5, height = b$altura %||% 4)
        if (!is.null(b$nota)) officer::body_add_par(d2, b$nota, style = "Normal") else d2
      },
      tabela = {
        d2 <- officer::body_add_table(doc, b$df, style = "table_template", header = TRUE)
        if (!is.null(b$nota)) officer::body_add_par(d2, b$nota, style = "Normal") else d2
      })
  }
  pasta(dirname(arq)); print(doc, target = arq)
  log_msg("DOCUMENTO | %s", arq)
  arq
}

# ---------------- ETAPA 01: busca ----------------
documentar_etapa_01 <- function(cfg, b, arq = "docs/etapa_01_busca.docx") {
  cat <- b$catalogo; B <- cfg$busca; T <- cfg$triagem
  pac <- tabela_pacotes(list(
    R = "Linguagem do workflow.",
    rentrez = "Acesso às E-utilities do NCBI: entrez_search (contar e listar as séries de cada consulta) e entrez_summary (título, resumo, plataforma, número de amostras, espécies e PubMed de cada série). Escolhido por ser o cliente oficial em R das E-utilities, com registro da consulta exata.",
    yaml = "Leitura de config/busca.yaml, onde ficam todos os termos e limites (nada de critério fixo no código).",
    dplyr = "coalesce e case_when na triagem: cada série recebe um único motivo de exclusão, na ordem de prioridade."))
  termos_tec <- data.frame(Tecido = names(cfg$tecidos), `Termos de busca` = vapply(cfg$tecidos, function(x) paste(x, collapse = "; "), ""),
                           `Séries encontradas` = b$consultas$n_resultados[match(names(cfg$tecidos), b$consultas$tecido)],
                           `Incluídas` = vapply(names(cfg$tecidos), function(t) sum(cat$triagem == "incluido" & grepl(t, cat$tecidos_busca)), 1L),
                           check.names = FALSE)
  n_mot <- function(rx) sum(grepl(rx, cat$motivo))
  excl <- data.frame(
    `Critério` = c("Espécie", "Tipo de dado", "Tamanho", "Espécie no título", "Termo no título",
                 "Tecido fora do escopo no título", "Termos genéricos que não salvam",
                 "Revisão: outro tipo de dado no título", "Revisão: mais de uma espécie", "Revisão: célula única", "Revisão: série muito grande"),
    Regra = c(sprintf("Nenhuma amostra de %s (ignorando %s)", B$organismo, paste(unlist(T$especies_ignorar), collapse = " e ")),
              "Não é perfil de expressão (array ou RNA-seq)", sprintf("Menos de %d amostras", T$n_min_amostras),
              paste(unlist(T$especies_titulo), collapse = "; "),
              paste(unlist(T$excluir_titulo), collapse = "; "),
              paste(unlist(T$tecido_fora_escopo), collapse = "; "),
              paste(unlist(T$tecido_generico), collapse = "; "),
              paste(unlist(T$outro_tipo_dado_titulo), collapse = "; "),
              "Homo sapiens junto com outra espécie",
              paste(unlist(T$revisar_titulo), collapse = "; "),
              sprintf("Mais de %d amostras", T$n_max_amostras)),
    Motivo = c("A pergunta é humana; 'synthetic construct' e vírus vêm de sondas de controle da plataforma, não de amostras",
               "Só expressão gênica responde à pergunta",
               "Abaixo disso não cabem 2 doadoras com DM2 e 2 sem diabetes (era 8 até a auditoria de 06/10/2026)",
               "Modelos animais; palavra exata, sem plural tolerante ('rates' não é 'rat')",
               "Células cultivadas ou modificadas, diabetes gestacional e tecido tumoral",
               "Só exclui quando o título NÃO cita também um tecido de interesse (ex.: PBMC de pacientes com nefropatia fica)",
               "Não contam como tecido de interesse (ex.: 'glomerular endothelial' sai)",
               "A série também é de expressão no GEO (ex.: multiome ATAC + RNA); a etapa 02 lê os metadados e a etapa de dados confirma a expressão",
               "A etapa 02 conta só as amostras humanas",
               "Pode ter desenho por doador; decisão depois da etapa 02",
               "Provável compilação ou célula única"),
    `Séries` = c(n_mot("não humanas"), n_mot("não é perfil"), n_mot("^menos de"),
                 sum(grepl("^título fora", cat$motivo) & cat$termo_triagem %in% unlist(T$especies_titulo)),
                 sum(grepl("^título fora", cat$motivo) & !cat$termo_triagem %in% unlist(T$especies_titulo)),
                 n_mot("^tecido fora"), NA, n_mot("outro tipo de dado"), n_mot("mais de uma espécie"),
                 n_mot("célula única"), n_mot("^mais de [0-9]+ amostras")),
    check.names = FALSE)
  sem <- b$sementes; sem$Encontrada <- ifelse(sem$gse %in% cat$gse[cat$encontrado_pela_busca], "sim", "não")
  sem$Triagem <- cat$triagem[match(sem$gse, cat$gse)]
  blocos <- list(
    list(tipo = "p", texto = sprintf("Gerado em %s a partir de config/busca.yaml e output/01_busca/. Workflow: efeito do DM2 em mulheres de 40–60 anos (proxy da transição menopausal), só com bancos públicos do GEO que tenham essas mulheres.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
    list(tipo = "h2", texto = "Resumo"),
    list(tipo = "p", texto = sprintf("A busca no GEO (06/10/2026, uma consulta por tecido) encontrou %d séries de expressão gênica humana que citam DM2. A triagem automática pelo título incluiu %d, mandou %d para revisão (a etapa 02 lê os metadados delas antes de decidir) e excluiu %d, cada uma com o motivo registrado. Os %d estudos já conhecidos com mulheres de 40–60 anos (sementes) foram todos encontrados pela busca. Depois de uma auditoria das exclusões (seção 7), regras que tiravam estudos úteis foram corrigidas.",
      nrow(cat), sum(cat$triagem == "incluido"), sum(cat$triagem == "revisar"), sum(cat$triagem == "excluido"), nrow(b$sementes))),
    list(tipo = "h2", texto = "1. Objetivo da etapa"),
    list(tipo = "p", texto = "Encontrar todos os estudos públicos de expressão gênica com DM2 e controles nos tecidos de interesse, registrando cada consulta e o motivo de cada exclusão. A busca não consegue filtrar idade nem sexo (o GEO não indexa isso); a restrição a mulheres de 40–60 anos é feita na etapa 02, amostra a amostra."),
    list(tipo = "h2", texto = "2. Pacotes usados"),
    list(tipo = "tabela", df = pac),
    list(tipo = "h2", texto = "3. Fonte de dados"),
    list(tipo = "p", texto = sprintf("GEO DataSets (banco '%s') pelas E-utilities do NCBI, com pausa de %s s entre chamadas (limite sem chave de API). Uma consulta por tecido.", B$base, B$pausa_seg)),
    list(tipo = "h2", texto = "4. Critérios de inclusão"),
    list(tipo = "b", itens = c(
      sprintf("Organismo: %s.", B$organismo),
      "Tipo de entrada: série do GEO (GSE).",
      sprintf("Tipo de dado: %s.", paste(unlist(B$tipos_dado), collapse = " ou ")),
      sprintf("Publicação a partir de %s.", B$data_publicacao_min),
      sprintf("Termos de DM2 (qualquer um): %s.", paste(unlist(B$termos_doenca), collapse = "; ")),
      "E pelo menos um termo do tecido (tabela abaixo).",
      sprintf("Pelo menos %d amostras e título sem termos de exclusão.", T$n_min_amostras),
      "Estudos-semente (já conhecidos com mulheres de 40–60) entram sempre e medem a sensibilidade da busca.")),
    list(tipo = "tabela", df = termos_tec, nota = "Uma série pode aparecer em mais de um tecido. O tecido real de cada amostra é lido na etapa 02."),
    list(tipo = "h2", texto = "5. Critérios de exclusão e de revisão manual"),
    list(tipo = "tabela", df = excl, nota = sprintf("Termos do título comparados com limites de palavra e plural opcional (exceto espécies); 'ChIP' e 'ATAC' sensíveis a maiúsculas (evita 'BeadChip'). O resumo não é usado na triagem, porque estudos humanos citam camundongos e linhagens. Regras testadas com %d casos (input/testes_triagem.csv).", nrow(utils::read.csv("input/testes_triagem.csv")))),
    list(tipo = "h2", texto = "6. Resultado"),
    list(tipo = "b", itens = c(sprintf("%d séries únicas encontradas.", nrow(cat)),
                               sprintf("Incluídas: %d. Para revisão manual: %d. Excluídas: %d.", sum(cat$triagem == "incluido"), sum(cat$triagem == "revisar"), sum(cat$triagem == "excluido")),
                               sprintf("Sensibilidade: %d de %d estudos-semente encontrados pela busca.", sum(sem$Encontrada == "sim"), nrow(sem)))),
    list(tipo = "tabela", df = sem[, c("gse", "tecido", "Encontrada", "Triagem")]),
    list(tipo = "h2", texto = "7. Decisões validadas pelo usuário"),
    list(tipo = "b", itens = c(
      "06/10/2026, escopo: tecidos = ilhotas, músculo, adiposo, fígado, sangue + osso, endométrio/ovário, mama e vasos; condição = só DM2 com controles; código escrito do zero.",
      "06/10/2026, 1ª execução: termos específicos de DM2 acrescentados mantendo 'diabetic'; tecido fora do escopo excluído pelo título só quando o título não cita tecido de interesse; títulos com diabetes tipo 1 seguem para a etapa 02.",
      "06/10/2026, correções na revisão: plural nos termos ('PBMCs'); termos genéricos de vaso não salvam título fora do escopo; câncer, carcinoma, tumor e melanoma excluem sempre.",
      "06/10/2026: etapa 01 aprovada pelo usuário ao seguir para a etapa 02; os estudos para revisão entram na etapa 02 só para leitura dos metadados (decisão final depois).",
      "06/10/2026, auditoria das exclusões pedida pelo usuário (o GSE200044, 'single-cell multiome (ATAC and RNA)' de ilhotas com DM2, tinha saído pelo termo 'ATAC'). Correções aprovadas: (a) termos de outro tipo de dado mandam para revisão; (b) 'synthetic construct' e vírus não contam como espécie (ex.: GSE189007, sangue com DM2, tinha saído como 'mais de uma espécie'); (c) série humana com parte em outra espécie vai para revisão; (d) espécies no título só como palavra exata ('rates' excluía o GSE77962); (e) mínimo de amostras 8 → 4. A busca de 06/10/2026 foi mantida e só a triagem foi refeita; casos de teste em input/testes_triagem.csv.")),
    list(tipo = "h2", texto = "8. Arquivos"),
    list(tipo = "b", itens = c("Código: R/01_busca.R; execução: run_01_busca.R; configuração: config/busca.yaml; sementes: input/estudos_semente.csv; testes: input/testes_triagem.csv. Triagem anterior à auditoria: output/antes_auditoria/catalogo_01.csv.",
                               "Saídas: output/01_busca/consultas.csv (texto exato e data de cada consulta), catalogo.csv (uma linha por série, com triagem e motivo), revisar.csv.",
                               "Validação: docs/validacao_01_busca.md.")))
  gravar_docx(blocos, arq, "Etapa 01 — Busca sistemática no GEO", etapa = "01")
}

# ---------------- ETAPA 02: metadados e elegibilidade ----------------
documentar_etapa_02 <- function(M, a, el, testes, lido, arq = "docs/etapa_02_metadados.docx") {
  S <- M$status; E <- M$elegibilidade; h <- a[a$humano, ]
  pac <- tabela_pacotes(list(
    R = "Linguagem do workflow. utils::download.file baixa o texto de cada série; regmatches/grepl (expressões regulares PCRE) leem os campos.",
    yaml = "Leitura de config/metadados.yaml, onde ficam todas as expressões regulares e limites (nada de critério fixo no código).",
    dplyr = "case_when na classificação do status e na categoria de cada estudo (ordem de prioridade explícita); contagens das chaves.",
    tidyr = "pivot_wider: formato longo (uma linha por campo) para uma linha por amostra.",
    officer = "Gera este documento Word a partir da configuração e das saídas."))
  regras <- data.frame(
    Campo = c("Sexo", "Sexo", "Sexo", "Idade", "Idade", "Idade",
              "Status", "Status: EXCLUIR (1º)", "Status: INTERMEDIÁRIO (2º)", "Status: ND (3º)", "Status: DM2 (3º)",
              "Status: diabetes sem tipo (4º)", "Status: contexto tipo 1", "Tecido", "Material cultivado (sai)",
              "Intervenção", "Condição basal (fica)", "Doador"),
    Regra = c(M$sexo$chave, M$sexo$feminino, M$sexo$masculino, M$idade$chave, M$idade$excluir_chave,
              sprintf("faixas de até %d anos = ponto médio; mais largas, '<' ou '>' = sem idade", M$idade$faixa_max_anos),
              sprintf("chaves: %s (exceto %s); sem chave, título + fonte", S$chave, S$excluir_chave),
              S$excluir, S$intermediario, S$nao_diabetico, S$dm2, S$diabetes_sem_tipo, S$contexto_tipo1,
              paste(sprintf("%s = %s", names(M$tecido$mapa), unlist(M$tecido$mapa)), collapse = "; "),
              M$material$cultivado, M$intervencao$chave, M$intervencao$basal,
              sprintf("chaves: %s (exceto %s); sem chave, cada amostra = um doador", M$doador$chave, M$doador$excluir_chave)),
    Uso = c("Chave da característica", "Valor = feminino", "Valor = masculino", "Chave da característica", "Chaves que não são idade",
            "Leitura do valor", "Onde procurar", "Diabetes tipo 1, gestacional, LADA, MODY e secundário: sai",
            "Pré-diabetes e resistência à insulina: sai", "Controle; frases de não diabético são retiradas antes de procurar DM2",
            "DM2", "'diabetic' sozinho = DM2 se o estudo não cita tipo 1", "Título ou resumo da série; se cita, 'diabetic' sozinho fica AMBÍGUO (sai)",
            "1º tecido que casa, na ordem", "Fonte, título e características", "Chaves de tratamento, tempo, visita, estímulo",
            "Valor que mantém a amostra; qualquer outro valor de intervenção tira a amostra", "Conta doadoras únicas"),
    check.names = FALSE, stringsAsFactors = FALSE)
  ct <- as.data.frame(table(Categoria = el$categoria), stringsAsFactors = FALSE); names(ct)[2] <- "Estudo × tecido"
  eleg <- el[el$categoria == "elegivel", c("gse", "tecido", "F40a60_T2D", "F40a60_ND", "triagem_01")]
  names(eleg) <- c("GSE", "Tecido", "Doadoras DM2 40–60", "Doadoras ND 40–60", "Triagem 01")
  blocos <- list(
    list(tipo = "p", texto = sprintf("Gerado em %s a partir de config/metadados.yaml e output/02_metadados/.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
    list(tipo = "h2", texto = "Resumo"),
    list(tipo = "p", texto = sprintf("Foram lidas as características de %d amostras de %d séries (incluídas e para revisão na etapa 01). Para cada amostra foram reconhecidos sexo, idade, status (DM2, sem diabetes ou outro), tecido, se é material cultivado e se está em condição basal. Ficaram %d amostras de mulheres de 40–60 anos aptas (DM2 %d, sem diabetes %d). Contando doadoras únicas, %d combinações estudo × tecido têm pelo menos %d doadoras com DM2 e %d sem diabetes nessa faixa e seguem para a próxima etapa.",
      nrow(a), length(unique(a$gse)), sum(h$apta & h$mulher_40a60), sum(h$apta & h$mulher_40a60 & h$status == "T2D"), sum(h$apta & h$mulher_40a60 & h$status == "ND"),
      sum(el$categoria == "elegivel"), E$min_por_grupo, E$min_por_grupo)),
    list(tipo = "tabela", df = {x <- el[el$categoria == "elegivel", ]; y <- stats::aggregate(cbind(`Estudos` = 1, `Doadoras DM2 40–60` = x$F40a60_T2D, `Doadoras ND 40–60` = x$F40a60_ND) ~ Tecido, data = transform(x, Tecido = tecido), FUN = sum); y}),
    list(tipo = "h2", texto = "1. Objetivo da etapa"),
    list(tipo = "p", texto = "Ler as características de cada amostra das séries aprovadas na etapa 01 e decidir, amostra a amostra, quem é mulher de 40–60 anos com DM2 ou sem diabetes, em tecido de interesse, não cultivada e em condição basal. Depois, contar doadoras únicas por estudo e tecido e decidir quais estudos têm mulheres suficientes nos dois grupos."),
    list(tipo = "h2", texto = "2. Pacotes usados"),
    list(tipo = "tabela", df = pac),
    list(tipo = "h2", texto = "3. Fonte de dados"),
    list(tipo = "p", texto = sprintf("Texto resumido das amostras (GSM) de cada série no GEO (%s), uma requisição por série, com pausa de %s s e até %d tentativas; guardado em cache/geo/. Séries com mais de %d amostras não são lidas (célula única com uma amostra por célula).",
                                     sub("\\?.*", "", M$download$url), M$download$pausa_seg, M$download$tentativas, M$download$max_amostras)),
    list(tipo = "h2", texto = "4. Critérios de inclusão da amostra"),
    list(tipo = "b", itens = c("Humana (organismo Homo sapiens).",
                               "Status ND (sem diabetes) ou DM2, pelas regras da seção 6.",
                               "Tecido de interesse reconhecido (ilhotas, músculo, adiposo, fígado, sangue, osso, endométrio/ovário, mama, vasos).",
                               "Não cultivada e em condição basal.",
                               sprintf("Para a contagem principal: sexo feminino e %d ≤ idade < %d.", E$janela_idade[1], E$janela_idade[2] + 1))),
    list(tipo = "h2", texto = "5. Critérios de exclusão da amostra"),
    list(tipo = "b", itens = c("Status EXCLUIR (outro tipo de diabetes), INTERMEDIÁRIO (pré-diabetes, resistência à insulina), AMBÍGUO (dois rótulos no mesmo valor, ou 'diabetic' em estudo que cita tipo 1) ou não reconhecido.",
                               "Material cultivado ou diferenciado in vitro.",
                               "Amostra sob intervenção (tratamento, estímulo, pós-exercício, clamp): fica só a basal do mesmo doador.",
                               "Idade dada como faixa larga ou só limite ('>60'): fica sem idade e não conta como 40–60.")),
    list(tipo = "h2", texto = "6. Regras exatas (expressões regulares, comparadas em minúsculas)"),
    list(tipo = "tabela", df = regras, nota = sprintf("Testadas antes de cada execução com %d casos (input/testes_regras.csv): %d corretos. Correções manuais em input/curadoria.csv sobrescrevem qualquer campo, com motivo.", nrow(testes), sum(testes$ok))),
    list(tipo = "h2", texto = "7. Critério de elegibilidade do estudo"),
    list(tipo = "b", itens = c(
      sprintf("Elegível: pelo menos %d doadoras DM2 e %d doadoras ND de %d–%d anos no mesmo estudo e tecido (doadoras únicas, não amostras).", E$min_por_grupo, E$min_por_grupo, E$janela_idade[1], E$janela_idade[2]),
      sprintf("Não elegível, com o primeiro motivo que se aplica: menos de %.0f%% das amostras com status ND/DM2 (sem status); sem sexo, mas com idade e status (candidato ao sexo genético); sem sexo; sem idade; poucas mulheres de 40–60 com DM2 e controles.", 100 * E$min_frac_campo))),
    list(tipo = "h2", texto = "8. Resultado"),
    list(tipo = "b", itens = c(sprintf("%d séries lidas, %d amostras (%d humanas); sem amostras legíveis: %d.", length(unique(a$gse)), nrow(a), nrow(h), length(lido$falhas)),
                               sprintf("Aptas: %d; aptas e mulheres de 40–60: %d (DM2 %d, ND %d).", sum(h$apta), sum(h$apta & h$mulher_40a60),
                                       sum(h$apta & h$mulher_40a60 & h$status == "T2D"), sum(h$apta & h$mulher_40a60 & h$status == "ND")))),
    list(tipo = "tabela", df = ct),
    list(tipo = "tabela", df = eleg, nota = "Estudos elegíveis. A lista completa, com os motivos dos demais, está em output/02_metadados/elegibilidade.csv."),
    list(tipo = "h2", texto = "9. Decisões validadas pelo usuário e motivos"),
    list(tipo = "tabela", df = data.frame(
      Data = "06/10/2026",
      `Decisão` = c(
        "Os 43 estudos 'para revisão' da etapa 01 entram nesta etapa só para leitura dos metadados.",
        sprintf("Mínimo de %d doadoras DM2 e %d ND de %d–%d anos por estudo × tecido.", E$min_por_grupo, E$min_por_grupo, E$janela_idade[1], E$janela_idade[2]),
        "Manter GSE86469; excluir GSE86468.",
        "Manter GSE41762; excluir GSE38642.",
        "Excluir GSE158055.",
        "Normoglicêmicos com história familiar de DM2 (FH+) do GSE25462 ficam ND (controles).",
        "Regras de status, sexo, idade, material e condição basal corrigidas durante a execução (ver seção 6).",
        "Curadoria herdada do workflow_multi_estruturado (seção 9b).",
        "Auditoria das exclusões: correção das regras de status, sexo, condição basal, material cultivado e tecido.",
        "'visit: V1' é a linha de base; amostras não estimuladas ('Unstimulated', 'No treatment', 'CTL') são basais.",
        "Mínimo de 4 amostras na etapa 01 (era 8).",
        "Só contam amostras de expressão de mRNA (array de expressão ou RNA-Seq).",
        "Manter GSE189005; excluir GSE189007.",
        "Ler o GSE124742 apesar do limite de 5.000 amostras (07/10/2026, revisão de metodologia)."),
      Motivo = c(
        "Estudos de célula única podem ter desenho por doador; a decisão final depende do que os metadados mostram.",
        "Mulheres de 40–60 com e sem DM2 são raras nos bancos públicos; com 2 por grupo o estudo ainda estima variância e entra na meta-análise com peso proporcional ao tamanho. Com 3 sairiam GSE221156, GSE76895, GSE86469 e GSE200678.",
        "Os dois têm os mesmos 8 doadores do HPAP (mesmo UNOS id), em bulk e em célula única; contar os dois duplicaria doadoras.",
        "Os dois vêm da coorte de ilhotas de Lund com doadores repetidos (excluído também no workflow anterior); GSE41762 é o maior.",
        "O 'DM2' vem de 'comorbidities: diabetes' em pacientes com COVID-19 e os controles são pessoas sem COVID; o efeito do DM2 ficaria confundido com a COVID.",
        "A descrição de cada uma dessas amostras no GEO diz 'Gene expression of skeletal muscle from subject without diabetes'.",
        "Estudos-semente caíam por erro de regra: 'cultured islets' tratado como cultivado, medidas clínicas ('fasting insulin', 'insulin_0h') tratadas como intervenção, 'exercise: PRE' não reconhecido como basal, identificador do doador de célula única não reconhecido, SuperSeries contadas em dobro, pools com sexos diferentes.",
        "Sexo codificado 0/1 no GSE18732 (confirmado pelo sexo genético) e status só no título das amostras em GSE18732, GSE25462 e GSE15653; GSE81965 são miócitos cultivados.",
        "Pedida pelo usuário depois do GSE200044. Erros achados: 'DM2' não era lido como DM2 e 'CTRL' não era lido como controle; sexo 'FEM'/'MAL' e a chave 'gander' não eram lidos; tratamento em branco tirava a amostra; 'passage: Fresh Frozen' e 'cell line: primary cells' eram tratados como cultura; 'Intima media' (artéria) não era tecido de interesse. Cada correção tem caso de teste em input/testes_regras.csv.",
        "V1 é a primeira visita de estudos longitudinais (antes de qualquer intervenção); sem estímulo a amostra está no estado basal.",
        "Coerente com o critério de 2 doadoras DM2 + 2 sem diabetes; a etapa 02 decide pelos números de doadoras.",
        "Achado na preparação da etapa 04: séries com várias plataformas contavam a mesma pessoa uma vez por ensaio (GSE189007: mRNA, miRNA e promotores; GSE200044 e GSE171153: RNA e ATAC). Arrays de miRNA, promotores, metilação e genotipagem e sequenciamento que não seja RNA-Seq deixam de contar; GSE171153 e GSE200044 ficam com 1/1 e saem.",
        "Os 45 arquivos CEL de mRNA do GSE189007 são idênticos aos do GSE189005 (mesmo nome e tamanho); fica a série só de expressão.",
        "Patch-seq de ilhotas com doadores DM2 (8.477 células) que ficava fora só pelo tamanho. Lido, mas sem idade e sem identificador de doador por célula no GEO (só placa e poço), não entra: sem doador não há pseudo-bulk por doadora nem faixa de 40–60. A ligação célula → doador está só no material do artigo (Camunas-Soler et al., Cell Metab 2020, PMID 32302527)."),
      check.names = FALSE, stringsAsFactors = FALSE),
      nota = "Exclusões registradas em input/exclusoes.csv; correções por amostra em input/curadoria.csv. Pendente para a etapa de dados: conferir se o GSE171153 (cromatina + expressão) tem matriz de expressão por doador."),
    list(tipo = "h2", texto = "9b. Correções manuais aplicadas (input/curadoria.csv)"),
    list(tipo = "tabela", df = stats::setNames(utils::read.csv("input/curadoria.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8"), c("GSE", "Amostras", "Campo", "Valor", "Motivo")),
         nota = "Amostras: * = todas; titulo~ = título casa com a expressão; carac:chave=valor = característica com esse valor."),
    list(tipo = "h2", texto = "10. Arquivos"),
    list(tipo = "b", itens = c("Código: R/02_metadados.R; execução: run_02_metadados.R; configuração: config/metadados.yaml; testes: input/testes_regras.csv; curadoria: input/curadoria.csv; exclusões decididas pelo usuário: input/exclusoes.csv.",
                               "Saídas: output/02_metadados/amostras_longo.csv (texto bruto, uma linha por campo), amostras.csv (uma linha por amostra, harmonizada), elegibilidade.csv (estudo × tecido, contagens e categoria), chaves.csv (cada chave, uso e exemplos), testes_regras.csv.",
                               "Validação: docs/validacao_02_metadados.md.")))
  gravar_docx(blocos, arq, "Etapa 02 — Metadados por amostra e elegibilidade", etapa = "02")
}

# ---------------- ETAPA 03: pré-análise de sexo genético ----------------
documentar_etapa_03 <- function(S, cand, n_sem_sexo, acerto, pv, res, er, achados = character(), arq = "docs/etapa_03_sexo_genetico.docx") {
  R <- S$regras
  pac <- tabela_pacotes(list(
    R = "Linguagem do workflow; stats::kmeans separa os dois grupos da leitura entre amostras; grDevices/graphics desenham as figuras.",
    yaml = "Leitura de config/sexo_genetico.yaml (genes, limiares e regras de aceite).",
    GEOquery = "getGEO baixa a matriz normalizada de cada série (series matrix) e a anotação da plataforma (GPL), com os símbolos dos genes. Escolhido por ser o leitor padrão do GEO em R.",
    Biobase = "exprs e fData extraem a matriz de expressão e a anotação das sondas do objeto do GEOquery.",
    dplyr = "Contagens e resumos por estudo.",
    officer = "Gera este documento Word."))
  hab <- function(x) ifelse(is.na(x), "-", sprintf("%.0f%%", 100 * x))
  ac <- data.frame(GSE = acerto$gse, Plataforma = acerto$gpl, `Declaradas F/M` = sprintf("%d/%d", acerto$declarado_F, acerto$declarado_M),
                   `Com sexo atribuído` = acerto$atribuido, `Acerto` = hab(acerto$acerto), check.names = FALSE)
  rs <- data.frame(GSE = res$gse, Plataforma = res$gpl, XIST = ifelse(res$xist, "sim", "não"), `Separação (DP)` = ifelse(is.na(res$separacao), "-", format(res$separacao)),
                   `Decisão` = res$decisao, F = res$F, M = res$M, `Plataforma validada` = ifelse(res$plataforma_validada, "sim", "não"), check.names = FALSE)
  eg <- data.frame(GSE = er$gse, Tecido = er$tecido, `Doadoras DM2 40–60` = er$F40a60_T2D, `Doadoras ND 40–60` = er$F40a60_ND,
                   `Categoria (plataformas validadas)` = er$categoria_validado, `Categoria (aceitando não validadas)` = er$categoria_se_aceito, check.names = FALSE)
  n_eleg <- sum(er$categoria_validado == "elegivel", na.rm = TRUE); n_eleg2 <- sum(er$categoria_se_aceito == "elegivel", na.rm = TRUE)
  n_final <- sum(er$categoria_final == "elegivel", na.rm = TRUE); nao <- er[nzchar(er$decisao_usuario), ]
  blocos <- list(
    list(tipo = "p", texto = sprintf("Gerado em %s a partir de config/sexo_genetico.yaml e output/03_sexo_genetico/.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
    list(tipo = "h2", texto = "Resumo"),
    list(tipo = "p", texto = sprintf("Dos %d estudo × tecido que saíram da etapa 02 por não terem sexo nos metadados, %d tinham idade, status e amostras de 40–60 anos nos dois grupos; nos outros faltam também idade ou status, e o sexo genético sozinho não os salvaria. O sexo foi lido na expressão de XIST (alto em mulheres) e de genes do cromossomo Y (expressos só em homens), com um método validado antes em estudos com sexo declarado nas mesmas plataformas. O sexo foi lido em %d dos %d candidatos, mas só %d poderiam passar a elegíveis (%s), ambos em plataformas sem estudo de validação. O usuário decidiu não aceitar nenhum dos dois (motivos na seção 8). Resultado final: %d estudo resgatado; o número de estudos elegíveis da etapa 02 não muda.",
                                     n_sem_sexo, nrow(cand), sum(!grepl("^não", res$decisao)), nrow(res), n_eleg2, paste(er$gse[er$categoria_se_aceito %in% "elegivel"], collapse = " e "), n_final)),
    list(tipo = "h2", texto = "1. Objetivo da etapa"),
    list(tipo = "p", texto = "Verificar se o sexo das amostras pode ser recuperado pela expressão gênica nos estudos que saíram da etapa 02 só por falta de sexo nos metadados (pedido do usuário, 06/10/2026). É uma pré-análise: usa a matriz já normalizada pelos autores no GEO; o processamento uniforme dos dados brutos vem depois."),
    list(tipo = "h2", texto = "2. Pacotes usados"),
    list(tipo = "tabela", df = pac),
    list(tipo = "h2", texto = "3. Critérios de inclusão (candidatos)"),
    list(tipo = "b", itens = c(sprintf("Categoria da etapa 02: %s.", paste(unlist(S$candidatos$categorias), collapse = " ou ")),
                               sprintf("Pelo menos %d amostras sem sexo, de 40–60 anos, com DM2 e %d sem diabetes no mesmo estudo e tecido (se todas fossem mulheres, o estudo seria elegível).", S$candidatos$min_sem_sexo_por_grupo, S$candidatos$min_sem_sexo_por_grupo),
                               "Matriz de expressão disponível no GEO, com pelo menos 2 genes do cromossomo Y anotados.")),
    list(tipo = "h2", texto = "4. Método e regras de decisão"),
    list(tipo = "b", itens = c(
      sprintf("Genes: XIST (cromossomo X, expresso só em mulheres) e %s (cromossomo Y).", paste(unlist(S$genes$cromossomo_y), collapse = ", ")),
      sprintf("Leitura (a), dentro da amostra: percentil do gene entre todos os genes medidos na amostra. Mulher: XIST ≥ %.2f e Y ≤ %.2f. Homem: Y ≥ %.2f e XIST ≤ %.2f. O ruído de fundo dos arrays fica entre os percentis 0,4 e 0,7, por isso ausente não é abaixo da mediana.", R$xist_alto, R$y_nao_alto, R$y_alto, R$xist_nao_alto),
      sprintf("Leitura (b), entre amostras: escore z(Y) − z(XIST); dois grupos por k-means, aceitos só com separação ≥ %d desvios-padrão intragrupo (igual ao workflow_multi_estruturado).", R$separacao_min),
      sprintf("Aceite com XIST: (a) e (b) concordam em ≥ %.0f%% das amostras; se o estudo tem um só sexo (sem dois grupos), vale (a) quando ≥ %.0f%% das amostras dão o mesmo sexo. Amostra com leituras discordantes fica sem sexo.", 100 * R$concordancia_min, 100 * R$concordancia_min),
      "Aceite sem XIST na plataforma (só genes Y): vale só (b), com dois grupos separados; um só sexo não é decidível, porque sem XIST não há como distinguir só mulheres de ruído.",
      sprintf("Plataforma validada: pelo menos um estudo com sexo declarado e acerto ≥ %.0f%%.", 100 * S$validacao$acerto_min))),
    list(tipo = "h2", texto = "5. Validação do método"),
    list(tipo = "p", texto = sprintf("A mesma regra foi aplicada a até %d estudos por plataforma COM sexo declarado (pelo menos %d mulheres e %d homens), comparando o sexo genético com o declarado.", S$validacao$estudos_por_plataforma, S$validacao$min_por_sexo, S$validacao$min_por_sexo)),
    list(tipo = "tabela", df = ac, nota = "GSE118230: as 12 amostras declaradas como homens têm XIST alto e Y ausente, iguais às declaradas mulheres; tecido masculino não tem esse perfil, então o mais provável é erro no sexo declarado, não no método."),
    list(tipo = "tabela", df = data.frame(Plataforma = pv$gpl, `Estudos de validação` = pv$estudos_validacao, `Melhor acerto` = hab(pv$melhor_acerto), Validada = ifelse(pv$validada, "sim", "não"), check.names = FALSE),
         nota = "Plataforma sem estudo de validação: não há estudo com sexo declarado nela, ou a matriz no GEO está vazia."),
    list(tipo = "img", arq = "docs/figuras/sexo_genetico_validacao.png", largura = 6.5, altura = 1.8 * ceiling(length(unique(acerto$gse)) / 3), nota = "Validação: cada ponto é uma amostra; cor = sexo declarado (rosa F, azul M). Mulheres ficam à direita e embaixo (XIST alto, Y baixo); homens à esquerda e em cima."),
    list(tipo = "h2", texto = "6. Resultado nos candidatos"),
    list(tipo = "tabela", df = rs),
    list(tipo = "img", arq = "docs/figuras/sexo_genetico_candidatos.png", largura = 6.5, altura = 1.8 * ceiling(nrow(res) / 3), nota = "Candidatos: cor = sexo genético atribuído (cinza = sem sexo)."),
    list(tipo = "h2", texto = "7. Elegibilidade com o sexo genético"),
    list(tipo = "tabela", df = cbind(eg, `Categoria final` = er$categoria_final), nota = "Mesma regra da etapa 02 (mínimo de 2 doadoras DM2 e 2 sem diabetes de 40–60 anos), com o sexo genético onde o declarado falta."),
    list(tipo = "h2", texto = "8. Achados e decisão do usuário"),
    list(tipo = "b", itens = gsub("[*][*]", "", achados)),
    list(tipo = "p", texto = "Decisão do usuário (06/10/2026): nenhum dos dois estudos que poderiam ser resgatados foi aceito."),
    list(tipo = "tabela", df = data.frame(GSE = nao$gse, Tecido = nao$tecido, `Seria elegível com` = sprintf("%d DM2 / %d ND", nao$F40a60_T2D, nao$F40a60_ND),
                                          `Decisão` = nao$decisao_usuario, Motivo = nao$motivo_usuario, check.names = FALSE),
         nota = "Motivos registrados em config/sexo_genetico.yaml (nao_aceitos); categoria final em output/03_sexo_genetico/elegibilidade_resgate.csv (coluna categoria_final)."),
    list(tipo = "h2", texto = "9. Decisões"),
    list(tipo = "tabela", df = data.frame(Data = "06/10/2026",
      `Decisão` = c("Fazer uma pré-análise de sexo genético dos estudos sem sexo nos metadados.",
                    "Só candidatos com idade e status.",
                    "Validar o método em estudos com sexo declarado antes de usá-lo.",
                    "Limiares da leitura (a) ajustados no piloto (ruído de fundo 0,4–0,7) e conferidos na validação.",
                    "Sem XIST, decide só a leitura entre amostras.",
                    "GSE174502 saiu como material cultivado (correção na etapa 02).",
                    "Não aceitar GSE43950.",
                    "Não aceitar GSE128665."),
      Motivo = c("Pedido do usuário.",
                 "Sem idade, o sexo sozinho não torna o estudo elegível.",
                 "Evitar ajustar limiares só nos próprios candidatos (raciocínio circular).",
                 "Com ausente = abaixo da mediana, estudos de um só sexo ficavam sem sexo (ex.: GSE19420, GSE128665).",
                 "Na GPL6244 a leitura (a) só com Y acertou 80% (GSE50397); a (b) acertou 96,6–100%.",
                 "Células-tronco derivadas de tecido adiposo (ASC) cultivadas; a regra de cultura não conhecia ASC.",
                 unname(unlist(S$nao_aceitos$GSE43950)), unname(unlist(S$nao_aceitos$GSE128665))), check.names = FALSE)),
    list(tipo = "h2", texto = "10. Arquivos"),
    list(tipo = "b", itens = c("Código: R/03_sexo_genetico.R; execução: run_03_sexo_genetico.R; configuração: config/sexo_genetico.yaml.",
                               "Saídas: output/03_sexo_genetico/candidatos.csv, sexo_amostras.csv (percentis, escore e sexo por amostra), resumo_estudos.csv, elegibilidade_resgate.csv, validacao_amostras.csv, validacao_acerto.csv.",
                               "Figuras: docs/figuras/sexo_genetico_validacao.png e sexo_genetico_candidatos.png. Validação: docs/validacao_03_sexo_genetico.md.")))
  gravar_docx(blocos, arq, "Etapa 03 — Pré-análise de sexo genético", etapa = "03")
}

# ---------------- ETAPA 04: obtenção e processamento dos dados de expressão ----------------
documentar_etapa_04 <- function(P, inv, ret, arq = "docs/etapa_04_processamento.docx") {
  Q <- P$qc; pr <- inv[is.na(inv$erro %||% NA), ]
  pac <- tabela_pacotes(list(
    R = "Linguagem do workflow; utils::download.file baixa os arquivos do GEO (cache em D:, fora do OneDrive).",
    yaml = "Leitura de config/processamento.yaml (tipo de processamento de cada estudo e regras do controle de qualidade).",
    GEOquery = "Matrizes publicadas (series matrix) e tabelas de anotação das plataformas (GPL).",
    oligo = "Leitura dos arquivos CEL e RMA (correção de fundo, normalização por quantis e sumarização), no nível de gene nos arrays Gene ST e Clariom.",
    AnnotationDbi = "mapIds: sonda -> símbolo do gene pelos pacotes .db de cada array Affymetrix (anotação uniforme e versionada).",
    org.Hs.eg.db = "Ensembl -> símbolo nas tabelas de contagens.",
    limma = "neqc (Illumina, com p de detecção), normexp e quantis (Agilent), quantis (matrizes do autor).",
    edgeR = "filterByExpr, TMM e log2-CPM das contagens de RNA-seq e pseudo-bulk.",
    Matrix = "Matrizes esparsas para somar as células de cada doador (pseudo-bulk).",
    rhdf5 = "Leitura em blocos do arquivo h5ad (contagens por célula e doador de cada célula).",
    officer = "Gera este documento Word."))
  res <- data.frame(GSE = inv$gse, Tecido = inv$tecido, Tipo = inv$tipo, Genes = inv$genes, `Amostras` = inv$amostras, Mantidas = inv$mantidas, Doadores = inv$doadores %||% NA,
                    `F 40–60 DM2/ND` = ifelse(is.na(inv$F40a60_T2D), "-", sprintf("%d/%d", inv$F40a60_T2D, inv$F40a60_ND)), Categoria = inv$categoria, check.names = FALSE)
  fon <- data.frame(GSE = pr$gse, Fonte = pr$fonte, Processamento = pr$processamento, `Sexo genético` = pr$sexo_genetico, check.names = FALSE)
  pt <- pr[pr$categoria == "pronto para a etapa 05", ]
  blocos <- list(
    list(tipo = "p", texto = sprintf("Gerado em %s a partir de config/processamento.yaml e output/04_processamento/.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
    list(tipo = "h2", texto = "Resumo"),
    list(tipo = "p", texto = sprintf("Os %d estudos elegíveis foram baixados e processados, cada tipo de dado sempre do mesmo jeito e cada estudo normalizado separadamente. Depois do controle de qualidade (sexo genético, amostras discrepantes, tamanho de biblioteca e células por doador), %d estudos estão prontos para a análise da etapa 05, com %d doadoras com DM2 e %d sem diabetes de 40–60 anos; %d amostras foram retiradas, cada uma com o motivo registrado.",
                                     nrow(inv), nrow(pt), sum(pt$F40a60_T2D), sum(pt$F40a60_ND), if (is.null(ret)) 0L else nrow(ret))),
    list(tipo = "h2", texto = "1. Objetivo da etapa"),
    list(tipo = "p", texto = "Obter a expressão gênica de cada amostra apta dos estudos elegíveis num formato comparável dentro do estudo (log2, genes pelo símbolo oficial), confirmar o sexo pela expressão e retirar amostras com problema técnico, registrando cada retirada."),
    list(tipo = "h2", texto = "2. Pacotes usados"),
    list(tipo = "tabela", df = pac),
    list(tipo = "h2", texto = "3. Critérios de inclusão"),
    list(tipo = "b", itens = c("Estudos: elegíveis na etapa 02 (input/exclusoes.csv já aplicado).",
                               "Amostras: todas as aptas do estudo (DM2 ou sem diabetes, tecido de interesse, não cultivadas, basais, ensaio de mRNA), de todas as idades e dos dois sexos (D1). A restrição a mulheres de 40–60 é feita no modelo da etapa 05.",
                               "Dados brutos sempre que existem; matriz do autor só sem brutos (D2).")),
    list(tipo = "h2", texto = "4. Critérios de exclusão de amostras (controle de qualidade)"),
    list(tipo = "tabela", df = data.frame(`Critério` = c("Sexo genético", "Estudo com discordância alta", "Amostra discrepante", "Biblioteca pequena", "Poucas células", "Lote confundido com o grupo"),
      Regra = c("Sexo pela expressão (método da etapa 03) diferente do declarado", sprintf("Mais de %.0f%% de discordância", 100 * Q$sexo_discordancia_max),
                sprintf("Conectividade entre amostras com z < %s (%d genes mais variáveis; só com %d ou mais amostras)", Q$conectividade_z_min, Q$genes_conectividade, Q$min_amostras_conectividade),
                sprintf("RNA-seq com menos de %s contagens", format(Q$biblioteca_min, big.mark = ".", decimal.mark = ",")), sprintf("Pseudo-bulk com menos de %d células no doador", Q$celulas_min_por_doador),
                sprintf("V de Cramér entre data de leitura e grupo > %s e menos de %.0f%% das amostras em lotes com os dois grupos", Q$lote_v_cramer_max, 100 * Q$lote_frac_mista_min)),
      Motivo = c("Indica troca de amostra ou erro de metadado (D6)", "Estudo vai só para a sensibilidade, sem descartar tudo (D6)", "Critério usual de conectividade (Oldham et al. 2012) (D7)",
                 "Perfil pouco confiável", "Soma de poucas células não representa o doador", "O efeito do DM2 não se separa do lote; estudo vai só para a sensibilidade (decisão de 07/10/2026)"), check.names = FALSE)),
    list(tipo = "h2", texto = "5. Resultado por estudo"),
    list(tipo = "tabela", df = res),
    list(tipo = "tabela", df = fon, nota = "Fonte, processamento e resultado do sexo genético de cada estudo."),
    list(tipo = "img", arq = "docs/figuras/pca_estudos.png", largura = 6.5, altura = 1.6 * ceiling(nrow(pr) / 4), nota = "PCA de cada estudo: vermelho = DM2, azul = sem diabetes; círculo = F, triângulo = M, aberto = sem sexo; X = amostra retirada."))
  if (!is.null(ret) && nrow(ret)) blocos <- c(blocos, list(list(tipo = "h2", texto = "6. Amostras retiradas"),
    list(tipo = "tabela", df = data.frame(GSE = ret$gse, Amostra = ret$coluna, `Sexo declarado` = ret$sexo, `Sexo genético` = ret$sexo_genetico, Status = ret$status, Idade = ret$idade, Motivo = ret$motivo, check.names = FALSE))))
  blocos <- c(blocos, list(
    list(tipo = "h2", texto = "7. Decisões validadas pelo usuário"),
    list(tipo = "tabela", df = data.frame(Data = "06/10/2026", `Nº` = sprintf("D%d", 1:7),
      `Decisão` = c("Processar todas as amostras aptas (todas as idades, os dois sexos).", "Brutos sempre que existirem; matriz do autor só sem brutos.", "Célula/núcleo único: pseudo-bulk de todas as células por doador.",
                    "GSE316126 (NanoString): só análise dirigida aos genes do painel.", "GSE189005 x GSE189007: fica o GSE189005.", "Sexo genético discordante sai; estudo com > 20% só na sensibilidade.", "Conectividade z < −3 sai."),
      Motivo = c("Normalização e QC mais estáveis; sexo genético entre amostras; análises de sensibilidade.", "Processamento uniforme.", "Comparável às ilhotas inteiras; doador como unidade.",
                 "Painel de ~750 genes, sem o genoma inteiro.", "Os 45 CEL de mRNA são idênticos (nome e tamanho); as outras amostras do GSE189007 são miRNA e promotores.", "Possível troca de amostras.", "Critério usual de conectividade."), check.names = FALSE)),
    list(tipo = "h2", texto = "8. Correções feitas durante a etapa"),
    list(tipo = "b", itens = c(
      "Etapa 02: séries com várias plataformas contavam a mesma pessoa uma vez por ensaio (GSE189007: mRNA, miRNA e promotores; GSE200044 e GSE171153: RNA e ATAC). Passaram a contar só ensaios de mRNA; GSE171153 e GSE200044 deixaram de ser elegíveis (1/1).",
      "GSE184050: só há contagens já normalizadas pelo autor (DESeq2) no GEO; usadas em log2 e registradas como matriz do autor.",
      "GSE29226: havia a matriz Illumina não normalizada; usado neqc (melhor que a matriz do autor prevista na intenção).",
      "GSE221156: os arquivos brutos do GEO juntam doadores por biblioteca; o pseudo-bulk usa o h5ad do CELLxGENE, que identifica o doador de cada célula.",
      "Sexo genético em RNA-seq calculado antes do filtro de expressão (XIST e genes Y são expressos só em parte das amostras e eram filtrados).",
      "GSE198922: o arquivo processed.data tem valores já normalizados (decimais, ~CPM), não contagens brutas; tratado como matriz do autor (log2(x + 1)).",
      "GSE23561: a coluna de símbolos da plataforma GPL10775 se chama 'Symbol v12'; a leitura passou a reconhecê-la (antes saíam 0 genes).",
      "GSE29226: as 24 amostras são 6 doadoras (3 sem diabetes, 3 com DM2) com 4 arrays cada (réplicas técnicas, pela descrição no GEO); a etapa 02 contava cada array como doadora (8/8 de 40–60). Com a curadoria do doador, ficam 2/2. As réplicas são promediadas por doadora (expressao_por_doador).",
      "GSE21340: 5 arrays 'replicate control' são cópias de uma amostra de referência (homem de 26 anos); saem por curadoria (status EXCLUIR).",
      "Leitura dos CSV: em estudos só com mulheres a coluna de sexo ('F') era lida como FALSE; as colunas de sexo passaram a ser lidas como texto.",
      "Lote de processamento (acrescentado em 07/10/2026, depois da 1ª execução da etapa 05): a data de leitura de cada array (CEL, Agilent) foi registrada por amostra e a confusão com o grupo DM2/ND medida por estudo. GSE189005 (V de Cramér 0,80; 30% das amostras em lotes mistos) e GSE21340 (0,70; 47%) passaram a 'só sensibilidade'.")),
    list(tipo = "h2", texto = "9. Arquivos"),
    list(tipo = "b", itens = c("Código: R/04_processamento.R; execução: run_04_processamento.R; configuração: config/processamento.yaml; intenção: docs/intencao_04_processamento.docx.",
                               "Saídas: output/04_processamento/<GSE>/expressao.rds (log2 e, quando há, contagens brutas), amostras_qc.csv (sexo declarado e genético, testes e motivo), resumo.csv; output/04_processamento/inventario.csv.",
                               "Figura: docs/figuras/pca_estudos.png. Validação: docs/validacao_04_processamento.md."))))
  gravar_docx(blocos, arq, "Etapa 04 — Obtenção e processamento dos dados de expressão", etapa = "04")
}

# ---------------- glossário completo ----------------
documentar_glossario <- function(arq = "docs/glossario.docx") {
  gl <- glossario()
  gravar_docx(list(list(tipo = "p", texto = sprintf("Gerado em %s a partir de config/glossario.yaml. Termos técnicos usados no workflow_dm_menopausa, em linguagem simples, com as etapas em que aparecem. Cada documento de etapa traz a parte do glossário que usa.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
                   list(tipo = "tabela", df = gl)), arq, "Glossário de conceitos técnicos")
}

# ---------------- ETAPA 05: efeito do DM2 por estudo e meta-análise por tecido ----------------
documentar_etapa_05 <- function(MC, info, cont, poder, top_vias, top_genes, sens, nano, multi, info_conf = NULL, fora_genoma = character(), loo_vias = NULL, vi = NULL, sob = NULL, ieg_res = NULL, ieg = NULL, arq = "docs/etapa_05_meta.docx") {
  f2 <- function(x) formatC(x, format = "f", digits = 2, decimal.mark = ",")
  fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
  pac <- tabela_pacotes(list(
    R = "Linguagem do workflow; stats: meta-análise de efeitos aleatórios (DerSimonian-Laird) escrita no próprio código, aplicada a todos os genes de uma vez, e FDR (p.adjust, Benjamini-Hochberg).",
    yaml = "Leitura de config/meta.yaml (decisões E1-E9, marcadores de composição celular).",
    limma = "Modelos lineares por estudo: lmFit, makeContrasts, contrasts.fit, eBayes (moderação da variância), voom e limma-trend.",
    edgeR = "Contagens: DGEList, filterByExpr e TMM antes do voom.",
    msigdbr = "Conjuntos Hallmark do MSigDB com símbolos humanos (escores de via).",
    officer = "Gera este documento Word."))
  n_rep <- sum(cont$rep_fdr05); n_vias <- sum(cont$vias_fdr05)
  blocos <- list(
    list(tipo = "p", texto = sprintf("Gerado em %s a partir de config/meta.yaml e output/05_meta/.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
    list(tipo = "h2", texto = "Resumo"),
    list(tipo = "p", texto = sprintf("O efeito do DM2 em mulheres de 40–60 anos foi estimado em cada um dos %d estudos (cada um sozinho, com o método do seu tipo de dado) e combinado por meta-análise em %d tecidos. Resultado principal: %d gene(s) replicado(s) em 2 ou mais estudos com FDR < 0,05 e %d via(s) Hallmark com FDR < 0,05, somando os tecidos. Com 3 a 34 doadoras por grupo por tecido, só efeitos grandes são detectáveis (seção 5); resultados negativos significam 'sem efeito grande', não 'sem efeito'. Resultados de um só estudo são apresentados como descoberta (%d gene(s) com FDR < 0,05 medidos em 1 só estudo de tecidos com 2+ estudos: pistas, não replicações).",
                                     nrow(info), nrow(cont), n_rep, n_vias, sum(cont$desc_fdr05[cont$estudos >= 2]))),
    list(tipo = "h2", texto = "1. Objetivo da etapa"),
    list(tipo = "p", texto = "Responder, por tecido, quais genes e vias têm expressão diferente entre mulheres de 40–60 anos com DM2 e sem diabetes, de forma consistente entre estudos, com o grau de confiança de cada resultado."),
    list(tipo = "h2", texto = "2. Pacotes usados"),
    list(tipo = "tabela", df = pac),
    list(tipo = "h2", texto = "3. Método"),
    list(tipo = "b", itens = c(
      "Sem matriz única: cada estudo é analisado sozinho; combinam-se os tamanhos de efeito (g de Hedges), comparáveis entre arrays e RNA-seq.",
      "Modelo por estudo (E1, alterada pelo usuário em 07/10/2026): só as mulheres de 40–60, DM2 × sem diabetes. O modelo anterior, com todas as amostras em grupos de médias (as outras amostras só ajudavam a estimar a variância), virou sensibilidade.",
      "Método por tipo de dado: voom (contagens brutas), limma-trend (matriz do autor), limma (arrays).",
      "g de Hedges = J × logFC / desvio-padrão moderado do limma (J = correção para amostras pequenas com os graus de liberdade moderados df); variância = (J × erro padrão do logFC no limma / desvio-padrão)² + g²/(2 df): o 1º termo vem do próprio ajuste do limma (inclui pesos do voom e covariáveis como lote; sem eles, é J²(1/n1 + 1/n2)) e o 2º é a incerteza do desvio-padrão (E2; revisão de 08/10/2026: antes 1/n1 + 1/n2 + g²/(2(n1 + n2)), e o IC não correspondia ao p do limma).",
      "Meta-análise de efeitos aleatórios por tecido: Hartung-Knapp modificado (principal desde 07/10/2026) e DerSimonian-Laird como sensibilidade, com I² (E3). Testes combinados ao lado: Stouffer, rOP (efeito em pelo menos 2 estudos, calibrado para a nula composta em 08/10/2026) e Cochran Q. Nenhum gene é descartado: 1 estudo = descoberta, 2+ = replicado (E4). FDR por tecido e por nível; < 0,05 significativo, < 0,10 sugestivo (E5).",
      "Vias: escore por amostra nos 50 conjuntos Hallmark (média dos z dos genes, descontada a média de todos os genes da amostra — escore competitivo, decisão do usuário de 08/10/2026; mínimo de 10 genes medidos), mesmo modelo e mesma meta-análise (E7).",
      "Sensibilidades: deixar um estudo de fora, sem matrizes do autor, modelo com todas as amostras (variância estimada também com homens e outras idades), ajuste por IMC (estudos com IMC em ≥ 80% das amostras), ajuste por escores de composição celular (E8, E9), sem ajuste de lote e com os estudos de lote confundido.",
      "Correção de método (07/10/2026): o g passou a ser padronizado pelo desvio-padrão dos grupos sem covariáveis, e covariáveis (lote, IMC, composição) só entram com pelo menos 6 graus de liberdade residuais. Antes, no modelo só com mulheres de 40–60, o ajuste de 5 lotes em 11 mulheres do GSE25462 produzia 113 genes e a via de fosforilação oxidativa 'significativos' no músculo por sobreajuste.",
      "Revisão de metodologia (07/10/2026, docs/revisao_metodologia_2026-10-07.md): meta-análise por Hartung-Knapp modificado (com 2 a 4 estudos o DerSimonian-Laird dá intervalos estreitos demais; DL ficou como sensibilidade); balanço de idade e IMC por estudo; sensibilidades com idade como covariável, sem estudos com diferença de idade > 5 anos e só com estudos com pelo menos 3 × 3; checagens de sanidade por estudo (fração de p < 0,05 e λ); sobreposição de doadoras por perfil; vias de interesse declaradas; GSE124742 (patch-seq) avaliado e mantido fora por não ter doador nem idade por célula no GEO.",
      "Escopo (decisão do usuário, 07/10/2026): só a comparação DM2 × sem diabetes nas mulheres de 40–60; homens e mulheres de outras idades nunca entram na comparação, só ajudam a estimar a variância no modelo principal. Não há análise de especificidade (comparação com homens ou outras idades).",
      "Depois da 1ª execução (decisões de 07/10/2026): só genes codificantes de proteína; lote (data de leitura do array) como covariável quando há 2 ou mais lotes e o modelo permite; estudos com lote confundido com o grupo só na sensibilidade; GSE23561 fora da análise do genoma inteiro.")),
    list(tipo = "p", texto = sprintf("Só na sensibilidade (lote confundido com o grupo): %s. Fora da análise do genoma inteiro: %s.",
                                     if (!is.null(info_conf) && nrow(info_conf)) paste(sprintf("%s (%s)", info_conf$gse, info_conf$tecido), collapse = "; ") else "nenhum",
                                     if (length(fora_genoma)) paste(sprintf("%s (%s)", fora_genoma, unlist(MC$excluir_genoma)), collapse = "; ") else "nenhum")),
    list(tipo = "h2", texto = "4. Estudos no modelo"),
    list(tipo = "tabela", df = data.frame(GSE = info$gse, Tecido = info$tecido, `Método` = info$metodo, Doadores = info$doadores, `F 40–60 DM2/ND` = sprintf("%d/%d", info$F40a60_T2D, info$F40a60_ND),
                                          Genes = info$genes, `Genes p < 0,05` = info$genes_p05, `IMC` = ifelse(info$imc, "sim", "não"), `Lote ajustado` = ifelse(info$lote_ajustado, "sim", "não"), check.names = FALSE)),
    list(tipo = "h2", texto = "4b. Balanço de idade e IMC e sanidade de cada estudo"),
    list(tipo = "tabela", df = data.frame(GSE = info$gse, Tecido = info$tecido, `Idade DM2 / ND` = sprintf("%s / %s", info$idade_T2D, info$idade_ND),
                                          `Diferença` = ifelse(is.na(info$dif_idade), "-", sprintf("%+.1f", info$dif_idade)),
                                          `IMC DM2 / ND` = ifelse(is.na(info$imc_T2D), "-", sprintf("%s / %s", info$imc_T2D, info$imc_ND)),
                                          `Genes p < 0,05` = sprintf("%.0f%%", 100 * info$frac_p05), `λ` = info$lambda, Alerta = info$alerta, check.names = FALSE),
         nota = "Mulheres de 40–60. Diferença de idade > 5 anos mistura DM2 e estado menopausal; IMC maior no DM2 mistura DM2 e obesidade. Sem efeito, espera-se ~5% dos genes com p < 0,05 e λ perto de 1."),
    list(tipo = "h2", texto = "5. Poder"),
    list(tipo = "tabela", df = data.frame(Tecido = poder$tecido, Estudos = poder$estudos, `DM2/ND` = sprintf("%d/%d", poder$T2D, poder$ND), `g mínimo (p < 0,05)` = f2(poder$mde_nominal),
                                          `g mínimo (Bonferroni no genoma)` = f2(poder$mde_genoma), `α do genoma` = poder$alfa_genoma, check.names = FALSE),
         nota = "Estimativa de PLANEJAMENTO: efeito mínimo detectável com 80% de poder, somando as doadoras dos estudos do tecido como se fosse um só estudo (efeito fixo). O α do genoma é 0,05 dividido pelo nº mediano de genes dos estudos do tecido. Não é o poder efetivo da análise (Hartung-Knapp com poucos estudos e FDR), que é menor; a heterogeneidade entre estudos aumenta esses valores."),
    list(tipo = "h2", texto = "6. Resultado por tecido"),
    list(tipo = "tabela", df = data.frame(Tecido = cont$tecido, Estudos = cont$estudos, Genes = cont$genes, Replicados = cont$replicados, `Descoberta` = cont$descoberta,
                                          `Replicados FDR < 0,05` = cont$rep_fdr05, `Replicados FDR < 0,10` = cont$rep_fdr10, `Descoberta FDR < 0,05` = cont$desc_fdr05,
                                          `Vias FDR < 0,05` = cont$vias_fdr05, `Vias FDR < 0,10` = cont$vias_fdr10, check.names = FALSE)),
    list(tipo = "img", arq = "docs/figuras/meta_vulcao.png", largura = 6.5, altura = 3.25, nota = "Gráfico de vulcão por tecido: efeito (g) × −log10(p); cheio = replicado, vazio = descoberta; vermelho FDR < 0,05, laranja FDR < 0,10."))
  if (!is.null(top_vias) && nrow(top_vias)) blocos <- c(blocos, list(list(tipo = "h2", texto = "7. Vias com FDR < 0,10"),
    list(tipo = "tabela", df = data.frame(Tecido = top_vias$tecido, Via = sub("^HALLMARK_", "", top_vias$id), `Nível` = top_vias$nivel, Estudos = top_vias$estudos,
                                          `g (IC 95%)` = sprintf("%s (%s a %s)", f2(top_vias$g), f2(top_vias$ic_inf), f2(top_vias$ic_sup)),
                                          `I²` = ifelse(is.na(top_vias$I2), "-", sprintf("%.0f%%", 100 * top_vias$I2)), `Mesmo sentido` = sprintf("%d/%d", top_vias$mesmo_sentido, top_vias$estudos), FDR = fp(top_vias$fdr), check.names = FALSE))))
  else blocos <- c(blocos, list(list(tipo = "h2", texto = "7. Vias"), list(tipo = "p", texto = "Nenhuma via com FDR < 0,10.")))
  if (!is.null(loo_vias) && nrow(loo_vias)) blocos <- c(blocos, list(
    list(tipo = "tabela", df = data.frame(Tecido = loo_vias$tecido, Via = sub("^HALLMARK_", "", loo_vias$via), `Sem o estudo` = loo_vias$sem, g = f2(loo_vias$g), FDR = fp(loo_vias$fdr),
                                          `g / FDR na principal` = sprintf("%s / %s", f2(loo_vias$g_principal), fp(loo_vias$fdr_principal)), check.names = FALSE),
         nota = "Robustez das vias com FDR < 0,10: a meta-análise é refeita tirando um estudo por vez. Se o FDR sobe muito ao tirar um estudo, o achado depende dele e deve ser lido com cautela.")))
  blocos <- c(blocos, list(list(tipo = "img", arq = "docs/figuras/meta_vias.png", largura = 4.5, altura = 7.4, nota = "Efeito do DM2 (g) em cada via Hallmark e tecido; vermelho = maior no DM2, azul = menor; ** FDR < 0,05, * FDR < 0,10.")))
  if (!is.null(top_genes) && nrow(top_genes)) blocos <- c(blocos, list(list(tipo = "h2", texto = "8. Genes com FDR < 0,10 (até 15 por tecido)"),
    list(tipo = "tabela", df = data.frame(Tecido = top_genes$tecido, Gene = top_genes$id, `Nível` = top_genes$nivel, Estudos = top_genes$estudos,
                                          `g (IC 95%)` = sprintf("%s (%s a %s)", f2(top_genes$g), f2(top_genes$ic_inf), f2(top_genes$ic_sup)),
                                          `Mesmo sentido` = sprintf("%d/%d", top_genes$mesmo_sentido, top_genes$estudos), FDR = fp(top_genes$fdr), check.names = FALSE))))
  else blocos <- c(blocos, list(list(tipo = "h2", texto = "8. Genes"), list(tipo = "p", texto = "Nenhum gene com FDR < 0,10.")))
  if (!is.null(vi) && nrow(vi)) blocos <- c(blocos, list(list(tipo = "h2", texto = "8b. Vias de interesse em todas as análises"),
    list(tipo = "p", texto = "Escolhidas depois de ver os dados da etapa 05 (as tendências mais consistentes): são hipóteses geradas aqui, a confirmar em dados independentes."),
    list(tipo = "tabela", df = data.frame(Tecido = vi$tecido, Via = sub("^HALLMARK_", "", vi$id), `Análise` = vi$analise, Estudos = vi$estudos,
                                          `g (IC 95%)` = sprintf("%s (%s a %s)", f2(vi$g), f2(vi$ic_inf), f2(vi$ic_sup)), FDR = fp(vi$fdr), check.names = FALSE))))
  if (!is.null(sob)) blocos <- c(blocos, list(list(tipo = "h2", texto = "8c. Possível sobreposição de doadoras entre estudos"),
    if (nrow(sob)) list(tipo = "tabela", df = data.frame(Tecido = sob$tecido, GSE = sob$gse, Doadora = sob$individuo, Status = sob$status, Idade = sob$idade, IMC = sob$bmi, check.names = FALSE),
                        nota = "Doadoras de estudos diferentes do mesmo tecido com status, idade e IMC idênticos; perfil igual não prova que é a mesma pessoa.")
    else list(tipo = "p", texto = "Nenhuma doadora com perfil idêntico entre estudos do mesmo tecido.")))
  blocos <- c(blocos, list(list(tipo = "h2", texto = "9. Sensibilidades"),
    list(tipo = "tabela", df = data.frame(Tecido = sens$tecido, `Análise` = sens$analise, Estudos = sens$estudos, `Genes replicados FDR < 0,05` = sens$genes_replicados_fdr05,
                                          `Genes principais mantidos` = sens$genes_principais_mantidos, `Correlação dos g` = ifelse(is.na(sens$cor_g_genes), "-", f2(sens$cor_g_genes)),
                                          `Vias FDR < 0,05` = sens$vias_fdr05, `Vias principais mantidas` = sens$vias_principais_mantidas, check.names = FALSE),
         nota = "'Correlação dos g' compara os efeitos dos genes replicados com a análise principal (1 = idênticos). Resultado que some ao tirar um estudo ou com IMC/composição deve ser lido com cautela.")))
  if (!is.null(nano)) blocos <- c(blocos, list(list(tipo = "h2", texto = "10. NanoString (GSE316126) x sangue"),
    list(tipo = "p", texto = sprintf("%d genes do painel, %d em comum com a meta-análise do sangue; correlação dos efeitos = %s; mesmo sentido em %.0f%% dos genes; %d genes com FDR < 0,05 no próprio painel.",
                                     nano$genes_painel, nano$em_comum, f2(nano$cor_g), 100 * nano$mesmo_sentido, nano$genes_fdr05_painel))))
  if (!is.null(multi) && nrow(multi)) blocos <- c(blocos, list(list(tipo = "h2", texto = "11. Genes com FDR < 0,10 em mais de um tecido"),
    list(tipo = "tabela", df = data.frame(Gene = multi$id, Tecido = multi$tecido, `Nível` = multi$nivel, g = f2(multi$g), FDR = fp(multi$fdr), check.names = FALSE))))
  blocos <- c(blocos, list(
    list(tipo = "h2", texto = "12. Decisões validadas pelo usuário"),
    list(tipo = "tabela", df = data.frame(Data = "07/10/2026", `Nº` = sprintf("E%d", 1:13),
      `Decisão` = c("Modelo só com as mulheres de 40–60 (alterada em 07/10/2026; o modelo com todas as amostras virou sensibilidade). Motivo: escopo só no range 40–60; com todas as amostras a variância dos homens e de outras idades tornava a análise mais conservadora (na fosforilação oxidativa do músculo, FDR 0,99 x 0,017).", "g de Hedges (e logFC).", "Efeitos aleatórios (DerSimonian-Laird), I².",
                    "Sem cobertura mínima: 1 estudo = descoberta, 2+ = replicado (ajustada pelo usuário).", "FDR < 0,05 por tecido e nível; < 0,10 sugestivo.", "Fígado: tudo como descoberta.",
                    "50 vias Hallmark, escore por amostra.", "Sem covariáveis na principal; IMC e composição em sensibilidade.", "Deixar um de fora, sem matriz do autor, IMC, composição, modelo com todas as amostras; 'todas as mulheres' retirada (só o range 40–60, pedido do usuário).",
                    "Estudos com lote confundido com o grupo (GSE189005, GSE21340) só na sensibilidade: na 1ª execução, 77 'descobertas' do sangue eram RNAs pequenos do GSE189005, cujos controles e DM2 foram lidos em datas diferentes.",
                    "Lote (data de leitura) como covariável quando há 2+ lotes.", "Só genes codificantes de proteína.", "GSE23561 fora do genoma inteiro (só 773 genes estimáveis)."),
      check.names = FALSE)),
    list(tipo = "h2", texto = "13. Arquivos"),
    list(tipo = "b", itens = c("Código: R/05_meta.R; execução: run_05_meta.R; configuração: config/meta.yaml; intenção: docs/intencao_05_meta.docx.",
                               "Saídas: output/05_meta/estudos/<GSE>/efeitos_genes.csv e efeitos_vias.csv; output/05_meta/<tecido>/meta_genes.csv e meta_vias.csv; estudos.csv, resumo_tecidos.csv, poder.csv, sensibilidades.csv, vias_por_tecido.csv, genes_fdr10_por_tecido.csv, nanostring_sangue.csv.",
                               "Figuras: docs/figuras/meta_vulcao.png e meta_vias.png. Validação: docs/validacao_05_meta.md."))))
  if (!is.null(ieg_res)) {
    ib <- list(list(tipo = "h2", texto = "14. Genes de resposta imediata (marcados para discussão)"),
      list(tipo = "p", texto = "Genes que sobem em minutos com isquemia ou manuseio do tecido antes do congelamento (FOS, JUN, EGR1, BTG2, KLF9, PPP1R15A e afins; lista em config/meta.yaml). Ficam na análise e são apenas marcados (coluna resposta_imediata) para a discussão posterior: se dominam os achados de um tecido, o sinal pode ser de coleta, não de DM2 (decisão do usuário, 08/10/2026)."),
      list(tipo = "tabela", df = data.frame(Tecido = ieg_res$tecido, Medidos = ieg_res$medidos, `p < 0,05` = ieg_res$p05, `Maiores no DM2` = ieg_res$maiores_dm2,
                                            `Fração p < 0,05 (resposta imediata)` = ieg_res$frac_p05_ieg, `Fração p < 0,05 (demais genes)` = ieg_res$frac_p05_demais, check.names = FALSE)))
    if (!is.null(ieg)) ib <- c(ib, list(list(tipo = "tabela", df = data.frame(Tecido = ieg$tecido, Gene = ieg$gene, Estudos = ieg$estudos, g = ieg$g, p = ieg$p,
                                                                              `Mesmo sentido` = sprintf("%d/%d", ieg$mesmo_sentido, ieg$estudos), check.names = FALSE))))
    blocos <- c(blocos, ib)
  }
  gravar_docx(blocos, arq, "Etapa 05 — Efeito do DM2 por estudo e meta-análise por tecido", etapa = "05")
}

# ---------------- decisões comuns das etapas 06-08 ----------------
decisoes_redes <- function() data.frame(Data = c(rep("07/10/2026", 6), rep("08/10/2026", 5)),
  `Decisão` = c("Construir os módulos aqui com todas as amostras de cada tecido; testar só nas mulheres de 40–60.",
                "Se nenhum módulo passar do FDR, seguir em modo exploratório (opção B).",
                "Enriquecimento com Hallmark, Reactome e GO (processos biológicos).",
                "Conectividade entre tecidos por STRING e OmniPath.",
                "Retirar o efeito do lote (data de leitura) antes de construir a rede (R8).",
                "Parâmetros R1–R7 da intenção (≥ 15 doadores para construir; bicor, rede com sinal; módulos ≥ 30 genes; Zsummary ≥ 2; kME ≥ 0,7; STRING ≥ 700).",
                "Rede de consenso e preservação em pelo menos 2 estudos (não em todos); testes combinados (Stouffer, rOP, Cochran Q) e influência de cada estudo.",
                "Tecidos com 1 estudo (fígado) seguem, com o rótulo 'exploratório (1 estudo)'.",
                "Genes-chave com kME ≥ 0,7 em pelo menos 2 estudos de construção (antes: em todos).",
                "GSE156993 (sangue) fora do teste principal (contraste DM2 + dislipidemia + periodontite x saudáveis); continua ajudando a construir a rede de sangue.",
                "Manter 3 amostras do GSE198922 (adiposo: 11_PRE, 4_PRE, 46_PRE) com possível contaminação por músculo (marcadores de músculo no topo)."),
  Motivo = c("A WGCNA precisa de ≥ 15–20 amostras; só com mulheres de 40–60 a maioria dos estudos tem 4 a 11. A rede não usa o status de DM2.",
             "Com o poder atual, era provável que nenhum módulo passasse do FDR; os resultados exploratórios ficam rotulados como hipóteses.",
             "Coleções complementares: resumida (Hallmark), bioquímica curada (Reactome) e ampla (GO).",
             "Cada tecido vem de pessoas diferentes; a ligação entre tecidos só pode vir de conhecimento prévio.",
             "Diferenças técnicas entre datas de leitura podem formar módulos falsos.",
             "Padrões da WGCNA e da literatura; intenção aprovada pelo usuário.",
             "Dados humanos com N pequeno e muita confusão: um efeito real pode não aparecer em todos os estudos (pedido do usuário).",
             "Não descartar o único estudo do tecido; a evidência fica marcada como de 1 estudo (pedido do usuário).",
             "Coerência com a rede e a preservação em ≥ 2 estudos (decisão do usuário, revisão de 08/10/2026).",
             "Os casos têm comorbidades que os controles não têm; a rede não usa o status de DM2, então o estudo serve para construí-la (decisão do usuário, revisão de 08/10/2026).",
             "Não perder N (decisão do usuário). Nenhuma das 3 está no modelo principal; entram só na construção da rede e na sensibilidade com todas as amostras. Ver docs/sanidade.docx."), check.names = FALSE)

# ---------------- ETAPA 06 ----------------
documentar_etapa_06 <- function(RC, resumo, mods, chv, arq = "docs/etapa_06_redes.docx") {
  fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
  mods$selecao[is.na(mods$selecao)] <- ""; nsel <- sum(nzchar(mods$selecao))
  blocos <- list(
    list(tipo = "p", texto = sprintf("Gerado em %s a partir de config/redes.yaml e output/06_redes/.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
    list(tipo = "h2", texto = "Resumo"),
    list(tipo = "p", texto = sprintf("Foram construídas redes de coexpressão (WGCNA) em %d tecidos, com todas as amostras dos estudos com pelo menos %d doadores, resultando em %d módulos, dos quais %d se repetem em todos os estudos de construção. O perfil de cada módulo foi comparado entre DM2 e sem diabetes só nas mulheres de 40–60, com o mesmo modelo e a mesma meta-análise da etapa 05. %s",
                                     nrow(resumo), RC$rede$min_doadores, nrow(mods), sum(mods$preservado %in% TRUE),
                                     if (nsel) sprintf("%d módulo(s) foram selecionados (%d significativos, %d sugestivos, %d exploratórios), com %d genes-chave.", nsel, sum(mods$selecao == "significativo"), sum(mods$selecao == "sugestivo"), sum(startsWith(mods$selecao, "exploratório")), if (is.null(chv)) 0L else nrow(chv))
                                     else "Nenhum módulo passou do FDR nem do critério exploratório; as direções observadas estão na tabela dos módulos.")),
    list(tipo = "h2", texto = "1. Objetivo da etapa"),
    list(tipo = "p", texto = "Encontrar grupos de genes que andam juntos em cada tecido (módulos) e verificar se algum deles muda entre mulheres de 40–60 com e sem DM2. Testar dezenas de módulos em vez de ~18 mil genes reduz o número de testes, e os genes centrais de um módulo associado ao DM2 são candidatos para as etapas seguintes."),
    list(tipo = "h2", texto = "2. Pacotes usados"),
    list(tipo = "tabela", df = tabela_pacotes(list(WGCNA = "pickSoftThreshold, blockwiseConsensusModules/blockwiseModules, moduleEigengenes e modulePreservation.",
                                                  limma = "removeBatchEffect (retirar o lote antes da rede) e o teste dos eigengenes (mesmo modelo da etapa 05).",
                                                  yaml = "Leitura de config/redes.yaml.", officer = "Este documento."))),
    list(tipo = "h2", texto = "3. Método"),
    list(tipo = "b", itens = c(
      sprintf("Construção: rede de consenso por tecido com todas as amostras aptas dos estudos com ≥ %d doadores; genes codificantes comuns, os %d mais variáveis; correlação bicor; rede com sinal; potência pela forma livre de escala (R² ≥ %.2f em todos os estudos) ou, se não atingida, a recomendação da WGCNA pelo número de amostras; módulos ≥ %d genes; fusão de módulos com eigengenes de correlação ≥ %.2f.",
              RC$rede$min_doadores, RC$rede$max_genes, RC$rede$r2_min, RC$rede$min_modulo, 1 - RC$rede$merge_corte),
      "Lote: efeito da data de leitura retirado da expressão antes da rede (preservando status e sexo), nos estudos com data conhecida (R8).",
      sprintf("Preservação: Zsummary de cada módulo no estudo de referência (o maior) contra os demais estudos de construção; segue o módulo com Zsummary ≥ %s em todos.", RC$preservacao$zsummary_min),
      "Teste: eigengene do módulo em cada estudo (inclusive os pequenos), DM2 × sem diabetes só nas mulheres de 40–60, g de Hedges, meta-análise de Hartung-Knapp, FDR entre os módulos do tecido.",
      sprintf("Seleção (definida antes): FDR < %s significativo; FDR < %s sugestivo; se nenhum no tecido, exploratório = p < %s e mesmo sentido em todos os estudos.", RC$teste$fdr, RC$teste$fdr_sugestivo, RC$teste$p_exploratorio),
      sprintf("Genes-chave: kME ≥ %s em pelo menos 2 estudos de construção (nos dois, se forem 2; decisão do usuário de 08/10/2026, coerente com o consenso em ≥ 2 estudos) e efeito do DM2 (etapa 05) no mesmo sentido do módulo em todos os estudos (em ≥ 2 para módulos 'exploratório (≥ 2 estudos)').", RC$genes_chave$kme_min))),
    list(tipo = "h2", texto = "4. Redes por tecido"),
    list(tipo = "tabela", df = data.frame(Tecido = resumo$tecido, `Estudos (rede)` = resumo$estudos_construcao, Genes = resumo$genes_rede, `Potência` = resumo$potencia,
                                          `Módulos` = resumo$modulos, Preservados = resumo$preservados, Selecionados = resumo$significativos + resumo$sugestivos + resumo$exploratorios, `Genes-chave` = resumo$genes_chave, check.names = FALSE),
         nota = "Critério da potência por tecido em output/06_redes/resumo_tecidos.csv."),
    list(tipo = "h2", texto = "5. Módulos e efeito do DM2"),
    list(tipo = "tabela", df = data.frame(Tecido = mods$tecido, `Módulo` = mods$id, Genes = mods$genes, `g (IC 95%)` = sprintf("%.2f (%.2f a %.2f)", mods$g, mods$ic_inf, mods$ic_sup),
                                          p = fp(mods$p), FDR = fp(mods$fdr), `Mesmo sentido` = sprintf("%d/%d", mods$mesmo_sentido, mods$estudos), `Seleção` = ifelse(nzchar(mods$selecao), mods$selecao, "-"),
                                          `Genes centrais` = mods$genes_centrais, check.names = FALSE)),
    list(tipo = "img", arq = "docs/figuras/redes_modulos.png", largura = 6.5, altura = 2.4 * ceiling(nrow(resumo) / 3), nota = "Efeito do DM2 (g, IC 95%) em cada módulo; cinza = não selecionado."))
  if (!is.null(chv) && nrow(chv)) blocos <- c(blocos, list(list(tipo = "h2", texto = "6. Genes-chave"),
    list(tipo = "tabela", df = data.frame(Tecido = chv$tecido, `Módulo` = chv$modulo, `Seleção` = chv$selecao, Gene = chv$gene, `kME (2º maior)` = chv$kME_2 %||% chv$kME_min, `kME mín.` = chv$kME_min, check.names = FALSE))))
  blocos <- c(blocos, list(list(tipo = "h2", texto = "7. Decisões validadas pelo usuário"), list(tipo = "tabela", df = decisoes_redes()),
    list(tipo = "h2", texto = "8. Arquivos"),
    list(tipo = "b", itens = c("Código: R/06_redes.R; execução: run_06_redes.R; configuração: config/redes.yaml; intenção: docs/intencao_06_redes.docx.",
                               "Saídas: output/06_redes/<tecido>/{modulos_genes.csv, meta_modulos.csv, efeitos_modulos_estudos.csv, preservacao.csv, genes_chave.csv, resumo.csv}; resumo_tecidos.csv; modulos_todos.csv.",
                               "Figura: docs/figuras/redes_modulos.png. Validação: docs/validacao_06_redes.md."))))
  gravar_docx(blocos, arq, "Etapa 06 — Redes de coexpressão (WGCNA)", etapa = "06")
}

# ---------------- ETAPA 07 ----------------
documentar_etapa_07 <- function(RC, conj, res, top, mods, conv, arq = "docs/etapa_07_enriquecimento.docx") {
  fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
  E <- RC$enriquecimento
  blocos <- list(
    list(tipo = "p", texto = sprintf("Gerado em %s a partir de config/redes.yaml e output/07_enriquecimento/.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
    list(tipo = "h2", texto = "Resumo"),
    list(tipo = "p", texto = sprintf("Foram testadas %s em cada tecido, só nas mulheres de 40–60: escore por amostra em cada via, com o mesmo modelo e a mesma meta-análise (Hartung-Knapp) da etapa 05. Somando os tecidos: %d vias com FDR < 0,05, %d com FDR < 0,10 e %d exploratórias (p < 0,05 e todos os estudos no mesmo sentido). A GSEA pré-ordenada daria %d vias com FDR < 0,05, mas ela ignora a correlação entre genes e ficou inflada; serve aqui só para o sentido e para os genes que puxam cada via. Os módulos da etapa 06 foram descritos pelas vias que concentram (sobre-representação). Vias convergentes (módulo selecionado e via do tecido no mesmo sentido): %d.",
                                     paste(sprintf("%d conjuntos %s", lengths(conj), names(conj)), collapse = ", "), sum(res$fdr05), sum(res$fdr25), sum(res$explor), sum(res$gsea_inflada), nrow(conv))),
    list(tipo = "h2", texto = "1. Objetivo da etapa"),
    list(tipo = "p", texto = "Saber quais vias biológicas mudam com o DM2 nas mulheres de 40–60 (GSEA, com todos os genes, independente dos módulos) e o que cada módulo representa (sobre-representação), destacando as vias que aparecem nos dois caminhos."),
    list(tipo = "h2", texto = "2. Pacotes usados"),
    list(tipo = "tabela", df = tabela_pacotes(list(fgsea = "GSEA pré-ordenada (algoritmo multinível, p-valores precisos).", clusterProfiler = "Sobre-representação (enricher) dos genes de cada módulo.",
                                                  msigdbr = "Coleções Hallmark, Reactome e GO (processos biológicos).", dplyr = "Junção e resumo das tabelas.", officer = "Este documento."))),
    list(tipo = "h2", texto = "3. Método"),
    list(tipo = "b", itens = c("Calibração empírica (revisão de 10/10/2026): o p de cada via é comparado com 2.000 conjuntos de genes sorteados, de tamanho parecido, que passam pelo mesmo escore, modelo e meta-análise; o p final é o MAIOR entre o paramétrico e o empírico (a calibração só corrige inflação: sorteados não têm a coexpressão das vias reais e, onde o teste já é conservador, deixariam o resultado liberal demais), e o FDR é calculado sobre ele. Motivo: no GSE130991 (fígado) 18% dos conjuntos sorteados davam p < 0,05 pelo teste paramétrico. Os p paramétricos ficam nas colunas p_parametrico e fdr_parametrico.", "Teste das vias (correção de 07/10/2026): escore por amostra (média dos z dos genes, descontada a média de todos os genes da amostra — escore competitivo, decisão do usuário de 08/10/2026; mínimo de 10 genes medidos) em cada via, DM2 × sem diabetes só nas mulheres de 40–60, g de Hedges, meta-análise de Hartung-Knapp por tecido, FDR dentro de cada coleção. Significativo FDR < 0,05; sugestivo < 0,10; exploratório p < 0,05 e todos os estudos no mesmo sentido, com pelo menos 2 estudos (com 1 estudo, 'todos no mesmo sentido' é trivial: no fígado, 777 vias passavam; lá só entram vias com FDR < 0,10). Em tecido com 2+ estudos, via medida em 1 só estudo não é selecionada.",
                               sprintf("GSEA pré-ordenada (fgsea) pelo g de cada gene, por estudo e por tecido, conjuntos de %d a %d genes: usada só para o sentido (NES) e para os genes que puxam a via (leading edge). A 1ª execução usou o FDR dela e deu milhares de vias significativas, inclusive em estudos com 2 × 6 mulheres: a GSEA pré-ordenada trata genes correlacionados como independentes.", E$tamanho_min, E$tamanho_max),
                               sprintf("Sobre-representação: genes de cada módulo preservado contra o universo da rede do tecido; FDR < %s.", E$fdr_ora),
                               "Convergência: via com sobre-representação num módulo selecionado e via selecionada no tecido (escore) no mesmo sentido do módulo.")),
    list(tipo = "h2", texto = "4. GSEA por tecido"),
    list(tipo = "tabela", df = data.frame(Tecido = res$tecido, `Coleção` = res$colecao, `Vias testadas` = res$vias, `FDR < 0,05` = res$fdr05, `FDR < 0,10` = res$fdr25, `Exploratórias` = res$explor,
                                          `p < 0,05 observadas` = res$p05, `p < 0,05 esperadas ao acaso` = res$acaso,
                                          `GSEA pré-ordenada FDR < 0,05 (inflada)` = res$gsea_inflada, check.names = FALSE),
         nota = "Esperadas ao acaso = 5% das vias testadas: listas exploratórias desse tamanho não são evidência por si; valem como hipóteses quando convergem com módulos e genes (revisão de 08/10/2026)."))
  if (nrow(top)) blocos <- c(blocos, list(list(tipo = "tabela", df = data.frame(Tecido = top$tecido, `Coleção` = top$colecao, Via = top$via, `g (IC 95%)` = sprintf("%.2f (%.2f a %.2f)", top$g, top$ic_inf, top$ic_sup),
                                                                               p = fp(top$p), FDR = fp(top$fdr), `Nível` = top$nivel, `Mesmo sentido` = sprintf("%d/%d", top$mesmo_sentido, top$estudos), check.names = FALSE),
                                                nota = "Vias selecionadas pelo escore (até 8 por tecido e coleção). g > 0 = maior no DM2.")))
  blocos <- c(blocos, list(list(tipo = "img", arq = "docs/figuras/gsea_hallmark.png", largura = 4.5, altura = 7.4, nota = "Cor = efeito do DM2 pelo escore de via (g); quadro = p < 0,05; ** FDR < 0,05 e * FDR < 0,10; +/− = sinal do NES da GSEA. (Revisão de 09/10/2026: antes a cor era o NES, que nunca fica perto de 0 e deixava o mapa homogêneo.)"),
    list(tipo = "h2", texto = "5. O que cada módulo representa"),
    list(tipo = "tabela", df = data.frame(Tecido = mods$tecido, `Módulo` = mods$id, Genes = mods$genes, g = round(mods$g, 2), `Seleção` = ifelse(nzchar(mods$selecao), mods$selecao, "-"),
                                          Representa = ifelse(is.na(mods$rotulo), "-", mods$rotulo), check.names = FALSE)),
    list(tipo = "h2", texto = "6. Vias convergentes"),
    if (nrow(conv)) list(tipo = "tabela", df = data.frame(Tecido = conv$tecido, `Módulo` = conv$modulo, `Coleção` = conv$colecao, Via = conv$via, `g da via` = round(conv$g_via, 2), `Nível da via` = conv$nivel_via, check.names = FALSE))
    else list(tipo = "p", texto = "Nenhuma via convergente: não há módulo selecionado na etapa 06, ou as vias dos módulos selecionados não aparecem na GSEA do tecido no mesmo sentido."),
    list(tipo = "h2", texto = "7. Decisões validadas pelo usuário"), list(tipo = "tabela", df = decisoes_redes()),
    list(tipo = "h2", texto = "8. Arquivos"),
    list(tipo = "b", itens = c("Código: R/07_enriquecimento.R; execução: run_07_enriquecimento.R; configuração: config/redes.yaml.",
                               "Saídas: output/07_enriquecimento/{gsea_estudos.csv, gsea_tecidos.csv, ora_modulos.csv, modulos_rotulados.csv, convergencia.csv}.",
                               "Figura: docs/figuras/gsea_hallmark.png. Validação: docs/validacao_07_enriquecimento.md."))))
  gravar_docx(blocos, arq, "Etapa 07 — Enriquecimento (GSEA e sobre-representação)", etapa = "07")
}

# ---------------- ETAPA 08 ----------------
documentar_etapa_08 <- function(RC, rt, painel, st_x, lr_x, progs = NULL, arq = "docs/etapa_08_painel.docx") {
  fp <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 2, decimal.mark = ","))
  blocos <- list(
    list(tipo = "p", texto = sprintf("Gerado em %s a partir de config/redes.yaml e output/08_painel/.", format(Sys.time(), "%d/%m/%Y %H:%M"))),
    list(tipo = "h2", texto = "Resumo"),
    list(tipo = "p", texto = sprintf("Os genes candidatos de cada tecido (genes-chave de módulos e genes que puxam as vias da GSEA) foram ligados entre tecidos por interações entre proteínas (STRING, %d ligações) e por pares ligante–receptor (OmniPath, %d pares). Cada gene recebeu pontos por 5 critérios definidos antes; %d gene × tecido atingiram pelo menos %d pontos e formam o painel. Como nenhum módulo ou via passou do FDR com o poder atual, o painel é EXPLORATÓRIO: uma lista de hipóteses para validação, não um resultado confirmado.",
                                     nrow(st_x), nrow(lr_x), nrow(painel), RC$painel$pontos_min)),
    list(tipo = "h2", texto = "1. Objetivo da etapa"),
    list(tipo = "p", texto = "Procurar ligações sistêmicas entre os genes alterados pelo DM2 em tecidos diferentes e reunir os genes com mais evidência num painel de genes de interesse."),
    list(tipo = "h2", texto = "2. Pacotes usados"),
    list(tipo = "tabela", df = tabela_pacotes(list(STRINGdb = sprintf("Interações entre proteínas (STRING v%s, confiança ≥ %d).", RC$conectividade$string_versao, RC$conectividade$string_score_min),
                                                  OmnipathR = "Pacote do OmniPath; os pares ligante–receptor (conjunto ligrecextra) foram baixados pela API web do OmniPath porque a função intercell_network falhou ao ler uma página interna (07/10/2026).",
                                                  igraph = "Figura da rede do painel.", dplyr = "Tabelas.", officer = "Este documento."))),
    list(tipo = "h2", texto = "3. Critérios do painel (1 ponto cada)"),
    list(tipo = "b", itens = c("Efeito replicado: 2 ou mais estudos do tecido, todos no mesmo sentido, e p < 0,05 na meta-análise (etapa 05).",
                               "Gene-chave de módulo selecionado (etapa 06).",
                               "Via forte ou convergente: no leading edge (GSEA, NES no mesmo sinal do escore) de via significativa ou sugestiva pelo escore no tecido, ou de via convergente com módulo (etapa 07). Vias só exploratórias geram candidatos, mas não dão este ponto (decisão do usuário, 08/10/2026).",
                               "Ligação com candidato de outro tecido que tenha 2 ou mais estudos (STRING ou ligante–receptor). Candidatos do fígado (1 estudo) não dão este ponto aos outros tecidos (08/10/2026).",
                               "Robusto a tirar um estudo por vez: o sentido do efeito combinado não muda e o p continua < 0,10 em cada retirada (só com 3 ou mais estudos; 08/10/2026).",
                               sprintf("Painel = pelo menos %d pontos.", RC$painel$pontos_min))),
    list(tipo = "h2", texto = "4. Candidatos por tecido"),
    list(tipo = "tabela", df = data.frame(Tecido = rt$tecido, Candidatos = rt$candidatos, Replicado = rt$replicado, `Gene-chave` = rt$gene_chave, Via = rt$via, `Ligação` = rt$ligacao,
                                          Robusto = rt$robusto, Painel = rt$painel, check.names = FALSE)),
    list(tipo = "h2", texto = "5. Painel de genes de interesse por programa (exploratório)"),
    list(tipo = "p", texto = "Os critérios de pontuação não são independentes: um gene de módulo selecionado ganha juntos os pontos de efeito consistente, gene-chave e via convergente, e proteínas de complexos (mitocôndria, interferon) têm muitas ligações no STRING. Por isso o painel é apresentado por PROGRAMA, isto é, o módulo selecionado de cada tecido, com os genes mais centrais (kME) em destaque. A lista completa vem a seguir como tabela suplementar (decisão do usuário, 08/10/2026)."),
    if (!is.null(progs) && nrow(progs)) list(tipo = "tabela", df = data.frame(Programa = progs$programa, `Vias do módulo` = progs$vias_do_modulo, `Seleção do módulo` = progs$selecao_modulo,
                                                                         `Genes no painel` = progs$genes_no_painel, `Maiores / menores no DM2` = sprintf("%d / %d", progs$maiores_dm2, progs$menores_dm2),
                                                                         `Destaques (mais centrais)` = progs$destaques, check.names = FALSE)) else list(tipo = "p", texto = "Nenhum programa."),
    list(tipo = "h2", texto = "5b. Lista completa do painel (tabela suplementar)"),
    if (nrow(painel)) list(tipo = "tabela", df = data.frame(Gene = painel$gene, Tecido = painel$tecido, Sentido = painel$sentido, g = round(painel$g, 2), p = fp(painel$p),
                                                            `Mesmo sentido` = sprintf("%d/%d", painel$mesmo_sentido, painel$estudos), Pontos = painel$pontos, `Evidência` = painel$evidencia, check.names = FALSE))
    else list(tipo = "p", texto = "Nenhum gene atingiu a pontuação mínima."))
  if (file.exists("docs/figuras/painel_rede.png")) blocos <- c(blocos, list(list(tipo = "img", arq = "docs/figuras/painel_rede.png", largura = 6.5, altura = 5.4,
    nota = "Genes do painel (maiores) e seus vizinhos; cor = tecido; cinza = ligação STRING; azul = ligante–receptor. Ligações por conhecimento prévio, não observadas na mesma pessoa.")))
  if (nrow(lr_x)) blocos <- c(blocos, list(list(tipo = "h2", texto = "6. Comunicação entre órgãos proposta (ligante–receptor)"),
    list(tipo = "tabela", df = data.frame(Ligante = lr_x$ligante, `Tecido do ligante` = lr_x$tecido_ligante, Receptor = lr_x$receptor, `Tecido do receptor` = lr_x$tecido_receptor, check.names = FALSE))))
  blocos <- c(blocos, list(list(tipo = "h2", texto = "7. Decisões validadas pelo usuário"), list(tipo = "tabela", df = decisoes_redes()),
    list(tipo = "h2", texto = "8. Arquivos"),
    list(tipo = "b", itens = c("Código: R/08_painel.R; execução: run_08_painel.R; configuração: config/redes.yaml.",
                               "Saídas: output/08_painel/{candidatos.csv, painel.csv, string_entre_tecidos.csv, ligante_receptor_entre_tecidos.csv}.",
                               "Figura: docs/figuras/painel_rede.png. Validação: docs/validacao_08_painel.md."))))
  gravar_docx(blocos, arq, "Etapa 08 — Conectividade entre tecidos e painel de genes", etapa = "08")
}
