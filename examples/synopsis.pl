#!/home/ben/software/install/bin/perl
use warnings;
use strict;
# Make a table.
use HTML::Make;
my $table = HTML::Make->new ('table');
my $tr = $table->push ('tr');
my $td = $tr->push ('td', text => 'This is your cell.');
# Add HTML as text.
$td->add_text ('<a href="http://www.example.org/">Example</a>');
# Get the output
print $table->text ();
