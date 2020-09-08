
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Reproduce the Results of Gerard (2020)

## Introduction

This repository contains the code and instructions needed to reproduce
all of the results from Gerard (2020).

## Instructions

You will need an up-to-date version of R, GNU make, and 7zip. To install
the required R packages, run the following in R:

``` r
install.packages(c("updog", 
                   "ldsep", 
                   "tidyverse", 
                   "vcfR",
                   "foreach",
                   "doParallel", 
                   "ggthemes", 
                   "latex2exp"))
```

To run all simulations, open up the terminal and run

``` bash
make
```

# Additional Results

Mathematica code for calculating the gradients necessary for standard
error calculations can be found at [here](./code/gradients.nb) and
[here](./code/gradients.md).

A description of the simulation figures in “./output/sims” can be found
[here](./output/sims/README.md).

# Session Information

    #> R version 4.0.2 (2020-06-22)
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
    #>  [1] latex2exp_0.4.0   ggthemes_4.2.0    doParallel_1.0.15 iterators_1.0.12 
    #>  [5] foreach_1.5.0     vcfR_1.12.0       forcats_0.5.0     stringr_1.4.0    
    #>  [9] dplyr_1.0.2       purrr_0.3.4       readr_1.3.1       tidyr_1.1.2      
    #> [13] tibble_3.0.3      ggplot2_3.3.2     tidyverse_1.3.0   ldsep_1.0.0      
    #> [17] updog_2.0.2      
    #> 
    #> loaded via a namespace (and not attached):
    #>  [1] httr_1.4.2                viridisLite_0.3.0        
    #>  [3] jsonlite_1.7.0            splines_4.0.2            
    #>  [5] modelr_0.1.8              assertthat_0.2.1         
    #>  [7] blob_1.2.1                cellranger_1.1.0         
    #>  [9] yaml_2.2.1                pillar_1.4.6             
    #> [11] backports_1.1.9           lattice_0.20-41          
    #> [13] glue_1.4.2                digest_0.6.25            
    #> [15] rvest_0.3.6               colorspace_1.4-1         
    #> [17] htmltools_0.5.0           Matrix_1.2-18            
    #> [19] pkgconfig_2.0.3           broom_0.7.0              
    #> [21] haven_2.3.1               scales_1.1.1             
    #> [23] mgcv_1.8-33               generics_0.0.2           
    #> [25] ellipsis_0.3.1            withr_2.2.0              
    #> [27] cli_2.0.2                 magrittr_1.5             
    #> [29] crayon_1.3.4              readxl_1.3.1             
    #> [31] evaluate_0.14             fs_1.5.0                 
    #> [33] fansi_0.4.1               nlme_3.1-149             
    #> [35] MASS_7.3-52               xml2_1.3.2               
    #> [37] RcppArmadillo_0.9.900.2.0 vegan_2.5-6              
    #> [39] tools_4.0.2               hms_0.5.3                
    #> [41] lifecycle_0.2.0           munsell_0.5.0            
    #> [43] reprex_0.3.0              cluster_2.1.0            
    #> [45] compiler_4.0.2            rlang_0.4.7              
    #> [47] grid_4.0.2                rstudioapi_0.11          
    #> [49] rmarkdown_2.3             gtable_0.3.0             
    #> [51] codetools_0.2-16          DBI_1.1.0                
    #> [53] R6_2.4.1                  lubridate_1.7.9          
    #> [55] knitr_1.29                pinfsc50_1.2.0           
    #> [57] permute_0.9-5             ape_5.4-1                
    #> [59] stringi_1.4.6             Rcpp_1.0.5               
    #> [61] vctrs_0.3.4               dbplyr_1.4.4             
    #> [63] tidyselect_1.1.0          xfun_0.16

## References

<div id="refs" class="references">

<div id="ref-gerard2020fast">

Gerard, David. 2020. “Scalable Bias-Corrected Linkage Disequilibrium
Estimation Under Genotype Uncertainty.” *Unpublished Manuscript*.

</div>

</div>
