# (с) Леонов П.А., 2005

package plgnAccess;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::Plugin';

use CMSBuilder;

sub plgn_load
{
	unshift @CMSBuilder::DBI::Object::ISA,'plgnAccess::ObjectHook';
	
	cmsb_event_reg('admin_view_additional',\&plgnAccess::ObjectHook::admin_additional);
}


#———————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————————————————————————————————————————————


package plgnAccess::ObjectHook;
use strict qw(subs vars);
use utf8;

import CGI 'param';
use CMSBuilder;
use CMSBuilder::IO;
use plgnUsers;

sub _rpcs {qw/access_chmod access_view/}

our ($AC_READ,$AC_WRITE,$AC_ADD,$AC_CHMOD,,$AC_CHOWN) = (1,2,4,8,16,32);

our %access_types =
(
	$AC_READ => 'Чтение',
	$AC_WRITE => 'Редактирование',
	$AC_ADD => 'Добавление&nbsp;элементов',
	$AC_CHMOD => 'Смена&nbsp;разрешений',
	#$AC_EXEC => 'Доступ&nbsp;ко&nbsp;вложенным',
	$AC_CHOWN => 'Изменять&nbsp;владельца',
);

our %type2bin =
(
	'r' => $AC_READ,
	'w' => $AC_WRITE,
	'a' => $AC_ADD,
	'c' => $AC_CHMOD,
	#'x' => $AC_EXEC,
	'o' => $AC_CHOWN,
);


#———————————————————————————— Методы поддерживающие RPC ————————————————————————

sub access_chmod
{
	my $o = shift;
	my $r = shift;
	
	my $chact = $r->{'chact'};
	
	unless($o->access('c')){ $o->err_add('У Вас нет прав менять разрешения этому элементу.'); return; }
	
	if($chact eq 'edit')
	{
		my $old_code = $o->{'_access_code'};
		
		$o->access_edit();
		
		$o->access_clear();
		$o->access('r');
		
		if($o->{'_access_code'} ne $old_code){ $sess->{'admin_refresh_left'} = 1; }
		
		if($r->{'wdo'} eq 'ok'){ $o->{'_do_list'} = 1; return; }
	}
	
	if($chact eq 'addlist'){ $o->access_add_list(); return; }
	if($chact eq 'add'){ $r->{'sindex'} = $o->access_add($r->{'memb'}) - 1; }
	if($chact eq 'del'){ $o->access_del($r->{'memb'}); }
	
	$o->{'_admin_call'} = 'access_view';
}


#————————————————————————————— Интерфейс пользователя ——————————————————————————

sub admin_cmenu_for_self
{
	my $o = shift;
	my $code;
	
	if($o->access('c'))
	{
		$code .= 'elem_add(JMIHref("Разрешения...","right.ehtml?url='.$o->myurl().'&act=access_chmod"));';
	}
	
	return $code . $o->CMSBuilder::DBI::Object::OAdmin::admin_cmenu_for_self(@_);
}

sub admin_additional
{
	my $o = shift;
	
	print '<tr><td valign="top">Вам&nbsp;разрешено:</td><td valign="top">',$o->access_print(),'</td></tr>';
}


#—————————————————————— Методы реализации разделения доступа ———————————————————

sub access_memb_name
{
	my $memb = shift;
	
	if($memb eq 'all'){ return 'Все'; }
	if($memb eq 'owner'){ return 'Владелец'; }
	
	return cmsb_url($memb)->name();
}

sub access_add
{
	my $o = shift;
	my $m = shift;
	my $code = shift;
	my($res,$sth);
	
	unless(access_memb_name($m)){ $o->err_add('Неверно указан элемент.'); return; }
	
	$sth = $CMSBuilder::DBI::dbh->prepare('SELECT ID FROM `access` WHERE memb = ? AND url = ?');
	$sth->execute($m,$o->myurl());
	if($sth->fetchrow_hashref()){ $o->err_add('Такой элемент уже есть.'); return; }
	
	unless($code)
	{
		if($m eq 'all'){ $code = $o->{'_access_code'} }
		elsif($m eq 'owner' and $o->owner->myurl eq $user->myurl){ $code = $o->{'_access_code'} }
		elsif($m eq $user->myurl()){ $code = $o->{'_access_code'} }
		elsif($m eq $group->myurl()){ $code = $o->{'_access_code'} }
	}
	
	$sth = $CMSBuilder::DBI::dbh->prepare('INSERT INTO `access` (url,memb,code) VALUES (?,?,?)');
	$sth->execute($o->myurl(),$m,$code || 0);
	
	$sth = $CMSBuilder::DBI::dbh->prepare('SELECT count(memb) FROM `access` WHERE url = ?');
	$sth->execute($o->myurl());
	($res) = $sth->fetchrow_array();
	return $res;
}

sub access_del
{
	my $o = shift;
	my $m = shift;
	my($res,$str,$have);
	
	unless(access_memb_name($m)){ $o->err_add('Неверно указан элемент.'); return; }
	
	$have = 0;
	$str = $CMSBuilder::DBI::dbh->prepare('SELECT ID FROM `access` WHERE memb = ? AND url = ?');
	$str->execute($m,$o->myurl());
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ $have = 1; }
	if(!$have){ $o->err_add('Такого элемента нет.'); return; }
	
	$str = $CMSBuilder::DBI::dbh->prepare('DELETE FROM `access` WHERE url = ? AND memb = ?');
	$str->execute($o->myurl(),$m);
}

sub access_add_list
{
	my $o = shift;
	my($res,$str,%membs,$tg,$tu,$to,$count);
	
	$str = $CMSBuilder::DBI::dbh->prepare('SELECT memb,code FROM `access` WHERE url = ?');
	$str->execute($o->myurl());
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ $membs{$res->{'memb'}} = 1; }
	
	print
	'
	<fieldset><legend>Добавление разрешений для элемента: ',$o->admin_name(),'</legend>
	<p><b>Специальные:</b>
	<blockquote>
	';
	
	$count = 0;
	unless($membs{'all'}){ print '<a href="?url=',$o->myurl(),'&act=access_chmod&chact=add&memb=all">Все</a><br>'; $count++; }
	unless($membs{'owner'}){ print '<a href="?url=',$o->myurl(),'&act=access_chmod&chact=add&memb=owner">Владелец</a> (сейчас: ',$o->owner->admin_name(),')<br>'; $count++; }
	unless($count){ print 'Нет элементов для отображения.'; }
	
	print
	'
	</blockquote></p>
	<hr>
	<p><b>Группы:</b>
	<blockquote>
	';
	
	$count = 0;
	for $tg (UserGroup->sel_where(' 1 '))
	{
		unless($membs{$tg->myurl()}){ print $tg->admin_name('?url='.$o->myurl().'&act=access_chmod&chact=add&memb='.$tg->myurl() ),'<br>'; $count++; }
	}
	if(!$count){ print 'Нет групп для отображения.'; }
	
	print
	'
	</blockquote></p>
	<p><b>Пользователи:</b>
	<blockquote>
	';
	
	$count = 0;
	for $tu (map {$_->sel_where(' 1 ')} user_classes())
	{
		unless($membs{$tu->myurl()}){ print $tu->admin_name('?url='.$o->myurl().'&act=access_chmod&chact=add&memb='.$tu->myurl() ),'<br>'; $count++; }
	}
	
	unless($count){ print 'Нет пользователей для отображения.'; }
	
	print '</fieldset>';
}

sub access_view
{
	my $o = shift;
	my $r = shift;
	
	my($res,$sth,$tm,$type,@all,$i);
	
	$sth = $CMSBuilder::DBI::dbh->prepare('SELECT memb,code FROM `access` WHERE url = ?');
	$sth->execute($o->myurl());
	while( $res = $sth->fetchrow_hashref('NAME_lc') ){ push(@all, $res); }
	
	#CMSBuilder::IO::GUI::print_info($o);
	
	if($#all < 0){ print '<center>Для этого элемента разрешения не определены.<br><br><a href="?url=',$o->myurl(),'&act=access_chmod&chact=addlist">Добавить пользователя/группу...</a></center>'; return; }
	
	print
	'
	<center><fieldset style="width:350px"><legend align="center">Изменение разрешений для элемента: ',$o->admin_name(),'</legend>
	<p>
	<select size="5" id="uarea" onchange="SelMemb()" class="ainput" style="width: 300px">
	';
	
	for $res ( @all ){ print '<option value="',$res->{'memb'},'">&nbsp;&nbsp;',access_memb_name($res->{'memb'}),'</option>'; }
	
	print
	'
	</select>
	<table style="width: 290px"><tr><td align="left"><img alt="Удалить пользователя/группу из списка" src="img/x.gif" onclick="if(changed){ alert(\'Сначала сохраните!\'); return; } DelMemb()"></td><td align="right"><a onclick="if(changed){ alert(\'Сначала сохраните!\'); return false}" href="?url=',$o->myurl(),'&act=access_chmod&chact=addlist">Добавить пользователя/группу...</a></td></tr></table>
	</p>
	';
	
	print '
	<form method="get" action="?" id="access_form">
	<input type="hidden" name="act" value="access_chmod">
	<input type="hidden" name="chact" value="edit">
	<input type="hidden" name="sindex" value="0" id="sindex">
	<input type="hidden" name="url" value="',$o->myurl(),'">
	<input type="hidden" name="wdo" value="permit">
	';
	
	for $res ( @all )
	{
		print
		'
		<div style="display: none" id="div_',$res->{'memb'},'">
		<fieldset align="center" style="width:300px"><legend align="center">',access_memb_name($res->{'memb'}),':</legend>
		<table width="100%">
		';
		
		for $type (keys(%access_types))
		{
			print '<tr><td>&nbsp;&nbsp;<b>',$access_types{$type},'</b></td>';
			print '<td>&nbsp;<input onclick="OnCh()" type="checkbox" ';
			if( ($res->{'code'}*1) & $type ){ print ' checked '; };
			print ' name="',$res->{'memb'},'_',$type,'"></td></tr>';
		}
		
		print '</table></fieldset></div>';
	}
	
	#<p><input type="submit" name="submit_ok" value="OK">&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Применить"></p>
	
	print
	'
	<p><button type="submit" onclick="wdo.value=\'ok\'">OK</button>&nbsp;&nbsp;&nbsp;<button type="submit">Применить</button></p>
	</form></fieldset></center>
	';
	
	
	print '
	
	<script language="JavaScript">
	var div_ids = new Array;
	var div_sel;
	var changed = 0;
	
	';
	
	$i = 0;
	for $res ( @all ){ print 'div_ids[',$i,'] = div_',$res->{'memb'},';'; $i++; }
	
	print '
	
	function OnCh(){ changed = 1; }
	
	function SelMemb()
	{
		if(div_sel) div_sel.style.display = "none";
		div_sel = div_ids[uarea.selectedIndex];
		if(div_sel) div_sel.style.display = "block";
		access_form.sindex.value = uarea.selectedIndex;
	}
	
	function DelMemb()
	{
		if(!doDel()) return;
		var memb = uarea.item(uarea.selectedIndex).value;
		
		location.href = "?url=',$o->myurl(),'&act=access_chmod&chact=del&memb=" + memb;
	}
	
	uarea.selectedIndex = '.($r->{'sindex'} || 0).';
	SelMemb()
	</script>
	
	';
}

sub access_edit
{
	my $o = shift;
	my($res,$str,@all,$box,%membs,$type,$m);
	
	$str = $CMSBuilder::DBI::dbh->prepare('SELECT memb,code FROM `access` WHERE url = ?');
	$str->execute($o->myurl());
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ push(@all, $res); }
	
	if($#all < 0){ $o->err_add('Перед редактированием не было добавлено ни одного пользователя.'); return; }
	
	for $res ( @all )
	{
		$membs{$res->{'memb'}} = 0;
		for $type (keys(%access_types))
		{
			$box = param($res->{'memb'}.'_'.$type);
			#print $membs{$res->{'memb'}} ,'|', ($box?$type:0), '=', $membs{$res->{'memb'}} | ($box?$type:0),'<br>';
			$membs{$res->{'memb'}} |= ($box?$type:0);
		}
	}
	
	$str = $CMSBuilder::DBI::dbh->prepare('UPDATE `access` SET code = ? WHERE memb = ? AND url = ?');
	
	for $m (keys(%membs)){ $str->execute($membs{$m},$m,$o->myurl()); }
	
	$o->notice_add('Разрешения успешно изменены.');
}

sub access_set
{
	my $o = shift;
	my $code = shift;
	
	$o->{'_access_code'} = 0;
	
	map { $o->{'_access_code'} |= $type2bin{$_} } split(//,$code);
}

sub access_clear
{
	my $o = shift;
	
	my $old_code = $o->{'_access_code'};
	delete $o->{'_access_code'};
	return $old_code;
}

sub access_get
{
	my $o = shift;
	if(exists $o->{'_access_code'}){ return; }
	my($type,$code,$papa);
	
	if($group->{'root'})
	{
		$o->{'_access_code'} = ~0;
		return;
	}
	
	$o->access_load();
}

sub access_load
{
	my $o = shift;
	my (%membs,$str,$res,$g,$u);
	
	$o->{'_access_code'} = 0;
	
	($g,$u) = ($group->myurl(),$user->myurl());
	
	$str = $CMSBuilder::DBI::dbh->prepare('SELECT memb,code FROM `access` WHERE url = ? and memb in (?,?,?,?)');
	$str->execute($o->myurl(),'all','owner',$g,$u);
	
	
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ $membs{$res->{'memb'}} = $res->{'code'}; }
	
	if(exists $membs{$u}){ $o->{'_access_code'} = $membs{$u}; return; }
	if(exists $membs{'owner'} and $user->myurl eq $o->owner->myurl){ $o->{'_access_code'} = $membs{'owner'}; return; }
	
	if(exists $membs{$g}){ $o->{'_access_code'} = $membs{$g}; return; }
	if(exists $membs{'all'}){ $o->{'_access_code'} = $membs{'all'}; return; }
	
	if(my $papa = $o->papa())
	{
		$papa->access_get();
		$o->{'_access_code'} = $papa->{'_access_code'};
	}
	else
	{
		$o->{'_access_code'} = ~0;
		return;
	}
	
	return;
}

sub access_bin
{
	my $o = shift;
	my $bin = shift;
	
	unless($CMSBuilder::Config::access_on_e){ return 1; }
	
	$o->access_get();
	
	return $o->{'_access_code'}&$bin?1:0;
}

sub access
{
	my $o = shift;
	my $type = shift;
	
	return $o->access_bin($type2bin{$type});
}

sub access_print
{
	my $o = shift;
	my $type;
	my @out;
	
	for $type (keys %access_types)
	{
		if($o->access_bin($type)){ push(@out,$access_types{$type}) }
	}
	
	if($#out < 0){ return 'Нет разрешений.' }
	return join(', ',@out).'.';
}


1;