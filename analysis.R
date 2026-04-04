# Sleep and Depression Analysis (NHANES)
# Author: Samuel Stinelli
# Purpose: Analyze the relationship between sleep duration and depressive symptoms
# using PHQ-9 scores from NHANES data.

# =========================
# 1. Load libraries
# =========================
library(haven)
library(dplyr)
library(ggplot2)

# =========================
# 2. Import datasets
# =========================
depression <- read_xpt("P_DPQ.xpt")
sleep <- read_xpt("P_SLQ.xpt")

# =========================
# 3. Merge datasets by participant ID
# =========================
merged <- merge(depression, sleep, by = "SEQN")

# =========================
# 4. Create PHQ-9 depression score
# NHANES PHQ items should be coded 0-3
# Special codes like 7 and 9 are treated as missing
# =========================
phq_items <- c(
  "DPQ010", "DPQ020", "DPQ030", "DPQ040", "DPQ050",
  "DPQ060", "DPQ070", "DPQ080", "DPQ090"
)

merged[phq_items] <- lapply(merged[phq_items], function(x) {
  ifelse(x %in% 0:3, x, NA)
})

merged$depression_score <- rowSums(merged[phq_items], na.rm = FALSE)

# =========================
# 5. Create analytic sample
# SLD012 = usual sleep duration in hours on weekdays/workdays
# Keep only complete cases for sleep and depression
# =========================
clean <- merged %>%
  select(SEQN, SLD012, depression_score) %>%
  filter(!is.na(SLD012), !is.na(depression_score))

# =========================
# 6. Report sample sizes
# =========================
cat("Merged sample size:", nrow(merged), "\n")
cat("Analytic sample size:", nrow(clean), "\n")

# =========================
# 7. Descriptive statistics
# =========================
cat("\n--- Sleep Duration Summary ---\n")
print(summary(clean$SLD012))

cat("\n--- Depression Score Summary ---\n")
print(summary(clean$depression_score))

cat("\n--- Frequency of Sleep Duration ---\n")
print(table(clean$SLD012))

sleep_group_summary <- clean %>%
  group_by(SLD012) %>%
  summarise(
    n = n(),
    mean_depression = mean(depression_score),
    sd_depression = sd(depression_score),
    .groups = "drop"
  ) %>%
  arrange(SLD012)

cat("\n--- Mean Depression Score by Sleep Duration ---\n")
print(sleep_group_summary)

# =========================
# 8. Correlation analysis
# =========================
cor_test <- cor.test(clean$SLD012, clean$depression_score)

cat("\n--- Correlation Test ---\n")
print(cor_test)

# =========================
# 9. Linear regression
# =========================
model_linear <- lm(depression_score ~ SLD012, data = clean)

cat("\n--- Linear Regression Summary ---\n")
print(summary(model_linear))

# =========================
# 10. Quadratic regression
# Tests whether a curved relationship fits better
# =========================
model_quadratic <- lm(depression_score ~ SLD012 + I(SLD012^2), data = clean)

cat("\n--- Quadratic Regression Summary ---\n")
print(summary(model_quadratic))

# =========================
# 11. Visualization 1:
# Scatterplot with LOESS smoothing
# =========================
plot1 <- ggplot(clean, aes(x = SLD012, y = depression_score)) +
  geom_jitter(width = 0.2, height = 0, alpha = 0.25) +
  geom_smooth(method = "loess", se = TRUE) +
  labs(
    title = "Sleep Duration and Depression Severity",
    subtitle = "NHANES 2017-2020: PHQ-9 score by self-reported sleep duration",
    x = "Sleep Duration (Hours)",
    y = "PHQ-9 Depression Score",
    caption = "Source: CDC NHANES"
  ) +
  theme_minimal(base_size = 12)

print(plot1)

ggsave(
  "sleep_vs_depression_scatter.png",
  plot = plot1,
  width = 8,
  height = 5,
  dpi = 300
)

# =========================
# 12. Filter grouped data by sample size
# Removes unstable mean estimates from very small groups
# =========================
sleep_group_filtered <- sleep_group_summary %>%
  filter(n >= 30)

cat("\n--- Filtered Sleep Groups (n >= 30) ---\n")
print(sleep_group_filtered)

# =========================
# 13. Visualization 2:
# Mean depression score by sleep duration
# Point size reflects sample size
# =========================
plot2 <- ggplot(sleep_group_filtered, aes(x = SLD012, y = mean_depression)) +
  geom_line(linewidth = 1) +
  geom_point(aes(size = n), alpha = 0.8) +
  geom_smooth(method = "loess", se = TRUE, linetype = "dashed", alpha = 0.2) +
  labs(
    title = "Mean Depression Score by Sleep Duration",
    subtitle = "Sleep groups with ≥30 participants (NHANES 2017–2020)",
    x = "Sleep Duration (Hours)",
    y = "Mean PHQ-9 Depression Score",
    caption = "Point size reflects sample size | Source: CDC NHANES"
  ) +
  theme_minimal(base_size = 12)

print(plot2)

ggsave(
  "mean_depression_by_sleep.png",
  plot = plot2,
  width = 8,
  height = 5,
  dpi = 300
)
