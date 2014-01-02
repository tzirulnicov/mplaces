# (с) Леонов П.А., 2006

package plgnSite::Interface;
use strict qw(subs vars);
use utf8;
use Switch;
use IPC::Open2;

our @ISA = qw(plgnTemplates::Interface);

sub _template_export
{qw(
	site_self_xml
	site_submenu site_mainmenu site_navigation site_content site_contentbox site_flatlist
	site_title site_description site_script
	site_preview site_mainpreview site_href site_head site_aname site_pagesline
	site_cdate site_adate
	site_root
	papa name
	site_name
	is_selected
)}
sub _sview { return shift()->aview(@_) }

#———————————————————————————————————————————————————————————————————————————————

use CMSBuilder;
use CMSBuilder::Utils;
use CMSBuilder::IO;
use plgnUsers;

sub sview { return shift()->_sview(@_) }

sub _rpcs {qw(modsearch_search)}

sub modsearch_search
{
	my $o = shift;
	my $r = shift;
	
	
	if($r->{'q'})
	{
		
		my @res;
		
		{
			my $to = cmsb_url($r->{'q'});
			push @res, $to if $to;
		}
		
		{
			my @keys = split /\s+/, $r->{'q'};
			map { push @res, $_->search(keys => [@keys]) } grep { $_->isa('plgnCatalog::Member') || $_->isa('plgnSite::Member') }  cmsb_classes();
		}
		
		if(@res)
		{
			#print "<p>Найдено объектов: " . scalar(@res) . '<p><dir>';
			print map { $_->name . '|' . $_->site_href . "\n"} @res;
			#print '</dir></p></p>';
		}
	}
}

sub site_my4
{
	my $o = shift;
	my $r = shift;
	
	my $ri = $r->info;
	
	$ri->{path} =~ m/\/([\w-]+)(\/.*)?/;
	my $my4 = $1;
	my $path = $2;
	
	for my $to ($o->get_all)
	{
		$r->info->{main_obj} = $to;
		
		if ($to->{my4} eq $my4)
		{
			
			if (!$path or $path eq '/')
			{
				$to->site_page($r);
				return 1;
			}
			else
			{
				$ri->{path} = $path;
				return $to->site_my4($r);
			}
		}
	}
	
	
	return;
}

sub site_root
{
	$_[0]->root;
}

sub site_self_xml
{
	my $o = shift;
	my $r = shift;
	
	my $tag = lc ref $o;
	$tag =~ s/::/-/g;
	
	print '<' . $tag . ' id="5">' . $o->myurl . '</' . $tag . '>';
	print '<' . $tag . ' id="5"></' . $tag . '>';
}

sub site_props
{
	my $o = shift;
	my @elems = @_;
	
	my $na =
	{
		-keys => $elems[0] ? [@elems] : [$o->sview()],
		@_
	};
	
	my $p = $o->props();
	
	unless( @{$na->{-keys}} ){ print '<div class="message">Нет доступных для редактирования свойств.</div>'; return 0; }
	
	#print '<table>';
	
	my $vtype;
	my $out;
	for my $key (@{$na->{-keys}})
	{
		next unless exists $p->{$key};
		
		$vtype = 'CMSBuilder::VType::'.$p->{$key}{'type'};
		if(${$vtype.'::admin_own_html'})
		{
			$out .= $vtype->aview( $key, $o->{$key}, $o );
		}
		else
		{
			# print
			# '
			# <tr>
			# <th><label for="',$key,'">',$p->{$key}{'name'},'</label>:</th>
			# <td>
			# ',$vtype->sview($key,$o->{$key},$o),'<small>',$p->{$key}{'subname'},'</small>
			# </td></tr>
			# ';
			$out .= '<p>' . $p->{$key}{'name'} . '</p>' . $vtype->sview($key,$o->{$key},$o);
		}
	}
	
	#print '</table>';
	
	return $out;
}

sub site_prop #only text 3 columns
{
	my $o = shift;
	# my $r = shift;
	my @elems = @_;
	
	my $na =
	{
		-keys => $elems[0] ? [@elems] : [$o->sview()],
		@_
	};
	
	my $p = $o->props();
	
	unless( @{$na->{-keys}} ){ print '<div class="message">Нет доступных для редактирования свойств.</div>'; return 0; }
	
	my $vtype;
	my $out = '<table>';
	my $inc = 0;
	my $td_style='';
#	$td_style=' style="font-size:12px"' if $o->myurl=~/CatWareSimple/;
	for my $key (@{$na->{-keys}})
	{
		next unless exists $p->{$key};
		next unless $o->{$key};
		$inc++;
		# print
		# '
		# <tr>
		# <th><label for="',$key,'">',$p->{$key}{'name'},'</label>:</th>
		# <td>
		# ',$vtype->sview($key,$o->{$key},$o),'<small>',$p->{$key}{'subname'},'</small>
		# </td></tr>
		# ';
		$out .= '<tr>' if $inc == 1;
		if ($p->{$key}{'type'} eq 'bool')
		{
			$out .= '<td class="bordered_td" width="50%"'.$td_style.'><span class="bool left">' . $p->{$key}{'name'} . '</span><span class="right">Есть</span></td>';
		}
		else
		{
			$out .= '<td class="bordered_td" width="50%"'.$td_style.'><span class="left">' . $p->{$key}{'name'} . ': </span><span class="right">' .  $o->{$key} . '</span></td>';
		}
		$out .= '<td class="noborder"><div style="width: 35px;"></div></td>' if $inc == 1;
		$out .= '</tr>' if $inc == 2;
		$inc = 0 if $inc == 2;
	}
	$out .= '</tr>' if $inc == 1;
	$out .= '</table>';
	
	return $out;
}

sub td_prop #only text one column
{
	my $o = shift;
	# my $r = shift;
	my @elems = @_;
	
	my $na =
	{
		-keys => $elems[0] ? [@elems] : [$o->sview()],
		@_
	};
	
	my $p = $o->props();
	
	unless( @{$na->{-keys}} ){ print '<div class="message">Нет доступных для редактирования свойств.</div>'; return 0; }
	
	my $vtype;
	my $out = '<table>';
	for my $key (@{$na->{-keys}})
	{
		next unless exists $p->{$key};
		if ($p->{$key}{'type'} ne 'bool' && !$o->{$key})
		{
			next;
		}
		# print
		# '
		# <tr>
		# <th><label for="',$key,'">',$p->{$key}{'name'},'</label>:</th>
		# <td>
		# ',$vtype->sview($key,$o->{$key},$o),'<small>',$p->{$key}{'subname'},'</small>
		# </td></tr>
		# ';
		if ($p->{$key}{'type'} eq 'bool')
		{
			$out .= '<tr><td class="bordered_td"><span class="left">' . $p->{$key}{'name'} . '</span><span class="right">' . ($o->{$key} ? 'Есть' : "Нет" ) . '</span></td></tr>';
		}
		else
		{
			$out .= '<tr><td  class="bordered_td"><span class="left">' . $p->{$key}{'name'} . ': </span><span class="right">' .  $o->{$key} . '</span></td></tr>';
		}
	}
	
	$out .= '</tr></table>';
	
	return $out;
}

sub site_cdate
{
	my $o = shift;
	my $r = shift;
	
	return toDateStr($o->{'CTS'});
}

sub site_adate
{
	my $o = shift;
	my $r = shift;
	
	return toDateStr($o->{'ATS'});
}


sub preview_text
{
	my $o = shift;
	
	my $desc = $o->{'desc'} || $o->{'content'};
	$desc =~ s/.*<\/h1>//g;
	$desc =~ s/\${.*?}/ /sg;
	$desc =~ s/<.*?>/ /sg;
	$desc =~ s/&nbsp;?/ /g;
	$desc =~ s/^\s+|\s+$//g;
	
	my @words = split /\s+/, $desc;
	
	$desc = join ' ',@words[0..20] if @words;
	$desc =~ s/([\.\?\!]+$)|([\,\;\:\-]+$)//;
	
	return $desc.(@words>10 && !$1?'...':'');
}


sub site_flatlist2{
	my $o=shift;
	my ($writer, $reader);
	IPC::Open2::open2($reader, $writer, "cat");
	select $writer;
	$o->site_flatlist(@_);
	close $writer;
	select STDOUT;
	return <$reader>;
}
sub site_flatlist
{
	my $o = shift;
	my $r = shift;
	my $deep = shift;
	my $sitemap = shift;
	my $bullet = shift;
	my $class = shift;
	my $get_papa=shift;
	my $check=0;
	my $nobr=0;
	$o=$o->papa if $get_papa;
if ($deep eq '"nobr"'){
$deep=0;
$nobr=1;
}
	return unless $o->len;
	
	$deep = 50 if $deep eq '*';
	
	my $mobj = $r->info->{'main_obj'};
	if ($class=~/ol/){
	   print "<ol>";
	} else {
	   print '<ul' . ($class ? ' class="' . $class . '"' : '') 
. '>' if !$bullet;
	}
	for my $to ($o->get_all)
	{
		next if $to->{'hidden'} || $to->{name} eq 'Дополнительная кровать';

		next if $sitemap > 0 && ($mobj->myurl eq $to->myurl);

		my $shortcontent = '<br /><a href="' . $to->site_href . '" style="font-size:11px;color:#777; text-decoration: none;">' . $to->preview_text . '</a>' if $sitemap >0;
#		my $shortcontent = '<div id="preview_' . $to->myurl . '" class="previewdesc">' . $to->{desc} . '</div>';

		# проверяем надо ли проверять на даты устаревания и публикации
		if ($to->{'usetime'}) 
		{
			# пришло ли время публиковать или все просрочено
			if ($to->{'start'} le myNOW() && myNOW() le $to->{'end'})
			{
				# рисуем пункты меню
				print '<li class="' . ($mobj->isapapa($to) ? 'sel item' : 'item') . '">' . $bullet .
					($mobj->myurl eq $to->myurl ? ('<span>'.$to->site_name . '</span>') :
					$to->site_aname) . $shortcontent;
				$to->site_flatlist($r,$deep - 1,$sitemap) if $deep > 0;
				print '</li>';
			} else {next;}
		}
		else
		{
			$check=1;
			# рисуем пункты меню
			print '<li'.($to->myurl eq $mobj->myurl?' class="activ"':'').'><a href="'.
				($to->myurl()=~/Feedback/ ? $CMSBuilder::Config::booking_url : $to->site_href).'">'.($class=~/span/?'<span>':'').$to->site_name.
				($class=~/span/?'</span>':'').'</a></li>'.($nobr?'':'
');
#			print '<li ref="' . $to->myurl . '"'.(($to->myurl eq $mobj->myurl || ($mobj->myurl=~/CatWareSimple/ && $to->myurl eq 'modCatalog1'))?' class="activ"':'').'>' . $bullet . '<a href="' . $to->site_href . '" class="' . ($mobj->isapapa($to) ? 'sel item' : 'item') . '">' . $to->site_name . '</a>';
			$to->site_flatlist($r,$deep - 1,$sitemap,1) if $deep > 0;
#			print '</li>' . $shortcontent;
		}
	}
       if ($class=~/ol/){
	print '</ol>';
   } else {	
	print '</ul>' if !$bullet;
   }
}

sub is_selected
{
	my $o = shift;
	my $r = shift;
	my $mobj = $r->info->{'main_obj'};
	
	return 'class="' . ($mobj->isapapa($o) ? 'sel' : 'item') . '"';
}

sub site_pagesline
{
	my $o = shift;
	my $r = shift;
	
	return unless $o->can('pages');
	return if $o->pages < 2;
	
	my $page = $r->{page};
	
	print '<div class="pagesline"><span class="text">Страницы:</span>';
	
	for my $p ($o->admin_calc_pageline_pages($page))
	{
		if ($p eq '...')
		{
			print '<span class="text">…</span>';
			next;
		}
		if ($p == $page)
		{
			print '<span class="current">'.($p+1).'</span>';
		}
		else
		{
			print '<span class="other"><a href="'.$o->site_href().'?page='.$p.'">'.($p+1).'</a></span>';
		}
	}
	
	print '</div>';
	
	return;
}

sub site_submenu
{
	my $o = shift;
	my $r = shift;
	
	return unless $o->len();
	
	print '<div class="submenu">';
	
	for my $to ($o->get_all())
	{
		next if $to->{'hidden'};

		# проверяем надо ли проверять на даты устаревания и публикации
		if ($to->{'usetime'}) 
		{
			# пришло ли время публиковать или все просрочено
			if ($to->{'start'} le myNOW() && myNOW() le $to->{'end'})
			{
				print '<div class="subpage">',$to->site_aname(),'</div>';
			} else {next;}
		}
		else
		{
			print '<div class="subpage">',$to->site_aname(),'</div>';
		}

	}
	
	print '</div>';
	
	return;
}

sub site_subnav
{
	my $o = shift;
	my $r = shift;
	
	return unless $o->len();
	
	my $out;
	
	for my $to ($o->get_all())
	{
		next if $to->{'hidden'};

		# проверяем надо ли проверять на даты устаревания и публикации
		if ($to->{'usetime'}) 
		{
			# пришло ли время публиковать или все просрочено
			if ($to->{'start'} le myNOW() && myNOW() le $to->{'end'})
			{
				print '<div class="subpage">',$to->site_aname(),'</div>';
			} else {next;}
		}
		else
		{
			$out .= '<div class="subpage">' . $to->site_aname() . '</div>';
		}

	}
	
	return $out . '<div style="background: none; padding: 0px" class="subpage png"><img width="150" height="10" src="/i/shadow.png" /></div>';
}

sub site_page
{
	my $o = shift;
	my $r = shift;
	
	my $tpl = $o->site_template_object;
	
	#if($o->{'hidden'}){ return err404("Hidden element"); }
	unless($tpl){ return err404("No template for viewving $o"); }
	
	print $tpl->parse($o,$r);
	
	return;
}

sub site_navigation
{
	my $o = shift;
	my $r = shift;
	
	my @all;
	my $cnt = 0;
	# if (ref($o) ne 'modSite')
	# {
	# 	unshift(@all, '<span class="mn" ref="' . $o->myurl . '">' . $o->site_name . '<ul class="subnav" id="' . $o->myurl . '">' . $o->papa->site_subnav($o, $r) . '</ul></span>');
	# }
	# else { unshift(@all,$o->name()); }
	my $orig_o=$o;
	unshift(@all,'<span class="p44">- &nbsp;'.$o->name().'</span>');
	
	while($o = $o->papa() and $cnt++ < 50)
	{
		next if $o->{'hidden'};
		
		# проверяем надо ли проверять на даты устаревания и публикации
		if ($o->{'usetime'}) 
		{
			# пришло ли время публиковать или все просрочено
			if ($o->{'start'} le myNOW() && myNOW() le $o->{'end'})
			{
				# рисуем пункты меню
				unshift(@all, $o->site_aname());
			}
			else
			{
				next;
			}
		}
		else
		{
			# рисуем пункты меню
			# if (ref($o) ne 'modSite')
			# 			{
			# 				unshift(@all, '<span class="mn" ref="' . $o->myurl . '">' . $o->site_aname . '<ul class="subnav" id="' . $o->myurl . '">' . $o->papa->site_subnav($o, $r) . '</ul></span>');
			# 			}
			# 			else { unshift(@all, $o->site_aname()); }
			unshift(@all, $o->site_aname());
		}
	}
	
	#shift @all;
	$all[0]=~s/(<\/a>)/\:\1/;
	print join('&nbsp;',@all);
	
	return;
}

sub site_content
{	
	my $o = shift;
	my $r = shift;

	print $o->{content};	
	
	# print ('<p>' . $_ . " — " . $ENV{$_} . '</p>') foreach (keys %ENV);
	
	return;
}


sub site_title
{
######
	my $o = shift;
	
	if($o->{'title'}){ print $o->{'title'};return; }
	
	my $ttl = $o->site_name();
	my $gttl = $o->papaN(2)->{'title'};
#print $o->papaN(2)->myurl.'!!!';
#	if ($gttl && $ENV{'SERVER_NAME'} ne 'evoo.ru'){
#		$gttl=modSite->new($CMSBuilder::site_id)->{title};
#	}
	my ($dbs,$row);
	if ($o->{PAPA_CLASS} eq 'Hotel'){
	   $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT h.name from 
		dbo_Hotel as h,dbo_Page as p1,dbo_Page as p2
		where h.ID=? and h.PAPA_ID=p1.ID and 
		p2.ID=p1.PAPA_ID and p2.PAPA_ID=141');
	   $dbs->execute($o->{PAPA_ID});
	   $row=$dbs->fetchrow_hashref;
        }
	if ($row->{name}){
	   Encode::_utf8_on($row->{name});
	   print $ttl.' '.$row->{name}.' - ';
	   if ($o->myurl=~/modFeedback/){
	      print 'отели и мини гостиницы Петербурга';
	   } elsif($o->{name} eq 'Контакты'){
	      print 'гостиницы и отели Санкт-Петербурга';
	   } else {
	      print 'гостиницы и мини отели в Питере';
	   }
	   return;
	}
	if ($ENV{'REQUEST_URI'} eq 'comments'){
	   print 'Отзывы '.$o->{name}.' - бронирование отелей и гостиниц СПб';
	   return;
        }


	print $gttl?"$ttl — $gttl":$ttl;
	
	return;
}


sub site_description
{
	my $o = shift;
	my $r = shift;
	
	$o->{'description'}?(print $o->{'description'}):($o->papa()?$o->papa()->site_description($r):'');
	
	return;
}

sub site_script
{
	my $o = shift;
	my $r = shift;
	
	return;
}

sub site_preview
{
	my $o = shift;
	
	print '<h4>',$o->{'name'},'</h4><p>Предварительный вывод (site_preview) для класса "',ref($o),'" не определён.</p>';
	
	return;
}

sub site_mainpreview
{
	my $o = shift;
	
	print '<h4>',$o->{'name'},'</h4><p>Вывод на главной (site_index) для класса "',ref($o),'" не определён.</p>';
	
	return;
}

sub site_href
{
	my $o = shift;
	my $page = shift;

	my @pp = $o->papa_path;
	shift @pp;
	
	return '/' . $o->{my4} if ref($o) eq 'modTags' && $o->{my4};
	
	my $path = join '/', grep { $_ } map { $_->{my4} } @pp;
		
	return '/' . $path if $path && $o->{my4};
	
	return '/'. ($path && $path . '/') .lc($o->myurl()).'.html';
}

sub show_prop
{
	my $o = shift;
	my $r = shift;
	my @elems = @_;
	
	my $na =
	{
		-keys => $elems[0] ? [@elems] : [$o->sview()],
		@_
	};
	
	my $p = $o->props();
	
	unless( @{$na->{-keys}} ){ return 0; }

	my $vtype;
	for my $key (@{$na->{-keys}})
	{
		next unless exists $p->{$key};
		
		$vtype = 'CMSBuilder::VType::'.$p->{$key}{'type'};
		if(${$vtype.'::admin_own_html'})
		{
			print $vtype->aview( $key, $o->{$key}, $o );
		}
		else
		{
			return $vtype->sview($key,$o->{$key},$o);
		}
	}
}

sub site_abs_href
{
	my $o = shift;
	my $page = shift;
	
	my $base = $o->root->{'address'} || ('http://' . $ENV{'SERVER_NAME'} . '/');
	chop $base;
	
	return $base.$o->site_href();
}

sub site_name
{
	my $o = shift;
	
	my $name = $o->name();
	$name =~ s/\s+/ /g;
	$name =~ s/<.*?>//g;
	
	return $name;
}

sub site_head
{
	my $o = shift;
	
	print $o->site_name;
	
	return;
}

sub site_aname
{
	my $o = shift;
	my $r = shift;
	
	
	return '<a href="'.$o->site_href().'" class="p44">'.$o->name().'</a>';
}

1;
