#' Runs vocabulary checks on a dataset
#'
#' Check vocabularies in a data set against the ICES DATSU data
#' submission utility, the user must supply a dataset version and
#' record type.
#'
#' @param filename the filename of the file to check
#' @param datasetverID the dataset ID
#' @param recordType string name of the record type
#'
#' @return The list of vocabulary errors. Every line that failed is
#'         reported for each field.
#'
#' @examples
#' \donttest{
#' filename <- system.file("test_files/vms_test.csv", package = "icesDatsuQC")
#' vc <- runVocabChecks(filename, 145, "VE")
#' if (length(vc) > 0) {
#'   library(icesDatsu)
#'   data <-
#'     read.csv(
#'       filename,
#'       header = FALSE,
#'       col.names = getDataFieldsDescription(145, "VE")$fieldcode
#'   )
#'   # some invalid entries
#'   data[vc[[1]], names(vc)[1]]
#' }
#' }
#' @export
#' @importFrom sqldf sqldf
#' @importFrom utils read.csv
#' @importFrom icesDatsu getListQCChecks getDataFieldsDescription
#' @importFrom glue glue
#' @importFrom icesVocab getCodeList
runVocabChecks <- function(filename, datasetverID, recordType) {
  feilds <- getDataFieldsDescription(datasetverID, recordType)

  # check only vocab feilds
  vocabs <- feilds[!is.na(feilds$codeGroup), ]

  vocabList <-
    lapply(
      vocabs$codeGroup,
      function(x) getCodeList(x)$Key
    )
  names(vocabList) <- vocabs$fieldcode

  # prepare the data table
  data <- read.csv(filename, header = FALSE)
  names(data) <- feilds$fieldcode

  checks <-
    lapply(
      vocabs$fieldcode,
      function(x) {
        which(!data[[x]] %in% vocabList[[x]])
      }
    )
  names(checks) <- vocabs$fieldcode

  # report back
  fails <- which(sapply(checks, function(x) length(x) > 0))
  if (length(fails) > 0) {
    warning(glue("{length(fails)} checks failed"))

    checks[fails]
  } else {
    message("all checks passed")
    invisible(NULL)
  }
}
