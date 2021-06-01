##################
## Plot results of maf_run.R
##################

library(tidyverse)
library(ggthemes)
maf <- read_csv("./output/maf/mafout.csv")

## Dprime ----

maf %>%
  select(nind,
         size,
         oaf,
         dprime,
         ploidy,
         naive = naive_Dprime_est,
         fast = fast_Dprime_est,
         mle = mle_Dprime_est) %>%
  gather(naive, fast, mle, key = "method", value = "estimate") %>%
  filter(size == 10, oaf == 0.5) %>%
  mutate(nind = as.factor(nind),
         mse = (estimate - dprime) ^ 2) %>%
  ggplot(aes(x = nind, y = mse, color = method)) +
  facet_grid(dprime ~ ploidy, scales = "free_y") +
  geom_boxplot(outlier.size = 0.3) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  scale_color_colorblind() +
  scale_y_log10()

## R2 estimate
maf %>%
  select(nind,
         size,
         oaf,
         r,
         ploidy,
         naive = naive_r2_est,
         fast = fast_r2_est,
         mle = mle_r2_est) %>%
  gather(naive, fast, mle, key = "method", value = "estimate") %>%
  filter(size == 10, oaf == 0.5) %>%
  mutate(nind = as.factor(nind),
         r2 = r^2,
         mse = (estimate - r2) ^ 2) %>%
  ggplot(aes(x = nind, y = mse, color = method)) +
  facet_grid(r2 ~ ploidy, scales = "free_y") +
  geom_boxplot(outlier.size = 0.3) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  scale_color_colorblind() +
  scale_y_log10()
