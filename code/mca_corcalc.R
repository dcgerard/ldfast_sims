############################
## Calculate LD using MoM and Naive (MLE too slow)
############################

library(updog)
library(ldsep)
library(corrplot)

ploidy <- 6
mca <- readRDS("./output/gerardii/updog_fits_hex.RDS")
postarray <- format_multidog(x = mca, varname = paste0("Pr_", 0:ploidy))

nsnp <- dim(postarray)[[1]]
nind <- dim(postarray)[[2]]

pm_mat <-
  apply(X = sweep(x = postarray,
                  MARGIN = 3,
                  STATS = 0:ploidy,
                  FUN = `*`),
        MARGIN = c(1, 2),
        FUN = sum)

summary(c(pm_mat))
mean(is.na(pm_mat))

## Calculate naive correlation ---------------

time_naive <- system.time(
  cor_naive <- cor(t(pm_mat), use = "pairwise.complete.obs")^2
)

corrplot(corr = cor_naive[c(1:100, 29000:29100), c(1:100, 29000:29100)],
         type = "upper",
         method = "color",
         diag = FALSE,
         is.corr = FALSE,
         tl.pos = "n",
         title = NULL)

## Calculate MoM correlation -----------------

time_mom <- system.time(
  cor_mom <- ldfast(gp = postarray, type = "r2", se = FALSE)
)

corrplot(corr = cor_mom$ldmat[c(1:100, 29000:29100), c(1:100, 29000:29100)],
         type = "upper",
         method = "color",
         diag = FALSE,
         is.corr = FALSE,
         tl.pos = "n",
         title = NULL)

## Plot results ------------------






