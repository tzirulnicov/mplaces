# (с) Леонов П. А., 2005

package CatType;
use strict qw(subs vars);
use utf8;

our @ISA = qw(plgnCatalog::Object CMSBuilder::DBI::Object);

use CMSBuilder;

sub _cname {'Тип товара'}
sub _aview {qw/name/}
#sub _have_icon {1}

sub _props
{
	
}

#———————————————————————————————————————————————————————————————————————————————




1;