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
~/bin/plink2 --vcf hgdp_wgs_autosomes.vcf.gz --make-pgen vzs --out hgdp_wgs_autosomes
# 174m51.457s
# mem 27%
# pgen is only 3.7G! (+4.9G pvar.zst, or 8.6G in total).

# cleanup
# this monstrous VCF file is no longer needed, entirely redundant for our purposes with smaller PGEN file
rm hgdp_wgs_autosomes.vcf.gz

################
### MAKE BED ###
################

# filter more and convert to BED
~/bin/plink2 --pfile hgdp_wgs_autosomes vzs --snps-only just-acgt --max-alleles 2 --make-bed --out hgdp_wgs_autosomes
# 7m1.854s
# mem 37%
# BED is 15G, BIM is 1.8G (total ~18G)

# data dimensions
zstdcat hgdp_wgs_autosomes.pvar.zst |wc -l
# 75,310,422
wc -l hgdp_wgs_autosomes.{bim,fam}
# 65,656,855 hgdp_wgs.20190516.full.autosomes.bim
#        929 hgdp_wgs.20190516.full.autosomes.fam

# cleanup
rm hgdp_wgs_autosomes.log

###############
### FIX FAM ###
###############

Rscript ~/docs/ochoalab/data/fam_add_hgdp_metadata.R hgdp_wgs.20190516.metadata.txt hgdp_wgs_autosomes.fam hgdp_wgs_autosomes.NEW.fam 
# replace when satisfied
mv hgdp_wgs_autosomes.NEW.fam hgdp_wgs_autosomes.fam

