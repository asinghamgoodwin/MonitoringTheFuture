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

## Step 0. Prepare helper functions, constants, etc.

Luckily, everything in the base set of community attachment measures,
substance use, and most covariates are asked in form 1 (file 2). I’ll
also need to pull some basic demographics from the core form (file 1).

``` r
all_years = 1976:2018
old_years = 1976:2008
new_years = 2009:2018
```

``` r
source('tools/mapping-variable-names-to-labels/create-mapping.R', local = knitr::knit_global())
```

\#code=xfun::read\_utf8(‘tools/mapping-variable-names-to-labels/create-mapping.R’),
include=FALSE}

\#code=xfun::read\_utf8(‘tools/creating-datasets/get-specific-data-by-years.R’),
include=FALSE}

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

## Step 1: Creating a smaller database that includes only the variables I need

First, define the list of variables we want. These are from the original
paper:

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

These are new variables I’m potentially interested
in:

``` r
# TODO - fill in later. Make sure the variables are from the same forms or can somehow be compared against what we're already searching for...
```

Get data from all participants for each of the variables above.
Merge/combine by ID number and year.

*TODO: probably worth making/modifying a helper function so that the
merges can be automatic.*

Notes:

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

``` r
raw_data_combined = inner_join(raw_data_file1, raw_data_file2, by = c("R'S ID-SERIAL #", "year"))
```

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
