# For 2020
train <- agg_data(hist_polls) %>%
  filter(!is.na(state) & (dem == "Joe Biden" & rep == "Donald Trump")) # Filter candidates only for the 2020 election
train <- bind_rows(data_16, train) # Use bind_rows to combine all polling data
election_res <- bind_rows(res_2016, res_2020) # Bind rows for scraped wikipedia results
train_df <- left_join(train, election_res, by = c("state", "year")) # Join train data with election results data 
train_df <- bind_rows(raw_polls, train_df) # Bind rows with raw poll data
# Filter in swing states for each year (because we are only predicting swing states)
# States within 6% margin of victory
train_df <- train_df %>%
  filter(ifelse(year == 2000, state %in% c("FL", "NM", "WI", "IA", "OR", "NH", "MN", "MO", "OH", 
                                           "NV", "TN", "PA", "ME", "MI", "AR", "WA"), TRUE),
         ifelse(year == 2004, state %in% c("WI", "IA", "NM", "NH", "OH", "PA", "NV", "MI", "MN", "OR", "CO", "FL"), TRUE),
         ifelse(year == 2008, state %in% c("MO", "NC", "IN", "MT", "FL", "OH", "GA"), TRUE),
         ifelse(2012, state %in% c("FL", "NC", "OH", "VA", "CO", "PA", "NH", "IA"), TRUE),
         ifelse(year == 2016, state %in% c("Michigan", "New Hampshire", "Pennsylvania", "Wisconsin", "Florida", 
                                           "Minnesota", "Nevada", "Maine", "Arizona", "North Carolina", "Colorado",
                                           "Georgia", "Virginia"), TRUE),
         ifelse(year == 2020, state %in% c("Georgia", "Arizona", "Wisconsin", "Pennsylvania", "North Carolina", "Nevada", 
                                           "Michigan", "Florida", "Texas"), TRUE))
# For 2024
test_df <- agg_data(curr_polls) %>%
  filter(state %in% swing$state & (dem == "Kamala Harris" & rep == "Donald Trump")) # Filter candidates only for the 2024 election