# NOTE: use FTP protocol (originally used HTTP and it was infeasibly slow)
url0='ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/'
url=$url0'working/20190425_NYGC_GATK/'
base_pre='CCDG_13607_B01_GRM_WGS_2019-02-19_chr'
base_pos='.recalibrated_variants.vcf.gz'

# NOTE: 2504 is same number of individuals as older tgp/plink2 data
# loci very closely agrees with 2020_Biddanda

################
### DOWNLOAD ###
################

# place raw data in a location that doesn't get synced
cd /scratch1/dbs2/
mkdir tgp-nygc
cd tgp-nygc

# download metadata too
wget $url0/20130606_g1k_3202_samples_ped_population.txt # 25-May-2020 14:14 (http ls)
wget $url0/working/1kGP.3202_samples.pedigree_info.txt  # 06-Oct-2021 10:28 # redundant?
# other useful info
wget $url0/20190405_1000G_2504_high_cov_data_reuse_README.md
wget $url0/20190405_1000G_2504_high_cov_README.md
# checksums
wget $url"20190425_NYGC_GATK_manifest.txt"

# VCF files per chromosome
# manually also downloaded "others", though pattern doesn't hold (doesn't have "chr" prefix)
for chr in {1..22} X Y
do
    # download files
    wget $url$base_pre$chr$base_pos
    wget $url$base_pre$chr$base_pos.tbi
done

# manually edited manifest to be a proper checksum list file, validated downloads!
time md5sum -c 20190425_NYGC_GATK_manifest_EDIT2.md5
# 241m11.722s viiiaR5 (with concurrent runs)

#################
### MAKE PGEN ###
#################

# these files are monstrous, so shrink ASAP
# - reencode to compact plink2 format (loses likelihoods and other VCF-specific info, keeps hard calls only)
# - remove non-PASS loci

for chr in {1..22}
do
    time plink2 --vcf $base_pre$chr$base_pos --var-filter --make-pgen vzs --out chr$chr
done
# all viiiaR5 with concurrent runs
# chr1 used 49.6% mem max, others not measured
# chr  real_time    input    pass
#   1 40m42.984s  9999904 8135339
#   2 36m16.527s 10304654 8920945
#   3 27m29.105s  8352452 7408508
#   4 27m20.747s  8227297 7299499
#   5 25m36.761s  7616296 6723364
#   6 24m28.627s  7078785 6381641
#   7 25m47.616s  6935505 5990067
#   8 24m03.372s  6483049 5779242
#   9 21m04.801s  5505304 4489112
#  10 18m58.603s  5902246 5065947
#  11 18m26.995s  5911061 5064757
#  12 17m56.192s  5675967 4894175
#  13 14m20.286s  4473266 3672204
#  14 12m34.834s  3802796 3336145
#  15 11m27.042s  3579026 3016967
#  16 13m11.056s  3968215 3362607
#  17 17m25.228s  3512337 2962508
#  18 10m45.394s  3457646 2876228
#  19  9m31.586s  2697962 2324375
#  20  9m32.792s  2875142 2354785
#  21  7m53.108s  1814704 1339976
#  22  8m33.513s  1872741 1405683


##############
### PMERGE ###
##############

name=tgp-nygc-autosomes

# creates list of files to merge
for chr in {1..22}
do
    echo chr$chr >> files-merge-list.txt
done

# run merge command
time plink2 --pmerge-list files-merge-list.txt pfile-vzs --pmerge-output-vzs --out $name
# 8m13.595s viiiaR5; max mem about 7%!
# dims according to report: 2504 x 102,804,074

du -hs tgp-nygc-autosomes.*
# 6.7G	tgp-nygc-autosomes.pgen
# 28K	tgp-nygc-autosomes.psam
# 5.1G	tgp-nygc-autosomes.pvar.zst

# cleanup, can toss per-chr copies and other stuff
for chr in {1..22}
do
    rm chr$chr.{log,pgen,psam,pvar.zst}
done
rm files-merge-list.txt

#########################################
### ASSIGN UNIQUE IDS TO LOCI W/O IDS ###
#########################################

# this data has all IDs missing; regardless plink2 operates poorly without unique IDs

# set missing IDs to unique values to avoid these being detected as repeated IDs
# NOTE: default mem (7938 MiB) wasn't enough for this dataset on viiiaR5, but `--memory 12000` worked
time plink2 --pfile $name vzs --set-missing-var-ids '@:#' --make-just-pvar zs --out $name-uniq --memory 12000
# 3m23.737s viiiaR5
# replace data after inspection
mv $name-uniq.pvar.zst $name.pvar.zst
# trash
rm $name-uniq.log

################
### MAKE BED ###
################

# filter more and convert to BED
time plink2 --pfile $name vzs --snps-only just-acgt --max-alleles 2 --mac 1 --make-bed --out $name
# 19m55.685s viiiaR5 (with some concurrent runs)

# data dimensions
zstdcat $name.pvar.zst |wc -l
# 102,804,200 # includes header lines
wc -l $name.{bim,fam}
# 91,784,660 tgp-nygc-autosomes.bim # NOTE: 91,784,637 was 2020_Biddanda count, so we have only 23 loci more!!!
#      2,504 tgp-nygc-autosomes.fam

# cleanup
rm $name.log

###############
### FIX FAM ###
###############

# NOTE: entire original fam file is trivial except for id column

# this script has inputs hardcoded, requires several files
Rscript ~/docs/ochoalab/data/fam_add_tgp-nygc_metadata.R
# inspect output, replace if satisfied
mv $name-NEW.fam $name.fam

##########
### MV ###
##########

# move working data from scratch space to sync space
mkdir ~/dbs/tgp-nygc/
mv $name.{bed,bim,fam} ~/dbs/tgp-nygc/
# rest of the commands happen in that space
cd ~/dbs/tgp-nygc/

###########
### AMR ###
###########

# fst-human Hispanics admixture analysis

# outputs
name_AMR=$name"_AMR"
name_AMRp=$name_AMR"+panels"
# tmp copies
name_AMR0=$name_AMR"0"
name_AMRp0=$name_AMRp"0"

# a subset of filt-minimal
grep -P '^(MXL|PEL|PUR|CLM)' $name.fam > $name_AMR0.fam
# create filtered file, removing individuals and fixed loci in subset
plink2 --bfile $name --keep $name_AMR0.fam --mac 1 --make-bed --out $name_AMR
# check that they agree
diff -q $name_AMR0.fam $name_AMR.fam
# data dimensions
wc -l $name_AMR.{bim,fam}
# 26994679 tgp-nygc-autosomes_AMR.bim
#      347 tgp-nygc-autosomes_AMR.fam
# cleanup
rm $name_AMR0.fam
rm $name_AMR.log

# repeat with admixture ref panels (and more stringent MAF 5% filter)
grep -P '^(MXL|PEL|PUR|CLM|GWD|IBS|CHB)' $name.fam > $name_AMRp0.fam
# create filtered file, removing individuals and fixed loci in subset
# since this is passed to `admixture`, need more stringent missingness filters
plink2 --bfile $name --keep $name_AMRp0.fam --maf 0.05 --geno --make-bed --out $name_AMRp
# check that they agree
diff -q $name_AMRp0.fam $name_AMRp.fam
# data dimensions
wc -l $name_AMRp.{bim,fam}
# 6277467 tgp-nygc-autosomes_AMR+panels.bim
#     670 tgp-nygc-autosomes_AMR+panels.fam
# cleanup
rm $name_AMRp0.fam
rm $name_AMRp.log


################
### LD PRUNE ###
################

# this command determines the loci to keep or exclude
time plink2 --bfile $name --indep-pairwise 1000kb 0.3 --out $name
sbatch -p biostat ld-prune-tgp-nygc.q # on DCC
# DCC 4 threads
# 423m2.773s/2504m42.859s (real/user) # viiiaR5 (7h) HGDP!!!!!!!!!!!!!!!!!!!!!!!!!!!
wc -l $name.prune.in
# 3,567,128

# this actually filters the data
name_ld=$name"_ld_prune_1000kb_0.3"
time plink2 --bfile $name --extract $name.prune.in --make-bed --out $name_ld
# 2m50.058s viiiaR5

# cleanup
rm $name.prune.{in,out} 
rm $name.log $name_ld.log

# a surprising amount of loci get eliminated!
wc -l $name.bim
# 63540915
wc -l $name_ld.bim
# 3567128
c 3567128/63540915
# 0.0561390719664644


##################
### MAF 1% cut ###
##################

# start from LD pruned data
name_ld_maf=$name_ld"_maf-0.01"
time plink2 --bfile $name_ld --maf 0.01 --make-bed --out $name_ld_maf
# 0m6.299s viiiaR5

# cleanup
rm $name_ld_maf.log

wc -l $name_ld.bim
# 3567128
wc -l $name_ld_maf.bim
# 924892
c 924892/3567128
# 0.259281976985407
