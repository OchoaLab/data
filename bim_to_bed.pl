# dumb script creates BED-formatted ranges file from a plink1-BIM file

use strict;

# process inputs
my ($file_in) = @ARGV;
die "Usage: perl -w $0 <file.bim>\nOutput gets suffix '_ranges.bed' (bim extension is removed)\n" unless $file_in;
# make sure extensions are as expected
die "Error: File must have `.bim` extension: $file_in\n" unless $file_in =~ /\.bim$/;

# construct output paths
my $file_out = $file_in; # copy
$file_out =~ s/\.bim$//; # remove extension
$file_out .= '_ranges.bed'; # concatenate suffix and desired output extension

# open input files
open(my $handle_in, '<', $file_in) || die "Could not open for reading $file_in: $!";
# now open outputs
open(my $handle_out, '>', $file_out) || die "Could not open for writing $file_out: $!";

while ( <$handle_in> ) {
    # process line
    chomp;
    my @data = split /\t/;
    # make sure there are only 6 fields per line
    die "Error: Line does not have exactly 6 fields!\n" unless @data == 6;
    # get fields of interest
    my $chr = 'chr' . $data[0]; # add chr prefix always
    my $pos = $data[3];
    # write output
    print $handle_out join("\t", $chr, $pos-1, $pos)."\n";
}

# if we're here, input file ended, so we're done!
close $handle_in;
close $handle_out;
