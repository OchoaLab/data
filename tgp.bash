########################
### EXECUTABLE PATHS ###
########################

# plink2
plink2="$HOME/bin/plink2"

# admixture
admixture="$HOME/bin/admixture_linux-1.3.0/admixture"

#################
### DOWNLOADS ###
#################

# all data goes here... (create dir first if it didn't exist)
cd ~/dbs/tgp/plink2/

# download "original" TGP files
# TGP phase 3 but in plink2 format (no need to transform from VCF, should be entirely the same contents)
wget https://www.dropbox.com/s/yozrzsdrwqej63q/phase3_corrected.psam?dl=1
wget https://www.dropbox.com/s/afvvf1e15gqzsqo/all_phase3.pgen.zst?dl=1
wget https://www.dropbox.com/s/0nz9ey756xfocjm/all_phase3.pvar.zst?dl=1
# rename one file for consistency
mv phase3_corrected.psam all_phase3.psam
# need to uncompress this file for plink2 to read:
# (compressed copy stays there!  this is unlike default gunzip behavior)
unzstd all_phase3.pgen.zst

#########################################
### ASSIGN UNIQUE IDS TO LOCI W/O IDS ###
#########################################

# set missing IDs to unique values to avoid these being detected as repeated IDs
$plink2 --pfile all_phase3 vzs --set-missing-var-ids '@:#' --make-just-pvar zs --out all_phase3_uniq
# replace data
mv all_phase3.pvar.zst all_phase3_orig.pvar.zst
mv all_phase3_uniq.pvar.zst all_phase3.pvar.zst
# trash
rm all_phase3_uniq.log

############################################
### BED with multiallelic variants split ###
############################################

# this is a version with the full TGP!
# the procedure is currently not documented, except for this random forum entry:
# https://groups.google.com/forum/#!searchin/plink2-users/multi$20allelic%7Csort:date/plink2-users/fNGW9er-P7g/s6eXg2HtAAAJ
$plink2 --pfile all_phase3 vzs --make-pgen vzs multiallelics=- --out all_phase3_split
$plink2 --pfile all_phase3_split vzs --make-bed --out all_phase3_split

# data dimensions
wc -l all_phase3_split.{bim,fam}
# 85,277,655 all_phase3_split.bim
#      2,504 all_phase3_split.fam

rm all_phase3_split.log

# I then "uniqueified" IDs with this script, for efficient filtering via plink2 later
cd ~/dbs/tgp/plink2/scripts/
time Rscript bim_unique_ids.R
cd ~/dbs/tgp/plink2/
mv all_phase3_split.bim all_phase3_split_orig.bim
gzip all_phase3_split_orig.bim # keep this around temporarily, though there should be no use to it
mv all_phase3_split_uniqueified.bim all_phase3_split.bim

#########################
### YRI ascertainment ###
#########################

# YRI filter, for ascertainment (108 individuals)
grep -P '\#|YRI' all_phase3.psam > all_phase3_YRI.psam
# get list of SNPs to use for ascertainment:

# have to do this way...
# first remove all duplicates (no other filters)
$plink2 --pfile all_phase3 vzs --rm-dup exclude-all --write-snplist zs --out nodups
# then remove those first, assert all other filters
# YRI individuals only, autosomes, SNPs only, biallelic, minimum one count (not fixed), write SNP list
$plink2 --pfile all_phase3 vzs --keep all_phase3_YRI.psam --extract nodups.snplist.zst --autosome --snps-only just-acgt --max-alleles 2 --mac 1 --write-snplist zs --out YRI

zstdcat YRI.snplist.zst|wc -l
# 20,417,484

#############################
### LWK/GWD ascertainment ###
#############################

# alternative choices for Bhatia comparisons, should be better than YRI ascertained on themselves.

# sample filters, for ascertainment
grep -P '\#|LWK' all_phase3.psam > all_phase3_LWK.psam # 99 individuals
grep -P '\#|GWD' all_phase3.psam > all_phase3_GWD.psam # 113 individuals
# get list of SNPs to use for ascertainment:

# have to do this way...
# first remove all duplicates (no other filters)
$plink2 --pfile all_phase3 vzs --rm-dup exclude-all --write-snplist zs --out nodups
# then remove those first, assert all other filters
# desired individuals only, autosomes, SNPs only, biallelic, minimum one count (not fixed), write SNP list
$plink2 --pfile all_phase3 vzs --keep all_phase3_LWK.psam --extract nodups.snplist.zst --autosome --snps-only just-acgt --max-alleles 2 --mac 1 --write-snplist zs --out LWK
$plink2 --pfile all_phase3 vzs --keep all_phase3_GWD.psam --extract nodups.snplist.zst --autosome --snps-only just-acgt --max-alleles 2 --mac 1 --write-snplist zs --out GWD

zstdcat LWK.snplist.zst|wc -l # 21468682
zstdcat GWD.snplist.zst|wc -l # 21315588
# both have more SNPs than YRI!


######################
### Bhatia subpops ###
######################

# filter for individuals in these subpopulations
# NOTE: keep the header too!
grep -P '\#|YRI|CEU|CHB' all_phase3.psam > all_phase3_Bhatia.psam 

# create filtered file
# filter by samples and loci simultaneously, require again that loci are polymorphic within subset
# convert to BED
$plink2 --pfile all_phase3 vzs --keep all_phase3_Bhatia.psam --extract YRI.snplist.zst --mac 1 --make-bed --out Bhatia
# alternative ascertainments
$plink2 --pfile all_phase3 vzs --keep all_phase3_Bhatia.psam --extract LWK.snplist.zst --mac 1 --make-bed --out Bhatia-ascLWK
$plink2 --pfile all_phase3 vzs --keep all_phase3_Bhatia.psam --extract GWD.snplist.zst --mac 1 --make-bed --out Bhatia-ascGWD

# data dimensions
wc -l Bhatia.{bim,fam}
# 20417484 Bhatia.bim
#      310 Bhatia.fam
wc -l Bhatia-ascLWK.{bim,fam}
# 16449760 Bhatia-ascLWK.bim
#      310 Bhatia-ascLWK.fam
wc -l Bhatia-ascGWD.{bim,fam}
# 16487330 Bhatia-ascGWD.bim
#      310 Bhatia-ascGWD.fam

###########
### AMR ###
###########

# filter for individuals in AMR subpopulations
# NOTE: keep the header too!
grep -P '\#|AMR' all_phase3.psam > all_phase3_AMR.psam 

# create filtered file (same as for Bhatia above)
$plink2 --pfile all_phase3 vzs --keep all_phase3_AMR.psam --extract YRI.snplist.zst --mac 1 --make-bed --out AMR-ascYRI

# data dimensions
wc -l AMR-ascYRI.{bim,fam}
# 14145583 AMR-ascYRI.bim
#      347 AMR-ascYRI.fam

###########
### EUR ###
###########

# filter for european individuals, except CEU (had to list all others explicitly)
# NOTE: keep the header too!
grep -P '\#|FIN|GBR|IBS|TSI' all_phase3.psam > all_phase3_EUR.psam 

# create filtered file (same as for Bhatia above)
$plink2 --pfile all_phase3 vzs --keep all_phase3_EUR.psam --extract YRI.snplist.zst --mac 1 --make-bed --out EUR-ascYRI

# data dimensions
wc -l EUR-ascYRI.{bim,fam}
# 8931972 EUR-ascYRI.bim
#     404 EUR-ascYRI.fam
 
#################
### ADMIXTURE ###
#################

# create MAF-filtered data (need small file that Admixture can handle)
# BUT also need individuals from reference panels!

# "AMR + admixture panels" filters...
# NOTE: keep the header too!
grep -P '\#|AMR|YRI|IBS|CHB' all_phase3.psam > all_phase3_AMR+panels.psam 
# create filtered file.  Unlike examples above, here we require a minimum MAF of 5%!
$plink2 --pfile all_phase3 vzs --keep all_phase3_AMR+panels.psam --extract YRI.snplist.zst --maf 0.05 --make-bed --out AMR+panels-ascYRI-maf0.05

# data dimensions
wc -l AMR+panels-ascYRI-maf0.05.{bim,fam}
# 6216713 AMR+panels-ascYRI-maf0.05.bim
#     665 AMR+panels-ascYRI-maf0.05.fam
 
# run admixture!
time $admixture -j12 AMR+panels-ascYRI-maf0.05.bed 3 > AMR+panels-ascYRI-maf0.05.3.log.txt
# real	157m34.819s # labbyDuke
# user	1789m33.758s
# sys	0m49.543s
# NOTE: 6 cores in viiiaX6
# time $admixture -j6 AMR+panels-ascYRI-maf0.05.bed 3 > AMR+panels-ascYRI-maf0.05.3.log.txt
# real    383m35.211s # viiiaX6
# user    2263m7.830s
# sys     2m57.199s

# compress outputs
gzip AMR+panels-ascYRI-maf0.05.3.P
gzip AMR+panels-ascYRI-maf0.05.3.Q
gzip AMR+panels-ascYRI-maf0.05.3.log.txt

###############
### Cleanup ###
###############

# they are redundant and can be easily regenerated...
rm all_phase3.pgen # remove uncompressed version (huge! kept compressed version anyway)
# list of individuals (for filters)
rm all_phase3_AMR.psam
rm all_phase3_AMR+panels.psam
rm all_phase3_EUR.psam
rm all_phase3_Bhatia.psam
rm all_phase3_YRI.psam
rm all_phase3_LWK.psam
rm all_phase3_GWD.psam
# plink2 log files
rm YRI.log
rm LWK.log
rm GWD.log
rm AMR-ascYRI.log
rm AMR+panels-ascYRI-maf0.05.log
rm EUR-ascYRI.log
rm Bhatia.log
rm Bhatia-ascLWK.log
rm Bhatia-ascGWD.log
rm nodups.log
# SNP lists
rm nodups.snplist.zst # list of unique (not duplicated) loci 
rm YRI.snplist.zst # list of YRI loci to keep (ascertainment filter)
rm LWK.snplist.zst # ditto
rm GWD.snplist.zst # ditto

################
### ADD POPS ###
################

# fam data has trivial fam$fam == 0
# replace here with subpopulation labels from main PSAM file
Rscript ~/docs/ochoalab/data/fam_add_pop_from_psam.R all_phase3.psam Bhatia.fam Bhatia.NEW.fam
Rscript ~/docs/ochoalab/data/fam_add_pop_from_psam.R all_phase3.psam Bhatia-ascLWK.fam Bhatia-ascLWK.NEW.fam
Rscript ~/docs/ochoalab/data/fam_add_pop_from_psam.R all_phase3.psam Bhatia-ascGWD.fam Bhatia-ascGWD.NEW.fam
Rscript ~/docs/ochoalab/data/fam_add_pop_from_psam.R all_phase3.psam AMR-ascYRI.fam AMR-ascYRI.NEW.fam
Rscript ~/docs/ochoalab/data/fam_add_pop_from_psam.R all_phase3.psam AMR+panels-ascYRI-maf0.05.fam AMR+panels-ascYRI-maf0.05.NEW.fam
Rscript ~/docs/ochoalab/data/fam_add_pop_from_psam.R all_phase3.psam all_phase3_split.fam all_phase3_split.NEW.fam

# overwrite after visually inspecting for correctness
mv Bhatia.NEW.fam Bhatia.fam
mv Bhatia-ascLWK.NEW.fam Bhatia-ascLWK.fam
mv Bhatia-ascGWD.NEW.fam Bhatia-ascGWD.fam
mv AMR-ascYRI.NEW.fam AMR-ascYRI.fam
mv AMR+panels-ascYRI-maf0.05.NEW.fam AMR+panels-ascYRI-maf0.05.fam
mv all_phase3_split.NEW.fam all_phase3_split.fam 
