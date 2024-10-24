
![Project Status](https://www.repostatus.org/badges/latest/active.svg)
[![r-universe
name](https://ices-tools-prod.r-universe.dev/badges/:name)](https://ices-tools-prod.r-universe.dev)
[![version
number](https://ices-tools-prod.r-universe.dev/badges/icesDatsuQC)](https://ices-tools-prod.r-universe.dev/icesDatsuQC)
![branch version
number](https://img.shields.io/badge/branch_version-1.2.0-blue)
[![GitHub
release](https://img.shields.io/github/release/ices-tools-prod/icesDatsuQC.svg?maxAge=6000)]()
[![License](https://img.shields.io/badge/license-GPL%20(%3E%3D%202)-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)

CRAN status:
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/icesDatsuQC)](https://cran.r-project.org/package=icesDatsuQC)
![CRAN RStudio mirror
downloads](https://cranlogs.r-pkg.org/badges/icesDatsuQC) ![CRAN RStudio
mirror
downloads](https://cranlogs.r-pkg.org/badges/grand-total/icesDatsuQC)

[<img align="right" alt="ICES Logo" width="17%" height="17%" src="http://ices.dk/_layouts/15/1033/images/icesimg/iceslogo.png">](http://ices.dk)

### icesDatsuQC

Run quality checks on data sets using the same checks that are conducted
on the [ICES Data Submission Utility
(DATSU)](https://datsu.ices.dk/web/index.aspx).

icesDatsuQC is implemented as an [R](https://www.r-project.org) package
and is currently hosted on
[r-universe](https://ices-tools-prod.r-universe.dev) and available on
[CRAN](https://cran.r-project.org/package=icesDatsuQC).

### Installation

The stable version of icesDatsuQC can be installed from CRAN using the
`install.packages` command:

``` r
install.packages("icesDatsuQC", repos = "https://cloud.r-project.org")
```

or a potentially more recent, but less stable version installed from
r-universe:

``` r
install.packages("icesDatsuQC", repos = "https://ices-tools-prod.r-universe.dev")
```

### Usage

For a summary of the package:

``` r
library(icesDatsuQC)
?icesDatsuQC
```

### Examples

#### Test a VMS data file

A sample data file is included with the icesDatsu package called
vms_test.csv

``` r
library(icesDatsuQC)
filename <- system.file("test_files/vms_test.csv", package = "icesDatsuQC")
vms_test <- read.csv(filename, header = FALSE)
head(vms_test)
```

    ##   V1 V2   V3 V4 V5     V6             V7  V8  V9            V10 V11 V12 V13 V14 V15      V16      V17      V18 V19      V20
    ## 1 VE IE 2020 11  2 aaa111 7400:374:112:4 OTT CAT OTT_CRU_>=70_0   A  NA  NA   1  NA 2.517947 2.185278 16.20309   1 622.8131
    ## 2 VE IE 2010 11  2 aaa111 7400:374:112:1 OTT CAT OTT_CRU_>=70_0   A  NA  NA   1  NA 2.517947 2.185278 16.20309   1 622.8131
    ## 3 VE IE 2020 11  2 aaa111 7400:374:112:4 OTT CAT OTT_CRU_>=70_0   A  NA  NA   1  NA 2.517947 2.185278 16.20309   1 622.8131
    ## 4 VE IE 2020 11  2 aaa111 7400:374:112:4 OTT CAT OTT_CRU_>=70_0   A  NA  NA   1  NA 2.517947 2.185278 16.20309   1 622.8131
    ## 5 VE IE 2020 11  2 aaa111 7400:374:112:4 OTT CAT OTT_CRU_>=70_0   A  NA  NA   1  NA 2.517947 2.185278 16.20309   1 622.8131
    ## 6 VE IE 2020 11  2 aaa111 7400:374:112:4 OTT CAT OTT_CRU_>=70_0   A  NA  NA   1  NA 2.517947 2.185278 16.20309   1 622.8131
    ##        V21      V22 V23 V24
    ## 1 27.63547 126.4042   1 0.2
    ## 2 27.63547 126.4042   2 0.2
    ## 3 27.63547 126.4042   1 0.2
    ## 4 27.63547 126.4042   1 0.2
    ## 5 27.63547 126.4042   1 0.2
    ## 6 27.63547 126.4042   1 0.2

Lets say we have used the `icesDatsu` package to find the correct
dataset version ID and record ID, that is, we know we want dataset 145
(VMS) and record type VE (VMS records).

Then to run the SQL checks on our file, run:

``` r
runQCChecks(filename, 145, "VE")
```

    ## GETing ... https://datsu.ices.dk/api/getListQCChecks/145?RecordType=VE

    ## no token used

    ## OK (HTTP 200).
    ## 
    ## year hard wired to 2022 for now
    ## GETing ... https://datsu.ices.dk/api/getDataFieldsDescription/145?RecordType=VE
    ## no token used
    ## OK (HTTP 200).

    ## Warning in runQCChecks(filename, 145, "VE"): 3 checks could not be run locally, you may still get errors on submission.

    ## all checks possible to run in R passed

So all checks passed. Great, what is it like if there is an error? Lets
force an error

``` r
# invalid year
vms_test[1:2, 3] <- 1999
# invalid month
vms_test[3, 4] <- 13
# invalid discinct vessel count
vms_test[3, 5] <- 0
# invalid country code - only one country per file MISSED
vms_test[3, 2] <- "NO"
write.table(vms_test, file = "vms_test2.csv", row.names = FALSE, col.names = FALSE, sep = ",")
runQCChecks("vms_test2.csv", 145, "VE")
```

    ## GETing ... https://datsu.ices.dk/api/getListQCChecks/145?RecordType=VE

    ## no token used

    ## OK (HTTP 200).
    ## 
    ## year hard wired to 2022 for now
    ## GETing ... https://datsu.ices.dk/api/getDataFieldsDescription/145?RecordType=VE
    ## no token used
    ## OK (HTTP 200).

    ## Warning in runQCChecks("vms_test2.csv", 145, "VE"): 3 checks could not be run locally, you may still get errors on
    ## submission.

    ## Warning in runQCChecks("vms_test2.csv", 145, "VE"): 5 checks failed

    ##     Linenumber                                    check_Description errorType
    ## 1            1        Year is not valid, plase check the year value     error
    ## 1.1          2        Year is not valid, plase check the year value     error
    ## 4            1 Only data from 2000 to the current year are accepted     error
    ## 4.1          2 Only data from 2000 to the current year are accepted     error
    ## 5            3  Invalid month - the month must be between 1 and 12.     error
    ## 6            3    There needs to be one or more distinct vessel(s).     error
    ## 7            1            Only one country can be submited per file     error

### References

ICES Data Screening Utility (DATSU): <https://datsu.ices.dk>

ICES Data Screening Utility web services:
<https://datsu.ices.dk/web/webservices.aspx>

### Development

icesDatsuQC is developed openly on
[GitHub](https://github.com/ices-tools-prod/icesDatsuQC).

Feel free to open an
[issue](https://github.com/ices-tools-prod/icesDatsuQC/issues) there if
you encounter problems or have suggestions for future versions.

The current development version can be installed using:

``` r
library(devtools)
install_github("ices-tools-prod/icesDatsuQC@development")
```
