#####################
## Look at monoallelic snp
#####################

library(updog)
library(ldsep)
library(tidyverse)

uitsing <- readRDS("./data/uitmono.RDS")

## Plot the uit snps -----------
uitsing$inddf %>%
  mutate(alt = size - ref) %>%
  ggplot(aes(x = alt, ref)) +
  geom_point() +
  xlim(0, 205) +
  ylim(0, 205) +
  xlab("Alternative Counts") +
  ylab("Reference Counts") +
  theme_bw() +
  facet_grid(.~snp) +
  theme(strip.background = element_rect(fill = "white")) ->
  pl

ggsave(filename = "./output/uit/mono_plot.pdf",
       plot = pl,
       family = "Times",
       height = 3.5,
       width = 6.5)

## LD calculation ----------
gp <- format_multidog(x = uitsing, varname = paste0("Pr_", 0:4))
ll <- format_multidog(x = uitsing, varname = paste0("logL_", 0:4))
pm <- format_multidog(x = uitsing, varname = "postmean")

mldest(geno = ll, K = 4, type = "comp")[["r"]]
mldest(geno = pm, K = 4, type = "comp")[["r"]]
ldfast(gp = gp, type = "r", shrinkrr = FALSE, se = FALSE, thresh = FALSE)

