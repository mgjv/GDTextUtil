# $Id: align.t,v 1.14 2002/07/03 13:05:03 mgjv Exp $
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

use lib ".", "..";
require "t/lib.pl";

use Test::More tests => 21;

use GD;
BEGIN { use_ok "GD::Text::Align" };
use constant PI => 4 * atan2(1,1);

# Create an image
$gd = GD::Image->new(200,200);
ok (defined $gd, "GD returns an object");

$gd->colorAllocate(255,255,255);
$black = $gd->colorAllocate(0,0,0);
is ($gd->colorsTotal, 2, "Colors allocation");

# Test the default setup
$t = GD::Text::Align->new($gd);
ok (defined $gd, "GD::Text::Align returns object")
    or diag($@);

$t->set_text('A string');
($w, $h, $cu, $cd) = $t->get(qw(width height char_up char_down));
ok ($w==48 && $h==13 && $cu==13 && $cd==0, "string returns right dim");

# Some alignments
$t->set_align('top', 'left');
$t->draw(100,10);
($x, $y) = $t->get(qw(x y));
ok ($x==100 && $y==10, "top left");

$t->set_align('center', 'right');
$t->draw(100,10);
($x, $y) = $t->get(qw(x y));
ok ($x==52 && $y==3.5, "center right");

$t->set_align('bottom','center');
$t->draw(100,20);
($x, $y) = $t->get(qw(x y));
ok ($x==76 && $y==7, "bottom center");

# Test loading of other builtin font
$t->set_font(gdGiantFont);
$t->set_align('bottom', 'right');
$t->draw(100,40);
($x, $y) = $t->get(qw(x y));
ok ($x==28 && $y==25, "builtin font");

# Test some angles, this method is not meant to be used by anyone but
# me :)
$t->draw(100,40,PI/4);
ok (!$t->_builtin_up, "angles test");

$t->draw(100,40,PI/4 + 0.000001);
ok ($t->_builtin_up, "angles test 2");

# And some bounding boxes
$t->set_align('bottom', 'left');
@bb = $t->bounding_box(100,100);
is ("@bb", "100 100 172 100 172 85 100 85", "bounding boxes");

@bb = $t->bounding_box(100,100,PI/2);
is ("@bb", "100 100 100 28 85 28 85 100", "bounding boxes 2");

# Constructor test
$t = GD::Text::Align->new($gd,
    valign => 'top',
    halign => 'left',
    text => 'Banana Boat',
    colour => $black,
    font => gdGiantFont,
);
@bb = $t->draw(10,10);
is ("@bb", "10 25 109 25 109 10 10 10", "constructor test");

# Test a '0' string
$t = GD::Text::Align->new($gd,
    text   => '0',
    font   => gdLargeFont,
    valign => 'bottom',
    halign => 'center',
    colour => $black);
@bb = $t->draw(100, 200);
is ("@bb", "96 200 104 200 104 184 96 184", "false string");

# TTF fonts
SKIP:
{
    # skip
    skip 6, "No ttf" unless ($t->can_do_ttf);

    $t = GD::Text::Align->new($gd,
        valign => 'top',
        halign => 'left',
        text => 'Banana Boat',
        colour => 1,
        ptsize => 18,
    );

    ok ($t->set_font('cetus.ttf'), "ttf font cetus");

    @bb = $t->draw(10,40);
    ok (aeq(\@bb, [qw"12 64 154 64 154 46 12 46"], 1), "drawing")
	or diag("bb = @bb");

    ok ($t->set_font('cetus', 12), "ttf cetus 12pt");

    $t->set_align('bottom', 'left');
    @bb = $t->bounding_box(100,100);
    ok (aeq(\@bb, [qw"101 96 194 96 194 84 101 84"], 1), "bottom left align")
	or diag("bb = @bb");


    $t->set_align('top', 'center');
    @bb = $t->bounding_box(100,100, 4*PI/3);
    ok (aeq(\@bb, [qw"109 51 62 132 73 138 119 57"], 1), "top center align")
	or diag("bb = @bb");

    @bb = $t->draw(140,100,4*PI/3);
    ok (aeq(\@bb, [qw"149 51 102 132 113 138 159 57"], 1), "last drawing")
	or diag("bb = @bb");
}

__END__
# only during testing of the test scripts
$gd->colorAllocate(127,127,127);
$gd->line(100,0,100,200,2);
$gd->line(0,100,200,100,2);

open(GD, ">/tmp/align.png") or die $!;
binmode GD;
print GD $gd->png;
close(GD);
