# Read in data
hist_polls <- read_csv("president_polls_historical.csv") # 2020 polling data
curr_polls <- read_csv("president_polls.csv") # 2024 polling data
# Create a function to aggregate hist_polls and curr_polls data
agg_data <- function(df) {
  info <- df %>%
    filter(party == "DEM" | party == "REP") %>% # Filter out 3rd party
    pivot_wider(id_cols = c(poll_id, question_id), # Set id_cols as poll_id and question_id
                names_from = party, # Take the names from the party
                values_from = c(candidate_name, candidate_id, pct)) # Take the values from candidate names and poll pcts
  data <- df %>%
    filter(party == "DEM" | party == "REP") %>% # Filter out 3rd party
    select(-c(party, answer, candidate_id, candidate_name, pct)) %>% # Remove cols with content from poll_info
    distinct(poll_id, question_id, .keep_all = TRUE) %>% # Take only distinct poll ids and keep all cols. 
    left_join(info, by = c("poll_id", "question_id")) %>% # Left join poll_info by poll_id 
    summarise( # Select cols. 
      year = cycle, poll_id, pollster_rating_id, state, 
      pollster = display_name,
      college_poll = ifelse(grepl("College|University|U.", pollster), 1, 0),
      start_date = mdy(start_date), end_date = mdy(end_date), election_date = mdy(election_date), 
      # Calculate poll length and days_to_election as days b/w start of poll and election
      poll_length = interval(start_date, end_date) %/% days(),
      days_to_election = interval(end_date, election_date) %/% days(), 
      n = sample_size,
      # Check partisan conditions
      left_lean = ifelse(partisan == "DEM", 1, 0), left_lean = ifelse(is.na(left_lean), 0, left_lean),
      right_lean = ifelse(partisan == "REP", 1, 0), right_lean = ifelse(is.na(right_lean), 0, right_lean), 
      partisan = ifelse(is.na(partisan), 0, 1), 
      lv = ifelse(population == "lv", 1, 0), rv = ifelse(population ==  'rv', 1, 0),
      ivr = ifelse(grepl("IVR", methodology), 1, 0), live_phone = ifelse(grepl("Live Phone", methodology), 1, 0), 
      email = ifelse(grepl("Email", methodology), 1, 0), text = ifelse(grepl("IVR", methodology), 1, 0), 
      online_panel = ifelse(grepl("Online Panel", methodology), 1, 0),
      numeric_grade, transparency_score, 
      dem = candidate_name_DEM, rep = candidate_name_REP,
      dem_pct = pct_DEM, rep_pct = pct_REP, proj_margin = dem_pct - rep_pct
    )
  return(data) # Return data
}