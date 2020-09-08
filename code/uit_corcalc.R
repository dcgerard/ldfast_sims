#################
## Estimate Correlation using Naive and MoM
#################

library(updog)
library(ldsep)
uit <- readRDS("./output/uit/uit_updog_fit.RDS")

ploidy <- 4
postarray <- format_multidog(x = uit, varname = paste0("Pr_", 0:ploidy))

nsnp <- dim(postarray)[[1]]
nind <- dim(postarray)[[2]]

pm_mat <-
  apply(X = sweep(x = postarray,
                  MARGIN = 3,
                  STATS = 0:ploidy,
                  FUN = `*`),
        MARGIN = c(1, 2),
        FUN = sum)

## Calculate naive correlation ---------------

time_naive <- system.time(
  cor_naive <- cor(t(pm_mat), use = "pairwise.complete.obs")^2
)

## Calculate MoM correlation -----------------

time_mom <- system.time(
  cor_mom <- ldfast(gp = postarray, type = "r2", se = FALSE, shrinkrr = TRUE, thresh = TRUE)
)

hist(cor_mom$rr)

# Plot naive
hist(cor_mom$ldmat[upper.tri(cor_mom$ldmat)] -
          cor_naive[upper.tri(cor_naive)])

which(cor_mom$ldmat - cor_naive == max(cor_mom$ldmat - cor_naive),
      arr.ind = TRUE)


snp1 <- 1715
snp2 <- 564

larray <- format_multidog(x = uit, varname = paste0("logL_", 0:ploidy))

pm_2 <- format_multidog(x = uit, varname = "postmean")

ldest(ga = pm_2[snp1, ], gb = pm_2[snp2, ], K = 4, type = "comp")["r"]
ldest(ga = larray[snp1, , ], gb = larray[snp2, ,], K = 4)["r"]
ldfast(gp = postarray[c(snp1, snp2), ,])$ldmat[1,2]

var(pm_2[snp1, ])
var(pm_2[snp2, ])

plot(uit, snp1)
plot(uit, snp2)
