# (с) Леонов П.А., 2005

package modControlPanel;
use strict qw(subs vars);
use utf8;

our @ISA = ('CMSBuilder::DBI::SimpleModule');

use CMSBuilder;
use CMSBuilder::Utils;
use plgnUsers;

sub _cname {'Панель управления'}
sub _have_icon {1}
sub _one_instance {1}
sub _rpcs {qw/cpanel_table_cre cpanel_dropall/, keys %{{_simplem_menu()}}}

sub _simplem_menu
{
	'cpanel_table_fix'		=> { -name => 'Обновить структуру...', -icon => 'icons/table.gif' },
	'cpanel_object_stat'	=> { -name => 'Статистика объектов', -icon => 'icons/install.gif' },
	'cpanel_install_mods'	=> { -name => 'Поставить модули...', -icon => 'icons/install.gif' },
	'cpanel_mod_root1'		=> { -obj => 'modRoot1' },
	$CMSBuilder::Config::server_type eq 'cgi-server'?
	('cpanel_stopserver'		=> { -name => 'Остановить сервер', -icon => 'icons/shutdown.gif' }):(),
}

#———————————————————————————————————————————————————————————————————————————————


our	$refresh;

sub default
{
	print 'Модуль "Панель управления" помогает Вам централизовано настраивать систему и получать административную информацию.';
}

sub mod_is_installed { return 1; }
sub install_code {}

sub cpanel_stopserver
{
	my $o = shift;
	my $r = shift;
	
	if($r->{'force'})
	{
		warn "Force killing server!";
		print `killall perl`,`killall perl-static`;
		return;
	}
	
	my $pid = f2var($CMSBuilder::Config::server_pidfile);
	warn "Killing server, pid: $pid";
	
	if(kill('KILL' => $pid)){ print "Сервер успешно остановлен (KILL => $pid)."; }
	else{ print "Сервер остановить не удалось ($pid).<p><a href=\"" . $o->admin_right_href . "&act=cpanel_stopserver&force=1\">Применить силу</a> <small>(killall perl)</small></p>"; }
}

sub admin_view_left
{
	my $o = shift;
	
	unless(modRoot->table_have())
	{
		print '<br><center>Структура базы не установлена!</center>';
		return;
	}
	
	return $o->SUPER::admin_view_left(@_);
}

sub admin_view_right
{
	my $o = shift;
	
	unless($group->{'root'})  { CMSBuilder::IO::err403('Trying to cpanel, less $group->{"root"}'); return; }
	unless($group->{'cpanel'}){ CMSBuilder::IO::err403('Trying to cpanel, less $group->{"cpanel"}'); return; }
	
	$refresh = 0;
	
	my @res = $o->SUPER::admin_view_right(@_);
	
	unless(modRoot->table_have())
	{
		print '<br><br>Структура базы не установлена! <a href="?url=',$o->myurl(),'&act=cpanel_table_cre"><b>Установить...</b></a>';
		return;
	}
	
	if($refresh){ print '<script language="JavaScript">parent.frames.admin_modules.document.location.href = parent.frames.admin_modules.document.location.href;</script>'; }
	
	return @res;
}

sub cpanel_scanbase
{
	my $o = shift;
	
	for my $cn (cmsb_classes())
	{
		for my $to ($cn->sel_where(" PAPA_CLASS = '' OR PAPA_ID = 0 "))
		{
			print $to->name(),'<br>';
		}
	}
}

sub cpanel_dropall
{
	my $o = shift;
	
	CMSBuilder::DBI::tables_dropall();
	
	print 'Все дропнули.';
}

sub cpanel_table_cre
{
	my $o = shift;
	
	CMSBuilder::DBI::table_create_system();
	modRoot->table_cre();
	my $mr = modRoot->cre();
	$mr->{'name'} = 'Корень модулей';
	$mr->papa_set($o);
	$mr->save();
	
	$o->cpanel_table_fix();
	
	print
	'
	<p>Таблицы всех классов, таблица разрешений, таблица связей и корень модулей успешно установлены.</p>
	<p>Обычно, следующий шаг &#151; это <a href="'.$o->admin_right_href().'&act=cpanel_install_mods"><u>Установка модулей</u></a>.</p>
	';
	$refresh = 1;
}

sub cpanel_table_fix
{
	my $ch;
	for my $cn (sort {$a->cname() cmp $b->cname()} cmsb_classes())
	{
		my $log = eval { $cn->table_fix() };
		
		print '<div><small style="float:right">';
		
		if($log->{'changed'} || $log->{'existed'} || $log->{'deleted'})
		{
			if($log->{'changed'})
			{
				print join ', ', map { '<strong>~'.$_->{'name'}.'</strong>[ '.$_->{'from'}.' &rarr; '.$_->{'to'}.' ]' } @{$log->{'changed'}};
			}
			if($log->{'existed'})
			{
				print join ', ', map { '<strong>+'.$_->{'name'}.'</strong>[ '.$_->{'to'}.' ]' } @{$log->{'existed'}};
			}
			if($log->{'deleted'})
			{
				print join ', ', map { '<strong>-'.$_->{'name'}.'</strong>[ '.$_->{'from'}.' ]' } @{$log->{'deleted'}};
			}
		}
		elsif($@)
		{
			print 'ошибка: ' . $@;
		}
		else
		{
			print 'порядок';
		}
		
		print '</small>',$cn->admin_cname(),'</div>';
		
		$ch += keys %$log;
	}
	
	print '<p>',$ch ? 'Структура обновлена.' : 'Обновление не требуется.','</p>';
}

sub cpanel_object_stat
{
	print '<table><tr><td align="center"><b>Класс</b></td><td width="25">&nbsp;</td><td><b>Кол-во</b></td></tr>';
	
	for my $cn (sort {$a->cname cmp $b->cname} cmsb_classes())
	{
		unless($cn){ print '<tr><td>&nbsp;</td><td></td><td></td></tr>'; next; }
		
		print '<tr><td>',$cn->admin_cname(),'(',$cn,')</td><td></td><td align="center">',(${$cn.'::simple'}?'-':$cn->count()),'</td></tr>';
	}
	
	print '</table>';
}

sub cpanel_install_mods
{
	my $some = 0;
	
	for my $mod (cmsb_modules())
	{
		$some |= $mod->install();
		$mod->err_print();
	}
	
	if($some){ print '<br>Модули успешно установлены.'; } #$refresh = 1;
	else{ print '<br>Установка не требуется.'; }
}


1;
