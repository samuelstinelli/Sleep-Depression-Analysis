# Sleep and Depression Analysis (NHANES)

## Overview
This project examines the relationship between sleep duration and depression using CDC NHANES data. Depression was measured using the PHQ-9, a clinically validated scale.

## Objective
To investigate how sleep duration relates to depression severity and identify patterns in real-world population data.

## Data Source
- CDC NHANES (2017–2020)
- Sleep data (SLQ)
- Depression data (DPQ)

## Methods
- Merged datasets using participant ID (SEQN)
- Constructed PHQ-9 depression scores (0–27 scale)
- Cleaned invalid responses (NHANES special codes)
- Filtered complete cases for analysis
- Calculated summary statistics and correlations
- Visualized the relationship using scatterplots and LOWESS smoothing

## Results
- A U-shaped relationship was observed between sleep duration and depression
- Lowest depression scores occurred around 7–9 hours of sleep
- Higher depression scores were observed at both low and high sleep durations

## Visualization
![Sleep vs Depression](figures/sleep_vs_depression.png)

## Tools Used
- R
- haven package
- Base R plotting

## Key Insight
Both insufficient and excessive sleep are associated with higher depression levels, suggesting that optimal sleep duration plays an important role in mental health.

## Author
Samuel Stinelli
