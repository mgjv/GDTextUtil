BEGIN { $| = 1; print "1..12\n"; }
END {print "not ok 1\n" unless $loaded;}
use GD;
use GD::Text::Wrap;
$loaded = 1;
print "ok 1\n";

$text = <<EOSTR;
Lorem ipsum dolor sit amet, consectetuer adipiscing elit, 
sed diam nonummy nibh euismod tincidunt ut laoreet dolore 
magna aliquam erat volutpat.
EOSTR

$i = 2;

# Create a GD:Image object
$gd = GD::Image->new(170,150);
print 'not ' unless defined $gd;
printf "ok %d\n", $i++;

# Allocate colours
$gd->colorAllocate(255,255,255);
$gd->colorAllocate(  0,  0,  0);
print 'not ' unless $gd->colorsTotal == 2;
printf "ok %d\n", $i++;

# Create a GD::Text::Wrap object
$wp = GD::Text::Wrap->new($gd, text => $text);
print 'not ' unless defined $wp;
printf "ok %d\n", $i++;

$wp->set(align => 'left', top => 10, left => 20, right => 150);

# Get the bounding box
@bb = $wp->get_bounds();
print 'not ' unless "@bb" eq '20 10 150 128';
printf "ok %d\n", $i++;

# Draw, and chekck that the result is the same
@bb2 = $wp->draw();
print 'not ' unless "@bb" eq "@bb2";
printf "ok %d\n", $i++;

$wp->set(align => 'left');
@bb2 = $wp->draw();
print 'not ' unless "@bb" eq "@bb2";
printf "ok %d\n", $i++;

$wp->set(align => 'justified');
@bb2 = $wp->draw();
print 'not ' unless "@bb" eq "@bb2";
printf "ok %d\n", $i++;

$wp->set(align => 'right');
@bb2 = $wp->draw();
print 'not ' unless "@bb" eq "@bb2";
printf "ok %d\n", $i++;

# TTF
if ($wp->can_do_ttf)
{
	$rc = $wp->set_font('cetus.ttf', 10);
	print 'not ' unless $rc;
	printf "ok %d\n", $i++;

	# Get the bounding box
	@bb = $wp->get_bounds();
	print 'not ' unless "@bb" eq '20 10 150 134';
	printf "ok %d\n", $i++;

	@bb2 = $wp->draw();
	print 'not ' unless "@bb" eq "@bb2";
	printf "ok %d\n", $i++;
}
else
{
	printf "ok %d # Skip\n", $i++ for (1 .. 3);
}

__END__
#Only here to test the test.
open(GD, '>/tmp/wrap.png') or die $!;
print GD $gd->png();
close GD;
