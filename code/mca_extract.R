#####################
## Extact SNPs from McAllister Data
#####################

library(stringr)
library(VariantAnnotation)
anodf <- read.csv("./data/gerardii/McAllister_Miller_Locality_Ploidy_Info.csv",
                  stringsAsFactors = FALSE)
fl <-"./data/gerardii/McAllister.Miller.all.mergedRefGuidedSNPs.vcf.gz"

## Create tabix file
compressVcf <- bgzip(fl, tempfile())
idx <- indexTabix(compressVcf, "vcf")
tab <- TabixFile(compressVcf, idx)

## extract chromosome 1 and read in vcf
chr1_gr = GRanges("1", IRanges(start = 1, end = 75000000))
param <- ScanVcfParam(which = chr1_gr)
mca <- readVcf(tab, "1", param)

## Keep only biallelic snps
which_ba <- sapply(alt(mca), length) == 1
mca <- mca[which_ba, ]

## Remove SNPs with low MAF
which_maf <- info(mca)$AF > 0.05 & info(mca)$AF < 0.95
stopifnot(length(table(sapply(which_maf, length))) == 1)
which_maf <- unlist(which_maf)
mca <- mca[which_maf, ]

## Extract read-count matrices
DP <- geno(mca)$DP
AD <- geno(mca)$AD
stopifnot(length(table(sapply(AD, length))) == 2)

get_elem <- function(x, num) {
  if (length(x) < num) {
    return(NA)
  } else {
    return(x[[num]])
  }
}

refmat <- sapply(AD, get_elem, num = 1)
dim(refmat) <- dim(AD)
dimnames(refmat) <- dimnames(AD)
altmat <- sapply(AD, get_elem, num = 2)
dim(altmat) <- dim(AD)
dimnames(altmat) <- dimnames(AD)
sizemat <- DP

## Remove snps with high missingness
goodsnp <- rowMeans(sizemat, na.rm = TRUE) >= 1
sizemat <- sizemat[goodsnp, ]
refmat <- refmat[goodsnp, ]

## remove individuals with high missingness
goodind <- str_split_fixed(colnames(sizemat), pattern = ":", n = 4)[, 1] %in% anodf$Individual
sizemat <- sizemat[, goodind]
refmat <- refmat[, goodind]

## split individuals based on ploidy
sixind <- anodf$Individual[anodf$Ploidy.Level == 6]
nonind <- anodf$Individual[anodf$Ploidy.Level == 9]
candidate <- str_split_fixed(colnames(sizemat), pattern = ":", n = 4)[, 1]
stopifnot(candidate %in% anodf$Individual)

which_six <- candidate %in% sixind
which_non <- candidate %in% nonind

sizemat_six <- sizemat[, which_six]
refmat_six <- refmat[, which_six]

sizemat_non <- sizemat[, which_non]
refmat_non <- refmat[, which_non]

## Remove duplicated rows
which_bad_six <- duplicated(sizemat_six) & duplicated(refmat_six)
sizemat_six <- sizemat_six[!which_bad_six, ]
refmat_six  <- refmat_six[!which_bad_six, ]

which_bad_non <- duplicated(sizemat_non) & duplicated(refmat_non)
sizemat_non <- sizemat_non[!which_bad_non, ]
refmat_non  <- refmat_non[!which_bad_non, ]

saveRDS(object = sizemat_six, file = "./output/gerardii/sizemat_hex.RDS")
saveRDS(object = refmat_six, file = "./output/gerardii/refmat_hex.RDS")
saveRDS(object = sizemat_non, file = "./output/gerardii/sizemat_non.RDS")
saveRDS(object = refmat_non, file = "./output/gerardii/refmat_non.RDS")
