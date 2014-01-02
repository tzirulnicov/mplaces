# (с) Леонов П.А., 2005

package plgnFileManager;
use strict qw(subs vars);
use utf8;

our @ISA = ('CMSBuilder::Plugin');


1;


package plgnFileManager::Object;
use strict qw(subs vars);
use utf8;

sub _rpcs {'fileman_view'}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;

our %mime =
(
	'jpg' => {-icon => 'self'},
	'gif' => {-icon => 'self'},
	'png' => {-icon => 'self'},
	'bmp' => {-icon => 'self'}
);

sub fileman_cmenu
{
	my $o = shift;
	my $path = shift;
	my $e = shift;
	
	my @rp = split(/\//,$path);
	pop @rp;
	my $rp = '/'.join('/',@rp);
	
	my $ftype = $o->fileman_ftype($path);
	
	return
	'
	elem_add(JMIHref('.($ftype eq 'dir'?'"Открыть"':'"Скачать"').',"'.$o->admin_right_href().'&act=fileman_view&path='.$path.'"));
	elem_add(JMIConfirm("Удалить","'.$o->admin_right_href().'&act=fileman_view&sact=del&path='.$rp.'&name='.$e->{'name'}.'","","Удалить \"'.$e->{'name'}.'\"?"));
	';
}

sub fileman_del
{
	my $o = shift;
	my $path = shift;
	my $name = shift;
	
	my $uldir = $o->fileman_localdir();
	
	my $fname = (reverse split(/\//,$path.'/'.$name))[0];
	
	unless($fname)
	{
		$o->err_add('Корень удалить нельзя.');
		return;
	}
	
	my $apath = $uldir.$path.'/'.$name;
	
	if(unlink($apath) || rmdir($apath))
	{
		$o->notice_add('Успешно удалено: "'.$fname.'".');
	}
	else
	{
		$o->err_add('Не удалось удалить: "'.$fname.'".');
	}
}

sub fileman_view
{
	my $o = shift;
	my $r = shift;
	
	my $sact = $r->{'sact'};
	my $path = ($r->{'path'} eq '/')?'':$r->{'path'};
	
	$path = $o->fileman_clearpath($path);
	
	if($sact eq 'del')
	{
		my $name = $r->{'name'};
		
		path_it($name);
		
		$o->fileman_del($path,$name);
	}
	
	my $ftype = $o->fileman_ftype($path);
	
	if($ftype eq 'dir')
	{
		my $ohref = $o->admin_right_href().'&act=fileman_view&path='.$path;
		
		my $up;
		
		if($path)
		{
			my @rpath = split(/\//,$path);
			pop @rpath;
			my $rpath = join('/',@rpath);
			
			$up = '<a href="'.$o->admin_right_href().'&act=fileman_view&path='.$rpath.'"><img src="icons/dirup.gif"></a>';
		}
		
		print '<fieldset class="plgn_fileman"><legend>',$up,'&nbsp;',$path?$path:'/','</legend>';
		
		my $sby = $r->{'sby'} || 'mtime';
		my @es = sort {length($a->{$sby}) <=> length($b->{$sby}) || $a->{$sby} cmp $b->{$sby}} $o->fileman_listdir($path);
		
		if(@es)
		{
			print
			'
			<table class="maintbl">
			<th><a href="',$ohref,'&sby=name">Имя файла</a></th><th><a href="',$ohref,'&sby=mtime">Дата</a></th><th><a href="',$ohref,'&sby=size">Размер</a></th>
			';
			
			for my $file (@es)
			{
				print '<tr><td>',CMSBuilder::IO::GUI::admin_name_ex
				(
					-name => $file->{'name'},
					-href => $o->admin_right_href().'&act=fileman_view&path='.$path.'/'.$file->{'name'},
					-icon => $o->fileman_icon($path.'/'.$file->{'name'}),
					-props =>
					{
						'title' => 'Размер: '.len2size($file->{'size'}),
						#'cmenu' => $file->{'name'},
						'oncontextmenu' => 'return OnContext(\''.$file->{'name'}.'\',event)',
					},
				),'</td><td>',toDateTimeStr(epoch2ts($file->{'mtime'})),'</td><td>',len2size($file->{'size'}),'</td></tr>';
			}
			
			print '</table>';
		}
		else
		{
			unless(@es){ print '<div class="empty">Папка пуста</div>'; }
		}
		
		print '</fieldset>';
		
		print
		'
		<script language="JavaScript">
		';
		
		for my $e (@es)
		{
			my $code .=
			'
			all_menus_static["'.$e->{'name'}.'"] = 1;
			all_menus["'.$e->{'name'}.'"] = JMenu();
			with(all_menus["'.$e->{'name'}.'"]){
			';
			
			my $title = CMSBuilder::IO::GUI::admin_name_ex(-name => $e->{'name'}, -icon => $o->fileman_icon($path.'/'.$e->{'name'}));
			$code .= 'elem_add(JTitle("'.escape($title).'"));';
			
			$code .= $o->fileman_cmenu($path.'/'.$e->{'name'},$e);
			
			$code .= '}';
			
			print 'all_menus_code["',$e->{'name'},'"] = "',escape($code),'";';
		}
		
		print
		'
		</script>
		';
	}
	elsif($ftype eq 'file')
	{
		my $fname = (reverse split(/\//,$path))[0];
		#my $ext = $fname;
		#$ext =~ s/.*\.//;
		
		#$CMSBuilder::IO::headers{'Content-type'} = 'application/'.$ext;
		$CMSBuilder::IO::headers{'Content-Disposition'} = 'attachment; filename="'.$fname.'"';
		
		my $str = $o->fileman_getfile($path);
		CMSBuilder::IO->send_data($str);
	}
	else
	{
		$o->err_add('Невозможно открыть путь "'.$path.'"');
	}
}

sub fileman_ftype
{
	my $o = shift;
	my $path = shift;
	
	my $uldir = $o->fileman_localdir();
	
	if(-f $uldir.$path){ return 'file'; }
	if(-d $uldir.$path){ return 'dir'; }
	
	return '';
}

sub fileman_getfile
{
	my $o = shift;
	my $path = shift;
	
	my $uldir = $o->fileman_localdir();
	
	return f2var($uldir.$path);
}

sub fileman_listdir
{
	my $o = shift;
	my $path = shift;
	
	my ($dh,@fs,@ds,$it);
	my $uldir = $o->fileman_localdir();
	
	opendir($dh,$uldir.$path) || return $o->err_add('Не удалось открыть директорию "'.$uldir.$path.'"');
	while(my $fname = readdir($dh))
	{
		if($fname eq '.' or $fname eq '..'){ next; }
		
		$it =
		{
			'name'	=> $fname,
			'size'	=> (stat($uldir.$path.'/'.$fname))[7],
			'mtime'	=> (stat($uldir.$path.'/'.$fname))[9],
		};
		
		if(-f $uldir.$path.'/'.$fname){ push @fs, $it; }
		elsif(-d $uldir.$path.'/'.$fname){ push @ds, $it; }
	}
	closedir($dh);
	
	return (@ds,@fs);
}

sub fileman_icon
{
	my $o = shift;
	my $path = shift;
	
	my $ftype = $o->fileman_ftype($path);
	
	if($ftype eq 'dir'){ return $CMSBuilder::Config::http_userdocs.'/icons/directory.gif'; }
	
	my $ext = $path;
	$ext =~ s/.*\.//;
	if($mime{$ext}->{'-icon'} eq 'self'){ return $o->fileman_href($path); }
	if(-f $CMSBuilder::Config::path_userdocs.'/icons/'.$ext.'.gif'){ return $CMSBuilder::Config::http_userdocs.'/icons/'.$ext.'.gif'; }
	
	return $CMSBuilder::Config::http_userdocs.'/icons/default.gif';
}

sub fileman_href
{
	my $o = shift;
	my $fname = shift;
	
	return $o->admin_right_href().'&act=fileman_view&path='.$fname;
}

sub fileman_clearpath
{
	my $o = shift;
	my $path = shift;
	
	if($path)
	{
		path_it($path);
		path_abs($path);
	}
	
	return $path;
}

sub fileman_localdir { $CMSBuilder::Config::path_userdocs.'/icons/' }


1;
