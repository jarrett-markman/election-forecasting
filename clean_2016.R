# Read in 2016 polling data
polls16 <- read_csv("presidential_polls.csv")
data_16 <- polls16 %>% 
  filter(state != "U.S.") %>%
  summarise(
    # Create year/NA cols. to match w/ later cols
    year = 2016, poll_id = NA, pollster_rating_id = NA, 
    state, pollster, college_poll = ifelse(grepl("College|University", pollster), 1, 0),
    start_date = mdy(startdate), end_date = mdy(enddate), election_date = mdy(forecastdate),
    poll_length = interval(start_date, end_date) %/% days(), 
    days_to_election = interval(end_date, election_date) %/% days(),
    n = samplesize, 
    # Set partisan cols. as NA
    left_lean = NA, right_lean = NA, partisan = NA,
    # Create indicator vars. for likely/registered voters
    lv = ifelse(population == "lv", 1, 0), rv = ifelse(population == "rv", 1, 0),
    # Set methodology cols. as NA
    ivr = NA, live_phone = NA, email = NA, text = NA, online_panel = NA,
    numeric_grade = NA, transparency_score = NA,
    dem = "Clinton", rep = "Trump",
    dem_pct = rawpoll_clinton, rep_pct = rawpoll_trump, proj_margin = dem_pct - rep_pct
  )