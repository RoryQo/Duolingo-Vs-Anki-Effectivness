## ------------------------------------------------------------------
languages = read.table("languages.csv", header = TRUE, sep = ",")
duolingo = languages[which(languages$app == "Duolingo"),]
anki = languages[which(languages$app == "Anki"),]
colnames(anki)
colnames(duolingo)


## ------------------------------------------------------------------
# Load necessary libraries
library(ggplot2)


ggplot(languages, aes(x = app, y = final, fill = app)) +
  geom_boxplot(outlier.colour = "red", outlier.shape = 16, outlier.size = 2) +
  labs(title = "Final Exam Scores by App Type",
       x = "App Type",
       y = "Final Exam Score") +
  scale_fill_manual(values = c("Duolingo" = "skyblue", "Anki" = "salmon")) +
  theme_minimal() +
  theme(legend.position = "none")



## ------------------------------------------------------------------
t.test(duolingo$final, anki$final, alternative = "two.sided", var.equal = FALSE)


## ------------------------------------------------------------------
ggplot(languages, aes(x = hours, y = final, color = app)) +
  geom_point(size = 3, alpha = 0.7) +  # Adjust point size and transparency
  geom_smooth(method = "lm", se = FALSE, aes(color = app), linetype = "solid") +  # Add solid regression lines
  labs(title = "Final Exam Scores vs. Hours Used",
       x = "Hours Used",
       y = "Final Exam Score") +
  scale_color_manual(values = c("Duolingo" = "#4C8BF9", "Anki" = "#F26B6B")) +  # Softer colors
  theme_minimal() +
  theme(legend.position = "top",  # Move the legend to the top
        plot.title = element_text(hjust = 0.5))  # Center the title


## ------------------------------------------------------------------
languages$duolingo = ifelse(languages$app == "Duolingo", 1, 0)
full = lm(final ~ hours + duolingo + hours*duolingo, data = languages)
reduced = lm(final ~ hours + duolingo, data = languages)
anova(full)
anova(reduced)


## ------------------------------------------------------------------
full = lm(final ~ hours + duolingo, data = languages)
reduced = lm(final ~ hours, data = languages)
anova(full)
anova(reduced)

