# (с) Леонов П.А., 2005

package CMSBuilder::IO::Session;
use strict qw(subs vars);
use utf8;

use Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw/$sess $sessid/;

use Fcntl;
use Fcntl ':flock';
use SDBM_File;
use Data::Dump 'dump';

use CMSBuilder::Utils;

our
(
	$sess,$sessid,
	$dir,$ses_fname,$sess
);

$dir = $CMSBuilder::Config::path_tmp;
$ses_fname = $dir . '/sessions';

sub start
{
	my %cook = CGI::cookie("CMSBSession");

	$sessid = $cook{"id"};
	$sessid =~ s/\W//g;
	
	{
		open my $f, '>', $ses_fname . '.flk' or die "Can`t open sessions lockfile with filename '$ses_fname.flk': $!";
		flock($f,LOCK_SH);
		tie my %all, 'SDBM_File', $ses_fname, O_RDONLY | O_CREAT, 0660 or die "Can`t tie sessions to SDBM_File:  filename '$ses_fname': $!";
		flock($f,LOCK_UN);
		close $f;
		
		if( length $sessid < 30 )
		{
			srand();
			
			do
			{
				$sessid = rand() . rand();
				$sessid =~ s/\D//g;
				$sessid = uc MD5(~$sessid);
			}
			while exists $all{$sessid};
		}
		
		$sess = eval $all{$sessid};
	}
	
	$cook{'id'} = $sessid;
	
	my $dom = $ENV{'HTTP_HOST'};
	my @dom = split(/\./,$dom);
	
	if(@dom > 1)
	{
		$dom = '.'.$dom[$#dom-1].'.'.$dom[$#dom];
	}
	else
	{
		$dom = '';
	}
	
	my $send = CGI::cookie
	(
		-name=>"CMSBSession",
		-value=>\%cook,
		-path=>'/',
		-expires=>'+365d',
		-domain=>$dom
	);
	
	$CMSBuilder::IO::headers{'Set-Cookie'} = $send->as_string;
	
	return $send;
}

sub stop
{
	open my $f, '>', $ses_fname . '.flk' or die "Can`t open sessions lockfile with filename '$ses_fname.flk': $!";
	flock($f,LOCK_EX);
	tie my %all, 'SDBM_File', $ses_fname, O_RDWR, 0660 or die "Can`t tie sessions to SDBM_File:  filename '$ses_fname': $!";
	
	if(keys %$sess)
	{
		$all{$sessid} = dump $sess;
	}
	else
	{
		delete $all{$sessid};
	}
	
	
	flock($f,LOCK_UN);
	close $f;
}


1;







