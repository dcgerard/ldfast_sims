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

ggplot(data.frame(rr = sqrt(cor_mom$rr)), aes(x = rr)) +
  geom_histogram(fill = "white", color = "black", bins = 30) +
  theme_bw() +
  xlab("Reliability Ratio Estimate") ->
  pl

ggsave(filename = "./output/uit/figs/rr_hist.pdf",
       plot = pl,
       family = "Times",
       height = 2.5,
       width = 2.5)


### Anything below this is garbage -----------------------

# snp1 <- order(cor_mom$rr, decreasing = TRUE)[[11]]
# snp2 <- snp1 - 1
# tibble(MoM_max = cor_mom$ldmat[snp1, ],
#        MoM_maxm1 = cor_mom$ldmat[snp2, ],
#        Naive_max = cor_naive[snp1, ],
#        Naive_maxm1 = cor_naive[snp2, ]) %>%
#   mutate(rn = row_number()) %>%
#   pivot_longer(-rn) %>%
#   separate(col = name, into = c("est", "loc")) %>%
#   pivot_wider(names_from = loc, values_from = value) %>%
#   ggplot(aes(x = max, y = maxm1)) +
#   geom_point() +
#   facet_wrap(.~est) +
#   geom_abline(intercept = 0, slope = 1, lty = 2, col = 2) +
#   theme_bw() +
#   theme(strip.background = element_rect(fill = "white")) +
#   ggtitle(paste0("Reliability Ratios = ", round(cor_mom$rr[[snp1]], digits = 2), ", ", round(cor_mom$rr[[snp2]], digits = 2))) +
#   xlab(paste0("Squared correlation estimate, ", uit$snpdf$snp[[snp1]])) +
#   ylab(paste0("Squared correlation estimate, ", uit$snpdf$snp[[snp2]])) ->
#   pl
#
# ## If correlations are correlated but not low MSE, then attenuation is probably ocuring
# corn2 <- cor(cor_naive)
# dout <- dist(x = cor_naive, method = "euclidean")
# dout <- as.matrix(dout)
# rrmult <- outer(cor_mom$rr, cor_mom$rr, FUN = `*`)
#
# candidate_snps <- which(corn2 > 0.7 &
#                           corn2 < 0.9 &
#                           dout > 6.5 &
#                           rrmult > 1.5,
#                         arr.ind = TRUE)
#
# candidate_snps <- as_tibble(which(corn2 > 0.7 &
#                                     corn2 < 0.9 &
#                                     rrmult > 1.5,
#                                   arr.ind = TRUE))
# candidate_snps %>%
#   filter(abs(row - col) < 10) ->
#   candidate_snps
#
# i <- sample(seq_len(nrow(candidate_snps)), size = 1)
# snp1 <- candidate_snps[[i, 1]]
# snp2 <- candidate_snps[[i, 2]]
#
# which_large <- corn2 > 0.7 & corn2 < 0.71
# tibble(cor = c(corn2[which_large]),
#        dist = c(dout[which_large]),
#        rr = c(rrmult[which_large])) %>%
#   ggplot(aes(x = cor, y = dist, col = rr)) +
#   geom_point()
#
#
# svmom <- svd(cor_mom$ldmat)
# svnav <- svd(cor_naive)
#
# plot(svmom$u[, 3:2])
# plot(svnav$u[, 3:2])
#
# pl
# maxrr <- order(cor_mom$rr, decreasing = TRUE)[[16]]
# mean((cor_mom$ldmat[maxrr, ] - cor_mom$ldmat[maxrr - 1, ])^2)
# mean((cor_naive[maxrr, ] - cor_naive[maxrr - 1, ])^2)
#
# ggsave(filename = "./output/uit/figs/cor_2snp.pdf",
#        plot = pl,
#        height = 3.5,
#        width = 6.5,
#        family = "Times")
#
#
# ## lag-1 MSE
# diag(cor_naive) <- NA
# diag(cor_mom$ldmat) <- NA
# naive_diff <- colMeans((scale(cor_naive[, -1]) - scale(cor_naive[, -ncol(cor_naive)]))^2, na.rm = TRUE)
# mom_diff <- colMeans((scale(cor_mom$ldmat[, -1]) - scale(cor_mom$ldmat[, -ncol(cor_mom$ldmat)]))^2, na.rm = TRUE)
#
# ovec <- order(cor_mom$rr, decreasing = TRUE)
# plot(naive_diff, mom_diff)
# abline(0, 1, lty = 2, col = 2)
#
#
#
# i <- sample(seq_along(cor_mom$rr), size = 1)
# mean((scale(cor_naive[i, ]) - scale(cor_naive[i-1, ]))^2, na.rm = TRUE)
# mean((scale(cor_mom$ldmat[i, ]) - scale(cor_mom$ldmat[i-1, ]))^2, na.rm = TRUE)
#
#
#
