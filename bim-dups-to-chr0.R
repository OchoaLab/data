library(genio)
library(ochoalabtools)

args <- args_cli()
name_in <- args[1]
name_out <- args[2]
if ( is.na( name_out ) )
    stop( 'usage: <in> <out>' )

bim <- read_bim( name_in )

# find IDs that appear more than once
x <- table( bim$id )
ids <- names( x[ x>1 ] )

# in total, duplicates are problematic (sometimes ref and alt are the same for both copies), just remove them!
# easiest way is to overwrite to set chr=0
bim$chr[ bim$id %in% ids ] <- 0

# other problematic cases to remove in this step
# anything with a position of zero (there are a few)
bim$chr[ bim$pos == 0 ] <- 0
# any row where ref and alt match each other
bim$chr[ bim$ref == bim$alt ] <- 0

# done, save new copy!
write_bim( name_out, bim )
