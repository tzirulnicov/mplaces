package ArrAny;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::DBI::Array);
sub _add_classes {qw(*)}

sub _cname {'Массив-контейнер'}

#———————————————————————————————————————————————————————————————————————————————



1;