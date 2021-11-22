library(genio)
library(readr)

# load two seemingly redundant sources of info
data1 <- read_table('1kGP.3202_samples.pedigree_info.txt') # smaller but newer table
data2 <- read_table('20130606_g1k_3202_samples_ped_population.txt') # bigger but older table

# yey, rows are already aligned by individual, nobody extra
all( data1$sampleID == data2$SampleID )

# sex disagrees in only one person (went from female to male?)
# unclear which one is most trustworthy at this point
indexes <- which( data1$sex != data2$Sex )
data1[ indexes, ]
##   sampleID fatherID motherID   sex
## 1 HG02300  HG02299  HG02298      2
data2[ indexes, ]
##   FamilyID SampleID FatherID MotherID   Sex Population Superpopulation
## 1 PEL52    HG02300  HG02299  HG02298      1 PEL        AMR            

# pat disagrees, data2 seems more complete
indexes <- which( data1$fatherID != data2$FatherID )
data1[ indexes, ]
## # A tibble: 6 × 4
##   sampleID fatherID motherID   sex
## 1 HG00867  0        0            2
## 2 HG02569  0        HG02568      1
## 3 HG03451  0        0            1
## 4 NA19445  0        0            2
## 5 NA19913  NA19904  0            2
## 6 NA20910  0        0            2
data2[ indexes, ]
## # A tibble: 6 × 7
##   FamilyID SampleID FatherID MotherID   Sex Population Superpopulation
## 1 CDX1     HG00867  HG00866  0            2 CDX        EAS            
## 2 GB20     HG02569  HG02567  HG02568      1 GWD        AFR            
## 3 SL50     HG03451  HG03466  0            1 MSL        AFR            
## 4 LWK004   NA19445  NA19453  0            2 LWK        AFR            
## 5 2426a    NA19913  0        0            2 ASW        AFR            
## 6 GIH003   NA20910  NA20909  0            2 GIH        SAS            

# mat also disagrees!
indexes <- which( data1$motherID != data2$MotherID )
data1[ indexes, ]
##   sampleID fatherID motherID   sex
## 1 HG00155  0        0            1
## 2 HG03944  0        0            2
## 3 NA18862  0        0            1
## 4 NA19434  0        0            2
## 5 NA20318  0        NA20317      1
## 6 NA20355  0        NA20334      2
## 7 NA20362  0        NA20359      1
data2[ indexes, ]
##   FamilyID SampleID FatherID MotherID   Sex Population Superpopulation
## 1 GBR001   HG00155  0        HG00144      1 GBR        EUR            
## 2 ST116    HG03944  0        HG04067      2 STU        SAS            
## 3 Y024     NA18862  0        NA19105      1 YRI        AFR            
## 4 LWK003   NA19434  0        NA19432      2 LWK        AFR            
## 5 2480a    NA20318  0        0            1 ASW        AFR            
## 6 2484a    NA20355  0        0            2 ASW        AFR            
## 7 2495a    NA20362  0        0            1 ASW        AFR            

# set missing parents to NA properly
data1$fatherID[ data1$fatherID == 0 ] <- NA
data2$FatherID[ data2$FatherID == 0 ] <- NA
data1$motherID[ data1$motherID == 0 ] <- NA
data2$MotherID[ data2$MotherID == 0 ] <- NA

# to better understand, remove parents who are not themselves subjects
ids <- data1$sampleID # data2$SampleID # already established these are the same
ids2 <- data1$fatherID
all( ids2[ !is.na( ids2 ) ] %in% ids ) # all data1 pat are good

ids2 <- data2$FatherID
all( ids2[ !is.na( ids2 ) ] %in% ids ) # some data2 pat are not subjects!
unique( ids2[ !(ids2 %in% ids) & !is.na( ids2 ) ] )
# [1] "HG00866" "HG02567" "HG03466" "NA19453" "NA20909"
# so those were almost all of the cases where parents disagreed in larger table!
# set those to NA
data2$FatherID[ !( data2$FatherID %in% ids ) ] <- NA

# repeat comparison, adapted to handle NAs correctly
indexes <- which( data1$fatherID != data2$FatherID | xor( is.na( data1$fatherID ), is.na( data2$FatherID ) ) )
data1[ indexes, ]
##   sampleID fatherID motherID   sex
## 1 NA19913  NA19904  NA           2
data2[ indexes, ]
##   FamilyID SampleID FatherID MotherID   Sex Population Superpopulation
## 1 2426a    NA19913  NA       NA           2 ASW        AFR            

# now repeat with mothers
ids2 <- data1$motherID
all( ids2[ !is.na( ids2 ) ] %in% ids ) # all data1 mat are good

ids2 <- data2$MotherID
all( ids2[ !is.na( ids2 ) ] %in% ids ) # some data2 mat are not subjects!
unique( ids2[ !(ids2 %in% ids) & !is.na( ids2 ) ] )
# [1] "HG00144" "HG04067" "NA19105" "NA19432"
# so those were almost all of the cases where parents disagreed in larger table!
# set those to NA
data2$MotherID[ !( data2$MotherID %in% ids ) ] <- NA

# repeat comparison, adapted to handle NAs correctly
indexes <- which( data1$motherID != data2$MotherID | xor( is.na( data1$motherID ), is.na( data2$MotherID ) ) )
data1[ indexes, ]
##   sampleID fatherID motherID   sex
## 1 NA20318  NA       NA20317      1
## 2 NA20355  NA       NA20334      2
## 3 NA20362  NA       NA20359      1
data2[ indexes, ]
##   FamilyID SampleID FatherID MotherID   Sex Population Superpopulation
## 1 2480a    NA20318  NA       NA           1 ASW        AFR            
## 2 2484a    NA20355  NA       NA           2 ASW        AFR            
## 3 2495a    NA20362  NA       NA           1 ASW        AFR            

# so after that correction, the bigger table has fewer parents than the smaller table
# the dates suggest the smaller table is more up to date, so should we merge them as so?

# NOTE: later I realized that actual samples are a subset of this big table, but that doesn't make the discrepancies go away
# in particular, every single one of the discrepant individuals and every single one of their parents are final samples
# only exception was HG02300, who had discrepant sex, is not part of final samples
