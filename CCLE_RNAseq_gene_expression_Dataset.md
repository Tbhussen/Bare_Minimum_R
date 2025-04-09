## Course Author
`Motivating Question
`

`Every analysis that a computational biologist undertakes should be motivated by a clearly stated biological question. Otherwise, how will you know if the data you have is appropriate and what analysis should be done?
`

`So let's do a bit of role-playing. Imagine that we are a team of biologists working for a biotech developing drugs to treat cancer. The biotech is called Figure One Lab (What else did you think I was going to call it?). Our mission is to make drugs that interfere with skin cancer metastasis.
`

`To see if our drugs work, we need to be able to test any anti-metastatic drugs we make on cells that model metastatic skin cancer cells. To start, we have decided to use cancer cell lines, because they are commercially available and relatively easy to grow at the bench. Given the dozens of skin cancer cell lines we can choose from, it's not clear which cell line we should use. We just know that we want to use a cell line that resembles metastatic skin cancer cells.
`

`We start with a bit of literature review. We come across this paper: Riker, A.I., Enkemann, S.A., Fodstad, O. et al. The gene expression profiles of primary and metastatic melanoma yields a transition point of tumor progression and metastasis. BMC Med Genomics 1, 13 (2008). DOI: 10.1186/1755-8794-1-13. Licensed under CC BY 2.0.
`

`From the paper:
`

`We have utilized gene microarray analysis and a variety of molecular techniques to compare 40 metastatic melanoma (MM) samples...to 42 primary cutaneous cancers...`

`...the metastatic melanomas express higher levels of genes such as MAGE, GPR19, BCL2A1, MMP14, SOX5, BUB1, RGS20, and more.`

`The authors describe transcriptional differences between metastatic melanomas and primary melanomas. This seems promising. This motivates us to ask: Based on the gene expression profiles of the metastatic melanomas studied by Riker et al., which skin cancer cell line should we use?`

`Fortunately, we can access the RNA sequencing (RNA-seq) profiles of 1000+ cell lines from the Cancer Cell Line Encyclopedia. We can do some simple exploration of this data to recommend a skin cancer cell line appropriate for testing our drugs.` 

## EDA
The main question at hand is to find the most suitable cancer cell line to test the drug, which will be used to interfere with skin cancer metastasis.
### Format Data
Let us begin by exploring the dataset:

```{r}
# Load the dataset
ccle_counts <- read.csv(paste0(getwd(),"/outs/ccle_subset_rnaseq_counts.csv"))
ccle_counts
```
How many rows and columns does ccle_counts have? What do the rows and columns represent? What does the Name column contain? What does the Description column contain?
```{r}
print(paste("The Dataset contains", dim(ccle_counts)[1], "rows and", dim(ccle_counts)[2], "colums"))

head(ccle_counts$Name)
head(ccle_counts$Description)
colnames(ccle_counts)
```
If we care more about gene-level rather than transcript-level expression, which column is unnecessary to keep? Remove that column.
```{r}
# Remove column Name as it is unnecessary
ccle_counts["Name"] <- NULL
head(ccle_counts)
```
It's important with any dataset to identify duplicated rows/columns early on and handle them before proceeding with downstream analysis. We want to be able to uniquely refer to each row and each column. In this particular case, we want to uniquely refer to each gene (row) and cell line (column).

Does `ccle_counts` have duplicated columns or rows?

```{r}
print(sum(duplicated(colnames(ccle_counts))))
print(sum(duplicated(ccle_counts$Description)))
```
It turns out there are 33 duplicated pairs of genes/rows. One of the ways to deal with duplicated entries for genes in RNA-seq data is to sum them. If we want to sum the counts for duplicated genes, how do we do that?

```{r}
# 
ccle_counts <- ccle_counts %>%
  group_by(Description) %>%
  summarise(across(everything(), sum))
head(ccle_counts)
```
`ccle_counts` now has 17,695 rows instead of 17,728 rows, because you have merged the duplicated genes.

Set the row names of `ccle_counts` to be the values in the `Description` column so that each row is identified as a gene. Remove the `Description` column so that the entire data frame contains only numeric values. Print out `ccle_counts` again to make sure all of these changes took place as intended.

```{r}
# 
ccle_counts <- as.data.frame(ccle_counts)  # Convert tibble to data frame
rownames(ccle_counts) <- ccle_counts$Description  # Set row names
ccle_counts$Description <- NULL
```
### Format Metadata

Read in the CCLE metadata, assign it to a variable called `ccle_meta`, and print it out to visually inspect it.

```{r}
# Load Metadata
ccle_meta <- read.csv(paste0(getwd(),"/data/Cell_lines_annotations_20181226.txt"), header = TRUE, sep = "\t")
print(ccle_meta)
```
Use `table()` to get a sense of the kind of information each column of `ccle_meta` contains.

```{r}
table(ccle_meta$Site_Primary)
```
Keep the columns with information you find useful, which should include `CCLE_ID` and `Site_Primary`. There should be others that you find relevant to our motivating question. Remove the columns that have uninterpretable information or have too many blanks or `NA`s.
```{r}
ccle_meta$Age <- NULL
ccle_meta$Gender <- NULL
```

```{r}
blank_cols <- colnames(ccle_meta)[colSums(ccle_meta == "", na.rm = TRUE) > 50]
ccle_meta[, blank_cols]
ccle_meta[colnames(ccle_meta) %in% blank_cols] <- NULL
ccle_meta
```
```{r}
containing_NA <- colnames(ccle_meta)[colSums(is.na(ccle_meta)) > 400]
containing_NA

ccle_meta[containing_NA] <- NULL
ccle_meta
```
Check how many IDs in `ccle_meta$CCLE_ID` is present in `colnames(ccle_counts)` and vice versa. We should not assume that `ccle_counts` and `ccle_meta` correspond to each other perfectly just because they are downloaded from the same data source. There are often discrepancies that we need to identify and handle.
```{r}
print(sum(ccle_meta$CCLE_ID %in% colnames(ccle_counts)))
print(sum(colnames(ccle_counts) %in% ccle_meta$CCLE_ID))
```
149 out of 149 IDs in `ccle_meta$CCLE_ID` are present in `colnames(ccle_counts)` and vice versa. That's great.

Now we need to make sure that the order of the IDs in `ccle_meta$CCLE_ID` is the same as the order of `colnames(ccle_counts)` and vice versa. Again, we don't assume that `ccle_counts` and `ccle_meta` correspond to each other perfectly just because they are downloaded from the same data source.

```{r}
identical(ccle_meta$CCLE_ID, colnames(ccle_counts))

ccle_meta <- ccle_meta[match(colnames(ccle_counts), ccle_meta$CCLE_ID), ]
ccle_meta
```
### Data Visualization

As we learned before, it is good practice in biological data analysis to have rows correspond to observations and columns correspond to features, especially when it comes to data visualization. Right now `ccle_counts` is not in that format. Fix it.

```{r}
ccle_counts <- ccle_counts %>% t() %>% data.frame()
ccle_counts
```
We also want `ccle_meta$Site_Primary` and `ccle_meta$Pathology` to be added as columns in `ccle_counts`. That makes it easier for us to plot `ccle_counts` with `Site_Primary` and `Pathology` information using `ggplot2`.

```{r}
ccle_counts <- ccle_counts %>% mutate(Site_Primary = ccle_meta$Site_Primary, Pathology = ccle_meta$Pathology)

ccle_counts[c("Site_Primary","Pathology")]
```
Recall now our motivating question: **Based on the gene expression profiles of the metastatic melanomas studied by Riker *et al*., which skin cancer cell line should we use?**

From the article:

> We found higher expression levels in MM for...some genes previously implicated in melanoma progression (*GDF15*, *MMP14*, *SPP1*), cell cycle progression (*CDK2*, *TYMS*, *BUB1*) and the prevention of apoptosis (*BIRC5*, *BCL2A1*).

How do we visualize the expression of these 8 genes to help us pick the best skin cancer cell lines to use? Should we plot the expression of these genes one at a time? Two at a time? By `Site_Primary` or `Pathology`? Should we plot their average? There is not a single right approach here. Try out a bunch of different plots.
```{r}
ggplot(ccle_counts, aes(Site_Primary, "GDF15")) +
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2), color = "purple") +
  labs(title = "GDF15 Expression", y = "GDF15")
ggplot(ccle_counts, aes(Site_Primary, "MMP14")) +
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2), color = "orange") +
  labs(title = "MMP14 Expression", y = "MMP14")
ggplot(ccle_counts, aes(Site_Primary, "SPP1")) +
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2), color = "blue") +
  labs(title = "SPP1 Expression", y = "SPP1")
ggplot(ccle_counts, aes(Site_Primary, "CDK2")) +
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2), color = "green") +
  labs(title = "CDK2 Expression", y = "CDK2")
ggplot(ccle_counts, aes(Site_Primary, "TYMS")) +
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2), color = "red") +
  labs(title = "TYMS Expression", y = "TYMS")

ggplot(ccle_counts, aes("BIRC5")) +
  geom_bar(width = 0.5, color = "grey") +
  facet_wrap(~ Site_Primary) +
  theme_minimal() +
  labs(title = "Count of BIRC5 Expression per tissue", x = "BIRC5", y = "Count")
ggplot(ccle_counts, aes("BCL2A1")) +
  geom_bar(width = 0.5, color = "grey") +
  facet_wrap(~ Site_Primary) +
  theme_minimal() +
  labs(title = "Count of BCL2A1 Expression per tissue", x = "BCL2A1", y = "Count")

ggplot(ccle_counts, aes(Pathology, "GDF15")) +
  geom_boxplot() +
  geom_jitter(position = position_jitter(0.2))
ggplot(ccle_counts, aes(Pathology, "MMP14")) +
  geom_boxplot() +
  geom_jitter(position = position_jitter(0.2))
ggplot(ccle_counts, aes(Pathology, "SPP1")) +
  geom_boxplot() +
  geom_jitter(position = position_jitter(0.2))
```

Now that we have looked at the data in several different ways, we noticed that some cell lines are derived from primary tumor vs metastatic samples. This begs the question: Which of our 8 genes of interest are more highly expressed in skin cancer cell lines with `Pathology=="metastasis"` than in those with `Pathology=="primary"`? 

In other words, can we replicate Riker *et al*.'s observations in our skin cancer cell line RNA-seq data?
```{r}
genes <- c("GDF15", "MMP14", "SPP1", "CDK2", "TYMS", "BUB1", "BIRC5", "BCL2A1")

gene_expression <- ccle_counts %>%
  filter(Site_Primary == "skin") %>%
  select(Pathology, genes)
gene_expression

ggplot(gene_expression, aes(x=Pathology, y=GDF15)) +
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2))
ggplot(gene_expression, aes(x=Pathology, y=MMP14)) +
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2))
ggplot(gene_expression, aes(x=Pathology, y=SPP1)) +
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2))
ggplot(gene_expression, aes(x=Pathology, y=CDK2)) +
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2))
ggplot(gene_expression, aes(x=Pathology, y=TYMS)) +
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2))
ggplot(gene_expression, aes(x=Pathology, y=BUB1)) +
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2))
ggplot(gene_expression, aes(x=Pathology, y=BIRC5)) +
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2))
ggplot(gene_expression, aes(x=Pathology, y=BCL2A1)) +
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2))
```
![image](https://github.com/user-attachments/assets/bc76151c-10f0-47de-a27b-7a58318f85af)
![image](https://github.com/user-attachments/assets/fea7b202-fca7-40fb-bace-f13277b8af2c)
Based on the plots above, the two genes which are the most upregulated in skin cancer cell lines with `Pathology=="metastasis"` than in those with `Pathology=="primary"` are **CDK2** and **TYMS**. 

How could we visualize the data in order to pick out the skin cancer cell line with the highest expression of these two genes?
```{r}
gene_expression <- filter(gene_expression, Pathology == "metastasis")
ggplot(gene_expression, aes(CDK2, rownames(gene_expression))) +
  geom_boxplot()
ggplot(gene_expression, aes(TYMS, rownames(gene_expression))) +
  geom_boxplot()
```
![image](https://github.com/user-attachments/assets/100656c8-55dc-4e7d-b0ab-dccb55bfaf2b)
![image](https://github.com/user-attachments/assets/3e17f18f-bb93-4be3-9385-ced722f8e247)

Based on just the plots above, we choose **COLO792_SKIN** your top skin cancer cell line.

Out of curiosity, how can you visualize the data to check whether there are there any kidney or brain cancer cell lines that also express these two genes at a high level?
```{r}
ggplot(ccle_counts, aes(x = CDK2, y = TYMS)) +
  geom_point() +
  facet_grid(Pathology ~ Site_Primary)
```
![image](https://github.com/user-attachments/assets/8b2f0119-5e9c-4a2a-a18d-c70be9f27173)




