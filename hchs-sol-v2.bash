# 2024-10-09

# redownloaded HCHS/SOL now that there's a big V2 update on dbGaP!

# load DCC modules
# to perform minor cleanups using R
module load R/4.1.1-rhel8
# merging bed/bim/fam only works with older plink :(
module load Plink/1.90
# for runs requiring more memory than the default
srun --mem 16G -p biostat --account biostat --pty bash -i


### CART FILE ###

# first logged into dbGaP, went to file selector, narrowed down to Study accessions: (phs000) 880, 810, 555 (.v2.p2)
# These three accessions are identified here:
# https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/study.cgi?study_id=phs000810.v2.p2

# selected almost everything, but specifically excluded these kinds of files:
# - Content type:
#   - Genotype calls-individual-format (huge and useless)
#   - Genotype qc (huge and redundant)
#   - Association PI (gwas summary stats previously published?  I don't have plans for these but maybe later, they are huge though)
#   - Genotype calls-vcf (probably redundant with plink versions I am getting, but worth revisiting at some point)

# cart file says it'll be 122.34 Gb
# currently there are 258 G free on DCC!


### DOWNLOAD ###

# on dcc
ssh $dcc
cd /datacommons/ochoalab

# create subdir to put downloads in
mkdir hchs-sol
cd hchs-sol
# manually created this cart file online, put under /home/viiia/docs/duke/dbgap/scripts/, let's copy from home to DCC:
scp cart_hchs-sol-v2.krt hchs-sol-v2-dl.q bim-dups-to-chr0.R $dcc:/datacommons/ochoalab/hchs-sol/

# new download command, submitted as a job:
sbatch hchs-sol-v2-dl.q
# ran smoothly, space usage was close to expectation:
du -hs . # 139G
# and overall free space on disk partition is: 137G, turned to 134G a few days later
df -h|grep ochoalab

# cleanup: remove download stuff from DCC (still on other computers, but gets in the way here)
rm cart_hchs-sol-v2.krt hchs-sol-v2-dl.q dl.out 

# at home, downloaded the PDFs to read:
cd /home/viiia/docs/duke/dbgap/2021-05-18_app-gwas/hchs-sol-2
scp $dcc:/datacommons/ochoalab/hchs-sol/*.pdf .


### EXTRACT AND REORGANIZE ###

### PAGE-CALICO-SOL ###

# this time I'll keep beter track of the source of each file this way:
tar -tf phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c1.HMB-NPU.tar
# phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c1/
# phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c1/PAGE_CALiCo_SOL_c1.bim.gz
# phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c1/PAGE_CALiCo_SOL_c1.fam.gz
# phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c1/PAGE_CALiCo_SOL_c1.bed.gz
tar -xf phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c1.HMB-NPU.tar
rm phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c1.HMB-NPU.tar

tar -tf phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c2.HMB.tar
# phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c2/
# phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c2/PAGE_CALiCo_SOL_c2.bim.gz
# phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c2/PAGE_CALiCo_SOL_c2.fam.gz
# phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c2/PAGE_CALiCo_SOL_c2.bed.gz
tar -xf phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c2.HMB.tar
rm phg000511.v2.PAGE_CALiCo_SOL.genotype-calls-matrixfmt.c2.HMB.tar

tar -tf phg000511.v2.PAGE_CALiCo_SOL.marker-info.MULTI.tar
# phg000511.v2.PAGE_CALiCo_SOL.marker-info.MULTI/
# phg000511.v2.PAGE_CALiCo_SOL.marker-info.MULTI/Cardio-Metabo_Chip_11395247_A.csv
# phg000511.v2.PAGE_CALiCo_SOL.marker-info.MULTI/Cardio-Metabo_Chip_11395247_A.csv.ssid.alleles.txt
# phg000511.v2.PAGE_CALiCo_SOL.marker-info.MULTI/Cardio-Metabo_Chip_11395247_A_ILLUMINA_1055361_dbSNP.gz
# phg000511.v2.PAGE_CALiCo_SOL.marker-info.MULTI/Cardio-Metabo_Chip_SnpID_Mapping.txt
# phg000511.v2.PAGE_CALiCo_SOL.marker-info.MULTI/SOL.map
# phg000511.v2.PAGE_CALiCo_SOL.marker-info.MULTI/SOL.marker
tar -xf phg000511.v2.PAGE_CALiCo_SOL.marker-info.MULTI.tar
rm phg000511.v2.PAGE_CALiCo_SOL.marker-info.MULTI.tar

tar -tf phg000511.v2.PAGE_CALiCo_SOL.sample-info.MULTI.tar
# ./phg000511.v2_FINAL/phg000511.v2.PAGE_CALiCo_SOL.sample-info.MULTI/
# ./phg000511.v2_FINAL/phg000511.v2.PAGE_CALiCo_SOL.sample-info.MULTI/phg000511.v2_release_manifest.txt
tar -xf phg000511.v2.PAGE_CALiCo_SOL.sample-info.MULTI.tar
rm phg000511.v2.PAGE_CALiCo_SOL.sample-info.MULTI.tar

tar -tf phg000771.v1.PAGE_CALiCo_SOL_v2.sample-info.MULTI.tar 
# phg000771.v1.PAGE_CALiCo_SOL_v2.sample-info.MULTI/
# phg000771.v1.PAGE_CALiCo_SOL_v2.sample-info.MULTI/phg000771.v1_release_manifest.txt
# phg000771.v1.PAGE_CALiCo_SOL_v2.sample-info.MULTI/README_as_is.txt
tar -xf phg000771.v1.PAGE_CALiCo_SOL_v2.sample-info.MULTI.tar 
rm phg000771.v1.PAGE_CALiCo_SOL_v2.sample-info.MULTI.tar 

# reorganize these into a nicer folder
mkdir page-calico-sol
mv phg000511.v2* phg000771.v1.PAGE_CALiCo_SOL_v2.sample-info.MULTI phs000555.v2.pht004716.v2.* page-calico-sol/

### HCHS-SOL-Hisp ###

tar -tf phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c0.MULTI.tar
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c0/
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c0/sample_level_PLINK_sets/
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c0/sample_level_PLINK_sets/HCHS_SOL_Hisp_AB_samples_c0.bed.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c0/sample_level_PLINK_sets/HCHS_SOL_Hisp_AB_samples_c0.bim.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c0/sample_level_PLINK_sets/HCHS_SOL_Hisp_AB_samples_c0.fam.gz
tar -xf phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c0.MULTI.tar
rm phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c0.MULTI.tar

tar -tf phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c1.HMB-NPU.tar
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c1/
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c1/sample_level_PLINK_sets/
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c1/sample_level_PLINK_sets/HCHS_SOL_Hisp_AB_samples_c1.bed.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c1/sample_level_PLINK_sets/HCHS_SOL_Hisp_AB_samples_c1.bim.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c1/sample_level_PLINK_sets/HCHS_SOL_Hisp_AB_samples_c1.fam.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c1/subject_level_PLINK/
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c1/subject_level_PLINK/SOL_TOP_subject_level_filtered_c1.bim.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c1/subject_level_PLINK/SOL_TOP_subject_level_filtered_c1.hh.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c1/subject_level_PLINK/SOL_TOP_subject_level_filtered_c1.fam.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c1/subject_level_PLINK/SOL_TOP_subject_level_filtered_c1.bed.gz
tar -xf phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c1.HMB-NPU.tar
rm phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c1.HMB-NPU.tar

tar -tf phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c2.HMB.tar
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c2/
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c2/sample_level_PLINK_sets/
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c2/sample_level_PLINK_sets/HCHS_SOL_Hisp_AB_samples_c2.bed.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c2/sample_level_PLINK_sets/HCHS_SOL_Hisp_AB_samples_c2.bim.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c2/sample_level_PLINK_sets/HCHS_SOL_Hisp_AB_samples_c2.fam.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c2/subject_level_PLINK/
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c2/subject_level_PLINK/SOL_TOP_subject_level_filtered_c2.bim.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c2/subject_level_PLINK/SOL_TOP_subject_level_filtered_c2.hh.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c2/subject_level_PLINK/SOL_TOP_subject_level_filtered_c2.fam.gz
# phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c2/subject_level_PLINK/SOL_TOP_subject_level_filtered_c2.bed.gz
tar -xf phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c2.HMB.tar
rm phg000663.v2.HCHS_SOL_Hisp.genotype-calls-matrixfmt.c2.HMB.tar

tar -tf phg000663.v2.HCHS_SOL_Hisp.marker-info.MULTI.tar
# phg000663.v2.HCHS_SOL_Hisp.marker-info.MULTI/
# phg000663.v2.HCHS_SOL_Hisp.marker-info.MULTI/SoL_HCHS_Custom_15041502_B3_RefStrand.csv.gz
tar -xf phg000663.v2.HCHS_SOL_Hisp.marker-info.MULTI.tar
rm phg000663.v2.HCHS_SOL_Hisp.marker-info.MULTI.tar

tar -tf phg000663.v2.HCHS_SOL_Hisp.sample-info.MULTI.tar
# ./phg000663.v2_FINAL/phg000663.v2.HCHS_SOL_Hisp.sample-info.MULTI/
# ./phg000663.v2_FINAL/phg000663.v2.HCHS_SOL_Hisp.sample-info.MULTI/README_study_outline.txt
# ./phg000663.v2_FINAL/phg000663.v2.HCHS_SOL_Hisp.sample-info.MULTI/phg000663.v2_release_manifest.txt
tar -xf phg000663.v2.HCHS_SOL_Hisp.sample-info.MULTI.tar
rm phg000663.v2.HCHS_SOL_Hisp.sample-info.MULTI.tar

tar -tf phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c0.MULTI.tar
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c0/
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c0/README_plink_sets.txt
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c0/sample_level_set/
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c0/sample_level_set/HCHS_SOL_Hisp_Ib_samples_c0.bed.gz
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c0/sample_level_set/HCHS_SOL_Hisp_Ib_samples_c0.bim.gz
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c0/sample_level_set/HCHS_SOL_Hisp_Ib_samples_c0.fam.gz
tar -xf phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c0.MULTI.tar
rm phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c0.MULTI.tar

tar -tf phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c1.HMB-NPU.tar
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c1/
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c1/README_plink_sets.txt
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c1/subject_level_set/
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c1/subject_level_set/SOL_phaseIb_TOP_subject_level_filtered_c1.bim.gz
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c1/subject_level_set/SOL_phaseIb_TOP_subject_level_filtered_c1.fam.gz
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c1/subject_level_set/SOL_phaseIb_TOP_subject_level_filtered_c1.bed.gz
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c1/sample_level_set/
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c1/sample_level_set/HCHS_SOL_Hisp_Ib_samples_c1.bed.gz
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c1/sample_level_set/HCHS_SOL_Hisp_Ib_samples_c1.bim.gz
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c1/sample_level_set/HCHS_SOL_Hisp_Ib_samples_c1.fam.gz
tar -xf phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c1.HMB-NPU.tar
rm phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c1.HMB-NPU.tar

tar -tf phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c2.HMB.tar
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c2/
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c2/README_plink_sets.txt
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c2/subject_level_set/
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c2/subject_level_set/SOL_phaseIb_TOP_subject_level_filtered_c2.bim.gz
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c2/subject_level_set/SOL_phaseIb_TOP_subject_level_filtered_c2.fam.gz
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c2/subject_level_set/SOL_phaseIb_TOP_subject_level_filtered_c2.bed.gz
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c2/sample_level_set/
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c2/sample_level_set/HCHS_SOL_Hisp_Ib_samples_c2.bed.gz
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c2/sample_level_set/HCHS_SOL_Hisp_Ib_samples_c2.bim.gz
# phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c2/sample_level_set/HCHS_SOL_Hisp_Ib_samples_c2.fam.gz
tar -xf phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c2.HMB.tar
rm phg000809.v1.HCHS_SOL_Hisp_Ib.genotype-calls-matrixfmt.c2.HMB.tar

tar -tf phg000809.v1.HCHS_SOL_Hisp_Ib.marker-info.MULTI.tar
# phg000809.v1.HCHS_SOL_Hisp_Ib.marker-info.MULTI/
# phg000809.v1.HCHS_SOL_Hisp_Ib.marker-info.MULTI/SoL_HCHS_Custom_15041502_E_sub.csv
# phg000809.v1.HCHS_SOL_Hisp_Ib.marker-info.MULTI/SoL_HCHS_Custom_15041502_E_sub_DD.txt
tar -xf phg000809.v1.HCHS_SOL_Hisp_Ib.marker-info.MULTI.tar
rm phg000809.v1.HCHS_SOL_Hisp_Ib.marker-info.MULTI.tar

tar -tf phg000809.v1.HCHS_SOL_Hisp_Ib.sample-info.MULTI.tar
# ./phg000809.v1_FINAL/phg000809.v1.HCHS_SOL_Hisp_Ib.sample-info.MULTI/
# ./phg000809.v1_FINAL/phg000809.v1.HCHS_SOL_Hisp_Ib.sample-info.MULTI/phg000809.v1_release_manifest.txt
tar -xf phg000809.v1.HCHS_SOL_Hisp_Ib.sample-info.MULTI.tar
rm phg000809.v1.HCHS_SOL_Hisp_Ib.sample-info.MULTI.tar

tar -tf phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1.HMB-NPU.tar
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr11_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr12_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr13_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr14_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr15_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr16_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr17_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr18_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr19_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr1_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr20_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr21_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr22_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr23_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr2_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr3_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr4_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr5_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr6_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr7_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr8_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr9_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr10_c1.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr10_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr11_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr12_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr13_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr14_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr15_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr16_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr17_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr18_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr19_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr1_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr20_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr21_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr22_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr23_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr2_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr3_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr4_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr5_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr6_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr7_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr8_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/phased_input/SOL_phaseI_comb_chr9_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr10_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr10_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr11_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr11_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr12_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr12_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr13_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr13_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr14_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr14_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr15_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr15_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr16_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr16_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr17_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr17_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr18_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr18_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr19_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr19_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr1_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr1_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr20_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr20_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr21_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr21_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr22_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr22_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr23_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr23_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr2_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr2_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr3_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr3_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr4_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr4_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr5_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr5_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr6_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr6_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr7_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr7_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr8_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr8_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr9_c1.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/SOL_imputed3_chr9_c1.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1/README_file_names.txt
tar -xf phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1.HMB-NPU.tar
rm phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1.HMB-NPU.tar

tar -tf phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2.HMB.tar
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr11_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr12_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr13_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr14_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr15_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr16_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr17_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr18_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr19_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr1_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr20_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr21_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr22_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr23_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr2_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr3_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr4_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr5_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr6_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr7_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr8_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr9_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr10_c2.haps.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr10_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr11_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr12_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr13_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr14_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr15_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr16_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr17_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr18_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr19_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr1_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr20_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr21_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr22_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr23_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr2_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr3_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr4_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr5_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr6_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr7_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr8_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/phased_input/SOL_phaseI_comb_chr9_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr10_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr10_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr11_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr11_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr12_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr12_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr13_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr13_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr14_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr14_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr15_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr15_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr16_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr16_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr17_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr17_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr18_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr18_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr19_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr19_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr1_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr1_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr20_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr20_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr21_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr21_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr22_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr22_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr23_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr23_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr2_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr2_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr3_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr3_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr4_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr4_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr5_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr5_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr6_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr6_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr7_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr7_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr8_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr8_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr9_c2.gprobs.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/SOL_imputed3_chr9_c2.sample.gz
# ./phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2/README_file_names.txt
tar -xf phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2.HMB.tar
rm phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c2.HMB.tar

# look at imputed data
cd phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c1
# manually confirmed that both sets (phaseI and imputed3) have the same numbers of individuals (n=2274)
# SNPs: imputed3 is much bigger!
cat SOL_imputed3_chr22_c1.gprobs.gz|wc -l                 # 689063
zcat phased_input/SOL_phaseI_comb_chr22_c1.haps.gz |wc -l #  32031
# right now I don't think I need this imputed data and I'm leaning for deleting it!  It'd be better in a different format anyway
# the phased inputs are smaller but even more useless, definitely delete!
cd ..

# imputed data are the big monsters, and I really don't think I need it (also it's in a terrible format), so let's delete it now (can always re-download later)
du -hs . # 145G
rm -r phg001865.v1.HCHS_SOL_Hisp.genotype-imputed-data.c?
du -hs . # 8.2G

# even more data specific to imputed stuff (same accession "phg001865") that I'm deleting without even extracting!
tar -tf phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI.tar
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr1.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr10.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr11.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr12.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr13.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr14.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr15.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr16.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr17.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr18.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr19.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr2.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr20.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr21.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr22.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr23.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr3.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr4.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr5.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr6.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr7.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr8.metrics.gz
# phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI/SOL_imputed3_chr9.metrics.gz
rm phg001865.v1.HCHS_SOL_Hisp.marker-info.MULTI.tar
tar -tf phg001865.v1.HCHS_SOL_Hisp.sample-info.MULTI.tar
# ./phg001865.v1_FINAL/phg001865.v1.HCHS_SOL_Hisp.sample-info.MULTI/
# ./phg001865.v1_FINAL/phg001865.v1.HCHS_SOL_Hisp.sample-info.MULTI/phg001865.v1_release_manifest.txt
rm phg001865.v1.HCHS_SOL_Hisp.sample-info.MULTI.tar
du -hs . # 7.4G

# proceed with extractions now...

tar -tf phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c0.MULTI.tar
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c0/
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c0/sample_level_set/
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c0/sample_level_set/HispCommunityHS_phaseII_AB_samples_c0.fam.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c0/sample_level_set/HispCommunityHS_phaseII_AB_samples_c0.bim.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c0/sample_level_set/HispCommunityHS_phaseII_AB_samples_c0.bed.gz
tar -xf phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c0.MULTI.tar
rm phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c0.MULTI.tar

tar -tf phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c1.HMB-NPU.tar
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c1/
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c1/sample_level_set/
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c1/sample_level_set/HispCommunityHS_phaseII_AB_samples_c1.bim.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c1/sample_level_set/HispCommunityHS_phaseII_AB_samples_c1.fam.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c1/sample_level_set/HispCommunityHS_phaseII_AB_samples_c1.bed.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c1/subject_level_set/
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c1/subject_level_set/SOL_phaseII_TOP_subject_level_filtered_c1.bim.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c1/subject_level_set/SOL_phaseII_TOP_subject_level_filtered_c1.fam.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c1/subject_level_set/SOL_phaseII_TOP_subject_level_filtered_c1.bed.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c1/README_plink_sets.txt
tar -xf phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c1.HMB-NPU.tar
rm phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c1.HMB-NPU.tar

tar -tf phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c2.HMB.tar
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c2/
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c2/sample_level_set/
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c2/sample_level_set/HispCommunityHS_phaseII_AB_samples_c2.bim.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c2/sample_level_set/HispCommunityHS_phaseII_AB_samples_c2.fam.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c2/sample_level_set/HispCommunityHS_phaseII_AB_samples_c2.bed.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c2/subject_level_set/
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c2/subject_level_set/SOL_phaseII_TOP_subject_level_filtered_c2.bim.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c2/subject_level_set/SOL_phaseII_TOP_subject_level_filtered_c2.fam.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c2/subject_level_set/SOL_phaseII_TOP_subject_level_filtered_c2.bed.gz
# phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c2/README_plink_sets.txt
tar -xf phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c2.HMB.tar
rm phg001866.v1.HCHS_SOL_Hisp_II.genotype-calls-matrixfmt.c2.HMB.tar

tar -tf phg001866.v1.HCHS_SOL_Hisp_II.marker-info.MULTI.tar
# phg001866.v1.HCHS_SOL_Hisp_II.marker-info.MULTI/
# phg001866.v1.HCHS_SOL_Hisp_II.marker-info.MULTI/HumanOmni2.5S-8v1_C.csv.gz
tar -xf phg001866.v1.HCHS_SOL_Hisp_II.marker-info.MULTI.tar
rm phg001866.v1.HCHS_SOL_Hisp_II.marker-info.MULTI.tar

tar -tf phg001866.v1.HCHS_SOL_Hisp_II.sample-info.MULTI.tar
# ./phg001866.v1_FINAL/phg001866.v1.HCHS_SOL_Hisp_II.sample-info.MULTI/
# ./phg001866.v1_FINAL/phg001866.v1.HCHS_SOL_Hisp_II.sample-info.MULTI/phg001866.v1_release_manifest.txt
tar -xf phg001866.v1.HCHS_SOL_Hisp_II.sample-info.MULTI.tar
rm phg001866.v1.HCHS_SOL_Hisp_II.sample-info.MULTI.tar

# finally done extracting


### REORGANIZE, CLEANUP ###

# remove executable bits for some weird files, but never for directories!
chmod -R -x+X .

# reading release notes and various other files convinced me that all c0 are just HapMap/ technical controls, without phenotypes, so we must delete them!
rm -r *.c0
du -hs . # 7.2G

# group data a bit more now
mkdir main
mv *phs000810* main/

mkdir ola
mv *phs000880* ola/
mv phg00* ola/

# remove directories of subsets
cd page-calico-sol
# this one is pretty simple, can get away doing this
# do it twice because one directory had two levels
mv -n */* .
mv -n */* .
# safe to toss all directories (which are now empty)
rmdir */
cd ..

cd ola
# buried README files explained the study outline better encoded here:
mkdir Ia Ib II
mv phg000663.v2* Ia
mv phg000809.v1* Ib # this is the most useful one to us it appears!
mv phg001866.v1* II
# process each of these separately
cd Ia
mv -n */* .
mv -n */* .
rmdir */
# twice because subject/sample files were in subdirs of the same name, this only procedes after those are tossed
mv -n */* .
mv -n */* .
rmdir */
# this particular file explained that "subject filtered" is better for GWAS/analysis than "sample-level", because the latter contains duplicate samples!
less README_plink_sets.txt
# going by explanation provided, we only want "subject filtered", remove sample version only
rm HCHS_SOL_Hisp_AB_samples_c*
cd ../Ib
# clean these up directly now
rm -r */sample_level_set/
# move the deeper levels down first
mv -n */*/* .
mv -n */* .
# remove one file that is duplicated
diff -q README_plink_sets.txt */README_plink_sets.txt
rm */README_plink_sets.txt
# ready to remove the directories
rmdir */*/
rmdir */
# repeat what we did last here too
cd ../II
rm -r */sample_level_set/
mv -n */*/* .
mv -n */* .
diff -q README_plink_sets.txt */README_plink_sets.txt
rm */README_plink_sets.txt
rmdir */*/
rmdir */
# done for now
cd ../..

# the removal of "sample" sets got us down here!
du -hs . # 3.9G
# but now let's uncompress plink files to work on them further
cd page-calico-sol/
gunzip *.{bed,bim,fam}.gz
wc -l *.{bim,fam}
# 196725 PAGE_CALiCo_SOL_c1.bim
# 196725 PAGE_CALiCo_SOL_c2.bim
#   2126 PAGE_CALiCo_SOL_c1.fam
#   9149 PAGE_CALiCo_SOL_c2.fam
cd ../ola/
gunzip */*.{bed,bim,fam}.gz
wc -l */*.{bim,fam}
# 2536661 Ia/SOL_TOP_subject_level_filtered_c1.bim
# 2536661 Ia/SOL_TOP_subject_level_filtered_c2.bim
#   88926 Ib/SOL_phaseIb_TOP_subject_level_filtered_c1.bim
#   88926 Ib/SOL_phaseIb_TOP_subject_level_filtered_c2.bim
# 2015318 II/SOL_phaseII_TOP_subject_level_filtered_c1.bim
# 2015318 II/SOL_phaseII_TOP_subject_level_filtered_c2.bim
#    2272 Ia/SOL_TOP_subject_level_filtered_c1.fam
#    9735 Ia/SOL_TOP_subject_level_filtered_c2.fam
#    2272 Ib/SOL_phaseIb_TOP_subject_level_filtered_c1.fam
#    9735 Ib/SOL_phaseIb_TOP_subject_level_filtered_c2.fam
#     317 II/SOL_phaseII_TOP_subject_level_filtered_c1.fam
#    1019 II/SOL_phaseII_TOP_subject_level_filtered_c2.fam
# as expected, Ia and Ib have the same "full" sample size, while II is reduced
# as for SNPs, Ia is the largest of all (but specifically Ib is very tiny)
# lastly, page-calico-sol is also smaller than the rest ("ola")
cd ..
du -hs . # 6.7G

# time to merge the two consent cohorts, whose only difference is c1 is for not profit while c2 is ok for profit, but for us both are the same

# before next steps, we have to seriously clean up data
# this includes chr=0 and X and Y, which we generally ignore
# all alleles are single char, but includes zeroes (sometimes as both ref and alt) which we absolutely want to remove
# let's see if this gets read of multiallelics too, though that might have to be a separate step
time plink2 --bfile PAGE_CALiCo_SOL_c1 --autosome --snps-only just-acgt --max-alleles 2 --make-bed --out data1
# this solved some problems, but duplicates remain, and also cases with pos=0 or ref=alt (both equal to ., which was 0 before)
# will have to remove them by brute force, with R
time Rscript ../bim-dups-to-chr0.R data1 data1b
mv data1.bim data1_ORIG.bim
mv data1b.bim data1.bim
# have to sort first, and awkwardly, have to go through pgen for that
time plink2 --bfile data1 --sort-vars --make-pgen --out data1s
# now filter that
time plink2 --pfile data1s --autosome --make-bed --out data1b

# repeat steps for the second part (c2)
time plink2 --bfile PAGE_CALiCo_SOL_c2 --autosome --snps-only just-acgt --max-alleles 2 --make-bed --out data2
time Rscript ../bim-dups-to-chr0.R data2 data2b
mv data2.bim data2_ORIG.bim
mv data2b.bim data2.bim
time plink2 --bfile data2 --sort-vars --make-pgen --out data2s
time plink2 --pfile data2s --autosome --make-bed --out data2b

# now merge!
#time plink2 --bfile data1b --pmerge data2b.{bed,bim,fam} --out data
# plink2 currently doesn't handle this well because ref/alt vary in order, so this is not a straight "concat" job
# plink1 ought to work?
time plink --bfile data1b --bmerge data2b --keep-allele-order --out data

# cleanup
rm data{1,2}* data.log

# final stats
wc -l *.{bim,fam}
# 188857 data.bim
# 196725 PAGE_CALiCo_SOL_c1.bim
# 196725 PAGE_CALiCo_SOL_c2.bim
#  11275 data.fam
#   2126 PAGE_CALiCo_SOL_c1.fam
#   9149 PAGE_CALiCo_SOL_c2.fam

# now re-compress and put the stuff we're unlikely to need regularly in a subdirectory, so it doesn't get in the way
gzip PAGE_CALiCo_SOL_c?.{bed,bim,fam}
mkdir raw
mv PAGE_CALiCo_SOL_c* Cardio-Metabo_Chip_* README_as_is.txt SOL.ma* phs000555.v2.pht004716.v2.* phg000* raw/
# compress even more things, though these weren't too big to begin with
cd raw
gzip *.csv *.txt *.xml SOL.*
cd ../..
du -hs . # 6.8G

# repeat for OLA subsets
cd ola/Ia
# this is really shared between studies/"phases"
mv README_study_outline.txt ..
gzip *.txt
# SNP issues are similar to those of calico, so repeat my previous cleanup here
time plink2 --bfile SOL_TOP_subject_level_filtered_c1 --autosome --snps-only just-acgt --max-alleles 2 --make-bed --out data1
time Rscript ../../bim-dups-to-chr0.R data1 data1b
mv data1.bim data1_ORIG.bim
mv data1b.bim data1.bim
time plink2 --bfile data1 --sort-vars --make-pgen --out data1s
time plink2 --pfile data1s --autosome --make-bed --out data1b
time plink2 --bfile SOL_TOP_subject_level_filtered_c2 --autosome --snps-only just-acgt --max-alleles 2 --make-bed --out data2
time Rscript ../../bim-dups-to-chr0.R data2 data2b
mv data2.bim data2_ORIG.bim
mv data2b.bim data2.bim
time plink2 --bfile data2 --sort-vars --make-pgen --out data2s
time plink2 --pfile data2s --autosome --make-bed --out data2b
# now merge!  This one required more than the default 1G, ran with 16G cause meh
time plink --bfile data1b --bmerge data2b --keep-allele-order --out data
# here there are new issues not encountered in calico, with diff-ID but same-pos SNPs!  Proportionally they are few and may be ignorable though.
# Warning: Variants 'rs9697457' and 'kgp15316745' have the same position.
# Warning: Variants 'rs6673601' and 'kgp15363534' have the same position.
# Warning: Variants 'rs819980' and 'kgp8416131' have the same position.
# 33042 more same-position warnings: see log file.
rm data{1,2}* data.log
# final stats
wc -l *.{bim,fam}
# 2318804 data.bim
# 2536661 SOL_TOP_subject_level_filtered_c1.bim
# 2536661 SOL_TOP_subject_level_filtered_c2.bim
#   12007 data.fam
#    2272 SOL_TOP_subject_level_filtered_c1.fam
#    9735 SOL_TOP_subject_level_filtered_c2.fam

gzip SOL_TOP_subject_level_filtered_c?.{bed,bim,fam}
mkdir raw
mv *.gz raw/
cd ..
du -hs .. # 9.3G

# more or less repeat for this too
cd Ib
gzip *.txt *.csv
time plink2 --bfile SOL_phaseIb_TOP_subject_level_filtered_c1 --autosome --snps-only just-acgt --max-alleles 2 --make-bed --out data1
time Rscript ../../bim-dups-to-chr0.R data1 data1b
mv data1.bim data1_ORIG.bim
mv data1b.bim data1.bim
time plink2 --bfile data1 --sort-vars --make-pgen --out data1s
time plink2 --pfile data1s --autosome --make-bed --out data1b
time plink2 --bfile SOL_phaseIb_TOP_subject_level_filtered_c2 --autosome --snps-only just-acgt --max-alleles 2 --make-bed --out data2
time Rscript ../../bim-dups-to-chr0.R data2 data2b
mv data2.bim data2_ORIG.bim
mv data2b.bim data2.bim
time plink2 --bfile data2 --sort-vars --make-pgen --out data2s
time plink2 --pfile data2s --autosome --make-bed --out data2b
# now merge!  This one required more than the default 1G, ran with 16G cause meh
time plink --bfile data1b --bmerge data2b --keep-allele-order --out data
# ditto diff-ID but same-pos SNPs warnings!
# Warning: Variants 'seq-rs3934834' and 'SoL-rs3934834' have the same position.
# Warning: Variants 'rs61760196' and 'kgp7438012' have the same position.
# Warning: Variants 'rs16862517' and 'kgp15286773' have the same position.
# 272 more same-position warnings: see log file.
rm data{1,2}* data.log
# final stats
wc -l *.{bim,fam}
# 76304 data.bim
# 88926 SOL_phaseIb_TOP_subject_level_filtered_c1.bim
# 88926 SOL_phaseIb_TOP_subject_level_filtered_c2.bim
# 12007 data.fam
#  2272 SOL_phaseIb_TOP_subject_level_filtered_c1.fam
#  9735 SOL_phaseIb_TOP_subject_level_filtered_c2.fam
gzip  SOL_phaseIb_TOP_subject_level_filtered_c?.{bed,bim,fam}
mkdir raw
mv *.gz raw/
cd ..
du -hs .. # 9.4G

# more or less repeat for this too
cd II
rm README_plink_sets.txt # this one was identical to the one in Ib, and both have limited useful info moving forward
gzip *.txt
time plink2 --bfile SOL_phaseII_TOP_subject_level_filtered_c1 --autosome --snps-only just-acgt --max-alleles 2 --make-bed --out data1
time Rscript ../../bim-dups-to-chr0.R data1 data1b
mv data1.bim data1_ORIG.bim
mv data1b.bim data1.bim
time plink2 --bfile data1 --sort-vars --make-pgen --out data1s
time plink2 --pfile data1s --autosome --make-bed --out data1b
time plink2 --bfile SOL_phaseII_TOP_subject_level_filtered_c2 --autosome --snps-only just-acgt --max-alleles 2 --make-bed --out data2
time Rscript ../../bim-dups-to-chr0.R data2 data2b
mv data2.bim data2_ORIG.bim
mv data2b.bim data2.bim
time plink2 --bfile data2 --sort-vars --make-pgen --out data2s
time plink2 --pfile data2s --autosome --make-bed --out data2b
# now merge!  This one required more than the default 1G, ran with 16G cause meh
time plink --bfile data1b --bmerge data2b --keep-allele-order --out data
# unlike Ia and Ib, this one had no merge warnings!
rm data{1,2}* data.log
# final stats
wc -l *.{bim,fam}
# 1856924 data.bim
# 2015318 SOL_phaseII_TOP_subject_level_filtered_c1.bim
# 2015318 SOL_phaseII_TOP_subject_level_filtered_c2.bim
#    1336 data.fam
#     317 SOL_phaseII_TOP_subject_level_filtered_c1.fam
#    1019 SOL_phaseII_TOP_subject_level_filtered_c2.fam
gzip SOL_phaseII_TOP_subject_level_filtered_c?.{bed,bim,fam}
mkdir raw
mv *.gz raw/
cd ..
du -hs .. # 9.4G

# stuff in the base is also not very useful, separate as well
mkdir raw
gzip *.xml
mv *.gz raw

# clean up main stuff, which also has files that are more distracting than they are useful
cd ../main
gzip  *.xml
mkdir raw
mv manifest_* phs000810.v2.pht00471{3,4}* raw/
cd ..

# ola is really part of main, decided to merge those two
mv ola/* main/
mv ola/raw/* main/raw/
rmdir ola/raw/
rmdir ola/

# and just put main in base dir now
mv main/* .
rmdir main/

# make sure non-group members can't read any of this data!
chmod o-r -R .
# and conversely, group members can write too
chmod g+w -R .


# TODO: actually perform QC on these datasets!
