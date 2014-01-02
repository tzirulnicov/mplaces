package CMSBuilder::Starter::cgi_server_cgi;
use strict qw(subs vars);
use utf8;

use Socket;
#use Digest::MD5;

sub start
{
	my $addr = $CMSBuilder::Config::server_addres;
	my $server;
	$server = get_connection_ex($addr);
	unless($server)
	{
		warn 'Starting server '.$addr.', because: '.$!;

		`$CMSBuilder::Config::server_cmd_start` if $CMSBuilder::Config::server_autostart;
		
		for(1..5){ last if $server = get_connection_ex($addr); sleep(1); }
		
		unless($server)
		{
			
			require CMSBuilder::IO;
			import CMSBuilder::IO;
			
			err500('Внутренний сервер не отвечает.');
			
			warn 'Server down. Culdn`t connect to '.$addr.', because: '.$!;
			
			return 0;
		}
	}
	
	aflush($server);
	#$ENV{'CMSB_PASS_HASH'} = Digest::MD5::md5_hex($CMSBuilder::Config::mysql_pas);
	my $env;
	for my $key (keys %ENV)
	{
		$env .= $key.'='.unpack('H*',$ENV{$key})."\n";
	}
	print $server $env."\n";
	my $rcont;
	binmode(STDIN);
	read(STDIN,$rcont,$ENV{'CONTENT_LENGTH'});
	
	
	
	binmode($server);
	print $server $rcont;
	
	while(my $res = <$server>){ print $res; }
	
	close($server);
	
	#print "Content-type: text/html\n\nOK",$rcont,$ENV{'CONTENT_LENGTH'}; return 1;
	return 1;
}

sub get_connection_ex
{
	my($type,$addr) = split(/:/,$_[0],2);
	
	if($type eq 'tcp')
	{
		my($host,$port) = split(/:/,$addr);
		return get_connection_tcp($host,$port);
	}
	elsif($type eq 'local')
	{
		return get_connection_local($addr);
	}
}

sub get_connection_tcp
{
	my($host,$port) = @_;
	
	unless($host && $port){ die "Bad addres $host:$port"; }
	
	my $iaddr = inet_aton($host);
	my $paddr = sockaddr_in($port,$iaddr);
	
	my $server;
	socket($server,PF_INET,SOCK_STREAM, getprotobyname('tcp'));
	
	return connect($server,$paddr)?$server:undef;
}

sub get_connection_local
{
	my $addr = shift;
	
	unless($addr){ die "Empty addres."; }
	
	my $server;
	socket($server,PF_UNIX,SOCK_STREAM,0);
	return connect($server,sockaddr_un($addr))?$server:undef;
}

sub aflush
{
	my $fh = select($_[0]);
	$| = 1;
	select($fh);
}

1;
