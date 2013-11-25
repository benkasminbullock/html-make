=encoding UTF-8

=head1 NAME

HTML::Make - make HTML

=head1 SYNOPSIS

    # Make a table.
    use HTML::Make;
    my $table = HTML::Make->new ('table');
    my $tr = $table->push ('tr');
    my $td = $tr->push ('td', text => 'This is your cell.');
    # Add HTML as text.
    $td->add_text ('<a href="http://www.example.org/">Example</a>');
    print $table->text ();

=head1 DESCRIPTION

This is an HTML generator. You first of all make a top node using
L</new>,

    my $top_node = HTML::Make->new ('ul');

then add children to the top node using L</push>:

    my $element = $top_node->push ('li');

You add text to the child element using L</add_text>:

    $element->add_text ('Ça plane pour moi');

You can add attributes to the child element using L</add_attr>:

    $element->add_attr (class => 'plastic bertrand');

When you want to get the HTML as text, you use L</text> on your top node:

    my $html = $top_node->text ();

=cut

package HTML::Make;
use warnings;
use strict;
our $VERSION = 0.02;
use Carp;

# Extracted from

# https://developer.mozilla.org/en-US/docs/Web/HTML/Element?redirectlocale=en-US&redirectslug=HTML%2FElement

# by "get-tags.pl".

my %tags = qw/
a 1
abbr 1
acronym 1
address 1
applet 1
area 1
article 1
aside 1
audio 1
b 1
base 1
basefont 1
bdi 1
bdo 1
bgsound 1
big 1
blink 1
blockquote 1
body 1
br 1
button 1
canvas 1
caption 1
center 1
cite 1
code 1
col 1
colgroup 1
content 1
data 1
datalist 1
dd 1
decorator 1
del 1
details 1
dfn 1
dir 1
div 1
dl 1
dt 1
element 1
em 1
embed 1
fieldset 1
figcaption 1
figure 1
font 1
footer 1
form 1
frame 1
frameset 1
h1 1
h2 1
h3 1
h4 1
h5 1
h6 1
head 1
header 1
hgroup 1
hr 1
html 1
i 1
iframe 1
img 1
input 1
ins 1
isindex 1
kbd 1
keygen 1
label 1
legend 1
li 1
link 1
listing 1
main 1
map 1
mark 1
marquee 1
menu 1
menuitem 1
meta 1
meter 1
nav 1
nobr 1
noframes 1
noscript 1
object 1
ol 1
optgroup 1
option 1
output 1
p 1
param 1
plaintext 1
pre 1
progress 1
q 1
rp 1
rt 1
ruby 1
s 1
samp 1
script 1
section 1
select 1
shadow 1
small 1
source 1
spacer 1
span 1
strike 1
strong 1
style 1
sub 1
summary 1
sup 1
table 1
tbody 1
td 1
template 1
textarea 1
tfoot 1
th 1
thead 1
time 1
title 1
tr 1
track 1
tt 1
u 1
ul 1
var 1
video 1
wbr 1
xmp 1
/;

our $texttype = 'text';

=head1 METHODS

=cut

=head2 new

    my $element = HTML::Make->new ('li');

Make a new HTML element of the specified type.

It is possible to add attributes or text to the item. To add
attributes, use the following syntax:

    my $element = HTML::Make->new ('li', attr => {class => 'biglist'});

To add text,

    my $element = HTML::Make->new ('li', text => "White punks on dope");

Both attributes and text may be added:

    my $element = HTML::Make->new ('li', attr => {id => 'ok'}, text => 'OK');

HTML::Make has a list of known HTML tags and will issue a warning if
the type given as the first argument to new is not on its list of
tags. To switch off this behaviour, use

    my $freaky = HTML::Make->new ('freaky', nocheck => 1);

=cut

sub new
{
    my ($class, $type, %options) = @_;
    my $obj = {};
    bless $obj;
    $obj->{type} = $type;
    # User is not allowed to use 'text' type.
    if ($type eq $texttype) {
	my ($package, undef, undef) = caller ();
	if ($package ne __PACKAGE__) {
	    die "Illegal use of text type";
	}
	if (! defined $options{text}) {
	    die "Text type object with empty text";
	}
	if (ref $options{text}) {
	    croak "text field must be a scalar";
	}
	$obj->{text} = $options{text};
    }
    else {
	if (! $options{nocheck} && ! $tags{lc $type}) {
	    carp "Unknown tag type '$type'";
	}
	if ($options{text}) {
            $obj->add_text ($options{text});
        }
	if ($options{attr}) {
	    $obj->add_attr (%{$options{attr}});
	}
    }
    return $obj;
}

=head2 add_attr

    $obj->add_attr (class => 'buggles');

Add attributes to the specified object, in other words

    my $obj = HTML::Make->new ('li');
    $obj->add_attr (class => 'beano');
    my $obj_text = $obj->text ();
    # <li class="beano"></li>

This issues a warning of the form B<"Overwriting attribute 'class' for
'li'"> if the object already contains an attribute of the specified
type.

=cut

sub add_attr
{
    my ($obj, %attr) = @_;
    for my $k (keys %attr) {
	if ($obj->{attr}->{$k}) {
	    carp "Overwriting attribute '$k' for '$obj->{type}' tag";
	}
        $obj->{attr}->{$k} = $attr{$k};
    }
}

=head2 add_text

    $element->add_text ('buggles');

Add text to C<$element>. For example,

    my $element = HTML::Make->new ('p');
    $element->add_text ('peanuts');
    print $element->text ();
    # <p>peanuts</p>

The text may contain HTML elements:

    my $element = HTML::Make->new ('p');
    $element->add_text ('peanuts <i>eggs</i>');
    print $element->text ();
    # <p>peanuts <i>eggs</i></p>

=cut

sub add_text
{
    my ($obj, $text) = @_;
    my $x = __PACKAGE__->new ($texttype, text => $text);
    CORE::push @{$obj->{children}}, $x;
    return $x;
}

=head2 push

    my $child = $element->push ('tag');

Add child element of type <tag> to C<$element> and return the result
as a new C<HTML::Make> object. For example,

    my $table = HTML::Make->new ('table');
    my $row = $table->push ('tr');
    my $cell = $row->push ('td');
    print $table->text ();
    # <table><tr><td></td></tr></table>

It's also possible to add all of the same arguments as L</new>, for
example

    $element->push ('a', attr => {href => 'http://www.example.org/'});

=cut

sub HTML::Make::push
{
    my ($obj, $el, %options) = @_;
    my $x = __PACKAGE__->new ($el, %options);
    CORE::push @{$obj->{children}}, $x;
    return $x;
}

=head2 opening_tag

    my $tag = $obj->opening_tag ();

Returns the text value of the HTML tag opening, complete with
attributes.

=cut

sub opening_tag
{
    my ($obj) = @_;
    my $text = "<$obj->{type}";
    if ($obj->{attr}) {
	my @attr;
	my %attr = %{$obj->{attr}};
	for my $k (keys %attr) {
	    my $v = $attr{$k};
	    $v =~ s/"/\\"/g;
	    CORE::push @attr, "$k=\"$v\"";
	}
	my $attr = join (' ', @attr);
	$text .= " $attr";
    }
    $text .= ">";
    return $text;
}

=head2 text

    $element->text ();

This function returns the element as text.

    my $p = HTML::Make->new ('p');
    print $p->text ();
    # <p></p>

=cut

sub text
{
    my ($obj) = @_;
    my $type = $obj->{type};
    if (! $type) {
        croak "No type";
    }
    my $text;
    if ($type eq $texttype) {
        $text = $obj->{text};
    }
    else {
        $text = $obj->opening_tag ();
        for my $child (@{$obj->{children}}) {
            $text .= $child->text ();
        }
        $text .= "</$type>\n";
    }
    return $text;
}

=head2 multiply

    my @elements = $obj->multiply ('li', \@contents);

Create multiple child elements of C<$obj> of type given by the first
argument, with text contents given by C<\@contents>.

    my $ol = HTML::Make->new ('ol');
    $ol->multiply ('li', ['one', 'two', 'three']);
    print $ol->text ();
    # <ol><li>one</li>\n<li>two</li>\n<li>three</li>\n</ol>

=cut

sub multiply
{
    my ($parent, $element, $contents) = @_;
    my @elements;
    if (! defined $element) {
        croak "No element given";
    }
    if (! defined $contents || ref $contents ne 'ARRAY') {
        croak 'contents not array or not defined';
    }
    for my $content (@$contents) {
        my $x = $parent->push ($element, text => $content);
        CORE::push @elements, $x;
    }
    if (@elements != @$contents) {
	die "Mismatch of number of elements";
    }
    return @elements;
}

1;

=head1 COPYRIGHT AND LICENCE

Copyright (c) 2013 Ben Bullock. This Perl module may be used,
redistributed, modified, and copied under the same terms as Perl
itself.

=cut
