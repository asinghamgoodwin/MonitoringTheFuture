Community Attachment
================

Using the paper [Associations between Community Attachments and
Adolescent Substance Use in Nationally Representative
Samples](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3699306/) as a
reference, I’m trying to replicate the original results (1976-2008), and
then see how community attachment relates to substance use in the period
from 2009-2018.

Some random thoughts and new directions I have in mind for potential
next steps:

  - What’s different about 2009-2018?
      - Legalization of marijuana
      - Opioid crisis
      - Financial crisis
      - Drug use in general going down, but marijuana staying constant
  - Other exposures/predictors to look at:
      - Broader “society attachment” / faith in institutions (ex. do you
        think voting matters?)
      - Community/society engagement (not just attachment) - things like
        having a job, drivers license, community service
      - Deeper dive into gender differences?
  - Another outcome: Mental health (internalizing/externalizing)?

# Code setup

## Step 0. Import helper functions, define constants, etc.

Luckily, everything in the base set of community attachment measures,
substance use, and most control variables are asked in form 1 (file 2).
I’ll also need to pull some basic demographics from the core form (file
1).

``` r
all_years = 1976:2018
old_years = 1976:2008
new_years = 2009:2018
```

These two helper functions come from separate R scripts.

Create a standardized list of names for variables across years.

*TODO - this shouldn’t happen in this file…. once I’ve gotten a better
handle on it I’d like to do this somewhere separate and have a
definitive static file of standard names to reference.*

``` r
grade12_file1_mapping = tibble()
grade12_file2_mapping = tibble()

for (year in new_years) {
  grade12_file1_mapping = rbind(grade12_file1_mapping,
                                create_mapping(path = "~/Documents/Code/MTF/MTFData/12th_grade/",
                                               year = year,
                                               file_number = 1
                                               )
                                )
    grade12_file2_mapping = rbind(grade12_file2_mapping,
                                create_mapping(path = "~/Documents/Code/MTF/MTFData/12th_grade/",
                                               year = year,
                                               file_number = 2
                                               )
                                )
}
```

## Step 1: Create a smaller database that includes only the variables I need

First, define the list of variables we want. The original paper includes
demographics (control variables), measures of community attachment, and
substance use.

<details>

<summary>Click to see all the variable names from the original
paper.</summary>

``` r
demographics = c("R'S ID-SERIAL #",
                 "SAMPLING WEIGHT",
                 "R'S SEX",
                 "R'S RACE", # Only for years before 2005
                 "R'S RACE B/W/H",
                 "FATHR EDUC LEVEL",
                 "MOTHR EDUC LEVEL",
                 "R WL DO 2YR CLG",
                 "R WL DO 4YR CLG",
                 "R HS GRADE/D=1"
                 )

social_trust = c("PPL TRY BE FAIR",
                 "PPL TRY B HLPFL",
                 "PPL CAN B TRSTD"
                 )

social_responsibility = c("IMP CNTRBTN SOC",
                          "IMP LDR COMUNTY",
                          "IMP CRRCT INEQL"
                          )

religiosity = c("R'ATTND REL SVC",
                "RLGN IMP R'S LF")

community_attachment = c(social_trust,
                         social_responsibility,
                         religiosity
                         )

substance_use = c("EVR SMK CIG,REGL",
                  "#CIGS SMKD/30DAY",
                  "#X ALC/LIF SIPS",
                  "#X DRNK/LIFETIME",
                  "#X ALC/30D SIPS",
                  "#X DRNK/LAST30DAY",
                  "5+DRK ROW/LST 2W",
                  "#XMJ+HS/LIFETIME",
                  "#XMJ+HS/LAST30DAY",
                  "#X LSD/LIFETIME",
                  "#X LSD/LAST30DAY",
                  "#X PSYD/LIFETIME",
                  "#X PSYD/LAST30DAY",
                  "#X COKE/LIFETIME",
                  "#X COKE/LAST30DAY",
                  "#X AMPH/LIFETIME",
                  "#X AMPH/LAST30DAY",
                  "#X SED/BARB/LAST30DAY",
                  "#X SED/BARB/LIFETIME",
                  "#X TRQL/LIFETIME",
                  "#X TRQL/LAST30DAY",
                  "#X NARC/LIFETIME",
                  "#X NARC/LAST30DAY"
                  )

# Notes about how to find stuff in the data:
# Lifetime alcohol & 30-day alcohol --
#    `#X ALC/LIF SIPS` and `#X ALC/30D SIPS` are only in 2009-2016
#    `#X DRNK/LIFETIME` and `#X DRNK/LAST30DAY` are how it's labeled in 2017-18
#    **** TODO **** (make sure it's the same coding, then combine into one helpful name)
# Other illicit drugs -- 
#    hallucinogens: include LSD & hall. other than LSD -- include MDMA? (I think no)
```

</details>

I’m potentially interested in a handful more variables, such as *X, Y,
Z*.

<details>

<summary>Click to see the variable names that I’m adding
in.</summary>

``` r
# TODO - fill in later. Make sure the variables are from the same forms or can somehow be compared against what we're already searching for...
```

</details>

Get data from all participants for each of the variables above.
Merge/combine by ID number and year.

Notes:

  - *TODO: probably worth making/modifying a helper function so that the
    merges can be automatic.*
  - Although many of the variables in `demographics`, `substance_use`,
    and `community_attachment` can be found in file 1 and file 2, the
    variables names are cleaner for substance use in file 1, so I’ve
    decided to get all deomgraphics and substance use info from file 1,
    all community attachment info from file 2, and combine on ID number.

<!-- end list -->

``` r
# TODO: add in from new_variable_lists once I get there
# TODO: switch from new_years to all_years once I've gotten the old data into good shape

raw_data_file1 = get_specific_data_by_years(path = "~/Documents/Code/MTF/MTFData/12th_grade/",
                                     file_number = 1,
                                     years = new_years,
                                     mapping = grade12_file1_mapping,
                                     variables_to_include = c(demographics,
                                                              substance_use)
                                     )

raw_data_file2 = get_specific_data_by_years(path = "~/Documents/Code/MTF/MTFData/12th_grade/",
                                     file_number = 2,
                                     years = new_years,
                                     mapping = grade12_file2_mapping,
                                     variables_to_include = c("R'S ID-SERIAL #",
                                                              community_attachment)
                                     )
```

</details>

``` r
raw_data_combined = inner_join(raw_data_file1, raw_data_file2, by = c("R'S ID-SERIAL #", "year"))

knitr::kable(raw_data_combined[100:110,])
```

| \#CIGS SMKD/30DAY | \#X ALC/30D SIPS | \#X ALC/LIF SIPS | \#X AMPH/LAST30DAY | \#X AMPH/LIFETIME | \#X COKE/LAST30DAY | \#X COKE/LIFETIME | \#X DRNK/LAST30DAY | \#X DRNK/LIFETIME | \#X LSD/LAST30DAY | \#X LSD/LIFETIME | \#X NARC/LAST30DAY | \#X NARC/LIFETIME | \#X PSYD/LAST30DAY | \#X PSYD/LIFETIME | \#X SED/BARB/LAST30DAY | \#X SED/BARB/LIFETIME | \#X TRQL/LAST30DAY | \#X TRQL/LIFETIME | \#XMJ+HS/LAST30DAY | \#XMJ+HS/LIFETIME | 5+DRK ROW/LST 2W | EVR SMK CIG,REGL | FATHR EDUC LEVEL | grade.x | MOTHR EDUC LEVEL | R HS GRADE/D=1 | R WL DO 2YR CLG | R WL DO 4YR CLG | R’S ID-SERIAL \# | R’S RACE | R’S RACE B/W/H | R’S SEX | SAMPLING WEIGHT | year | grade.y | IMP CNTRBTN SOC | IMP CRRCT INEQL | IMP LDR COMUNTY | PPL CAN B TRSTD | PPL TRY B HLPFL | PPL TRY BE FAIR | R’ATTND REL SVC | RLGN IMP R’S LF |
| ----------------: | ---------------: | ---------------: | -----------------: | ----------------: | -----------------: | ----------------: | -----------------: | ----------------: | ----------------: | ---------------: | -----------------: | ----------------: | -----------------: | ----------------: | ---------------------: | --------------------: | -----------------: | ----------------: | -----------------: | ----------------: | ---------------: | ---------------: | ---------------: | ------: | ---------------: | -------------: | --------------: | --------------: | ---------------: | -------: | -------------: | ------: | --------------: | ---: | ------: | --------------: | --------------: | --------------: | --------------: | --------------: | --------------: | --------------: | --------------: |
|                 1 |                1 |                5 |                  1 |                 1 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 1 |                  1 |                 1 |                      1 |                     1 |                  1 |                 1 |                  1 |                 1 |                1 |                1 |                7 |      12 |                1 |              4 |               1 |               3 |            10100 |      \-8 |              3 |       1 |          1.4732 | 2009 |      12 |               3 |               2 |               2 |               1 |               1 |               1 |             \-9 |             \-9 |
|                 4 |                3 |                7 |                  1 |                 1 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 1 |                  1 |                 1 |                      1 |                     1 |                  1 |                 1 |                  1 |                 1 |                2 |                5 |                3 |      12 |                3 |              2 |               3 |               3 |            10101 |      \-8 |              2 |       1 |          1.3784 | 2009 |      12 |               2 |               2 |               3 |               2 |               1 |               1 |               4 |               3 |
|                 1 |                1 |                3 |                  1 |                 1 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 2 |                  1 |                 1 |                      1 |                     1 |                  1 |                 1 |                  1 |                 1 |                1 |                1 |                2 |      12 |                4 |              6 |               3 |               3 |            10102 |      \-8 |              2 |       2 |          2.5084 | 2009 |      12 |               3 |               3 |               2 |               1 |               2 |               2 |               2 |               3 |
|                 4 |                2 |                7 |                  1 |                 1 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 1 |                  1 |                 2 |                      1 |                     1 |                  1 |                 1 |                  4 |                 7 |                2 |                5 |                3 |      12 |                4 |              6 |               1 |               3 |            10103 |      \-8 |              2 |       2 |          0.3013 | 2009 |      12 |               3 |               4 |               4 |               1 |               2 |               1 |             \-9 |             \-9 |
|                 1 |                1 |                1 |                \-9 |               \-9 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 1 |                  1 |                 1 |                      1 |                     1 |                  1 |                 1 |                  1 |                 1 |                1 |                1 |                3 |      12 |                3 |              4 |               3 |               2 |            10104 |      \-8 |            \-9 |       2 |          1.4105 | 2009 |      12 |               3 |               3 |               2 |               1 |               2 |               1 |               4 |               4 |
|                 1 |                2 |                4 |                  1 |                 1 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 3 |                  1 |                 1 |                      1 |                     1 |                  1 |                 1 |                  1 |                 2 |                2 |                2 |                3 |      12 |                3 |              9 |               2 |               4 |            10105 |      \-8 |              2 |       2 |          1.0390 | 2009 |      12 |               2 |               1 |               2 |               1 |               1 |               2 |               2 |               2 |
|                 3 |                3 |                7 |                  1 |                 1 |                  1 |                 2 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 1 |                  1 |                 2 |                      1 |                     1 |                  1 |                 1 |                  6 |                 7 |                1 |                4 |                5 |      12 |                4 |              5 |               1 |               4 |            10106 |      \-8 |              2 |       1 |          0.4684 | 2009 |      12 |               4 |               2 |               4 |               1 |               1 |               1 |               2 |               4 |
|                 3 |                6 |                7 |                  1 |                 2 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 3 |                  1 |                 1 |                      1 |                     1 |                  1 |                 1 |                  1 |                 5 |                1 |                5 |                3 |      12 |                3 |              2 |               3 |               4 |            10107 |      \-8 |              2 |       2 |          1.1753 | 2009 |      12 |               4 |               4 |               3 |               1 |               1 |               1 |               1 |               3 |
|                 1 |                3 |                7 |                  7 |                 7 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 1 |                  1 |                 1 |                      1 |                     1 |                  1 |                 1 |                  1 |                 1 |                1 |                1 |                1 |      12 |                3 |              8 |             \-9 |             \-9 |            10108 |      \-8 |              1 |       2 |          0.1830 | 2009 |      12 |               3 |               3 |               2 |               1 |               2 |               1 |               4 |               3 |
|                 3 |                2 |                5 |                  1 |                 2 |                  1 |                 2 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 2 |                  1 |                 2 |                      1 |                     2 |                  1 |                 1 |                  5 |                 6 |                1 |                4 |                4 |      12 |                4 |              7 |               3 |               3 |            10109 |      \-8 |              2 |       1 |          0.9600 | 2009 |      12 |               1 |               2 |               1 |               1 |               2 |               1 |               2 |               1 |
|                 1 |                1 |                3 |                  1 |                 1 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 1 |                  1 |                 1 |                      1 |                     1 |                  1 |                 1 |                  3 |                 6 |                1 |                2 |                3 |      12 |                4 |              5 |               1 |               4 |            10110 |      \-8 |            \-9 |       2 |          0.5349 | 2009 |      12 |               3 |               2 |               1 |               1 |               3 |               1 |               1 |               1 |

``` r
summary(raw_data_combined)
```

    ##  #CIGS SMKD/30DAY  #X ALC/30D SIPS   #X ALC/LIF SIPS  #X AMPH/LAST30DAY
    ##  Min.   :-9.0000   Min.   :-9.0000   Min.   :-9.000   Min.   :-9.0000  
    ##  1st Qu.: 1.0000   1st Qu.: 1.0000   1st Qu.: 1.000   1st Qu.: 1.0000  
    ##  Median : 1.0000   Median : 1.0000   Median : 2.000   Median : 1.0000  
    ##  Mean   : 0.7873   Mean   :-0.6126   Mean   : 0.874   Mean   : 0.2456  
    ##  3rd Qu.: 1.0000   3rd Qu.: 2.0000   3rd Qu.: 5.000   3rd Qu.: 1.0000  
    ##  Max.   : 7.0000   Max.   : 7.0000   Max.   : 7.000   Max.   : 7.0000  
    ##  #X AMPH/LIFETIME  #X COKE/LAST30DAY #X COKE/LIFETIME #X DRNK/LAST30DAY
    ##  Min.   :-9.0000   Min.   :-9.000    Min.   :-9.000   Min.   :-9.000   
    ##  1st Qu.: 1.0000   1st Qu.: 1.000    1st Qu.: 1.000   1st Qu.:-8.000   
    ##  Median : 1.0000   Median : 1.000    Median : 1.000   Median :-8.000   
    ##  Mean   : 0.3987   Mean   :-0.181    Mean   :-0.124   Mean   :-6.206   
    ##  3rd Qu.: 1.0000   3rd Qu.: 1.000    3rd Qu.: 1.000   3rd Qu.:-8.000   
    ##  Max.   : 7.0000   Max.   : 7.000    Max.   : 7.000   Max.   : 7.000   
    ##  #X DRNK/LIFETIME #X LSD/LAST30DAY #X LSD/LIFETIME   #X NARC/LAST30DAY 
    ##  Min.   :-9.000   Min.   :-9.000   Min.   :-9.0000   Min.   :-9.00000  
    ##  1st Qu.:-8.000   1st Qu.: 1.000   1st Qu.: 1.0000   1st Qu.: 1.00000  
    ##  Median :-8.000   Median : 1.000   Median : 1.0000   Median : 1.00000  
    ##  Mean   :-5.865   Mean   : 0.313   Mean   : 0.3722   Mean   :-0.03284  
    ##  3rd Qu.:-8.000   3rd Qu.: 1.000   3rd Qu.: 1.0000   3rd Qu.: 1.00000  
    ##  Max.   : 7.000   Max.   : 7.000   Max.   : 7.0000   Max.   : 7.00000  
    ##  #X NARC/LIFETIME  #X PSYD/LAST30DAY #X PSYD/LIFETIME  #X SED/BARB/LAST30DAY
    ##  Min.   :-9.0000   Min.   :-9.0000   Min.   :-9.0000   Min.   :-9.0000      
    ##  1st Qu.: 1.0000   1st Qu.: 1.0000   1st Qu.: 1.0000   1st Qu.: 1.0000      
    ##  Median : 1.0000   Median : 1.0000   Median : 1.0000   Median : 1.0000      
    ##  Mean   : 0.1359   Mean   : 0.1675   Mean   : 0.2514   Mean   : 0.1435      
    ##  3rd Qu.: 1.0000   3rd Qu.: 1.0000   3rd Qu.: 1.0000   3rd Qu.: 1.0000      
    ##  Max.   : 7.0000   Max.   : 7.0000   Max.   : 7.0000   Max.   : 7.0000      
    ##  #X SED/BARB/LIFETIME #X TRQL/LAST30DAY  #X TRQL/LIFETIME  #XMJ+HS/LAST30DAY
    ##  Min.   :-9.0000      Min.   :-9.00000   Min.   :-9.0000   Min.   :-9.000   
    ##  1st Qu.: 1.0000      1st Qu.: 1.00000   1st Qu.: 1.0000   1st Qu.: 1.000   
    ##  Median : 1.0000      Median : 1.00000   Median : 1.0000   Median : 1.000   
    ##  Mean   : 0.2204      Mean   : 0.05662   Mean   : 0.1534   Mean   : 1.048   
    ##  3rd Qu.: 1.0000      3rd Qu.: 1.00000   3rd Qu.: 1.0000   3rd Qu.: 1.000   
    ##  Max.   : 7.0000      Max.   : 7.00000   Max.   : 7.0000   Max.   : 7.000   
    ##  #XMJ+HS/LIFETIME 5+DRK ROW/LST 2W  EVR SMK CIG,REGL FATHR EDUC LEVEL
    ##  Min.   :-9.000   Min.   :-9.0000   Min.   :-9.000   Min.   :-9.000  
    ##  1st Qu.: 1.000   1st Qu.: 1.0000   1st Qu.: 1.000   1st Qu.: 3.000  
    ##  Median : 1.000   Median : 1.0000   Median : 1.000   Median : 4.000  
    ##  Mean   : 2.024   Mean   : 0.6359   Mean   : 1.152   Mean   : 2.775  
    ##  3rd Qu.: 4.000   3rd Qu.: 1.0000   3rd Qu.: 2.000   3rd Qu.: 5.000  
    ##  Max.   : 7.000   Max.   : 6.0000   Max.   : 5.000   Max.   : 7.000  
    ##     grade.x   MOTHR EDUC LEVEL R HS GRADE/D=1  R WL DO 2YR CLG  
    ##  Min.   :12   Min.   :-9.000   Min.   :-9.00   Min.   :-9.0000  
    ##  1st Qu.:12   1st Qu.: 3.000   1st Qu.: 4.00   1st Qu.: 1.0000  
    ##  Median :12   Median : 4.000   Median : 7.00   Median : 1.0000  
    ##  Mean   :12   Mean   : 2.844   Mean   : 4.69   Mean   : 0.4008  
    ##  3rd Qu.:12   3rd Qu.: 5.000   3rd Qu.: 8.00   3rd Qu.: 3.0000  
    ##  Max.   :12   Max.   : 7.000   Max.   : 9.00   Max.   : 4.0000  
    ##  R WL DO 4YR CLG  R'S ID-SERIAL #    R'S RACE  R'S RACE B/W/H   
    ##  Min.   :-9.000   Min.   :10001   Min.   :-8   Min.   :-9.0000  
    ##  1st Qu.: 2.000   1st Qu.:10645   1st Qu.:-8   1st Qu.: 1.0000  
    ##  Median : 4.000   Median :11237   Median :-8   Median : 2.0000  
    ##  Mean   : 1.659   Mean   :11244   Mean   :-8   Mean   :-0.4641  
    ##  3rd Qu.: 4.000   3rd Qu.:11834   3rd Qu.:-8   3rd Qu.: 2.0000  
    ##  Max.   : 4.000   Max.   :12910   Max.   :-8   Max.   : 3.0000  
    ##     R'S SEX        SAMPLING WEIGHT        year         grade.y  
    ##  Min.   :-9.0000   Min.   :0.07635   Min.   :2009   Min.   :12  
    ##  1st Qu.: 1.0000   1st Qu.:0.61495   1st Qu.:2011   1st Qu.:12  
    ##  Median : 1.0000   Median :0.85074   Median :2013   Median :12  
    ##  Mean   : 0.3893   Mean   :0.99824   Mean   :2013   Mean   :12  
    ##  3rd Qu.: 2.0000   3rd Qu.:1.22205   3rd Qu.:2016   3rd Qu.:12  
    ##  Max.   : 2.0000   Max.   :5.80390   Max.   :2018   Max.   :12  
    ##  IMP CNTRBTN SOC  IMP CRRCT INEQL  IMP LDR COMUNTY PPL CAN B TRSTD  
    ##  Min.   :-9.000   Min.   :-9.000   Min.   :-9.00   Min.   :-9.0000  
    ##  1st Qu.: 2.000   1st Qu.: 2.000   1st Qu.: 2.00   1st Qu.: 1.0000  
    ##  Median : 3.000   Median : 2.000   Median : 2.00   Median : 1.0000  
    ##  Mean   : 2.654   Mean   : 2.139   Mean   : 2.23   Mean   : 0.9586  
    ##  3rd Qu.: 4.000   3rd Qu.: 3.000   3rd Qu.: 3.00   3rd Qu.: 2.0000  
    ##  Max.   : 4.000   Max.   : 4.000   Max.   : 4.00   Max.   : 3.0000  
    ##  PPL TRY B HLPFL  PPL TRY BE FAIR  R'ATTND REL SVC  RLGN IMP R'S LF 
    ##  Min.   :-9.000   Min.   :-9.000   Min.   :-9.000   Min.   :-9.000  
    ##  1st Qu.: 1.000   1st Qu.: 1.000   1st Qu.:-9.000   1st Qu.:-9.000  
    ##  Median : 2.000   Median : 2.000   Median : 2.000   Median : 2.000  
    ##  Mean   : 1.476   Mean   : 1.375   Mean   :-1.139   Mean   :-1.106  
    ##  3rd Qu.: 2.000   3rd Qu.: 2.000   3rd Qu.: 3.000   3rd Qu.: 3.000  
    ##  Max.   : 3.000   Max.   : 3.000   Max.   : 4.000   Max.   : 4.000

NOTES:

  - Check in on the values here… there’s a lot more missing data (`-9`)
    than I expected\!
  - It would probably be helpful to recode `-9` as `NA` so I could take
    advantage of R’s built-in understandings of missing data.
  - I’d love a more useful quick representation of the data than
    `summary()` provides (I’m imagining something like `proc freq` in
    SAS…)

## Step 2: Recode, create indicators/aggregate values, etc.

At minimum: 1. Create social trust score 2. Create social responsibility
score 3. Create religiosity score 4. Operationalize substance use
(probably multiple different variables) 5. Combine momEd and dadEd into
SES 6. Combine 2yr and 4yr college graduation expectations 7. Create
dummy variable for each year of the survey, to account for historical
trends. (Note: in original paper they did this and then found the dummy
variables to not be significant. But it’s worth it for me to check, both
for 2009-2018 and if I add in any new predictors or outcoems.)

``` r
recoded = raw_data_combined %>% 
  na_if(., -9) %>% # This is how MTF codes missing values
  na_if(., -8) %>% # This is how my code (and sometimes MTF) codes questions that weren't asked to a participant
  
  # Values we can use as-is without mutating:
  rename(., `High school grades` = `R HS GRADE/D=1`
         ) %>% 
  
  # For both of these, 7 meant "I don't know / doesn't apply" so I'm recoding those as missing
  mutate(., `MOTHR EDUC LEVEL` = na_if(`MOTHR EDUC LEVEL`, 7),
         `FATHR EDUC LEVEL` = na_if(`FATHR EDUC LEVEL`, 7)
         ) %>% 
  
  # Recode and rename demographics/control variables
  mutate(., Sex = as.factor(recode(`R'S SEX`,
                                   `1` = 'Male',
                                   `2` = 'Female')), # Male=1 Female=0
         Race = as.factor(recode(`R'S RACE B/W/H`,
                                 `1` = 'Black',
                                 `2` = 'White',
                                 `3` = 'Hispanic',
                                 .missing = 'Other/missing')), # White=1, Black=0, others=missing
         `College aspirations` = as.factor(case_when(
           `R WL DO 4YR CLG` %in% c(3, 4) ~ '4-year college plans',
           `R WL DO 2YR CLG` %in% c(3, 4) ~ '2-year college plans',
           `R WL DO 2YR CLG` %in% c(1, 2) ~ 'No college plans')), # coded with dummy variables
         `Parents' education` = 
           as.factor(pmax(`MOTHR EDUC LEVEL`, `FATHR EDUC LEVEL`, na.rm = TRUE)) #NOTE - pmax does max comparissons element-by-element. if either value exists, return that instead of NA
         ) %>% 
  
  # Create social trust score and social responsibility score
  mutate(., `Social Trust` = rowMeans(cbind(`PPL CAN B TRSTD`, `PPL TRY B HLPFL`, `PPL TRY BE FAIR`), na.rm = TRUE),
         `Social Trust - NO_MISSING` = rowMeans(cbind(`PPL CAN B TRSTD`, `PPL TRY B HLPFL`, `PPL TRY BE FAIR`)),
         `Social Responsibility` = rowMeans(cbind(`IMP CNTRBTN SOC`, `IMP CRRCT INEQL`, `IMP LDR COMUNTY`), na.rm = TRUE),
         `Social Responsibility - NO_MISSING` = rowMeans(cbind(`IMP CNTRBTN SOC`, `IMP CRRCT INEQL`, `IMP LDR COMUNTY`))
         ) %>% 
  
  # Prep work and then create religiosity score
  mutate(., rel1scaled = scale(`R'ATTND REL SVC`),
         rel2scaled = scale(`RLGN IMP R'S LF`),
         `Religiosity` = rowMeans(cbind(rel1scaled, rel2scaled), na.rm = TRUE),
         `Religiosity - NO_MISSING` = rowMeans(cbind(rel1scaled, rel2scaled))
         )

summary(recoded)
```

    ##  #CIGS SMKD/30DAY #X ALC/30D SIPS #X ALC/LIF SIPS #X AMPH/LAST30DAY
    ##  Min.   :1.000    Min.   :1.000   Min.   :1.000   Min.   :1.00     
    ##  1st Qu.:1.000    1st Qu.:1.000   1st Qu.:2.000   1st Qu.:1.00     
    ##  Median :1.000    Median :1.000   Median :4.000   Median :1.00     
    ##  Mean   :1.284    Mean   :1.838   Mean   :3.747   Mean   :1.06     
    ##  3rd Qu.:1.000    3rd Qu.:2.000   3rd Qu.:6.000   3rd Qu.:1.00     
    ##  Max.   :7.000    Max.   :7.000   Max.   :7.000   Max.   :7.00     
    ##  NA's   :1124     NA's   :5694    NA's   :5612    NA's   :1884     
    ##  #X AMPH/LIFETIME #X COKE/LAST30DAY #X COKE/LIFETIME #X DRNK/LAST30DAY
    ##  Min.   :1.00     Min.   :1.000     Min.   :1.000    Min.   :1.000    
    ##  1st Qu.:1.00     1st Qu.:1.000     1st Qu.:1.000    1st Qu.:1.000    
    ##  Median :1.00     Median :1.000     Median :1.000    Median :1.000    
    ##  Mean   :1.23     Mean   :1.019     Mean   :1.086    Mean   :1.673    
    ##  3rd Qu.:1.00     3rd Qu.:1.000     3rd Qu.:1.000    3rd Qu.:2.000    
    ##  Max.   :7.00     Max.   :7.000     Max.   :7.000    Max.   :7.000    
    ##  NA's   :1891     NA's   :2787      NA's   :2790     NA's   :18911    
    ##  #X DRNK/LIFETIME #X LSD/LAST30DAY #X LSD/LIFETIME #X NARC/LAST30DAY
    ##  Min.   :1.000    Min.   :1.000    Min.   :1.000   Min.   :1.000    
    ##  1st Qu.:1.000    1st Qu.:1.000    1st Qu.:1.000   1st Qu.:1.000    
    ##  Median :3.000    Median :1.000    Median :1.000   Median :1.000    
    ##  Mean   :3.388    Mean   :1.027    Mean   :1.092   Mean   :1.044    
    ##  3rd Qu.:5.000    3rd Qu.:1.000    3rd Qu.:1.000   3rd Qu.:1.000    
    ##  Max.   :7.000    Max.   :7.000    Max.   :7.000   Max.   :7.000    
    ##  NA's   :18874    NA's   :1656     NA's   :1659    NA's   :2494     
    ##  #X NARC/LIFETIME #X PSYD/LAST30DAY #X PSYD/LIFETIME #X SED/BARB/LAST30DAY
    ##  Min.   :1.000    Min.   :1.000     Min.   :1.000    Min.   :1.000        
    ##  1st Qu.:1.000    1st Qu.:1.000     1st Qu.:1.000    1st Qu.:1.000        
    ##  Median :1.000    Median :1.000     Median :1.000    Median :1.000        
    ##  Mean   :1.235    Mean   :1.029     Mean   :1.117    Mean   :1.029        
    ##  3rd Qu.:1.000    3rd Qu.:1.000     3rd Qu.:1.000    3rd Qu.:1.000        
    ##  Max.   :7.000    Max.   :7.000     Max.   :7.000    Max.   :7.000        
    ##  NA's   :2498     NA's   :1999      NA's   :1991     NA's   :2054         
    ##  #X SED/BARB/LIFETIME #X TRQL/LAST30DAY #X TRQL/LIFETIME #XMJ+HS/LAST30DAY
    ##  Min.   :1.000        Min.   :1.000     Min.   :1.000    Min.   :1.000    
    ##  1st Qu.:1.000        1st Qu.:1.000     1st Qu.:1.000    1st Qu.:1.000    
    ##  Median :1.000        Median :1.000     Median :1.000    Median :1.000    
    ##  Mean   :1.116        Mean   :1.035     Mean   :1.148    Mean   :1.707    
    ##  3rd Qu.:1.000        3rd Qu.:1.000     3rd Qu.:1.000    3rd Qu.:1.000    
    ##  Max.   :7.000        Max.   :7.000     Max.   :7.000    Max.   :7.000    
    ##  NA's   :2060         NA's   :2268      NA's   :2280     NA's   :1432     
    ##  #XMJ+HS/LIFETIME 5+DRK ROW/LST 2W EVR SMK CIG,REGL FATHR EDUC LEVEL
    ##  Min.   :1.000    Min.   :1.000    Min.   :1.000    Min.   :1.000   
    ##  1st Qu.:1.000    1st Qu.:1.000    1st Qu.:1.000    1st Qu.:3.000   
    ##  Median :1.000    Median :1.000    Median :1.000    Median :4.000   
    ##  Mean   :2.707    Mean   :1.321    Mean   :1.674    Mean   :3.846   
    ##  3rd Qu.:4.000    3rd Qu.:1.000    3rd Qu.:2.000    3rd Qu.:5.000   
    ##  Max.   :7.000    Max.   :6.000    Max.   :5.000    Max.   :6.000   
    ##  NA's   :1357     NA's   :1543     NA's   :1138     NA's   :4184    
    ##     grade.x   MOTHR EDUC LEVEL High school grades R WL DO 2YR CLG
    ##  Min.   :12   Min.   :1.000    Min.   :1.000      Min.   :1.000  
    ##  1st Qu.:12   1st Qu.:3.000    1st Qu.:5.000      1st Qu.:1.000  
    ##  Median :12   Median :4.000    Median :7.000      Median :2.000  
    ##  Mean   :12   Mean   :4.056    Mean   :6.654      Mean   :2.236  
    ##  3rd Qu.:12   3rd Qu.:5.000    3rd Qu.:8.000      3rd Qu.:3.000  
    ##  Max.   :12   Max.   :6.000    Max.   :9.000      Max.   :4.000  
    ##               NA's   :3447     NA's   :2918       NA's   :3800   
    ##  R WL DO 4YR CLG R'S ID-SERIAL #    R'S RACE     R'S RACE B/W/H 
    ##  Min.   :1.000   Min.   :10001   Min.   : NA     Min.   :1.000  
    ##  1st Qu.:3.000   1st Qu.:10645   1st Qu.: NA     1st Qu.:2.000  
    ##  Median :4.000   Median :11237   Median : NA     Median :2.000  
    ##  Mean   :3.396   Mean   :11244   Mean   :NaN     Mean   :2.055  
    ##  3rd Qu.:4.000   3rd Qu.:11834   3rd Qu.: NA     3rd Qu.:2.000  
    ##  Max.   :4.000   Max.   :12910   Max.   : NA     Max.   :3.000  
    ##  NA's   :3260                    NA's   :23262   NA's   :5300   
    ##     R'S SEX      SAMPLING WEIGHT        year         grade.y   IMP CNTRBTN SOC
    ##  Min.   :1.000   Min.   :0.07635   Min.   :2009   Min.   :12   Min.   :1.00   
    ##  1st Qu.:1.000   1st Qu.:0.61495   1st Qu.:2011   1st Qu.:12   1st Qu.:2.00   
    ##  Median :2.000   Median :0.85074   Median :2013   Median :12   Median :3.00   
    ##  Mean   :1.518   Mean   :0.99824   Mean   :2013   Mean   :12   Mean   :2.97   
    ##  3rd Qu.:2.000   3rd Qu.:1.22205   3rd Qu.:2016   3rd Qu.:12   3rd Qu.:4.00   
    ##  Max.   :2.000   Max.   :5.80390   Max.   :2018   Max.   :12   Max.   :4.00   
    ##  NA's   :2497                                                  NA's   :614    
    ##  IMP CRRCT INEQL IMP LDR COMUNTY PPL CAN B TRSTD PPL TRY B HLPFL
    ##  Min.   :1.000   Min.   :1.000   Min.   :1.000   Min.   :1.000  
    ##  1st Qu.:2.000   1st Qu.:2.000   1st Qu.:1.000   1st Qu.:1.000  
    ##  Median :2.000   Median :2.000   Median :1.000   Median :2.000  
    ##  Mean   :2.465   Mean   :2.533   Mean   :1.632   Mean   :1.813  
    ##  3rd Qu.:3.000   3rd Qu.:3.000   3rd Qu.:2.000   3rd Qu.:2.000  
    ##  Max.   :4.000   Max.   :4.000   Max.   :3.000   Max.   :3.000  
    ##  NA's   :661     NA's   :611     NA's   :1474    NA's   :725    
    ##  PPL TRY BE FAIR R'ATTND REL SVC RLGN IMP R'S LF     Sex       
    ##  Min.   :1.000   Min.   :1.000   Min.   :1.000   Female:10765  
    ##  1st Qu.:1.000   1st Qu.:2.000   1st Qu.:2.000   Male  :10000  
    ##  Median :2.000   Median :2.000   Median :3.000   NA's  : 2497  
    ##  Mean   :1.723   Mean   :2.514   Mean   :2.561                 
    ##  3rd Qu.:2.000   3rd Qu.:4.000   3rd Qu.:4.000                 
    ##  Max.   :3.000   Max.   :4.000   Max.   :4.000                 
    ##  NA's   :756     NA's   :7380    NA's   :7380                  
    ##             Race                 College aspirations Parents' education
    ##  Black        : 2552   2-year college plans: 1773    1   : 561         
    ##  Hispanic     : 3531   4-year college plans:16936    2   :1205         
    ##  Other/missing: 5300   No college plans    : 1478    3   :3600         
    ##  White        :11879   NA's                : 3075    4   :4035         
    ##                                                      5   :6451         
    ##                                                      6   :4281         
    ##                                                      NA's:3129         
    ##   Social Trust   Social Trust - NO_MISSING Social Responsibility
    ##  Min.   :1.000   Min.   :1.000             Min.   :1.000        
    ##  1st Qu.:1.333   1st Qu.:1.333             1st Qu.:2.000        
    ##  Median :1.667   Median :1.667             Median :2.667        
    ##  Mean   :1.725   Mean   :1.722             Mean   :2.656        
    ##  3rd Qu.:2.000   3rd Qu.:2.000             3rd Qu.:3.333        
    ##  Max.   :3.000   Max.   :3.000             Max.   :4.000        
    ##  NA's   :559     NA's   :1689              NA's   :518          
    ##  Social Responsibility - NO_MISSING  rel1scaled.V1    rel2scaled.V1  
    ##  Min.   :1.000                      Min.   :-1.353   Min.   :-1.399  
    ##  1st Qu.:2.000                      1st Qu.:-0.459   1st Qu.:-0.503  
    ##  Median :2.667                      Median :-0.459   Median : 0.393  
    ##  Mean   :2.656                      Mean   : 0.000   Mean   : 0.000  
    ##  3rd Qu.:3.333                      3rd Qu.: 1.327   3rd Qu.: 1.289  
    ##  Max.   :4.000                      Max.   : 1.327   Max.   : 1.289  
    ##  NA's   :827                        NA's   :7380     NA's   :7380    
    ##   Religiosity     Religiosity - NO_MISSING
    ##  Min.   :-1.399   Min.   :-1.376          
    ##  1st Qu.:-0.928   1st Qu.:-0.928          
    ##  Median :-0.033   Median :-0.033          
    ##  Mean   : 0.000   Mean   : 0.000          
    ##  3rd Qu.: 0.860   3rd Qu.: 0.860          
    ##  Max.   : 1.327   Max.   : 1.308          
    ##  NA's   :7316     NA's   :7444

``` r
#library(Hmisc)
#Hmisc::describe(recoded)
#glimpse(recoded)
# could do transmute to get rid of old columns! it only keeps the new ones you define
```

# Random questions and notes for later:

  - Is religiosity driving the whole community attachment indicator?
  - Somewhere, data from before 1990 is formatted differently (names of
    columns), so I need to incorporate that into my code.
  - Should I remove anyone who has missing data for any question? That
    seems like a lot\!
  - Do I need to code things as dummy variables, or does R have a way to
    do regression without?
      - Related: should everything be factors?
  - When averaging things (like for social trust score) is it ok if
    you’re missing one of the 3 things to average?
