#######################
## Estimate LD from updog fits
#######################

library(ldsep)
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

flist <- list.files(path = "./output/maf/ufit/", full.names = TRUE)

ploidy_vec <- as.numeric(str_match(flist, "ploidy(\\d+)")[, 2])
nind_vec <- as.numeric(str_match(flist, "nind(\\d+)")[, 2])

load("./output/maf/maf_reads.RData")

for (i in seq_along(flist)) {
  mout <- readRDS(file = flist[[i]])
  ploidy <- ploidy_vec[[i]]
  nind <- nind_vec[[i]]

  inddf <- cbind(seq(1, nrow(mout$snpdf), by = 2), seq(2, nrow(mout$snpdf), by = 2))
  npairs <- nrow(inddf)
  dprime_df <- data.frame(ploidy        = ploidy,
                          nind          = nind,
                          mom_dprime    = rep(NA_real_, npairs),
                          mom_rr_a      = NA_real_,
                          mom_rr_b      = NA_real_,
                          rr_se_a       = NA_real_,
                          rr_se_b       = NA_real_,
                          shrink_dprime = NA_real_,
                          shrink_rr_a   = NA_real_,
                          shrink_rr_b   = NA_real_,
                          mle_dprime    = NA_real_,
                          naive_dprime  = NA_real_)

  dprime_df <- cbind(paramdf, dprime_df)

  ## Fit new moment based approach
  gp <- format_multidog(x = mout, varname = paste0("Pr_", 0:ploidy))
  mom_out <- ldfast(gp = gp,
                    type = "Dprime",
                    shrinkrr = FALSE,
                    se = FALSE,
                    thresh = FALSE,
                    win = 1)
  dprime_df$mom_dprime <- mom_out$ldmat[inddf]
  dprime_df$mom_rr_a <- mom_out$rr[seq(1, length(mom_out$rr), by = 2)]
  dprime_df$mom_rr_b <- mom_out$rr[seq(2, length(mom_out$rr), by = 2)]

  ## Moment-based with shrinkage
  shrink_out <- ldfast(gp = gp,
                       type = "Dprime",
                       shrinkrr = TRUE,
                       se = FALSE,
                       thresh = TRUE,
                       win = 1)
  dprime_df$shrink_dprime <- shrink_out$ldmat[inddf]
  dprime_df$shrink_rr_a <- shrink_out$rr[seq(1, length(shrink_out$rr), by = 2)]
  dprime_df$shrink_rr_b <- shrink_out$rr[seq(2, length(shrink_out$rr), by = 2)]
  dprime_df$rr_se_a <- shrink_out$rr_se[seq(1, length(shrink_out$rr), by = 2)]
  dprime_df$rr_se_b <- shrink_out$rr_se[seq(2, length(shrink_out$rr), by = 2)]

  ## MLE
  gl <- format_multidog(x = mout, varname = paste0("logL_", 0:ploidy))
  mle_out <- sldest(geno = gl,
                    K = ploidy,
                    win = 1,
                    nc = nc,
                    type = "comp",
                    se = FALSE)
  mle_out <- mle_out[seq(1, nrow(mle_out), by = 2), ]
  dprime_df$mle_dprime <- mle_out$Dprime

  ## Naive
  pm <- format_multidog(x = mout, varname = "postmean")
  naive_out <- sldest(geno = pm,
                      K = ploidy,
                      win = 1,
                      nc = nc,
                      type = "comp",
                      se = FALSE)
  naive_out <- naive_out[seq(1, nrow(naive_out), by = 2), ]
  dprime_df$naive_dprime <- naive_out$Dprime

  if (i == 1) {
    dtot <- dprime_df
  } else {
    dtot <- rbind(dtot, dprime_df)
  }
}

write.csv(x = dtot,
          file = "./output/maf/maf_ldfits.csv",
          row.names = FALSE)
