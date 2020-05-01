# a script for transfering TGP population labels to plink FAM files
# uses genio a bit but also performs a lot of sanity checks specific to the TGP data (doesn't quite generalize)

library(readr)

setwd('~/dbs/hgdp_wgs/')

# name file paths
file_in <- 'hgdp_wgs.20190516.metadata.txt'
file_out <- 'pops-annot.txt'

# read input:
info <- read_tsv(file_in, col_types = 'ccccccddccddddd')

# columns to keep
# note, we toss individual info here, focus only on subpopulation data
names_keep <- c('population', 'latitude', 'longitude', 'region')
info <- info[ , names_keep ]

nrow(info)
# [1] 929

# toss repeated rows, leaving us with the unique data of interest
info <- unique(info)

nrow(info)
# [1] 54 # the expected number!

# reorder by region
region_order <- c(
    'AFRICA',
    'MIDDLE_EAST',
    'EUROPE',
    'CENTRAL_SOUTH_ASIA',
    'EAST_ASIA',
    'AMERICA',
    'OCEANIA'
)
indexes <- order( match(info$region, region_order) )
info <- info[ indexes, ]

# rename columns to match our existing files
names(info)[ names(info) == 'population' ] <- 'pop'
names(info)[ names(info) == 'region' ] <- 'superpop'
names(info)[ names(info) == 'longitude' ] <- 'x'
names(info)[ names(info) == 'latitude' ] <- 'y'

# save where kinship matrix will be
setwd('~/docs/ochoalab/storey/fst/simulations/hgdp_wgs_autosomes/')

# save table
write_tsv(info, file_out)
