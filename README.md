# Language Learning Platforms Comparison

## Table of Contents

1. [Overview](#overview-and-study-scenario)  
2. [Data Preparation](#data-preparation) 
3. [Analysis Methodology](#analysis-methodology)  
4. [Results and Conclusion](#results-and-conclusion)  





## Overview and Study Scenario

This analysis compares the effectiveness of two widely-used language learning platforms—**Duolingo** and **Anki**—by examining their impact on students' performance in a foreign language course. In this study, students enrolled in a foreign language course choose either **Duolingo** or **Anki** as their preferred study tool. The goal is to compare how the hours spent using each app relate to students' final exam performance. We hypothesize that the platform used may have a significant effect on the final exam scores, and we further explore whether spending more time on an app results in better performance.

## Data Preparation

The data is loaded and separated into two groups based on the platform used—Duolingo or Anki—before any analysis is conducted.

```{r}
languages = read.table("languages.csv", header = TRUE, sep = ",")
duolingo = languages[which(languages$app == "Duolingo"),]
anki = languages[which(languages$app == "Anki"),]
```


## Analysis Methodology

### 3.1 Boxplots and Two-Sample T-Test (With Equal/Unequal Variance Test)

We start by plotting **boxplots** to visualize the distribution of final exam scores for both Duolingo and Anki users to validate normality assumptions of our models. And to identify any high leverage points or outliers that could skew the results.

<img src="https://github.com/RoryQo/Duolingo-Vs-Anki-Effectivness/blob/main/Figures/graph1.jpg" alt="Scatterplot" width="400"/>


#### Levene’s Test for Equality of Variances and T-Tests
Before performing the two-sample t-test, we first test whether the assumption of **equal variances** holds. We do this by conducting **Levene's Test**. This test checks for the equality of variances across the two groups (Duolingo and Anki). The **Levene’s test** suggests unequal variances (p-value < 0.05), therefore we proceed with a **Welch’s t-test**, which is a variation of the t-test that does not assume equal variances. We perform a t-test to identify any initial significant difference between the final exam scores of both groups. Before controlling for hours spent studying, the Duolingo users have a significantly higher average final exam score.

The two-sample t-test results comparing Duolingo and Anki final exam scores are as follows:

| Statistic        | Value      |
|------------------|------------|
| t-value          | 3.2044     |
| Degrees of Freedom| 26.279     |
| p-value          | 0.003534   |
| Confidence Interval (95%) | [2.512, 11.488] |
| Mean of Duolingo  | 89.6       |
| Mean of Anki     | 82.6       |


```{r}
# Perform Levene's Test for Equality of Variances
leveneTest(final ~ app, data = languages)

# Perform Two-Sample T-Test assuming unequal variances (Welch's T-Test)
t.test(duolingo$final, anki$final, alternative = "two.sided", var.equal = FALSE)

```

### 3.2 Scatterplot and Regression Analysis

Next, we use a **scatterplot** to visualize the relationship between the number of hours students spent using the app and their final exam scores. A scatterplot helps identify any patterns or trends between study hours and exam scores.

To better understand the relationship, we add **linear regression lines** for both Duolingo and Anki groups. This allows us to assess whether there is a consistent trend in the data, and whether the slope of the line differs between the two groups. We can see that it appears that duolingo users study more hours than Anki users, and the slopes may differ, indicating we should test for an interaction term between app type and hours as well.

<img src="https://github.com/RoryQo/Duolingo-Vs-Anki-Effectivness/blob/main/Figures/graph2.jpg" alt="Scatterplot" width="400"/>


### 3.3 Testing the Appropriateness of ANCOVA

Given that study hours may be a confounding factor in the analysis, we use **Analysis of Covariance (ANCOVA)** to adjust for the number of study hours. ANCOVA helps us determine whether the final exam score differences between Duolingo and Anki are still significant after controlling for study time.

We compare two models:


   
1. A **full model** that includes both study hours and the interaction term between hours and app type.

$$\text{final} = \beta_0 + \beta_1(\text{hours}) + \beta_2(\text{duolingo}) + \beta_3(\text{hours} \times \text{duolingo}) + \epsilon$$

2. A **reduced model** that includes study hours and app type but omits the interaction term.

$$\text{final} = \beta_0 + \beta_1(\text{hours}) + \beta_2(\text{duolingo}) + \epsilon$$

 The interaction term of hours and Duolingo is not statistically significant, so we can proceed with a reduced ANCOVA model (not including the interaction term).
```{r}
languages$duolingo = ifelse(languages$app == "Duolingo", 1, 0)
full = lm(final ~ hours + duolingo + hours*duolingo, data = languages)
reduced = lm(final ~ hours + duolingo, data = languages)
anova(full)
anova(reduced)
```

#### ANCOVA Results (Full Model with Interaction)

| Term           | Df | Sum Sq      | Mean Sq     | F value      | Pr(>F)        |
|---------------|----|------------|------------|-------------|--------------|
| hours         | 1  | 1142.865956 | 1142.865956 | 73.1432913  | 1.166507e-09 |
| duolingo      | 1  | 57.445279   | 57.445279   | 3.6764913   | 6.443980e-02 |
| hours:duolingo | 1  | 1.712905    | 1.712905    | 0.1096257   | 7.427984e-01 |
| Residuals     | 31 | 484.375860  | 15.625028   | NA          | NA           |


#### ANCOVA Results (Reduced Model without Interaction)

| Term      | Df | Sum Sq     | Mean Sq    | F value    | Pr(>F)        |
|-----------|----|-----------|------------|-----------|---------------|
| hours     | 1  | 1142.86596 | 1142.86596 | 75.236692  | 6.524577e-10 |
| duolingo  | 1  | 57.44528   | 57.44528   | 3.781714   | 6.064903e-02 |
| Residuals | 32 | 486.08877  | 15.19027   | NA         | NA            |


### 3.4 Testing Equality of Adjusted Means

Finally, we test for the **equality of adjusted means** between the two groups (Duolingo and Anki) after accounting for study hours. This test ensures that any difference in final exam scores is not simply due to the amount of time spent studying.

We compare two models:
1. A **full model** that includes both hours and app type.

$$\text{final} = \beta_0 + \beta_1 \times \text{hours} + \beta_2 \times \text{duolingo} + \epsilon$$

2. A **reduced model** that only includes hours.

$$\text{final} = \beta_0 + \beta_1 \times \text{hours} + \epsilon$$

Since the full model with app type produces significantly different results at the 90% confidence level compared to the reduced model, we conclude that app type influences the final exam scores, even after controlling for study hours.

```{r}
full = lm(final ~ hours + duolingo, data = languages)
reduced = lm(final ~ hours, data = languages)

# Calculate the adjusted means for final exam scores based on hours and app type
adjusted_means = emmeans(full, ~ duolingo)

# Display the adjusted means
summary(adjusted_means)
```
#### ANCOV Results

| Term      | Df | Sum Sq     | Mean Sq    | F value    | Pr(>F)        |
|-----------|----|-----------|------------|-----------|---------------|
| hours     | 1  | 1142.86596 | 1142.86596 | 75.236692  | 6.524577e-10 |
| duolingo  | 1  | 57.44528   | 57.44528   | 3.781714   | 6.064903e-02 |
| Residuals | 32 | 486.08877  | 15.19027   | NA         | NA            |


#### Adjusted Means Comparison

| duolingo | Adj Mean  | SE     |
|----------|---------|----------|
| 0        | 84.9853 | 1.05993  |
| 1        | 87.8110 | 0.90654  |




## Results and Conclusion

Results and Conclusion

The analysis of final exam scores between Duolingo and Anki users reveals several key insights. Duolingo users, on average, scored significantly higher on the final exam compared to Anki users. The mean final exam score for Duolingo users was 89.6, while Anki users had a mean score of 82.6. This difference was statistically significant with a p-value of 0.0035, as indicated by the two-sample t-test results (t = 3.2044, df = 26.279, 95% CI = [2.512, 11.488]).

Additionally, the scatter plot analysis showed that Duolingo users spent more time studying on average, which may contribute to their higher scores. This observation aligns with Duolingo's gamified design, which tends to engage users for longer study sessions.

To account for the potential confounding factor of study hours, we used ANCOVA to adjust for the number of study hours. In the final ANCOVA model, which excluded the insignificant interaction term, the p-value for the app type (Duolingo vs. Anki) was 0.0606, which is significant at the 90% confidence level, indicating a trend toward higher scores for Duolingo users after accounting for hours spent studying.

The adjusted means comparison further supports this finding: Duolingo users had an adjusted mean final exam score of 87.81, compared to 84.99 for Anki users, suggesting that Duolingo not only **encourages longer study sessions** but also yields better academic outcomes on a **per-hour basis**.

In conclusion, Duolingo appears to be superior to Anki in terms of both user engagement and academic performance. The gamified features of Duolingo likely contribute to longer study durations, which in turn lead to improved performance. Despite controlling for study hours, Duolingo users continue to outperform their Anki counterparts, suggesting that Duolingo’s design is more conducive to effective language learning. However, further research could explore additional factors such as app preferences, and specific learning strategies to provide a more comprehensive understanding of the platforms’ effectiveness.


