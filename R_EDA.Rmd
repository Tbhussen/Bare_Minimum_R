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
