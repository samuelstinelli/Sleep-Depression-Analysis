# Sleep and Depression Analysis (NHANES)
# Author: Samuel Stinelli
# Purpose: Analyze the relationship between sleep duration and depression using PHQ-9 scores

library(haven)

# Load NHANES datasets
depression <- read_xpt("P_DPQ.xpt")
sleep <- read_xpt("P_SLQ.xpt")

# Merge datasets by participant ID
merged <- merge(depression, sleep, by = "SEQN")

# Create PHQ-9 depression score (0–27), removing invalid values
merged$depression_score <- ifelse(
  merged$DPQ010 > 3 | merged$DPQ020 > 3 | merged$DPQ030 > 3 |
    merged$DPQ040 > 3 | merged$DPQ050 > 3 | merged$DPQ060 > 3 |
    merged$DPQ070 > 3 | merged$DPQ080 > 3 | merged$DPQ090 > 3,
  NA,
  merged$DPQ010 + merged$DPQ020 + merged$DPQ030 +
    merged$DPQ040 + merged$DPQ050 + merged$DPQ060 +
    merged$DPQ070 + merged$DPQ080 + merged$DPQ090
)

# Filter complete cases for sleep and depression score
clean <- merged[complete.cases(merged[, c("SLD012", "depression_score")]), ]

# Summary statistics
summary(clean$depression_score)
mean(clean$SLD012)
tapply(clean$depression_score, clean$SLD012, mean, na.rm = TRUE)
table(clean$SLD012)

# Correlation analysis
cor(clean$SLD012, clean$depression_score)

# Visualization: scatterplot with LOWESS trend line
plot(
  jitter(clean$SLD012),
  clean$depression_score,
  xlab = "Sleep (hours)",
  ylab = "PHQ-9 Depression Score",
  main = "Sleep Duration vs Depression (PHQ-9)"
)

lines(lowess(clean$SLD012, clean$depression_score), col = "red", lwd = 2)