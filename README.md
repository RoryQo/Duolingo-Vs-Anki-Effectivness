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
Before performing the two-sample t-test, we first test whether the assumption of **equal variances** holds. We do this by conducting **Levene's Test**. This test checks for the equality of variances across the two groups (Duolingo and Anki). If the p-value from the Levene's test is greater than 0.05, we assume equal variances; otherwise, we proceed with the unequal variance assumption.

The **Levene’s test** suggests unequal variances (p-value < 0.05), therefore we proceed with a **Welch’s t-test**, which is a variation of the t-test that does not assume equal variances. We perform a t-test to identify any initial significant difference between the final exam scores of both groups. Before controlling for hours spent studying, the Duolingo users have a significantly higher average final exam score.

```{r}
# Perform Levene's Test for Equality of Variances
leveneTest(final ~ app, data = languages)

# Perform Two-Sample T-Test assuming unequal variances (Welch's T-Test)
t.test(duolingo$final, anki$final, alternative = "two.sided", var.equal = FALSE)

```

### 3.2 Scatterplot and Regression Analysis

Next, we use a **scatterplot** to visualize the relationship between the number of hours students spent using the app and their final exam scores. A scatterplot helps identify any patterns or trends between study hours and exam scores.

To better understand the relationship, we add **linear regression lines** for both Duolingo and Anki groups. This allows us to assess whether there is a consistent trend in the data, and whether the slope of the line differs between the two groups.

<img src="https://github.com/RoryQo/Duolingo-Vs-Anki-Effectivness/blob/main/Figures/graph2.jpg" alt="Scatterplot" width="400"/>


### 3.3 Testing the Appropriateness of ANCOVA

Given that study hours may be a confounding factor in the analysis, we use **Analysis of Covariance (ANCOVA)** to adjust for the number of study hours. ANCOVA helps us determine whether the final exam score differences between Duolingo and Anki are still significant after controlling for study time.

We compare two models:
1. A **full model** that includes both study hours and the interaction term between hours and app type.
2. A **reduced model** that includes study hours and app type but omits the interaction term.

 The interaction term of hours and Duolingo is not statistically significant, so we can proceed with a reduced ANCOVA model (not including the interaction term).
```{r}
languages$duolingo = ifelse(languages$app == "Duolingo", 1, 0)
full = lm(final ~ hours + duolingo + hours*duolingo, data = languages)
reduced = lm(final ~ hours + duolingo, data = languages)
anova(full)
anova(reduced)
```

### 3.4 Testing Equality of Adjusted Means

Finally, we test for the **equality of adjusted means** between the two groups (Duolingo and Anki) after accounting for study hours. This test ensures that any difference in final exam scores is not simply due to the amount of time spent studying.

We compare two models:
1. A **full model** that includes both hours and app type.
2. A **reduced model** that only includes hours.

Since the full model with app type produces significantly different results compared to the reduced model, we conclude that app type influences the final exam scores, even after controlling for study hours.

```{r}
full = lm(final ~ hours + duolingo, data = languages)
reduced = lm(final ~ hours, data = languages)
anova(full)
anova(reduced)
```

## Results and Conclusion

The analysis indicates that **Duolingo** users tend to perform better on average in final exam scores compared to **Anki** users. Additionally, Duolingo users study for longer periods, likely due to its engaging gamified features. This suggests that Duolingo's design encourages more consistent and longer study sessions.

Even after adjusting for the total number of study hours, Duolingo users still significantly outperform Anki users. This implies that Duolingo is more effective on a **per-hour basis**, meaning that for the same amount of time spent studying, Duolingo leads to better academic performance.

These findings point to the superior effectiveness of Duolingo in terms of both user engagement and academic outcomes, driven by its interface and structured learning approach. However, further research could investigate other factors such as user preferences, study habits, and the role of different learning strategies in determining the effectiveness of each app. 
