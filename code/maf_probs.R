
# Prob presented non-monomorphic
af <- 0.01
ploidy <- 2
nind <- 10
1 - sum(dbinom(x = c(0, ploidy), size = ploidy, prob = af)) ^ nind

nind <- 100
1 - sum(dbinom(x = c(0, ploidy), size = ploidy, prob = af)) ^ nind

# Max correlation
(min(af * 0.5, (1-af)*0.5)) / sqrt(af * (1 - af) * 0.5^2)
