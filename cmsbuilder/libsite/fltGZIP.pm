# (с) Леонов П. А., 2005

package fltGZIP;
use strict qw(vars subs);
use utf8;

our @ISA = 'CMSBuilder::IO::Filter';

use CMSBuilder::IO;
use Compress::Zlib;

sub filt
{
	my $c = shift;
	my $str = shift;
	
	unless($ENV{'HTTP_ACCEPT_ENCODING'} =~ /gzip/){ return; }
	
	$$str = Compress::Zlib::memGzip($$str);
	$headers{'Content-Length'} = length($$str);
	$headers{'Content-Encoding'} = 'gzip';
}

1;
