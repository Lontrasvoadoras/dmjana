###############################################################################
#  00_utils.R - utilitários comuns do workflow_dm_menopausa
###############################################################################

`%||%` <- function(a, b) if (is.null(a) || !length(a)) b else a

# Lê um YAML da pasta config/
ler_config <- function(arq = "config/busca.yaml") yaml::read_yaml(arq)

# Pasta de saída (criada se não existir)
pasta <- function(...) { d <- file.path(...); dir.create(d, recursive = TRUE, showWarnings = FALSE); d }

# Registro de execução: tela + logs/workflow.log
log_msg <- function(fmt, ...) {
  txt <- sprintf("[%s] %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), sprintf(fmt, ...))
  message(txt)
  cat(txt, "\n", file = file.path(pasta("logs"), "workflow.log"), append = TRUE, sep = "")
  invisible(txt)
}

# CSV em UTF-8, sem nomes de linha; devolve o caminho
escrever_csv <- function(x, arq) {
  pasta(dirname(arq)); utils::write.csv(x, arq, row.names = FALSE, na = "", fileEncoding = "UTF-8"); arq
}

# Expressão regular de uma lista de termos, com limites de palavra e plural opcional
# ("PBMC" casa com "PBMCs"; "islet" com "islets"). Revisão de 06/10/2026: sem o plural, o título
# "Human PBMCs: ..." não era reconhecido como sangue.
# plural = FALSE: só a palavra exata (termos de espécie; auditoria de 06/10/2026: "rates" casava com "rat")
regex_termos <- function(termos, plural = TRUE) paste0("(^|[^A-Za-z0-9])(", paste(gsub("([.+*?^$(){}|\\[\\]\\\\])", "\\\\\\1", termos), collapse = "|"), ")",
                                                       if (plural) "(s|es)?" else "", "([^A-Za-z0-9]|$)")

# rbind que preenche com NA as colunas ausentes em algum pedaço (ex.: fígado, 1 estudo, sem colunas de preservação)
rbind_preenche <- function(lst) {
  lst <- Filter(function(x) !is.null(x) && NROW(x) > 0, lst); if (!length(lst)) return(NULL)
  cols <- unique(unlist(lapply(lst, names)))
  do.call(rbind, lapply(lst, function(x) { for (c0 in setdiff(cols, names(x))) x[[c0]] <- NA; x[, cols, drop = FALSE] }))
}
