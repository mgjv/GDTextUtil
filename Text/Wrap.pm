# $Id: Wrap.pm,v 1.12 2000/02/28 23:29:38 mgjv Exp $

package GD::Text::Wrap;

$GD::Text::Wrap::VERSION =
	(q($Revision: 1.12 $) =~ /\s([\d.]+)/ ? $1 : "0.0");

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
      line_space  => 4,
      color       => $black,
      text        => $text,
  );
  $wrapbox->set_font(gdMediumBoldFont);
  $wrapbox->set_font('cetus.ttf', 12);
  $wrapbox->set(align => 'left', width => 120);
  $wrapbox->draw(10,140);

  $gd->rectangle($wrap_box->get_bounds(10,140), $color);

=head1 DESCRIPTION

GD::Text::Wrap provides an object that draws a formatted paragraph of
text in a box on a GD::Image canvas, using either a builtin GD font
or a TrueType font.

=head1 METHODS

This class doesn't inherit from GD::Text directly, but delegates most of
its work to it (in fact to a GD::Text::Align object. That means that
most of the GD::Text::Align methods are available for this class,
specifically C<set_font> and C<font_path>. Other methods and methods
with a different interface are described here:

=cut

use strict;

# XXX add version number to GD
use GD;
use GD::Text::Align;
use Carp;

my %attribs = (
	width		=> undef,
	height		=> undef,
    line_space  => 2,
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

	$self->{render} = GD::Text::Align->new($self->{gd}, text => 'Foo');
	croak "Cannot allocate GD::Text::Align object" unless $self->{render};

	# XXX 5.004_04 doesn't like foreach as a modifier
	#$self->set($_, $attribs{$_}) foreach (keys %attribs);
	foreach (keys %attribs) { $self->set($_, $attribs{$_}) };
	# XXX SET DEFAULTS

    $self->set(
		colour => $self->{gd}->colorsTotal - 1,
		width  => ($self->{gd}->getBounds())[0] - 1,
	);
}

=head2 $wrapbox->set( attribute => value, ... )

set the value for an attribute. Valid attributes are:

=over 4

=item width

The width of the box to draw the text in. If unspecified, they will
default to the width of the GD::Image object.

=item line_space

The number of pixels between lines. Defaults to 2.

=item color, colour

Synonyms. The colour to use when drawing the font. Will be initialised
to the last colour in the GD object's palette.

=item align, alignment

Synonyms. One of 'justified' (the default), 'left', 'right' or 'center'.

=item text

The text to draw. This is the only attribute that you absolutely have to
set.

=back

As with the methods, attributes unknown to this class get delegated to
the GD::Text::Align class. 

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
		SWITCH: for ($attrib)
		{
			exists $attribs{$attrib} and 
				$self->{$attrib} = $val, last SWITCH;
			
			# If we don't have this attribute, maybe the GD::Text::Align
			# object can use it (for colour mainly at the moment)
			$self->{render}->set($attrib => $val) and last SWITCH;

			carp "No attribute $attrib";
		}
	}
}

=head2 $wrapbox->get( attribute );

Get the current value of an attribute. All attributes mentioned under
the C<set()> method can be retrieved

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

Returns the bounding box of the box that will be drawn with the current
attribute settings as a list. The values returned are the coordinates of
the upper left and lower right corner.

	($left, $top, $right, $bottom) = $wrapbox->get_bounds();

Returns an empty list on error.

NOTE: The return list of this method may change in a future
implementation that allows angled boxes.

=cut

my $dry_run = 0;

sub get_bounds
{
    my $self = shift;
	$dry_run = 1;
    return $self->draw(@_);
}

=head2 $wrapbox->draw(x, y)

Draw the box, with (x,y) as the top right corner. 
Returns the same values as the C<getbounds()> method.

NOTE: The return list of this method may change in a future
implementation that allows angled boxes.

=cut

sub draw
{
    my $self 		= shift;
	$self->{left} 	= shift or return;
	$self->{top} 	= shift or return;
	$self->{angle} 	= shift || 0; #unused

	$self->{right} = $self->{left} + $self->{width};

	return unless $self->{text};

	my $y = $self->{top} + $self->{render}->get('char_up');
	my @line = ();
	foreach my $word (split(' ', $self->{text}))
	{
        my $len = $self->{render}->width(join(' ', @line, $word));
		if ($len > $self->{right} - $self->{left} && @line)
		{
			$self->_draw_line(0, $y, @line) unless $dry_run;
			@line = ();
			$y += $self->{render}->get('height') + $self->{line_space};
		}
		push @line, $word;
	}
	# take care of the last line
	$self->_draw_line(1, $y, @line) unless $dry_run;

	# Reset dry_run
	$dry_run = 0;

	$self->{bottom} = $y + $self->{render}->get('char_down');
    return (
        $self->{left}, $self->{top},
        $self->{right}, $self->{bottom}
    )
}

sub _draw_line
{
	my $self = shift;
	# we need the following for justification only
	my $last = shift;
	my $y = shift;

    for ($self->{align})
    {
		/^just/i	and !$last and do
		{
			$self->_draw_justified_line($y, @_);
			last;
		};
        /^right/i   and do 
		{
			$self->{render}->set_text(join(' ', @_));
			$self->{render}->set_halign('right');
			$self->{render}->draw($self->{right}, $y);
			last;
		};
        /^center/i  and do
		{
			$self->{render}->set_text(join(' ', @_));
			$self->{render}->set_halign('left');
			my $x = ($self->{right} + $self->{left} - 
				$self->{render}->get('width')) / 2;
			$self->{render}->draw($x, $y);
			last;
		};
        # default action, left justification
		$self->{render}->set_text(join(' ', @_));
		$self->{render}->set_halign('left');
		$self->{render}->draw($self->{left}, $y);
    }
}

sub _draw_justified_line
{
	my $self = shift;
	my $y = shift;
	my $x = $self->{left};

	$self->{render}->set_halign('left');

	my @lengths = ();
	my $length = 0;
	# first, calculate the lengths of the individual words
	foreach my $word (@_)
	{
		$self->{render}->set_text($word);
		my $len = $self->{render}->get('width');
		push @lengths, $len;
		$length += $len;
	}

	# Calculate the average space between words
	my $space = ($self->{right} - $self->{left} - $length)/($#_ || 1);

	# Draw all the words, except the last one
	for (my $i = 0; $i < $#_; $i++)
	{
		$self->{render}->set_text($_[$i]);
		$self->{render}->draw($x, $y);
		$x += $lengths[$i] + $space;
	}

	# Draw the last word
	# XXX This will make a single word that's too long stick out the
	# right side of the box. is that what we want?
	$self->{render}->set_halign('right');
	$self->{render}->set_text($_[-1]);
	$self->{render}->draw($self->{right}, $y);
}


#
# Delegate all the other methods to the GD::Text::Align method
use vars qw($AUTOLOAD);
sub AUTOLOAD
{
	my $self = shift;
	my ($method) = $AUTOLOAD =~ /.*::(.*)$/;
	$self->{render}->$method(@_);
}

=head1 NOTES

As with all Modules for Perl: Please stick to using the interface. If
you try to fiddle too much with knowledge of the internals of this
module, you may get burned. I may change them at any time.

You can only use TrueType fonts with version of GD > 1.20, and then
only if compiled with support for this. If you attempt to do it
anyway, you will get errors.

Even though this module lives in the GD::Text namespace, it is not a
GD::Text. It does however delegate a lot of its functionality to a
contained object that is one (GD::Text::Align).

=head1 BUGS

None that I know of, but that doesn't mean much. There may be some
problems with exotic fonts, or locales and character encodings that I am
not used to.

=head1 TODO

Angled boxes.

At the moment, the only bit of the box that is allowed to be unspecified
and in fact must be unspecified, is the bottom. If there is enough need
for it, I might implement more flexibility, in that that you need to
only specify three of the four sides of the box, and the fourth will
be calculated.

Automatic resizing of a TrueType font to fit inside a box when four
sides are specified, or maybe some other nifty things.

More flexibility in the interface. Especially draw needs some thought.

More and better error handling.

Better handling of GD version before and after 1.20. This may be by
delegation to GD::Text.

Warnings for lines that are too long and stick out of the box.
Warning for emptyish lines?

=head1 COPYRIGHT

copyright 1999
Martien Verbruggen (mgjv@comdyn.com.au)

=head1 SEE ALSO

L<GD>, L<GD::Text>, L<GD::Text::Align>

=cut

1;
