#!/usr/bin/perl -w
use strict;
use lib 'lib';
use GD::Text;

$GD::Text::OS = 'MSWin';

my $f;
for (1 .. 1<<20)
{
GD::Text->font_path('c:\Foo\Bar;.;/foo');

$f = GD::Text::_find_TTF('foo');
}


print "Using $f\n";
