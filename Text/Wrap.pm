package GD::Text::Wrap;

$GD::Text::Wrap::VERSION = 1.00;

=head1 NAME

GD::Text::Wrap - Wrap strings in boxes

=head1 SYNOPSIS

  use GD;
  use GD::Text::Wrap;

  my $gd = GD::Image->new(800,600);
  # allocate colours, do other things.
  
  my $text = <<EOSTR;
  Lorem ipsum dolor sit amet, consectetuer adipiscing elit, 
  sed diam nonummy nibh euismod tincidunt ut laoreet dolore 
  magna aliquam erat volutpat.
  EOSTR
  
  my $wrapbox = GDTextWrap->new( $gd,
      font        => '/usr/share/fonts/ttfonts/Arialn.ttf',
      font_size   => 10,
      top         => 10,
      line_space  => 4,
      color       => $black,
      text        => $text,
  );
  $wrapbox->set(align => 'left', left => 10, right => 140);
  $wrapbox->draw();

=head1 DESCRIPTION

GD::Text::Wrap provides an object that draws a formatted paragraph of
text in a box on a GD::Image canvas.

=head1 NOTES

As with all Modules for Perl: Please stick to using the interface. If
you try to fiddle too much with knowledge of the internals of this
module, you may get burned. I may change them at any time.

=head1 METHODS

=cut

use strict;

# XXX add version number to GD
use GD;
use GD::Text;
use Carp;

my %attribs = (
    left        => 0,
    right       => undef,
    top         => 0,
    line_space  => 2,
    font        => '/usr/share/fonts/ttfonts/arialbd.ttf',
    font_size   => 12,
	colour		=> undef,
    align       => 'justified',
	text		=> undef,
);

=head2 GD::Text::Wrap->new( $gd_object, attribute => value, ... )

Create a new object. The first argument to new has to be a valid
GD::Image object. The other arguments will be passed to the set() method
for initialisation of the attributes.

=cut

sub new
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $gd    = shift;
    ref($gd) and $gd->isa('GD::Image') 
        or croak "Not a GD::Image object";
    my $self  = { gd => $gd };
    bless $self => $class;
    $self->_init();
    $self->set(@_);
    return $self
}

sub _init
{
    my $self = shift;
    $self->set(
		colour => $self->{gd}->colorsTotal - 1,
		right  => ($self->{gd}->getBounds())[0] - 1,
	);
}

=head2 $wrapbox->set( attribute => value, ... )

set the value for an attribute. See L<"ATTRIBUTES>.

=cut

sub set
{
    my $self = shift;
    my %args = @_;

    while (my ($attrib, $val) =  each %args)
	{
		# This spelling problem keeps bugging me.
		$attrib = 'colour' if $attrib eq 'color';
		$attrib = 'align'  if $attrib =~ /^align/;
		exists $attribs{$attrib} or 
			do { carp "No attribute $_"; next };
		$self->{$attrib} = $val;
	}
}

=head2 $wrapbox->get( attribute );

Get the current value of an attribute.

=cut

sub get 
{ 
	my $self = shift;
	my $attrib = shift;

	$attrib = 'colour' if $attrib eq 'color';
	$attrib = 'align'  if $attrib =~ /^align/;
	$self->{$attrib} 
}

=head2 $wrapbox->get_bounds()

returns the bounding box of the box that will be drawn with the current
attribute settings as a list. The values returned are the coordinates of
the upper left and lower right corner.

	($left, $top, $right, $bottom) = $wrapbox->get_bounds();

returns an empty list on error.

=cut

sub get_bounds
{
    my $self = shift;
    $self->_set_text() or return;
    return (
        $self->{left}, $self->{top},
        $self->{right}, $self->{bottom}
    )
}

=head2 $wrapbox->draw()

Draw the box. Returns a true value on success, and undef on failure.

=cut

sub draw
{
    my $self = shift;
    $self->_set_text() or return;
    for ($self->{align})
    {
        /^just/i    and $self->_draw_justified(), last;
        /^right/i   and $self->_draw_right(),     last;
        /^center/i  and $self->_draw_center(),    last;
        # default action
        $self->_draw_left();
    }
	return 1;
}

sub _set_font_params
{
    my $self = shift;
    my @bb1 = GD::Image->stringTTF(0, 
        $self->{font}, $self->{font_size}, 0, 0, 0, 'Ag')
			or return;
    my @bb2 = GD::Image->stringTTF(0, 
        $self->{font}, $self->{font_size}, 0, 0, 0, 'A g');
    # Height of font above  and below the baseline
    $self->{fh} = -$bb1[7];
    $self->{fl} = $bb1[1];
    # Height of font in total
    $self->{font_height} = $self->{fh} + $self->{fl};
    # width of a space
    $self->{space} = ($bb2[2]-$bb2[0]) - ($bb1[2]-$bb1[0]);
}

sub _get_string_width
{
    my $self = shift;
    my $string = shift;
    my @bb = GD::Image->stringTTF(0, 
        $self->{font}, $self->{font_size}, 0, 0, 0, $string);
    return @bb ? ($bb[2] - $bb[0]) : undef;
}

sub _set_text
{
    my $self = shift;
    $self->_set_font_params() or return;
    my $line_len = 0;
    my $line_max = $self->{right} - $self->{left};
    my (@line, @lines);

    foreach my $word (split ' ', $self->{text})
    {
        my $len = $self->_get_string_width($word);
        my $space_used = $line_len + $len + 
			@line * $self->{space};
        if ($space_used > $line_max && @line)
        {
            push @lines, [$line_len, @line];
            $line_len = 0;
            @line = ();
        }
        $line_len += $len;
        push @line, [$len, $word];
    }
    push @lines, [$line_len, @line] if (@line);

    $self->{lines} = \@lines;
    $self->{bottom} = $self->{top} + 
		@lines * $self->{font_height} + 
        $#lines * $self->{line_space};
}

sub _draw_left
{
    my $self = shift;
    my $y = $self->{top} + $self->{fh};

    foreach my $line (@{$self->{lines}})
    {
        $self->_draw_left_line($line, $y);
        $y += $self->{font_height} + $self->{line_space};
    }
}

sub _draw_left_line
{
    my $self = shift;
    my ($line, $y) = @_;
    my $x = $self->{left};

    foreach my $token (@{$line}[1..$#$line])
    {
        my $len  = $token->[0];
        my $word = $token->[1];
        $self->{gd}->stringTTF($self->{colour}, 
			$self->{font}, $self->{font_size}, 
			0, $x, $y, $word);
        $x += $len + $self->{space};
    }
}

sub _draw_right
{
    my $self = shift;
    my $y = $self->{top} + $self->{fh};

    foreach my $line (@{$self->{lines}})
    {
        $self->_draw_right_line($line, $y);
        $y += $self->{font_height} + $self->{line_space};
    }
}

sub _draw_right_line
{
    my $self = shift;
    my ($line, $y) = @_;
    my $x = $self->{right};

	foreach my $token (reverse @{$line}[1..$#$line])
	{
		my $len  = $token->[0];
		my $word = $token->[1];
		$x -= $len;
		$self->{gd}->stringTTF($self->{colour}, 
			$self->{font}, $self->{font_size}, 
			0, $x, $y, $word);
		$x -= $self->{space};
	}
}

sub _draw_center
{
    my $self = shift;
    my $y = $self->{top} + $self->{fh};

    foreach my $line (@{$self->{lines}})
    {
        $self->_draw_center_line($line, $y);
        $y += $self->{font_height} + $self->{line_space};
    }
}

sub _draw_center_line
{
    my $self = shift;
    my ($line, $y) = @_;
    my $line_max = $self->{right} - $self->{left};
    my $space    = $line_max - $line->[0] - 
		($#$line - 1) * $self->{space};
    my $x = $self->{left} + $space/2;

    foreach my $token (@{$line}[1..$#$line])
    {
        my $len  = $token->[0];
        my $word = $token->[1];

        $self->{gd}->stringTTF($self->{colour}, 
            $self->{font}, $self->{font_size}, 
			0, $x, $y, $word);
        $x += $len + $self->{space};
    }
}

sub _draw_justified
{
    my $self = shift;
    my $y = $self->{top} + $self->{fh};

    foreach my $line 
		(@{$self->{lines}}[0..($#{$self->{lines}} - 1)])
    {
		$self->_draw_justified_line($line, $y);
        $y += $self->{font_height} + $self->{line_space};
    }
    $self->_draw_left_line($self->{lines}->[-1], $y);
}

sub _draw_justified_line
{
    my $self = shift;
    my ($line, $y) = @_;
    my $line_max = $self->{right} - $self->{left};
    my $space = ($line_max - $line->[0])/($#$line - 1 || 1);
    my $x = $self->{left};

    foreach my $token (@{$line}[1..($#$line - 1)])
    {
        my $len  = $token->[0];
        my $word = $token->[1];

        $self->{gd}->stringTTF($self->{colour}, 
            $self->{font}, $self->{font_size}, 
			0, $x, $y, $word);
        $x += $len + $space;
    }
    # The last word needs to be treated separately
    $x = $self->{right} - $line->[-1]->[0];
    $self->{gd}->stringTTF($self->{colour}, 
        $self->{font}, $self->{font_size}, 0, $x, $y,
        $line->[-1]->[1]);
}

$GD::Text::Wrap::VERSION;

=head1 ATTRIBUTES

=head2 left, right

The left and right boundary of the box to draw the text in. If
unspecified, they will default to the left and right edges of the gd
object.

=head2 top

The top and bottom of the box to draw the text in. The top defaults to
the top edge of the gd object if unspecified. Note that you cannot set
the bottom. This will be automatically calculated, and can be retrieved
with the get_bounds() method.

=head2 font

The font to use. This can be either a builtin GD font object (see L<GD>)
or the path to a TrueType font file. The default is
'/usr/share/fonts/ttfonts/Arialn.ttf'.

=head2 font_size

The size of the TrueType font. For builtins changing this has no effect.
The default is 12.

=head2 line_space

The number of pixels between lines. Defaults to 2.

=head2 color, colour

Synonyms. The colour to use when drawing the font. Will be initialised
to the last colour in the GD object's palette.

=head2 align, alignment

Synonyms. One of 'justified' (the default), 'left', 'right' or 'center'.

=head2 text

The text to draw. This is the only attribute that you absolutely have to
set.

=head1 BUGS

None that I know of, but that doesn't mean much.

=head1 COPYRIGHT

copyright 1999
Martien Verbruggen (mgjv@comdyn.com.au)

=head1 SEE ALSO

L<GD>, L<GD::Text>, L<GD::Text::Align>

=cut

