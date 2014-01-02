# (с) Леонов П.А., 2005

package CMSBuilder::DBI::Array::AAdmin;
use strict qw(subs vars);
use utf8;

sub _admin_right_panels {qw(admin_array_view)}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;
use CMSBuilder::IO;

sub admin_cmenu_for_self
{
	my $o = shift;
	
	my $code = $o->CMSBuilder::DBI::Object::admin_cmenu_for_self(@_);
	
	if($o->access('w'))
	{
		$code .=
		'
		
		smenu = JMenu();
		with(smenu)
		{
			elem_add(JTitle("Сортировать"));
		';
		if($o->len)
		{
			$code .=
			'
			elem_add(JMIHref("Обратить","right.ehtml?url=' . $o->myurl . '&act=cms_array_sort&by=reverse"));
			/*elem_add(JMIHref("По имени","right.ehtml?url=' . $o->myurl . '&act=cms_array_sort&by=name"));
			elem_add(JMIHref("По типу","right.ehtml?url=' . $o->myurl . '&act=cms_array_sort&by=class"));
			elem_add(JMIHref("Создан","right.ehtml?url=' . $o->myurl . '&act=cms_array_sort&by=cts"));
			elem_add(JMIHref("Изменён","right.ehtml?url=' . $o->myurl . '&act=cms_array_sort&by=ats"));
			elem_add(JHR());*/
			';
		}
		$code .=
		'
			/*elem_add(JMIHref("По ID","right.ehtml?url=' . $o->myurl . '&act=cms_array_sort&by=id"));
			elem_add(JMIHref("Починить","right.ehtml?url=' . $o->myurl . '&act=cms_array_sort&by=num"));*/
		}
		smenu_i = elem_add(JMISubMenu("Сортировать",smenu));
		';

		$code .= 'elem_add(JMIConfirm("Очистить","right.ehtml?url=' . $o->myurl . '&act=cms_array_clear","","Удалить ' . $o->len . ' элементов?"));' if $o->len;
	}
	
	return $code;
}

sub admin_cmenu_for_son
{
	my $o = shift;
	my $son = shift;
	my ($code,$son_name);
	
	if($o->access('w'))
	{
		$code .=
		'
		elem_add(JHR());
		elem_add(JMIHref("Копия...", "right.ehtml?url=' . $o->myurl . '&act=cms_array_elem_mkcopy&turl=' . $son->myurl . '"));
		elem_add(JMIHref("Ярлык...", "right.ehtml?url=' . $o->myurl . '&act=cms_array_elem_mkshcut&turl=' . $son->myurl . '"));
		';
		
		if($son->enum)
		{
$son_name=$son->name;
$son_name=~s/"/\\\"/g;
			$code .=
			'
			elem_add(JMIHref("Переместить...", "right.ehtml?url=' . $o->myurl . '&act=cms_array_elem_move2&enum=' . $son->enum . '"));
			elem_add(JMIConfirm("Удалить", "right.ehtml?url=' . $o->myurl . '&act=cms_array_elem_delete&enum=' . $son->enum . '","","Удалить \"' . $son_name . '\"?"));
			';
		}
	}
	
	return $code;
}

sub admin_left_tree
{
	my $o = shift;
	
	my %ret = %{$o->CMSBuilder::DBI::Object::admin_left_tree(@_)};
	
	if($o->{'SHCUT'}){ return {%ret}; }
	
	return {%ret, -elems => $o->len ? [{-name => 'Загрузка…'}] : []};
}

sub admin_left_tree_data
{
	my $o = shift;
	
	my %ret = %{$o->CMSBuilder::DBI::Object::admin_left_tree(@_)};
	
	if($o->{'SHCUT'}){ return {%ret}; }
	
	my @elems;
	
	for my $to (sort {$a->name cmp $b->name} $o->get_interval(1, $CMSBuilder::Config::admin_max_left))
	{
		next if $to->dont_list_me;
		push @elems, $to->admin_left_tree;
	
	
	if($o->len > $CMSBuilder::Config::admin_max_left)
	{
		push @elems, {-name => '<font style="cursor: pointer" onclick="alert(\'Количество элементов, отображаемых в левой панели, ограничено. Вы можете продолжать добавлять элементы. Они будут доступны в правой панели — по '.($o->array_onpage()||$CMSBuilder::Config::array_def_on_page).' на странице.\')" color="#ff7300" size=1>&nbsp;Элементы перечислены не полностью...</font>', -id => 'to_many'};
	}
	}
	
	#map { print CMSBuilder::IO::GUI::tree_build($_) } @elems;
	
	print CMSBuilder::IO::GUI::tree_build({%ret, -elems => \@elems}, -flat => 1,);
}

sub admin_array_view
{
	my $o = shift;
	my $r = shift;
	
	unless($o->access('r')){ return; }
	
	my $page = $o->admin_array_selectedpage($r);
	
	my $dsp = {CGI::cookie('aview_elems')}->{'s'} eq '0'?0:1;
	
	print
	'
	<fieldset>
	<legend onmousedown="ShowHide(aview_elems,treenode_aview_elems)"><span class="objtbl"><img class="ticon" id="treenode_aview_elems" src="img/'.($dsp?'minus':'plus').'.gif"><span class="subsel">Список вложенных элементов</span></span></legend>
	<div class="padd" id="aview_elems" style="display:'.($dsp?'block':'none').'">
	';
	
	print '<div class="add-list">';
	$o->admin_add_list();
	print '</div>';
	
	my @pagea;
if ($o->myurl=~/modHotelQuick/){
   my $row;
   my $ids;
   if ($r->{ids}){
      foreach my $k(split(',',$r->{ids})){
	next if !$k;
	$CMSBuilder::DBI::dbh->do('UPDATE dbo_Hotel set num='.
		$r->{"num".$k}.' where ID='.$k);
      }
      print "Порядок следования элементов успешно изменён";
   }
   print '<form action="/admin/right.ehtml"><table class="admin_array_view"><tr><td>&nbsp;</td></tr>';
   my $dbh=$CMSBuilder::DBI::dbh->prepare('SELECT ID,name,num from dbo_Hotel where
        rekomenduem=1');
   $dbh->execute();
   while ($row=$dbh->fetchrow_hashref){
#      push(@pagea,{$row->{ID},$row->{name}});
Encode::_utf8_on($row->{name});
$ids.=$row->{ID}.',';
print '<tr><td>';
print '<table><tr><td><input type="text" size=2 maxlength=3 name="num'.$row->{ID}.'" value="'.$row->{num}.'"></td><td><table><tr><td><a target="admin_right" 
	href="right.ehtml?url=Hotel'.$row->{ID}.'">
	<img src="icons/default.gif"><span class="subsel">'.$row->{name}.'</span></a></td></tr></table></td>';

                        print '</tr></table></td></tr>';
                        print "\n";
}
                print '</table><input type="hidden" name="ids" value="'.$ids.'">
		<input type="hidden" name="url" value="'.$o->myurl.'">
		<p><input type="submit" value="Save"></form>';
} else {
   @pagea = $o->get_page($page);
	
	if(@pagea)
	{
		print '<table class="admin_array_view"><tr><td myurl="' . $o->myurl . '" elempos="' . ( $pagea[0]->enum - 1) . '" cms_ondragover="this.className = \'dragline\';" ondragover="return CMS_GlobalDragOver(this)" ondrop="return CMS_GlobalDrop(this)" ondragleave="this.className = \'\';">&nbsp;</td></tr>';
		
		for my $e (@pagea)
		{
			unless($o->access('r')){ next; }
			
			print '<tr><td myurl="' . $o->myurl . '" elempos="' . $e->enum . '" cms_ondragover="this.className = \'dragline\';" ondragover="return CMS_GlobalDragOver(this)" ondrop="return CMS_GlobalDrop(this)" ondragleave="this.className = \'\';">';
			
			$e->admin_arrayline($o);
			
			print '<table><tr><td>'.$e->admin_name.'</td>';
			if (ref($e) eq 'CatWareSimple'){
				#map { print '<td><a href="' . $_->admin_right_href() . '" style="color: red; font-size: 9px">' . $_->name . '&nbsp;</a></td>' } grep { $e->checked($_->myurl) } modMarket->new(1)->get_all;
			        #!!!
				#map { print '<td>&nbsp;</td><td><form action="' . $_->admin_right_href() .'" style="top:-10px"><input type="submit" style="color: red; font-size: 9px;height:15px" value="Добавить в ' . $_->name .'"></form></td><td>&nbsp;</td>' } grep { !$e->checked($_->myurl) } modMarket->new(1)->get_all;
				print '<td><span style="color:black;font-size:9px">'.$e->{'price'}.'p.</span></td>';
			}
			
			print '</tr></table></td></tr>';
			print "\n";
		}
		
		print '</table>';
	}
	else
	{
		print '<p align="center">Нет элементов.</p>';
	}
}	
	$o->admin_array_pagesline($r);
	
	print '</fieldset>';
}

sub admin_calc_pageline_pages
{
	my $o = shift;
	my $page = shift;
	
	my $w = $CMSBuilder::Config::array_pages_width;
	my @pages;
	
	push @pages, 0;
	
	if ($page > $w + 1)
	{
		push @pages, '...';
	}
	
	push @pages, ($page - $w < 1 ? 1 : $page - $w) .. ($page + $w > $o->pages - 2 ? $o->pages - 2 : $page + $w);
	
	if ($page < $o->pages - 2 - $w)
	{
		push @pages, '...';
	}
	
	push @pages, $o->pages - 1;
	
	return @pages;
}

sub admin_array_pagesline
{
	my $o = shift;
	my $r = shift;
	
	return if $o->pages < 2;
	
	my $page = $o->admin_array_selectedpage($r);
	
	print '<table class="pagesline"><tr>';
	
	for my $p ($o->admin_calc_pageline_pages($page))
	{
		if ($p eq '...')
		{
			print '<td>…</td>';
			next;
		}
		
		my $href = '?url=' . $o->myurl . '&page=' . $p;
		my $drag = 'myurl="' . $o->myurl . '" elempos="&page=' . $p . '" ondragover="return CMS_GlobalDragOver(this)" ondrop="return CMS_GlobalDrop(this)" cms_ondragenter="if(!this.dclassName) this.dclassName=this.className; this.className = \'drag\';" ondragleave="this.className = this.dclassName;"';
		
		if($p == $page)
		{
			print '<td class="current" ' . $drag . '>' . ($p + 1) . '</td>';
		}
		else
		{
			print '<td onclick="location.href=\'' . $href . '\'" class="other" ' . $drag . '>' . ( $p + 1 ) .'</td>';
		}
	}
	
	print '</tr></table>';
}

sub admin_array_selectedpage
{
	my $o = shift;
	my $r = shift;
	
	my $page = $r->{'page'};
	
	unless (defined $page) { $page = 0; } #{ $page = $sess->{$o->myurl . '.page'} || 0; }
	else { $sess->{$o->myurl . '.page'} = $page; }
	
	return $page;
}

sub admin_add_list
{
	my $o = shift;
	
	unless($o->access('a')){ return; }
	
	print
	'
	<fieldset>
	<legend align="center">Создать</legend>
	<div class="padd">
	';
	
	my $cnt;
	for my $cn (cmsb_classes())
	{
		unless($o->elem_can_add($cn)){ next; }
		if ($cn->one_instance){ next; }
		print $cn->admin_cname('','right.ehtml?url='.$o->myurl().'&act=cms_array_add&cname='.$cn),'&nbsp;';
		$cnt++;
	}
	
	unless($cnt){ print 'Нет классов.'; };
	
	print '</div></fieldset>';
}


1;
