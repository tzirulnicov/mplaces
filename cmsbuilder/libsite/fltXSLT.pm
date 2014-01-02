# (с) Леонов П. А., 2005

package fltXSLT;
use strict qw(subs vars);
use utf8;

our @ISA = ('CMSBuilder::IO::Filter');

use XML::XSLT;

use CMSBuilder::Utils;
use CMSBuilder::IO;

#-------------------------------------------------------------------------------

push @XML::Parser::Expat::Encoding_Path, $CMSBuilder::Config::path_etc . '/xmlenc';

our $doparse = 0;
sub doparse { $doparse = $_[1] }

sub filt
{
	my $c = shift;
	my $strr = shift;
	
	unless($doparse){ return; }
	$doparse = 0;
	
	unless($$strr =~ m'<\?xml-stylesheet.+?href="(.+?)"\?>')
	{
		warn "$c: stylesheet is not defined.";
		return;
	}
	
	my $file = $1;
	if($file =~ m'^/.+'){ $file = $CMSBuilder::Config::path_htdocs . $file; }
	unless(-f $file){ warn "$c: no surch file '$file'"; return; }
	
	my $xsl = f2var_utf8($file);
	my $xslt = XML::XSLT->new($xsl, 'warnings' => 1);
	$xslt->transform($$strr);
	
	
	$$strr = $xslt->toString;
	$headers{'Content-Type'} = 'text/html; charset=utf-8';
}

1;