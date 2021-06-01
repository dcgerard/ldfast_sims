##########################
## Explore fixed versus adaptive priors
##########################

library(dplyr)
library(updog)
library(fitPoly)
library(ldsep)

ploidy <- 8
horse_prior <- c(0.45, rep(0.1 / (ploidy - 1), ploidy - 1), 0.45)

nind <- c(10, 100, 1000)
size <- c(10, 100)
seq <- 0.01
od <- 0.01
bias <- 1
maf <- 0.5
oaf <- 0.5
rho <- 0.9
itermax <- 200

paramdf <- expand.grid(seed = seq_len(itermax),
                       nind = nind,
                       size = size,
                       seq = seq,
                       od = od,
                       bias = bias,
                       maf = maf,
                       oaf = oaf,
                       rho = rho,
                       ploidy = ploidy)
paramdf$delta <- paramdf$rho * sqrt(paramdf$maf * (1 - paramdf$maf) * paramdf$oaf * (1 - paramdf$oaf))
paramdf$pAB <- paramdf$delta + paramdf$maf * paramdf$oaf
paramdf$pAb <- paramdf$maf - paramdf$pAB
paramdf$paB <- paramdf$oaf - paramdf$pAB
paramdf$pab <- 1 - paramdf$pAB - paramdf$pAb - paramdf$paB

## Sanity check
stopifnot(paramdf$pab >= 0, paramdf$pab <= 1)
stopifnot(paramdf$pAb >= 0, paramdf$pAb <= 1)
stopifnot(paramdf$paB >= 0, paramdf$paB <= 1)
stopifnot(paramdf$pAB >= 0, paramdf$pAB <= 1)

paramdf %>%
  mutate(updog_rho = NA_real_,
         fitPoly_rho = NA_real_,
         uniform_rho = NA_real_,
         horse_rho = NA_real_) ->
  paramdf

## shuffle order to equalize computation time across nodes
paramdf <- paramdf[sample(seq_len(nrow(paramdf))), ]

## Register workers ----------------------------------------------------------
if (nc == 1) {
  foreach::registerDoSEQ()
} else {
  cl = parallel::makeCluster(nc)
  doParallel::registerDoParallel(cl = cl)
  if (foreach::getDoParWorkers() == 1) {
    stop(paste0("nc > 1 but only one core registered from ",
                "foreach::getDoParWorkers()."))
  }
}

i <- 1
simdf <- foreach::foreach(i = seq_len(nrow(paramdf)),
                          .combine = rbind,
                          .export = c("ldest",
                                      "ldfast",
                                      "rflexdog",
                                      "flexdog")) %dopar% {
                            set.seed(paramdf$seed[[i]])

                            # generate data -----------------------------------
                            prob <- c(paramdf$pab[[i]],
                                      paramdf$pAb[[i]],
                                      paramdf$paB[[i]],
                                      paramdf$pAB[[i]])
                            hapmat <- stats::rmultinom(n = paramdf$nind[[i]],
                                                       size = paramdf$ploidy[[i]],
                                                       prob = prob)
                            gA <- hapmat[2, ] + hapmat[4, ]
                            gB <- hapmat[3, ] + hapmat[4, ]
                            sizevec <- rep(paramdf$size[[i]], paramdf$nind[[i]])
                            refA <- updog::rflexdog(sizevec = sizevec,
                                                    geno    = gA,
                                                    ploidy  = paramdf$ploidy[[i]],
                                                    seq     = paramdf$seq[[i]],
                                                    bias    = paramdf$bias[[i]],
                                                    od      = paramdf$od[[i]])
                            refB <- updog::rflexdog(sizevec = sizevec,
                                                    geno    = gB,
                                                    ploidy  = paramdf$ploidy[[i]],
                                                    seq     = paramdf$seq[[i]],
                                                    bias    = paramdf$bias[[i]],
                                                    od      = paramdf$od[[i]])

                            ## Run updog --------------------------------------
                            updog_A <- updog::flexdog(refvec      = refA,
                                                      sizevec     = sizevec,
                                                      ploidy      = paramdf$ploidy[[i]],
                                                      verbose     = FALSE,
                                                      bias_init   = paramdf$bias[[i]],
                                                      update_bias = FALSE,
                                                      seq         = paramdf$seq[[i]],
                                                      update_seq  = FALSE,
                                                      od          = paramdf$od[[i]],
                                                      update_od   = FALSE,
                                                      model       = "hw")
                            updog_B <- updog::flexdog(refvec      = refB,
                                                      sizevec     = sizevec,
                                                      ploidy      = paramdf$ploidy[[i]],
                                                      verbose     = FALSE,
                                                      bias_init   = paramdf$bias[[i]],
                                                      update_bias = FALSE,
                                                      seq         = paramdf$seq[[i]],
                                                      update_seq  = FALSE,
                                                      od          = paramdf$od[[i]],
                                                      update_od   = FALSE,
                                                      model       = "hw")

                            ## Run fitPoly ------------------------------------
                            fa_df <- data.frame(MarkerName = "A",
                                                SampleName = paste0("S", seq_len(paramdf$nind[[i]])),
                                                ratio = refA / sizevec)

                            fb_df <- data.frame(MarkerName = "B",
                                                SampleName = paste0("S", seq_len(paramdf$nind[[i]])),
                                                ratio = refB / sizevec)

                            fitpoly_A <- fitPoly::fitOneMarker(ploidy = paramdf$ploidy[[i]],
                                                               marker = "A",
                                                               data = fa_df,
                                                               p.threshold = 1,
                                                               call.threshold = 0)
                            fitpoly_B <- fitPoly::fitOneMarker(ploidy = paramdf$ploidy[[i]],
                                                               marker = "B",
                                                               data = fb_df,
                                                               p.threshold = 1,
                                                               call.threshold = 0)

                            ## Use uniform prior ------------------------------
                            suppressWarnings({
                            unif_A <- updog::flexdog(refvec      = refA,
                                                     sizevec     = sizevec,
                                                     ploidy      = paramdf$ploidy[[i]],
                                                     verbose     = FALSE,
                                                     bias_init   = paramdf$bias[[i]],
                                                     update_bias = FALSE,
                                                     seq         = paramdf$seq[[i]],
                                                     update_seq  = FALSE,
                                                     od          = paramdf$od[[i]],
                                                     update_od   = FALSE,
                                                     model       = "uniform")
                            unif_B <- updog::flexdog(refvec      = refB,
                                                     sizevec     = sizevec,
                                                     ploidy      = paramdf$ploidy[[i]],
                                                     verbose     = FALSE,
                                                     bias_init   = paramdf$bias[[i]],
                                                     update_bias = FALSE,
                                                     seq         = paramdf$seq[[i]],
                                                     update_seq  = FALSE,
                                                     od          = paramdf$od[[i]],
                                                     update_od   = FALSE,
                                                     model       = "uniform")
                            })

                            ## Use horseshoe fixed prior ----------------------
                            horse_A <- updog::flexdog(refvec      = refA,
                                                      sizevec     = sizevec,
                                                      ploidy      = paramdf$ploidy[[i]],
                                                      verbose     = FALSE,
                                                      bias_init   = paramdf$bias[[i]],
                                                      update_bias = FALSE,
                                                      seq         = paramdf$seq[[i]],
                                                      update_seq  = FALSE,
                                                      od          = paramdf$od[[i]],
                                                      update_od   = FALSE,
                                                      model       = "custom",
                                                      prior_vec   = horse_prior)
                            horse_B <- updog::flexdog(refvec      = refB,
                                                      sizevec     = sizevec,
                                                      ploidy      = paramdf$ploidy[[i]],
                                                      verbose     = FALSE,
                                                      bias_init   = paramdf$bias[[i]],
                                                      update_bias = FALSE,
                                                      seq         = paramdf$seq[[i]],
                                                      update_seq  = FALSE,
                                                      od          = paramdf$od[[i]],
                                                      update_od   = FALSE,
                                                      model       = "custom",
                                                      prior_vec   = horse_prior)

                            }

