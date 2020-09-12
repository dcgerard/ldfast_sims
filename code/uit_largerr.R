################
## Look at largest rr snps only
################

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

## Calculate covariance -------------
cor_naive <- cor(t(pm_mat), use = "pairwise.complete.obs")^2
mout <- ldfast(gp = postarray,
               type = "r2",
               se = FALSE,
               shrinkrr = TRUE,
               thresh = TRUE)
cor_mom <- mout$ldmat

## Subset to those with largest rr ------------
which_most <- order(mout$rr, decreasing = TRUE)[seq_len(20)]
sub_pm <- pm_mat[which_most, ]
sub_post <- postarray[which_most, , ]
sub_ll <- llarray[which_most, , ]
sub_cnav <- cor_naive[which_most, which_most]
sub_cmom <- cor_mom[which_most, which_most]


## Calculate MLE -------------------------------
mletime <- system.time(
  ldmle <- mldest(geno = sub_ll,
                  K = 4,
                  nc = 1,
                  type = "comp",
                  model = "norm")
)

sub_cmle <- format_lddf(ldmle, element = "r2")

## plot data
library(tidyverse)
library(GGally)

mypoint <- function(data, mapping, ...) {
  ggplot(data, mapping) +
    geom_point() +
    geom_abline(slope = 1, intercept = 0, lty = 2, col = 2) +
    xlim(0, 1) +
    ylim(0, 1)
}
myhist <- function(data, mapping, ...) {
  ggplot(data, mapping) +
    geom_histogram(fill = "white", color = "black", bins = 20)
}
tibble(MLE = sub_cmle[upper.tri(sub_cmle)],
       MoM = sub_cmom[upper.tri(sub_cmom)],
       Naive = sub_cnav[upper.tri(sub_cnav)]) %>%
  ggpairs(lower = list(continuous = mypoint),
          diag = list(continuous = myhist),
          upper = NULL) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) ->
  pl

ggsave(filename = "./output/uit/figs/mle_mom_nav.pdf",
       plot = pl,
       height = 5.5,
       width = 6,
       family = "Times")
