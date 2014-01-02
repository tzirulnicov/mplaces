# (с) Леонов П.А., 2005

package modNews;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnSite::Member','CMSBuilder::DBI::TreeModule');

sub _cname {'Новости'}
sub _classes {qw/News/}
sub _add_classes {qw/!* News/}
sub _have_icon {1}
sub _pages_direction {0}
sub _aview{qw/name blocklen blockfull onpage/}
sub _template_export {qw/newslist newspage show_last show_prelast show_last_on_main/}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
	'blocklen'	=> { 'type' => 'int', 'name' => 'Кол-во новостей в блоке' },
	'blockfull'	=> { 'type' => 'bool', 'name' => 'Не сокращать автоматически текст новостей' },
}

#———————————————————————————————————————————————————————————————————————————————

sub show_last_on_main{
   my $o=shift;
   shift;
   my $num=shift;
   print '<div class="v_news-block" style="margin-left:7px;margin-right:0px;width:70%">
                                                        <div class="v_block-title">Новости</div>';
   my $cnt=0;
   for my $k($o->get_all()){# replace with get_interval!
      print '<div class="v_news">
	<div class="v_title">'.$k->{name}.'</div>';
      $k->site_preview(1);
      print '</div>
';
      last if ++$cnt==$num;
   }
   print '</div>';
}

sub show_last
{
	my $o = shift;
	my $r = shift;
	
	map {return $_->site_preview()} $o->get_all;
	return;
}

sub show_prelast
{
	my $o = shift;
	my $r = shift;
	
	map {return $_->site_preview()} $o->get_interval(2,2);
	return;
}

sub newspage
{
	my $o = shift;
	#my $r = shift;
	
	my $cnt = $o->{'blocklen'} || 3;
	
	print '<div class="newsblock">';
	
	for my $to ($o->get_interval(1,$cnt))
	{
		$to->site_content()
	}
	
	print '</div>';
	
	return;
}

sub newslist
{
	my $o = shift;
	#my $r = shift;
	
	my $cnt = $o->{'blocklen'} || 3;
	
	print '<div class="newsblock">';
	
	for my $to ($o->get_interval(1,$cnt))
	{
		$to->site_preview()
	}
	
	print '<div class="arch"><a href="',$o->site_href(),'">Архив новостей</a>(',$o->len(),')</div>';
	
	print '</div>';
	
	return;
}

sub site_content
{
	my $o = shift;
	my $r = shift;
	
	if($o->{'descr'})
	{
		print $o->{'descr'},'<br><br>';
	}
	
	print '<div class="newspage">';
	
	if($o->len())
	{
		for my $to ($o->get_page($r->{'page'}))
		{
			$to->site_preview();
		}
	}
	else
	{
		print 'Нет новостей.';
	}
	
	print '</div>';
	
	return;
}

sub install_code {}
sub mod_is_installed {1}

1;
