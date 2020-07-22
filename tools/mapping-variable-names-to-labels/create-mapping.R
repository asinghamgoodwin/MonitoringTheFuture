create_standard_helpful_name = function(unedited_name = unedited_name) {
  # everything to uppercase
  helpful_name = str_to_upper(unedited_name)
  
  # take away alphanumerics at the beginning if they fit the pattern ###C##CC
  helpful_name = str_remove(helpful_name, "^[0-9]{3}C[0-9]{2}[A-Z]{2}")
  
  # remove anything before a delineation character like : | ; ! and (R)
  #    (might be blank before special char, from removal in line above)
  helpful_name = str_remove(helpful_name, "^.*[:|\\||;|!]\\s*")
  helpful_name = str_remove(helpful_name, "[A-z0-9]+\\(R\\)")
  
  # for the specific format that goes `BYyy ALPHANUM varname` strip to just varname
  helpful_name = str_remove(helpful_name, "^BY[0-9]{2} [A-z0-9]+ ")
  
  # for the one weird case in 1997 where `= "caseid"` was left in the name
  helpful_name = str_remove(helpful_name, '\\= \\"')
  helpful_name = str_remove(helpful_name, '\\"$')
  
  # 'H'/ "H"/ and H/ are used interchangeably, so convert everything to no quotes
  helpful_name = str_replace(helpful_name, "\\'H\\'\\/", "H/")
  helpful_name = str_replace(helpful_name, '\\"H\\"\\/', "H/")
  
  # strip extra spaces from around equal signs
  helpful_name = str_replace_all(helpful_name, " = ", "=")
  
  # standardize the way that /LAST 30 DAYS and /LAST 12 MO is written wrt. spaces and cutting off DAY
  helpful_name = str_replace(helpful_name, "\\/LAST ", "\\/LAST")
  helpful_name = str_replace(helpful_name, "30 DA", "30DA")
  helpful_name = str_replace(helpful_name, "30D[A]?$", "30DAY")
  helpful_name = str_replace(helpful_name, "12 MO", "12MO")
  helpful_name = str_replace(helpful_name, "12M[O]?", "12MO")
  helpful_name = str_replace(helpful_name, "LIFETIM[E]?", "LIFETIME")
  helpful_name = str_replace(helpful_name, "SED\\/BARB\\/30DAY", "SED\\/BARB\\/LAST30DAY")
  helpful_name = str_replace(helpful_name, "SED\\/BARB\\/12MO", "SED\\/BARB\\/LAST12MO")
  helpful_name = str_replace(helpful_name, "SED\\/BARB\\/LIFE(TIME)?", "SED\\/BARB\\/LIFETIME")
  
  # standardize the way that MSA/NON-MSA = 0 etc. is written
  helpful_name = str_replace_all(helpful_name, "SMSA", "MSA")
  helpful_name = str_replace(helpful_name, "MSA(=1)?\\/NON[ |\\-]MSA", "MSA/NON-MSA")
  helpful_name = str_replace(helpful_name, "072 LARGE MSA=1/NOT=0", "LARGE MSA=1/NOT=0")
  
  # standardize the way that a bunch more random things are written
  helpful_name = str_replace(helpful_name, "R XPCTS BE? OFFCR", "R XPCTS BE OFFCR")
  helpful_name = str_replace(helpful_name, "R'S HSHLD MOTHE?R", "R'S HSHLD MOTHER")
  helpful_name = str_replace(helpful_name, "R'S HSHLD FATHE?R", "R'S HSHLD FATHER")
  helpful_name = str_replace(helpful_name, "R[ |']ATTND", "R'ATTND")
  helpful_name = str_replace(helpful_name, "R[ |']POL", "R'POL")
  helpful_name = str_replace(helpful_name, "RLGN IMP R'?S LF", "RLGN IMP R'S LF")
  helpful_name = str_replace(helpful_name, "YEAR OF ADMIN.*", "YEAR OF ADMIN")
  
  helpful_name = str_replace(helpful_name, "R'S HSHLD SPOUSE?", "R'S HSHLD SPOUSE")
  helpful_name = str_replace(helpful_name, "R'S HSHLD RELTVS?", "R'S HSHLD RELTVS")
  helpful_name = str_replace(helpful_name, "R'S HSHLD NONRLT?", "R'S HSHLD NONRLT")
  helpful_name = str_replace(helpful_name, "R'S HSHLD GRPR[T|N][T|N]?", "R'S HSHLD GRPRNT")
  helpful_name = str_replace(helpful_name, "R'S HSHLD CHLDRN?", "R'S HSHLD CHLDRN")
  helpful_name = str_replace(helpful_name, "SCH REG-4 CAT", "SCHL RGN-4 CAT")
  
  # if something starts with RS, convert to R'S.
  helpful_name = str_replace(helpful_name, "^R[S|s]", "R'S")
  
  # for two years, respondent ID was listed as ARCHIVE ID. Other years there was an extra space. Standardize
  helpful_name = str_replace(helpful_name, "ARCHIVE ID|R'S  ID-SERIAL #", "R'S ID-SERIAL #")
  
  # at some point, sampling weight switched to archive weight 
  helpful_name = str_replace(helpful_name, "ARCHIVE WEIGHT", "SAMPLING WEIGHT")
  
  
  # FILE 4 / FORM 3 SPECIFIC STUFF
  helpful_name = str_replace(helpful_name, "GD JB COLLG ?[\\+|&|/] ?UNIV", "GD JB COLLG&UNIV")
  helpful_name = str_replace(helpful_name, "GD JB PRES ?[\\+|&|/] ?ADMIN", "GD JB PRES&ADMIN")
  helpful_name = str_replace(helpful_name, "R'POL BLF RADCL", "R'S POL BLF RADCL")
  
  # trim whitespace off of either end
  helpful_name = str_trim(helpful_name)
  
  helpful_name
}

create_mapping = function(path = path,
                          year = year,
                          file_number = file_number
) {
  
  mapping = tibble(
    helpful_name = character(),
    unedited_name = character(),
    year = numeric(),
    variable_name = character(),
    file_number = numeric()
  )
  
  file_name = str_c(path, "y", year, "_", file_number,".sas7bdat")
  this_year_data = read_sas(data_file = file_name)
  
  for (col in 1:ncol(this_year_data)) {
    unedited_name = attr(this_year_data[[col]], "label")
    helpful_name = create_standard_helpful_name(unedited_name)
    
    mapping = add_row(mapping,
                      helpful_name = helpful_name,
                      unedited_name = unedited_name,
                      year = year,
                      variable_name = colnames(this_year_data)[col],
                      file_number = file_number
    )
  }
  mapping
}