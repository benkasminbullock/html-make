package HTML::Make;
use warnings;
use strict;
our $VERSION = '0.06';
use Carp;
use HTML::Valid::Tagset ':all';

# This is a list of valid tags.

my %tags = %HTML::Valid::Tagset::isKnown;

# Up to version 0.04 the following list was used. This will probably
# be removed in later versions of this module.

# Extracted from

# https://developer.mozilla.org/en-US/docs/Web/HTML/Element?redirectlocale=en-US&redirectslug=HTML%2FElement

# by "get-tags.pl".

# qw/
# a 1
# abbr 1
# acronym 1
# address 1
# applet 1
# area 1
# article 1
# aside 1
# audio 1
# b 1
# base 1
# basefont 1
# bdi 1
# bdo 1
# bgsound 1
# big 1
# blink 1
# blockquote 1
# body 1
# br 1
# button 1
# canvas 1
# caption 1
# center 1
# cite 1
# code 1
# col 1
# colgroup 1
# content 1
# data 1
# datalist 1
# dd 1
# decorator 1
# del 1
# details 1
# dfn 1
# dir 1
# div 1
# dl 1
# dt 1
# element 1
# em 1
# embed 1
# fieldset 1
# figcaption 1
# figure 1
# font 1
# footer 1
# form 1
# frame 1
# frameset 1
# h1 1
# h2 1
# h3 1
# h4 1
# h5 1
# h6 1
# head 1
# header 1
# hgroup 1
# hr 1
# html 1
# i 1
# iframe 1
# img 1
# input 1
# ins 1
# isindex 1
# kbd 1
# keygen 1
# label 1
# legend 1
# li 1
# link 1
# listing 1
# main 1
# map 1
# mark 1
# marquee 1
# menu 1
# menuitem 1
# meta 1
# meter 1
# nav 1
# nobr 1
# noframes 1
# noscript 1
# object 1
# ol 1
# optgroup 1
# option 1
# output 1
# p 1
# param 1
# plaintext 1
# pre 1
# progress 1
# q 1
# rp 1
# rt 1
# ruby 1
# s 1
# samp 1
# script 1
# section 1
# select 1
# shadow 1
# small 1
# source 1
# spacer 1
# span 1
# strike 1
# strong 1
# style 1
# sub 1
# summary 1
# sup 1
# table 1
# tbody 1
# td 1
# template 1
# textarea 1
# tfoot 1
# th 1
# thead 1
# time 1
# title 1
# tr 1
# track 1
# tt 1
# u 1
# ul 1
# var 1
# video 1
# wbr 1
# xmp 1
# /;

my %noCloseTags = %HTML::Valid::Tagset::emptyElement;
# (
# 	"area" => 1,
# 	"br" => 1,
# 	"dd" => 1,
# 	"dt" => 1,
# 	"hr" => 1,
# 	"image" => 1,
# 	"input" => 1,
# 	"img" => 1,
# 	"link" => 1,
# 	"meta" => 1,
# );

our $texttype = 'text';
our $blanktype = 'blank';

# This is for checking %options for stray stuff.

my %validoptions = (qw/text 1 nocheck 1 attr 1/);

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
    }
    else {
	if (! $options{nocheck} && $type ne $blanktype && ! $tags{lc $type}) {
	    carp "Unknown tag type '$type'";
	}
	elsif (! $options{nocheck} && ! $isHTML5{lc $type}) {
	    carp "<$type> is not HTML5";
	}
	if ($options{text}) {
            $obj->add_text ($options{text});
        }
	if ($options{attr}) {
	    $obj->add_attr (%{$options{attr}});
	}
	for my $k (keys %options) {
	    if (! $validoptions{$k}) {
		carp "Unknown option '$k'";
	    }
	}
    }
    return $obj;
}

sub check_attributes
{
    my ($obj, %attr) = @_;
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

sub add_text
{
    my ($obj, $text) = @_;
    my $x = __PACKAGE__->new ($texttype, text => $text);
    CORE::push @{$obj->{children}}, $x;
    return $x;
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

sub HTML::Make::push
{
    my ($obj, $el, %options) = @_;
    check_mismatched_tags ($obj, $el);
    my $x = __PACKAGE__->new ($el, %options);
    CORE::push @{$obj->{children}}, $x;
    return $x;
}

sub opening_tag
{
    my ($obj) = @_;
    my $text = "<$obj->{type}";
    if ($obj->{attr}) {
	my @attr;
	my %attr = %{$obj->{attr}};
	for my $k (sort keys %attr) {
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
	if ($type ne $blanktype) {
	    $text = $obj->opening_tag ();
	}
        for my $child (@{$obj->{children}}) {
            $text .= $child->text ();
        }
	if ($type ne $blanktype && ! $noCloseTags{$type}) {
	    $text .= "</$type>\n";
	}
    }
    return $text;
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

1;

