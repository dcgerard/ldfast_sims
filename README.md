
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Reproduce the Results of Gerard (2020)

## Introduction

This repository contains the code and instructions needed to reproduce
all of the results from Gerard (2020).

## Instructions

  - You will need an up-to-date version of R, GNU make, and 7zip. To
    install the required R packages, run the following in R:
    
    ``` r
    install.packages(c("updog", 
                       "ldsep", 
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
    ```

  - To run all analyses, open up the terminal and run
    
    ``` bash
    make
    ```

  - To run just the simulations, run
    
    ``` bash
    make sims
    ```

  - To run just the real data analyses using the data from Uitdewilligen
    (2013), run
    
    ``` bash
    make uit
    ```

  - Note that running these scripts will result in downloading the real
    datasets used. But you can also download them directly from:
    
      - <https://doi.org/10.1371/journal.pone.0062355.s004>
      - <https://doi.org/10.1371/journal.pone.0062355.s007>
      - <https://doi.org/10.1371/journal.pone.0062355.s009>
      - <https://doi.org/10.1371/journal.pone.0062355.s010>
    
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
    #> Running under: Ubuntu 20.04.1 LTS
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
    #>  [1] ashr_2.2-47        matrixStats_0.57.0 latex2exp_0.4.0    gridExtra_2.3     
    #>  [5] GGally_2.0.0       ggthemes_4.2.0     doParallel_1.0.16  iterators_1.0.13  
    #>  [9] foreach_1.5.1      vcfR_1.12.0        forcats_0.5.0      stringr_1.4.0     
    #> [13] dplyr_1.0.2        purrr_0.3.4        readr_1.4.0        tidyr_1.1.2       
    #> [17] tibble_3.0.4       ggplot2_3.3.2      tidyverse_1.3.0    ldsep_2.0.0       
    #> [21] updog_2.0.2       
    #> 
    #> loaded via a namespace (and not attached):
    #>  [1] nlme_3.1-150             fs_1.5.0                 lubridate_1.7.9.2       
    #>  [4] RColorBrewer_1.1-2       httr_1.4.2               tools_4.0.3             
    #>  [7] backports_1.2.0          irlba_2.3.3              R6_2.5.0                
    #> [10] vegan_2.5-6              DBI_1.1.0                mgcv_1.8-33             
    #> [13] colorspace_2.0-0         permute_0.9-5            withr_2.3.0             
    #> [16] tidyselect_1.1.0         compiler_4.0.3           cli_2.2.0               
    #> [19] rvest_0.3.6              xml2_1.3.2               scales_1.1.1            
    #> [22] SQUAREM_2020.5           mixsqp_0.3-43            digest_0.6.27           
    #> [25] rmarkdown_2.5            pkgconfig_2.0.3          htmltools_0.5.0         
    #> [28] invgamma_1.1             dbplyr_2.0.0             rlang_0.4.8             
    #> [31] readxl_1.3.1             rstudioapi_0.13          generics_0.1.0          
    #> [34] jsonlite_1.7.1           magrittr_2.0.1           Matrix_1.2-18           
    #> [37] Rcpp_1.0.5               munsell_0.5.0            fansi_0.4.1             
    #> [40] ape_5.4-1                lifecycle_0.2.0          stringi_1.5.3           
    #> [43] yaml_2.2.1               MASS_7.3-53              plyr_1.8.6              
    #> [46] pinfsc50_1.2.0           grid_4.0.3               crayon_1.3.4            
    #> [49] lattice_0.20-41          haven_2.3.1              splines_4.0.3           
    #> [52] hms_0.5.3                knitr_1.30               pillar_1.4.7            
    #> [55] codetools_0.2-18         reprex_0.3.0             glue_1.4.2              
    #> [58] evaluate_0.14            RcppArmadillo_0.10.1.2.0 modelr_0.1.8            
    #> [61] vctrs_0.3.5              cellranger_1.1.0         gtable_0.3.0            
    #> [64] reshape_0.8.8            assertthat_0.2.1         xfun_0.19               
    #> [67] broom_0.7.2              viridisLite_0.3.0        truncnorm_1.0-8         
    #> [70] cluster_2.1.0            ellipsis_0.3.1

## References

<div id="refs" class="references">

<div id="ref-gerard2020fast">

Gerard, David. 2020. “Scalable Bias-Corrected Linkage Disequilibrium
Estimation Under Genotype Uncertainty.” *Unpublished Manuscript*.

</div>

<div id="ref-uitdewilligen2013next">

Uitdewilligen, Anne-Marie A. AND D’hoop, Jan G. A. M. L. AND Wolters.
2013. “A Next-Generation Sequencing Method for Genotyping-by-Sequencing
of Highly Heterozygous Autotetraploid Potato.” *PLOS ONE* 8 (5): 1–14.
<https://doi.org/10.1371/journal.pone.0062355>.

</div>

</div>
