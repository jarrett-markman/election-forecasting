# Scrape Wikipedia for 2016 election results
url <- "https://en.wikipedia.org/wiki/2016_United_States_presidential_election#Results_by_state"
response <- GET(url)
html_content <- read_html(response)
wiki <- html_content %>%
  html_nodes(".wikitable") %>% html_table(header = TRUE)
df_2016 <- as.data.frame(wiki[[16]])
res_2016 <- df_2016[, c(1, 3, 6)] %>% 
  dplyr::slice(-c(1, 58, 59)) %>%
  summarise(state = `@supports(writing-mode:vertical-rl){.mw-parser-output .ts-vertical-header{line-height:1;max-width:1em;padding:0.4em;vertical-align:bottom;width:1em}html.client-js .mw-parser-output .sortable:not(.jquery-tablesorter) .ts-vertical-header:not(.unsortable),html.client-js .mw-parser-output .ts-vertical-header.headerSort{background-position:50%.4em;padding-right:0.4em;padding-top:21px}.mw-parser-output .ts-vertical-header.is-valign-top{vertical-align:top}.mw-parser-output .ts-vertical-header.is-valign-middle{vertical-align:middle}.mw-parser-output .ts-vertical-header.is-normal{font-weight:normal}.mw-parser-output .ts-vertical-header>*{display:inline-block;transform:rotate(180deg);writing-mode:vertical-rl}@supports(writing-mode:sideways-lr){.mw-parser-output .ts-vertical-header>*{transform:none;writing-mode:sideways-lr}}}State ordistrict`,
            real_dem_pct = `Hillary ClintonDemocratic`,
            real_dem_pct = as.numeric(gsub("%", "", real_dem_pct)),
            real_rep_pct = `Donald TrumpRepublican`,
            real_rep_pct = as.numeric(gsub("%", "", real_rep_pct))) %>%
  mutate(
    winner = ifelse(real_dem_pct > real_rep_pct, 1, 0), # Create winner col (initialize winner as dem)
    # Modify state variables
    state = gsub("†", "", state),
    state = gsub("\\[.*?\\]", "", state),
    state = trimws(state), 
    state = case_when( # Use case_when to modfy wikipedia syntax for CDs
      state == "ME-1Tooltip Maine's 1st congressional district" ~ "Maine CD-1",
      state == "ME-2Tooltip Maine's 2nd congressional district" ~ "Maine CD-2",
      state == "NE-1Tooltip Nebraska's 1st congressional district" ~ "Nebraska CD-1",
      state == "NE-2Tooltip Nebraska's 2nd congressional district" ~ "Nebraska CD-2",
      state == "NE-3Tooltip Nebraska's 3rd congressional district" ~ "Nebraska CD-3",
      TRUE ~ state),
    year = 2016
  ) %>% select(-c(real_dem_pct, real_rep_pct)) # Remove pcts
# Scrape Wikipedia for 2020 election results
url <- "https://en.wikipedia.org/wiki/2020_United_States_presidential_election#Results"
response <- GET(url)
html_content <- read_html(response)
wiki <- html_content %>% 
  html_nodes(".wikitable") %>% html_table(header = TRUE)
# Take the 12th listed item from res_2020, store it as a data frame
df_2020 <- as.data.frame(wiki[[12]]) 
res_2020 <- df_2020[, c(1, 3, 6)] %>% # Subset state/dem pct/rep pct cols
  dplyr::slice(-c(1, 58, 59)) %>% # Use slice to deselect rows
  summarise( # Rename cols and change data types
    state = `@supports(writing-mode:vertical-rl){.mw-parser-output .ts-vertical-header{line-height:1;max-width:1em;padding:0.4em;vertical-align:bottom;width:1em}html.client-js .mw-parser-output .sortable:not(.jquery-tablesorter) .ts-vertical-header:not(.unsortable),html.client-js .mw-parser-output .ts-vertical-header.headerSort{background-position:50%.4em;padding-right:0.4em;padding-top:21px}.mw-parser-output .ts-vertical-header.is-valign-top{vertical-align:top}.mw-parser-output .ts-vertical-header.is-valign-middle{vertical-align:middle}.mw-parser-output .ts-vertical-header.is-normal{font-weight:normal}.mw-parser-output .ts-vertical-header>*{display:inline-block;transform:rotate(180deg);writing-mode:vertical-rl}@supports(writing-mode:sideways-lr){.mw-parser-output .ts-vertical-header>*{transform:none;writing-mode:sideways-lr}}}State ordistrict`,
    real_dem_pct = `Biden/HarrisDemocratic`,
    real_dem_pct = as.numeric(gsub("%", "", real_dem_pct)),
    real_rep_pct = `Trump/PenceRepublican`,
    real_rep_pct = as.numeric(gsub("%", "", real_rep_pct))
  ) %>%
  mutate(
    winner = ifelse(real_dem_pct > real_rep_pct, 1, 0), # Create winner col (initialize winner as dem)
    # Modify state variables
    state = gsub("†", "", state),
    state = gsub("\\[.*?\\]", "", state),
    state = trimws(state), 
    state = case_when( # Use case_when to modfy wikipedia syntax for CDs
      state == "ME-1Tooltip Maine's 1st congressional district" ~ "Maine CD-1",
      state == "ME-2Tooltip Maine's 2nd congressional district" ~ "Maine CD-2",
      state == "NE-1Tooltip Nebraska's 1st congressional district" ~ "Nebraska CD-1",
      state == "NE-2Tooltip Nebraska's 2nd congressional district" ~ "Nebraska CD-2",
      state == "NE-3Tooltip Nebraska's 3rd congressional district" ~ "Nebraska CD-3",
      TRUE ~ state),
    year = 2020
  ) %>% select(-c(real_dem_pct, real_rep_pct)) # Remove pcts