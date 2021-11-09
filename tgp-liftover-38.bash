# liftover
# downloaded executable and chain files for local run
# http://hgdownload.cse.ucsc.edu/downloads.html
# wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/liftOver
# wget http://hgdownload.cse.ucsc.edu/goldenPath/hg38/liftOver/hg38ToHg19.over.chain.gz
# wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz
# binary now on path, chain files under ~/dbs/liftOver/

# create BED file from TGP to pass to liftOver
time perl -w bim_to_bed.pl ~/dbs/tgp/plink2/all_phase3_filt-minimal.bim
# 1m56.977s ideapad
# creates ~/dbs/tgp/plink2/all_phase3_filt-minimal_ranges.bed

cd ~/dbs/tgp/plink2/

# rename for clarity
mv all_phase3_filt-minimal_ranges.bed all_phase3_filt-minimal_ranges37.bed

# run liftover
liftOver all_phase3_filt-minimal_ranges37.bed ~/dbs/liftOver/hg19ToHg38.over.chain.gz all_phase3_filt-minimal_ranges38.bed all_phase3_filt-minimal_ranges38_unmapped

# ls -lh all_phase3_filt-minimal_ranges37.bed all_phase3_filt-minimal_ranges38.bed all_phase3_filt-minimal_ranges38_unmapped
# # -rw-rw-r--. 1 viiia viiia 1.8G Nov  8 16:59 all_phase3_filt-minimal_ranges37.bed
# # -rw-rw-r--. 1 viiia viiia 1.8G Nov  8 17:20 all_phase3_filt-minimal_ranges38.bed
# # -rw-rw-r--. 1 viiia viiia 557K Nov  8 17:20 all_phase3_filt-minimal_ranges38_unmapped
# grep -c -v '^#' all_phase3_filt-minimal_ranges38_unmapped
# # 14246
# wc -l all_phase3_filt-minimal_ranges3{7,8}.bed 
# # 77513663 all_phase3_filt-minimal_ranges37.bed
# # 77499417 all_phase3_filt-minimal_ranges38.bed
# c 77513663-77499417
# # 14246 # perfect!

# create BIM with new info, and with unmapped data formatted so it's easy to remove
# (negative pos?)
time perl -w ~/docs/ochoalab/data/liftover-process-bim-bed.pl all_phase3_filt-minimal_ranges38_unmapped all_phase3_filt-minimal_ranges38.bed all_phase3_filt-minimal.bim all_phase3_filt-minimal_v38.bim
# 3m39.712s ideapad

# yey as expected
wc -l all_phase3_filt-minimal{,_v38}.bim
# 77513663 all_phase3_filt-minimal.bim
# 77513663 all_phase3_filt-minimal_v38.bim

# also inspected tails, saw data matches final entries as expected

# archive some big temporary data away from sync space
mkdir tgp-liftover
mv all_phase3_filt-minimal_ranges3{7,8}.bed all_phase3_filt-minimal_ranges38_unmapped tgp-liftover
gzip tgp-liftover/*
mv tgp-liftover/ ~/tmp/

# setup v38 fully, to filter and reorder as needed
# first give the unfiltered file a different name
mv all_phase3_filt-minimal_v38.bim all_phase3_filt-minimal_v38-unfilt.bim
# and softlinks to the rest of the original data
ln -s all_phase3_filt-minimal.bed all_phase3_filt-minimal_v38-unfilt.bed
ln -s all_phase3_filt-minimal.fam all_phase3_filt-minimal_v38-unfilt.fam

# filter with plink2
# also fixes "split chromosome" issue
# have to do in two steps, first make a pgen, then convert that to bed
time plink2 --bfile all_phase3_filt-minimal_v38-unfilt --autosome --allow-extra-chr --sort-vars --make-pgen --out all_phase3_filt-minimal_v38
# 9m9.164s viiiaR5
# (ideapad ran out of memory)

# confirmed some loci lost, as expected
# wc -l all_phase3_filt-minimal_v38.psam # 2505
# wc -l all_phase3_filt-minimal.fam      # 2504
# wc -l all_phase3_filt-minimal.bim      # 77513663
# wc -l all_phase3_filt-minimal_v38.pvar # 77470433 # delta = 43230

time plink2 --pfile all_phase3_filt-minimal_v38 --make-bed --out all_phase3_filt-minimal_v38
# 12m19.538s viiiaR5

wc -l all_phase3_filt-minimal_v38.{bim,fam}
# 77470432 all_phase3_filt-minimal_v38.bim
#     2504 all_phase3_filt-minimal_v38.fam

# verified bim order in R

# move more intermediate files to temporarly location out of sync space
mv all_phase3_filt-minimal_v38.p{gen,sam,var} all_phase3_filt-minimal_v38.log all_phase3_filt-minimal_v38-unfilt.bim ~/tmp/tgp-liftover/
# remove these symlinks
rm all_phase3_filt-minimal_v38-unfilt.{bed,fam}
