BEGIN { $| = 1; print "1..18\n"; }
END {print "not ok 1\n" unless $loaded;}
use GD;
use GD::Text;
$loaded = 1;
print "ok 1\n";

$i = 2;

# Test the default setup
$t = GD::Text->new();
print 'not ' unless ($t->is_builtin);
printf "ok %d\n", $i++;

# Check some size parameters
$t->set_text('Some text');
($w, $h, $cu, $cd) = $t->get(qw(width height char_up char_down));
print 'not ' unless ($w==54 && $h==13 && $cu==13 && $cd==0);
printf "ok %d\n", $i++;

# Change the text
$t->set_text('Some other text');
$w = $t->get('width');
print 'not ' unless ($w==90 && $h==13 && $cu==13 && $cd==0);
printf "ok %d\n", $i++;

# Test loading of other builtin font
$t->set_font(gdGiantFont);
print 'not ' unless ($t->is_builtin);
printf "ok %d\n", $i++;

# Test the width method
$w = $t->width('Foobar Banana');
print 'not ' unless (defined $w and $w == 117);
printf "ok %d\n", $i++;

# And make sure it didn't change the text in the object
$text = $t->get('text');
print 'not ' unless (defined $text and $text eq 'Some other text');
printf "ok %d\n", $i++;

# Now check the Giant Font parameters
($w, $h, $cu, $cd) = $t->get(qw(width height char_up char_down));
print 'not ' unless ($w==135 && $h==15 && $cu==15 && $cd==0);
printf "ok %d\n", $i++;

# Check that constructor with argument works
$t = GD::Text->new(text => 'FooBar Banana', font => gdGiantFont);
($w) = $t->get(qw(width)) if defined $t;
#print "$t, $w\n";
print 'not ' unless (defined $t && defined $w && $w==117);
printf "ok %d\n", $i++;

# Check multiple fonts in one go, number 1
$rc = $t->set_font(['foo', gdGiantFont, 'bar', gdTinyFont]);
print 'not ' unless $rc;
printf "ok %d\n", $i++;

if ($t->can_do_ttf)
{
	# Test loading of TTF
	$rc = $t->set_font('cetus.ttf', 18);
	print 'not ' unless ($rc && $t->is_ttf);
	printf "ok %d\n", $i++;

	# Check some size parameters
	@p = $t->get(qw(width height char_up char_down space));
	print 'not ' unless ("@p" eq "173 30 24 6 7");
	printf "ok %d\n", $i++;

	# Check that constructor with argument works
	$t = GD::Text->new(text => 'FooBar', font =>'cetus');
	@p = $t->get(qw(width height char_up char_down space)) if defined $t;
	#print "$i: @p\n";
	print 'not ' unless (defined $t && "@p" eq "45 16 13 3 4");
	printf "ok %d\n", $i++;

	# Check multiple fonts in one go, number 2
	$rc = $t->set_font(['cetus', gdGiantFont, 'bar'], 24);
	@p = $t->get('font', 'ptsize');
	#print "$i : $rc - @p\n";
	print 'not ' unless $rc && "@p" eq "./cetus.ttf 24";
	printf "ok %d\n", $i++;
}
else
{
	for (1 .. 4) { printf "ok %d # Skip\n", $i++ };
}

# Font Path tests
#
# Only do this if we have TTF font support, and if we're on a unix-like
# OS, will adapt this once I have support for other OS's for the font
# path.
if ($t->can_do_ttf && $^O &&
		$^O !~ /^MS(DOS|Win)/i && $^O !~ /VMS/i && 
		$^O !~ /^MacOS/i && $^O !~ /os2/i && $^O !~ /^AmigaOS/i)
{
	# Font Path
	$t->font_path('demo/..:/tmp');
	$rc = GD::Text::_find_TTF('cetus', 18);
	#print "$i: $rc\n";
	print 'not ' unless $rc eq './cetus.ttf';
	printf "ok %d\n", $i++;

	$t->font_path('demo/..:.:/tmp');
	$rc = GD::Text::_find_TTF('cetus', 18);
	#print "$i: $rc\n";
	print 'not ' unless $rc eq 'demo/../cetus.ttf';
	printf "ok %d\n", $i++;

	$rc = GD::Text::_find_TTF('/usr/foo/font.ttf', 18);
	#print "$i: $rc\n";
	print 'not ' unless $rc eq '/usr/foo/font.ttf';
	printf "ok %d\n", $i++;

	$t->font_path(undef);
	$rc = GD::Text::_find_TTF('cetus.ttf', 18);
	#print "$i: $rc\n";
	print 'not ' unless $rc eq './cetus.ttf';
	printf "ok %d\n", $i++;
}
else
{
	# Grumble to 5.004_04, cannot use for as modifier
	for (1 .. 4) { printf "ok %d # Skip\n", $i++ };
}
