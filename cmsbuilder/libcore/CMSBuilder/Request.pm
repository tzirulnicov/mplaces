# (с) Леонов П. А., 2005

package CMSBuilder::Request;
use strict qw(subs vars);
use utf8;

sub new { bless {}, $_[0] }

sub info
{
	return CMSBuilder::request_info($_[0]);
}

1;