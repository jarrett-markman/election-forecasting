# Forecasting the 2024 Presidential Election

A project I did in collaboration with [Chris Marfisi](https://www.linkedin.com/in/chris-marfisi-317505227/), attempting to predict the results in the 7 key battleground states in the 2024 presidential election. 

Check out a link to our writeup [here](https://jarrettmarkman.substack.com/p/forecasting-the-2024-presidential)

In our analysis, we used polling data from 538 via [github](https://github.com/fivethirtyeight/data/blob/master/pollster-ratings/raw_polls.csv), [kaggle](https://www.kaggle.com/datasets/fivethirtyeight/2016-election-polls), and their [website](https://projects.fivethirtyeight.com/polls/).

From the data we decided to use the following variables: 
- **college_poll**: binary (0/1) if the pollster was a college/university
- **poll_length**: the duration of the poll.
- **days_to_election**: how close to the election was the poll made
- **n**: the sample size of the poll
- **left_lean/right_lean/partisan**: a binary (0/1) if the pollster or sponsor was a democratic/republican (or just a partisan poll) partisan group, respectively
- **lv/rv**: a binary (0/1) based on the polling population (likely voters or registered voters)
- **ivr/live_phone/email/text/online_panel**: a binary (0/1) based on the polling methodology.
- **numeric_grade**: pollster grade (0-3) determined by 538 based on historical accuracy
- **transparency_score**: pollster grade (0-10) determined by 538 based on how transparent the methodology is
- **proj_margin**: projected margin from the democratic perspective (democratic percentage — republican percentage)
- **winner**: a binary (0/1) representing whether a democrat (1) or republican (0) won the state.

To make our predictions, we build an eXtreme Gradient Boost model (XGBoost) on prior presidential polling data and results from 2000-2024, and trained and tested it with its built-in ability of cross validation. 

Our train and test merror’s were 0.014 and 0.086 respectively. One of the biggest concerns with machine learning models like XGBoost is overfitting — the idea that the model will be highly effective in predicting prior observations, rather than predicting new data. Given the test merror was 0.086, we weren’t concerned about overfitting.

The following visual displays the variable importance for each individual poll:

![image](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F9dfcd8cf-0bbf-447e-a7c8-9d830a3512c2_1600x964.png)

After building our model, we applied it to the 2024 presidential election. 

![image](https://substackcdn.com/image/fetch/w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F54ac6086-4b47-4142-a51c-5ba9d8d71c44_550x694.png)

Based on each state’s probability of winning, if we assumed a classified result  (the higher win percentage for each state)  then Donald Trump would win by 281 electoral votes (219 + Arizona (11) + Georgia (15) + North Carolina (15) + Pennsylvania (19)) to Kamala Harris’ 257 electoral votes (226 + Michigan (15) + Nevada (6) + Wisconsin (10)).

Additionally, we calculated the expected value of electoral votes by multiplying the generated percentages of victory by the electoral votes for each state. The end results came out to Trump’s 270 to Harris’ 268 indicating how close this election may be.

We then ran 100,000 simulations of the election, predicting the likelihood of victory for each state with each simulation generating a winner (based on the probabilities in the table above). From this simulation we calculated the win rate for each of the candidates. Kamala Harris has a 45% chance to win to Donald Trump’s 53% chance along with 2% likelihood of a tie.
