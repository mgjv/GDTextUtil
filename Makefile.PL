use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

use strict;
use Config;

WriteMakefile(
    'NAME'			=> 'GDTextUtil',
    'VERSION_FROM' 	=> 'lib/GD/Text.pm',
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
demo: GDWrap.png
GDWrap.png: demo/GDWrap.pl
	\@$Config{'perl'} -Ilib demo/GDWrap.pl
)
}

# $Id: Makefile.PL,v 1.8 2000/01/09 09:40:55 mgjv Exp $
