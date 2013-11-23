=head1 NAME

HTML::Make - make HTML

=head1 SYNOPSIS

=head1 DESCRIPTION

HTML generator.

=cut

package HTML::Make;
use warnings;
use strict;
our $VERSION = 0.01;
use Carp;

=head1 METHODS

=cut

=head2 new

    my $element = HTML::Make->new ('li');

Make a new HTML element of the specified type.

It is possible to add attributes or text to the item.

    my $element = HTML::Make->new ('li', attr => {class => 'biglist'});

Add text:

    my $element = HTML::Make->new ('li', text => "White punks on dope");

=cut

sub new
{
    my ($class, $type, %options) = @_;
    my $obj = {};
    bless $obj;
    $obj->{type} = $type;
    if ($options{text}) {
        if ($type eq 'text') {
            $obj->{text} = $options{text};
        }
        else {
            $obj->add_text ($options{text});
        }
    }
    
    if ($options{attr}) {
        $obj->add_attr (%{$options{attr}});
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

=cut

sub add_attr
{
    my ($obj, %attr) = @_;
    for my $k (keys %attr) {
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
    my $x = __PACKAGE__->new ('text', text => $text);
    push @{$obj->{children}}, $x;
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

It's also possible to add the same arguments as L</new>:

    $element->push ('a', attr => {href => 'http://www.example.org/'});

=cut

sub HTML::Make::push
{
    my ($obj, $el, %options) = @_;
    my $x = __PACKAGE__->new ($el, %options);
    push @{$obj->{children}}, $x;
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
    my $text = '';
        $text .= "<$obj->{type}";
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
    my $text = '';
    if ($type eq 'text') {
        $text = $obj->{text};
    }
    else {
        $text .= $obj->opening_tag ();
        for my $child (@{$obj->{children}}) {
            $text .= $child->text ();
        }
        $text .= "</$obj->{type}>\n";
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
    return @elements;
}

1;

=head1 COPYRIGHT AND LICENCE

Copyright (c) 2013 Ben Bullock. This Perl module may be used,
redistributed, modified, and copied under the same terms as Perl
itself.


