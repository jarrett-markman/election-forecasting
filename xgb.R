# Model for classification
# Set seed for reproducible results
set.seed(2024)
# Set split at 90% to train a larger data set
train_ind <- sample(1:nrow(train_df), .9 * nrow(train_df)) 
# Create train/test datasets
model_train <- train_df %>% 
  dplyr::slice(train_ind) %>% # Use slice to select cols from train_ind
  # Remove character cols. 
  select(-c(state, year, poll_id, pollster_rating_id, pollster, start_date, end_date, election_date, dem, rep, winner, dem_pct, rep_pct)) %>%
  as.matrix() %>%
  xgb.DMatrix(label = train_df$winner[train_ind])
model_test <- train_df %>% 
  dplyr::slice(-train_ind) %>%
  select(-c(state, year, poll_id, pollster_rating_id, pollster, start_date, end_date, election_date, dem, rep, winner, dem_pct, rep_pct)) %>%
  as.matrix() %>%
  xgb.DMatrix(label = train_df$winner[-train_ind])
# Run xgb model
model <- xgb.train(
  params = list(
    num_class = 2, # 2 classes 0 (rep) or 1 (dem)
    objective = "multi:softprob", 
    # Set objective at multi:softprob to get the probability of each class being selected for each poll
    eval_metric = "merror"
  ),
  data = model_train,
  nrounds = 500, # Run 500 rounds
  early_stopping_rounds = 50, # Stop if the model shows no improvement after 50 rounds
  watchlist = list(
    train = model_train,
    test = model_test
  )
)