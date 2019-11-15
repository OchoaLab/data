# this script automatically updates plink 1.9 and plink 2.0 alpha
# unfortunately both are needed since 2.0 alpha isn't fully functional

# https://www.cog-genomics.org/plink/2.0/

##############
### CONFIG ###
##############

# version date gets changed most often
plink2Date="20191112" # "20190527" # "20190306" # "20190724"
plink1Date="20190304"

# destination of unzipped contents (binaries)
binDir="$HOME/bin/"

# destination of ZIPs (archive dir)
srcDir="$HOME/bin/src/"

# other variables that might be configured

# download ZIP name, specific to Linux x86_64!
plink2File="plink2_linux_x86_64_$plink2Date.zip"
plink1File="plink_linux_x86_64_$plink1Date.zip"

# full download URL
plink2URL="http://s3.amazonaws.com/plink2-assets/$plink2File"
plink1URL="http://s3.amazonaws.com/plink1-assets/$plink1File"

#################
### FUNCTIONS ###
#################

# download plink2 binary, unzip, "install" in local ~/bin/ dir
function updatePlink2 {
    # download ZIP file
    wget $plink2URL
    # unzip it
    unzip $plink2File
    # NOTE: plink2 only comes with the binary "plink2", nothing else!
    # move plink2 to binary dir
    mv plink2 $binDir
    # move ZIP to archival location
    mv $plink2File $srcDir
}

# repeat for plink1.9 (unfortunately some functionality is only here, like merging!)
function updatePlink1 {
    # download ZIP file
    wget $plink1URL
    # unzip it
    # NOTE: plink1 comes with several files, the below command ensures they're all in a single directory called "plink1/"
    unzip -d plink1/ $plink1File
    # move plink1/ to binary dir
    mv plink1/ $binDir
    # move ZIP to archival location
    mv $plink1File $srcDir
}
