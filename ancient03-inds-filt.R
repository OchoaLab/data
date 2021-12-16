# takes detailed annotation file provided and simplifies to group by sub(sub)populations, process labels and group by subpopulations, etc, mirroring my earlier HO processing

library(readr)
library(genio)

# go where the data is
setwd( '~/dbs/ancient/' )

# read the bigger of the two annotation files (the smaller one is a proper subset)
data <- read_tsv( 'v50.0_HO_public.anno', show_col_types = FALSE )
# also load FAM file, since IDs turned out to be different (and it makes it hard to apply plink filters without matching IDs)
fam <- read_fam( 'v50.0_HO_public' )

# make sure they agree
stopifnot( nrow( fam ) == nrow( data ) )
stopifnot( all( fam$id == data$`Version ID` ) )
stopifnot( all( fam$sex == sex_to_int( data$Sex ) ) )
stopifnot( all( fam$pat == 0 ) ) # all missing
stopifnot( all( fam$mat == 0 ) ) # all missing
stopifnot( all( fam$pheno == 0 ) )

# NOTE: only fam$fam vs data$`Group Label` vary slightly, that was analyzed later by hand
# easy sol is just to use data's (they appear more correct, like typos are fixed)
fam$fam <- data$`Group Label`
# write out this corrected fam file (don't replace original, will do manually)
# also note this is full data (no individuals removed)
write_fam( 'v50.0_HO_public_FIXED', fam )

# report sizes before and after filters
message( nrow( data ), "\tOriginal" )

##########################
### FILTER: ASSESSMENT ###
##########################

## # assessment looks interesting, might want to filter!
## table( data$ASSESSMENT )
## ##              MERGE_PASS                    PASS        PROVISIONAL_PASS 
## ##                       2                   13973                      22 
## ##            QUESTIONABLE   QUESTIONABLE_CRITICAL             REPLOT_PASS 
## ##                     161                     136                      17 
## ## REPLOT_PROVISIONAL_PASS 
## ##                       2 
## # most non-PASS are QUESTIONABLE and QUESTIONABLE_CRITICAL, I definitely want to remove those
## # all other cases have the word PASS in them so that all seems favorable and I'll keep!

# so filter this annotation table
indexes <- !(data$ASSESSMENT %in% c('QUESTIONABLE', 'QUESTIONABLE_CRITICAL'))
data <- data[ indexes, ]
fam <- fam[ indexes, ]

message( nrow( data ), "\tRm questionable" )

# related, many samples have an "ignore" group label, which is often based on being outliers (on PCA or otherwise), relatives of others, high missingness, etc, though sometimes there's no reason
# for simplicity let's toss them too
indexes <- !grepl( 'ignore', data$`Group Label`, ignore.case=TRUE)
data <- data[ indexes, ]
fam <- fam[ indexes, ]

message( nrow( data ), "\tRm ignore" )

# additional outliers
indexes <- !grepl( 'outlier', data$`Group Label`, ignore.case=TRUE)
data <- data[ indexes, ]
fam <- fam[ indexes, ]

message( nrow( data ), "\tRm outlier" )

# NOTE: "_o" appears to mark outliers too, but since it's not always clear, for now we'll keep

#########################
### FILTER: RELATIVES ###
#########################

# observed relative labels (all were observed lowercase, but kept case-insensitivity just in case there's unseen typos):
# father, mother, son, daughter, child, brother, sister, sibling, rel, relative
# they appear to be labeled one way only (so removing them all with these labels doesn't remove all people that were related to anybody, just a minimal independent subset presumably/sort of)
# not observed: parent

# remove sibs
indexes <- !grepl( 'brother|sister|sibling', data$`Group Label`, ignore.case=TRUE)
data <- data[ indexes, ]
fam <- fam[ indexes, ]
message( nrow( data ), "\tRm brother|sister|sibling" )

# never keep chldren of other people already present
indexes <- !grepl( 'son|daughter|child', data$`Group Label`, ignore.case=TRUE)
data <- data[ indexes, ]
fam <- fam[ indexes, ]
message( nrow( data ), "\tRm son|daughter|child" )

# now go after parents, if any remain
indexes <- !grepl( 'father|mother', data$`Group Label`, ignore.case=TRUE)
#View( data[ !indexes, ] )
data <- data[ indexes, ]
fam <- fam[ indexes, ]
message( nrow( data ), "\tRm father|mother" )

# start removing relatives
# full word has no false positives
indexes <- !grepl( 'relative', data$`Group Label`, ignore.case=TRUE)
data <- data[ indexes, ]
fam <- fam[ indexes, ]
message( nrow( data ), "\tRm relative" )
# shorter word has tons of false positives, even lowercase only
# but flanked with symbols it becomes specific
indexes <- !grepl( '\\.rel\\.', data$`Group Label`) # , ignore.case=TRUE
data <- data[ indexes, ]
fam <- fam[ indexes, ]
message( nrow( data ), "\tRm .rel." )

indexes <- !grepl( '_rel', data$`Group Label`) # , ignore.case=TRUE
data <- data[ indexes, ]
fam <- fam[ indexes, ]
message( nrow( data ), "\tRm _rel" )

# all remaining "rel"s are false positives (i.e. Ireland, Berel, etc)
## indexes <- !grepl( 'rel', data$`Group Label`) # , ignore.case=TRUE
## View( data[ !indexes, ] )


########################
### FILTER: REP INDS ###
########################

# from their website:
## Please note: The unique individual identifier is given in the 'Master ID' field. Multiple representatives of the same individual are thus indicated by a duplicated master ID. Some individuals are represented more than once to reflect different versions of processing or different publications. This may happen for example, when increased coverage has been generated after an initial publication. For many analyses it may be necessary to select only one version: for example the single sample Loschbour (master ID=I0001) is represented by two Version IDs, 'Loschbour_snpAD.DG' and 'Loschbour_published.DG'. It would be incorrect to consider these as two samples from the same population. If it is not important which version is used, we suggest choosing the master ID which has the highest number of SNPs hit on autosomal targets. 

# figure out IDs situation
# these are unique!
ids_uniq <- data$`Version ID`
stopifnot( length( ids_uniq ) == length( unique( ids_uniq ) ) )
# these are not unique!
ids <- data$`Master ID`
# let's see which ones they are first
x <- table( ids )
x <- x[ x > 1 ]
# inspection shows these include lots of HGDP and TGP, and also other samples, and some are repeated more than 2 times!
ids_reps <- names( x )
# save other things
ms <- data$`SNPs hit on autosomal targets`
# keep track of removals
ids_rm <- c()

# loop through IDs, picking which ones to toss
for ( id in ids_reps ) {
    # find in big table
    indexes <- ids == id
    # get sequenced loci, pick highest value
    indexes2 <- which.max( ms[ indexes ] )
    # easiest to keep track of things to remove
    # need unique IDs here ( all ids were the same by 
    ids_rm <- c( ids_rm, ids_uniq[ indexes ][ -indexes2 ] )
}

# to make sure it worked, compare these mean counts
mean_ms0 <- mean( ms ) #[1] 695645.7

# filter data now
indexes <- !( ids_uniq %in% ids_rm )
data <- data[ indexes, ]
fam <- fam[ indexes, ]

# repeat counts
ms <- data$`SNPs hit on autosomal targets`
mean_ms1 <- mean( ms ) #[1] 705161.6 # yey it is bigger
stopifnot( mean_ms1 > mean_ms0 )

# if this worked then master IDs should be unique now
ids <- data$`Master ID`
stopifnot( length( ids ) == length( unique( ids ) ) )

message( nrow( data ), "\tRm repeats" )

# NOTE: some duplicates are labeled as "dup", but filtering by that string doesn't always keep the highest-coverage version
# so better to do it as we did above, and ignore the "dup" substring in whomever remain


###############
### WRAP-UP ###
###############

# the end!  Write file with ids to keep, to filter data with plink
write_lines( fam$id, 'inds-keep.txt' )

# write filtered copy for further analysis
write_tsv( data, 'v50.0_HO_public_ind-filt.anno' )

## # a grand analysis of "anno" labels, to see which subpopulations are so small we should definitely merge (and automatically sorted so things that differ by suffix are nearby!
## y <- data$`Group Label`
## library(tibble)
## labels <- as_tibble( table( y ) )
## # write for inspection
## write_tsv( labels, 'subpop-sizes.txt' )


## # for closer inspection, filter to AFR only
## afr_countries <- read_lines( '~/docs/ochoalab/duffy-neg/data/allen/african-countries.txt' )
## data <- data[ data$Country %in% afr_countries, ]
## write_tsv( data, 'v50.0_HO_public_ind-filt_AFR.anno' )
## # remove useless stuff for visualizing
## data$Index <- NULL
## data$`Master ID` <- NULL
## data$ASSESSMENT <- NULL # trivial at this stage
## data$`ASSESSMENT REASONING (Xcontam interval is listed if lower bound is >0.005, ""QUESTIONABLE"" if lower bound is 0.01-0.02, ""QUESTIONABLE_CRITICAL"" or ""FAIL"" if lower bound is >0.02) (mtcontam confidence interval is listed if coverage >2 and upper bound is <0.98: 0.9-0.95 is ""QUESTIONABLE""; <0.9 is ""QUESTIONABLE_CRITICAL"", questionable status gets overriden by ANGSD with PASS if upper bound of contamination is <0.01 and QUESTIONABLE if upper bound is 0.01-0.05) (damage for ds.half is ""QUESTIONABLE_CRITICAL/FAIL"" if <0.01, ""QUESTIONABLE"" for 0.01-0.03, and recorded but passed if 0.03-0.05; libraries with fully-treated last base are ""QUESTIONABLE_CRITICAL"" or ""FAIL"" if <0.03, ""QUESTIONABLE"" if 0.03-0.06, and recorded but passed if 0.06-0.1) (sexratio is QUESTIONABLE if [0.03,0.10] or [0.30,0.35); QUESTIONABLE_CRITICAL/FAIL if (0.10,0.30))` <- NULL
## data$`Full Date: One of two formats. (Format 1) 95.4% CI calibrated radiocarbon age (Conventional Radiocarbon Age BP, Lab number) e.g. 2624-2350 calBCE (3990¬±40 BP, Ua-35016). (Format 2) Archaeological context range, e.g. 2500-1700 BCE` <- NULL
## # shorten some absurd names
## names( data )[ names(data) == "Date mean in BP [OxCal mu for a direct radiocarbon date, and average of range for a contextual date]" ] <- 'date'

## View( data )

## # repeat for AFR only
## y <- data$`Group Label`
## labels <- as_tibble( table( y ) )
## write_tsv( labels, 'subpop-sizes-AFR.txt' )




# obsolete analysis

## ###################
## ### SUB-SUBPOPS ###
## ###################

## # these agree almost always... the disagreements are minor and absolutely ignorable
## # fam version appears to have a typo (LatEMedieval -> LateMedieval) that constitutes the majority of the differences, let's fix that ahead of the rest of the analysis
## # further inspection suggests "anno" is more accurate, though overall the differences (in which one to keep) are negligible
## fam$fam<- sub( 'LatEMedieval', 'LateMedieval', fam$fam )
## x <- fam$fam
## y <- data$`Group Label`
## mean( x == y ) # [1] 0.9993413
## indexes <- x != y
## library(tibble)
## z <- tibble( x = x, y = y )
## z <- z[ indexes, ]
## nrow(z) # [1] 8
## # their almost the same in count (i.e. resolution)
## length( unique( x ) ) # 2491
## length( unique( y ) ) # 2492
## # oddly disagreement in counts is not within differences, but must be separating pops in anno's version
## length( unique( z$x ) ) # 5
## length( unique( z$y ) ) # 5
## # which pop is separated in anno compared to fam?
## d <- table( x, y )
## a <- colSums( d > 0 )
## b <- rowSums( d > 0 )
## table( a )
## ##    1    2
## ## 2491    1 
## table( b )
## ##    1    2
## ## 2489    2 
## a[ a > 1 ]
## ## England_BellBeaker_highEEF
## ##                          2 
## b[ b > 1 ]
## ## England_BellBeaker_mediumEEF      Scotland_N_mediumlowEEF
## ##                            2                            2 
## e <- d[ , colnames(d) == 'England_BellBeaker_highEEF' ]
## e[ e> 0 ]
## ## England_BellBeaker_highEEF England_BellBeaker_mediumEEF
## ##                          1                            2 
## f <- d[ rownames(d) %in% c('England_BellBeaker_highEEF', 'England_BellBeaker_mediumEEF', 'Scotland_N_mediumlowEEF'), ]
## # this is a matrix
## f[ ,colSums(f)> 0 ]
## # recall x=fam, y=anno
## ##                               y
## ## x                              England_BellBeaker_highEEF England_BellBeaker_mediumEEF Scotland_N_lowEEF Scotland_N_mediumlowEEF
## ##   England_BellBeaker_highEEF                            1                            0                 0                       0
## ##   England_BellBeaker_mediumEEF                          2                            1                 0                       0
## ##   Scotland_N_mediumlowEEF                               0                            0                 1                       2

## # still trying to make decisions
## View( data[ grep('England_BellBeaker', y ), ] )
## # read original paper for Bell Beaker data and found no clues as to what high/medium/low EEF means.
## # all of these appear interchangeable


#######################################################

# my sub-subpopulation labels are "Group Label" here
# x = "Long."
# y = "Lat."


