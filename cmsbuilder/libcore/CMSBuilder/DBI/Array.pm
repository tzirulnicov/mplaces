# (с) Леонов П.А., 2005

package CMSBuilder::DBI::Array;
use strict qw(subs vars);
use utf8;

our @ISA =
(
	'CMSBuilder::DBI::Array::AAdmin',
	'CMSBuilder::DBI::Array::ACore',
	'CMSBuilder::DBI::Array::ABase',
	
	'CMSBuilder::DBI::Object'
);

sub _cname {'Массив'}
sub _props {'onpage' => { 'type' => 'int', 'name' => 'Элементов на странице' }}

#———————————————————————————————————————————————————————————————————————————————


1;