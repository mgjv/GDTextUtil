# $Id: Text.pm,v 1.9 1999/12/15 02:17:47 mgjv Exp $

package GD::Text;

=head1 NAME

GD::Text - Text utilities for use with GD

=head1 SYNOPSIS

  use GD;
  use GD::Text;

  my $gd_text = GD::Text->new();
  $gd_text->set_font('funny.ttf', 12) or die "Error: $@";
  $gd_text->set_font(gdTinyFont);
  $gd_text->set_font(GD::Font::Tiny);
  ...
  $gd_text->set_text($string);
  my ($w, $h) = $gd_text->get('width', 'height');

  if ($gd_text->is_ttf)
  {
	  ...
  }

=head1 DESCRIPTION

This module provides  a font-independent way of dealing with text, for
use with the GD::Text::* modules and GD::Graph.

=head1 NOTES

As with all Modules for Perl: Please stick to using the interface. If
you try to fiddle too much with knowledge of the internals of this
module, you may get burned. I may change them at any time.

You can only use TrueType fonts with version of GD > 1.20, and then
only if compiled with support for this. If you attempt to do it
anyway, you will get errors.

=head1 METHODS

=cut

use strict;

use GD;
use Carp;

=head2 GD::Text->new()

Create a new object. This method has one optional argument: The
string.

=cut

sub new
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
	my $self = { 
			type   => 'builtin',
			font   => gdSmallFont,
		};
    bless $self => $class;
	$self->set_text(shift) if @_;
	$self->_recalc();
    return $self
}

=head2 $gd_text->set_font( font attribs )

Set the font to use for this string. The arguments are either a GD
builtin font (like gdSmallFont or GD::Font->Small) or the name of a
TrueType font file and the size of the font to use.

Returns true on success, and undef on an error. if an error is returned,
$@ will contain an error message.

=cut

sub set_font
{
	my $self = shift;
	my $font = shift;
	my $size = shift;

	return $self->_set_builtin_font($font) 
		if (ref($font) && $font->isa('GD::Font'));
	
	return $self->_set_TTF_font($font, $size);
}

sub _set_builtin_font
{
	my $self = shift;
	my $font = shift;

	$self->{type}   = 'builtin';
	$self->{font}   = $font;
	$self->{ptsize} = 0;
	$self->_recalc();
	return 1;
}

sub _set_TTF_font
{
	my $self = shift;
	my $font = shift;
	my $size = shift;

	return unless (defined $size && $size > 0);

	# Check that the font exists and is a real TTF font
	my @bb = GD::Image->stringTTF(0, $font, $size, 0, 0, 0, "foo");
	return unless @bb;

	$self->{type}   = 'ttf';
	$self->{font}   = $font;
	$self->{ptsize} = $size;
	$self->_recalc();
	return 1;
}

=head2 $gd_text->set_text('some text')

Set the text to operate on. Returns true on success and undef on error.

=cut

sub set_text
{
	my $self = shift;
	my $text = shift;
	return unless defined $text;

	$self->{text} = $text;
	$self->_recalc_width();
}

=head2 $gd_text->get( attrib, ... )

Get the value of an attribute.
Return a list of the attribute values in list context, and the value of
the first attribute in scalar context.

The attributes that can be retrieved are:

=over 4

=item font

The font in use.

=item ptsize

This is only useful if font is a TrueType font.

=item width, height

The width (height) of the string in pixels

=item space

The width of a space in pixels

=item char_up, char_down

The number of pixels that a character can stick out above and below the
baseline. Note that this is only useful for TrueType fonts. For builtins
char_up is equal to height, and char_down is always 0.

=back

Note that some of these parameters (char_up, char_down and space) are
generic font properties.

=cut

sub get
{
	my $self = shift;
	my @wanted = map { $self->{$_} } @_;
	wantarray ? @wanted : $wanted[0];
}

=head2 $gd_text->width('string')

Return the length of a string, without changing the current value of
the text.
Returns the width of 'string' rendered in the current font and size.
On failure, returns undef.

=cut

sub width
{
	my $self   = shift;
	my $string = shift;
	my $save   = $self->get('text');

	$self->set_text($string) or return;
	my ($w) = $self->get('width');
	$self->set_text($save);

	return $w;
}

# Here we do the real work. See the documentation for the get method to
# find out which attributes need to be set and/or reset

sub _recalc_width
{
	my $self = shift;

	return unless (defined $self->{text} && $self->{font});

	if ($self->is_builtin)
	{
		$self->{width} = $self->{font}->width() * length($self->{text});
	}
	elsif ($self->is_ttf)
	{
		my @bb1 = GD::Image->stringTTF(0, 
			$self->{font}, $self->{ptsize}, 0, 0, 0, $self->{text});
		$self->{width} = $bb1[2] - $bb1[0];
	}
	else
	{
		confess "Impossible error in GD::Text::_recalc.";
	}
}

my ($test_string, $space_string, $n_spaces);

BEGIN
{
	# Fill test string with all printable characters, i.e. the range
	# from 0x21..0x7E
	$test_string .= chr($_) for (0x21 .. 0x7e);
	$space_string = $test_string;
	$n_spaces = $space_string =~ s/(.{5})(.{5})/$1 $2/g;
}

sub _recalc
{
	my $self = shift;

	return unless $self->{font};

	if ($self->is_builtin)
	{
		$self->{height} =
		$self->{char_up} = $self->{font}->height();
		$self->{char_down} = 0;
		$self->{space} = $self->{font}->width();
	}
	elsif ($self->is_ttf)
	{
		my @bb1 = GD::Image->stringTTF(0, 
			$self->{font}, $self->{ptsize}, 0, 0, 0, $test_string)
				or return;
		my @bb2 = GD::Image->stringTTF(0, 
			$self->{font}, $self->{ptsize}, 0, 0, 0, $space_string);
		$self->{char_up} = -$bb1[7];
		$self->{char_down} = $bb1[1];
		$self->{height} = $self->{char_up} + $self->{char_down};
		# XXX Should we really round this?
		$self->{space} = sprintf "%.0f", 
			(($bb2[2]-$bb2[0]) - ($bb1[2]-$bb1[0]))/$n_spaces;
	}
	else
	{
		confess "Impossible error in GD::Text::_recalc.";
	}

	$self->_recalc_width() if $self->{text};

	return 1;
}

=head2 $gd_text->is_builtin

Returns true if the current object is based on a builtin GD font.

=cut

sub is_builtin
{
	my $self = shift; 
	return $self->{type} eq 'builtin';
}

=head2 $gd_text->is_ttf

Returns true if the current object is based on a TrueType font.

=cut

sub is_ttf
{
	my $self = shift; 
	return $self->{type} eq 'ttf';
}

=head2 $gd_text->can_do_ttf() or GD::Text->can_do_ttf()

Return true if this object can handle TTF fonts. See also the
C<can_do_ttf()> method in L<GD::Text>.

This depends on whether your version of GD is younger than 1.19 and
has TTF support compiled into it.

=cut

sub can_do_ttf
{
	my $proto = shift;

	my $gd = GD::Image->new(10,10);
	# XXX is this #test robust enough?
	# It isn't. It turns out that when TTF is not compiled in, this
	# method is still present. It just returns an error when you try to
	# use it. This needs testing.
	$gd->can('stringTTF');
}

=head1 BUGS

This module has only been tested with anglo-centric 'normal' fonts and
encodings.  Fonts that have odd characteristics may need some changes.

=head1 COPYRIGHT

copyright 1999
Martien Verbruggen (mgjv@comdyn.com.au)

=head1 SEE ALSO

GD(3), GD::Text::Wrap(3), GD::Text::Align(3)

=cut

1;
