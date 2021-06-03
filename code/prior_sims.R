##########################
## Explore fixed versus adaptive priors
##########################

library(dplyr)
library(updog)
library(ldsep)
library(polyRAD)
library(foreach)
library(doParallel)

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

ploidy <- 8
horse_prior <- c(0.45, rep(0.1 / (ploidy - 1), ploidy - 1), 0.45)

nind <- c(10, 100, 1000, 10000)
size <- c(5, 10, 100)
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
         polyrad_rho = NA_real_,
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
                            gp_updog <- aperm(array(c(updog_A$postmat, updog_B$postmat), dim = c(dim(updog_A$postmat), 2)), perm = c(3, 1, 2))


                            ## Use polyRAD ------------------------------------
                            alleleDepth <- cbind("SNP1_A" = refA,
                                                 "SNP1_a" = sizevec - refA,
                                                 "SNP2_A" = refB,
                                                 "SNP2_a" = sizevec - refB)
                            rownames(alleleDepth) <- paste0("ind", seq_len(nrow(alleleDepth)))
                            class(alleleDepth) <- "integer"
                            alleles2loc <- c(1L, 1L, 2L, 2L)
                            locTable <- data.frame(Chr = rep(1, 2))
                            rownames(locTable) <- c("SNP1", "SNP2")
                            possiblePloidies <- list(ploidy)
                            contamRate <- 0.01
                            alleleNucleotides <- c("A", "C", "A", "C")
                            rd <- polyRAD::RADdata(alleleDepth = alleleDepth,
                                                   alleles2loc = alleles2loc,
                                                   locTable = locTable,
                                                   possiblePloidies = possiblePloidies,
                                                   contamRate = contamRate,
                                                   alleleNucleotides = alleleNucleotides)
                            mydataHWE <- polyRAD::IterateHWE(rd, overdispersion = 9)
                            gp_polyrad <- aperm(mydataHWE$posteriorProb[[1]][,,c(1, 3)], c(3, 2, 1))

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
                            gp_unif <- aperm(array(c(unif_A$postmat, unif_B$postmat), dim = c(dim(unif_A$postmat), 2)), perm = c(3, 1, 2))

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
                            gp_horse <- aperm(array(c(horse_A$postmat, horse_B$postmat), dim = c(dim(horse_A$postmat), 2)), perm = c(3, 1, 2))

                            ## Fit ldsep using different posterior matrices
                            ldf_updog <- ldfast(gp = gp_updog,
                                                type = "r",
                                                shrinkrr = FALSE,
                                                se = TRUE,
                                                thresh = FALSE)

                            ldf_polyrad <- ldfast(gp = gp_polyrad,
                                                  type = "r",
                                                  shrinkrr = FALSE,
                                                  se = TRUE,
                                                  thresh = FALSE)

                            ldf_unif <- ldfast(gp = gp_unif,
                                               type = "r",
                                               shrinkrr = FALSE,
                                               se = TRUE,
                                               thresh = FALSE)

                            ldf_horse <- ldfast(gp = gp_horse,
                                                type = "r",
                                                shrinkrr = FALSE,
                                                se = TRUE,
                                                thresh = FALSE)

                            paramdf$updog_rho[[i]] <- ldf_updog$ldmat[1, 2]
                            paramdf$polyrad_rho[[i]] <- ldf_polyrad$ldmat[1, 2]
                            paramdf$uniform_rho[[i]] <- ldf_unif$ldmat[1, 2]
                            paramdf$horse_rho[[i]] <- ldf_horse$ldmat[1, 2]

                            paramdf[i, ]
                            }

write.csv(x = simdf, file = "./output/prior/prior_sims_out.csv", row.names = FALSE)
