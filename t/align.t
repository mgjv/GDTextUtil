# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

BEGIN { $| = 1; print "1..17\n"; }
END {print "not ok 1\n" unless $loaded;}
use GD;
use GD::Text::Align;
use constant PI => 4 * atan2(1,1);
$loaded = 1;
print "ok 1\n";

$i = 2;

# Create an image
$gd = GD::Image->new(200,200);
print 'not ' unless defined $gd;
printf "ok %d\n", $i++;

$gd->colorAllocate(255,255,255);
$gd->colorAllocate(0,0,0);
print 'not ' unless $gd->colorsTotal == 2;
printf "ok %d\n", $i++;

# Test the default setup
$t = GD::Text::Align->new($gd);
print 'not ' unless defined $t;
printf "ok %d\n", $i++;

$t->set_text('A string');
($w, $h, $cu, $cd) = $t->get(qw(width height char_up char_down));
print 'not ' unless ($w==48 && $h==13 && $cu==13 && $cd==0);
printf "ok %d\n", $i++;

# Some alignments
$t->set_align('top', 'left');
$t->draw(100,10);
($x, $y) = $t->get(qw(x y));
print 'not ' unless ($x==100 && $y==10);
printf "ok %d\n", $i++;

$t->set_align('center', 'right');
$t->draw(100,10);
($x, $y) = $t->get(qw(x y));
print 'not ' unless ($x==52 && $y==3.5);
printf "ok %d\n", $i++;

$t->set_align('bottom','center');
$t->draw(100,20);
($x, $y) = $t->get(qw(x y));
print 'not ' unless ($x==76 && $y==7);
printf "ok %d\n", $i++;

# Test loading of other builtin font
$t->set_font(gdGiantFont);
$t->set_align('bottom', 'right');
$t->draw(100,40);
($x, $y) = $t->get(qw(x y));
print 'not ' unless ($x==28 && $y==25);
printf "ok %d\n", $i++;

# Test some angles, this method is not meant to be used by anyone but
# me :)
$t->draw(100,40,PI/4);
print 'not ' if ($t->_builtin_up);
printf "ok %d\n", $i++;

$t->draw(100,40,PI/4 + 0.000001);
print 'not ' unless ($t->_builtin_up);
printf "ok %d\n", $i++;

# And, finally, some bounding boxes

$t->set_align('bottom', 'left');
@bb = $t->bounding_box(100,100);
print 'not ' unless ("@bb" eq "100 100 172 100 172 85 100 85");
printf "ok %d\n", $i++;

@bb = $t->bounding_box(100,100,PI/2);
print 'not ' unless ("@bb" eq "100 100 100 28 85 28 85 100");
printf "ok %d\n", $i++;

# TTF fonts
if ($t->can_do_ttf)
{
	$rc = $t->set_font('cetus.ttf', 12);
	print 'not ' unless $rc;
	printf "ok %d\n", $i++;

	$t->set_align('bottom', 'left');
	@bb = $t->bounding_box(100,100);
	print 'not ' unless ("@bb" eq "100 99 155 99 155 84 100 84");
	printf "ok %d\n", $i++;

	$t->set_align('top', 'center');
	@bb = $t->bounding_box(100,100, 4*PI/3);
	print 'not ' unless ("@bb" eq "100 67 73 113 86 121 112 74");
	printf "ok %d\n", $i++;

	$rc = $t->draw(140,100,4*PI/3);
	print 'not ' unless $rc;
	printf "ok %d\n", $i++;
}
else
{
	printf "ok %d # Skip\n", $i++ for (1 .. 4);
}

__END__
# only during testing of the test scripts
$gd->colorAllocate(127,127,127);
$gd->line(100,0,100,200,2);
$gd->line(0,100,200,100,2);

open(GD, ">/tmp/align.png");
print GD $gd->png;
close(GD);
