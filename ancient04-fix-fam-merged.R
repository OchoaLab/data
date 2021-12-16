library(genio)

# go where the data is
setwd( '~/dbs/ancient/' )

# load FAM files
# this one has been corrected
fam <- read_fam( 'v50.0_HO_public' )

# this is the one to replace
fam2 <- read_fam( 'v50' )

# align the new one to the old one
indexes <- match( fam2$id, fam$id )
fam <- fam[ indexes, ]
# make sure it was done right
stopifnot( all( fam2$id == fam$id ) )

# one unexpected problem is the phenotype is encoded differently in both version
# keep previous version for consistency (plink must like it better)
fam$pheno <- -9

# now create version to replace old one
write_fam( 'v50_FIXED', fam )
