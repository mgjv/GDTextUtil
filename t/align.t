# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..5\n"; }
END {print "not ok 1\n" unless $loaded;}
use GD;
use GD::Text::Align;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$gd = GD::Image->new(200,200);
$gd->colorAllocate(255,255,255);
$gd->colorAllocate(0,0,0);
print 'not ' unless defined $gd;
print "ok 2\n";

# Test the default setup
$t = GD::Text::Align->new($gd);
print 'not ' unless defined $t;
print "ok 3\n";

$t->set_text('A string');
($w, $h, $cu, $cd) = $t->get(qw(width height char_up char_down));
print 'not ' unless ($w==48 && $h==13 && $cu==13 && $cd==0);
print "ok 4\n";
#print "$w $h $cu $cd\n";

$t->set_halign('left');
$t->draw(100,10);
$t->set_halign('right');
$t->draw(100,10);
$t->set_halign('center');
$t->draw(100,20);

#print "$t->{x}:$t->{y}:$t->{width}\n";

# Test loading of other builtin font
$t->set_font(gdGiantFont);
$t->set_halign('left');
$t->draw(100,40);
$t->set_halign('right');
$t->draw(100,40);
$t->set_halign('center');
$t->draw(100,50);

$t->set_font(gdSmallFont);
$t->set_halign('left');
$t->set_valign('top');
$t->draw(0,100);
$t->set_valign('center');
$t->draw(0,100);
$t->set_valign('bottom');
$t->draw(0,100);

$rc = $t->set_font('cetus.ttf', 12);
print 'not ' unless $rc;
print "ok 5\n";

$t->set_valign('bottom');
$t->set_halign('left');
$t->draw(100,200);
$t->set_halign('right');
$t->draw(100,200);
$t->set_halign('center');
$t->draw(100,180);

$t->set_valign('center');
$t->set_halign('right');
$t->draw(200,100);

$gd->colorAllocate(127,127,127);
$gd->line(100,0,100,200,2);
$gd->line(0,100,200,100,2);
open(GD, ">/tmp/foo.png");
print GD $gd->png;
close(GD);
