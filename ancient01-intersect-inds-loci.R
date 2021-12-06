# figure out the relationship between the two datasets we have available

library(genio)

name1 <- 'v50.0_1240k_public'
name2 <- 'v50.0_HO_public'

# first individuals
fam1 <- read_fam( name1 )
fam2 <- read_fam( name2 )

# second file has more samples
nrow(fam1) #[1] 10391
nrow(fam2) #[1] 14313

# verify ID uniqueness
stopifnot( length( unique( fam1$id ) ) == nrow( fam1 ) )
stopifnot( length( unique( fam2$id ) ) == nrow( fam2 ) )

# verified first file is entirely contained in the second!
all( fam1$id %in% fam2$id ) # [1] TRUE


# now compare loci
bim1 <- read_bim( name1 )
bim2 <- read_bim( name2 )

# as expected, here it's backwards: the first file has more loci
nrow(bim1) #[1] 1233013
nrow(bim2) #[1] 597573

# verify ID uniqueness
stopifnot( length( unique( bim1$id ) ) == nrow( bim1 ) )
stopifnot( length( unique( bim2$id ) ) == nrow( bim2 ) )

# verified second file is entirely contained in the first!
all( bim2$id %in% bim1$id ) # [1] TRUE
