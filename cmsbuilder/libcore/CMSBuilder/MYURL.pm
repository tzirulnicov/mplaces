# (с) Леонов П. А., 2005

package CMSBuilder::MYURL;
use strict qw(subs vars);
use utf8;

use CMSBuilder;
use CMSBuilder::IO;

sub process_request
{
	my $c = shift;
	my $r = shift;
	
	my $ri = $r->info;
	
	#$ri->{path} =~ m/.*\/(.+?)\.html(\/.*)?/;
	$ri->{path} =~ m/.*\/(.+?)\.(\w+)(\/.*)?/;
	my $myurl = $1;
	my $path = $2;
	
	$myurl =~ s#/#::#g;
	#----
	# $myurl = $CMSBuilder::Config::slashobj_myurl if $ri->{path} eq '/';
	
	if ($ri->{path} eq '/')
	{ 
		for my $to (@CMSBuilder::Config::slashobj_myurl)
		{	
			if (cmsb_url($to)->{address} eq $ENV{'SERVER_NAME'})
			{
				$myurl = $to;
			}
		}
	}
	
	#----
	my $obj = cmsb_url($myurl);
	
	return unless $obj;
	
	$ri->{path} = $path;
	
	$ri->{'main_obj'} = $obj;
	$obj->site_page($r);
	
	return 1;
}


1;