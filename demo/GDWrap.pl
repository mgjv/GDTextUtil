#!/usr/bin/perl -w
use strict;
use GD;
use GD::Text::Wrap;

my $gd = GD::Image->new(450,170);
            $gd->colorAllocate(255,255,255);
my $black = $gd->colorAllocate(  0,  0,  0);
my $blue  = $gd->colorAllocate(127,127,255);

#print "No colours: $black ", $gd->colorsTotal, "\n";

my $text = <<EOSTR;
Lorem ipsum dolor sit amet, consectetuer adipiscing elit, 
sed diam nonummy nibh euismod tincidunt ut laoreet dolore 
magna aliquam erat volutpat.
EOSTR

my $wp = GD::Text::Wrap->new($gd,
    font        => '/usr/share/fonts/ttfonts/Arialn.ttf',
    font_size   => 10,
    top         => 10,
    line_space  => 4,
    color       => $black,
    text        => $text,
);

#print "font: ", $wp->get('font'), "\n";

$wp->set(align => 'left', left => 10, right => 140);
$gd->rectangle($wp->get_bounds, $blue);
$wp->draw();
$wp->set(align => 'justified', left => 160, right => 290);
$gd->rectangle($wp->get_bounds, $blue);
$wp->draw();
$wp->set(align => 'right', left => 310, right => 440);
$gd->rectangle($wp->get_bounds, $blue);
$wp->draw();
$wp->set(align => 'center', left => 40, right => 410,
    font => '/usr/share/fonts/ttfonts/Arialnb.ttf', 
    font_size => 12, top => 110);
$gd->rectangle($wp->get_bounds, $blue);
$wp->draw();

open(GD, '>GDWrap.png') or die $!;
print GD $gd->png();
close GD;
