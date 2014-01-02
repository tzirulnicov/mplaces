# (с) Леонов П.А., 2005

package plgnCPanelBackup;
use strict qw(subs vars);
use utf8;

our @ISA = ('CMSBuilder::Plugin');

#———————————————————————————————————————————————————————————————————————————————


sub plgn_load
{
	my $c = shift;
	
	push @modControlPanel::ISA,'plgnCPanelBackup::ModBackup';
}


1;


package plgnCPanelBackup::ModBackup;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnFileManager::Object','CMSBuilder::DBI::SimpleModule');

sub _cname {'Резервное копирование'}
sub _have_icon {1}
sub _one_instance {1}
sub _rpcs {keys %{{_simplem_menu()}}}

sub _simplem_menu
{
	'cpanel_backup'				=> { -name => 'Резервная копия', -icon => 'icons/backup.gif' },
		'fileman_view'			=> { -name => 'Список архивов', -icon => 'icons/Dir.gif', -papa => 'cpanel_backup' },
		'cpanel_backup_create'	=> { -name => 'Создать', -icon => 'icons/backup.gif', -papa => 'cpanel_backup' },
		'cpanel_backup_restore'	=> { -name => 'Восстановить', -icon => 'icons/backup.gif', -papa => 'cpanel_backup', -hide => 1},
}

#———————————————————————————————————————————————————————————————————————————————


use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use POSIX ('strftime');
use CMSBuilder::Utils;
use CMSBuilder::IO;

our $confname = 'config_v1.5.txt';

our $zitems =
[
	{
		-name	=> 'ee',
		-text	=> 'Файлы пользователей',
		-type	=> 'tree',
		-local	=> $CMSBuilder::Config::path_htdocs.$CMSBuilder::Config::http_eroot,
		-zip	=> 'ee',
		-checked => 0,
	},
	{
		-name	=> 'admin',
		-text	=> 'Система администрирования',
		-type	=> 'tree',
		-local	=> $CMSBuilder::Config::path_htdocs.$CMSBuilder::Config::http_aroot,
		-zip	=> 'admin',
	},
	{
		-name	=> 'etc',
		-text	=> 'Служебные файлы',
		-type	=> 'tree',
		-local	=> $CMSBuilder::Config::path_etc,
		-zip	=> 'etc',
	},
	{
		-name	=> 'tmp',
		-text	=> 'Временные файлы',
		-type	=> 'tree',
		-local	=> $CMSBuilder::Config::path_tmp,
		-zip	=> 'tmp',
	},
	{
		-name	=> 'www',
		-text	=> 'Дизайн',
		-type	=> 'tree',
		-local	=> $CMSBuilder::Config::path_htdocs,
		-zip	=> 'www',
		-rule	=> sub { $_ !~ /$CMSBuilder::Config::path_htdocs($CMSBuilder::Config::http_aroot)|($CMSBuilder::Config::http_eroot)/ },
		-checked => 0,
	},
	{
		-name	=> 'libsite',
		-text	=> 'Код приложений',
		-type	=> 'tree',
		-local	=> $CMSBuilder::Config::path_libsite,
		-zip	=> 'code/libsite',
		#-checked => 1,
	},
	{
		-name	=> 'libcore',
		-text	=> 'Код ядра',
		-type	=> 'tree',
		-local	=> $CMSBuilder::Config::path_libcore,
		-zip	=> 'code/libcore',
	},
	{
		-name	=> 'base',
		-text	=> 'База данных',
		-type	=> 'base',
		-cmdin	=> $CMSBuilder::Config::mysql_dumpcmd,
		-cmdout	=> $CMSBuilder::Config::mysql_importcmd,
		-zip	=> 'base.sql',
		-checked => 1,
	},
	
	#{
	#	-name	=> '',
	#	-text	=> '',
	#	-type	=> 'tree',
	#	-local	=> ,
	#	-zip	=> '',
	#},
];

our $zfuncs_cre =
{
	'tree' => sub
	{
		my $zip = shift;
		my $it = shift;
		
		$zip->addTree($it->{'-local'},$it->{'-zip'},$it->{'-rule'});
		
		return 1;
	},
	
	'file' => sub
	{
		my $zip = shift;
		my $it = shift;
		
		$zip->addFile($it->{'-local'},$it->{'-zip'});
		
		return 1;
	},
	
	'command' => sub
	{
		my $zip = shift;
		my $it = shift;
		
		my $cmd = $it->{'-cmdin'};
		
		my $res = `$cmd`;
		$zip->addString($res,$it->{'-zip'});
		
		return 1;
	},
	
	'base' => sub
	{
		my $zip = shift;
		my $it = shift;
		
		my $cmd = $it->{'-cmdin'};
		
		my $res = `$cmd` || do { $cmd =~ s/-p\s*\S+/-p(YES)/; die "Cannnot `$cmd`: $!"; };
		$zip->addString($res,$it->{'-zip'});
		
		return 1;
	},
};

our $zfuncs_have =
{
	'tree' => sub
	{
		my $zip = shift;
		my $it = shift;
		
		my @mbs = $zip->membersMatching('^'.$it->{'-zip'}.'/');
		
		#print '[',@mbs,']';
		
		return (@mbs > 0);
	},
	
	'file' => sub
	{
		my $zip = shift;
		my $it = shift;
		
		return $zip->memberNamed($it->{'-zip'});
	},
	
	'command' => sub
	{
		my $zip = shift;
		my $it = shift;
		
		return $zip->memberNamed($it->{'-zip'});
	},
	
	'base' => sub
	{
		my $zip = shift;
		my $it = shift;
		
		return $zip->memberNamed($it->{'-zip'});
	},
};

our $zfuncs_res =
{
	'tree' => sub
	{
		my $zip = shift;
		my $it = shift;
		
		$zip->extractTree($it->{'-zip'},$it->{'-local'});
		
		return 1;
	},
	
	'file' => sub
	{
		my $zip = shift;
		my $it = shift;
		
		$zip->extractMember($it->{'-zip'},$it->{'-local'});
		
		return 1;
	},
	
	'command' => sub
	{
		my $zip = shift;
		my $it = shift;
		
		my $cmd = $it->{'-cmdout'};
		my $res = $zip->contents($it->{'-zip'});
		
		my $fh;
		open($fh,'|-',$cmd);
		print $fh $res;
		close($fh);
		
		return 1;
	},
	
	'base' => sub
	{
		my $zip = shift;
		my $it = shift;
		
		my $cmd = $it->{'-cmdout'};
		my $res = $zip->contents($it->{'-zip'});
		
		my $fh;
		open($fh,'|-',$cmd) || do { $cmd =~ s/-p\s*\S+/-p(YES)/; die "Cannot open(|-) $cmd: $!"; };
		print $fh $res;
		close($fh);
		
		return 1;
	},
};

sub fileman_localdir { $CMSBuilder::Config::path_backup; }

sub mod_is_installed { return 1; }
sub install_code {}

sub fileman_cmenu
{
	my $o = shift;
	
	my $path = shift;
	my $e = shift;
	
	return
	$o->SUPER::fileman_cmenu($path,$e,@_).'
	elem_add(JHR());
	elem_add(JMIHref("Восстановить","'.$o->admin_right_href().'&act=cpanel_backup_restore&path='.$path.'",""));
	';
}

sub cpanel_backup_restore
{
	my $o = shift;
	my $r = shift;
	
	if($r->{'sact'} eq 'cre'){ return $o->cpanel_backup_restore_make($r); }
	
	my $path = ($r->{'path'} eq '/')?'':$r->{'path'};
	
	unless($path){ return $o->fileman_view($r); }
	
	$path = $o->fileman_clearpath($path);
	
	my $zip = Archive::Zip->new($o->fileman_localdir().'/'.$path);
	
	unless($zip->memberNamed($confname)){ return $o->err_add('Неверный формат файла!'); }
	
	print $zip->zipfileComment().'<br><hr><br>' if $zip->zipfileComment();
	
	print
	'
	<form action="?" method="post">
		<input type="hidden" name="url" value="',$o->myurl(),'">
		<input type="hidden" name="path" value="',$path,'">
		<input type="hidden" name="act" value="cpanel_backup_restore">
		<input type="hidden" name="sact" value="cre">
		Выберите информацию, которую надо восстановить:<br><br>
		<table>
	';
	
	for my $it (@$zitems)
	{
		if($zfuncs_have->{$it->{'-type'}}->($zip,$it))
		{
			print '<tr><td>',$it->{'-text'},':</td><td><input type="checkbox" name="',$it->{'-name'},'" checked></td></tr>';
		}
		else
		{
			print '<tr><td>',$it->{'-text'},':</td><td><input type="checkbox" name="',$it->{'-name'},'" disabled></td></tr>';
		}
	}
	
	print
	'
			<tr><td colspan="2"><hr></td></tr>
			<tr><td>Всё:</td><td><input type="checkbox" checked onclick="
				tc = this.checked;
	';
	
	for my $it (@$zitems)
	{
		if($zfuncs_have->{$it->{'-type'}}->($zip,$it))
		{
			print $it->{'-name'},'.checked=tc;';
		}
	}
	
	print
	'
			"></td></tr>
			<tr><td colspan="2"><hr></td></tr>
			<tr><td></td><td>&nbsp;</td></tr>
			<tr><td colspan="2"><input type="submit" value="Восстановить" onclick="return confirm(\'ВНИМАНИЕ! При восстановлении из архива информация из выбранных разделов будет безвозвратно утеряна.\\n\\nПродолжить восстановление?\')"></td></tr>
		</table>
	</form>
	';
}

sub cpanel_backup_restore_make
{
	my $o = shift;
	my $r = shift;
	
	my $path = ($r->{'path'} eq '/')?'':$r->{'path'};
	
	$path = $o->fileman_clearpath($path);
	
	my $zip = Archive::Zip->new($o->fileman_localdir().'/'.$path);
	
	unless($zip->memberNamed($confname)){ return $o->err_add('Неверный формат файла!'); }
	
	my $cnt;
	for my $it (@$zitems)
	{
		if($zfuncs_have->{$it->{'-type'}}->($zip,$it) && $r->{$it->{'-name'}})
		{
			print '<div>',$it->{'-text'} . '&nbsp;—&nbsp;';
			
			my $res = eval { $zfuncs_res->{$it->{'-type'}}->($zip,$it) };
			if($@)
			{
				print "Ошибка: $@";
			}
			else
			{
				if($res)
				{
					print 'успешно';
					$cnt++;
				}
				else
				{
					print 'не удалось';
				}
			}
			
			print '</div>';
		}
	}
	
	unless($cnt){ $o->notice_add('Ни одного элемента не было выбрано для восстановления.'); }
}

sub cpanel_backup_create
{
	my $o = shift;
	my $r = shift;
	
	if($r->{'sact'} eq 'cre'){ return $o->cpanel_backup_make($r); }
	
	print
	'
	<form action="?" method="post">
		<input type="hidden" name="url" value="',$o->myurl(),'">
		<input type="hidden" name="act" value="cpanel_backup_create">
		<input type="hidden" name="sact" value="cre">
		Выберите информацию, которую надо архивировать:<br><br>
		<table>
	';
	
	for my $it (@$zitems)
	{
		print '<tr><td>',$it->{'-text'},':</td><td><input type="checkbox" name="',$it->{'-name'},'" ',($it->{'-checked'}?'checked':''),'></td></tr>';
	}
	
	print
	'
			<tr><td colspan="2"><hr></td></tr>
			<tr><td>Всё:</td><td><input type="checkbox" onclick="
				tc = this.checked;
	';
	
	for my $it (@$zitems)
	{
		print $it->{'-name'},'.checked=tc;';
	}
	
	print
	'
			"></td></tr>
			<tr><td colspan="2"><hr></td></tr>
			<tr><td>Скачать архив:</td><td><input type="checkbox" name="send"></td></tr>
			<tr><td colspan="2"><hr></td></tr>
			<tr><td></td><td>&nbsp;</td></tr>
			<tr><td colspan="2"><input type="submit" value="Архивировать"></td></tr>
		</table>
	</form>
	';
}

sub cpanel_backup_make
{
	my $o = shift;
	my $r = shift;
	
	my($sql,$mb,@mbs,@done,@errs);
	
	unless(-d $CMSBuilder::Config::path_backup){ mkdir($CMSBuilder::Config::path_backup); }
	
	my $zip = Archive::Zip->new();
	
	for my $it (@$zitems)
	{
		if(exists $r->{$it->{'-name'}})
		{
			print '<div>',$it->{'-text'} . '&nbsp;—&nbsp;';
			
			my $res = eval { $zfuncs_cre->{$it->{'-type'}}->($zip,$it); };
			if($@)
			{
				push @errs, $it->{'-name'};
				print "Ошибка: $@";
			}
			else
			{
				if($res)
				{
					push @done, $it->{'-name'};
					print 'успешно';
				}
				else
				{
					push @errs, $it->{'-name'};
					print 'не удалось';
				}
			}
			
			print '</div>';
		}
	}
	
	if(@errs)
	{
		$o->notice_add('Создание архива прервано в связи с ошибками.');
		return;
	}
	
	unless(@done)
	{
		$o->err_add('Не указаны объекты архивации.');
	}
	
	my $conf = join(', ',@done);
	$zip->addString($conf,$confname);
	
	for $mb ($zip->members())
	{
		$mb->desiredCompressionMethod(COMPRESSION_DEFLATED);
		$mb->desiredCompressionLevel(COMPRESSION_LEVEL_BEST_COMPRESSION);
	}
	
	my($zfname,$fi);
	do
	{
		$zfname = $CMSBuilder::Config::mysql_base.'_'.strftime('%y%m%d',localtime()).($fi?"($fi)":'').'.zip';#(%H%M%S)
		$fi++;
	}
	while(-f $CMSBuilder::Config::path_backup.'/'.$zfname);
	
	
	if($zip->writeToFileNamed($CMSBuilder::Config::path_backup.'/'.$zfname) == AZ_OK)
	{
		$o->notice_add('Архив успешно создан: <b>'.$zfname.'</b> ('.len2size((stat($CMSBuilder::Config::path_backup.'/'.$zfname))[7]).').');
		if($r->{'send'}){ print '<iframe style="width:0;height:0" src="',$o->admin_right_href(),'&act=fileman_view&path=/',$zfname,'"></iframe>'; }
	}
	else{ $o->err_add('Не удалось сохранить файл архива!'); }
}

sub cpanel_backup_old
{
	my $o = shift;
	my $r = shift;
	my $sact = $r->{'sact'};
	
	if($sact eq 'do')
	{

	}
	elsif($sact eq 'upload')
	{
		my($zf);
		my $bfile = CGI::param('bfile');
		my $tmpz = $CMSBuilder::Config::path_backup.'/temp'.$$.'.zip';
		
		open($zf,'>',$tmpz);
		binmode($zf);
		binmode($bfile);
		my $buff;
		while(read($bfile,$buff,2048)){ print $zf $buff; }
		close($zf);
		
		my $zip = Archive::Zip->new();
		$zip->read($tmpz);
		
		unless($zip->memberNamed($confname))
		{
			$o->err_add('Неверный формат файла!');
			unlink($tmpz);
			return;
		}
		
		CMSBuilder::IO->stop();
		
		my $conf = $zip->contents($confname);
		
		if($conf =~ /sql/)
		{
			my $sql = $zip->contents('sql.txt');
			
			while($sql =~ m/CREATE TABLE (\S+) \(\n/g)
			{
				$CMSBuilder::DBI::dbh->do('DROP TABLE IF EXISTS '.$1);
			}
			
			my $fh;
			open($fh,'|-',$CMSBuilder::Config::mysql_importcmd);
			print $fh $sql;
			close($fh);
			
			print 'База данных восcтановлена.<br>';
		}
		
		if($conf =~ /www/)
		{
			$zip->extractTree('www',$CMSBuilder::Config::path_htdocs);
			print 'Дизайн восcтановлен.<br>';
		}
		
		if($conf =~ /ee/)
		{
			$zip->extractTree('ee',$CMSBuilder::Config::path_htdocs.$CMSBuilder::Config::http_eroot);
			print 'Файлы пользователей восcтановлены.<br>';
		}
		
		if($conf =~ /admin/)
		{
			$zip->extractTree('admin',$CMSBuilder::Config::path_htdocs.$CMSBuilder::Config::http_aroot);
			print 'Интерфейс администратора восcтановлена.<br>';
		}
		
		if($conf =~ /etc/)
		{
			$zip->extractTree('etc',$CMSBuilder::Config::path_etc);
			print 'Служебные файлы восcтановлены.<br>';
		}
		
		if($conf =~ /tmp/)
		{
			$zip->extractTree('tmp',$CMSBuilder::Config::path_tmp);
			print 'Временные файлы воcстановлены.<br>';
		}
		
		if($conf =~ /libcore/)
		{
			$zip->extractTree('code/libcore',$CMSBuilder::Config::path_libcore);
			$zip->extractMember('code/eml.cgi','eml.cgi');
			print 'Код ядра воcстановлен.<br>';
		}
		
		if($conf =~ /libsite/)
		{
			$zip->extractTree('code/libsite',$CMSBuilder::Config::path_libsite);
			print 'Код приложений воcстановлен.<br>';
		}
		
		unlink($tmpz);
		
		print '<br><br>Воcстановление закончено.';
	}
	elsif($sact eq 'send')
	{
		my $zfname = $r->{'fname'};
		path_it($zfname);
		
		%headers =
		(
			'Content-type' => 'application/zip',
			'Content-Disposition' => 'attachment; filename="'.$zfname.'"'
		);
		
		send_data_begin();
		
		my $fh;
		open($fh,'<',$CMSBuilder::Config::path_backup.'/'.$zfname);
		binmode($fh);
		binmode(select());
		print join('',<$fh>);
		close($fh);
		
		send_data_end();
	}
	else
	{
		print
		'
		<form action="?" method="post">
			<input type="hidden" name="url" value="',$o->myurl(),'">
			<input type="hidden" name="act" value="cpanel_backup_create">
			<input type="hidden" name="sact" value="do">
			Выберите информацию, которую надо архивировать:<br><br>
			<table>
				<tr><td>База данных:</td><td><input type="checkbox" name="sql" checked></td></tr>
				<tr><td>Файлы пользователей:</td><td><input type="checkbox" name="ee" checked></td></tr>
				<tr><td>Служебные файлы:</td><td><input type="checkbox" name="etc" checked></td></tr>
				<tr><td colspan="2"><hr></td></tr>
				<tr><td>Дизайн:</td><td><input type="checkbox" name="www"></td></tr>
				<tr><td>Временные файлы:</td><td><input type="checkbox" name="tmp"></td></tr>
				<tr><td>Интерфейс администратора:</td><td><input type="checkbox" name="admin"></td></tr>
				<tr><td>Код ядра:</td><td><input type="checkbox" name="libcore"></td></tr>
				<tr><td>Код приложений:</td><td><input type="checkbox" name="libsite"></td></tr>
				<tr><td colspan="2"><hr></td></tr>
				<tr><td>Всё:</td><td><input type="checkbox" onclick="
					tc = this.checked;
					sql.checked=tc;
					ee.checked=tc;
					etc.checked=tc;
					www.checked=tc;
					tmp.checked=tc;
					admin.checked=tc;
					libcore.checked=tc;
					libsite.checked=tc;
				"></td></tr>
				<tr><td colspan="2"><hr></td></tr>
				<tr><td>Выслать:</td><td><input type="checkbox" name="send" checked></td></tr>
				<tr><td></td><td>&nbsp;</td></tr>
				<tr><td colspan="2"><input type="submit" value="Архивировать"></td></tr>
			</table>
		</form>
		
		<form action="?" method="post" enctype="multipart/form-data">
			<input type="hidden" name="url" value="',$o->myurl(),'">
			<input type="hidden" name="act" value="cpanel_backup_restore">
			<input type="hidden" name="sact" value="upload">
			<input type="file" name="bfile">
			<input type="submit" value="Восстановить">
		</form>
		';
		
	}
}

sub cpanel_backup
{
	my $o = shift;
	
	print
	'
	<p>
	Этот модуль поможет вам сохранить ценную информацию в случаях, когда она может
	быть повреждена или утеряна.
	</p>
	
	<p>
	<a href="',$o->admin_right_href(),'&act=cpanel_backup_create"><u>Создание резервных копий</u></a> сайта до начала внесения изменений и после его окончания
	позволит упростить администрирование и снять часть нагрузки с редактора. Регулярное
	создание и скачивание копий защитит от ошибок и сбоев в работе сервера.
	</p>
	
	<p>
	<a href="',$o->admin_right_href(),'&act=fileman_view"><u>Сохранив на свой компьютер</u></a> копию сайта, вы сведёте к минимуму риск утери сайта в случае ситуаций форс-мажорного характера.
	Сайт всегда можно будет восстановить в прежнем виде, даже если в интернете он более не доступен.
	</p>
	';
}


1;