#!/usr/bin/env perl


use strict;
use warnings;
use vCard;
use Data::Dumper;

my @recordTypes = qw[Name: Home: Mobile: Email: Blank:];
use constant namePos			=> 0;
use constant homePhonePos	=> 1;
use constant cellPhonePos	=> 2;
use constant emailPos		=> 3;

my $recDelimiter = 'Name:';
my $separatorLine =  '=' x 40;

my $title = 'Elder - North Hillsboro';
my $vCardFile='';

my $debug=0;

my $newRecord=0;

my $hr={};

while (<>) {

	chomp;
	my $line = $_;
	
	if ( ! $line ) {
		if ( $newRecord and $hr->{full_name} ) {
			#print "Write here? - $newRecord\n";
			print "vCardFile: $vCardFile\n";
			my $vCard = vCard->new;
			$hr->{photo} = '';
			$vCard->load_hashref($hr);
			$vCard->version('3.0');
			$vCard->as_file($vCardFile);

			#as_file($vCardFile
			print "HR: ", Dumper($hr) if $debug;
		}
		$newRecord = 0;
		next;
	}
	
	my $lineType = detectLineType($line);

	if ( $lineType eq $recDelimiter ) { #  the lineType that starts a new record
		$newRecord = 1;
		print "$separatorLine\n";
		$hr = {};
		#} else { 
		#$newRecord = 0;
	}

	print "Line Type: $lineType\n" if $debug;

	print "$line\n";

	if ( $lineType eq $recordTypes[namePos] ) {
		my @names = split(/\s+/,$line);
		@names = @names[1..$#names];

		$hr->{full_name} 	  = join(' ', @names);
		$hr->{given_names}  = [$names[0]];
		$hr->{family_names} = [$names[$#names]];
		$hr->{title}        = $title;

		$vCardFile = join('-', @names). '.vcf';

	} elsif ( $lineType eq $recordTypes[homePhonePos] ) {
		my @phones = split(/\s+/,$line);
		@phones = @phones[1..$#phones];
		push @{$hr->{phones}} , { type => ['home'], number => join('',@phones) };
	} elsif ( $lineType eq $recordTypes[cellPhonePos] ) {
		my @phones = split(/\s+/,$line);
		@phones = @phones[1..$#phones];
		push @{$hr->{phones}} , { type => ['mobile', 'text'], number => join('',@phones) };
	} elsif ( $lineType eq $recordTypes[emailPos] ) {
		my @emails = split(/\s+/,$line);
		push @{$hr->{email_addresses}} , { type => ['home'], address => $emails[1] };
	}

}

sub detectLineType {
	my $line=shift;

	my $debug=0;

	print "line Internal: $line\n" if $debug;
	
	my ($word) = split(/\s+/, $line);
	#my ($lType) = grep {qw[ Name: Home: Mobile: Email: ]} ($word);
	my ($lType) = grep {@recordTypes} ($word);
	# this line will probably never set to 'Blank' due to skipping blank lines in the main loop
	$lType = 'Blank' unless $lType;

	print "lType Internal: $lType\n" if $debug;
	return $lType;
}

