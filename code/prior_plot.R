##########################
## Boxplots for prior effects
##########################

library(tidyverse)
library(ggthemes)

prior <- read_csv("./output/prior/prior_sims_out.csv")

prior %>%
  select(nind,
         size,
         updog = updog_rho,
         polyRAD = polyrad_rho,
         uniform = uniform_rho,
         horseshoe = horse_rho) %>%
  gather(updog, polyRAD, uniform, horseshoe, key = "Method", value = "Estimate") %>%
  mutate(nind = as.factor(nind), size = as.factor(size),
         Method = parse_factor(Method, levels = c("horseshoe", "uniform", "polyRAD", "updog")),
         size = parse_factor(paste0("Depth = ", size), levels = c("Depth = 5", "Depth = 10", "Depth = 100"))) %>%
  ggplot(aes(x = nind, y = Estimate, color = Method)) +
  facet_wrap(.~size) +
  geom_boxplot(outlier.size = 0.3) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  scale_color_colorblind() +
  geom_hline(yintercept = 0.9, lty = 2, col = 2) +
  xlab("Sample Size") ->
  pl

ggsave(filename = "./output/prior/prior_box.pdf", plot = pl, height = 3, width = 6.5, family = "Times")
