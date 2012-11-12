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

my $html2 = HTML::Make->new ('p', attr => {id => 'buggles'});
my $text2 = $html2->text ();

like ($text2, qr!<p id="buggles">!, "Use attribute");

my $html3 = HTML::Make->new ('p');
$html3->add_text ('person');
my $text3 = $html3->text ();
like ($text3, qr!<p>person</p>!, "Add text to element");

my $html4 = HTML::Make->new ('div', attr => {chunky => 'monkey'});
$html4->add_text ('boo');
my $p = $html4->push ('b');
$p->add_text ('bloody');
$html4->add_text ('hoo');
my $text4 = $html4->text ();
like ($text4, qr!<div chunky=\"monkey\">boo<b>bloody</b>\s*hoo</div>!,
    "Nested text and tags");

my $html5 = HTML::Make->new ('table');
my $row5 = $html5->push ('tr');
for my $heading (qw/red white black blue/) {
    $row5->push ('th', text => $heading);
}
my $text5 = $html5->text ();
like ($text5, qr!red.*white.*black.*blue.*!sm,
      "Insert elements using push with text");

my $html6 = HTML::Make->new ('ul');
my @list = qw/monkeys dandelions pineapples/;
$html6->multiply ('li', \@list);
my $text6 = $html6->text ();
#note ($text6);
like ($text6,
      qr!<li>monkeys</li>.*?<li>dandelions</li>.*?<li>pineapples</li>!sm,
      "Multiply elements");

TODO: {
    local $TODO = 'not yet';
};

done_testing ();

# Local variables:
# mode: perl
# End:
