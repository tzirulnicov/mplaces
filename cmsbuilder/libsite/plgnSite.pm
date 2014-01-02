# (с) Леонов П.А., 2006

package plgnSite;
use strict qw(subs vars);
use utf8;

our @ISA = ('CMSBuilder::Plugin');

use CMSBuilder;

sub plgn_load
{
	my $c = shift;
	
	cmsb_siteload('Site');
	
	cmsb_event_reg('admin_view_additional',\&admin_additional);
	
	unshift(@plgnUsers::UserMember::ISA,'plgnSite::Interface');
	unshift(@UserGroup::ISA,'plgnSite::Interface');
	unshift(@modUsers::ISA,'plgnSite::Object');
}

sub admin_additional
{
	my $o = shift;
	
	print '<tr><td valign="top">Адрес&nbsp;на&nbsp;сайте:</td><td>',$o->can('site_href')?$o->site_href():'Нет.','</td></tr>';
}


1;