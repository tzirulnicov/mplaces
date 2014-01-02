# (с) Леонов П. А., 2005

package CatTypesDir;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnCatalog::Object','CMSBuilder::DBI::Array');

sub _cname {'Типы товаров'}
sub _aview {qw(name)}
#sub _have_icon {1}

sub _add_classes {qw/!* CatType/}

sub _props
{
	
}

#———————————————————————————————————————————————————————————————————————————————

sub name { $_[0]->papa ? $_[0]->_cname . ': ' . $_[0]->papa->name : $_[0]->SUPER::name }



1;