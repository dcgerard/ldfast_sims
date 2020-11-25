################
## Run simulations comparing fast LD to naive using posterior mean and normal MLE
################

set.seed(1)
library(updog)
library(ldsep)
library(dplyr)
library(foreach)
library(doParallel)

# Number of threads to use for multithreaded computing. This must be
# specified in the command-line shell; e.g., to use 8 threads, run
# command
#
#  R CMD BATCH '--args nc=8' mouthwash_sims.R
#
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  nc <- 1
} else {
  eval(parse(text = args[[1]]))
}

cat(nc, "\n")

## Parameters of simulations setting ------------------------------------------
nind   <- c(10, 100, 1000) # number of individuals
size   <- c(10, 100) # depth per individual
ploidy <- c(2, 4, 6, 8)

# major allele frequencies and D
rseq <- c(0, 0.5, 0.9) ## r has to be less than 0.57 in the 0.5/0.75 scenario
p0505  <- lapply(c(0, 0.5, 0.9) * sqrt(0.5^4), function(x) c("pA" = 0.5, "pB" = 0.5, "D" = x))
p05075 <- lapply(c(0, 0.5) * sqrt(0.5^2 * 0.25 * 0.75), function(x) c("pA" = 0.5, "pB" = 0.75, "D" = x))
p0909  <- lapply(c(0, 0.5, 0.9) * sqrt(0.9^2 * 0.1^2), function(x) c("pA" = 0.9, "pB" = 0.9, "D" = x))
papbd  <- c(p0505, p05075, p0909)

bias <- 1 # allele bias
od   <- 0.01 # overdispersion
seq  <- 0.01 # sequencing error

itermax <- 200

get_Dprime <- function(pab, pAb, paB, pAB) {
  pA <- pAb + pAB
  pB <- paB + pAB
  D  <- pAB - pA * pB
  Dprime <- ifelse(D < 0,
                   D / pmin(pA * pB, (1 - pA) * (1 - pB)),
                   D / pmin(pA * (1 - pB), (1 - pA) * pB))
  return(Dprime)
}

get_Dprimeg <- function(pab, pAb, paB, pAB, K) {
  qmat <- ldsep::get_prob_array(K = K, prob = c(pab, pAb, paB, pAB), log_p = FALSE)
  ldout <- ldsep::Dprime(qmat = qmat, type = "geno")
  return(ldout[["Dprime"]])
}

paramdf <- expand.grid(seed   = seq_len(itermax),
                       nind   = nind,
                       size   = size,
                       papd   = papbd,
                       bias   = bias,
                       od     = od,
                       seq    = seq,
                       ploidy = ploidy)
paramdf <- cbind(paramdf, do.call(rbind, paramdf$papd))
paramdf %>%
  select(-papd) %>%
  mutate(pAB = D + pA * pB,
         pAb = pA - pAB,
         paB = pB - pAB,
         pab = 1 - paB - pAb - pAB,
         r2  = round(D ^ 2 / (pA * (1 - pA) * pB * (1 - pB)), digits = 2),
         r   = sign(D) * sqrt(r2),
         z   = atanh(r),
         Dprime = get_Dprime(pab = pab, pAb = pAb, paB = paB, pAB = pAB)) %>%
  rowwise() %>%
  mutate(Dprimeg = get_Dprimeg(pab = pab, pAb = pAb, paB = paB, pAB = pAB, K = ploidy)) ->
  paramdf

## confirm parameters
stopifnot(abs(sort(rseq) - sort(unique(paramdf$r))) < 0.0001)
stopifnot(paramdf$pAB > 0, paramdf$pAB < 1,
          paramdf$paB > 0, paramdf$paB < 1,
          paramdf$pAb > 0, paramdf$pAb < 1,
          paramdf$pab > 0, paramdf$pab < 1)

# populate columns to be filled ----------------------------------------------
paramdf %>%
  mutate(naive_D_est       = NA_real_,
         naive_D_se        = NA_real_,
         naive_Dprime_est  = NA_real_,
         naive_Dprime_se   = NA_real_,
         naive_Dprimeg_est = NA_real_,
         naive_Dprimeg_se  = NA_real_,
         naive_r2_est      = NA_real_,
         naive_r2_se       = NA_real_,
         naive_z_est       = NA_real_,
         naive_z_se        = NA_real_,
         naive_r_est       = NA_real_,
         naive_r_se        = NA_real_,
         naive_time        = NA_real_,
         fast_r2_est       = NA_real_,
         fast_r2_se        = NA_real_,
         fast_z_est        = NA_real_,
         fast_z_se         = NA_real_,
         fast_r_est        = NA_real_,
         fast_r_se         = NA_real_,
         fast_D_est        = NA_real_,
         fast_D_se         = NA_real_,
         fast_Dprime_est   = NA_real_,
         fast_Dprime_se    = NA_real_,
         fast_time         = NA_real_,
         mle_D_est         = NA_real_,
         mle_D_se          = NA_real_,
         mle_Dprime_est    = NA_real_,
         mle_Dprime_se     = NA_real_,
         mle_r2_est        = NA_real_,
         mle_r2_se         = NA_real_,
         mle_z_est         = NA_real_,
         mle_z_se          = NA_real_,
         mle_r_est         = NA_real_,
         mle_r_se          = NA_real_,
         mle_time          = NA_real_) ->
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
                            foutA <- updog::flexdog(refvec      = refA,
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
                            foutB <- updog::flexdog(refvec      = refB,
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

                            ## Estimate ld ------------------------------------
                            tryCatch({
                              paramdf$naive_time[[i]] <- system.time(
                                ldnaive <- ldsep::ldest(ga = foutA$postmean,
                                                        gb = foutB$postmean,
                                                        K = paramdf$ploidy[[i]],
                                                        type = "comp")
                              )[[3]]

                              paramdf$naive_D_est[[i]]        <- ldnaive[["D"]]
                              paramdf$naive_D_se[[i]]         <- ldnaive[["D_se"]]
                              paramdf$naive_Dprime_est[[i]]   <- ldnaive[["Dprime"]]
                              paramdf$naive_Dprime_se[[i]]    <- ldnaive[["Dprime_se"]]
                              paramdf$naive_Dprimeg_est[[i]]  <- ldnaive[["Dprimeg"]]
                              paramdf$naive_Dprimeg_se[[i]]   <- ldnaive[["Dprimeg_se"]]
                              paramdf$naive_r2_est[[i]]       <- ldnaive[["r2"]]
                              paramdf$naive_r2_se[[i]]        <- ldnaive[["r2_se"]]
                              paramdf$naive_z_est[[i]]        <- ldnaive[["z"]]
                              paramdf$naive_z_se[[i]]         <- ldnaive[["z_se"]]
                              paramdf$naive_r_est[[i]]        <- ldnaive[["r"]]
                              paramdf$naive_r_se[[i]]         <- ldnaive[["r_se"]]
                            }, error = function(e) NULL)

                            tryCatch({
                              gp <- aperm(array(c(foutA$postmat, foutB$postmat), dim = c(dim(foutA$postmat), 2)), perm = c(3, 1, 2))
                              # stopifnot(gp[1, , ] == foutA$postmat)
                              # stopifnot(gp[2, , ] == foutB$postmat)

                              paramdf$fast_time[[i]] <-
                                system.time(
                                  ldf <- ldfast(gp = gp, type = "r",
                                                shrinkrr = FALSE,
                                                se = TRUE,
                                                thresh = FALSE)
                                )[[3]]
                              paramdf$fast_r_est[[i]]  <- ldf$ldmat[[1, 2]]
                              paramdf$fast_r_se[[i]] <- ldf$semat[[1, 2]]

                              ldf <- ldfast(gp = gp, type = "r2",
                                            shrinkrr = FALSE,
                                            se = TRUE,
                                            thresh = FALSE)
                              paramdf$fast_r2_est[[i]]  <- ldf$ldmat[[1, 2]]
                              paramdf$fast_r2_se[[i]] <- ldf$semat[[1, 2]]

                              ldf <- ldfast(gp = gp, type = "z",
                                            shrinkrr = FALSE,
                                            se = TRUE,
                                            thresh = FALSE)
                              paramdf$fast_z_est[[i]]  <- ldf$ldmat[[1, 2]]
                              paramdf$fast_z_se[[i]] <- ldf$semat[[1, 2]]

                              ldf <- ldfast(gp = gp, type = "D",
                                            shrinkrr = FALSE,
                                            se = TRUE,
                                            thresh = FALSE)
                              paramdf$fast_D_est[[i]]  <- ldf$ldmat[[1, 2]]
                              paramdf$fast_D_se[[i]] <- ldf$semat[[1, 2]]

                              ldf <- ldfast(gp = gp, type = "Dprime",
                                            shrinkrr = FALSE,
                                            se = TRUE,
                                            thresh = FALSE)
                              paramdf$fast_Dprime_est[[i]]  <- ldf$ldmat[[1, 2]]
                              paramdf$fast_Dprime_se[[i]] <- ldf$semat[[1, 2]]
                            }, error = function(e) NULL)

                            tryCatch({
                              paramdf$mle_time[[i]] <- system.time(
                                ldmle <- ldsep::ldest(ga = foutA$genologlike,
                                                      gb = foutB$genologlike,
                                                      K = paramdf$ploidy[[i]],
                                                      type = "hap",
                                                      pen = 1.0001)
                              )[[3]]

                              paramdf$mle_D_est[[i]]        <- ldmle[["D"]]
                              paramdf$mle_D_se[[i]]         <- ldmle[["D_se"]]
                              paramdf$mle_Dprime_est[[i]]   <- ldmle[["Dprime"]]
                              paramdf$mle_Dprime_se[[i]]    <- ldmle[["Dprime_se"]]
                              paramdf$mle_r2_est[[i]]       <- ldmle[["r2"]]
                              paramdf$mle_r2_se[[i]]        <- ldmle[["r2_se"]]
                              paramdf$mle_z_est[[i]]        <- ldmle[["z"]]
                              paramdf$mle_z_se[[i]]         <- ldmle[["z_se"]]
                              paramdf$mle_r_est[[i]]        <- ldmle[["r"]]
                              paramdf$mle_r_se[[i]]         <- ldmle[["r_se"]]
                            }, error = function(e) NULL)

                            paramdf[i, , drop = FALSE]
                          }

if (nc > 1) {
  parallel::stopCluster(cl)
}

write.csv(simdf, "./output/sims/simout.csv", row.names = FALSE)
