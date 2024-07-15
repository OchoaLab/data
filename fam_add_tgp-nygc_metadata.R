library(genio)
library(readr)

# run where the data is!

# load two seemingly redundant sources of info
data1 <- read_table('1kGP.3202_samples.pedigree_info.txt') # smaller but newer table
data2 <- read_table('20130606_g1k_3202_samples_ped_population.txt') # bigger but older table
# and existing fam, to make sure output order matches
fam <- read_fam( 'tgp-nygc-autosomes' )

# yey, rows are already aligned by individual, nobody extra
stopifnot( all( data1$sampleID == data2$SampleID ) )

# separate script shows data1 appears to be more updated, so let's start from that one by adapting columns
names( data1 )[ names( data1 ) == 'sampleID' ] <- 'id'
names( data1 )[ names( data1 ) == 'fatherID' ] <- 'pat'
names( data1 )[ names( data1 ) == 'motherID' ] <- 'mat'
# original col "sex" is already ok

# add "fam" from other table
data1$fam <- data2$Population

# lastly, need dummy/missing pheno
data1$pheno <- -9

# however, the actual samples we have are a subset of this table
stopifnot( all( fam$id %in% data1$id ) ) # yes, they are a subset
data1 <- data1[ match( fam$id, data1$id ), ] # subset/reorder
stopifnot( all( data1$id == fam$id ) ) # perfect agreement now!

# write output
write_fam( 'tgp-nygc-autosomes-NEW', data1 )
