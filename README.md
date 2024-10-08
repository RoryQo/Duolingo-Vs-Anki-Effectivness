# Comparison of Language Learning Platforms

## Table of Contents

1. [Overview](#overview)
2. [Scenario](#scenario)
3. [Results](#results)
4. [Conclusion](#conclusion)
5. [Data Preparation](#data-preparation)
6. [Visualizations and Statistical Tests](#visualizations-and-statistical-tests)

## Overview

This document explores the effectiveness of two language learning applications—Duolingo and Anki—by analyzing how the number of hours spent using each app correlates with students' final exam scores in a foreign language course.

## Scenario

In this analysis, we compare the study habits of students using either Duolingo or Anki to understand their impact on exam performance.

## Results

The analysis reveals that Duolingo users generally perform better on average and study longer compared to Anki users. This increased study time could be attributed to the engaging gamification aspects of Duolingo, which encourage users to invest more time in their learning. 

Moreover, when adjusting for hours studied, Duolingo users still significantly outperform Anki users, indicating that Duolingo is more effective on a per-hour basis. The combined evidence suggests that both the interface and learning curriculum of Duolingo contribute to its superiority in language learning.

## Conclusion

The findings underscore the effectiveness of Duolingo as a language learning tool, highlighting its advantages in user engagement and academic performance compared to Anki. Further exploration could provide deeper insights into user preferences and study habits.

## Data Preparation

We start by loading the necessary data and separating it by app type.

```{r}
languages = read.table("languages.csv", header = TRUE, sep = ",")
duolingo = languages[which(languages$app == "Duolingo"),]
anki = languages[which(languages$app == "Anki"),]
```

## Visualizations and Statistical Tests

### 1. Boxplots and Two-Sample T-Test

We create boxplots to visualize the final exam scores for both apps and perform a two-sample t-test to compare their means.

<img src="https://raw.githubusercontent.com/RoryQo/DuoLingo-Vs-Anki-Effectivness/main/graph1.jpg" alt="Scatterplot" width="400"/>

### 2. Scatterplot

Next, we plot the relationship between the hours spent using the apps and the final exam scores. Linear regression lines are added for each app to illustrate trends.

<img src="https://raw.githubusercontent.com/RoryQo/DuoLingo-Vs-Anki-Effectivness/main/graph2.jpg" alt="Scatterplot" width="400"/>

### 3. Testing Appropriateness of ANCOVA

We assess the appropriateness of using ANCOVA by comparing models with and without interaction terms.  The interaction term of hours and Duolingo is not statistically significant, so we can proceed with a reduced ANCOVA model (not including the interaction term).

```{r}
languages$duolingo = ifelse(languages$app == "Duolingo", 1, 0)
full = lm(final ~ hours + duolingo + hours*duolingo, data = languages)
reduced = lm(final ~ hours + duolingo, data = languages)
anova(full)
anova(reduced)
```

### 4. Testing Equality of Adjusted Means

Finally, we check for equality of adjusted means between the two groups to see if the differences in final scores are statistically significant.  Duolingo outperforms Anki at a 90% confidence level.

```{r}
full = lm(final ~ hours + duolingo, data = languages)
reduced = lm(final ~ hours, data = languages)
anova(full)
anova(reduced)
```
