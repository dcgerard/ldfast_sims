###########################
## Look at SNPs with large sd on reliability ratios. See shrinkage in action.
###########################

## load data ----------
library(updog)
library(ldsep)
uit <- readRDS("./output/uit/uit_updog_fit.RDS")
ploidy <- 4

## remotve duplicates -----
pm_mat <- format_multidog(x = uit, varname = "postmean")
uni_snp <- !duplicated(pm_mat)
uit <- filter_snp(uit, snp %in% uit$snpdf$snp[uni_snp])
postarray <- format_multidog(x = uit, varname = paste0("Pr_", 0:ploidy))
pm_mat <- format_multidog(x = uit, varname = "postmean")
llarray <- format_multidog(x = uit, varname = paste0("logL_", 0:4))

nsnp <- dim(postarray)[[1]]
nind <- dim(postarray)[[2]]

## Manually calculate rr and se ----
pm_mat <- matrix(NA_real_, nrow = nsnp, ncol = nind)
pv_mat <- matrix(NA_real_, nrow = nsnp, ncol = nind)
ldsep:::fill_pm(pm = pm_mat, gp = postarray)
ldsep:::fill_pv(pv = pv_mat, pm = pm_mat, gp = postarray)
varx <- matrixStats::rowVars(x = pm_mat, na.rm = TRUE)
muy <- rowMeans(x = pv_mat, na.rm = TRUE)
rr <- (muy + varx) / varx
amom <- abind::abind(pm_mat, pm_mat^2, pv_mat, along = 3)
mbar <- apply(X = amom, MARGIN = 3, FUN = rowMeans, na.rm = TRUE)
covarray <- apply(X = amom, MARGIN = 1, FUN = stats::cov, use = "pairwise.complete.obs")
dim(covarray) <- c(3, 3, nsnp)
gradmat <- matrix(NA_real_, nrow = nsnp, ncol = 3)
gradmat[, 1] <-
  -2 * mbar[, 1] / (mbar[, 3] + mbar[, 2] - mbar[, 1]^2) +
  2 * mbar[, 1] / (mbar[, 2] - mbar[, 1]^2)
gradmat[, 2] <-
  1 / (mbar[, 3] + mbar[, 2] - mbar[, 1]^2) -
  1 / (mbar[, 2] - mbar[, 1]^2)
gradmat[, 3] <-
  1 / (mbar[, 3] + mbar[, 2] - mbar[, 1]^2)
svec <- rep(NA_real_, nsnp) # Variances for log rr
nvec <- rowSums(!is.na(pm_mat))
for (i in seq_len(nsnp)) {
  svec[[i]] <- gradmat[i, , drop = FALSE] %*% covarray[, , i, drop = TRUE] %*% t(gradmat[i, , drop = FALSE])
}
svec <- svec / nvec
svec[svec < 0] <- 0
lvec <- log(rr)

## Plot bad snp
library(tidyverse)
library(ggthemes)
library(gridExtra)
tibble(l = lvec, s = sqrt(svec)) %>%
  mutate(islarge = s > 0.2) %>%
  ggplot(aes(x = l, y = s, color = islarge)) +
  geom_point() +
  theme_bw() +
  xlab("Log of Reliability Ratio") +
  ylab("Estimated Standard Error") +
  scale_color_colorblind(guide = FALSE) +
  ggtitle("(A)") ->
  pl1

badsnp1 <- order(svec, decreasing = TRUE)[[1]]
indout <- filter_snp(uit, snp == uit$snpdf$snp[[badsnp1]])$inddf
indout %>%
  mutate(alt = size - ref) %>%
  ggplot(aes(x = alt, y = ref)) +
  geom_point() +
  xlim(0, 120) +
  ylim(0, 120) +
  theme_bw() +
  xlab("Alternative Counts") +
  ylab("Reference Counts") +
  ggtitle("(B)")  ->
  pl2

badsnp2 <- order(svec, decreasing = TRUE)[[2]]
indout <- filter_snp(uit, snp == uit$snpdf$snp[[badsnp2]])$inddf
indout %>%
  mutate(alt = size - ref) %>%
  ggplot(aes(x = alt, y = ref)) +
  geom_point() +
  xlim(0, 125) +
  ylim(0, 125) +
  theme_bw() +
  xlab("Alternative Counts") +
  ylab("Reference Counts") +
  ggtitle("(C)")  ->
  pl3

## Fit ASH
ashout <- ashr::ash(betahat = lvec,
                    sebetahat = sqrt(svec),
                    mixcompdist = "uniform",
                    mode = 0)
rr_shrink <- exp(ashr::get_pm(a = ashout))

tibble(r = rr, newrr = rr_shrink, s = sqrt(svec)) %>%
  mutate(islarge = s > 0.2) %>%
  ggplot(aes(x = r, y = newrr, color = islarge)) +
  geom_point() +
  scale_color_colorblind(guide = FALSE) +
  theme_bw() +
  geom_abline(intercept = 0, slope = 1, lty = 2, col = 2) +
  xlab("Raw Reliability Ratio") +
  ylab("Shrunken Reliability Ratio") +
  ggtitle("(D)")  ->
  pl4

pdf(file = "./output/uit/figs/highsdsnp.pdf",
    height = 6.5,
    width = 6.5,
    family = "Times")
grid.arrange(pl1, pl2, pl3, pl4, nrow = 2, ncol = 2)
dev.off()
