# (с) Леонов П.А., 2005

package User;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnUsers::UserMember','CMSBuilder::DBI::Object', 'plgnForms::Interface');

sub _cname {'Пользователь'}
sub _aview {qw/name email/}
sub _have_icon {1}

sub _props
{
	'name'		=> { 'type' => 'string', 'name' => 'Имя' },
	'email'		=> { 'type' => 'string', 'name' => 'E-Mail' },
}

#———————————————————————————————————————————————————————————————————————————————


sub table_cre
{
	my $class = shift;
	my $ret;
	
	$ret = $class->SUPER::table_cre(@_);
	
	$CMSBuilder::DBI::dbh->do('ALTER TABLE '.$class->table_name().' ADD INDEX ( `login` )');
	$CMSBuilder::DBI::dbh->do('ALTER TABLE '.$class->table_name().' ADD INDEX ( `pas` )');
	
	return $ret;
}



1;