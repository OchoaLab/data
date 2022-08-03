base0='hgdp_wgs.20190516.full'
basec=$base0.chr
url='ftp://ngs.sanger.ac.uk/production/hgdp/hgdp_wgs.20190516/'

################
### DOWNLOAD ###
################

# download metadata too
wget $url/metadata/hgdp_wgs.20190516.metadata.txt

# VCF files per chromosome
for chr in {1..22} X Y
do
    # download files
    wget $url$basec$chr.vcf.gz
    wget $url$basec$chr.vcf.gz.tbi # got but did not use
done

#####################
### HEADER CHECKS ###
#####################

# are all headers the same?
# All autosomes yes, but X and Y differ (will ignore)

# get first one separately, compare to all others
chr=1
zgrep '^#' $basec$chr.vcf.gz > header$chr.vcf
# skippped some autosomes (all tested autosomes agreed)
for chr in {2..10} 22 X Y
do
    zgrep '^#' $basec$chr.vcf.gz > header$chr.vcf
    diff -q header$chr.vcf header1.vcf
done
# Files headerX.vcf and header1.vcf differ
# Files headerY.vcf and header1.vcf differ
# cleanup
rm header*.vcf

#############
### MERGE ###
#############

# # bcftools: error while loading shared libraries: libhts.so.2: cannot open shared object file: No such file or directory
# # needed this hack for bcftools to work...
# export LD_LIBRARY_PATH=/usr/lib64/R/library/Rhtslib/usrlib/ # libhts.so.2
# # path from:
# find / -name libhts.so.2
# # alternative (untested, run only once forever?)
# sudo ldconfig

# merge with a proper VCF tool
# only autosomes
bcftools concat -n -Oz -o hgdp_wgs_autosomes.vcf.gz "$basec"{1..22}.vcf.gz
# 122m21.429s
# output is 308G!
# yey, extremely low mem

#################
### MAKE PGEN ###
#################

# convert to pgen!
plink2 --vcf hgdp_wgs_autosomes.vcf.gz --make-pgen vzs --out hgdp_wgs_autosomes
# 174m51.457s
# mem 27%
# pgen is only 3.7G! (+4.9G pvar.zst, or 8.6G in total).

# cleanup
# this monstrous VCF file is no longer needed, entirely redundant for our purposes with smaller PGEN file
rm hgdp_wgs_autosomes.vcf.gz

#########################################
### ASSIGN UNIQUE IDS TO LOCI W/O IDS ###
#########################################

# set missing IDs to unique values to avoid these being detected as repeated IDs
plink2 --pfile hgdp_wgs_autosomes vzs --set-missing-var-ids '@:#' --make-just-pvar zs --out hgdp_wgs_autosomes_uniq
# replace data
mv hgdp_wgs_autosomes_uniq.pvar.zst hgdp_wgs_autosomes.pvar.zst
# trash
rm hgdp_wgs_autosomes_uniq.log

################
### MAKE BED ###
################

# filter more and convert to BED
time plink2 --pfile hgdp_wgs_autosomes vzs --var-filter --snps-only just-acgt --max-alleles 2 --make-bed --out hgdp_wgs_autosomes
# 5m12.584s viiiaR5

# data dimensions
zstdcat hgdp_wgs_autosomes.pvar.zst |wc -l
# 75,310,422
wc -l hgdp_wgs_autosomes.{bim,fam}
# 63,540,915 hgdp_wgs_autosomes.bim
#        929 hgdp_wgs_autosomes.fam

# cleanup
rm hgdp_wgs_autosomes.log

###############
### FIX FAM ###
###############

Rscript ~/docs/ochoalab/data/fam_add_hgdp_metadata.R hgdp_wgs.20190516.metadata.txt hgdp_wgs_autosomes.fam hgdp_wgs_autosomes.NEW.fam 
# replace when satisfied
mv hgdp_wgs_autosomes.NEW.fam hgdp_wgs_autosomes.fam

################
### LD PRUNE ###
################

# this command determines the loci to keep or exclude
time plink2 --bfile hgdp_wgs_autosomes --indep-pairwise 1000kb 0.3 --out hgdp_wgs_autosomes
# 423m2.773s/2504m42.859s (real/user) # viiiaR5 (7h)
wc -l hgdp_wgs_autosomes.prune.in
# 3,567,128

# this actually filters the data
time plink2 --bfile hgdp_wgs_autosomes --extract hgdp_wgs_autosomes.prune.in --make-bed --out hgdp_wgs_autosomes_ld_prune_1000kb_0.3
# 2m50.058s viiiaR5

# cleanup
rm hgdp_wgs_autosomes.prune.{in,out} 
rm hgdp_wgs_autosomes.log hgdp_wgs_autosomes_ld_prune_1000kb_0.3.log

# a surprising amount of loci get eliminated!
wc -l hgdp_wgs_autosomes.bim
# 63540915
wc -l hgdp_wgs_autosomes_ld_prune_1000kb_0.3.bim
# 3567128
c 3567128/63540915
# 0.0561390719664644


##################
### MAF 1% cut ###
##################

# start from LD pruned data
name="hgdp_wgs_autosomes_ld_prune_1000kb_0.3"

time plink2 --bfile $name --maf 0.01 --make-bed --out $name"_maf-0.01"
# 0m6.299s viiiaR5

# cleanup
rm $name"_maf-0.01".log

wc -l $name.bim
# 3567128
wc -l $name"_maf-0.01".bim
# 924892
c 924892/3567128
# 0.259281976985407


###################
### MISSINGNESS ###
###################

# start from most filtered data
name="hgdp_wgs_autosomes_ld_prune_1000kb_0.3_maf-0.01"
name_out=$name"_geno-0.1"

# apply geno filter, which is most severe in this dataset than all other comparable ones
time plink2 --bfile $name --geno 0.1 --make-bed --out $name_out
# 0m2.047s viiiaR5

# cleanup
rm $name_out.log

wc -l $name.bim
# 924892
wc -l $name_out.bim
# 771322
c 771322/924892
# 0.833958991968792
