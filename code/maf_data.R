##################################
## Generate SNP data for studying small minor allele frequencies.
##################################

library(dplyr)
library(updog)

## Parameters of simulations setting ------------------------------------------

## Number of replications per parameter setting
itermax <- 200

## Proportion from maximum delta prime
delta_prime_seq <- c(0, 0.5, 0.9) # must be between 0 and 1 when in HWE

## Major allele frequency of one locus
maf <- 0.99

## Major allele frequency of other locus
oaf <- c(0.5, 0.9, 0.99)

## number of individuals
nind_vec   <- c(100, 1000)

## depth per individual
size   <- c(10, 100)

## Ploidy of the species
ploidy_seq <- c(2, 4, 6, 8)

## Sequence quality parameters
bias <- 1 # allele bias
od   <- 0.01 # overdispersion
seq  <- 0.01 # sequencing error

## Parameter data frame -------
## Locus A = maf
## Locus B = oaf
paramdf <- expand.grid(size = size,
                       seed = seq_len(itermax),
                       maf = maf,
                       oaf = oaf,
                       dprime = delta_prime_seq,
                       bias   = bias,
                       od     = od,
                       seq    = seq)
paramdf$delta_e <- pmin(paramdf$maf * (1 - paramdf$oaf), (1 - paramdf$maf) * paramdf$oaf)
paramdf$delta <- paramdf$delta_e * paramdf$dprime
paramdf$pAB <- paramdf$delta + paramdf$maf * paramdf$oaf
paramdf$pAb <- paramdf$maf - paramdf$pAB
paramdf$paB <- paramdf$oaf - paramdf$pAB
paramdf$pab <- 1 - paramdf$pAB - paramdf$pAb - paramdf$paB
paramdf$r <- paramdf$delta / sqrt(paramdf$maf * (1 - paramdf$maf) * paramdf$oaf * (1 - paramdf$oaf))

## Sanity check
stopifnot(paramdf$pab >= 0, paramdf$pab <= 1)
stopifnot(paramdf$pAb >= 0, paramdf$pAb <= 1)
stopifnot(paramdf$paB >= 0, paramdf$paB <= 1)
stopifnot(paramdf$pAB >= 0, paramdf$pAB <= 1)

reflist <- list()
sizelist <- list()
m <- 1
for (j in seq_along(ploidy_seq)) {
  ploidy <- ploidy_seq[[j]]
  for (k in seq_along(nind_vec)) {
    nind <- nind_vec[[k]]
    reflist[[m]] <- matrix(NA_real_, nrow = 2 * nrow(paramdf), ncol = nind)
    sizelist[[m]] <- matrix(NA_real_, nrow = 2 * nrow(paramdf), ncol = nind)
    names(reflist)[[m]] <- paste0("ploidy", ploidy, "_nind", nind)
    names(sizelist)[[m]] <- paste0("ploidy", ploidy, "_nind", nind)
    colnames(reflist[[m]]) <- paste0("ind", seq_len(nind))
    rownames(reflist[[m]]) <- paste0("snp", seq_len(nrow(reflist[[m]])))
    colnames(sizelist[[m]]) <- paste0("ind", seq_len(nind))
    rownames(sizelist[[m]]) <- paste0("snp", seq_len(nrow(reflist[[m]])))

    ell <- 1
    for (i in seq_len(nrow(paramdf))) {
      set.seed(paramdf$seed[[i]])

      # generate data -----------------------------------
      prob <- c(paramdf$pab[[i]],
                paramdf$pAb[[i]],
                paramdf$paB[[i]],
                paramdf$pAB[[i]])
      hapmat <- stats::rmultinom(n = nind,
                                 size = ploidy,
                                 prob = prob)
      gA <- hapmat[2, ] + hapmat[4, ]
      gB <- hapmat[3, ] + hapmat[4, ]
      sizevec <- rep(paramdf$size[[i]], nind)
      refA <- updog::rflexdog(sizevec = sizevec,
                              geno    = gA,
                              ploidy  = ploidy,
                              seq     = paramdf$seq[[i]],
                              bias    = paramdf$bias[[i]],
                              od      = paramdf$od[[i]])
      refB <- updog::rflexdog(sizevec = sizevec,
                              geno    = gB,
                              ploidy  = ploidy,
                              seq     = paramdf$seq[[i]],
                              bias    = paramdf$bias[[i]],
                              od      = paramdf$od[[i]])

      reflist[[m]][ell, ] <- refA
      reflist[[m]][ell + 1, ] <- refB
      sizelist[[m]][ell, ] <- sizevec
      sizelist[[m]][ell + 1, ] <- sizevec
      ell <- ell + 2
    }
    m <- m + 1
  }
}

save(reflist, sizelist, paramdf, file = "./output/maf/maf_reads.RData")
