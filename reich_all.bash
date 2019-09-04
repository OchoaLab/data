# load function to convert GENO inputs into the more usual BED format
. geno2bed.bash

geno2bed v37.2.1240K_HumanOrigins
# real	6m44.782s
geno2bed v37.2.1240K
# real	8m57.557s

# fix FAM files to contain subpopulations
Rscript ~/docs/ochoalab/data/ind_to_fam.R *.ind

