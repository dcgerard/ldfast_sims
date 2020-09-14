#################
## Estimate Correlation using Naive and MoM
#################

library(updog)
library(ldsep)
library(tidyverse)
library(latex2exp)
uit <- readRDS("./output/uit/uit_updog_fit.RDS")

ploidy <- 4
postarray <- format_multidog(x = uit, varname = paste0("Pr_", 0:ploidy))

nsnp <- dim(postarray)[[1]]
nind <- dim(postarray)[[2]]

pm_mat <- format_multidog(x = uit, varname = "postmean")

## Calculate naive correlation ---------------

time_naive <- system.time(
  cor_naive <- cor(t(pm_mat), use = "pairwise.complete.obs")^2
)

## Calculate MoM correlation -----------------

time_mom <- system.time(
  cor_mom <- ldfast(gp = postarray, type = "r2", se = FALSE, shrinkrr = TRUE, thresh = TRUE)
)

timedf <- as_tibble(rbind(time_mom, time_naive))
timedf$method <- c("MoM", "Naive")
write_csv(x = timedf, path = "./output/uit/time_uit.csv")

ggplot(data.frame(rr = cor_mom$rr), aes(x = rr)) +
  geom_histogram(fill = "white", color = "black", bins = 30) +
  theme_bw() +
  xlab("Reliability Ratio Estimate") ->
  pl

ggsave(filename = "./output/uit/figs/rr_hist.pdf",
       plot = pl,
       family = "Times",
       height = 2.5,
       width = 4)
