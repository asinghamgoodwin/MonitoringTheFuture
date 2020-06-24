library(tidyverse)

plot_prevalence_over_time = function(dataset = dataset,
                                     variable = variable,
                                     yes_codes = yes_codes,
                                     no_codes = no_codes,
                                     title = title) {
  
  # get (weighted) counts by year for our variable of interest, split up by the codes designated in the input
  counts = dataset %>% 
    mutate(.,
           matches_criteria = 
             case_when(!!sym(variable) %in% yes_codes ~ "yes",
                       !!sym(variable) %in% no_codes ~ "no",
                       TRUE ~ "leave out")
    ) %>% 
    group_by(., year) %>% 
    count(., matches_criteria, wt = `SAMPLING WEIGHT`)
  
  # get the "percent yes" for each year/grade group.
  # the pivot_wider gets us a DB where each row represents one year, and has columns for yes, no, leave out, and then our calculated percent_yes 
  percent_yes_db = counts %>%
    pivot_wider(., names_from = matches_criteria, values_from = n) %>%
    mutate(.,
           percent_yes = (yes / (yes + no))*100
    ) %>%
    select(., year, percent_yes) %>%
    ungroup(.)
  
  plot = ggplot(percent_yes_db,
                aes(x = year, y = percent_yes)
  ) +
    geom_line() +
    geom_point() +
    labs(
      title = title,
      x = "Year",
      y = "Prevalence"
    ) +
    geom_text(label = round(percent_yes_db$percent_yes, 1), nudge_x = 0, nudge_y = .3)
  
  plot
}