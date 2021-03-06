##################################
## Plot output of simulation study
##################################

library(tidyverse)
library(ggthemes)
library(latex2exp)
simdf <- read_csv("./output/sims/simout.csv")

simdf %>%
  select(size, pA, pB) %>%
  distinct() ->
  ddf

for (index in seq_len(nrow(ddf))) {
  size_now <- ddf$size[[index]]
  pA_now <- ddf$pA[[index]]
  pB_now <- ddf$pB[[index]]

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
    filter(size == size_now, pA == pA_now, pB == pB_now) ->
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
    ylab(TeX("$\\hat{\\rho}^2$")) ->
    pl
  if (!(near(pA_now, 0.5) && near(pB_now, 0.5) && near(size_now, 10))) {
    pl <- pl + ggtitle(TeX(paste0("Depth = ", size_now, ", $(p_A, p_B)$ = (", pA_now, ",", pB_now, ")")))
  }

  ggsave(filename = paste0("./output/sims/r2box_size",
                           size_now,
                           "_pa",
                           round(pA_now * 100),
                           "_pb",
                           round(pB_now * 100),
                           ".pdf"),
         plot = pl,
         height = 6.5,
         width = 6.5,
         family = "Times")

  ## black and white r2 figure for publication ----
  if (near(pA_now, 0.5) && near(pB_now, 0.5) && near(size_now, 10)) {
    depth10df %>%
      ggplot(aes(x = nind, y = estimate, fill = method)) +
      facet_grid(ploidy ~ r2) +
      geom_boxplot(outlier.size = 0.5) +
      scale_fill_grey(start = 0.1, end = 0.9) +
      theme_bw() +
      theme(strip.background = element_rect(fill = "white")) +
      geom_hline(data = r2df, mapping = aes(yintercept = r2), lty = 2) +
      xlab("Sample Size") +
      ylab(TeX("$\\hat{\\rho}^2$")) ->
      pl

    ggsave(filename = paste0("./output/sims/r2box_size",
                             size_now,
                             "_pa",
                             round(pA_now * 100),
                             "_pb",
                             round(pB_now * 100),
                             "_bw.pdf"),
           plot = pl,
           height = 6.5,
           width = 6.5,
           family = "Times")
  }

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
    mutate(nind = as.factor(nind),
           D = round(D, digits = 3)) %>%
    filter(size == size_now, pA == pA_now, pB == pB_now) ->
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
    ylab(TeX("$\\hat{\\Delta}$")) +
    ggtitle(TeX(paste0("Depth = ", size_now, ", $(p_A, p_B)$ = (", pA_now, ",", pB_now, ")")))->
    pl

  ggsave(filename = paste0("./output/sims/Dbox_size",
                           size_now,
                           "_pa",
                           round(pA_now * 100),
                           "_pb",
                           round(pB_now * 100),
                           ".pdf"),
         plot = pl,
         height = 6.5,
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
    mutate(nind = as.factor(nind),
           Dprime = round(Dprime, digits = 3)) %>%
    filter(size == size_now, pA == pA_now, pB == pB_now) ->
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
    ylab(TeX("$\\hat{\\Delta}^\\prime$")) +
    ggtitle(TeX(paste0("Depth = ", size_now, ", $(p_A, p_B)$ = (", pA_now, ",", pB_now, ")")))->
    pl

  ggsave(filename = paste0("./output/sims/Dprimebox_size",
                           size_now,
                           "_pa",
                           round(pA_now * 100),
                           "_pb",
                           round(pB_now * 100),
                           ".pdf"),
         plot = pl,
         height = 6.5,
         width = 6.5,
         family = "Times")
}

## SE -----------------------------------------------------------------------

simdf %>%
  select(seed, nind, size, ploidy, pA, pB, r, starts_with("fast_"), -fast_time) %>%
  gather(starts_with("fast_"), key = "meth_type", value = "value") %>%
  mutate(meth_type = str_replace(meth_type, "fast_", "")) %>%
  separate(col = "meth_type", into = c("method", "type")) %>%
  spread(key = type, value = value) %>%
  group_by(nind, size, ploidy, pA, pB, r, method) %>%
  filter(is.finite(est)) %>%
  summarize(sd_est = sd(est, na.rm = TRUE),
            m_se = mean(se, na.rm = TRUE)) %>%
  ungroup() %>%
  filter(m_se < 10000) ->
  sddf

sddf %>%
  mutate(method = recode(method,
                         D = "hat(Delta)",
                         Dprime = "paste(hat(Delta), minute)",
                         r2 = "hat(rho)^2",
                         r = "hat(rho)",
                         z = "hat(z)"),
         nind = as.factor(nind)) %>%
  ggplot(aes(x = sd_est, m_se, color = nind, shape = nind)) +
  geom_point() +
  facet_wrap(.~method, scales = "free", labeller = label_parsed) +
  geom_abline(slope = 1, intercept = 0) +
  theme_bw() +
  xlab("Standard Deviation of Estimates") +
  ylab("Mean of Standard Errors") +
  theme(strip.background = element_rect(fill = "white")) +
  scale_color_colorblind(name = "Sample\nSize") +
  scale_shape_discrete(name = "Sample\nSize") ->
  pl

ggsave(filename = "./output/sims/seplots.pdf",
       plot = pl,
       height = 4,
       width = 6.5,
       family = "Times")

pl + scale_x_log10() + scale_y_log10() ->
  pl

ggsave(filename = "./output/sims/seplots_ll.pdf",
       plot = pl,
       height = 4,
       width = 6.5,
       family = "Times")
