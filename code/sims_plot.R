##################################
## Plot output of simulation study
##################################

library(tidyverse)
library(ggthemes)
library(latex2exp)
simdf <- read_csv("./output/sims/simout.csv")


## r2 -------------------------------------------------------------------------
simdf %>%
  select(nind,
         size,
         ploidy,
         r2,
         pA,
         pB,
         Naive = naive_r2_est,
         MoM = fast_r2_est,
         MLE = mle_r2_est) %>%
  gather(-nind, -size, -ploidy, -pA, -pB, -r2, key = "method", value = "estimate") %>%
  mutate(nind = as.factor(nind)) %>%
  filter(size == 10, pA == 0.5, pB == 0.5) ->
  depth10df

depth10df %>%
  select(ploidy, r2) %>%
  distinct() ->
  r2df

depth10df %>%
  ggplot(aes(x = nind, y = estimate, color = method)) +
  facet_grid(ploidy ~ r2) +
  geom_boxplot(outlier.size = 0.5) +
  scale_color_colorblind() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_hline(data = r2df, mapping = aes(yintercept = r2), color = 2, lty = 2) +
  xlab("Sample Size") +
  ylab(TeX("$\\hat{r}^2$")) ->
  pl

ggsave(filename = "./output/sims/r2box.pdf",
       plot = pl,
       height = 8,
       width = 6.5,
       family = "Times")

## D --------------------------------------------------------------------------

simdf %>%
  select(nind,
         size,
         ploidy,
         D,
         pA,
         pB,
         Naive = naive_D_est,
         MoM = fast_D_est,
         MLE = mle_D_est) %>%
  gather(-nind, -size, -ploidy, -pA, -pB, -D, key = "method", value = "estimate") %>%
  mutate(nind = as.factor(nind)) %>%
  filter(size == 10, pA == 0.9, pB == 0.9) ->
  depth10df

depth10df %>%
  select(ploidy, D) %>%
  distinct() ->
  Ddf

depth10df %>%
  ggplot(aes(x = nind, y = estimate, color = method)) +
  facet_grid(ploidy ~ D) +
  geom_boxplot(outlier.size = 0.5) +
  scale_color_colorblind() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_hline(data = Ddf, mapping = aes(yintercept = D), color = 2, lty = 2) +
  xlab("Sample Size") +
  ylab(TeX("$\\hat{r}^2$")) ->
  pl

ggsave(filename = "./output/sims/Dbox.pdf",
       plot = pl,
       height = 8,
       width = 6.5,
       family = "Times")


## Dprime --------------------------------------------------------------------

simdf %>%
  select(nind,
         size,
         ploidy,
         Dprime,
         pA,
         pB,
         Naive = naive_Dprime_est,
         MoM = fast_Dprime_est,
         MLE = mle_Dprime_est) %>%
  gather(-nind, -size, -ploidy, -pA, -pB, -Dprime, key = "method", value = "estimate") %>%
  mutate(nind = as.factor(nind)) %>%
  filter(size == 10, pA == 0.9, pB == 0.9) ->
  depth10df

depth10df %>%
  select(ploidy, Dprime) %>%
  distinct() ->
  Dprimedf

depth10df %>%
  ggplot(aes(x = nind, y = estimate, color = method)) +
  facet_grid(ploidy ~ Dprime) +
  geom_boxplot(outlier.size = 0.5) +
  scale_color_colorblind() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_hline(data = Dprimedf, mapping = aes(yintercept = Dprime), color = 2, lty = 2) +
  xlab("Sample Size") +
  ylab(TeX("$\\hat{r}^2$")) ->
  pl

ggsave(filename = "./output/sims/Dprimebox.pdf",
       plot = pl,
       height = 8,
       width = 6.5,
       family = "Times")


## SE -----------------------------------------------------------------------

simdf %>%
  select(seed, nind, size, ploidy, pA, pB, r, starts_with("fast_"), -fast_time) %>%
  gather(starts_with("fast_"), key = "meth_type", value = "value") %>%
  mutate(meth_type = str_replace(meth_type, "fast_", "")) %>%
  separate(col = "meth_type", into = c("method", "type")) %>%
  spread(key = type, value = value) %>%
  group_by(nind, size, ploidy, pA, pB, r, method) %>%
  filter(is.finite(est)) %>%
  summarize(sd_est = mad(est, na.rm = TRUE),
            m_se = median(se, na.rm = TRUE)) %>%
  ungroup() ->
  sddf

sddf %>%
  mutate(`n and r` = nind == 10 & r == 0.9,
         `n and r` = case_when(`n and r` ~ "n = 10, r = 0.9",
                               !`n and r` ~ "other"),
         method = recode(method,
                         D = "hat(D)",
                         Dprime = "paste(hat(D), minute)",
                         r2 = "hat(r)^2",
                         r = "hat(r)",
                         z = "hat(z)")) %>%
  ggplot(aes(x = sd_est, m_se, color = `n and r`, shape = `n and r`)) +
  geom_point() +
  facet_wrap(.~method, scales = "free", labeller = label_parsed) +
  geom_abline(slope = 1, intercept = 0) +
  theme_bw() +
  xlab("MAD of Estimates") +
  ylab("Median of Standard Errors") +
  theme(strip.background = element_rect(fill = "white")) +
  scale_color_colorblind() ->
  pl

ggsave(filename = "./output/sims/seplots.pdf",
       plot = pl,
       height = 4,
       width = 6.5,
       family = "Times")
