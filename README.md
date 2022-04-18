
[![r-universe
version](https://ices-tools-prod.r-universe.dev/badges/icesDatsuQC)](https://ices-tools-prod.r-universe.dev/ui#package:icesDatsuQC)
[![CRAN
Status](http://r-pkg.org/badges/version/icesDatsuQC)](https://cran.r-project.org/package=icesDatsuQC)
[![CRAN
Monthly](http://cranlogs.r-pkg.org/badges/icesDatsuQC)](https://cran.r-project.org/package=icesDatsuQC)
[![CRAN
Total](http://cranlogs.r-pkg.org/badges/grand-total/icesDatsuQC)](https://cran.r-project.org/package=icesDatsuQC)

[<img align="right" alt="ICES Logo" width="17%" height="17%" src="http://ices.dk/_layouts/15/1033/images/icesimg/iceslogo.png">](http://ices.dk)

# icesDatsuQC

Run quality checks on data sets using the same checks that are conducted
on the [ICES Data Submission Utility
(DATSU)](https://datsu.ices.dk/web/index.aspx).

icesDatsuQC is implemented as an [R](https://www.r-project.org) package
and available on [CRAN](https://cran.r-project.org/package=icesDatsuQC).

## Installation

icesDatsuQC can be installed from CRAN using the standard
`install.packages()` command

``` r
install.packages("icesDatsuQC")
```

## Usage

For a summary of the package:

``` r
library(icesDatsuQC)
?icesDatsuQC
```

## Examples

## Test a VMS data file

A sample data file is included with the icesDatsu package called
vms\_test.csv

``` r
filename <- system.file("test_files/vms_test.csv", package = "icesDatsu")
vms_test <- read.csv(filename, header = FALSE)
head(vms_test)
```

    ##   V1 V2   V3 V4 V5     V6             V7  V8  V9            V10 V11      V12      V13      V14 V15
    ## 1 VE IE 2020 11  2 aaa111 7400:374:112:4 OTT CAT OTT_CRU_>=70_0   A 2.517947 2.185278 16.20309   1
    ## 2 VE IE 2010 11  2 aaa111 7400:374:112:1 OTT CAT OTT_CRU_>=70_0   A 2.517947 2.185278 16.20309   1
    ## 3 VE IE 2020 11  2 aaa111 7400:374:112:4 OTT CAT OTT_CRU_>=70_0   A 2.517947 2.185278 16.20309   1
    ## 4 VE IE 2020 11  2 aaa111 7400:374:112:4 OTT CAT OTT_CRU_>=70_0   A 2.517947 2.185278 16.20309   1
    ## 5 VE IE 2020 11  2 aaa111 7400:374:112:4 OTT CAT OTT_CRU_>=70_0   A 2.517947 2.185278 16.20309   1
    ## 6 VE IE 2020 11  2 aaa111 7400:374:112:4 OTT CAT OTT_CRU_>=70_0   A 2.517947 2.185278 16.20309   1
    ##        V16      V17      V18 V19
    ## 1 622.8131 27.63547 126.4042   1
    ## 2 622.8131 27.63547 126.4042   2
    ## 3 622.8131 27.63547 126.4042   1
    ## 4 622.8131 27.63547 126.4042   1
    ## 5 622.8131 27.63547 126.4042   1
    ## 6 622.8131 27.63547 126.4042   1

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

    ## Error : near "from": syntax error
    ## Error : near "from": syntax error
    ## Error : near "isnull": syntax error
    ## Error : near "from": syntax error

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

    ## Error : near "from": syntax error
    ## Error : near "from": syntax error
    ## Error : near "isnull": syntax error
    ## Error : near "from": syntax error

    ## $`Year is not valid, plase check the year value`
    ##   RecordType CountryCode Year Month NoDistinctVessels AnonymizedVesselID       C-square MetierL4
    ## 1         VE          IE 1999    11                 2             aaa111 7400:374:112:4      OTT
    ## 2         VE          IE 1999    11                 2             aaa111 7400:374:112:1      OTT
    ##   MetierL5       MetierL6 VesselLengthRange AverageFishingSpeed FishingHour AverageVesselLength
    ## 1      CAT OTT_CRU_>=70_0                 A            2.517947    2.185278            16.20309
    ## 2      CAT OTT_CRU_>=70_0                 A            2.517947    2.185278            16.20309
    ##   AveragekW kWFishingHour TotWeight TotValue AverageGearWidth
    ## 1         1      622.8131  27.63547 126.4042                1
    ## 2         1      622.8131  27.63547 126.4042                2
    ## 
    ## $`Only data from 2000 to the current year are accepted`
    ##   RecordType CountryCode Year Month NoDistinctVessels AnonymizedVesselID       C-square MetierL4
    ## 1         VE          IE 1999    11                 2             aaa111 7400:374:112:4      OTT
    ## 2         VE          IE 1999    11                 2             aaa111 7400:374:112:1      OTT
    ##   MetierL5       MetierL6 VesselLengthRange AverageFishingSpeed FishingHour AverageVesselLength
    ## 1      CAT OTT_CRU_>=70_0                 A            2.517947    2.185278            16.20309
    ## 2      CAT OTT_CRU_>=70_0                 A            2.517947    2.185278            16.20309
    ##   AveragekW kWFishingHour TotWeight TotValue AverageGearWidth
    ## 1         1      622.8131  27.63547 126.4042                1
    ## 2         1      622.8131  27.63547 126.4042                2
    ## 
    ## $`Invalid month - the month must be between 1 and 12.`
    ##   RecordType CountryCode Year Month NoDistinctVessels AnonymizedVesselID       C-square MetierL4
    ## 1         VE          NO 2020    13                 0             aaa111 7400:374:112:4      OTT
    ##   MetierL5       MetierL6 VesselLengthRange AverageFishingSpeed FishingHour AverageVesselLength
    ## 1      CAT OTT_CRU_>=70_0                 A            2.517947    2.185278            16.20309
    ##   AveragekW kWFishingHour TotWeight TotValue AverageGearWidth
    ## 1         1      622.8131  27.63547 126.4042                1
    ## 
    ## $`There needs to be one or more distinct vessel(s).`
    ##   RecordType CountryCode Year Month NoDistinctVessels AnonymizedVesselID       C-square MetierL4
    ## 1         VE          NO 2020    13                 0             aaa111 7400:374:112:4      OTT
    ##   MetierL5       MetierL6 VesselLengthRange AverageFishingSpeed FishingHour AverageVesselLength
    ## 1      CAT OTT_CRU_>=70_0                 A            2.517947    2.185278            16.20309
    ##   AveragekW kWFishingHour TotWeight TotValue AverageGearWidth
    ## 1         1      622.8131  27.63547 126.4042                1

# References
