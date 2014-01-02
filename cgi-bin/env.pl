#!/usr/local/bin/perl
use strict qw(subs vars);
use Config;

print
'Status: 200 OK
Content-type: text/html

';

print
"Perl version: $Config{'version'}<br/>
OS name: $^O
";

print '<p><hr></p>';

map { print "$_ = $ENV{$_}<br/>" } sort keys %ENV;

1;
