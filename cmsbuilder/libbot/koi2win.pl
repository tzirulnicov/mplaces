#!/usr/bin/perl
use cyrillic qw /koi2win/;
print koi2win($ARGV[-1])."\n"
