use warnings;
use strict;
use Test::More;
BEGIN { use_ok('HTML::Make') };
use HTML::Make;

my $html1 = HTML::Make->new ('table');
my $row1 = $html1->push ('tr');
my $cell1 = $row1->push ('td');
my $text1 = $html1->text ();

like ($text1, qr!<table.*?>.*?<tr.*?>.*?<td.*?>.*?</td>.*?</tr>.*?</table>!sm,
      "Nested HTML elements");

done_testing ();

# Local variables:
# mode: perl
# End:
