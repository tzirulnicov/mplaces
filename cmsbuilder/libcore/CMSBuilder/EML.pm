# (с) Леонов П. А., 2005

package CMSBuilder::EML;
use strict qw(subs vars);
use utf8;

use CMSBuilder;
use CMSBuilder::Utils;
use CMSBuilder::IO;
use CMSBuilder::IO::Session;
import CGI 'param';

#———————————————————————————————————————————————————————————————————————————————

our(@head,@pull,$dir,$path,%sess,$part_num);
our $daparser;

sub process_request
{
	my $c = shift;
	my $r = shift;
	
	CMSBuilder::EML->init();
	return CMSBuilder::EML->doall();
}

sub init
{
	@head = @pull = ();
	%sess = ();
	$part_num = $daparser = $dir = $path = undef;
}

sub doall
{
	my $cn = shift;
	my $eml = $cn->new();

	$eml->init_normal();
	
	return unless $eml->parse();
	$eml->construct();
	$eml->execute();
	
	$daparser = $eml;
	
	return $eml;
}

sub new
{
	my $class = shift;
	
	my $o = {};
	bless($o,$class);
	
	return $o;
}

sub parser { return $pull[$#pull]; }

sub header
{
	my $str = shift;
	
	unless($str){ return join('',@head); }
	
	push(@head, $str);
}

sub parse
{
	my $o = shift;
	
	return unless(-f $o->{'file'});
	
	my $emlf;
	unless(open($emlf,'<:utf8',$o->{'file'})){ err500('Can`t open (<:utf8) file: '.$o->{'file'}); }
	$o->{'data'} = join('',<$emlf>);
	close($emlf);
	
	# Считываем и парсим конструкции <!--#include ... -->
	chdir($o->{'dir'});
	$o->{'data'} =~ s/<!--#include\s+(.+)\s*-->/SSI($o,$1);/gei;
	chdir($o->{'cgi_dir'});
	
	# Считываем и парсим конструкции <?eml *** ?>
	$o->{'parts'} = [ split(/<\?eml((?:.|\n)+?)\?>/,$o->{'data'}) ];
	
	return 1;
}

sub execute
{
	my $o = shift;
	
	push @pull, $o;
	eval($o->{'code'});
	pop @pull;
	
	if($@ && !$CMSBuilder::IO::err_catched)
	{
		my $etext = $@.'eval("'.$o->{'parts'}[$part_num].'") in '.$o->{'file'};
		print STDERR $etext;
		err500($etext);
	}
	
	undef $CMSBuilder::IO::err_catched;
}

sub construct
{
	my $o = shift;
	my $i;
	$o->{'parts'}[$#{ $o->{'parts'} }+1] = '';
	for($i=0;$i<=$#{ $o->{'parts'} };$i+=2)
	{
		$o->{'code'} .= 'print parser()->{\'parts\'}['.$i.']; $CMSBuilder::EML::part_num = '.($i+1).'; '.$o->{'parts'}[$i+1].';';
	}
}

sub init_normal
{
	my $o = shift;
	
	$o->{'uri'} = $ENV{'REQUEST_URI'};
	
	$o->{'cgi_dir'} = $ENV{'SCRIPT_FILENAME'};
	$o->{'cgi_dir'} =~ s/\/[^\/]+$/\//;
	
	$o->{'file'} = $ENV{'PATH_TRANSLATED'};
	$o->{'file'} =~ s/\\/\//g;
	if ($o->{'file'}=~/^redirect\:/){
           $o->{'file'}=~s/redirect\:\/cgi\-bin\/cmsb.pl//;
           $o->{'file'}=$CMSBuilder::Config::path_htdocs.$o->{'file'};
        }
	$o->{'file'} =~ s/\.ehtml(\/.*)//;
	$o->{'path'} = $1;
	if($o->{'path'}){ $o->{'file'} .= '.ehtml'; }
	
	$o->{'dir'} = $o->{'file'};
	$o->{'dir'} =~ s/\/[^\/]+$/\//;
}

sub eml_f2var
{
	my $o = shift;
	my $f = shift;
	my $var;
	local *SSI;
	
	unless( open(SSI,'<',$f) ){ return '[an error occurred while processing this directive]'; }
	$var = join('',<SSI>);
	close(SSI);
	
	return $var;
}

sub SSI
{
	my $o = shift;
	my $str = shift;
	
	if($str =~ m/\w+="(.+?)"/){ return eml_f2var($o,$1); }
	
	return '';
}

1;
