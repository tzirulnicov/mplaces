# (с) Леонов П.А., 2005

package CMSFront;
use strict qw(subs vars);
use utf8;

our @ISA = ('CMSBuilder::Plugin');

import CGI 'param';
use CMSBuilder;
use CMSBuilder::IO::GUI;
use CMSBuilder::Fileman;
use plgnUsers;
use CMSBuilder::IO;

sub servername
{
	print $ENV{'SERVER_NAME'};
}

sub user_xinfo
{
	my $name = shift;
	
	
	if($name eq 'left_td_width')
	{
		my %cook = CGI::cookie('left_td');
		print $cook{'width'} || $CMSBuilder::Config::admin_left_width;
	}
	
	elsif($name eq 'main_menu')
	{
		print '<span class="toolpanel">';
		
		if ($group->{'cpanel'})
		{
			print '<a title="Обновить структуру" href="',modControlPanel->new(1)->admin_right_href(),'&act=cpanel_table_fix" target="admin_right"><img src="icons/table.gif" /></a>';
			
			print '<a title="Удалить все таблицы" onclick="return doDel(\'все таблицы\')" href="',modControlPanel->new(1)->admin_right_href(),'&act=cpanel_dropall" target="admin_right"><img src="icons/stop.gif" /></a>';
			
			print '<img src="img/nx.gif" />';
		}
		
		print '<a title="Поиск" href="' . modAdminSearch->new(1)->admin_right_href() . '" target="admin_right"><img src="icons/modAdminSearch.gif" /></a>';
		
		print '<img src="img/nx.gif" />';
		
		print '<a title="Мои документы"   onclick="return selectLeftPanel(\'admin_docs_icon\')" id="admin_docs_icon" href="fileman.ehtml"><img src="icons/mydocs.gif" /></a>' if $group->{'files'};
		
		print modControlPanel->new(1)->admin_toolbar_icon() if $group->{'cpanel'};
		
		print '<a title="Выбранный модуль" onclick="return selectLeftPanel(\'admin_modules_icon\')" id="admin_modules_icon" href="about:blank"><img src="icons/folders.gif" /></a>';
		
		print '</span>';
	}
	
	elsif($name eq 'name')
	{
		my $uname;
		
		if($CMSBuilder::Config::access_on_e)
		{
			$uname = $group->name().' / '.$user->name();
		}
		else
		{
			$uname = 'Монопольный режим';
		}
		
		print $uname;
	}
	
	elsif($name eq 'exit')
	{
		unless($CMSBuilder::Config::access_on_e){ return; }
		if(is_guest($user))
		{
			print '<a href="login.ehtml">Вход</a>';
		}
		else
		{
			print '<a href="login.ehtml?act=out">Выход</a>';
		}
	}
}

sub modules
{
	unless(modRoot->table_have())
	{
		print '<br><center>Структура базы не установлена!</center>
		<script language="JavaScript">
			parent.admin_right.location.href = "right.ehtml?url=modControlPanel1";
			parent.admin_left.location.href = "left.ehtml?url=modControlPanel1";
		</script>
		';
		
		return;
	}
	
	my $mr = cmsb_url('modRoot1');
	return unless $mr;
	my @mods = $mr->get_all();
	
	for my $mod (@mods)
	{
		my %opts = $mod->admin_name_ex_opts();
		$opts{'-props'}{'onclick'} = 'SelectMod(id_'.$mod->myurl().',\''.$mod->admin_left_href().'\',\''.$mod->admin_right_href().'\'); return false;';
		print '<div>',admin_name_ex(%opts),'</div>';
	}
	
	if(@mods)
	{
		my $sm = $mods[0];
		my $so = $sm;
		
		if(my $to = cmsb_url(param('url')))
		{
			$sm = $to->root;
			$so = $to;
			#print $to->admin_abs_href();
		}
		
		print
		'
			<script language="JavaScript">
				SelectMod(id_',$sm->myurl(),',"',$sm->admin_left_href(),'","',$so->admin_right_href(),'");
			</script>
		';
	}
	else
	{
		print '<br><center>Нет модулей для отображения.</center>';
	}
}

sub right
{
	my $url = param('url');
	my $to = cmsb_url($url) || return;
	
	return $to->admin_view_right();
}

sub left
{
	my $url = param('url');
	my $to = cmsb_url($url) || return;
	
	return $to->admin_view_left();
}

sub left_head
{
	my $url = param('url');
	my $to = cmsb_url($url) || return;
	
	print $to->name();
}

sub jscript
{
	if($sess->{'admin_refresh_left'} and $CMSBuilder::Config::have_left_frame and $CMSBuilder::Config::have_left_tree)
	{
		print 'if(CMS_HaveParent()) parent.frames.admin_left.document.location.href = parent.frames.admin_left.document.location.href;';
	}
	
	delete $sess->{'admin_refresh_left'};
	
	my $to = cmsb_url(param('url'));
	
	print
	'
	function SafeRefresh()
	{
		',$to?('document.location.href = "',$to->admin_right_href(),'";'):'','
	}
	';
	
	cmenus();
	dnd();
}

sub path_html
{
	if(my $to = cmsb_url(param('url'))){ print $to->admin_path_html({CGI->Vars()}); }
}

sub path_js
{
	print '
	function CMS_admin_path()
	{
		if(CMS_HaveParent() && parent.admin_left.CMS_SelectLO)
		{
	';
	
	if(my $to = cmsb_url(param('url'))){ $to->admin_path_js({CGI->Vars()}); }
	
	print '
		}
	}
	CMS_admin_path();
	';
}

sub dnd
{
	print "var g_add_classes = new Object;\n\n";
	
	for my $tc (cmsb_classes())
	{
		print 'g_add_classes["'.$tc.'"] = [';
		
		if($tc->can('elem_can_add'))
		{
			print '"',join('","',grep {$tc->elem_can_add($_)} cmsb_classes()),'"';
		}
		
		print "]\n";
	}
}

sub rpccmenu
{
	my $to = cmsb_url(param('url')) || return;
	
	$to->admin_cmenu();
	
	print
	'
	
	if(all_menus_code["'.$to->myurl().'"] != undefined)
		ShowCMenu("'.$to->myurl().'",'.param('mx').','.param('my').');
	';
}

sub cmenus
{
	return;
	for my $to (values(%CMSBuilder::dbo_cache))
	{
		$to->admin_cmenu();
		print "\n\n";
	}
}

sub access
{
	unless($group->{'cms'}){ CMSBuilder::IO::err403(); }
}


1;