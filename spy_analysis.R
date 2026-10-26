# My First Quantitative Research Project
# Analyze historical SPY stock prices

library(quantmod)

# Download historical SPY stock prices
getSymbols("SPY", src = "yahoo", from = "2020-01-01")

# Display the first six closing prices
head(Cl(SPY))


# Calculate daily logarithmic returns using adjusted prices
daily_returns <- dailyReturn(Ad(SPY), type = "log")

# Display the first six returns
head(daily_returns)

# Calculate summary statistics
summary(daily_returns)

# Prepare returns for regression
returns <- as.numeric(na.omit(daily_returns))[-1]

# Yesterday's return predicts today's return
research <- data.frame(
  yesterday = returns[-length(returns)],
  today = returns[-1]
)

# Use the earliest 70% for model training
split_at <- floor(0.70 * nrow(research))
train <- research[1:split_at, ]

# Fit linear regression
model <- lm(today ~ yesterday, data = train)
summary(model)

# Test the model on the remaining 30% of observations
test <- research[(split_at + 1):nrow(research), ]

# Predict returns on unseen data
predictions <- predict(model, newdata = test)

# Compare with a simple baseline: the training average
baseline <- rep(mean(train$today), nrow(test))

# Calculate prediction errors in percentage points
model_rmse <- 100 * sqrt(mean((test$today - predictions)^2))
baseline_rmse <- 100 * sqrt(mean((test$today - baseline)^2))

cat("Model RMSE (% points):", round(model_rmse, 4), "\n")
cat("Baseline RMSE (% points):", round(baseline_rmse, 4), "\n")

# Calculate out-of-sample R-squared
oos_r2 <- 1 - sum((test$today - predictions)^2) /
  sum((test$today - baseline)^2)

cat("Out-of-sample R-squared:", round(oos_r2, 5), "\n")


png("D:/quantitative-research-r/spy_out_of_sample.png",
    width = 1100, height = 650)

plot(test$today * 100, type = "l", col = "gray60",
     main = "SPY: Actual vs Predicted Returns",
     xlab = "Test Trading Day",
     ylab = "Daily Log Return (%)")

lines(predictions * 100, col = "blue", lwd = 2)
abline(h = 0, lty = 3)

legend("topright",
       legend = c("Actual", "Predicted"),
       col = c("gray60", "blue"),
       lty = 1)

dev.off()

