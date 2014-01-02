# (с) Леонов П.А., 2005

package CMSBuilder::Starter;
use strict qw(subs vars);
use utf8;

our $already_loaded;

sub start
{
	my $starts = $CMSBuilder::Config::server_type || 'cgi';
	open(STDERR,'>>:utf8',$CMSBuilder::Config::file_errorlog) if $CMSBuilder::Config::file_errorlog && ! exists $ENV{'MOD_PERL'};
	if($starts eq 'cgi')
	{
		start_cgi();
	}
	elsif($starts eq 'cgi-server')
	{
		start_cgi_server();
	}
	elsif($starts eq 'http-server')
	{
		
	}
	elsif($starts eq 'rpc-server')
	{
		
	}
}

sub start_cgi_server
{
	if($ARGV[0] eq 'server')
	{
		require CMSBuilder::Starter::cgi_server_server;
		CMSBuilder::Starter::cgi_server_server::start();
	}
	else
	{
		require CMSBuilder::Starter::cgi_server_cgi;
		CMSBuilder::Starter::cgi_server_cgi::start();
	}
}

sub start_cgi
{
	require CMSBuilder;
	
	################################################################################
	
	unless($already_loaded)
	{
		# Загрузка и компиляция
		CMSBuilder->load();
	}
	
	
	# Инициализация и начало работы
	CMSBuilder->init();
	
	# Собственно работа
	CMSBuilder->process();
	
	# Конец работы: флаши, кеши, пуши и т.д.
	CMSBuilder->destruct();
	
	# для mod_perl
	$already_loaded = 1;
	
	if($already_loaded && !exists $ENV{'MOD_PERL'})
	{
		# Выгрузка
		CMSBuilder->unload();
	}
	
	################################################################################
}

1;
