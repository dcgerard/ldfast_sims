
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Reproduce the Results of Gerard (2020)

## Introduction

This repository contains the code and instructions needed to reproduce
all of the results from Gerard (2020).

## Instructions

-   You will need an up-to-date version of R, GNU make, and 7zip. To
    install the required R packages, run the following in R:

    ``` r
    install.packages(c("updog", 
                       "devtools", 
                       "tidyverse", 
                       "vcfR",
                       "foreach",
                       "doParallel", 
                       "ggthemes", 
                       "GGally",
                       "gridExtra",
                       "latex2exp",
                       "matrixStats",
                       "ashr"))
    devtools::install_github("dcgerard/ldsep")
    ```

-   To run all analyses, open up the terminal and run

    ``` bash
    make
    ```

-   To run just the simulations, run

    ``` bash
    make sims
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

A description of the simulation figures in “./output/sims” can be found
[here](./output/sims/README.md).

# Session Information

    #> R version 4.0.3 (2020-10-10)
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
    #>  [1] ashr_2.2-47        matrixStats_0.58.0 latex2exp_0.4.0    gridExtra_2.3     
    #>  [5] GGally_2.1.0       ggthemes_4.2.4     doParallel_1.0.16  iterators_1.0.13  
    #>  [9] foreach_1.5.1      vcfR_1.12.0        forcats_0.5.1      stringr_1.4.0     
    #> [13] dplyr_1.0.4        purrr_0.3.4        readr_1.4.0        tidyr_1.1.2       
    #> [17] tibble_3.0.6       ggplot2_3.3.3      tidyverse_1.3.0    devtools_2.3.2    
    #> [21] usethis_2.0.0      ldsep_2.0.0        updog_2.0.2       
    #> 
    #> loaded via a namespace (and not attached):
    #>  [1] colorspace_2.0-0         ellipsis_0.3.1           rprojroot_2.0.2         
    #>  [4] RcppArmadillo_0.10.1.2.2 fs_1.5.0                 rstudioapi_0.13         
    #>  [7] listenv_0.8.0            remotes_2.2.0            lubridate_1.7.9.2       
    #> [10] xml2_1.3.2               codetools_0.2-18         splines_4.0.3           
    #> [13] cachem_1.0.2             knitr_1.31               pkgload_1.1.0           
    #> [16] jsonlite_1.7.2           broom_0.7.4              cluster_2.1.0           
    #> [19] dbplyr_2.1.0             compiler_4.0.3           httr_1.4.2              
    #> [22] backports_1.2.1          assertthat_0.2.1         Matrix_1.3-2            
    #> [25] fastmap_1.1.0            cli_2.3.0                htmltools_0.5.1.1       
    #> [28] prettyunits_1.1.1        tools_4.0.3              gtable_0.3.0            
    #> [31] glue_1.4.2               doRNG_1.8.2              Rcpp_1.0.6              
    #> [34] cellranger_1.1.0         vctrs_0.3.6              ape_5.4-1               
    #> [37] nlme_3.1-151             pinfsc50_1.2.0           xfun_0.20               
    #> [40] globals_0.14.0           ps_1.5.0                 testthat_3.0.1          
    #> [43] rvest_0.3.6              irlba_2.3.3              lifecycle_0.2.0         
    #> [46] rngtools_1.5             future_1.21.0            MASS_7.3-53             
    #> [49] scales_1.1.1             hms_1.0.0                RColorBrewer_1.1-2      
    #> [52] yaml_2.2.1               memoise_2.0.0            reshape_0.8.8           
    #> [55] stringi_1.5.3            SQUAREM_2021.1           desc_1.2.0              
    #> [58] permute_0.9-5            pkgbuild_1.2.0           truncnorm_1.0-8         
    #> [61] rlang_0.4.10             pkgconfig_2.0.3          invgamma_1.1            
    #> [64] evaluate_0.14            lattice_0.20-41          processx_3.4.5          
    #> [67] tidyselect_1.1.0         parallelly_1.23.0        plyr_1.8.6              
    #> [70] magrittr_2.0.1           R6_2.5.0                 generics_0.1.0          
    #> [73] DBI_1.1.1                pillar_1.4.7             haven_2.3.1             
    #> [76] withr_2.4.1              mgcv_1.8-33              mixsqp_0.3-43           
    #> [79] modelr_0.1.8             crayon_1.4.0             doFuture_0.12.0         
    #> [82] rmarkdown_2.6            grid_4.0.3               readxl_1.3.1            
    #> [85] callr_3.5.1              vegan_2.5-7              reprex_1.0.0            
    #> [88] digest_0.6.27            munsell_0.5.0            viridisLite_0.3.0       
    #> [91] sessioninfo_1.1.1

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-gerard2020fast" class="csl-entry">

Gerard, David. 2020. “Scalable Bias-Corrected Linkage Disequilibrium
Estimation Under Genotype Uncertainty.” *Unpublished Manuscript*.

</div>

<div id="ref-uitdewilligen2013next" class="csl-entry">

Uitdewilligen, Anne-Marie A. AND D’hoop, Jan G. A. M. L. AND Wolters.
2013. “A Next-Generation Sequencing Method for Genotyping-by-Sequencing
of Highly Heterozygous Autotetraploid Potato.” *PLOS ONE* 8 (5): 1–14.
<https://doi.org/10.1371/journal.pone.0062355>.

</div>

</div>
