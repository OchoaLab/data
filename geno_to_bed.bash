## convert eigensoft GENO format into the more common BED format I can handle
#eigv='6.1.4'
eigv='7.2.1' # 2018-02-06: convertf has to be compiled: dnf install openblas-devel; make install
eigbin="$HOME/bin/EIG-$eigv/bin"
## a script to process things nicely!
function geno_to_bed {
    if [ -z "$1" ]
    then
        # if no inputs, show usage message...
	echo "Usage: geno_to_bed <file>"
	echo "Converts file.{geno,snp,ind} into file.{bed,bim,fam}"
    else
	file=$1
	# temporary "parameter" file!
	file_par='par_geno_to_bed_tmp.txt'
	# this is what we're writing!
	# this "par" file maps inputs/outputs, and says X chromosome should have been excluded, though output has Chr 23 and 24...
	cat > $file_par <<EOF
genotypename:    $file.geno
snpname:         $file.snp
indivname:       $file.ind
outputformat:    PACKEDPED
genotypeoutname: $file.bed
snpoutname:      $file.bim
indivoutname:    $file.fam
familynames:     NO
noxdata:         YES
EOF
	# now run desired command!
	time $eigbin/convertf -p $file_par
	# remove temp file when done!
	rm $file_par
    fi
}
