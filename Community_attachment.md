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
substance use, and most covariates are asked in form 1 (file 2). I’ll
also need to pull some basic demographics from the core form (file 1).

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
demographics (covariates), measures of community attachment, and
substance use.

<details>

<summary>Click to see all the variable names from the original
paper.</summary>

``` r
demographics = c("R'S ID-SERIAL #",
                 "SAMPLING WEIGHT",
                 "R'S SEX",
                 "R'S RACE",
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

knitr::kable(head(raw_data_combined))
```

| \#CIGS SMKD/30DAY | \#X ALC/30D SIPS | \#X ALC/LIF SIPS | \#X AMPH/LAST30DAY | \#X AMPH/LIFETIME | \#X COKE/LAST30DAY | \#X COKE/LIFETIME | \#X DRNK/LAST30DAY | \#X DRNK/LIFETIME | \#X LSD/LAST30DAY | \#X LSD/LIFETIME | \#X NARC/LAST30DAY | \#X NARC/LIFETIME | \#X PSYD/LAST30DAY | \#X PSYD/LIFETIME | \#X SED/BARB/LAST30DAY | \#X SED/BARB/LIFETIME | \#X TRQL/LAST30DAY | \#X TRQL/LIFETIME | \#XMJ+HS/LAST30DAY | \#XMJ+HS/LIFETIME | 5+DRK ROW/LST 2W | EVR SMK CIG,REGL | FATHR EDUC LEVEL | grade.x | MOTHR EDUC LEVEL | R HS GRADE/D=1 | R WL DO 2YR CLG | R WL DO 4YR CLG | R’S ID-SERIAL \# | R’S RACE | R’S RACE B/W/H | R’S SEX | SAMPLING WEIGHT | year | grade.y | IMP CNTRBTN SOC | IMP CRRCT INEQL | IMP LDR COMUNTY | PPL CAN B TRSTD | PPL TRY B HLPFL | PPL TRY BE FAIR | R’ATTND REL SVC | RLGN IMP R’S LF |
| ----------------: | ---------------: | ---------------: | -----------------: | ----------------: | -----------------: | ----------------: | -----------------: | ----------------: | ----------------: | ---------------: | -----------------: | ----------------: | -----------------: | ----------------: | ---------------------: | --------------------: | -----------------: | ----------------: | -----------------: | ----------------: | ---------------: | ---------------: | ---------------: | ------: | ---------------: | -------------: | --------------: | --------------: | ---------------: | -------: | -------------: | ------: | --------------: | ---: | ------: | --------------: | --------------: | --------------: | --------------: | --------------: | --------------: | --------------: | --------------: |
|               \-9 |              \-9 |              \-9 |                \-9 |               \-9 |                \-9 |               \-9 |                \-8 |               \-8 |               \-9 |              \-9 |                \-9 |               \-9 |                \-9 |               \-9 |                    \-9 |                   \-9 |                \-9 |               \-9 |                \-9 |               \-9 |              \-9 |              \-9 |              \-9 |      12 |              \-9 |            \-9 |             \-9 |             \-9 |            10001 |      \-8 |            \-9 |     \-9 |          1.0787 | 2009 |      12 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |               4 |               4 |
|               \-9 |              \-9 |              \-9 |                \-9 |               \-9 |                \-9 |               \-9 |                \-8 |               \-8 |               \-9 |              \-9 |                \-9 |               \-9 |                \-9 |               \-9 |                    \-9 |                   \-9 |                \-9 |               \-9 |                \-9 |               \-9 |              \-9 |              \-9 |              \-9 |      12 |              \-9 |            \-9 |             \-9 |             \-9 |            10002 |      \-8 |            \-9 |     \-9 |          1.6354 | 2009 |      12 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |
|               \-9 |              \-9 |              \-9 |                \-9 |               \-9 |                \-9 |               \-9 |                \-8 |               \-8 |               \-9 |              \-9 |                \-9 |               \-9 |                \-9 |               \-9 |                    \-9 |                   \-9 |                \-9 |               \-9 |                \-9 |               \-9 |              \-9 |              \-9 |              \-9 |      12 |              \-9 |            \-9 |             \-9 |             \-9 |            10003 |      \-8 |            \-9 |     \-9 |          0.7607 | 2009 |      12 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |
|               \-9 |              \-9 |              \-9 |                \-9 |               \-9 |                \-9 |               \-9 |                \-8 |               \-8 |               \-9 |              \-9 |                \-9 |               \-9 |                \-9 |               \-9 |                    \-9 |                   \-9 |                \-9 |               \-9 |                \-9 |               \-9 |              \-9 |              \-9 |              \-9 |      12 |              \-9 |            \-9 |             \-9 |             \-9 |            10004 |      \-8 |            \-9 |     \-9 |          1.8473 | 2009 |      12 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |
|               \-9 |                7 |                7 |                \-9 |               \-9 |                \-9 |               \-9 |                \-8 |               \-8 |               \-9 |              \-9 |                \-9 |               \-9 |                \-9 |               \-9 |                    \-9 |                   \-9 |                \-9 |               \-9 |                  7 |                 7 |                3 |              \-9 |                5 |      12 |                6 |              8 |             \-9 |               4 |            10005 |      \-8 |            \-9 |       1 |          0.5000 | 2009 |      12 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |               1 |             \-9 |
|               \-9 |              \-9 |              \-9 |                \-9 |               \-9 |                \-9 |               \-9 |                \-8 |               \-8 |               \-9 |              \-9 |                \-9 |               \-9 |                \-9 |               \-9 |                    \-9 |                   \-9 |                \-9 |               \-9 |                \-9 |               \-9 |              \-9 |              \-9 |              \-9 |      12 |              \-9 |            \-9 |             \-9 |             \-9 |            10006 |      \-8 |            \-9 |     \-9 |          1.0104 | 2009 |      12 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |             \-9 |

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

*NOTE: Check in on the values here… there’s a lot more missing data
(`-9`) than I expected\! Also, it would probably be helpful to recode
`-9` as `NA` so I could take advantage of R’s built-in understandings of
missing data.*

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
# TODO: write code, look up from old MTF SAS file
```

# Random questions and notes for later:

  - Is religiosity driving the whole community attachment indicator?
  - Somewhere, data from before 1990 is formatted differently (names of
    columns), so I need to incorporate that into my code.
