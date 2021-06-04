##################
## Plot results of maf_run.R
##################

library(tidyverse)
library(ggthemes)
library(latex2exp)

maf <- read_csv(file = "./output/maf/maf_ldfits.csv")

maf %>%
  select(nind,
         size,
         oaf,
         dprime,
         ploidy,
         naive = naive_dprime,
         mom = mom_dprime,
         mle = mle_dprime) %>%
  gather(naive, mom, mle, key = "method", value = "estimate") %>%
  filter(size == 100, oaf == 0.99) %>%
  mutate(nind = as.factor(nind)) %>%
  ggplot(aes(x = nind, y = estimate, color = method)) +
  facet_grid(dprime ~ ploidy) +
  geom_boxplot() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  scale_color_colorblind() -> temp

size_seq <- unique(maf$size)
oaf_seq <- unique(maf$oaf)

for (i in seq_along(size_seq)) {
  size_c <- size_seq[[i]]
  for (j in seq_along(oaf_seq)) {
    oaf_c <- oaf_seq[[j]]
    maf %>%
      select(nind,
             size,
             oaf,
             dprime,
             ploidy,
             Naive = naive_dprime,
             MoM = mom_dprime,
             MLE = mle_dprime) %>%
      gather(Naive, MoM, MLE, key = "Method", value = "estimate") %>%
      filter(size == size_c, oaf == oaf_c) %>%
      mutate(nind = as.factor(nind),
             mse = (estimate - dprime) ^ 2) %>%
      ggplot(aes(x = nind, y = mse, color = Method)) +
      facet_grid(ploidy ~ dprime) +
      geom_boxplot(outlier.size = 0.3) +
      theme_bw() +
      theme(strip.background = element_rect(fill = "white")) +
      scale_color_colorblind() +
      scale_y_log10() +
      xlab("Sample Size") +
      ylab("Mean Squared Error") +
      ggtitle(TeX(paste0("Depth = ", size_c, ", $(p_A, p_B)$ = (0.99,", oaf_c, ")"))) ->
      pl
    ggsave(filename = paste0("./output/maf/maf_plots/maf_size",
                             size_c,
                             "_oaf",
                             round(oaf_c * 100),
                             ".pdf"),
           plot = pl,
           height = 6.5,
           width = 6.5,
           family = "Times")
  }
}

