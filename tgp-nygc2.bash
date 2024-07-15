# first (older) version used raw sequencing with missingness, and unphased, and was original n = 2504 set
# second version (this) is phased, has no missingness, and has trios!  n = 2504 + 698 = 3202

# NOTE: use FTP protocol (originally used HTTP and it was infeasibly slow)
url0='ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage'
url=$url0'/working/20220422_3202_phased_SNV_INDEL_SV'
base_pre='1kGP_high_coverage_Illumina.chr'
base_pos='.filtered.SNV_INDEL_SV_phased_panel.vcf.gz'

################
### DOWNLOAD ###
################

# place raw data in a location that doesn't get synced
cd /scratch1/dbs2/
mkdir tgp-nygc2
cd tgp-nygc2

# actually downloaded all of these manually using the http:/ versions (latest "wget2" doesn't support FTP!)
# download metadata too
wget $url0/20130606_g1k_3202_samples_ped_population.txt # 25-May-2020 14:14 (http ls)
wget $url0/working/1kGP.3202_samples.pedigree_info.txt  # 06-Oct-2021 10:28 # redundant?
# other useful info
wget $url0/20200526_1000G_2504plus698_high_cov_data_reuse_README.txt
wget $url0/README_2504_plus_additional_698_related_samples.txt
wget $url0/working/README_111822.pdf

# these commands download everything in the $url directory, as desired!
ncftp $url
# run these inside the ncftp console: (runs for hours...)
get *
exit

# edit checksum with R, just reverses column order
# library(readr)
# data <- read_table( '20220804_manifest.txt', col_names = c('file','sum') )
# data <- data[,2:1]
# write_delim( data, '20220804_manifest.md5', delim = ' ', col_names = FALSE )

# validate downloads!
time md5sum -c 20220804_manifest.md5
# 4m6.639s viiiaR5

#################
### MAKE PGEN ###
#################

# rename chrX, only one with a weird update that resulted in an off-pattern file name
rename .v2 '' $base_pre'X'*

# these files are monstrous, so shrink ASAP
# - reencode to compact plink2 format (input is hard calls only, so here there's practically no loss; weird INFO fields are also preserved in pvar!)
# - remove non-PASS and MAC=0 loci (in this case nothing is removed, everything PASSes and there are no fixed loci?)

# NOTES:
# - this data has many fewer loci than the older rawer sequencing data (chr1 went from 8.1M to 5.8M)
# - all autosomal loci have non-missing and unique IDs!  (old data didn't, so we had to add a step to add that; format appears to be the same as our previous choice!)
# - tried adding chrX, but the below command resulted in this error, which discouraged me for now (I don't have any immediate need for any X data):
#   > Error: chrX is present in the input file, but no sex information was provided; rerun this import with --psam or --update-sex.  --split-par may also be appropriate.

for chr in {1..22}; do
    time plink2 --vcf $base_pre$chr$base_pos --var-filter --mac 1 --make-pgen vzs --out chr$chr
done

##############
### PMERGE ###
##############

# TODO: compare to CureGN's pipeline (more recent), did I do something better in that case???
# confirmed this is the phased data I want, but what do I do about formats now?

name=tgp-nygc-autosomes

# creates list of files to merge
for chr in {1..22}; do
    echo chr$chr >> files-merge-list.txt
done

# run merge command
time plink2 --pmerge-list files-merge-list.txt pfile-vzs --pmerge-output-vzs --out $name
# 8m13.595s viiiaR5; max mem about 7%!
# dims according to report: 3202 x 70,692,015 (OLD DATA: 2504 x 102,804,074)

du -hs $name.*
# 8.4G    tgp-nygc-autosomes.pgen
# 36K     tgp-nygc-autosomes.psam
# 4.8G    tgp-nygc-autosomes.pvar.zst

# cleanup, can toss per-chr copies and other stuff
for chr in {1..22}; do
    rm chr$chr.{log,pgen,psam,pvar.zst}
done
rm files-merge-list.txt

# this confirms that there's no missingness in this data!
time plink2 --pfile $name vzs --missing sample-only --out $name --memory 7000 --threads 1
# 1m20.576s dell-xps
# confirm by inspection that every sample has MISSING_CT = F_MISS = 0
less $name.smiss
# cleanup
rm $name.{smiss,log}


################
### MAKE BED ###
################

# NOTE:
# - this version loses not just multiallelic variants but also phase info
# - previous version also removed indels, but this time we'll keep them, for now

# filter more and convert to BED
time plink2 --pfile $name vzs --max-alleles 2 --mac 1 --make-bed --out $name
# 12m14.266s viiiaR5

# data dimensions
zstdcat $name.pvar.zst |wc -l
# 70,692,119 # includes header lines
wc -l $name.{bim,fam}
# 70,692,015 tgp-nygc-autosomes.bim
#      3,202 tgp-nygc-autosomes.fam

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

# transfer updates to psam version!
time plink2 --fam $name.fam --make-just-psam --out $name-NEW
# inspect output, replace if satisfied
mv $name-NEW.psam $name.psam
# cleanup
rm $name-NEW.log

##########
### MV ###
##########

# move working data from scratch space to sync space
# we want more complete phased versions too!
mkdir ~/dbs/tgp-nygc2/
mv $name.{bed,bim,fam,pgen,psam,pvar.zst} ~/dbs/tgp-nygc2/
# rest of the commands happen in that space
cd ~/dbs/tgp-nygc2/

# copy manually-constructed pop annotations from much older versions of the TGP data...
cp ../tgp-nygc/pops-annot.txt .

################
### FOUNDERS ###
################

# removes non-founders, which is usually a better choice to have less related individuals, but particularly here because there are so many trios
time plink2 --pfile $name vzs --keep-founders --mac 1 --make-pgen vzs --out $name-founders
# 608 samples removed, 2594 samples remain.
# 3546 variants removed due to --mac, 70688469 variants remain.
# 2m12.108s/6m31.705s dell-xps

# so compared to classic TGP (2504), keeping parents and never their children gains us only 90 individuals.  The paper mentions 602 trios.  (608 samples were removed, so that's very close, the extras I think are some partial relatives that were previously known.)  Is it then that the additions are most often children rather than their parents?

# create bed/bim/fam version of this
time plink2 --pfile $name-founders vzs --max-alleles 2 --mac 1 --make-bed --out $name-founders
# 1m11.901s dell-xps

# cleanup
rm $name-founders.log
