BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}
use GD;
use GD::Text;
$loaded = 1;
print "ok 1\n";

# Test the default setup
$t = GD::Text->new();
print 'not ' unless ($t->is_builtin);
print "ok 2\n";

# Check some size parameters
$t->set_text('Some text');
($w, $h, $cu, $cd) = $t->get(qw(width height char_up char_down));
print 'not ' unless ($w==54 && $h==13 && $cu==13 && $cd==0);
print "ok 3\n";

# Change the text
$t->set_text('Some other text');
$w = $t->get('width');
print 'not ' unless ($w==90 && $h==13 && $cu==13 && $cd==0);
print "ok 4\n";

# Test loading of other builtin font
$t->set_font(gdGiantFont);
print 'not ' unless ($t->is_builtin);
print "ok 5\n";

($w, $h, $cu, $cd) = $t->get(qw(width height char_up char_down));
print 'not ' unless ($w==135 && $h==15 && $cu==15 && $cd==0);
print "ok 6\n";

# Test loading of TTF
$rc = $t->set_font('cetus.ttf', 18);
print 'not ' unless ($t->is_ttf);
print "ok 7\n";

# Check some size parameters
($w, $h, $cu, $cd, $sp) = 
	$t->get(qw(width height char_up char_down space));
print 'not ' unless 
	($rc && $w==174 && $h==23 && $cu==18 && $cd==5 && $sp == 7);
print "ok 8\n";

