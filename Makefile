# ADJUST THESE VARIABLES AS NEEDED TO SUIT YOUR COMPUTING ENVIRONMENT
# -------------------------------------------------------------------
# This variable specifies the number of threads to use for the
# parallelization. This could also be specified automatically using
# environment variables. For example, in SLURM, SLURM_CPUS_PER_TASK
# specifies the number of CPUs allocated for each task.
nc = 6

# R scripting front-end. Note that makeCluster sometimes fails to
# connect to a socker when using Rscript, so we are using the "R CMD
# BATCH" interface instead.
rexec = R CMD BATCH --no-save --no-restore

# AVOID EDITING ANYTHING BELOW THIS LINE
# --------------------------------------

# Plots from simulation study
simplots = ./output/sims/Dbox_size10_pa50_pb50.pdf \
           ./output/sims/Dbox_size10_pa50_pb75.pdf \
           ./output/sims/Dbox_size10_pa90_pb90.pdf \
           ./output/sims/Dbox_size100_pa50_pb50.pdf \
           ./output/sims/Dbox_size100_pa50_pb75.pdf \
           ./output/sims/Dbox_size100_pa90_pb90.pdf \
           ./output/sims/Dprimebox_size10_pa50_pb50.pdf \
           ./output/sims/Dprimebox_size10_pa50_pb75.pdf \
           ./output/sims/Dprimebox_size10_pa90_pb90.pdf \
           ./output/sims/Dprimebox_size100_pa50_pb50.pdf \
           ./output/sims/Dprimebox_size100_pa50_pb75.pdf \
           ./output/sims/Dprimebox_size100_pa90_pb90.pdf \
           ./output/sims/r2box_size10_pa50_pb50.pdf \
           ./output/sims/r2box_size10_pa50_pb75.pdf \
           ./output/sims/r2box_size10_pa90_pb90.pdf \
           ./output/sims/r2box_size100_pa50_pb50.pdf \
           ./output/sims/r2box_size100_pa50_pb75.pdf \
           ./output/sims/r2box_size100_pa90_pb90.pdf \
           ./output/sims/seplots.pdf

# Raw data from Uitdewilligen et al (2013)
uitdat = ./data/uit/NewPlusOldCalls.headed.vcf \
         ./data/uit/CSV-file\ S1\ -\ Sequence\ variants\ filtered\ DP15.csv \
         ./data/uit/journal.pone.0062355.s009.xls \
         ./data/uit/journal.pone.0062355.s010.xls

# Readcounts from Uitdewilligen et al (2013)
uitclean = ./output/uit/uit_suc.csv \
           ./output/uit/refmat_suc.RDS \
           ./output/uit/sizemat_suc.RDS

# Updog fits on simulated data for small minor allele frequencies
mafufit = ./output/maf/ufit/maf_ufit_ploidy2_nind100.RDS \
          ./output/maf/ufit/maf_ufit_ploidy4_nind100.RDS \
          ./output/maf/ufit/maf_ufit_ploidy6_nind100.RDS \
          ./output/maf/ufit/maf_ufit_ploidy8_nind100.RDS \
          ./output/maf/ufit/maf_ufit_ploidy2_nind1000.RDS \
          ./output/maf/ufit/maf_ufit_ploidy4_nind1000.RDS \
          ./output/maf/ufit/maf_ufit_ploidy6_nind1000.RDS \
          ./output/maf/ufit/maf_ufit_ploidy8_nind1000.RDS

# MSE plots for MAF simulations
mafplots = ./output/maf/maf_plots/maf_size10_oaf50.pdf \
           ./output/maf/maf_plots/maf_size10_oaf90.pdf \
           ./output/maf/maf_plots/maf_size10_oaf99.pdf \
           ./output/maf/maf_plots/maf_size100_oaf50.pdf \
           ./output/maf/maf_plots/maf_size100_oaf90.pdf \
           ./output/maf/maf_plots/maf_size100_oaf99.pdf

# Run simulations
.PHONY : all
all : sims uit maf prior

# Pairwise LD estimation simulations ---------------
./output/sims/simout.csv : ./code/sims_run.R
	mkdir -p ./output/sims
	mkdir -p ./output/rout
	$(rexec) '--args nc=$(nc)' $< ./output/rout/$(basename $(notdir $<)).Rout

$(simplots) : ./code/sims_plot.R ./output/sims/simout.csv
	mkdir -p ./output/sims
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

.PHONY : sims
sims : $(simplots)

# Real data analysis using data from Uitdewilligen et. al. (2013)

$(uitdat) :
	mkdir -p ./data/uit
	wget --directory-prefix=data/uit -nc https://doi.org/10.1371/journal.pone.0062355.s004
	mv ./data/uit/journal.pone.0062355.s004 ./data/uit/journal.pone.0062355.s004.gz ## variant annotations
	wget --directory-prefix=data/uit -nc https://doi.org/10.1371/journal.pone.0062355.s007
	mv ./data/uit/journal.pone.0062355.s007 ./data/uit/journal.pone.0062355.s007.gz ## read-depth data
	wget --directory-prefix=data/uit -nc https://doi.org/10.1371/journal.pone.0062355.s009
	mv ./data/uit/journal.pone.0062355.s009 ./data/uit/journal.pone.0062355.s009.xls ## super scaffold annotations
	wget --directory-prefix=data/uit -nc https://doi.org/10.1371/journal.pone.0062355.s010
	mv ./data/uit/journal.pone.0062355.s010 ./data/uit/journal.pone.0062355.s010.xls ## contig annotations
	7z e ./data/uit/journal.pone.0062355.s004.gz -o./data/uit
	7z e ./data/uit/journal.pone.0062355.s007.gz -o./data/uit

$(uitclean) : ./code/uit_extract.R $(uitdat)
	mkdir -p ./output/uit
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

./output/uit/uit_updog_fit.RDS : ./code/uit_fit_updog.R $(uitclean)
	mkdir -p ./output/uit
	mkdir -p ./output/rout
	$(rexec) '--args nc=$(nc)' $< ./output/rout/$(basename $(notdir $<)).Rout

./output/uit/mono_plot.pdf : ./code/uit_mono.R ./data/uitmono.RDS
	mkdir -p ./output/uit
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

./output/uit/figs/rr_hist.pdf ./output/uit/time_uit.csv : ./code/uit_corcalc.R ./output/uit/uit_updog_fit.RDS
	mkdir -p ./output/uit
	mkdir -p ./output/uit/figs
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

./output/uit/figs/mle_mom_nav.pdf : ./code/uit_largerr.R ./output/uit/uit_updog_fit.RDS
	mkdir -p ./output/uit
	mkdir -p ./output/uit/figs
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

./output/uit/figs/highsdsnp.pdf : ./code/uit_largesd.R ./output/uit/uit_updog_fit.RDS
	mkdir -p ./output/uit
	mkdir -p ./output/uit/figs
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

.PHONY : uit
uit : ./output/uit/figs/rr_hist.pdf \
      ./output/uit/time_uit.csv \
      ./output/uit/mono_plot.pdf \
      ./output/uit/figs/mle_mom_nav.pdf \
      ./output/uit/figs/highsdsnp.pdf

# Deeper exploration of small minor allele frequency

.PHONY : maf
maf : $(mafplots)

./output/maf/maf_reads.RData : ./code/maf_data.R
	mkdir -p ./output/maf
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

$(mafufit) : ./code/maf_updog.R ./output/maf/maf_reads.RData
	mkdir -p ./output/maf
	mkdir -p ./output/rout
	$(rexec) '--args nc=$(nc)' $< ./output/rout/$(basename $(notdir $<)).Rout

./output/maf/maf_ldfits.csv : ./code/maf_ldest.R $(mafufit)
	mkdir -p ./output/maf
	mkdir -p ./output/rout
	$(rexec) '--args nc=$(nc)' $< ./output/rout/$(basename $(notdir $<)).Rout

$(mafplots) : ./code/maf_plot.R ./output/maf/maf_ldfits.csv
	mkdir -p ./output/maf
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

# Briefly look at exploration of prior

.PHONY : prior
prior : ./output/prior/prior_box.pdf

./output/prior/prior_sims_out.csv : ./code/prior_sims.R
	mkdir -p ./output/prior
	mkdir -p ./output/rout
	$(rexec) '--args nc=$(nc)' $< ./output/rout/$(basename $(notdir $<)).Rout

./output/prior/prior_box.pdf : ./code/prior_plot.R ./output/prior/prior_sims_out.csv
	mkdir -p ./output/maf
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout
