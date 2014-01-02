# (с) Леонов П.А., 2005

package plgnCatalog::Ware;
use strict qw(subs vars);
use utf8;

our @ISA = qw(plgnCatalog::Member);

use plgnUsers;
use CMSBuilder;
use CMSBuilder::IO;
use CMSBuilder::Utils;
use Switch;

sub _aview {qw/name photo photobig2 textfield desc/}

sub _all {qw/name photo photobig2 textfield desc template hidden title my4 tag description usetime start end/}

sub _have_icon {'icons/CatWare.gif'}

sub _props
{
	mediumphoto1	=> { 'type' => 'sizedimg', 'for' => 'photo', 'size' => '539x*', 'quality' => 8, 'format' => 'jpeg'},
        photobig2       => { 'type' => 'img', 'msize' => 10000, 'name' => 'Большая дополнительная фотография' },
	textfield	=> { 'type'=>'string',name=>'text field for goga'},
}

sub _template_export {qw(site_title site_buy_button site_papa_url site_basket_url site_basket_step1)}

sub _rpcs {qw(catalog_add_to_comp ajaxsave)}

#———————————————————————————————————————————————————————————————————————————————

sub checked
{
	my $o = shift;
	my $tag = shift;

	map { return 'checked' if $_->myurl eq $tag } @{$o->{exportto}};
	return;
}

sub ajaxsave
{
	my $o = shift;
	my $r = shift;
	
	$o->save();
	print $o->name . ': сохранено!';
	return;
}

sub site_title
{
	my $o = shift;
	

	if($o->{'title'}){ print $o->{'title'}; return; }
        if($o->papa->{'title_child'}){ print $o->papa->{'title_child'}; return; }	
	my $ttl = $o->site_name();
	my $gttl = $o->papaN(0)->{'title'};
#       if ($gttl && $ENV{'SERVER_NAME'} ne 'av-st.ru'){
#               $gttl=modSite->new($CMSBuilder::site_id)->{title};
#       }
	print $gttl?"$ttl — $gttl":$ttl;
	
	return;


}

sub admin_props
{
	my $o = shift;
	my $mcw_id;
	print '<table class="props_table">';

	print '<tr><td colspan="2"><h2>Служебные характеристики</h2></td></tr>';
	$o->admin_view_props('_aview');
=head
if ($ENV{QUERY_STRING}=~/mcw\=mcw\w+(\d+)/ || $o->{mcw_id}){
   $mcw_id=($o->{mcw_id}?$o->{mcw_id}:$1);
   foreach my $k (cmsb_url('mcwWare'.$mcw_id)->get_all){
      $o->admin_view_props2($k);
   }
} else {
	print '<tr><td colspan="2"><h2>Общие характеристики</h2></td></tr>';
	$o->admin_view_props('_main');
	print '<tr><td colspan="2"><h2>Камера</h2></td></tr>';
	$o->admin_view_props('_camera');
	print '<tr><td colspan="2"><h2>Мультимедиа</h2></td></tr>';
	$o->admin_view_props('_multi');
	print '<tr><td colspan="2"><h2>Память</h2></td></tr>';
	$o->admin_view_props('_memory');
	print '<tr><td colspan="2"><h2>Экран</h2></td></tr>';
	$o->admin_view_props('_screen');
	print '<tr><td colspan="2"><h2>Интерфейсы</h2></td></tr>';
	$o->admin_view_props('_interface');
	print '<tr><td colspan="2"><h2>Звонки</h2></td></tr>';
	$o->admin_view_props('_calls');
	print '<tr><td colspan="2"><h2>Управление звонками</h2></td></tr>';
	$o->admin_view_props('_callcontrol');
	print '<tr><td colspan="2"><h2>Клавиатура</h2></td></tr>';
	$o->admin_view_props('_keybrd');
	print '<tr><td colspan="2"><h2>Органайзер</h2></td></tr>';
	$o->admin_view_props('_org');
	print '<tr><td colspan="2"><h2>Сообщения</h2></td></tr>';
	$o->admin_view_props('_mess');
	print '<tr><td colspan="2"><h2>Питание</h2></td></tr>';
	$o->admin_view_props('_power');
	print '<tr><td colspan="2"><h2>Размеры и вес</h2></td></tr>';
	$o->admin_view_props('_sizes');
	print '<tr><td colspan="2"><h2>Дополнительный функционал</h2></td></tr>';
	$o->admin_view_props('_dop');
	print '<tr><td colspan="2"><h2>Экспорт в Яндекс.Маркет</h2></td></tr>';
	$o->admin_view_props('_yandex');
}	
=cut	
	print '</table>';
#<input type="hidden" name="mcw_id" value="'.$mcw_id.'">';
	
	return 1;
}

sub admin_view_props
{
	my $o = shift;
	my $view = shift;
	
	my $na =
	{
		-keys => [$o->aview($view)],
		-action => 'view',
		@_
	};
	
	unless( @{$na->{-keys}} )
	{ print '<p align="center">Нет доступных для редактирования свойств.</p>'; return 0; }
	
	my $p = $o->props();
	
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
}

sub catalog_add_to_comp
{
	my $o = shift;
	my $r = shift;
	
	if ($r->{checked})
	{
		$sess->{catalog_comp}->{$o->myurl} = 1;
	}
	else
	{
		delete $sess->{catalog_comp}->{$o->myurl};
	}
	
	$o->catalog_root->catalog_add_to_comp_js($r);
}

sub ware_handler
{
	my $o = shift;
	my $mp = shift;
	
	my $h = CatWareHandler->cre();
	
	my $tmp;
	map { $tmp = $_ if $o->{price} eq $_->{value} } $o->{multiprops}->get_all;
	$mp = $mp || $tmp;
	
	$h->{ware} = $o;
	$h->{count} = 1;
	$h->{price} = $mp ? $mp->{value} : $o->{price};
	$h->{prop} = $mp->myurl if $mp;
	return $h;
}

sub site_basket_view_img
{
	my $o = shift;
	my $handler = shift;
	
	return '<span class="catalog-ware-basket"><img src="' . $o->{'smallphoto'}->href . '" class="icon" align="absmiddle"/> <a href="' . $o->site_href . '">' . $o->name . ($handler->{prop} ? ' (' . cmsb_url($handler->{prop})->{name} . ')' : '') . '</a></span>';
}

sub site_basket_view
{
	my $o = shift;
	
	return '<span class="catalog-ware-basket"><a href="' . $o->site_href . '">' . $o->name . '</a></span>';
}

sub site_add_to_comp_button
{
	my $o = shift;
	my $r = shift;
	
	return
	'
	<div class="to-comp">
		<input
			type="checkbox"
			action="/srpc/' . $o->myurl . '/catalog_add_to_comp"
			onclick="catalog_add_to_comp(this)"
			id="' . $o->myurl . '_add_to_comp"
			' . ($sess->{catalog_comp}->{$o->myurl} && 'checked="true"') . '
		/>
		<label for="' . $o->myurl . '_add_to_comp">сравнить</label>
	</div>
	';
}

sub site_to_the_basket_button
{
	my $o = shift;
	my $r = shift;

	my $basket = $user->{basket} || cmsb_url($sess->{basket});

	return unless $basket;
	if ($o->{insight})
	{
		my $hnd = $basket->search_ware_handler($o);
		
		if ($hnd)
		{
			return '<img src="/i/vkorzine.png">';#'<a href="#"><img src="/i/buy.png" alt="" /></a>';
			#return '<div class="to-the-basket"><a class="add" action="/srpc/' . $basket->myurl . '/catalog_edit_ware?ware=' . $o->myurl . '" onclick="catalog_edit_basket(this)" style="cursor: pointer;" title="Внести изменения"><img alt="Внести изменения" src="/img/edit.png"/></a></div>';
		}
		else
		{
			return '<a class="add" action="/srpc/' . $basket->myurl . '/catalog_add_ware?ware=' . $o->myurl . '" actionedit="/srpc/' . $basket->myurl . '/catalog_edit_ware?ware=' . $o->myurl . '" onclick="catalog_move_to_basket(this)" style="cursor: pointer;" title="Купить">
			<img src="/i/buy'.($ENV{'SERVER_NAME'} ne 'av-st.ru'?'_sat':'').'.png" alt="" /></a>';
			#'<div class="to-the-basket"><img alt="Купить" src="/img/buy.png"/></a></div>';
		}
	}
	else
	{
		return '<div class="to-the-basket"><button class="not-in-sight" disabled="yes"/>Нет&nbsp;в&nbsp;наличии</button></div>';
	}
}

sub site_to_the_basket_button_preview
{
	my $o = shift;
	my $r = shift;

	my $basket = $user->{basket} || cmsb_url($sess->{basket});

	return unless $basket;
	
	if ($o->{insight})
	{
		my $hnd = $basket->search_ware_handler($o);
		
		if ($hnd)
		{
			return '<div class="to-the-basket"><button class="not-in-sight" disabled="yes"/>Добавлено</button></div>'; #&nbsp;(' . $hnd->count . ')
		}
		else
		{
			return '<div class="to-the-basket"><button class="add" action="/srpc/' . $basket->myurl . '/catalog_add_ware?ware=' . $o->myurl . '" onclick="catalog_move_to_basket(this)"/>В&nbsp;корзину</button></div>';
		}
	}
	else
	{
		return '<div class="to-the-basket"><button class="not-in-sight" disabled="yes"/>Нет&nbsp;в&nbsp;наличии</button></div>';
	}
}

sub site_basket_step1
{
	my $o=shift;
        my $basket = $user->{basket} || cmsb_url($sess->{basket});
	my $sum=$o->{price};
	my $count=1;
        for my $to ($basket->get_all)
        {
           $sum+=$to->summ;
	   $count+=$to->{count};
	}
	$sum=substr($sum,0,-3).' '.substr($sum,-3) if length $sum>3;
	print '<div class="tovar">
	<a href="'.$o->site_href.'" class="tovar-photo"><img src="'.$o->{photo}->href.'" alt="" width="93" id="mainphoto2" /></a>
	<h3><a href="'.$o->site_href.'">'.$o->{name}.'</a></h3>
	<span>'.$o->{price}.' руб</span>
</div>
<div class="basket-variants">
	<div>
		Теперь в корзине <span>'.$count.' товаров</span><br />

		на сумму <span>'.$sum.' р</span>
	</div>
	<ol>
		<li style="color: #02a0df;">1 - <a href="'.$o->papa->site_href.'" style="color: #02a0df; border-bottom: 1px dotted #02a0df;">Продолжить выбор покупок</a></li>
		<!--<li style="color: #e71e25;">2 - <a href="'.$basket->site_href.'" style="color: #e71e25; border-bottom: 1px dotted #e71e25;">Перейти в корзину</a></li>-->
		<li style="color: #38c000;">2 - <a href="'.$basket->site_href.'" style="color: #38c000; border-bottom: 1px dotted #38c000;" class="supernext">Оформить заказ</a></li>
	</ol>
</div>';
}

sub site_basket_url
{
        my $basket = $user->{basket} || cmsb_url($sess->{basket});
	return $basket->site_href;
}

sub site_papa_url
{
	my $o=shift;
#	print '/'.lc($o->papa->myurl).'.html';
	print $o->papa->site_href;
}

sub site_content
{
	my $o = shift;
	my $r = shift;
	#$o->{desc}=~s/\{TEXT\}/$o->{textfield}/g;
	#$o->{desc}=~s/\{IMG\}/$o->{photo_href}/g;
	print '<DIV  Class="bigramka">
<IMG SRC="Image/bigramkatop.gif" Class="bigimgt" Border="none" Alt="image"><IMG SRC="Image/bigramkatop.gif" Class="bigimgt" Border="none" Alt="image">
			<a href="">'.($o->{mediumphoto1}->exists?'<img src="'.$o->{mediumphoto1}->href.'" class="bigimg" border="none" alt="image">':'').'</a>
<IMG SRC="Image/bigramkabottom.gif" Class="bigimgb" Border="none" Alt="image">
		</DIV>
<DIV Class="ramka" Style="margin-left:40px;">
<table style="height:100%"><tr><td valign="middle">			<A HREF=""><IMG SRC="'.($o->{photobig2}->exists?$o->{photobig2}->href:'').'" Border="none" alt="image" id="ramka_ware"></A></td></tr></table>
			<div class="d2"></div>
			<p class="q1">
				<A  Class="imgtexta" HREF="">'.$o->{textfield}.'
				 </A>
			</p>
		</DIV>
		<DIV Class="text1">'.$o->{desc};
#.'<br><br><P Class="p5"><A HREF="" Class="p55">www.evoobonsay.ru</A></P> 
		print '<br>&nbsp;</DIV>';
}

sub site_preview
{
	my $o = shift;
	# my $r = shift;
	my $count = shift;
	
	my $style;
	$style = 'style="width:49%"' if $count == 2;
	
	my $photo_href;
	if ($o->{mediumphoto1} && $o->{mediumphoto1}->exists)
	{
		$photo_href = $o->{mediumphoto1}->href
	}
	elsif ((my $cr = $o->catalog_root)->{shownophoto})
	{
		$photo_href = $cr->{nophotoimg}->href;
	}
	my $href=$o->site_href;
	$o->{desc}=~s/<\/?\w[^>]*>//g;
#	$o->{desc}=~s/\{TEXT\}/$o->{textfield}/g;
#	$o->{desc}=~s/\{IMG\}/$o->{photo_href}/g;
	print '
<div class="cat_block" ' . $style . '>';
print '
				<div class="cat_descr">
					<h3>'.$o->site_name.'</h3><p>
					<a href="' . $o->site_href . '">' . substr($o->{desc},0,150).(length($o->{desc})>150?'...':'') . '</a>
					<p>';
	print			'</p>
				</div>
			</div>';
	return;
}

sub site_props
{
	my $o = shift;
	
	my $props =  '' . 
					($o->{camera} ? "Камера $o->{camera} Мпикс, " : "" ) .
					($o->{gps} ? "GPS, " : "") .
					($o->{ggg} ? "3G, " : "") .
					($o->{wifi} ? "WiFi, " : "") .
					($o->{edge} ? "EDGE, " : "") .
					($o->{bluetooth} ? "Bluetooth $o->{bluetooth}, " : "") .
					($o->{cards} ? "$o->{cards}, " : "") .
					($o->{memory} ? "память $o->{memory} Мб, " : "") .
					($o->{vplayback} ? "видео" . ($o->{aplayback} ? "-" : "") : "") .
					($o->{aplayback} ? "аудио " : "") .
					($o->{vplayback} || $o->{aplayback} ? " плеер, " : "") .
					($o->{radio} ? "FM, " : "") .
					($o->{voicerec} ? "диктофон, " : "") .
					($o->{games} ? "игры, " : "") .
					($o->{screentype} ? "экран $o->{screentype}, " : "") .
					($o->{screeninc} ? "$o->{screeninc}\", " : "") .
					($o->{screensize} ? "$o->{screensize}, " : "") .
					($o->{screencolor} ? "$o->{screencolor} тыс. цветов" : "") ;
	$props =~ s/, $//;
	
	return $props;
}
1;
