# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

BEGIN { $| = 1; print "1..5\n"; }
END {print "not ok 1\n" unless $loaded;}
use GD;
use GD::Text::Align;
use constant PI => 4 * atan2(1,1);
$loaded = 1;
print "ok 1\n";

# Create an image
$gd = GD::Image->new(200,200);
print 'not ' unless defined $gd;
print "ok 2\n";

$gd->colorAllocate(255,255,255);
$gd->colorAllocate(0,0,0);

# Test the default setup
$t = GD::Text::Align->new($gd);
print 'not ' unless defined $t;
print "ok 3\n";

$t->set_text('A string');
($w, $h, $cu, $cd) = $t->get(qw(width height char_up char_down));
print 'not ' unless ($w==48 && $h==13 && $cu==13 && $cd==0);
print "ok 4\n";

# Some alignments
$t->set_align('top', 'left');
$t->draw(100,10);
($x, $y) = $t->get(qw(x y));
print 'not ' unless ($x==100 && $y==10);
print "ok 5\n";

$t->set_align('center', 'right');
$t->draw(100,10);
($x, $y) = $t->get(qw(x y));
print 'not ' unless ($x==52 && $y==3.5);
print "ok 6\n";

$t->set_align('bottom','center');
$t->draw(100,20);
($x, $y) = $t->get(qw(x y));
print 'not ' unless ($x==76 && $y==7);
print "ok 7\n";

# Test loading of other builtin font
$t->set_font(gdGiantFont);
$t->set_align('bottom', 'right');
$t->draw(100,40);
($x, $y) = $t->get(qw(x y));
print 'not ' unless ($x==28 && $y==25);
print "ok 8\n";

# Test some angles, this method is not meant to be used by anyone but
# me :)
$t->draw(100,40,PI/4);
print 'not ' if ($t->_builtin_up);
print "ok 9\n";

$t->draw(100,40,PI/4 + 0.000001);
print 'not ' unless ($t->_builtin_up);
print "ok 10\n";

# And, finally, some bounding boxes

$t->set_align('bottom', 'left');
@bb = $t->bounding_box(100,100);
print 'not ' unless ("@bb" eq "100 100 172 100 172 85 100 85");
print "ok 11\n";

@bb = $t->bounding_box(100,100,PI/2);
print 'not ' unless ("@bb" eq "100 100 100 28 85 28 85 100");
print "ok 12\n";

# TTF fonts
if ($t->can_do_ttf)
{
	$rc = $t->set_font('cetus.ttf', 12);
	print 'not ' unless $rc;
	print "ok 13\n";

	$t->set_align('bottom', 'left');
	@bb = $t->bounding_box(100,100);
	print 'not ' unless ("@bb" eq "100 100 155 100 155 85 100 85");
	print "ok 14\n";

	$t->set_align('top', 'center');
	@bb = $t->bounding_box(100,100, 4*PI/3);
	print 'not ' unless ("@bb" eq "101 68 74 114 87 122 113 75");
	print "ok 15\n";
}
else
{
	print "ok $_ # Skip\n" for (13 .. 15);
}

#$t->set_valign('base');
#$t->set_halign('left');
#$t->draw(100,200);
#$t->set_halign('right');
#$t->draw(100,200);
#$t->set_halign('center');
#$t->draw(100,180);

#$t->set_align('bottom', 'left');
#@bb = $t->bounding_box(100,100,0*PI/2);
#print "@bb\n";
#$t->draw(100,100,0*PI/2);

# XXX remove again!
$gd->colorAllocate(127,127,127);
$gd->line(100,0,100,200,2);
$gd->line(0,100,200,100,2);

open(GD, ">/tmp/foo.png");
print GD $gd->png;
close(GD);
