# Variable importance plot
vipplot <- vip::vip(model) +
  labs(
    title = "Variable Importance Plot",
    caption = "Date: FiveThirtyEight"
  ) +
  ggthemes::theme_fivethirtyeight() +
  theme(plot.title = element_text(size = 12, face = "bold", hjust = 0.5))
ggsave("Variable Importance Plot.png", vipplot)
# 1. Win probabilities for state
state_viz <- res %>% 
  mutate(Trump = round(trump_wp, digits = 2), Harris = round(harris_wp, digits = 2)) %>% # Round cols. 
  select(-c(trump_wp, harris_wp), State = state) %>% # Rm cols, change state name
  gt() %>%
  # Set blues as the color scale
  data_color(columns = c(Trump, Harris), colors = scales::col_numeric("Blues",
                                                                      domain = NULL)) %>%
  # Center everything and title the plot
  cols_align(align = "center") %>%
  tab_header(title = "Swing State Win Probabilities") %>%
  tab_source_note(
    source_note = "Data: FiveThirtyEight"
  )
gtsave(state_viz, "State Win Probabilities.png")
# 2. Classify results based on whoever has the higher wp
res %>% 
  summarize(state, winner = ifelse(trump_wp > harris_wp, "Trump", "Harris"))
# 3. Expected electoral votes
# Calculate expected electoral votes sum of each states likelihood of winning * electoral votes
probs <- res %>%
  left_join(swing, by = "state") %>%
  summarize(trump_x_ev = sum(trump_wp * ev),
            harris_x_ev = sum(harris_wp * ev)) %>% as.vector()
probs$trump_x_ev + 219
probs$harris_x_ev + 226
# 4. Simulate the results of the election
sim_state <- function(swing) {
  # Initialize a data frame for state/winner based on probabilities
  df <- data.frame(state = swing, winner = NA)
  wp <- res %>%
    filter(state == swing) %>% # Filter for state obs
    select(harris_wp) # Select harris wp
  if (runif(1) <= wp) { # Use runif(1) to return a random decimal 0-1, if it's <= harris wp
    df$winner <- "Harris" # If <= Harris wins the state
    return(df)
  } else { # Else Trump wins
    df$winner <- "Trump"
    return(df)
  }
}
sim_election_cycle <- function() {
  # Initialize an empty data frame to store results
  results <- data.frame(state = character(), winner = character(), stringsAsFactors = FALSE)
  
  # Loop through each state in "res" df
  for (state_name in res$state) {
    # Simulate the result for each state using sim_state and bind the results
    results <- rbind(results, sim_state(state_name))
  }
  
  ev <- results %>%
    left_join(swing, by = "state") %>% # Join swing state data to collect simulated electoral votes
    group_by(winner) %>% # Group by winning candidate
    summarize(ev = sum(ev)) %>% # Get total ev
    # Use pivot wider to get individual harris/trump ev as the cols. in the df
    pivot_wider(names_from = winner, values_from = ev)
    
  # Set harris_ev and trump_ev, checking if "Harris" and "Trump" exist in names
  harris_ev <- 226 + ifelse("Harris" %in% names(ev), ev$Harris, 0)
  trump_ev <- 219 + ifelse("Trump" %in% names(ev), ev$Trump, 0)
  # Create ev df to bind cols for state res
  ev <- cbind(harris_ev, trump_ev)
  
  # Wide the results col. to make it an individual observation for each individual state
  votes <- results %>%
    pivot_wider(names_from = state, values_from = winner)

  data <- cbind(votes, ev) %>%
    # Create winner col. based on Harris EV total
    mutate(winner = ifelse(harris_ev >= 270, "Harris", "Trump"),
           winner = ifelse(harris_ev == 269, "Tie", winner))
  
  return(data)
}
# Create a fn that runs simulations for n election cycles 
run_simulations <- function(n) {
  results <- list()  # Initialize an empty list to store each cycle's results
  for (i in 1:n) {
    print(paste("Simulating cycle number:", i))
    results[[i]] <- sim_election_cycle()  # Run the simulation and store the result in the list
  }
  
  # Bind the rows after the loop and add the simulation_id
  results_df <- bind_rows(results, .id = "simulation_id")
  
  return(results_df) # Return the results df
}
# Restate seed for replicable results
set.seed(2024)
# Apply run_simulations function for 100k sims
sims <- run_simulations(100000)
# Calculate win pct for each candidate (or tie)
sims %>% 
  group_by(winner) %>% # Group by election winner
  count(name = "wins") %>% # Count number of wins
  ungroup() %>% # Remove group constraints
  mutate(win_rate = round(wins/sum(wins) * 100, digits = 2)) %>% # Calculate win rate
  select(-wins) %>% # Rm wins col. 
  pivot_wider(names_from = winner, values_from = win_rate) %>%
  gt() 
# Show most frequent simulated results
freq_res <- sims %>%
  select(-c(simulation_id, harris_ev, trump_ev, winner)) %>%  # Exclude non-state columns
  group_by(across(everything())) %>%  # Group all state cols 
  count(name = "times") %>%
  ungroup() %>%
  mutate(freq = times/sum(times)) %>% 
  arrange(desc(freq)) %>% # Calculate and sort by win rate
  head(5) %>% # Take first 5 results
  mutate(Frequency = round(freq * 100, digits = 2)) %>%
  select(-c(times, freq)) %>%
  # Create a table for sim results
  gt() %>% 
  cols_align(align = "center") %>%
  tab_header(title = "5 Most Frequent Simulated Results") %>%
  tab_source_note(
    source_note = "Data: FiveThirtyEight"
  )
gtsave(freq_res, "Most Frequent Results.png")
ties <- sims %>% 
  # Group by the election winner and summarize across all columns
  group_by(winner) %>% 
  summarise(across(everything())) %>% 
  ungroup() %>% 
  filter(winner == "Tie") %>% # Filter tie results
  distinct(Arizona, Georgia, Michigan, Nevada, `North Carolina`, Pennsylvania, Wisconsin) %>% # Get distinct states for each tie
  # Create a table of ties
  gt() %>%
  cols_align(align = "center") %>%
  tab_header(title = "Electoral Tie Scenarios") %>%
  tab_source_note(
    source_note = "Data: FiveThirtyEight"
  )
gtsave(ties, "Tie Scenarios.png")
# Create a function to analyze results for both candidates
analyze_candidate <- function(candidate) {
  wins <- sims %>%
    filter(winner == candidate) # Filter winning candidate
  state_wp <- wins %>%
    select(-c(simulation_id, harris_ev, trump_ev, winner)) %>%  # Exclude non-state columns
    summarise(across(everything(), ~ mean(. == candidate)) * 100) %>%
  # Summarise across all cols. by mean when the value is candidate
    pivot_longer(everything(), names_to = "State", values_to = "win_rate")
  return(state_wp)
}
harris_states <- analyze_candidate("Harris")
harris_states_viz <- harris_states %>%
  # Create a table of the win rate in wins for Harris
  summarise(State, "Win Rate" = round(win_rate, digits = 2)) %>%
  gt() %>%
  # Set blue color scale
  data_color(columns = -State, colors = scales::col_numeric("Blues", domain = NULL)) %>%
  # Center everything and title the table (with subtitle)
  cols_align(align = "center") %>%
  tab_header(title = "State Win Rate in Harris Victories", 
             subtitle = "Frequency of winning a state given she wins the election (e.g. she wins Arizona 51.28% of the time when she wins") %>%
  tab_source_note(
    source_note = "Data: FiveThirtyEight"
  )
gtsave(harris_states_viz, "Harris State Importance.png")
trump_states_viz <- analyze_candidate("Trump") %>% 
  # Create a table of the win rate in wins for Trump
  summarise(State, "Win Rate" = round(win_rate, digits = 2)) %>%
  gt() %>%
  # Set red color scale
  data_color(columns = -State, colors = scales::col_numeric("Reds", domain = NULL)) %>%
  # Center everything and title the table (with subtitle)
  cols_align(align = "center") %>%
  tab_header(title = "State Win Rate in Trump Victories", 
             subtitle = "Frequency of winning a state given he wins the election (e.g. he wins Arizona 69.72% of the time when he wins") %>%
  tab_source_note(
    source_note = "Data: FiveThirtyEight"
  )
gtsave(trump_states_viz, "Trump State Importance.png")