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
The main quation at hand is to find the most suitable cancer cell line to test the drug, which will be used to interfere with skin cancer metastasis.
