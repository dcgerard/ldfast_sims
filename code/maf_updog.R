########################
## Fit updog on maf_reads
########################

library(updog)
library(stringr)

# Number of threads to use for multithreaded computing. This must be
# specified in the command-line shell; e.g., to use 8 threads, run
# command
#
#  R CMD BATCH '--args nc=8' sims.R
#
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  nc <- 1
} else {
  eval(parse(text = args[[1]]))
}

cat(nc, "\n")

## Load data
load("./output/maf/maf_reads.RData")
stopifnot(length(reflist) == length(sizelist))
od <- unique(paramdf$od)
bias <- unique(paramdf$bias)
seq <- unique(paramdf$seq)
stopifnot(length(od) == 1, length(bias) == 1, length(seq) == 1)

## Fit updog
for (i in seq_along(reflist)) {
  ploidy <- as.numeric(str_extract(names(reflist)[[i]], "\\d+"))
  nind <- as.numeric(str_match(names(reflist)[[i]], "nind(\\d+)")[[2]])
  mout <- multidog(refmat = reflist[[i]],
                   sizemat = sizelist[[i]],
                   ploidy = ploidy,
                   od = od,
                   bias_init = bias,
                   seq = seq,
                   update_od = FALSE,
                   update_bias = FALSE,
                   update_seq = FALSE,
                   nc = nc)
  saveRDS(object = mout, file = paste0("./output/maf/maf_ufit_ploidy", ploidy, "_nind", nind, ".RDS"))
}
