# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..7\n"; }
END {print "not ok 1\n" unless $loaded;}
use GD;
use GD::Text;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# Test the default setup
$t = GD::Text->new();
$t->set_text('Some text');
($w, $h, $cu, $cd) = $t->get(qw(width height char_up char_down));
print 'not' unless ($w==54 && $h==13 && $cu==13 && $cd==0);
print "ok 2\n";
#print "$w $h $cu $cd\n";

print 'not' unless ($t->is_builtin);
print "ok 3\n";

# Change the text
$t->set_text('Some other text');
$w = $t->get('width');
print 'not' unless ($w==90 && $h==13 && $cu==13 && $cd==0);
print "ok 4\n";
#print "$w $h $cu $cd\n";

# Test loading of other builtin font
$t->set_font(gdGiantFont);
($w, $h, $cu, $cd) = $t->get(qw(width height char_up char_down));
print 'not' unless ($w==135 && $h==15 && $cu==15 && $cd==0);
print "ok 5\n";
#print "$w $h $cu $cd\n";

# Test loading of TTF
$rc = $t->set_font('cetus.ttf', 18);
print 'not' unless ($t->is_ttf);
print "ok 6\n";

($w, $h, $cu, $cd, $sp) = $t->get(qw(width height char_up char_down space));
print 'not' unless ($rc && $w==174 && $h==23 && $cu==18 && $cd==5 && $sp == 7);
print "ok 7\n";
#print "$@ $w $h $cu $cd $sp\n";

