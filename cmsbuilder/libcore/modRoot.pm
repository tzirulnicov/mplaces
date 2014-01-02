# (с) Леонов П.А., 2005

package modRoot;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::DBI::Array';

sub _cname {'Корень модулей'}
sub _have_icon {1}
sub _one_instance {1}
sub _add_classes {'CMSBuilder::DBI::Module'}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;

sub name { return $_[0]->_cname(@_); }

sub site_my4
{
	my $o = shift;
	my $r = shift;
	
	my $ri = $r->info;
	
	$ri->{path} =~ m/\/([\w-]+)(\/.*)?/;
	my $my4 = $1;
	my $path = $2;
	
	for my $to ($o->get_all)
	{
		$r->info->{main_obj} = $to;
		
		if ($to->{my4} eq $my4)
		{
			
			if (!$path or $path eq '/')
			{
				$to->site_page($r);
				return 1;
			}
			else
			{
				$ri->{path} = $path;
				return $to->site_my4($r);
			}
		}
	}
	
	
	return;
}

sub elem_paste
{
	my $o = shift;
	
	my $ret = $o->SUPER::elem_paste(@_);
	
	my $to = shift;
	$to->papa_set();
	$to->save();
	
	return $ret;
}

sub access
{
	my $o = shift;
	my $type = shift;
	
	if($type eq 'r' || $type eq 'x'){ return 1; }
	
	return $o->SUPER::access($type);
}


1;