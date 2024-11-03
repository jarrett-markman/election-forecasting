# Read to raw-polls data
raw_polls <- read_csv("raw-polls.csv")
raw_polls <- raw_polls %>% 
  filter(type_simple == "Pres-G" & location != "US") %>% # Filter out primary (and not presidential) polls
  summarise(
    year, poll_id, pollster_rating_id,
    state = location, pollster, college_poll = ifelse(grepl("College|University", pollster), 1, 0),
    # Set poll_length and start_date as NA 
    start_date = NA, 
    end_date = mdy(polldate), election_date = mdy(electiondate), 
    poll_length = NA, 
    days_to_election = interval(end_date, election_date) %/% days(),
    n = samplesize,
    left_lean = ifelse(partisan == "D", 1, 0), right_lean = ifelse(partisan == "R", 1, 0),
    partisan = ifelse(is.na(partisan), 0, 1), 
    # Set voter pop. and methodology, scores as NAs
    lv = NA, rv = NA, ivr = NA, live_phone = NA, email = NA, text = NA, online_panel = NA,
    numeric_grade = NA, transparency_score = NA, 
    dem = cand1_name, rep = cand2_name, dem_pct = cand1_pct, rep_pct = cand2_pct, proj_margin = dem_pct - rep_pct, 
    real_dem_pct = cand1_actual, real_rep_pct = cand2_actual, 
    winner = ifelse(real_dem_pct > real_rep_pct, 1, 0)
  ) %>% 
  select(-c(real_dem_pct, real_rep_pct)) %>%
  filter(year != 2016) # Remove obs from 2016