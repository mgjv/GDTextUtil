use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

use strict;

# XXX Test for GD and test for the version.

WriteMakefile(
    'NAME'			=> 'GDTextUtil',
    'VERSION' 		=> '0.60',
	'PREREQ_PM'		=> { 'GD' => 0 },
	($] >= 5.005 and (
		 'ABSTRACT'     => 'text utilities for GD',
		 'AUTHOR'       => 'Martien Verbruggen (mgjv@comdyn.com.au)')
	),
);

# $Id: Makefile.PL,v 1.7 1999/12/30 04:33:42 mgjv Exp $
