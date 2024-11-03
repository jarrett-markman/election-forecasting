# Create an xgb.DMatrix to apply model to predict 2024 election
pred_matrix <- test_df %>%
  select(-c(state, year, poll_id, pollster_rating_id, pollster, start_date, end_date, election_date, dem, rep, dem_pct, rep_pct)) %>%
  as.matrix() %>%
  xgb.DMatrix()
preds <- predict(model, pred_matrix) # Apply model
preds <- matrix(preds, ncol = 2, byrow = TRUE) # Create a matrix for preds (b/c there are preds for each class)
res <- bind_cols(test_df, preds) %>% # Use bind_rows to combine test data with predicted values
  group_by(state) %>% # Group by the state
  summarize( # Caclulate the mean values for each candidate
    trump_wp = mean(`...30`), 
    harris_wp = mean(`...31`)
  ) %>%
  ungroup() # Remove constraints