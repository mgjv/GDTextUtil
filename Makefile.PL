use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

use strict;
use Config;

WriteMakefile(
    'DISTNAME'		=> 'GDTextUtil',
	'NAME'			=> 'GD::Text',
    'VERSION_FROM' 	=> 'Text.pm',
	'PREREQ_PM'		=> { 'GD' => 0 },
	($] >= 5.005 ? (
		 'ABSTRACT'     => 'text utilities for GD',
		 'AUTHOR'       => 'Martien Verbruggen (mgjv@comdyn.com.au)',
		):()
	),

	clean			=> {FILES => "GDWrap.png"},
);

sub MY::postamble
{
qq(
.PHONY: demo
demo: pure_all GDWrap.png
GDWrap.png: demo/GDWrap.pl
	\@$Config{'perlpath'} -Iblib/lib demo/GDWrap.pl
)
}

# $Id: Makefile.PL,v 1.9 2000/04/30 04:49:39 mgjv Exp $
