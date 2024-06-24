package HTML::Make;
use warnings;
use strict;
require Exporter;
our $VERSION = '0.17';
use Carp;
use HTML::Valid::Tagset ':all';
use JSON::Parse '0.62', 'read_json';

my $dir = __FILE__;
$dir =~ s/Make\.pm/Make/;
my $infofile = "$dir/info.json";
my $info = read_json ($infofile);

# This is a list of valid tags.

my %tags = %HTML::Valid::Tagset::isKnown;
my %noCloseTags = %HTML::Valid::Tagset::emptyElement;
my %isBlock = %HTML::Valid::Tagset::isBlock;

our $texttype = 'text';
our $blanktype = 'blank';

sub op
{
}

sub new
{
    my ($class, $type, %options) = @_;
    my $obj = {};
    bless $obj;
    if (! $type) {
	$type = $blanktype;
    }
    $obj->{type} = lc ($type);
    # User is not allowed to use 'text' type.
    if ($type eq $texttype) {
	my ($package, undef, undef) = caller ();
	if ($package ne __PACKAGE__) {
	    die "Illegal use of text type";
	}
	if (! defined $options{text}) {
	    croak "Text type object with empty text";
	}
	if (ref $options{text}) {
	    croak "text field must be a scalar";
	}
	$obj->{text} = $options{text};
	return $obj;
    }
    if ($options{nocheck}) {
	# We won't check when the user adds attributes later.
	$obj->{nocheck} = 1;
	delete $options{nocheck};
    }
    if (! $obj->{nocheck}) {
	if ($type ne $blanktype) {
	    if (! $tags{lc $type}) {
		carp "Unknown tag type '$type'";
	    }
	    elsif (! $isHTML5{lc $type}) {
		carp "<$type> is not HTML5";
	    }
	}
    }
    if (exists $options{text}) {
	if (! defined $options{text}) {
	    carp "Undefined value for text";
	    $options{text} = '';
	}
	$obj->add_text ($options{text});
	delete $options{text};
    }
    if ($options{attr}) {
	$obj->add_attr (%{$options{attr}});
	delete $options{attr};
    }
    # Convenience shortcuts
    if ($options{id}) {
	$obj->add_attr (id => $options{id});
	delete $options{id};
    }
    if ($options{class}) {
	$obj->add_attr (class => $options{class});
	delete $options{class};
    }
    if (exists $options{href}) {
	if (! defined $options{href}) {
	    carp "Undefined value for href";
	    $options{href} = '';
	}
	if ($type ne 'a' && $type ne 'link') {
	    carp "href is only allowed with an 'a' or 'link' element";
	}
	else {
	    $obj->add_attr (href => $options{href});
	}
	delete $options{href};
    }
    if ($options{src}) {
	if ($type ne 'img' && $type ne 'image') {
	    carp "src is only allowed with an 'img' element";
	}
	else {
	    $obj->add_attr (src => $options{src});
	}
	delete $options{src};
    }
    for my $k (keys %options) {
	carp "Unknown option '$k'";
	delete $options{$k};
    }
    return $obj;
}

sub check_attributes
{
    my ($obj, %attr) = @_;
    if ($obj->{nocheck}) {
	return;
    }
    if ($attr{id}) {
	# This is a bit of a bug since \s matches more things than the
	# 5 characters disallowed in HTML IDs.
	if ($attr{id} =~ /\s/) {
	    carp "ID attributes cannot contain spaces";
	}
    }
    for my $k (keys %attr) {
	my $type = lc $obj->{type};
	if (! tag_attr_ok (lc $type, $k)) {
	    carp "attribute $k is not allowed for <$type> in HTML5";
	}
    }
}

sub add_attr
{
    my ($obj, %attr) = @_;
    if (! $obj->{nocheck}) {
	check_attributes ($obj, %attr);
    }
    for my $k (sort keys %attr) {
	if ($obj->{attr}->{$k}) {
	    carp "Overwriting attribute '$k' for '$obj->{type}' tag";
	}
        $obj->{attr}->{$k} = $attr{$k};
    }
}

sub add_class
{
    my ($obj, $class) = @_;
    my $oldclass = $obj->{attr}{class};
    my $newclass;
    if ($oldclass) {
	$newclass = $oldclass . ' ' . $class;
    }
    else {
	$newclass = $class;
    }
    $obj->{attr}{class} = $newclass;
}

sub add_text
{
    my ($obj, $text) = @_;
    my $x = __PACKAGE__->new ($texttype, text => $text);
    CORE::push @{$obj->{children}}, $x;
    return $x;
}

sub add_comment
{
    my ($obj, $comment) = @_;
    my $x = __PACKAGE__->new ($texttype, text => "<!-- $comment -->");
    CORE::push @{$obj->{children}}, $x;
    return $x;
}

sub attr
{
    my ($obj) = @_;
    my $attr = $obj->{attr};
    if (! $attr) {
	return {};
    }
    # Copy the hash so that the caller does not accidentally alter
    # this object's internals
    my %attr = %$attr;
    return \%attr;
}

sub check_mismatched_tags
{
    my ($obj, $el) = @_;
    my $ptype = $obj->{type};
    my $is_table_el = ($el =~ /^(th|td)$/i);
    if ($ptype eq 'tr' && ! $is_table_el) {
	carp "Pushing non-table element <$el> to a table row";
	return;
    }
    if ($is_table_el && $ptype ne 'tr') {
	carp "Pushing <$el> to a non-tr element <$ptype>";
	return;
    }
    my $is_list_parent = ($ptype =~ /^(ol|ul)$/);
    if (lc ($el) eq 'li' && ! $is_list_parent) {
	carp "Pushing <li> to a non-list parent <$ptype>";
	return;
    }
}

sub children
{
    my ($obj) = @_;
    if (! $obj->{children}) {
	return [];
    }
    my @children = @{$obj->{children}};
    return \@children;
}

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

sub opening_tag
{
    my ($obj) = @_;
    my $text = '';
    my $type = $obj->{type};
    if ($type eq 'html') {
	$text .= "<!DOCTYPE html>\n";
    }
    $text .= "<$type";
    if ($obj->{attr}) {
	my @attr;
	my %attr = %{$obj->{attr}};
	for my $k (sort keys %attr) {
	    my $v = $attr{$k};
	    if (! defined $v) {
		carp "Value of attribute '$k' in element of type '$type' is undefined";
		$v = '';
	    }
	    $v =~ s/"/\\"/g;
	    if ($type eq 'script' && ($k eq 'async' || $k eq 'defer')) {
		CORE::push @attr, "$k";
	    }
	    else {
		CORE::push @attr, "$k=\"$v\"";
	    }
	}
	my $attr = join (' ', @attr);
	$text .= " $attr";
    }
    $text .= ">";
    if ($info->{newline}{$type}) {
	$text .= "\n";
    }
    return $text;
}

sub HTML::Make::push
{
    if (scalar (@_) % 2 != 0) {
	carp "Usage: ->push ('el', class => 'a', );";
	return;
    }
    my ($obj, $el, %options) = @_;
    my $x;
    if (ref $el eq __PACKAGE__) {
	$x = $el;
	if ($x->{parent}) {
	    carp "Pushed element of type $x->{type} already has a parent of type $x->{parent}{type}";
	    return;
	}
    }
    else {
	check_mismatched_tags ($obj, $el);
	$x = __PACKAGE__->new ($el, %options);
    }
    CORE::push @{$obj->{children}}, $x;
    $x->{parent} = $obj;
    return $x;
}

sub text
{
    my ($obj) = @_;
    my $type = $obj->{type};
    if (! $type) {
        croak "No type";
    }
    if ($type eq $texttype) {
        return $obj->{text};
    }
    my $text = '';
    if ($type ne $blanktype) {
	$text = $obj->opening_tag ();
	if ($isBlock{$type} || $type eq 'tr') {
	    $text .= "\n";
	}
    }
    # Recursively add text
    for my $child (@{$obj->{children}}) {
	$text .= $child->text ();
    }
    if ($type ne $blanktype && ! $noCloseTags{$type}) {
	$text .= "</$type>\n";
    }
    return $text;
}

sub type
{
    my ($obj) = @_;
    my $type = $obj->{type};
    if ($type eq $blanktype) {
	return undef;
    }
    return $type;
}

1;

