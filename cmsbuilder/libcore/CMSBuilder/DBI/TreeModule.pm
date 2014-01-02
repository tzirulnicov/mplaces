# (с) Леонов П.А., 2005

package CMSBuilder::DBI::TreeModule;
use strict qw(subs vars);
use utf8;

our @ISA =
(
	'CMSBuilder::DBI::Module',
	'CMSBuilder::DBI::Array',
	'CMSBuilder::DBI::SimpleModule',
);

sub _cname {'Модуль с древовидной структурой'}

#———————————————————————————————————————————————————————————————————————————————


sub admin_view_left
{
	my $o = shift;
	
	if($o->have_funcs())
	{
		$o->CMSBuilder::DBI::SimpleModule::admin_view_left(@_);
	}
	
	return $o->SUPER::admin_view_left(@_);
}


1;