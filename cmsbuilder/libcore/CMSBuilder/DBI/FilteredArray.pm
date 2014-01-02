# (с) Леонов П.А., 2005

package CMSBuilder::DBI::FilteredArray;
use strict qw(subs vars);
use utf8;

#———————————————————————————————————————————————————————————————————————————————

sub interval_filter_get_all
{
	my $o = shift;
	return $o->CMSBuilder::DBI::Array::ABase::get_interval(1,$o->CMSBuilder::DBI::Array::ABase::len());
}

sub elem_tell_enum
{
	my $o = shift;
	my $to = shift;
	
	my $i;
	map { $i++; return $i if $_->myurl() eq $to->myurl() } $o->get_all();
	
	return 0;
}

sub get_interval
{
	my $o = shift;
	my $beg = shift;
	my $end = shift;
	#my $where = shift;
	
	my @all = $o->interval_filter($o->interval_filter_get_all());
	@all = @all[($beg-1) .. ($end-1)];
	
	return (grep {$_} @all);
}

sub len
{
	my $o = shift;
	
	my @all = $o->interval_filter($o->interval_filter_get_all());
	
	return scalar @all;
}


sub interval_filter
{
	my $o = shift;
	
	return @_;
}

1;