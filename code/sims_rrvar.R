#############################
## Look at variance of reliability ratios
#############################

library(tidyverse)
library(ggthemes)

sim <- read_csv(file = "./output/sims/simout.csv")
maf <- read_csv(file = "./output/maf/maf_ldfits.csv")


sim %>%
  select(nind,
         size,
         ploidy,
         pA,
         pB,
         Dprime,
         rratio_a,
         rratio_b,
         rratio_a_se,
         rratio_b_se) ->
  sim

maf %>%
  select(nind,
         size,
         ploidy,
         pA = maf,
         pB = oaf,
         Dprime = dprime,
         rratio_a = mom_rr_a,
         rratio_b = mom_rr_b) ->
  maf

sim %>%
  select(nind, size, ploidy, pA, pB, rratio_a_se, rratio_b_se) %>%
  mutate(pab = paste0("(", pA, ",", pB, ")"),
         nind = as.factor(nind)) %>%
  select(-pA, -pB) %>%
  gather(rratio_a_se, rratio_b_se, key = "locus", value = "se") %>%
  select(-locus) %>%
  ggplot(aes(x = nind, y = se, color = pab)) +
  facet_grid(ploidy ~ size, scales = "free_y") +
  geom_boxplot(outlier.size = 0.3) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  scale_color_colorblind(name = "Allele Frequencies") +
  scale_y_log10() +
  xlab("Sample Size") +
  ylab("Estimated Standard Error of Reliability Ratio") ->
  pl

ggsave(filename = "./output/rr_se.pdf",
       plot = pl,
       height = 6.5,
       width = 6.5,
       family = "Times")
