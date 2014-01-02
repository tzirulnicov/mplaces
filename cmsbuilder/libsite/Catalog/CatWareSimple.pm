# (с) Леонов П.А., 2005

package CatWareSimple;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnCatalog::Ware','CMSBuilder::DBI::Object');

sub _cname {'Товар'}
#sub _aview {qw/name price photo desc/}

#———————————————————————————————————————————————————————————————————————————————


1;