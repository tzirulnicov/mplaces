#  (с) Вадим Цырульников, 2009

package modFeedback;
use strict qw(subs vars);
use utf8;

our $VERSION = 1.0.0.1;

our @ISA = ('plgnSite::Member','CMSBuilder::DBI::TreeModule','Page');
sub _cname {'Вопрос-ответ'}
sub _add_classes {qw/!*/}
sub _aview {qw/name onpage email emailme link_text/}

sub _have_icon {1}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
	'email'		=> { 'type' => 'string', 'name' => 'E-Mail' },
	'emailme'	=> { 'type' => 'checkbox', 'name' => 'Уведомлять о новых вопросах по e-mail' },
        link_text       => { 'type'=>'string',length=>70,name=>'Текст ссылки на главную'},

}

sub _template_export{qw/contacts images site_myurl nomer_select hotel_name select_rooms get_date beds_price/}

sub _rpcs{qw/postmail/}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;

sub install_code
{
	my $o = shift;
	
	my $root_module = modRoot->new(1);
	
	my $this_module = $o->cre();
	$this_module->{'name'} = 'Вопрос - ответ';
	$this_module->{'refresh'} = 5;
	$this_module->{'messagesonpage'} = 15;
	$this_module->{'themesonpage'} = 30;
	$this_module->save();		
	
	$root_module->elem_paste($this_module);
}

sub mod_is_installed {1}

#Распечатывает список тем. Если их слишком много, бьёт на страницы.
sub site_content
{
	my $o = shift;
	my $r = shift;
#fbTheme->site_content;
return 1;
	print '<div class="mod-feedback">';
	
	if(!$o->len())
	{
		print '<div class="message">Администратор не создал ни одной темы, по которой можно задать вопрос.</div>';
	}
	elsif($o->len() == 1) #Одна тема. Её прямо тут и выведем.
	{
		($o->get_all())[0]->site_content($r,@_);
	}
	else
	{
		map { $_->site_preview() } $o->get_page($r->{'page'});
	}
	
	print '</div>';
	
	return;
}
sub contacts{
   shift->papa->contacts();   
}
sub images{
   shift->papa->images();
}
sub site_myurl{
   shift->myurl;
}
sub nomer_select{
   foreach my $k(shift->papa->get_all){
      next if $k->{name} ne 'Номера';
      nomer_select_sub($k);
      last;
   }
}
sub nomer_select_sub{
   foreach my $k(shift->get_all){
      print '<option value="'.$k->{ID}.'">'.$k->{name}.'</option>';
   }
}
sub hotel_name{
   print shift->papa->site_name;
}
sub postmail{
   if (hPanel::process_params(shift,shift)){
#      print 'yes';
   } else {
#      print 'no';
   }
}
sub select_rooms{
   my $o=shift;
   foreach my $k($o->papa->get_all){
      next if $k->name!~/Номера/;
      $o=$k;
      last;
   }
   foreach my $k($o->get_all){
      print '<option value='.$k->{ID}.' price="'.$k->{price}.'">'.$k->{name}.'</option>'
   }
}
sub get_date{
   my $o=shift;
   shift;
   my $type=shift;
   $type=($type?'otyezd':'zayezd');
   my ($day,$month,$year)=(localtime(time))[3,4,5];
   my $k;
   $month++;
   $year+=1900;
print '<input id="'.$type.'" name="'.$type.'" type="text" class="calendar_input" value="'.$day.'.'.$month.'.'.$year.'">';
return;
   print '<select id="'.$type.'_day" name="'.$type.'_d" onchange="recalc_form()">';
   foreach $k(1..31){
      print "<option".($k==$day+($type eq 'otyezd'?2:0)?' selected':'').">".sprintf("%02d",$k)."</option>";
   }
   print '</select><select id="'.$type.'_month" name="'.$type.'_m" onchange="recalc_form()">';
   foreach $k(1..12){
      print "<option".($k==$month?' selected':'').">".sprintf("%02d",$k)."</option>";
   }
   print '</select><select id="'.$type.'_year" name="'.$type.'_y" onchange="recalc_form()">';
   foreach $k($year..$year+2){
      print "<option".($k==$year?' selected':'').">".$k."</option>";
   }
}

sub beds_price_calc{
   my $o=shift;
   my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT p1.price from dbo_Page as p1,
        dbo_Page as p2 where p2.PAPA_ID='.$o->{PAPA_ID}.' and
        p2.PAPA_CLASS="Hotel" and p1.PAPA_CLASS="Page" and p1.PAPA_ID=p2.ID
        and p1.name="Дополнительная кровать"');
   $dbs->execute();
   my @ar=$dbs->fetchrow_array;
   return $ar[0] || 0;
}
sub beds_price{
   print shift->beds_price_calc;
}
1;
