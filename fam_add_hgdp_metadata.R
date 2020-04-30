# a script for transfering TGP population labels to plink FAM files
# uses genio a bit but also performs a lot of sanity checks specific to the TGP data (doesn't quite generalize)

library(genio)
library(readr)

# constants
verbose <- TRUE

# get arguments from terminal
args <- commandArgs(trailingOnly=TRUE)

# usage
if (length(args) < 3) {
    message('Usage: Rscript fam_add_hgdp_metadata.R <input.txt> <input.fam> <output.fam>')
} else {
    # name file paths
    file_in_txt <- args[1]
    file_in_fam <- args[2]
    file_out <- args[3]
    
    # read inputs:
    fam <- read_fam(file_in_fam, verbose = verbose)
    info <- read_tsv(file_in_txt, col_types = 'ccccccddccddddd')

    # make sure columns to overwite are trivial as expected
    stopifnot( fam$fam == 0 )
    stopifnot( fam$sex == 0 )
    
    # make sure desired columns in info file are present
    stopifnot( c('sample', 'population', 'sex') %in% names(info) )

    # make sure all IDs in fam are present in info
    stopifnot( fam$id %in% info$sample )

    # now match the respective rows
    indexes <- match( fam$id, info$sample )

    # make sure IDs agree after this reordering/subsetting
    # (I often get this wrong)
    stopifnot( fam$id == info$sample[ indexes ] )

    # overwrite column as desired
    fam$fam <- info$population[ indexes ]
    fam$sex <- sex_to_int( info$sex[ indexes ] )
    
    # write output file
    write_fam(file_out, fam, verbose = verbose)
}
