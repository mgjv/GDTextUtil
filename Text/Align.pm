package GD::Text::Align;

$GD::Text::Align::VERSION = 1.00;

=head1 NAME

GD::Text::Align - Draw aligned strings

=head1 SYNOPSIS

  use GD;
  use GD::Text::Align;

  my $gd = GD::Image->new(800,600);
  # allocate colours, do other things.
  
=head1 DESCRIPTION

GD::Text::Align provides an object that draws a string aligned to left,
center, right and top, center, bottom of a coordinate. It draws strings
horizontally, vertically and upside down. There is no support for other
angles.

Note that for builtin fonts, there is only one vertical direction, and
no upside down for the moment. This can be done, but is a lot of work,
so I might not implement it.

=head1 NOTES

As with all Modules for Perl: Please stick to using the interface. If
you try to fiddle too much with knowledge of the internals of this
module, you may get burned. I may change them at any time.

=head1 METHODS

This class inherits everything from GD::Text. I will only discuss the
methods and attributes here that are not discussed there.

=cut

use strict;

# XXX add version number to GD
use GD;
use GD::Text;
use Carp;

@GD::Text::Align::ISA = qw( GD::Text );

=head2 GD::Text::Align->new( $gd_object )

Create a new object. The first argument to new has to be a valid
GD::Image object.

=cut

sub new
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $gd    = shift;
    ref($gd) and $gd->isa('GD::Image') 
        or croak "Not a GD::Image object";
	my $self = $class->SUPER::new();
	$self->{gd} = $gd;
	$self->_init();
    bless $self => $class;
    return $self
}

my %defaults = (
	halign	=> 'left',
	valign	=> 'base',
);

sub _init
{
	my $self = shift;
	while (my ($k, $v) = each(%defaults))
	{
		$self->{$k} = $v;
	}
	$self->{colour} = $self->{gd}->colorsTotal - 1,
}

sub set_orientation
{
	my $self = shift;
	local $_ = shift or return;

	if (/^hor/ || /^vert/) 
	{
		$self->{orient} = $_; 
		return $_;
	}
	else
	{
		carp "Illegal orientation: $_";
		return;
	}
}

sub set_valign
{
	my $self = shift;
	local $_ = shift or return;

	if (/^top/ || /^center/ || /^bottom/ || /^base/) 
	{
		$self->{valign} = $_; 
		return $_;
	}
	else
	{
		carp "Illegal vertical alignment: $_";
		return;
	}
}

sub set_halign
{
	my $self = shift;
	local $_ = shift or return;

	if (/^left/ || /^center/ || /^right/) 
	{
		$self->{halign} = $_; 
		return $_;
	}
	else
	{
		carp "Illegal horizontal alignment: $_";
		return;
	}
}

sub set_align
{
	my $self = shift;

	$self->set_halign(shift) or return;
	$self->set_valign(shift) or return;
}

=head2 $gd_str->draw()

=cut

#
# This routine calculates the x and y coordinate that should be passed
# to the GD::Image drawing routines
#
sub _align
{
	my $self = shift;
	my ($x, $y) = @_;

	#print "$x:$y:$self->{halign}:$self->{valign}\n";

	# X Coordinate
	for ($self->{halign})
	{
		/^left/   and $self->{x} = $x;
		/^center/ and $self->{x} = $x - $self->{width}/2;
		/^right/  and $self->{x} = $x - $self->{width};
	}

	$self->{y} = $y;

	if ($self->is_builtin)
	{
		for ($self->{valign})
		{
			/^top/    and $self->{y} = $y;
			/^center/ and $self->{y} = $y - $self->{height}/2;
			/^bottom/ and $self->{y} = $y - $self->{height};
			/^base/   and $self->{y} = $y - $self->{height};
		}
	}
	elsif ($self->is_ttf)
	{
		for ($self->{valign})
		{
			/^top/    and $self->{y} = $y + $self->{char_up};
			/^center/ and $self->{y} = 
					$y - $self->{char_down} + $self->{height}/2;
			/^bottom/ and $self->{y} = $y - $self->{char_down};
			/^base/   and $self->{y} = $y;
		}
	}
	else
	{
		confess "Impossible error in GD::Text::Align::_align";
	}
}

sub draw
{
	my $self = shift;
	my ($x, $y) = @_;

	defined($x) && defined($y) or return;
	defined($self->{text})   or carp("no text set!"),   return;
	defined($self->{colour}) or carp("no colour set!"), return;

	$self->_align($x, $y);

	if ($self->is_builtin)
	{
		$self->{gd}->string($self->{font}, $self->{x}, $self->{y},
			$self->{text}, $self->{colour});
	}
	elsif ($self->is_ttf)
	{
		$self->{gd}->stringTTF($self->{colour}, 
			$self->{font}, $self->{ptsize},
			0, $self->{x}, $self->{y}, $self->{text});
	}
	else
	{
		confess "Impossible error in GD::Text::Align::draw";
	}
}

sub bounding_box
{
	my $self = shift;
	my ($x, $y) = @_;

	defined($x) && defined($y) or return;
	defined($self->{text}) or carp("no text set!"), return;

	$self->_align($x, $y);
}

=head1 BUGS

None that I know of, but that doesn't mean much.

=head1 COPYRIGHT

copyright 1999
Martien Verbruggen (mgjv@comdyn.com.au)

=head1 SEE ALSO

L<GD>, L<GD::Text>, L<GD::Text::Wrap>

=cut

