use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

require 5.004;
use strict;

WriteMakefile(
    'NAME'			=> 'GDTextUtil',
    'VERSION_FROM' 	=> 'lib/GD/Text.pm', # finds $VERSION
	'PREREQ_PM'		=> { 'GD' => 0 },
	($] >= 5.005 and (
		 'ABSTRACT'     => 'text utilities for GD',
		 'AUTHOR'       => 'Martien Verbruggen (mgjv@comdyn.com.au)')
	),
);

# $Id: Makefile.PL,v 1.1 1999/12/05 13:20:22 mgjv Exp $
