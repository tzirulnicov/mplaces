package CMSBuilder::Starter::cgi_server_server;
use strict qw(subs vars);
use utf8;

use Socket;
use POSIX 'setsid';
use POSIX ':sys_wait_h';

use CMSBuilder;
use CMSBuilder::Utils;


sub reaper
{
	while(waitpid(-1,WNOHANG) > 0){}
	$SIG{'CHLD'} = \&reaper;
}

sub start
{
	print "Starting server: $CMSBuilder::Config::server_addres\n";
	
	
	if($CMSBuilder::Config::server_daemon)
	{
		print "Starting as daemon...";
		
		$SIG{'CHLD'} = 'IGNORE'; #$SIG{'CHLD'} = \&reaper;
		defined (my $dpid = fork) or die "Cannot fork for a daemon: $!";
		
		if($dpid){ exit(0); }
		
		print " OK\n";
		
		#open(STDERR,'>>:utf8',$CMSBuilder::Config::server_logfile);
		open(STDOUT,'>&',STDERR);
		close(STDIN);
		
		setsid() or die "Cannot setsid() for daemon";
		
		var2f($$,$CMSBuilder::Config::server_pidfile);
	}
	
	
	my $srv = start_server_ex($CMSBuilder::Config::server_addres);
	
	listen_loop($srv);
}

sub listen_loop
{
	my $srv = shift;
	
	open RSTDOUT, ">&STDOUT";
	close(STDOUT);
	open RSTDIN,  "<&STDIN";
	close(STDIN);
	
	$| = 1;
	
	# Загрузка и компиляция
	CMSBuilder->load();
	
	print RSTDOUT "Ready for connections...\n";
	
	my $clnts_cnt = 0;
	
	while(1)
	{
		my $clnt;
		accept($clnt,$srv);
		
		aflush($clnt);
		
		unless(fork)
		{
			on_connection($clnt);
			close($clnt);
			exit();
		}
		
		close($clnt);
		
		$clnts_cnt++;
		
		if
		(
			$CMSBuilder::Config::server_autostart &&
			$CMSBuilder::Config::server_shdown &&
			$clnts_cnt >= $CMSBuilder::Config::server_shdown
		)
		{
			warn "exit() after $clnts_cnt connections";
			exit();
		}
	}
	
	# Выгрузка
	CMSBuilder->unload();
}

sub on_connection # forked
{
	my $clnt = shift;
	
	%ENV = ();
	
	while(my $env = <$clnt>)
	{
		chomp($env);
		unless($env){ last; }
		
		my($key,$val) = split('=',$env);
		$val = pack('H*',$val);
		
		$ENV{$key} = $val
	}
	
	my $rcont;
	binmode($clnt);
	read($clnt,$rcont,$ENV{'CONTENT_LENGTH'});
	
	
	open STDIN, "<", \$rcont;
	binmode(STDIN);
	select($clnt);
	
	CGI::initialize_globals();
	
	#print "Content-type: text/html\n\nreading ",*STDIN,<STDIN>;
	
	do_job();
	
	close(STDIN);
	close($clnt);
}

sub do_job
{
	# Инициализация и начало работы
	CMSBuilder->init();
	
	# Собственно работа
	CMSBuilder->process();
	
	# Конец работы: флаши, кеши, пуши и т.д.
	CMSBuilder->destruct();
}

sub start_server_ex
{
	my($type,$addr) = split(/:/,$_[0],2);
	
	if($type eq 'tcp')
	{
		my($host,$port) = split(/:/,$addr);
		return start_server_tcp($host,$port);
	}
	elsif($type eq 'local')
	{
		return start_server_local($addr);
	}
}

sub start_server_tcp
{
	my $host = shift;
	my $port = shift;
	
	unless($host && $port){ die "Bad addres $host:$port"; }
	
	my $iaddr = inet_aton($host);
	my $my_addr = sockaddr_in($port, $iaddr);
	
	my $server;
	socket($server,PF_INET,SOCK_STREAM, getprotobyname('tcp'));
	#setsockopt($server,SOL_SOCKET,SO_REUSEADDR, 1);
	
	unless( bind($server,$my_addr) ){ die "Could not bind to $host:$port"; }
	unless( listen($server,SOMAXCONN) ){ die "Could not listen on $host:$port"; }
	
	return $server;
}

sub start_server_local
{
	my $addr = shift;
	
	unless($addr){ die "Empty addres."; }
	
	my $server;
	socket($server,PF_UNIX,SOCK_STREAM, 0);
	#setsockopt($server,SOL_SOCKET,SO_REUSEADDR, 1);
	
	unlink($addr);
	
	unless( bind($server,sockaddr_un($addr)) ){ die "Could not bind to $addr, because: ".$!; }
	unless( listen($server,SOMAXCONN) ){ die "Could not listen on $addr, because".$!; }
	
	return $server;
}



sub aflush
{
	my $fh = select($_[0]);
	$| = 1;
	select($fh);
}


1;