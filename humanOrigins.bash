########################
### EXECUTABLE PATHS ###
########################

# wget https://github.com/DReichLab/EIG/archive/v7.2.1.tar.gz

# load function to convert GENO inputs into the more usual BED format
. geno_to_bed.bash

# plink2
plink2="$HOME/bin/plink2"
# plink1 (for merging files only)
plink1="$HOME/bin/plink1/plink"

#################
### DOWNLOADS ###
#################

# MAIN ARCHIVE:
# https://reich.hms.harvard.edu/datasets

## assume the raw archive NearEastPublic.zip is unpacked here:
cd ~/dbs/humanOrigins/

# TODO:
# - actually download and write explicit processing (some of these dirs are pretty bulky, we only need a few subfiles)
# - add newer data (for newer papers)

# a few files I've downloaded
wget https://reich.hms.harvard.edu/sites/reich.hms.harvard.edu/files/inline-files/NearEastPublic.tar.gz
wget https://reich.hms.harvard.edu/sites/reich.hms.harvard.edu/files/inline-files/SkoglundEtAl2016_Pacific_FullyPublic%20%283%29.tar.gz
wget https://reich.hms.harvard.edu/sites/reich.hms.harvard.edu/files/inline-files/EuropeFullyPublic.tar.gz

# store lengthy names into more intuitive variables
hoAll=HumanOrigins2583
hoPub=HumanOriginsPublic2068
pacAll=SkoglundEtAl2016_Pacific_v13.1
pacPub=SkoglundEtAl2016_Pacific_FullyPublic
ancL16=AncientLazaridis2016

################
### geno2bed ###
################

## describes initial steps cleaning $hoPub.geno (from NearEastPublic file from Reich Lab, Lazaridis et al. 2016)
## NOTE: the full Pacific data was given to me in BED format already, no need to bother with this!

## actual inputs
geno_to_bed $hoPub # original HO
# numvalidind:   2068  maxmiss: 2068001
# real	4m50.414s
geno_to_bed $hoAll # extended HO!
# numvalidind:   2583  maxmiss: 2583001
# real	6m13.144s
geno_to_bed $ancL16 # ancient data we've ignored so far...
# numvalidind:    294  maxmiss: 294001
# real	1m4.631s
geno_to_bed $pacPub
# numvalidind:     74  maxmiss: 74001
# real	0m11.298s

# resulting *.fam files don't preserve subpopulations, so this custom script fixes that (rewrites every *.fam, which was derived anyway so it's ok)
Rscript ~/docs/ochoalab/data/ind_to_fam.R $ancL16.ind $hoAll.ind $hoPub.ind $pacPub.ind

##############################
### MERGING MAIN HO w/ PAC ###
##############################

# INPUTS

# full data
wc -l $hoAll.{bim,fam}
# 621799 HumanOrigins2583.bim
#   2583 HumanOrigins2583.fam
wc -l $pacAll.{bim,fam}
# 597573 SkoglundEtAl2016_Pacific_v13.1.bim
#    360 SkoglundEtAl2016_Pacific_v13.1.fam

# public data
wc -l $hoPub.{bim,fam}
# 621799 HumanOriginsPublic2068.bim
#   2068 HumanOriginsPublic2068.fam
wc -l $pacPub.{bim,fam}
# 597573 SkoglundEtAl2016_Pacific_FullyPublic.bim
#     74 SkoglundEtAl2016_Pacific_FullyPublic.fam

# get list of loci in the pacific data
# (separately found it was the subset of the two sets to merge)
$plink2 --bfile $pacAll --write-snplist --out lociPac
# this confirms that all IDs are unique in this data!
wc -l lociPac.snplist        # 597573
uniq lociPac.snplist | wc -l # 597573
# cleanup
rm lociPac.log

# new merge operation
# NEED plink1 for this only!
# also, can't merge and filter at the same time, so dumb...

# full data
# merge only
$plink1 --keep-allele-order --indiv-sort none --bfile $hoAll --bmerge $pacAll --out HoPacAll0

# identify singleton subpopulations!
Rscript ~/docs/ochoalab/data/singleton_fams.R HoPacAll0 rm-fam.txt
# manually add AA
echo AA >> rm-fam.txt
# manually add ancient subpops (note Lapita_Tonga was a singleton, so only one addition is needed)
echo Lapita_Vanuatu >> rm-fam.txt

# filter now (compared to old, added "--autosome --mac 1")
# NOTE: loci are all biallelic SNPs, so no other filters are necessary
$plink2 --bfile HoPacAll0 --extract lociPac.snplist --remove-fam rm-fam.txt --autosome --mac 1 --make-bed --out HoPacAll

# map IDs at this stage
perl -p -i -e 's/Gujarati[A-D]/Gujarati/' HoPacAll.fam
perl -p -i -e 's/Southwest/SW/' HoPacAll.fam

# new files
wc -l HoPacAll0.{bim,fam}
# 621799 HoPacAll0.bim
#   2943 HoPacAll0.fam
wc -l HoPacAll.{bim,fam}
# 588091 HoPacAll.bim # reasonable filters, lost 9482 loci
#   2922 HoPacAll.fam

# cleanup
rm HoPacAll0.*
rm HoPacAll.{log,nosex}
rm rm-fam.txt

# old ones
wc -l HumanOriginsAndPac2939.{bim,fam}
# 597573 HumanOriginsAndPac2939.bim
#   2939 HumanOriginsAndPac2939.fam
# This one didn't have MAC filter!  That's why numbers disagree!
wc -l ~/dbs/humanOrigins/HumanOriginsAndPac2939-filt.{bim,fam}
# 593124 /home/viiia/dbs/humanOrigins/HumanOriginsAndPac2939-filt.bim # only lost 4449
#   2939 /home/viiia/dbs/humanOrigins/HumanOriginsAndPac2939-filt.fam

# REPEAT for public data
# ..............

# TODO
# + remove ancient samples in PAC
# + fix .fam data to include (pop, id) in first two columns (all files have issues!)
# - PAC pub
#   - potential MAP cM=NA issues
#   - clean up IDs more...
# + filter as in paper:
#   + no subpop singletons and AA
#   x indInfo, do we need it?  We can experiment without it!
#     + redundant with new fam: id/sex/pop
#     + non-redundant:
#       x source # not used anywhere!
#       x pop2   # for fine-lab map, and to sort more finely (is it needed?)
#   x use fine labels for these cases only...

##################
### LD pruning ###
##################

# this command determines the loci to keep or exclude
time $plink2 --bfile HoPacAll --indep-pairwise 1000kb 0.7 --out HoPacAll
# 24s on ideapad!

# this actually filters the data
time $plink2 --bfile HoPacAll --extract HoPacAll.prune.in --make-bed --out HoPacAll_ld_prune_1000kb_0.7 

# cleanup
rm HoPacAll.prune.{in,out} 
rm HoPacAll.log HoPacAll_ld_prune_1000kb_0.7.log

# a surprising amount of loci get eliminated!
wc -l HoPacAll.bim
# 588091
wc -l HoPacAll_ld_prune_1000kb_0.7.bim 
# 393280
# c 393280/588091
# 0.668740041932286
