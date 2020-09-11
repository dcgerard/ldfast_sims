############################
## Leave-one-out cross validation using largest rr
############################

## load data ----------
library(updog)
library(ldsep)
uit <- readRDS("./output/uit/uit_updog_fit.RDS")
ploidy <- 4
postarray <- format_multidog(x = uit, varname = paste0("Pr_", 0:ploidy))
pm_mat <- format_multidog(x = uit, varname = "postmean")

## remotve duplicates -----
uni_snp <- !duplicated(pm_mat)
postarray <- postarray[uni_snp, , ]
pm_mat <- pm_mat[uni_snp, ]

nsnp <- dim(postarray)[[1]]
nind <- dim(postarray)[[2]]

## Calculate covariance -------------
cov_naive <- cov(t(pm_mat), use = "pairwise.complete.obs")
mout <- ldfast(gp = postarray, type = "D", se = FALSE, shrinkrr = TRUE, thresh = TRUE)
cov_mom <- mout$ldmat * ploidy

## Subset to those with largest rr ------------
which_most <- order(mout$rr, decreasing = TRUE)[seq_len(50)]
sub_pm <- pm_mat[which_most, ]
sub_post <- postarray[which_most, , ]
muhat <- rowMeans(sub_pm) ## use this as estimated mean for everything
nsubsnp <- length(muhat)

## Leave one out cross validation naive -----------
err_naive <- rep(0, nsubsnp)
for (i in seq_len(nind)) {
  cv_dat <- sub_pm[, -i]
  sigma <- cov(t(sub_pm), use = "pairwise.complete.obs")
  for (j in seq_len(nsubsnp)) {
    yhat <- muhat[[j]] + sigma[j, -j , drop = FALSE] %*% (solve(sigma[-j, -j]) %*% (sub_pm[-j, i, drop = FALSE] - muhat[-j]))
    y <- sub_pm[j, i]
    err_naive[[j]] <- err_naive[[j]] + (yhat - y)^2
  }
}
err_naive <- err_naive / nind
err_naive


## Leave one out cross validation MoM -----------
err_mom <- rep(0, nsubsnp)
for (i in seq_len(nind)) {
  cv_dat <- sub_post[, -i, ]
  mout <- ldfast(gp = cv_dat, type = "D", se = FALSE, shrinkrr = TRUE, thresh = TRUE)
  sigma <- mout$ldmat * ploidy
  for (j in seq_len(nsubsnp)) {
    yhat <- muhat[[j]] + sigma[j, -j , drop = FALSE] %*% (solve(sigma[-j, -j]) %*% (sub_pm[-j, i, drop = FALSE] - muhat[-j]))
    y <- sub_pm[j, i]
    err_mom[[j]] <- err_mom[[j]] + (yhat - y)^2
  }
}
err_mom <- err_mom / nind
err_mom





