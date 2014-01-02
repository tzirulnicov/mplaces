# (с) Леонов П.А., 2005

package CMSBuilder::DBI::Object::OAdmin;
use strict qw(subs vars);
use utf8;

sub _rpcs {qw/admin_edit admin_path_html admin_path_js admin_left_tree_data/}
sub _admin_right_panels {qw(admin_right_props admin_view_additional)}

#-------------------------------------------------------------------------------


use CMSBuilder::Utils;
use plgnUsers;

sub admin_view
{
	my $o = shift;
	map { $o->$_(@_); } $o->admin_right_panels;
}

sub admin_right_panels
{
	my $c = ref($_[0]) || $_[0];
	my $buff = $c.'::_admin_right_panels';
	if($$buff){ return @$$buff; }
	my @t = varr($c,'_admin_right_panels',1);
	my @res;
	for my $v (reverse @t)
	{
		if($v eq '-'){ last; }
		unshift(@res,$v)
	}
	
	my $h = {};
	@res = grep {$h->{$_}?0:($h->{$_} = 1); } @res;
	$$buff = [@res];
	return @$$buff;
}

sub admin_view_right
{
	my $o = shift;
	my $c = ref($o) || $o;
	
	my $act = CGI::param('act') || 'default';
	
	$o->{'_do_list'} = 0;
	
	my $r = decode_utf8_hashref({CGI->Vars()});
	$o->rpc_exec($act,$r);
	
	$o->save() if $act ne 'default';
	CMSBuilder::IO::GUI::print_info($o);
	if($o->{'_do_list'}){ $o->admin_view($r); }
	if($o->{'_admin_call'})
	{
		$o->rpc_exec($o->{'_admin_call'},$r);
		$o->{'_admin_call'} = '';
	}
}

sub admin_view_left
{
	my $o = shift;
	unless($CMSBuilder::Config::have_left_tree)
	{
		print '<br><br><br><center>Дерево елементов отключено.</center>';
		return;
	}
	my $tree = $o->admin_left_tree();
	$tree->{'-root'} = 1;
	
	print '<div class="togpanell">'; #<div class="head">Структура</div>
	
	print '<div class="content">'.
		CMSBuilder::IO::GUI::tree_build($tree); #, -openroot => 1

if ($o->myurl=~/modHotelQuick/){
   my $dbh=$CMSBuilder::DBI::dbh->prepare('SELECT ID from dbo_Hotel where 
	rekomenduem=1');
   $dbh->execute();
   my $row;
   while ($row=$dbh->fetchrow_hashref){
      $row->{o}=CMSBuilder::cmsb_url('Hotel'.$row->{ID});
      $row->{tree}=$row->{o}->admin_left_tree();
      print CMSBuilder::IO::GUI::tree_build($row->{tree});
   }
}
	print '</div></div>';
}

sub admin_left_tree
{
	my $o = shift;
	
	return {-name => $o->admin_name(), -id => $o->myurl, -myurl => $o->myurl};
}

sub admin_arrayline { }

sub admin_hicon
{
	my $o = shift;
	
	return( $o->{'SHCUT'}?'icons/shcut.gif':'' );
}

sub admin_toolbar_icon
{
	my $o = shift;
	return '<a href="'.$o->admin_left_href().'" title="'.$o->name().'" onclick="return selectLeftPanel(\''.$o->myurl().'_tbicon\')" id="'.$o->myurl().'_tbicon" target="admin_left"><img src="'.$o->admin_icon().'" /></a>';
}

sub admin_name
{
	my $o = shift;
	my $href = shift || $o->admin_right_href();
	my $targ = shift || 'admin_right';
	
	return CMSBuilder::IO::GUI::admin_name_ex
	(
		$o->admin_name_ex_opts(),
		-myobject => $o,
		-href => $href,
		-target => $targ
	);
}

sub admin_name_ex_opts
{
	my $o = shift;
	
	my $myurl = $o->myurl();
	
	my $name = $o->name();
	$name =~ s/\<.+?\>//sg;
	unless($name){ $name = $o->cname().' без имени'; }
	
	return
	(
		-name => $name,
		-href => $o->admin_right_href(),
		-icon => $o->admin_icon(),
		-hicon => $o->admin_hicon(),
		-selid => 'id_'.$myurl,
		-props =>
		{
			#'cmenu' => $myurl,
			'myurl' => $myurl,
			'papa' => $o->papa(),
			'num' => $o->enum(),
			
			'cms_ondragover' => 'this.className=\'object_dragover\'',
			'ondragleave' => 'this.className=\'\'',
			'ondragstart' => 'return CMS_GlobalDragStart(this)',
			'ondragover' => 'return CMS_GlobalDragOver(this)',
			'ondrop' => 'return CMS_GlobalDrop(this)',
			'oncontextmenu' => 'return OnContext(\''.$myurl.'\',event)',
		}
	);
}

sub admin_cname
{
	my $o = shift;
	my $name = shift || $o->cname();
	my $href = shift;
	my $targ = shift;
	my $icon = shift || $o->admin_icon();
	
	return CMSBuilder::IO::GUI::admin_name_ex
	(
		-name => $name,
		-href => $href,
		-target => $targ,
		-icon => $icon,
	);
}

sub admin_icon
{
	my $o = shift;
	
	my $fname = ref($o) || $o;
	$fname =~ s/::/_/;
	
	if( $o->have_icon() ){ return ($o->have_icon() eq '1')?'icons/'.$fname.'.gif':$o->have_icon(); }
	return 'icons/default.gif';
}

sub admin_abs_href
{
	my $o = shift;
	return $CMSBuilder::Config::http_adress.$CMSBuilder::Config::http_aroot.'/?url='.$o->myurl();
}

sub admin_right_href
{
	my $o = shift;
	return 'right.ehtml?url='.$o->myurl();
}

sub admin_left_href
{
	my $o = shift;
	return 'left.ehtml?url='.$o->myurl();
}

sub admin_cmenu
{
	my $o = shift;
	unless($o->access('r')){ print 'all_menus["',$o->myurl(),'"] = JMenu();'; return; }
	
	my $code .=
	'
	all_menus["'.$o->myurl().'"] = JMenu();
	with(all_menus["'.$o->myurl().'"]){
	';
	
	my $title = CMSBuilder::IO::GUI::admin_name_ex(-name => $o->name(), -icon => $o->admin_icon());
	$code .= 'elem_add(JTitle("'.escape($title).'"));';
	
	$code .= $o->admin_cmenu_for_self();
	
	if(my $papa = $o->papa())
	{
		$code .= $papa->admin_cmenu_for_son($o);
	}
	
	for my $sub (@{$CMSBuilder::DBI::cmenus{$o->myurl()}},@{$CMSBuilder::DBI::cmenus{ref($o)}},@{$CMSBuilder::DBI::cmenus{'*'}})
	{
		$code .= $o->$sub();
	}
	
	$code .= '}';
	
	print 'all_menus_code["',$o->myurl(),'"] = "',escape($code),'";';
}

sub admin_cmenu_for_self
{
	my $o = shift;
	my $code;
	
	if($o->access('r'))
	{
		$code .= 'elem_add(JMIHref("Открыть","'.$o->admin_right_href().'"));';
	}
	
	return $code;
}

sub admin_cmenu_for_son {}

sub admin_path_html
{
	my $o = shift;
	
	return join(' &gt; ', map { $_->admin_name() } $o->papa_path() );
}

sub admin_path_js
{
	my $o = shift;
	
	for my $to ($o->papa_path())
	{
		print 'parent.admin_left.CMS_SelectLO("id_'.$to->myurl().'");';
		print 'parent.admin_left.CMS_ShowMe_tree("'.$to->myurl().'");';
	}
}

sub admin_edit
{
	my $o = shift;
	my $r = shift;
	
	my $na =
	{
		-keys => [$o->aview('_all')],
		@_
	};
	
	my $p = $o->props();
	
	my ($val,$vt);
	for my $key (@{$na->{'-keys'}})
	{
		do { warn ref($o).': _props{} has no key "'.$key.'"'; next } unless exists $p->{$key};
		$vt = 'CMSBuilder::VType::'.$p->{$key}{'type'};
		$val = $r->{$key};
		unless($group->{'html'} || ${$vt.'::dont_html_filter'}){ $val = HTMLfilter($val); }
		$o->{$key} = $vt->aedit($key,$val,$o,$r);
	}
	
	$o->notice_add( $o->err_cnt()?'Изменения внесены частично.<br>':'Изменения успешно сохранены.<br>' );
}

sub admin_cre
{
	my $o = shift;
	my $where = shift;
	
	my @props = $o->aview();
	
	print
	'
	<fieldset><legend>Создание элемента ',$o->admin_cname(),'</legend>
	<form onkeydown="return QuickSubmit(event, this)" id="main_form" action="?" method="post" enctype="multipart/form-data">
	<div class="padd">
	';
	
	
	$o->admin_props(-where => $where, -action => 'create');
	
	print
	'
	<p align=center>
	<!--<button type="submit">OK</button>
	&nbsp;&nbsp;&nbsp;
	 <button onclick="location.href = \'right.ehtml?url='.$where->myurl().'\'">Отмена</button> 
	&nbsp;&nbsp;&nbsp;-->
	<button type="submit" onclick="wdo.value = \'add\'"><img src="icons/save.gif" /> Создать</button>
	</p>
	</div>
	<input type="hidden" name="act" value="cms_admin_cre">
	<input type="hidden" name="cname" value="',ref($o),'">
	<input type="hidden" name="url" value="',$where->myurl(),'">
	<input type="hidden" name="wdo" value="ok">
	</form>
	</fieldset>
	';
}

sub admin_right_props
{
	my $o = shift;
	
	my @props = $o->aview();
	
	my $dsp = {CGI::cookie('aview_props')}->{'s'} eq '0'?0:1;
	
	print
	'
	<fieldset>
	<legend onmousedown="ShowHide(aview_props,treenode_aview_props)"><span class="objtbl"><img class="ticon" id="treenode_aview_props" src="img/'.($dsp?'minus':'plus').'.gif"><span class="subsel">Свойства элемента',!$o->access('w')?' (только чтение)':'','</span></span></legend>
	<div class="padd" id="aview_props" style="display:'.($dsp?'block':'none').'">
	';
	
	if($o->access('w'))
	{
		print '<form onkeydown="return QuickSubmit(event, this)" id="main_form" id="',$o->myurl(),'_edit_form" action="?" method="post" enctype="multipart/form-data">';
	}
	else
	{
		print '<form onmousedown="return false;" onclick="return false;" disabled="true">';
	}
	
	print
	'
	<table width="100%">
	<tr><td align="center">
	';
	
	$o->admin_props();
	
	if(@props){ $o->admin_view_buttonsline(); }
	
	print
	'
	</td></tr></table>
	<input type="hidden" name="act" value="cms_admin_edit">
	<input type="hidden" name="url" value="',$o->myurl(),'">
	</form>
	</div>
	</fieldset>
	';
}

sub admin_view_buttonsline
{
	my $o = shift;
	
	print '<table class="edit_buttons"><tr><td width="50">';
	
	#выведем ссылочку на предыдущий объект, если он, конечно, существует
	print '<a href="' . $o->papa->elem($o->enum - 1)->admin_right_href . '" title="Открыть предыдущий элемент…">&larr;</a>'
		if $o->enum > 1;
	
	print '</td><td>';
	
	
	if($o->access('w') && keys %{$o->props()})
	{
		print
		'
			<div class="ok_save">
				<!-- <button title="Отменить изменения" type="reset">Отмена</button> -->
				<button type="submit" title="Сохранить изменения"><img src="icons/save.gif" /> Сохранить</button>
			</div>
		';
	}
	else
	{
		print '&nbsp;';
	}
	
	print '</td><td align="right" width="50">';
	
	#выведем ссылочку на следующий объект, если он, конечно, существует
	print '<a href="' . $o->papa->elem($o->enum + 1)->admin_right_href . '" title="Открыть следующий элемент…">&rarr;</a>'
		if $o->papa && $o->enum < $o->papa->len;
	
	print '</td></tr></table>';
}

sub admin_view_additional
{
	my $o = shift;
	
	my $dsp = {CGI::cookie('aview_additional')}->{'s'};
	
	print
	'
	<fieldset>
	<legend onmousedown="ShowHide(aview_additional,treenode_aview_additional)"><span class="objtbl"><img class="ticon" id="treenode_aview_additional" src="img/'.($dsp?'minus':'plus').'.gif"><span class="subsel">Дополнительно</span></span></legend>
	<div class="padd" id="aview_additional" style="display:'.($dsp?'block':'none').'">
	
	<table>
	<tr><td valign="top">Создан:</td><td>',toDateTimeStr($o->{'CTS'}),'</td></tr>
	<tr><td valign="top">Изменён:</td><td>',toDateTimeStr($o->{'ATS'}),'</td></tr>
	';
	
	$o->event_call('admin_view_additional');
	
	print
	'
	</table>
	</div>
	
	</fieldset>
	';
}

sub admin_props
{
	my $o = shift;
	my $na =
	{
		-keys => [$o->aview()],
		-action => 'view',
		@_
	};
	
	my $p = $o->props();
	
	unless( @{$na->{-keys}} ){ print '<p align="center">Нет доступных для редактирования свойств.</p>'; return 0; }
	print '<table class="props_table">';
	
	for my $key (@{$na->{-keys}})
	{
		do { warn ref($o).': _props{} has no key "'.$key.'"'; next } unless exists $p->{$key};
		
		my $vt = 'CMSBuilder::VType::'.$p->{$key}{'type'};
		
		if(${$vt.'::admin_own_html'})
		{
			my $val = $na->{-action} eq 'create' ? $p->{$key}{'default'} : $o->{$key};
			print $vt->aview( $key, $val, $o );
		}
		else
		{
			print
			'
			<tr>
			<td valign="top" width="20%" align="left"><label for="',$key,'">',$p->{$key}{'name'},'</label>:</td>
			<td width="80%" align="left" valign="middle">
			',$vt->aview($key,$o->{$key},$o),'
			</td></tr>
			';
		}
	}
	
	print '</table>';
	
	return 1;
}


#———————————————————————————— Методы отображения ошибок ————————————————————————

sub err_add
{
	my $o = shift;
	my $str = shift;
	
	if(!$o->{'_errors'}){ $o->{'_errors'} = (); }
	
	push(@{ $o->{'_errors'} }, $str);
}

sub err_print
{
	my $o = shift;
	my $str;
	
	print join('<br>',@{ $o->{'_errors'} });
}

sub err_cnt
{
	my $o = shift;
	
	return $#{ $o->{'_errors'} } + 1;
}

sub err_strs
{
	return @{ $_[0]->{'_errors'} };
}


#—————————————————————————— Методы отображения сообщений ———————————————————————

sub notice_add
{
	my $o = shift;
	my $str = shift;
	
	push(@{$o->{'_notices'}}, $str);
}

sub notice_print
{
	my $o = shift;
	my $str;
	print join('<br>',@{ $o->{'_notices'} });
}

sub notice_cnt
{
	my $o = shift;
	
	return $#{ $o->{'_notices'} } + 1;
}

sub notice_strs
{
	return @{ $_[0]->{'_notices'} };
}

1;
