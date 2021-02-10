# Description

PDF files of the form 

```
<statistic>box_size<size>_pa<pa>_pb<pb>.pdf
```

contain boxplots of `<statistic>` at a read-depth of `<size>`, a major
allele frequency of `<pa>` at locus 1, and a major allele frequency of
`<pb>` at locus 2. For example, `r2box_size100_pa90_pb90` contains
boxplots of $\hat{r}^2$ for simulations with a read-depth of 100 and
major allele frequencies of 0.9 at both loci.

For each figure, boxplots of the `<statistic>` (y-axis) are stratified
by the sample size (x-axis), the ploidy (row-facets), the true level
of linkage disequilibrium (column-facets), and the method used
(color). The true level of LD is also represented by the horizontal
dashed red line, and boxplots that concentrate about that line
indicate superior performance.

The MLE method is that of Gerard (2021a).

The "MoM" method is the newly developed method of Gerard (2021b).

The "Naive" method is just the sample correlation/covariance between
posterior mean genotypes at both loci. This is what is typically used
in the literature.

# References

- Gerard, David. 2021a. "Pairwise Linkage Disequilibrium Estimation for Polyploids." *Molecular Ecology Resources*: [doi:10.1111/1755-0998.13349](https://doi.org/10.1111/1755-0998.13349).
- Gerard, David. 2021b. "Scalable Bias-Corrected Linkage Disequilibrium Estimation Under Genotype Uncertainty." *bioRxiv*. [doi:10.1101/2021.02.08.430270](https://doi.org/10.1101/2021.02.08.430270)
