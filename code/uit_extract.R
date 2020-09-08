############################
##  Extract Uitdewilligen SNPS
############################

library(vcfR)
library(tidyverse)
uitvcf <- read.vcfR(file = "./data/uit/NewPlusOldCalls.headed.vcf")
uitdf <- read_csv2("./data/uit/CSV-file S1 - Sequence variants filtered DP15.csv",
                   na = "#N/A")

## Filter for a single super scaffold
uitdf %>%
  count(`Super Scaffold`) %>%
  arrange(desc(n)) %>%
  head()

## sucrose contig
uitdf %>%
  filter(`Super Scaffold` == "PGSC0003DMB000000192") ->
  subuitdf


which_keep <- getFIX(uitvcf)[, "ID"] %in% subuitdf$`Variant name`
stopifnot(sum(which_keep) == nrow(subuitdf))


refmat  <- extract.gt(uitvcf, element = "RA")
class(refmat) <- "numeric"
sizemat <- extract.gt(uitvcf, element = "DP")
class(sizemat) <- "numeric"

subref <- refmat[which_keep, ]
subsize <- sizemat[which_keep, ]

stopifnot(rownames(subref) == subuitdf$`Variant name`)
stopifnot(rownames(subsize) == subuitdf$`Variant name`)

write_csv(x = subuitdf, path = "./output/uit/uit_suc.csv")
saveRDS(object = subref, file = "./output/uit/refmat_suc.RDS")
saveRDS(object = subsize, file = "./output/uit/sizemat_suc.RDS")
