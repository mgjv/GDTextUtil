package GD::Text;

$GD::Text::VERSION = 1.00;

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
  my $w = $gd_text->get_width();
  my $h = $gd_text->get_height();

=head1 DESCRIPTION

This module provides  a font-independent way of dealing with text, for
use with the GD::Text::* modules and GD::Graph.

=head1 NOTES

As with all Modules for Perl: Please stick to using the interface. If
you try to fiddle too much with knowledge of the internals of this
module, you may get burned. I may change them at any time.

=head1 METHODS

=cut

use strict;

use GD;
use Carp;

use constant GD_FONT_BUILTIN => 1;
use constant GD_FONT_TTF 	 => 2;

=head2 GD::Text::Wrap->new()

Create a new object. This method does not expect any arguments.

=cut

sub new
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
	my $self = { 
			type   => GD_FONT_BUILTIN,
			font   => gdSmallFont,
		};
    bless $self => $class;
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

	return $self->_set_builtin_font($font) 
		if (ref($font) && $font->isa('GD::Font'));
	
	return $self->_set_TTF_font($font, shift);
}

sub _set_builtin_font
{
	my $self = shift;
	my $font = shift;

	$self->{type}   = GD_FONT_BUILTIN;
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

	$self->{type}   = GD_FONT_TTF;
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
	$self->_recalc();
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

# Here we do the real work. See the documentation for the get method to
# find out which attributes need to be set and/or reset

sub _recalc
{
	my $self = shift;

	return unless ($self->{text} && $self->{font});

	if ($self->is_builtin)
	{
		$self->{height} =
		$self->{char_up} = $self->{font}->height();
		$self->{char_down} = 0;
		$self->{width} = $self->{font}->width() * length($self->{text});
		$self->{space} = $self->{font}->width();
	}
	elsif ($self->is_ttf)
	{
		my @bb1 = GD::Image->stringTTF(0, 
			$self->{font}, $self->{ptsize}, 0, 0, 0, 'Ag')
				or return;
		my @bb2 = GD::Image->stringTTF(0, 
			$self->{font}, $self->{ptsize}, 0, 0, 0, 'A g');
		$self->{char_up} = -$bb1[7];
		$self->{char_down} = $bb1[1];
		$self->{height} = $self->{char_up} + $self->{char_down};
		$self->{space} = ($bb2[2]-$bb2[0]) - ($bb1[2]-$bb1[0]);
		@bb1 = GD::Image->stringTTF(0, 
			$self->{font}, $self->{ptsize}, 0, 0, 0, $self->{text});
		$self->{width} = $bb1[2] - $bb1[0];
	}
	else
	{
		confess "Impossible error in GD::Text::_recalc.";
	}

	return 1;
}

sub is_builtin
{
	my $self = shift; 
	return $self->{type} == GD_FONT_BUILTIN;
}

sub is_ttf
{
	my $self = shift; 
	return $self->{type} == GD_FONT_TTF;
}

=head1 BUGS

None that I know of, but that doesn't mean much.

=head1 COPYRIGHT

copyright 1999
Martien Verbruggen (mgjv@comdyn.com.au)

=head1 SEE ALSO

GD(3), GD::Text::Wrap(3), GD::Text::Align(3)

=cut

$GD::Text::VERSION;
