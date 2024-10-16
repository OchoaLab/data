#  Instructions for real data processing shared across projects 

Includes R scripts and bash commands (mostly based on plink2) with instructions for processing real datasets in the usual ways (download, reformatting, merging, filtering for biallelic autosomal loci, by MAF, LD pruning, and subpopulation subsets).

Noteworthy instruction files:

- [1000 Genomes high coverage (NYGC) version, n = 2504](tgp-nygc.bash) 
- [1000 Genomes high coverage (NYGC) version plus trios, n = 3202](tgp-nygc2.bash) 
- [Human Genome Diversity Panel, whole genome sequencing version](hgdp_wgs.bash)
- [Human Origins and Pacific merged](humanOrigins.bash)
- [Allen Ancient DNA resource](ancient.bash)
- [HCHS/SOL V2 from dbGaP](hchs-sol-v2.bash)

Some of the rest of the files are a bit of a dump and may be obsolete (i.e. other 1000 genomes versions) but are retained as the commands remain useful and/or for reference.

This repository doesn't contain data, just code to process data.
