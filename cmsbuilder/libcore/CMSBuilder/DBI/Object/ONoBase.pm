# (с) Леонов П.А., 2005

package CMSBuilder::DBI::Object::ONoBase;
use strict qw(subs vars);
use utf8;

#————————— Методы, отменяющие непосредственную работу с Базой Данных ———————————

sub count { return 1; }

sub del {}

sub sel_one {}
sub sel_where {}
sub sel_sql {}

# Устанавливать значения полей желательно в перегруженной версии этого метода
sub reload
{
	my $o = shift;
	$o->{'name'} = $o->cname();
	$o->{'ID'} = 1;
	$o->{'OWNER'} = '';
} 

sub save {}

sub insert { return 1; }

sub table_have { return 0; }

sub table_fix { return 0; }

sub table_cre {}

sub check {}

1;