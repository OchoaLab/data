# dumb script creates BED-formatted ranges file from a plink1-BIM file

use strict;

# process inputs
my ($file_in_unmapped, $file_in_bed, $file_in_bim, $file_out_bim) = @ARGV;
die "Usage: perl -w $0 <in_unmapped> <in.bed> <in.bim> <out.bim>\n" unless $file_in_unmapped && $file_in_bed && $file_in_bim && $file_out_bim;

# read unmapped data first, small table
print "Reading: $file_in_unmapped\n";
# store locations in hash
my %unmapped = ();
open(my $handle_in_unmapped, '<', $file_in_unmapped) || die "Could not open for reading $file_in_unmapped: $!";
while ( <$handle_in_unmapped> ) {
    # process pairs of lines
    # first one should always be this
    die "Unexpected line didn't match '#Deleted in new': $_" unless $_ eq "#Deleted in new\n";
    # now read actual data line
    $_ = <$handle_in_unmapped>;
    chomp;
    my @data = split /\t/;
    # make sure there are only 3 fields per line
    die "Error: Line does not have exactly 3 fields!\n" unless @data == 3;
    # last column is ignored
    # first two are cleaned up and merged
    my $chr = $data[0];
    my $pos = $data[1] + 1; # transform 0-based (BED format req) to 1-based (BIM format)
    die "Error: chr didn't have 'chr' prefix: $chr\n" unless $chr =~ s/^chr//;
    # add to hash of unmapped locations
    $unmapped{ $chr . ':' . $pos } = 1;
}

# open rest of input files
print "Reading: $file_in_bim, $file_in_bed\n";
open(my $handle_in_bim, '<', $file_in_bim) || die "Could not open for reading $file_in_bim: $!";
open(my $handle_in_bed, '<', $file_in_bed) || die "Could not open for reading $file_in_bed: $!";
# now open outputs
print "Writing: $file_out_bim\n";
open(my $handle_out_bim, '>', $file_out_bim) || die "Could not open for writing $file_out_bim: $!";

# read BIM input and take action depending on whether line was unmapped or not
while ( <$handle_in_bim> ) {
    # process line
    chomp;
    my @data_bim = split /\t/;
    # make sure there are only 6 fields per line
    die "Error: Line (BIM) does not have exactly 6 fields!\n" unless @data_bim == 6;
    # get fields of interest
    my $chr = $data_bim[0];
    my $pos = $data_bim[3];
    # check if it was unmapped
    if ( $unmapped{ $chr . ':' . $pos } ) {
	# change chr/pos to zeroes, to remove easily with plink
	$data_bim[0] = 0;
	$data_bim[3] = 0;
    } else {
	# new position comes from input BED file
	$_ = <$handle_in_bed>;
	chomp;
	my @data_bed = split /\t/;
	die "Error: Line (BED) does not have exactly 3 fields!\n" unless @data_bed == 3;
	# last column is ignored
	# first two are cleaned up and merged
	my $chr_bed = $data_bed[0];
	my $pos_bed = $data_bed[1] + 1; # transform 0-based (BED format req) to 1-based (BIM format)
	die "Error: chr didn't have 'chr' prefix: $chr_bed\n" unless $chr_bed =~ s/^chr//;
	# chr can change, usually gets placed in a separate contig or even another autosome, so let's always overwrite in output
	# also overwrite position to that from BED
	$data_bim[0] = $chr_bed;
	$data_bim[3] = $pos_bed;
    }
    # write output, copying everything as in input except chr/pos is updated
    print $handle_out_bim join("\t", @data_bim)."\n";
}

# if we're here, input file ended, so we're done!
close $handle_in_bim;
close $handle_in_bed;
close $handle_out_bim;
