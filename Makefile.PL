use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

# The main reason for this is that I haven't tested it on anything less,
# and that I am pretty sure there are one or two 5.005 specific
# constructs around. Besides that, people should upgrade.
require 5.005;
use strict;

# XXX Test for GD and test for the version.

WriteMakefile(
    'NAME'			=> 'GDTextUtil',
    'VERSION' 		=> '0.56',
	'PREREQ_PM'		=> { 'GD' => 0 },
	($] >= 5.005 and (
		 'ABSTRACT'     => 'text utilities for GD',
		 'AUTHOR'       => 'Martien Verbruggen (mgjv@comdyn.com.au)')
	),
);

# $Id: Makefile.PL,v 1.6 1999/12/12 01:17:39 mgjv Exp $
