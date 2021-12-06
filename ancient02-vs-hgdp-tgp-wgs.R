# figure out if HGDP individuals are in the larger sequencing data (they are definitely in HO but that's useless)

library(genio)

name1 <- 'v50.0_1240k_public'
name2 <- '../hgdp_wgs/hgdp_wgs_autosomes'
name3 <- '../tgp-nygc/tgp-nygc-autosomes'

# first individuals
fam1 <- read_fam( name1 )
fam2 <- read_fam( name2 )
fam3 <- read_fam( name3 )

# no direct intersection of IDs
any( fam2$id %in% fam1$id ) #[1] FALSE
any( fam3$id %in% fam1$id ) #[1] FALSE

# glad I grepped, as practically all samples appear to be here but with odd suffixes
fam1[ grep( 'hgdp', fam1$id, ignore.case=TRUE ), ]
## # A tibble: 930 × 6
##    fam                             id            pat   mat     sex pheno
##  1 Mayan.SG                        HGDP00877.SG  0     0         1     0
##  2 China_Lahu.SDG                  HGDP01319.SDG 0     0         1     0
##  3 Ignore_Mandenka(relative).SDG   HGDP01201.SDG 0     0         2     0
##  4 Ignore_Biaka.SDG                HGDP00479.SDG 0     0         1     0
##  5 BantuKenya.SDG                  HGDP01408.SDG 0     0         1     0
##  6 Ignore_MbutiPygmy(relative).SDG HGDP00471.SDG 0     0         2     0
##  7 Ignore_BantuKenya.SDG           HGDP01411.SDG 0     0         1     0
##  8 Yoruba.SDG                      HGDP00937.SDG 0     0         1     0
##  9 Miao.SDG                        HGDP01189.SDG 0     0         1     0
## 10 Biaka.SDG                       HGDP01094.SDG 0     0         1     0

# only one has .SG suffix (mistake?), rest have .SDG (TGP has the same suffixes)
# remove both to be sure and do exact matching
fam1$id <- sub( '\\.SG$', '', fam1$id )
fam1$id <- sub( '\\.SDG$', '', fam1$id )

# now all of them are here!
all( fam2$id %in% fam1$id ) # [1] TRUE
all( fam3$id %in% fam1$id ) # [1] TRUE

# just curious, there's one extra present in "ancient" and not HGDP-WGS
# weird, this was empty!  suggests repeated IDs?
#fam1[ grepl( 'hgdp', fam1$id, ignore.case=TRUE ) & !( fam1$id %in% fam2$id ), ]
# get full list
ids <- fam1$id[ grep( 'hgdp', fam1$id, ignore.case=TRUE ) ]
# this confirms there is one repeated ID: (the only one with SG instead of SDG prefix!)
table( ids )[ table( ids ) > 1 ]
## HGDP00877 
##         2 
fam1[ fam1$id == 'HGDP00877', ]
##   fam       id        pat   mat     sex pheno
## 1 Mayan.SG  HGDP00877 0     0         1     0
## 2 Mayan.SDG HGDP00877 0     0         1     0

# for TGP there are no repeats
ids <- fam1$id[ fam1$id %in% fam3$id ]
stopifnot( length( unique( ids ) ) == length( ids ) )
