#!/usr/bin/perl -w
use strict;
use GD;
use GD::Text::Wrap;

my $gd = GD::Image->new(400,240);
my $white = $gd->colorAllocate(255,255,255);
my $black = $gd->colorAllocate(  0,  0,  0);
my $blue  = $gd->colorAllocate(127,127,255);
my $red   = $gd->colorAllocate(127,  0,  0);

#print "No colours: $black ", $gd->colorsTotal, "\n";

my $text = <<EOSTR;
Lorem ipsum dolor sit amet, consectetuer adipiscing elit, 
sed diam nonummy nibh euismod tincidunt ut laoreet dolore 
magna aliquam erat volutpat.
EOSTR

my $wp = GD::Text::Wrap->new($gd,
    width       => 180,
    line_space  => 5,
    color       => $black,
    text        => $text,
);

$wp->set(align => 'left');
$gd->rectangle($wp->get_bounds(10,10), $blue);
$wp->draw(10,10);

$wp->set_font('cetus.ttf', 10);
$wp->set(align => 'justified', line_space => 2);
$gd->rectangle($wp->get_bounds(210,10), $blue);
$wp->draw(210,10);

$wp->set(align => 'right');
$gd->rectangle($wp->get_bounds(10,120), $blue);
$wp->draw(10,120);

$wp->set(colour => $white, align => 'center');
$wp->set_font(gdMediumBoldFont, 12);
$gd->filledRectangle($wp->get_bounds(210,120), $red);
$wp->draw(210,120);

open(GD, '>GDWrap.png') or die "Cannot open GDWrap.png for write: $!";
binmode GD ;
print GD $gd->png();
close GD;
