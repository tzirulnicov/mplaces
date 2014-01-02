# (с) Леонов П. А., 2006

package CMSBuilder::SimpleRPC;
use strict qw(subs vars);
use utf8;

#use Encode;

use CMSBuilder;
use CMSBuilder::Utils;
use CMSBuilder::IO;

sub process_request
{
	my $c = shift;
	my $r = shift;
	
	return unless $r->info->{path} =~ m~^/srpc/(.+?)/(.+)$~;
	my($url, $func) = ($1, $2);
	
	my $to = cmsb_url($url);
	return unless $to;
	
	my $out = catch_out { eval { $to->rpc_exec($func,$r) } };
	my $err = $@ || catch_out { $to->err_print };
	
	$headers{'Content-type'} = ($func eq 'markers'?'application/xml':($func eq 'vcard2'?'application/vcf; name=vcard.vcf':($func eq 'view_captcha'?'image/gif':'text/html; charset=utf-8')));
#	$headers{'Content-Disposition'}='inline;filename=vcard.vcf' if $func eq 'vcard';
	if($err)
	{
		#$err =~ s~\s+~ ~g;
		#$err = MIME::Base64::encode_base64($err);
		#$headers{'XML-RPC-Error'} = '=?UTF-8?B?' . $err . '?=';
		$err =~ s~<.+?>~~g;
		$err =~ s~&\S+~~g;
		
		$headers{Status} = 500;
		
		print '<result><error>' . $err . '</error></result>';
	}
	else
	{
		print $out;
	}
	
	return 1;
}


1;
