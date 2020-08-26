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
      - Broader “society attachment” / faith in institutions (ex. “do
        you think voting matters?”)
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

<details>

<summary> Click to see code & notes </summary>

``` r
all_years = 1976:2018
old_years = 1976:2008
new_years = 2009:2018
```

These two helper functions come from separate R scripts.

Create a standardized list of names for variables across years.

TODO - this shouldn’t happen in this file…. once I’ve gotten a better
handle on it I’d like to do this somewhere separate and have a
definitive static file of standard names to reference.

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

</details>

## Step 1: Create a smaller database that includes only the variables I need

**First, define the list of variables we want.** The original paper
includes demographics (control variables), measures of community
attachment, and substance use.

<details>

<summary> Click to see code & notes </summary>

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

I’m potentially interested in a handful more variables, such as *X, Y, Z
(not added in
yet\!)*.

``` r
# TODO - fill in later. Make sure the variables are from the same forms or can somehow be compared against what we're already searching for...
```

</details>

<br> **Next, get data from all participants for each of the variables
above. Merge/combine by ID number and year.**

<details>

<summary> Click to see code & notes </summary> Notes:

TODO: probably worth making/modifying a helper function so that the
merges can be automatic.

Although many of the variables in can be found in file 1 and file 2, the
variables names are cleaner for substance use in file 1, so I’ve decided
to get all deomgraphics and substance use info from file 1, all
community attachment info from file 2, and combine on ID number.

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

``` r
raw_data_combined = inner_join(raw_data_file1, raw_data_file2, by = c("R'S ID-SERIAL #", "year"))

knitr::kable(raw_data_combined[100:105,])
```

| \#CIGS SMKD/30DAY | \#X ALC/30D SIPS | \#X ALC/LIF SIPS | \#X AMPH/LAST30DAY | \#X AMPH/LIFETIME | \#X COKE/LAST30DAY | \#X COKE/LIFETIME | \#X DRNK/LAST30DAY | \#X DRNK/LIFETIME | \#X LSD/LAST30DAY | \#X LSD/LIFETIME | \#X NARC/LAST30DAY | \#X NARC/LIFETIME | \#X PSYD/LAST30DAY | \#X PSYD/LIFETIME | \#X SED/BARB/LAST30DAY | \#X SED/BARB/LIFETIME | \#X TRQL/LAST30DAY | \#X TRQL/LIFETIME | \#XMJ+HS/LAST30DAY | \#XMJ+HS/LIFETIME | 5+DRK ROW/LST 2W | EVR SMK CIG,REGL | FATHR EDUC LEVEL | grade.x | MOTHR EDUC LEVEL | R HS GRADE/D=1 | R WL DO 2YR CLG | R WL DO 4YR CLG | R’S ID-SERIAL \# | R’S RACE | R’S RACE B/W/H | R’S SEX | SAMPLING WEIGHT | year | grade.y | IMP CNTRBTN SOC | IMP CRRCT INEQL | IMP LDR COMUNTY | PPL CAN B TRSTD | PPL TRY B HLPFL | PPL TRY BE FAIR | R’ATTND REL SVC | RLGN IMP R’S LF |
| ----------------: | ---------------: | ---------------: | -----------------: | ----------------: | -----------------: | ----------------: | -----------------: | ----------------: | ----------------: | ---------------: | -----------------: | ----------------: | -----------------: | ----------------: | ---------------------: | --------------------: | -----------------: | ----------------: | -----------------: | ----------------: | ---------------: | ---------------: | ---------------: | ------: | ---------------: | -------------: | --------------: | --------------: | ---------------: | -------: | -------------: | ------: | --------------: | ---: | ------: | --------------: | --------------: | --------------: | --------------: | --------------: | --------------: | --------------: | --------------: |
|                 1 |                1 |                5 |                  1 |                 1 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 1 |                  1 |                 1 |                      1 |                     1 |                  1 |                 1 |                  1 |                 1 |                1 |                1 |                7 |      12 |                1 |              4 |               1 |               3 |            10100 |      \-8 |              3 |       1 |          1.4732 | 2009 |      12 |               3 |               2 |               2 |               1 |               1 |               1 |             \-9 |             \-9 |
|                 4 |                3 |                7 |                  1 |                 1 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 1 |                  1 |                 1 |                      1 |                     1 |                  1 |                 1 |                  1 |                 1 |                2 |                5 |                3 |      12 |                3 |              2 |               3 |               3 |            10101 |      \-8 |              2 |       1 |          1.3784 | 2009 |      12 |               2 |               2 |               3 |               2 |               1 |               1 |               4 |               3 |
|                 1 |                1 |                3 |                  1 |                 1 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 2 |                  1 |                 1 |                      1 |                     1 |                  1 |                 1 |                  1 |                 1 |                1 |                1 |                2 |      12 |                4 |              6 |               3 |               3 |            10102 |      \-8 |              2 |       2 |          2.5084 | 2009 |      12 |               3 |               3 |               2 |               1 |               2 |               2 |               2 |               3 |
|                 4 |                2 |                7 |                  1 |                 1 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 1 |                  1 |                 2 |                      1 |                     1 |                  1 |                 1 |                  4 |                 7 |                2 |                5 |                3 |      12 |                4 |              6 |               1 |               3 |            10103 |      \-8 |              2 |       2 |          0.3013 | 2009 |      12 |               3 |               4 |               4 |               1 |               2 |               1 |             \-9 |             \-9 |
|                 1 |                1 |                1 |                \-9 |               \-9 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 1 |                  1 |                 1 |                      1 |                     1 |                  1 |                 1 |                  1 |                 1 |                1 |                1 |                3 |      12 |                3 |              4 |               3 |               2 |            10104 |      \-8 |            \-9 |       2 |          1.4105 | 2009 |      12 |               3 |               3 |               2 |               1 |               2 |               1 |               4 |               4 |
|                 1 |                2 |                4 |                  1 |                 1 |                  1 |                 1 |                \-8 |               \-8 |                 1 |                1 |                  1 |                 3 |                  1 |                 1 |                      1 |                     1 |                  1 |                 1 |                  1 |                 2 |                2 |                2 |                3 |      12 |                3 |              9 |               2 |               4 |            10105 |      \-8 |              2 |       2 |          1.0390 | 2009 |      12 |               2 |               1 |               2 |               1 |               1 |               2 |               2 |               2 |

``` r
#summary(raw_data_combined)
```

</details>

## Step 2: Recode, create indicators/aggregate values, etc.

What I’ve done so far:

1.  Create social trust score
2.  Create social responsibility score
3.  Create religiosity score
4.  Combine substance use levels where appropriate (to make `other
    illicit drugs` category)
5.  Combine momEd and dadEd into SES
6.  Combine 2yr and 4yr college graduation expectations
7.  Recode all `-9` as `NA` to take advantage of R’s built-in handling
    of missing data

Haven’t done yet:

8.  Create dummy variable for each year of the survey, to account for
    historical trends. (Note: in original paper they did this and then
    found the dummy variables to not be significant. But it’s worth it
    for me to check, both for 2009-2018 and if I add in any new
    predictors or outcoems.)
9.  Dealt with missing data -\> Impute? Throw out any participants who
    have any missing data?
10. Make a definitive decision on how to handle the `race` variable
    *NOTE - look to example from lab code\!*

<details>

<summary>Click to see the data wrangling
code</summary>

``` r
# TODO - remove 'NO_MISSING' versions of community attachment scores if I decide that's the right approach (currently not selected)

recoded = raw_data_combined %>% 
  na_if(., -9) %>% # This is how MTF codes missing values
  na_if(., -8) %>% # This is how my code (and sometimes MTF) codes questions that weren't asked to a participant
  
  # Values we can use as-is without mutating:
  rename(., `High school grades` = `R HS GRADE/D=1`,
         `Cigarettes - Lifetime` = `EVR SMK CIG,REGL`,
         `Cigarettes - 30 Day` = `#CIGS SMKD/30DAY`,
         `Binge Drinking` = `5+DRK ROW/LST 2W`,
         `Marijuana/Hashish – Lifetime` = `#XMJ+HS/LIFETIME`,
         `Marijuana/Hashish - 30 Day` = `#XMJ+HS/LAST30DAY`,
         `Cocaine - Lifetime` = `#X COKE/LIFETIME`,
         `Cocaine - 30 Day` = `#X COKE/LAST30DAY`,
         `Amphetamines - Lifetime` = `#X AMPH/LIFETIME`,
         `Amphetamines - 30 Day` = `#X AMPH/LAST30DAY`,
         `Barbiturates - Lifetime` = `#X SED/BARB/LIFETIME`,
         `Barbiturates - 30 Day` = `#X SED/BARB/LAST30DAY`,
         `Tranquilizers - Lifetime` = `#X TRQL/LIFETIME`,
         `Tranquilizers - 30 Day` = `#X TRQL/LAST30DAY`,
         `Narcotics - Lifetime` = `#X NARC/LIFETIME`,
         `Narcotics - 30 Day` = `#X NARC/LAST30DAY`
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
         ) %>% 
  
  # Substance use questions - renamed and recoded
  mutate(.,
         `Hallucinogens - Lifetime` = pmax(`#X LSD/LIFETIME`, `#X PSYD/LIFETIME`, na.rm = TRUE), # Double check these are correct
         `Hallucinogens - 30 Day` = pmax(`#X LSD/LAST30DAY`, `#X PSYD/LAST30DAY`, na.rm = TRUE),
         `Alcohol - Lifetime` = case_when(
           year <= 2016 ~ `#X ALC/LIF SIPS`,
           year > 2016 ~ `#X DRNK/LIFETIME`),
         `Alcohol - 30 Day` = case_when(
           year <= 2016 ~ `#X ALC/30D SIPS`,
           year > 2016 ~ `#X DRNK/LAST30DAY`),
         `Other illicit drugs – Lifetime` = as.factor(case_when(
           `Hallucinogens - Lifetime` > 1 | `Cocaine - Lifetime` > 1 |
            `Amphetamines - Lifetime` > 1 | `Barbiturates - Lifetime` > 1 |
            `Tranquilizers - Lifetime` > 1 | `Narcotics - Lifetime` > 1 ~ "Yes", # If their answer was greater than "none" for any illicit drug, code this as "yes"
           TRUE ~ "No")), # Otherwise, code as "No" --> could instead be 1/0
         `Other illicit drugs – 30 Day` = as.factor(case_when(
           `Hallucinogens - 30 Day` > 1 | `Cocaine - 30 Day` > 1 |
            `Amphetamines - 30 Day` > 1 | `Barbiturates - 30 Day` > 1 |
            `Tranquilizers - 30 Day` > 1 | `Narcotics - 30 Day` > 1 ~ "Yes",
           TRUE ~ "No"))
         ) %>% 
  
  # Rearrange columns, and get rid of any we don't need any more
  select(., `R'S ID-SERIAL #`, `SAMPLING WEIGHT`,
         year, Sex, Race, `High school grades`, `College aspirations`, `Parents' education`,
         `Social Trust`, `Social Responsibility`, `Religiosity`,
         `Cigarettes - Lifetime`,
         `Cigarettes - 30 Day`,
         `Alcohol - Lifetime`,
         `Alcohol - 30 Day`,
         `Binge Drinking`,
         `Marijuana/Hashish – Lifetime`,
         `Marijuana/Hashish - 30 Day`,
         `Other illicit drugs – Lifetime`,
         `Other illicit drugs – 30 Day`,
         `Hallucinogens - Lifetime`,
         `Hallucinogens - 30 Day`,
         `Cocaine - Lifetime`,
         `Cocaine - 30 Day`,
         `Amphetamines - Lifetime`,
         `Amphetamines - 30 Day`,
         `Barbiturates - Lifetime`,
         `Barbiturates - 30 Day`,
         `Tranquilizers - Lifetime`,
         `Tranquilizers - 30 Day`,
         `Narcotics - Lifetime`,
         `Narcotics - 30 Day`,
         )
```

</details>

<br> Here’s a random snapshot of what the data looks like at this
point:

| R’S ID-SERIAL \# | SAMPLING WEIGHT | year | Sex    | Race          | High school grades | College aspirations  | Parents’ education | Social Trust | Social Responsibility | Religiosity | Cigarettes - Lifetime | Cigarettes - 30 Day | Alcohol - Lifetime | Alcohol - 30 Day | Binge Drinking | Marijuana/Hashish – Lifetime | Marijuana/Hashish - 30 Day | Other illicit drugs – Lifetime | Other illicit drugs – 30 Day | Hallucinogens - Lifetime | Hallucinogens - 30 Day | Cocaine - Lifetime | Cocaine - 30 Day | Amphetamines - Lifetime | Amphetamines - 30 Day | Barbiturates - Lifetime | Barbiturates - 30 Day | Tranquilizers - Lifetime | Tranquilizers - 30 Day | Narcotics - Lifetime | Narcotics - 30 Day |
| ---------------: | --------------: | ---: | :----- | :------------ | -----------------: | :------------------- | :----------------- | -----------: | --------------------: | ----------: | --------------------: | ------------------: | -----------------: | ---------------: | -------------: | ---------------------------: | -------------------------: | :----------------------------- | :--------------------------- | -----------------------: | ---------------------: | -----------------: | ---------------: | ----------------------: | --------------------: | ----------------------: | --------------------: | -----------------------: | ---------------------: | -------------------: | -----------------: |
|            10100 |          1.4732 | 2009 | Male   | Hispanic      |                  4 | 4-year college plans | 1                  |     1.000000 |              2.333333 |         NaN |                     1 |                   1 |                  5 |                1 |              1 |                            1 |                          1 | No                             | No                           |                        1 |                      1 |                  1 |                1 |                       1 |                     1 |                       1 |                     1 |                        1 |                      1 |                    1 |                  1 |
|            10101 |          1.3784 | 2009 | Male   | White         |                  2 | 4-year college plans | 3                  |     1.333333 |              2.333333 |   0.8599165 |                     5 |                   4 |                  7 |                3 |              2 |                            1 |                          1 | No                             | No                           |                        1 |                      1 |                  1 |                1 |                       1 |                     1 |                       1 |                     1 |                        1 |                      1 |                    1 |                  1 |
|            10102 |          2.5084 | 2009 | Female | White         |                  6 | 4-year college plans | 4                  |     1.666667 |              2.666667 | \-0.0332074 |                     1 |                   1 |                  3 |                1 |              1 |                            1 |                          1 | Yes                            | No                           |                        1 |                      1 |                  1 |                1 |                       1 |                     1 |                       1 |                     1 |                        1 |                      1 |                    2 |                  1 |
|            10103 |          0.3013 | 2009 | Female | White         |                  6 | 4-year college plans | 4                  |     1.333333 |              3.666667 |         NaN |                     5 |                   4 |                  7 |                2 |              2 |                            7 |                          4 | Yes                            | No                           |                        2 |                      1 |                  1 |                1 |                       1 |                     1 |                       1 |                     1 |                        1 |                      1 |                    1 |                  1 |
|            10104 |          1.4105 | 2009 | Female | Other/missing |                  4 | 2-year college plans | 3                  |     1.333333 |              2.666667 |   1.3079516 |                     1 |                   1 |                  1 |                1 |              1 |                            1 |                          1 | No                             | No                           |                        1 |                      1 |                  1 |                1 |                      NA |                    NA |                       1 |                     1 |                        1 |                      1 |                    1 |                  1 |
|            10105 |          1.0390 | 2009 | Female | White         |                  9 | 4-year college plans | 3                  |     1.333333 |              1.666667 | \-0.4812425 |                     2 |                   1 |                  4 |                2 |              2 |                            2 |                          1 | Yes                            | No                           |                        1 |                      1 |                  1 |                1 |                       1 |                     1 |                       1 |                     1 |                        1 |                      1 |                    3 |                  1 |

<details>

<summary> Click to expand summary data from this table </summary> This
has ugly formatting :( I hope to find an R tool that makes this easier
to parse, like “proc freq” in SAS\!

``` r
summary(recoded)
```

    ##  R'S ID-SERIAL # SAMPLING WEIGHT        year          Sex       
    ##  Min.   :10001   Min.   :0.07635   Min.   :2009   Female:10765  
    ##  1st Qu.:10645   1st Qu.:0.61495   1st Qu.:2011   Male  :10000  
    ##  Median :11237   Median :0.85074   Median :2013   NA's  : 2497  
    ##  Mean   :11244   Mean   :0.99824   Mean   :2013                 
    ##  3rd Qu.:11834   3rd Qu.:1.22205   3rd Qu.:2016                 
    ##  Max.   :12910   Max.   :5.80390   Max.   :2018                 
    ##                                                                 
    ##             Race       High school grades           College aspirations
    ##  Black        : 2552   Min.   :1.000      2-year college plans: 1773   
    ##  Hispanic     : 3531   1st Qu.:5.000      4-year college plans:16936   
    ##  Other/missing: 5300   Median :7.000      No college plans    : 1478   
    ##  White        :11879   Mean   :6.654      NA's                : 3075   
    ##                        3rd Qu.:8.000                                   
    ##                        Max.   :9.000                                   
    ##                        NA's   :2918                                    
    ##  Parents' education  Social Trust   Social Responsibility  Religiosity    
    ##  1   : 561          Min.   :1.000   Min.   :1.000         Min.   :-1.399  
    ##  2   :1205          1st Qu.:1.333   1st Qu.:2.000         1st Qu.:-0.928  
    ##  3   :3600          Median :1.667   Median :2.667         Median :-0.033  
    ##  4   :4035          Mean   :1.725   Mean   :2.656         Mean   : 0.000  
    ##  5   :6451          3rd Qu.:2.000   3rd Qu.:3.333         3rd Qu.: 0.860  
    ##  6   :4281          Max.   :3.000   Max.   :4.000         Max.   : 1.327  
    ##  NA's:3129          NA's   :559     NA's   :518           NA's   :7316    
    ##  Cigarettes - Lifetime Cigarettes - 30 Day Alcohol - Lifetime Alcohol - 30 Day
    ##  Min.   :1.000         Min.   :1.000       Min.   :1.000      Min.   :1.000   
    ##  1st Qu.:1.000         1st Qu.:1.000       1st Qu.:1.000      1st Qu.:1.000   
    ##  Median :1.000         Median :1.000       Median :3.000      Median :1.000   
    ##  Mean   :1.674         Mean   :1.284       Mean   :3.676      Mean   :1.806   
    ##  3rd Qu.:2.000         3rd Qu.:1.000       3rd Qu.:6.000      3rd Qu.:2.000   
    ##  Max.   :5.000         Max.   :7.000       Max.   :7.000      Max.   :7.000   
    ##  NA's   :1138          NA's   :1124        NA's   :1224       NA's   :1343    
    ##  Binge Drinking  Marijuana/Hashish – Lifetime Marijuana/Hashish - 30 Day
    ##  Min.   :1.000   Min.   :1.000                Min.   :1.000             
    ##  1st Qu.:1.000   1st Qu.:1.000                1st Qu.:1.000             
    ##  Median :1.000   Median :1.000                Median :1.000             
    ##  Mean   :1.321   Mean   :2.707                Mean   :1.707             
    ##  3rd Qu.:1.000   3rd Qu.:4.000                3rd Qu.:1.000             
    ##  Max.   :6.000   Max.   :7.000                Max.   :7.000             
    ##  NA's   :1543    NA's   :1357                 NA's   :1432              
    ##  Other illicit drugs – Lifetime Other illicit drugs – 30 Day
    ##  No :18816                      No :21779                   
    ##  Yes: 4446                      Yes: 1483                   
    ##                                                             
    ##                                                             
    ##                                                             
    ##                                                             
    ##                                                             
    ##  Hallucinogens - Lifetime Hallucinogens - 30 Day Cocaine - Lifetime
    ##  Min.   :1.000            Min.   :1.000          Min.   :1.000     
    ##  1st Qu.:1.000            1st Qu.:1.000          1st Qu.:1.000     
    ##  Median :1.000            Median :1.000          Median :1.000     
    ##  Mean   :1.151            Mean   :1.042          Mean   :1.086     
    ##  3rd Qu.:1.000            3rd Qu.:1.000          3rd Qu.:1.000     
    ##  Max.   :7.000            Max.   :7.000          Max.   :7.000     
    ##  NA's   :1440             NA's   :1439           NA's   :2790      
    ##  Cocaine - 30 Day Amphetamines - Lifetime Amphetamines - 30 Day
    ##  Min.   :1.000    Min.   :1.00            Min.   :1.00         
    ##  1st Qu.:1.000    1st Qu.:1.00            1st Qu.:1.00         
    ##  Median :1.000    Median :1.00            Median :1.00         
    ##  Mean   :1.019    Mean   :1.23            Mean   :1.06         
    ##  3rd Qu.:1.000    3rd Qu.:1.00            3rd Qu.:1.00         
    ##  Max.   :7.000    Max.   :7.00            Max.   :7.00         
    ##  NA's   :2787     NA's   :1891            NA's   :1884         
    ##  Barbiturates - Lifetime Barbiturates - 30 Day Tranquilizers - Lifetime
    ##  Min.   :1.000           Min.   :1.000         Min.   :1.000           
    ##  1st Qu.:1.000           1st Qu.:1.000         1st Qu.:1.000           
    ##  Median :1.000           Median :1.000         Median :1.000           
    ##  Mean   :1.116           Mean   :1.029         Mean   :1.148           
    ##  3rd Qu.:1.000           3rd Qu.:1.000         3rd Qu.:1.000           
    ##  Max.   :7.000           Max.   :7.000         Max.   :7.000           
    ##  NA's   :2060            NA's   :2054          NA's   :2280            
    ##  Tranquilizers - 30 Day Narcotics - Lifetime Narcotics - 30 Day
    ##  Min.   :1.000          Min.   :1.000        Min.   :1.000     
    ##  1st Qu.:1.000          1st Qu.:1.000        1st Qu.:1.000     
    ##  Median :1.000          Median :1.000        Median :1.000     
    ##  Mean   :1.035          Mean   :1.235        Mean   :1.044     
    ##  3rd Qu.:1.000          3rd Qu.:1.000        3rd Qu.:1.000     
    ##  Max.   :7.000          Max.   :7.000        Max.   :7.000     
    ##  NA's   :2268           NA's   :2498         NA's   :2494

``` r
#library(Hmisc)
#Hmisc::describe(recoded)
#glimpse(recoded)
# could do transmute to get rid of old columns! it only keeps the new ones you define
```

</details>

## Step 3: Build regression models

Note: First I need to check assumptions\! (but I’m skipping that step
for now) Also, those assumptions might change as I add in new variables,
or analyze different sets of years, so this isn’t just a one-and-done
process. One thing I immediately notice is that in the original paper,
marijuana, cigarettes, and alcohol use were all coded as continuous and
used as the outcomes for linear regression, even though some are heavily
right-skewed. “Other illicit drugs” is a binary outcome for logistic
regression.

# Random questions and notes for later:

**About the findings/context:**

1.  Is religiosity driving the whole community attachment indicator?

**About the data & R:**

1.  Somewhere, data from before 1990 is formatted differently (the names
    of the columns), so I need to incorporate that into my code if I
    want to recreate the analysis from the original years, rather than
    just update it for recent years
2.  Do I need to code things as dummy variables, or does R have a way to
    do regression without? –\> Related: should everything be factors?
3.  When averaging things (like for social trust score) is it ok if
    you’re missing one of the 3 things to average?
