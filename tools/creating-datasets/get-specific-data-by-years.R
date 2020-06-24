library(tidyverse)
require(haven) # lets us read SAS files
require(stringr) # lets us subset a string using negative numbers

get_specific_data_by_years = function(path = path,
                                      file_number,
                                      years = years,
                                      mapping = mapping,
                                      variables_to_include = variables_to_include) {
  all_years = tibble()
  
  for (this_year in years) {
    # this depends on what file the questions are in. For now, assume everything is in file 1.
    file_name = str_c(path, "y", this_year, "_", file_number, ".sas7bdat")
    
    relevant_variables_and_years = filter(mapping,
                                          year == this_year & helpful_name %in% variables_to_include)
    original_variable_names = relevant_variables_and_years$variable_name
    rename_vector = original_variable_names
    names(rename_vector) = relevant_variables_and_years$helpful_name
    
    excluded = setdiff(variables_to_include, relevant_variables_and_years$helpful_name)
    
    # What's happening in these piped functions below:
    # 1. Select all of the variables from our mapping table that existed for this year of the survey
    # 2. Add in (mutate) columns for year and grade
    # 3. rename varables from MTF names to helpful_names
    this_year_data = read_sas(data_file = file_name) %>% 
      select(.,
             one_of(original_variable_names)
      ) %>%
      mutate(.,
             year = this_year,
             grade = 12
      ) %>%
      rename(.,
             !!rename_vector)
    
    # 4. add in any variables that were excluded that year as -8 (but was specfied by user to variables_to_include),
    # ...so that the datasets can be stacked later
    # QUESTON: is there a dplyr way to do this, not in a for loop?
    for (excluded_var in excluded) {
      this_year_data = mutate(this_year_data, !!excluded_var := -8)
    }
    
    # QUESTION: is there a better way to combine data frames vertically, by comlumn name??
    # need to sort alphabetically before binding rows
    this_year_data = this_year_data %>% select(sort(tidyselect::peek_vars()))
    
    # QUESTON: will I have trouble with factors?
    all_years = bind_rows(all_years, this_year_data)
  }
  
  all_years
}