#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use FindBin '$Bin';
use lib "$Bin/copied/lib";
use Perl::Build;
perl_build (
make_pod => "$Bin/make-pod.pl",
);
exit;
