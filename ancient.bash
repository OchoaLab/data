# NOTE: final v50 contains more than autosomes, but v50_v38 is autosomes only

# download data
# https://reich.hms.harvard.edu/allen-ancient-dna-resource-aadr-downloadable-genotypes-present-day-and-ancient-dna-data
# get both versions because locus/ind coverages vary (one not subset of other)
wget https://reichdata.hms.harvard.edu/pub/datasets/amh_repo/curated_releases/V50/V50.0/SHARE/public.dir/v50.0_1240K_public.tar
wget https://reichdata.hms.harvard.edu/pub/datasets/amh_repo/curated_releases/V50/V50.0/SHARE/public.dir/v50.0_HO_public.tar

# extract both
tar -xf v50.0_1240K_public.tar
tar -xf v50.0_HO_public.tar
# cleanup
rm v50.0_1240K_public.tar v50.0_HO_public.tar


# load function to convert GENO inputs into the more usual BED format
. geno_to_bed.bash
# convert to plink format!
geno_to_bed v50.0_1240k_public
# 18m13.327s
geno_to_bed v50.0_HO_public
# 9m59.136s

# fix FAM files to contain subpopulations
# move original backups
mv v50.0_1240k_public.fam v50.0_1240k_public.fam0
mv v50.0_HO_public.fam v50.0_HO_public.fam0
# create the new files
Rscript ~/docs/ochoalab/data/ind_to_fam.R *.ind
# inspect, then toss bad backups when satisfied
less v50.0_1240k_public.fam v50.0_1240k_public.fam0
less v50.0_HO_public.fam v50.0_HO_public.fam0
rm v50.0_1240k_public.fam0 v50.0_HO_public.fam0

# move original geno data elsewhere, I won't need it!
mkdir ../../dbs2/ancient/
mv *.geno *.ind *.snp ../../dbs2/ancient/

# dimensions of two main files
wc -l v50.0_1240k_public.{fam,bim}
#   10391 v50.0_1240k_public.fam
# 1233013 v50.0_1240k_public.bim
wc -l v50.0_HO_public.{fam,bim}
#   14313 v50.0_HO_public.fam
#  597573 v50.0_HO_public.bim

# verify that 'v50.0_1240k_public' is contained in 'v50.0_HO_public' in terms of individuals but the other way around in terms of loci
# (run from data location)
Rscript ancient01-intersect-inds-loci.R

# consider what a full union of data looks like
# total dims: 14313*1233013 = 17648115069
# empty subset: "(14313-10391)*(1233013-597573)" = 2492195680
# proportion empty: 2492195680/17648115069 = 0.141215969538735
# so proper merge won't be so bad, let's try this!

# let's leave v50.0_1240k_public as is, and extract the difference from the other file
time plink2 --bfile v50.0_HO_public --remove v50.0_1240k_public.fam --make-bed --out v50.0_HO_public-diff
# 0m0.883s

# verified this is exactly expected size!
wc -l v50.0_HO_public-diff.{fam,bim}
#   3922 v50.0_HO_public-diff.fam
# 597573 v50.0_HO_public-diff.bim

# now merge, plink1 is required for this
time plink1 --keep-allele-order --bfile v50.0_1240k_public --bmerge v50.0_HO_public-diff --out v50
# 1m18.820s

# verified dimensions are as expected
wc -l v50.{fam,bim}
#   14313 v50.fam
# 1233013 v50.bim

# lastly, verified with R that BIM files agree (they only differ in whitespace).  I.e. alleles indeed didn't get flipped, reordered, and nothing else weird happened.

# cleanup, don't need "-diff" anymore
rm v50.0_HO_public-diff.*

# this script finds that all of the HGDP and TGP individuals are in the sequencing file!
# however, "ancient" has only 1.2M loci, whereas HGDP-WGS has 64M and TGP 92M!
# can re-evaluate after zeroing in on a given locus, but might want to replace those samples to have more loci
Rscript ancient02-vs-hgdp-tgp-wgs.R

# this identifies lots of individuals to remove for various reasons
time Rscript ancient03-inds-filt.R
# 14313	Original
# 14016	Rm questionable
# 13624	Rm ignore
# 13609	Rm outlier
# 13488	Rm brother|sister|sibling
# 13405	Rm son|daughter|child
# 13378	Rm father|mother
# 13376	Rm relative
# 13279	Rm .rel.
# 13277	Rm _rel
# 11830	Rm repeats
# real	0m0.778s

# TODO: create data that is actually filtered!




### LIFTOVER hg38 ###

# to make any HGDP/TGP comparisons even possible, must liftover!

# create BED file from TGP to pass to liftOver
time perl -w ~/docs/ochoalab/data/bim_to_bed.pl ~/dbs/ancient/v50.bim
# 0m1.241s
# creates v50_ranges.bed
# NOTE: contains up to chr24, maybe should clean to have autosomes only?

# run liftover
time liftOver v50_ranges.bed ~/dbs/liftOver/hg19ToHg38.over.chain.gz v50_ranges38.bed v50_ranges38_unmapped
# 0m3.634s

# # NOTE: only autosomes were mapped
# grep -c -v '^#'  v50_ranges38_unmapped
# # 82766
# wc -l v50_ranges{,38}.bed
# # 1233013 v50_ranges.bed
# # 1150247 v50_ranges38.bed
# c 1233013-1150247
# # 82766 # perfect

# create BIM with new info, and with unmapped data formatted so it's easy to remove
# (negative pos?)
time perl -w ~/docs/ochoalab/data/liftover-process-bim-bed.pl v50_ranges38_unmapped v50_ranges38.bed v50.bim v50_hg38.bim
# 0m2.596s

# yey as expected
wc -l v50{,_hg38}.bim
# 1233013 v50.bim
# 1233013 v50_hg38.bim

# also inspected tails, saw data matches final entries as expected

# separate stuff I will likely delete later
mkdir trash
mv v50_ranges{,38}.bed v50_ranges38_unmapped trash/


# setup hg38 fully, to filter and reorder as needed
# first give the unfiltered file a different name
mv v50_hg38.bim v50_hg38-unfilt.bim
# and softlinks to the rest of the original data
ln -s v50.bed v50_hg38-unfilt.bed
ln -s v50.fam v50_hg38-unfilt.fam

# filter with plink2
# also fixes "split chromosome" issue
# have to do in two steps, first make a pgen, then convert that to bed
time plink2 --bfile v50_hg38-unfilt --autosome --allow-extra-chr --sort-vars --make-pgen --out v50_hg38
# 0m42.737s

# confirmed some loci lost, as expected
wc -l v50_hg38.psam # 14314
wc -l v50.fam      # 14313
wc -l v50.bim      # 1233013
wc -l v50_hg38.pvar # 1150108 # delta = 82905

time plink2 --pfile v50_hg38 --make-bed --out v50_hg38
# 0m45.925s

wc -l v50_hg38.{bim,fam}
# 1150107 v50_hg38.bim
#   14313 v50_hg38.fam

# move more intermediate files to temporarly location out of sync space
mv v50_hg38.p{gen,sam,var} v50_hg38.log v50_hg38-unfilt.bim trash/
# remove these symlinks
rm v50_hg38-unfilt.{bed,fam}

# final liftover cleanup
du -hs trash/ # 3.6G
rm -r trash/

