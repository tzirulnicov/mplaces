# (с) Леонов П. А., 2007

package CMSBuilder::MY4;
use strict qw(subs vars);
use utf8;

use CMSBuilder;

sub process_request
{
	my $c = shift;
	my $r = shift;
	
	my $myurl;
	
	# for my $to (@CMSBuilder::Config::slashobj_myurl)
	# 	{	
	# 		if (cmsb_url($to)->{address} eq $ENV{SERVER_NAME})
	# 		{
	# 			$myurl = $to;
	# 		}
	# 	}
	warn 'my4';
	my @roots = map { cmsb_url $_ }  @CMSBuilder::Config::slashobj_my4; #grep { $_ eq $myurl }

	map { $_->site_my4($r) and return 1 } @roots;
	
	return;
}


1;
