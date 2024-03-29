use strict;
use warnings;
use ExtUtils::MakeMaker;

my $pm = 'lib/HTML/Make.pm';
my $pod = 'lib/HTML/Make.pod';
my $repo = 'https://github.com/benkasminbullock/HTML-Make';

WriteMakefile (
    NAME => 'HTML::Make',
    VERSION_FROM => $pm,
    ABSTRACT_FROM => $pod,
    AUTHOR => 'Ben Bullock <bkb@cpan.org>',
    LICENSE => 'perl',
    PREREQ_PM => {
	'JSON::Parse' => '0.62',
	'HTML::Valid::Tagset' => '0',
    },
    META_MERGE => {
        resources => {
            repository => $repo,
            bugtracker => "$repo/issues",
        },
	no_index => {
	    file => [
		"t/HMT.pm",
	    ],
	}
    },
    MIN_PERL_VERSION => '5.006001',
);
