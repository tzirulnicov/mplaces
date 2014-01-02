# (с) Леонов П.А., 2005

package modCatalog;
use strict qw(subs vars);
use utf8;

use CMSBuilder;
use CMSBuilder::Utils;
use CMSBuilder::IO;

use plgnUsers;

our @ISA = qw(plgnCatalog::Member plgnSite::Member CMSBuilder::DBI::TreeModule);

sub _cname {'Каталог'}
sub _aview {qw/name shownophoto nophotoimg ptextlen orders payments price_from price_to/}
sub _have_icon {1}

sub _props
{
	shownophoto		=> { type => 'bool', name => 'Выводить картинку по умолчанию' },
	nophotoimg		=> { type => 'img', name => 'Картинка по умолчанию' },
	smallnophotoimg	=> { 'type' => 'sizedimg', 'for' => 'nophotoimg', 'size' => '155x107', 'quality' => 8, 'format' => 'jpeg'},
	ptextlen		=> { type => 'int', name => 'Кол-во слов в кратком описании' },
	#types			=> { type => 'object', class => 'CatTypesDir', name => 'Типы товаров' }
	#currency		=> { type => 'string', name => 'Назваие валюты' },
	price_from		=> { type=>'int', name=>'Разброс цены от'},
	price_to		=> { type=>'int', name=>'Разброс цены до'}
}

sub _template_export {qw(site_title)}

sub _rpcs {qw(catalog_comp_delete)}

sub class_load
{
	cmsb_event_reg('template_call:site_content:end', \&catalog_comp_menu, 'plgnCatalog::Member');
}

#———————————————————————————————————————————————————————————————————————————————

sub site_title
{
	my $o = shift;

	
	if($o->{'title'}){ print $o->{'title'}; return; }

	my $ttl = $o->site_name();
	my $gttl = $o->papaN(0)->{'title'};
	
	print $gttl?"$ttl — $gttl":$ttl;
	
	return;
}

sub catalog_comp_delete
{
	my $o = shift;
	my $r = shift;
	
	if ($r->{ware} eq 'all')
	{
		delete $sess->{catalog_comp};
	}
	else
	{
		delete $sess->{catalog_comp}->{$r->{ware}};
	}
	
	$o->catalog_comp_table();
}

sub catalog_comp_table
{
	my $o = shift;
	my $r = shift;
	
	my $ri = request_info($r);
	
	# загружаем товары, фильтруя пустые (возможно удаленные)
	my @wares = grep { $_ } map { cmsb_url($_) } keys %{ $sess->{catalog_comp} };
	
	# очищаем от пустых товаров сессию
	map { delete $sess->{catalog_comp}->{$_} } grep { !cmsb_url($_) } keys %{ $sess->{catalog_comp} };
	
	
	unless (@wares) { print '<div class="message">Нет товаров, выбранных для сравнения.<p>Вы можете <a href="' . $o->site_href . '">выбрать другие товары</a> из каталога.</p></div>'; return; }
	
	my %wprops;
	
	map { map { $wprops{$_->name}++;  } $_->{multiprops}->get_all } @wares;
	
	print
	'
	<table>
		<thead>
	';
	
	print '<tr><th></th>', ( map { '<th><p><button class="delete" action="/srpc/' . $o->myurl . '/catalog_comp_delete" ware="' . $_->myurl . '" onclick="catalog_comp_delete(this)"/>X</button>' . $_->name . '</p>' . $_->site_to_the_basket_button . '</th>' } @wares ), '</tr>';
	#print '<tr><th></th>', ( map { '<th>' . $_->site_to_the_basket_button . '</th>' } @wares ), '</tr>';
	
	print '</thead>';
	
	for my $key (keys %wprops)
	{
		my $diff;
		my $buff;
		
		map { defined($buff) ? ($buff eq $_->mp_get($key) || ($diff++)) : ($buff = $_->mp_get($key) || '') } @wares;
		
		print '<tr' . ($diff ? ' class="diff"' : '') . '><th>' . $key . '</th>';
		for my $to (@wares)
		{
			
			
			print '<td>' . ($to->mp_get($key) || '-') . '</td>';
		}
		print '</tr>';
	}
	
	print '</table>';
	
	print '<div class="delete-all"><button action="/srpc/' . $o->myurl . '/catalog_comp_delete" ware="all" onclick="catalog_comp_delete(this)"/>Удалить все элементы</button></div>';
	
	return;
}

sub catalog_comp_content
{
	my $o = shift;
	my $r = shift;
	
	print '<div class="catalog-comp" id="catalog_compare">';
	
	$o->catalog_comp_table();
	
	print '</div>';
}

sub site_content
{
	my $o = shift;
	my $r = shift;
	
	if ($r->info->{path} =~ '/compare') { return $o->catalog_comp_content($r) }
	
	return $o->SUPER::site_content($r);
}

sub catalog_comp_menu_button
{
	my $o = shift;
	
	my $elems = scalar keys %{ $sess->{catalog_comp} };
	
	if ($elems > 1)
	{
		return '<form action="' . $o->site_href . '/compare"><button type="submit">Сравнить ' . $elems . '&nbsp;' . rus_case($elems, ['элементов', 'элемент', 'элемента', 'элементов']) . '…</button></form>';
	}
	
	return;
}

sub catalog_comp_menu
{
	my $o = shift;
	my $r = shift;
	
	return if $r->info->{path} =~ '/compare';
	
	my $elems = scalar keys %{ $sess->{catalog_comp} };
	
	if ($elems > 1)
	{
		print '<div class="message" id="catalog_comp_button_div">' . $o->catalog_root->catalog_comp_menu_button . '</div>';
	}
	
	return;
}

sub catalog_add_to_comp_js
{
	my $o = shift;
	my $r = shift;
	
	my $elems = scalar keys %{ $sess->{catalog_comp} };
	
	if ($elems > 1)
	{
		print
		'
			var div = document.getElementById("catalog_comp_button_div");
			
			if (!div)
			{
				div = document.createElement("div");
				div.className = "message";
				div.id = "catalog_comp_button_div";
				
				document.getElementById("content").appendChild(div);
			}
			
			div.innerHTML = "' . escape( $o->catalog_root->catalog_comp_menu_button ) . '";
		';
		#print 'alert("' . join(', ', keys %{$sess->{catalog_comp}}) . '")';
	}
	else
	{
		print
		'
			var div = document.getElementById("catalog_comp_button_div");
			if (div && div.parentNode) div.parentNode.removeChild(div);
		';
	}
}

sub install_code {}
sub mod_is_installed {1}

1;
