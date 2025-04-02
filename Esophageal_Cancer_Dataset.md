`esoph` contains data from a study on the relationship between esophageal cancer and several risk factors, such as alcohol and tobacco consumption. The study aims to investigate how these risk factors may contribute to the occurrence of esophageal cancer.

`esoph` has the following columns:

1.  **agegp**: A factor indicating the age group of individuals. It categorizes subjects into different age groups, such as "25-34", "35-44", etc.

2.  **alcgp**: A factor indicating the alcohol consumption group. It categorizes subjects into different levels of alcohol consumption, such as "0-39g/day", "40-79g/day", etc.

3.  **tobgp**: A factor indicating the tobacco consumption group. It categorizes subjects into different levels of tobacco consumption, such as "0-9g/day", "10-19g/day", etc.

4.  **ncases**: The number of cases (individuals with esophageal cancer) for the given combination of age group, alcohol, and tobacco consumption.

5.  **ncontrols**: The number of controls (individuals without esophageal cancer) for the given combination of age group, alcohol, and tobacco consumption.

```{r}
library(tidyverse)
library(ggplot)
print(esoph)
```

Make plot to show which `agegp` has the highest frequency of esophageal cases.

```{r}
df <- esoph %>%
  group_by(agegp) %>%
  mutate(cases = ncases / (ncases + ncontrols))

ggplot(df, aes(agegp, cases)) + 
  geom_boxplot() +
  geom_jitter(color = "blue", alpha = 0.5) +
  labs(title = "Frequency of Esophageal cancer per Age Group", x = "Age Group", y = "Frequency")
```

Do the same for `alcgp` and `tobgp`.

```{r}
df <- esoph %>%
  group_by(alcgp) %>%
  mutate(cases = ncases / (ncases + ncontrols))    

ggplot(df, aes(alcgp, cases)) + 
  geom_boxplot() +
  geom_jitter(color = "blue", alpha = 0.5) +
  labs(title = "Frequency of Esophageal cancer per alcohol consumption", x = "Alcohol Consumption", y = "Frequency")
```
```{r}
df <- esoph %>%
  group_by(tobgp) %>%
  mutate(cases = ncases / (ncases + ncontrols))    

ggplot(df, aes(tobgp, cases)) + 
geom_boxplot() +
geom_jitter(color = "blue", alpha = 0.5) +
  labs(title = "Frequency of Esophageal cancer per tobacco consumption", x = "tobacco Consumption", y = "number of cases")
```

Based on the three separate plots you made above, which `alcgp`-`tobgp` combination would you say carries the highes risk for having esophageal cancer? What about lowest risk?

Among the observed alcohol consumption groups, `120+g/day` showed the greatest frequency of getting esophageal cancer. Similarly, consuming `30+g/day` of tobacco is seen to have the greatest frequency. Thus, we predict that the combination of consuming `120+g/day` of alcohol and `30+g/day` of tobacco would lead to highest risk of dveeloping eophageal cancer.

On the other hand, consuming `0-39g/day` of alcohol and `20-29g/day` of tobacco showed the least frequency of esophageal cancer. So, we suspect this combination to have the lowest risk of dveloping the desease.

Let us make a plot with facets to see if our predictions are right.

```{r}
# Compute frequency of cases per alcohol & tobacco group
esoph_summary <- esoph %>%
  group_by(alcgp, tobgp) %>%
  summarise(total_cases = sum(ncases), total_controls = sum(ncontrols), .groups = "drop") %>%
  mutate(freq = total_cases / (total_cases + total_controls))  # Compute frequency

# Plot with facets
ggplot(esoph_summary, aes(x = alcgp, y = freq, fill = tobgp)) +
  geom_col(position = "dodge") +  # Side-by-side bars for each tobacco group
  facet_wrap(~ tobgp) +  # Separate plots for each tobacco consumption level
  theme_minimal() +
  labs(title = "Esophageal Cancer Frequency by Alcohol & Tobacco Consumption",
       x = "Alcohol Consumption Group",
       y = "Frequency of Cases",
       fill = "Tobacco Group")

```

1️⃣ Highest Risk: `120+g/day` Alcohol & `30+g/day` Tobacco

✅ Prediction matches the findings

In the bottom-right panel (yellow, `30+g/day` tobacco), the highest bar corresponds to `120+g/day` alcohol.

This confirms that individuals with both high alcohol and high tobacco consumption have the greatest frequency of esophageal cancer cases.

2️⃣ Lowest Risk: `0-39g/day` Alcohol & `20-29g/day` Tobacco

⚠ Prediction does not fully match the findings

We predicted that the `0-39g/day` alcohol & `20-29g/day` tobacco combination has the lowest risk.

However, in the top-left panel (purple, `0-9g/day` tobacco), the `0-39g/day` alcohol group has the lowest frequency.

The `20-29g/day` tobacco group (green, bottom-left panel) has a higher frequency than the `0-9g/day` tobacco group.

**Revised Interpretation:**

The lowest risk group appears to be `0-39g/day` alcohol & `0-9g/day` tobacco, rather than `20-29g/day` tobacco. However, this would be generalization as `0-9g/day` does not have much data to measure.

The highest risk group (`120+g/day` alcohol & `30+g/day` tobacco) was correctly predicted.

_This plot strongly suggests an interaction effect between alcohol and tobacco, where both together significantly increase esophageal cancer frequency._

```{r}
esoph_mutated <- esoph %>%
  mutate(npeople = ncases + ncontrols) %>%
  mutate(esoph_freq = ncases / npeople)
esoph_mutated

ggplot(data = esoph_mutated, aes(x = agegp, y = esoph_freq, color = agegp)) +
  geom_point() +
  facet_grid(tobgp ~ alcgp) +
  theme_minimal()
```
