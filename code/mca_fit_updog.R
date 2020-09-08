#################################
## Fit updog on McAllister Snps
#################################

library(updog)

# Number of threads to use for multithreaded computing. This must be
# specified in the command-line shell; e.g., to use 8 threads, run
# command
#
#  R CMD BATCH '--args nc=8' mca_fit_updog.R
#
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  nc <- 1
} else {
  eval(parse(text = args[[1]]))
}
cat(nc, "\n")

refhex <- readRDS("./output/gerardii/refmat_hex.RDS")
sizehex <- readRDS("./output/gerardii/sizemat_hex.RDS")
mouthex <- multidog(refmat  = refhex,
                    sizemat = sizehex,
                    ploidy = 6,
                    model = "hw",
                    nc = nc,
                    bias_init = 1,
                    seq = 0.001,
                    od = 0.01,
                    update_bias = FALSE,
                    update_od = FALSE,
                    update_seq = FALSE)

saveRDS(object = mouthex, file = "./output/gerardii/updog_fits_hex.RDS")

