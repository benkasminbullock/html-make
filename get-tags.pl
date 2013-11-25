#!/home/ben/software/install/bin/perl
use warnings;
use strict;
my $infile = 'mozilla.txt';
my %tags;
my @tags;
open my $in, "<", $infile or die $!;
my $stuff = '';
my $keep;
while (<$in>) {
    if (/<div class="index widgeted">/) {
	$keep = 1;
    }
    if ($keep) {
	$stuff .= $_;
    }
}
close $in or die $!;
while ($stuff =~ /<code>&lt;(.*?)(&gt;|><\/code>)/gsm) {
    my $tag = $1;
    if ($tag =~ m!/!) {
	next;
    }
    push @tags, $1;
}
for (@tags) {
    print "$_ 1\n";
}
