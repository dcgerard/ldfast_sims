
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Reproduce the Results of Gerard (2021)

[![DOI](https://zenodo.org/badge/289036114.svg)](https://zenodo.org/badge/latestdoi/289036114)

## Introduction

This repository contains the code and instructions needed to reproduce
all of the results from Gerard (2021).

## Instructions

-   You will need an up-to-date version of R, GNU make, and 7zip. To
    install the required R packages, run the following in R:

    ``` r
    install.packages("BiocManager")
    BiocManager::install(c("devtools", 
                           "tidyverse", 
                           "vcfR",
                           "foreach",
                           "doParallel", 
                           "ggthemes", 
                           "GGally",
                           "gridExtra",
                           "latex2exp",
                           "matrixStats",
                           "ashr",
                           "polyRAD"))
    devtools::install_github("dcgerard/updog")
    devtools::install_github("dcgerard/ldsep")
    ```

-   To run all analyses, open up the terminal and run

    ``` bash
    make
    ```

-   To run just the simulations evaluating common variants, run

    ``` bash
    make sims
    ```

-   To run just the simulations evaluating rare variants, run

    ``` bash
    make maf
    ```

-   To run just the simulations evaluating the effects of the prior
    genotyping distribution, run

    ``` bash
    make prior
    ```

-   To run just the real data analyses using the data from
    Uitdewilligen (2013), run

    ``` bash
    make uit
    ```

-   Note that running these scripts will result in downloading the real
    datasets used. But you can also download them directly from:

    -   <https://doi.org/10.1371/journal.pone.0062355.s004>
    -   <https://doi.org/10.1371/journal.pone.0062355.s007>
    -   <https://doi.org/10.1371/journal.pone.0062355.s009>
    -   <https://doi.org/10.1371/journal.pone.0062355.s010>

    Just make sure that you then place them in the “./data/uit/”
    directory.

# Additional Results

Mathematica code for calculating the gradients necessary for standard
error calculations can be found at [here](./code/gradients.nb) and
[here](./code/gradients.md).

# Session Information

    #> R version 4.1.0 (2021-05-18)
    #> Platform: x86_64-pc-linux-gnu (64-bit)
    #> Running under: Ubuntu 20.04.2 LTS
    #> 
    #> Matrix products: default
    #> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3
    #> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/liblapack.so.3
    #> 
    #> locale:
    #>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    #>  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    #>  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    #>  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    #>  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    #> [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    #> 
    #> attached base packages:
    #> [1] parallel  stats     graphics  grDevices utils     datasets  methods  
    #> [8] base     
    #> 
    #> other attached packages:
    #>  [1] polyRAD_1.4        ashr_2.2-47        matrixStats_0.59.0 latex2exp_0.5.0   
    #>  [5] gridExtra_2.3      GGally_2.1.1       ggthemes_4.2.4     doParallel_1.0.16 
    #>  [9] iterators_1.0.13   foreach_1.5.1      vcfR_1.12.0        forcats_0.5.1     
    #> [13] stringr_1.4.0      dplyr_1.0.6        purrr_0.3.4        readr_1.4.0       
    #> [17] tidyr_1.1.3        tibble_3.1.2       ggplot2_3.3.3      tidyverse_1.3.1   
    #> [21] devtools_2.4.1     usethis_2.0.1      ldsep_2.0.3        updog_2.1.0       
    #> 
    #> loaded via a namespace (and not attached):
    #>  [1] colorspace_2.0-1         ellipsis_0.3.2           rprojroot_2.0.2         
    #>  [4] RcppArmadillo_0.10.5.0.0 fs_1.5.0                 rstudioapi_0.13         
    #>  [7] listenv_0.8.0            remotes_2.4.0            fansi_0.5.0             
    #> [10] lubridate_1.7.10         xml2_1.3.2               codetools_0.2-18        
    #> [13] splines_4.1.0            cachem_1.0.5             knitr_1.33              
    #> [16] pkgload_1.2.1            jsonlite_1.7.2           broom_0.7.6             
    #> [19] cluster_2.1.2            dbplyr_2.1.1             compiler_4.1.0          
    #> [22] httr_1.4.2               backports_1.2.1          assertthat_0.2.1        
    #> [25] Matrix_1.3-3             fastmap_1.1.0            cli_2.5.0               
    #> [28] htmltools_0.5.1.1        prettyunits_1.1.1        tools_4.1.0             
    #> [31] gtable_0.3.0             glue_1.4.2               doRNG_1.8.2             
    #> [34] fastmatch_1.1-0          Rcpp_1.0.6               cellranger_1.1.0        
    #> [37] vctrs_0.3.8              ape_5.5                  nlme_3.1-152            
    #> [40] pinfsc50_1.2.0           xfun_0.23                globals_0.14.0          
    #> [43] ps_1.6.0                 testthat_3.0.2           rvest_1.0.0             
    #> [46] irlba_2.3.3              lifecycle_1.0.0          rngtools_1.5            
    #> [49] future_1.21.0            MASS_7.3-54              scales_1.1.1            
    #> [52] hms_1.1.0                RColorBrewer_1.1-2       yaml_2.2.1              
    #> [55] memoise_2.0.0            reshape_0.8.8            stringi_1.6.2           
    #> [58] SQUAREM_2021.1           desc_1.3.0               permute_0.9-5           
    #> [61] pkgbuild_1.2.0           truncnorm_1.0-8          rlang_0.4.11            
    #> [64] pkgconfig_2.0.3          invgamma_1.1             evaluate_0.14           
    #> [67] lattice_0.20-44          processx_3.5.2           tidyselect_1.1.1        
    #> [70] parallelly_1.25.0        plyr_1.8.6               magrittr_2.0.1          
    #> [73] R6_2.5.0                 generics_0.1.0           DBI_1.1.1               
    #> [76] pillar_1.6.1             haven_2.4.1              withr_2.4.2             
    #> [79] mgcv_1.8-35              mixsqp_0.3-43            modelr_0.1.8            
    #> [82] crayon_1.4.1             utf8_1.2.1               doFuture_0.12.0         
    #> [85] rmarkdown_2.8            grid_4.1.0               readxl_1.3.1            
    #> [88] callr_3.7.0              vegan_2.5-7              reprex_2.0.0            
    #> [91] digest_0.6.27            munsell_0.5.0            viridisLite_0.4.0       
    #> [94] sessioninfo_1.1.1

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-gerard2021fast" class="csl-entry">

Gerard, David. 2021. “Scalable Bias-Corrected Linkage Disequilibrium
Estimation Under Genotype Uncertainty.” *bioRxiv*.
<https://doi.org/10.1101/2021.02.08.430270>.

</div>

<div id="ref-uitdewilligen2013next" class="csl-entry">

Uitdewilligen, Anne-Marie A. AND D’hoop, Jan G. A. M. L. AND Wolters.
2013. “A Next-Generation Sequencing Method for Genotyping-by-Sequencing
of Highly Heterozygous Autotetraploid Potato.” *PLOS ONE* 8 (5): 1–14.
<https://doi.org/10.1371/journal.pone.0062355>.

</div>

</div>
