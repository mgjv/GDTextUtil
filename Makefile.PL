use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

use strict;
use Config;

my %extras;

eval { local $SIG{'__WARN__'}; require Test::More };
if ($@)
{
    print "Test::More is not installed: All tests will be skipped\n";
    # XXX Why can't I reset this to not do any tests?
    $extras{test} = {TESTS => undef};
}

WriteMakefile(
    'DISTNAME'		=> 'GDTextUtil',
    'NAME'		=> 'GD::Text',
    'VERSION_FROM' 	=> 'Text.pm',
    'PREREQ_PM'		=> { 'GD' => 0 },
	($] >= 5.005 ? (
	     'ABSTRACT'     => 'text utilities for GD',
	     'AUTHOR'       => 'Martien Verbruggen (mgjv@comdyn.com.au)',
	    ):()
	),
    clean			=> {FILES => "GDWrap.png"},
    %extras,
);

sub MY::postamble
{
qq(
.PHONY: demo
demo: pure_all GDWrap.png
GDWrap.png: demo/GDWrap.pl
	\@$Config{'perlpath'} -Iblib/lib demo/GDWrap.pl demo/GDWrap.png
)
}

# $Id: Makefile.PL,v 1.11 2003/02/05 02:28:44 mgjv Exp $
