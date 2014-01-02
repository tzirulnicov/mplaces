# (с) Леонов П.А., 2005

# 
# Модуль управляет буферизацией вывода
# и определяет функции стандартных ошибок.
# 

package CMSBuilder::IO;
use strict qw(subs vars);
use utf8;

use Carp;
use POSIX 'strftime';
use CGI '-compile';

use Exporter;
our @ISA = 'Exporter';
our @EXPORT =
qw/
&err500 &err404 &err403 &errany
$sess $sessid %headers $system_ini $modules_ini
/;

use CMSBuilder::IO::Session;
use CMSBuilder::IO::Ini;
use CMSBuilder::IO::GUI;

use CMSBuilder::Utils;

our
(
	$buffer_on,
	$mem, $out, %headers,
	$system_ini,$modules_ini,$sts,
	%errtext,%errstatus,$errtpl,
	$stdout_bkp,$err_catched
);

%errstatus =
(
	200 => 'OK',
	500 => 'Internal Server Error',
	404 => 'Not Found',
	403 => 'Forbidden',
	'*' => 'Unknown',
);

%errtext =
(
	500 => '<h4>На сервере произошла ошибка.</h4><p>Попробуйте обратиться к этой странице позже.</p>',
	404 => '<h4>Запрашиваемый документ не найден.</h4>',
	403 => '<h4>У вас нет доступа к этому разделу или элементу.</h4>
			<p>Если вы не вошли в систему под своим именем,<br> можете сделать это на <a href="'.$CMSBuilder::Config::http_aroot.'/login.ehtml"><u>странице входа в систему</u></a>.</p>',
	'*' => 'Неизвестная ошибка.'
);

#——————————————————————————— Рабочие функции интерфейса ————————————————————————

sub errany
{
	my $en = shift;
	my $etext = shift;
	
	$en =~ s/\D//g;
	# if ($en=~/404/){
	#    $headers{'Location'}='http://'.$ENV{'HTTP_HOST'}.'/page17.html';
	#   	   $en=302;
	# }
	$errtpl = $errtpl || f2var_utf8($CMSBuilder::Config::path_etc.'/errors.html.tpl');
	
	my $res = parsetpl
	(
		$errtpl,
		{
			'errnum' => $en,
			'errtext' => $etext || $errtext{$en} || $errtext{'*'},
			'aroot' => $CMSBuilder::Config::http_aroot,
		}
	);
	
	$headers{'Status'} = $en.' '.($errstatus{$en} || $errstatus{'*'});
	
	CMSBuilder::IO->send_data_utf8($res);
}

sub err500{ my $en = $err_catched = 500; errany($en); croak('Error '.$en.': '.join('',@_)); }
sub err404{ my $en = $err_catched = 404; errany($en); croak('Error '.$en.': '.join('',@_)); }
sub err403{ my $en = $err_catched = 403; errany($en); croak('Error '.$en.': '.join('',@_)); }

sub sess { return \%CMSBuilder::IO::Session::sess; }
sub sessid { return \%CMSBuilder::IO::Session::sessid; }

sub buffer { \$out }

sub buffer_on
{
	return if $buffer_on;
	$buffer_on = 1;
	
	open($mem, '>>:utf8', \$out);
	$stdout_bkp = select($mem);
	#warn '['.$stdout_bkp.']';
	return 1;
}

sub buffer_off
{
	return unless $buffer_on;
	$buffer_on = 0;
	
	select $stdout_bkp if $stdout_bkp;
	close $mem;
	
	return 1;
}

sub buffer_clear
{
	my $c = shift;
	
	if ($buffer_on)
	{
		$c->buffer_off();
		undef $out;
		$c->buffer_on();
	}
	else
	{
		undef $out;
	}
}


sub init
{
	my $c = shift;
	
	undef $buffer_on;
	undef $out;
	
	#$c->buffer_clear();
	
	# Заголовки
	%headers =
	(
		'Content-type'		=> 'text/html; charset=utf-8',
		'Pragma'			=> 'no-cache',
		'Cache-control'		=> 'max-age=0',
		'Expires'			=> '0',
		'X-Powered-By'		=> 'Paleo CMS Builder ' . $CMSBuilder::version,
		'Last-Modified'		=> estrftime('%a, %d %b %Y %T %H:%M:%S GMT' , localtime( time() - 3600 * 2 ) ),
	);
}

sub start
{
	my $c = shift;
	
	if($sts){ return; }
	$sts = 1;
	
	$c->init();
	
	$system_ini = CMSBuilder::IO::Ini->new($CMSBuilder::Config::path_etc.'/system.ini');
	$modules_ini = CMSBuilder::IO::Ini->new($CMSBuilder::Config::path_etc.'/modules.ini');
	
	$c->buffer_on();
	
	CMSBuilder::IO::Session->start();
}

sub stop
{
	my $c = shift;
	
	unless($sts){ return; }
	$sts = 0;
	
	CMSBuilder::IO::Session->stop();
	
	undef $system_ini;
	undef $modules_ini;
	
	$c->buffer_off();
	
	for my $flt (@CMSBuilder::Config::io_filters){ $flt->filt($c->buffer); }
	
	$c->print_headers();
	print ${$c->buffer};
}

sub send_data_begin
{
	my $c = shift;
	
	$c->buffer_off();
	print_headers();
	binmode(select());
}

sub send_data_end
{
	my $c = shift;
	
	$c->buffer_on();
	#close(select(undef));
}

sub send_data
{
	my $c = shift;
	my $data = shift;
	
	$c->send_data_begin();
	binmode(select());
	print $data;
	$c->send_data_end();
}

sub send_data_utf8
{
	my $c = shift;
	my $data = shift;
	
	$c->send_data_begin();
	binmode select(), ':utf8';
	print $data;
	$c->send_data_end();
}

sub print_headers
{
	print map {  $_ . ': ' . $headers{$_} . "\n" } keys %headers;
	print "\n";
}


package CMSBuilder::IO::Filter;

sub filt {}

1;
