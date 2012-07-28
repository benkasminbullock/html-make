=head1 NAME

HTML::Make - make HTML

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

=cut

sub new
{
    my ($class, $type, $text) = @_;
    my $obj = {};
    $obj->{type} = $type;
    if ($type eq 'text' && $text) {
        $obj->{text} = $text;
    }
    bless $obj;
    return $obj;
}

=head2 add_text

    $element->add_text ('buggles');

Add text to C<$element>.

=cut

sub add_text
{
    my ($obj, $text) = @_;
    my $x = __PACKAGE__->new ('text', $text);
    push @{$obj->{children}}, $x;
    return $x;
}

=head2 push

    $element->push ($child);

Add child element C<$child> to C<$element>. For example,

    my $table = HTML::Make->new ('table');
    my $row = $table->push ('tr');
    my $cell = $row->push ('td');

=cut

sub HTML::Make::push
{
    my ($obj, $el) = @_;
    my $x = __PACKAGE__->new ($el);
    push @{$obj->{children}}, $x;
    return $x;
}

=head2 text

    $element->text ();

Return the element as text.

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
        $text .= "<$obj->{type}>";
        for my $child (@{$obj->{children}}) {
            $text .= $child->text ();
        }
        $text .= "</$obj->{type}>\n";
    }
    return $text;
}

1;
