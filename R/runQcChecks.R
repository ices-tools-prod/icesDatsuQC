#' Runs quality checks on a dataset
#'
#' Check a data set against the ICES DATSU data submission utility,
#' the user must supply a dataset version and record type.
#'
#' @param filename the filename of the file to check
#' @param datasetverID the dataset ID
#' @param recordType string name of the record type
#'
#' @return The list of check failures
#'
#' @examples
#' \dontrun{
#' filename <- system.file("test_files/vms_test.csv", package = "icesDatsuQC")
#' runQCChecks(filename, 145, "VE")
#' }
#' @export
#' @importFrom sqldf sqldf
#' @importFrom utils read.csv
#' @importFrom icesDatsu getListQCChecks getDataFieldsDescription
runQCChecks <- function(filename, datasetverID, recordType) {
  qc <- getListQCChecks(datasetverID, recordType)

  # some formatting and mods to T-SQL
  qc$sqlExpression <-
    gsub(
      "year[(]getdate[(][)][)]", format(Sys.time(), "%Y"),
      qc$sqlExpression, ignore.case = TRUE
    )
  qc$sqlExpression <-
    gsub(
      "len[(]", "length(",
      qc$sqlExpression, ignore.case = TRUE
    )
  # qc$sqlExpression <- gsub("isnull[(]", "ifnull(", qc$sqlExpression)

  # prepare the data table
  data <- read.csv(filename, header = FALSE)
  colnames <- getDataFieldsDescription(datasetverID, recordType)$fieldcode

  if (length(colnames) != ncol(data)) {
    stop("The number of columns in the data file does not match the number of fields in the dataset")
  }

  names(data) <- colnames
  data$Linenumber <- 1:nrow(data)
  assign(paste0("R", recordType), data)

  # try and run checks
  try_sqldf <- function(sql) {
    try(
      suppressWarnings(
        sqldf(glue("select * {sql}"))
      ),
      silent = TRUE
    )
  }

  checks <- lapply(qc$sqlExpression, try_sqldf)

  # report back
  errored <- which(sapply(checks, function(x) inherits(x, "try-error")))
  if (length(errored)) {
    warning(glue("{length(errored)} checks could not be run locally, you may still get errors on submission."))
  }

  fails <- which(sapply(checks, function(x) !inherits(x, "try-error") && nrow(x) > 0))
  if (length(fails) > 0) {
    warning(glue("{length(fails)} checks failed"))

    cbind(
      Linenumber = unlist(lapply(checks[fails], "[[", "Linenumber")),
      qc[rep(fails, sapply(checks[fails], nrow)), c("check_Description", "errorType")]
    )
  } else {
    message("all checks possible to run in R passed")

    invisible(NULL)
  }
}
