library(readr)
library(genio)

# go where the data is
setwd( '~/dbs/ancient/' )

# read a local list of african countries, as they appear in the annotations file
countries_afr <- read_lines( 'african-countries.txt' )

# read annotations table, where country is listed
data <- read_tsv( 'v50.0_HO_public_ind-filt.anno', show_col_types = FALSE )

# subset big table by country
data <- data[ data$Country %in% countries_afr, ]

# extract IDs remaining
ids <- data$`Version ID`

# last thing is to pick FAM table to present to --keep, filtered as desired
fam <- read_fam( 'v50.0_HO_public_ind-filt_autosomes' )
# filter it
fam <- fam[ fam$id %in% ids, ]

# these should have the same number of individuals at this point
stopifnot( nrow( fam ) == nrow( data ) )
# and IDs are in the same order!
stopifnot( all( fam$id == ids ) )

# write FAM file out, for filtering
write_fam( 'v50.0_HO_public_ind-filt_autosomes_AFR-filt', fam )

# also write filtered annotations table
write_tsv( data, 'v50.0_HO_public_ind-filt_autosomes_AFR.anno' )
