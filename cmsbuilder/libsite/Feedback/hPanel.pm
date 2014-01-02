# (с) Вадим Цырульников, 2009
#http://mplaces.ru/".$o->{ID}."?hid=".$hotel->{ID}."&cid=".$to->{ID},
package hPanel;
use strict qw(subs vars);
#use Digest::MD5;
use utf8;
use Time::Local;

use CMSBuilder::IO;#for auth (getting $sess)

#our @ISA = ('plgnSite::Object','CMSBuilder::DBI::FilteredArray','CMSBuilder::DBI::Array');
our @ISA = ('plgnSite::Member','CMSBuilder::DBI::TreeModule');

sub _cname {'Панель бронирования'}
sub _aview {'name'}
sub _add_classes {qw/!* hClient/}
sub _template_export {qw/hpanel_right user_name hpanel_otchet_period/}
#sub _have_icon {1}
sub _rpcs {qw/manager_comment/}

sub _props
{
	'name'	=> { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	#'desc'	=> { 'type' => 'miniword', 'name' => 'Описание' },
}

#———————————————————————————————————————————————————————————————————————————————

use plgnUsers;
use CMSBuilder::Utils;

sub interval_filter
{
	my $o = shift;
	
	return @_ if !$o->papa() || $o->papa()->access('w');
	
	return grep {$_->{'answer'}} @_;
}

sub _have_icon 
{
	my $o = shift;
	
	return (grep {!$_->{'answer'}} $o->get_all())?'icons/fbTheme_new.gif':'icons/fbTheme.gif';
}

sub process_params
{
	my $o = shift;# modfeedback object
#CMSBuilder::debug_write($o->myurl);
	my $r = shift;
	my $hotel = $o->papa;
	my $row;
	my $root_email=$o->root->{email};
	return 0 if $r->{'action'} ne 'save';
	my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT ID from dbo_hPanel limit 1');
	$dbs->execute();
	return 0 if !($row=$dbs->fetchrow_hashref);
	$o=CMSBuilder::cmsb_url("hPanel$row->{ID}");
	if($r->{'email'}=~/\@/ && $r->{fio} && $r->{phone}=~/\d{2}/)
	{
		my $to = hClient->cre();
		my $res = $o->elem_paste($to);
		($r->{summ_vneseno},$r->{summ_oplate})=(0,0);
		$r->{status}="t1_no";
		my @date_ar=split('\.',$r->{zayezd});
#open(FILE,'>/www/gogasat/headcall.ru/cmsbuilder/tmp/htest.txt');
#print FILE $hotel->{'email'}.'!!!';
#close(FILE);
		$r->{zayezd}=$date_ar[2].'-'.$date_ar[1].'-'.$date_ar[0];
		@date_ar=split('\.',$r->{otyezd});
		$r->{otyezd}=$date_ar[2].'-'.$date_ar[1].'-'.$date_ar[0];
		my @zayezd=split('-',$r->{zayezd});
                $zayezd[1]--;$zayezd[0]-=1900;
                my @otyezd=split('-',$r->{otyezd});
                $otyezd[1]--;$otyezd[0]-=1900;
                $r->{summ_period} = ($r->{beds_reqd} eq 'true'?$o->beds_price_calc:0)+
		CMSBuilder::cmsb_url("Page$r->{roomID}")->{price}*
                (timelocal(0,0,0,$otyezd[2],$otyezd[1],$otyezd[0])-
                timelocal(0,0,0,$zayezd[2],$zayezd[1],$zayezd[0]))/86400;

		$to->admin_edit($r);
		$to->save();
#print "http://headcall.ru/".$o->site_href."?hid=".$hotel->{ID}."&cid=".$to->{ID};
		print '<div class="message">';
		if ($res){
		   sendmail (
			to	=> $root_email,#$hotel->{'email'},
			from	=> 'BigCityHotels <'.$root_email.'>',
					subj	=> 'Подтверждение заявки с сайта MPlaces.Ru',
					text	=> "Здравствуйте. Для подтверждени брони пройдите по ссылке:
http://mplaces.ru".$o->site_href."?hid=".$hotel->{ID}."&cid=".$to->{ID},
					ct		=> 'text/plain; charset=windows-1251'
		   );
			
		   print
			'Спасибо за заявку. В самое ближайшее время с Вами свяжется наш администратор
			';
		} else {
		   print
			'Ошибка - Не удалось сохранить Вашу заявку. Пожалуйста, попробуйте немного позже
			';
		   return 0;
		}
		
		print '</div>';
	}
	else
	{
		print '<div class="error">Ошибка - Неверно заполнены обязательные поля</div>';
		return 0;
	}
	return 1;
}

#Скрывает строчку с номерами страниц во время составления вопроса.
sub site_pagesline
{
	my $o = shift;
	my $r = shift;
	
	return if $r->{'form'};
	
	return $o->SUPER::site_pagesline($r,@_);
}

#Распечатывает список тем. Если их слишком много, бьет на страницы.
sub site_content
{
	my $o = shift;
	my $r = shift;
	my ($client,$room,$hotel);
	return if (!$r->{cid} && !$r->{hid} && !$o->hpanel_auth($r) ||
		$o->hpanel_otchet($r));
	$o->site_content_panel($r) if !$r->{cid} && !$r->{hid} && !$r->{id};
        $o->site_content_client($r) if $r->{id};
	if ($r->{cid} && ($client=CMSBuilder::cmsb_url("hClient$r->{cid}")) &&
		($room=CMSBuilder::cmsb_url("Page$client->{roomID}"))){
	   $hotel=$room->papa->papa;
	   if ($hotel->{ID}!=$r->{hid}){
	      print "<h4 style='color:red'>Отказано в доступе. Обратитесь в нашему администратору: <a href='mailto:".$room->root->{email}."'>".$room->root->{email}."</a></h4>";
	      return;
	   }
	   if ($client->{status} ne 't1_no'){
	      print "<h4>Ошибка - Вы уже оставили свой ответ по данному клиенту</h4>";
	      return;
	   }
	   if ($o->site_content_confirm_save($r,$client)){
	      print "<h4>Спасибо ! Информация передана нашему администратору на обработку</h4>";
	      return;
	   }
	   my %p=$client->_props();
	   print '<form action="/'.lc($o->myurl).'.html" method="get">
<table style="width:50%">';
	   foreach my $k(qw/zayezd otyezd roomID persons/){
	      print "<tr><td>$p{$k}{name}</td><td>";
	      if ($k eq 'roomID'){
		 print $room->{name};
	      } else {
	         print get_prop($client->{$k},$p{$k});
	      }
	      print "</td></tr>\n";
	   }
	   my @zayezd=split('-',$client->{zayezd});
	   $zayezd[1]--;
	   $zayezd[0]-=1900;
	   my @otyezd=split('-',$client->{otyezd});
	   $otyezd[1]--;
	   $otyezd[0]-=1900;
	   my $days = $room->{price}*($client->{zayezd} ne '0000-00-00' && $client->{otyezd} ne '0000-00-00' ? 
		(timelocal(0,0,0,$otyezd[2],$otyezd[1],$otyezd[0])-
		timelocal(0,0,0,$zayezd[2],$zayezd[1],$zayezd[0]))/86400 : 1);
	   print '<tr><td>Сумма к оплате</td><td>'.$days.' руб.</td></tr>';
	   print '<tr><td colspan=2><hr></td></tr><tr><td><input type="submit" name="ok" 
		value="Подтвердить"></td><td><input type="submit" 
		name="no" value="Отклонить">
		<input type="hidden" name="hid" value='.$r->{hid}.'>
		<input type="hidden" name="cid" value='.$r->{cid}.'></td></tr></table></form>';
	};
}
sub get_prop{
   my ($val,$data)=@_;
   return ($val?'Да':'Нет') if $data->{type} eq 'checkbox';
   return ($val ne ''?$val:'<i>(Не заполнено)</i>') if $data->{type} ne 'select';
   foreach my $k(@{$data->{variants}}){
      next if !exists $k->{$val};
      return $k->{$val};
   }
}
#http://headcall.ru/hpanel1.html?hid=35&cid=2
#http://headcall.ru/modfeedback47.html
sub site_content_panel{
   my $o=shift;
   my $r=shift;
   if ($ENV{QUERY_STRING} ne 'archive'){
      $o->site_content_panel_sub('В процессе','summ_vneseno=0',1);
      $o->site_content_panel_sub('Контроль заездов','summ_vneseno<>0 and status<>"t3_on" and status not like "t4_%"',1);
      $o->site_content_panel_sub('Контроль выездов','summ_vneseno<>0 and status="t3_on"',0);
      print '<br><br><a href="'.$o->site_href.'?archive">Архив</a>';
   } else {
      $o->site_content_panel_sub('Архив','status like "t4_%"',0);
      print '<br><br><a href="'.$o->site_href.'">Вернуться</a>';
   }
}
sub site_href{
   my $o=shift;
  return '/'.lc($o->myurl).'.html';
}
sub site_content_panel_sub{
   my $o=shift;
   my $header=shift;
   my $where=shift;
   my $show_status=shift;
   print '<span class="hpanel_table">
		<h1>'.$header.'</h1>
		<table><tr><th>&nbsp;</th>
			<th>Дата</th>
			<th>Сумма за номер</th>
			<th>Сумма за период</th>
			<th>Сумма внесённая</th>
			<th>Сумма к оплате</th>
			<th>Id брони</th>
			'.($show_status?'<th>Статус</th>':'').'
			<th>Гостиница</th></tr><tr><td colspan=9><hr></td></tr>';
   my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT * from dbo_hClient where PAPA_ID=? and '.$where);
   my $row;
   my $count=0;
   my %p=hClient->_props();
   my $room;
   $dbs->execute($o->{ID});
   while($row=$dbs->fetchrow_hashref){
      $room=Page->new($row->{roomID});
      Encode::_utf8_on($row->{fio});
      print '<tr><td><a href="/'.lc($o->myurl).'.html?id='.$row->{ID}.'">'.
	++$count.'. '.$row->{fio}.'</a></td><td>'.$row->{zayezd}.
	' - '.$row->{otyezd}.'</td><td>'.
	$room->{price}.' p</td><td>'.$row->{summ_period}.' p</td><td>'.
	$row->{summ_vneseno}.' p</td><td>'.$row->{summ_oplate}.' p</td>
	<td>'.$row->{ID}.'</td>'.($show_status?'<td>'.
	get_prop($row->{status},$p{status}).'</td>':'').
	'<td>'.$room->papa->papa->{name}.'</td></tr>';
   }
   print '</table></span>';
}
sub site_content_client{
   my $o=shift;
   my $r=shift;
   my $client=hClient->new($r->{id});
   if (!$client->{ID}){
      print "<h4 style='color:red'>Клиент не найден</h4>";
      return;
   }
   if ($r->{act} eq 'save'){
      $client->{status}=$r->{status} if $r->{status} ne 't3_on_not' and
		$r->{status} ne 't4_on_not';
      $client->{status}='t4_otkaz' if $r->{t4_otkaz};
      $client->{summ_vneseno}=$r->{summ_vneseno};
      $client->{summ_oplate}=$client->{summ_period}-$r->{summ_vneseno};
      $client->save();
      #$o->site_content_client_save($client)){
      $o->site_content_panel($r);
      return;
   }
   my %p=$client->_props();
   my @ap=$client->_aview();
   my $room=Page->new($client->{roomID});
   print '<a href="/'.lc($o->myurl).'.html">Вернуться</a>
	<form action="/'.lc($o->myurl).'.html" method="get" onsubmit="return check_save()">
<table style="width:80%">';
   foreach my $k(@ap){
      next if $k eq 'mngr_comment';
      print "<tr><td>$p{$k}{name}</td><td>";
      if ($k eq 'roomID'){
         print $room->{name};
      } elsif ($k eq 'status') {
	 print '<select name="status">';
	 if (!$client->{summ_vneseno}){
	    foreach my $k2(@{$p{$k}{variants}}){
	       print "<option value='".(keys %$k2)[0]."'".
		((keys %$k2)[0] eq $client->{$k}?' selected':'').">".
		$k2->{(keys %$k2)[0]}."</option>" if (keys %$k2)[0]=~/t1_/;
	    }
	 } elsif ($client->{status} ne "t3_on" && $client->{status}!~/t4_/){
	    print "<option value='t3_on_not' selected>Не въехал</option>";
            print "<option value='t3_on'>Въехал</option>";
	 } elsif ($client->{status} eq "t3_on"){
	    print "<option value='t4_on_not' selected>Не выехал</option>";
            print "<option value='t4_on'>Выехал</option>";
	 } else {
	    print "<option value='t4_on'>Выехал</option>";
	 }
	 print '</select>';
      } elsif ($k eq 'summ_vneseno') {
	 print '<input type="text" name="summ_vneseno" id="summ_vneseno" 
		value="'.get_prop($client->{$k},$p{$k}).'"> p';
      } else {
         print '<span id="'.$k.'">'.get_prop($client->{$k},$p{$k}).'</span>';
      }
       print "</td></tr>\n";
    }
   print '<tr><td colspan=2><hr></td></tr><tr><td><input 
	type="submit" value="Save" onclick="otkaz=0"><input type="hidden" name="id" 
	value="'.$r->{id}.'"><input type="hidden" name="act" value="save">
	</td><td><input type="submit" name="t4_otkaz" 
	value="Отказ клиента" onclick="otkaz=1"></td></tr></table></form>';
   print '<div id="manager_comment_loading" style="display:none"><img src="/loadingAnimation.gif"></div><form action="/srpc/'.$o->myurl.'/manager_comment" 
	id="manager_comment_form" onsubmit="return hpanel_mngrcomment_send()">
	Комментарий менеджера<br><textarea 
	name="manager_comment">'.$client->{mngr_comment}.'</textarea><br><br><input type="hidden" name="id" 
	value="'.$r->{id}.'"><input type="submit" id="manager_comment_submitbtn" value="Сохранить">
	</form><!--<input type="button" onclick="hpanel_mngrcomment_send()" value="test">-->';}
sub site_content_confirm_save{
   my $o=shift;
   my $r=shift;
   my $client=shift;
   my $root_email=Page->new($client->{roomID})->root->{email};
   return 0 if !$r->{ok} && !$r->{no};
   $client->{status}=$r->{ok}?'t1_ok':'t1_cancel';
   $client->save;
   sendmail (
        to      => $client->{email},
        from    => 'BigCityHotels <'.$root_email.'>',
                        subj    => 'Ваша бронь подтверждена',
                        text    => 'Ваша бронь подтверждена, в ближайшее время с Вами свяжется наш менеджер',
                        ct              => 'text/plain; charset=windows-1251'
   );
   sendmail (
        to      => $root_email,
        from    => 'BigCityHotels <'.$root_email.'>',
                        subj    => 'Бронь # подтверждена',
                        text    => 'Бронь # подтверждена, просьба зайти в панель управления и подтвердить её',
                        ct              => 'text/plain; charset=windows-1251'
   );
   return 1;
}
#gray 636363, lightblue 41bde3, backgrd f2ffe5, tahoma 11-13pt, red c52f41, green 58c10c
sub hpanel_right{
   my $o=shift;
   my $r=shift;
   my $hotel;
   $hotel=Hotel->new($r->{hid}) if $r->{hid};
   $hotel=Page->new(hClient->new($r->{id})->{roomID})->papa->papa if $r->{id};
   return if !$hotel;
   print '
	<div class="photos">
	   <div>
		<h4>Фотографии</h4>
		<span>';
   print $hotel->site_name;
   print '</span>';
   $hotel->images($r);
   print '
	   </div>
	</div>
	<div class="hotel">';
   $hotel->comments_preview($r);
   print '
	</div>';
}
sub site_navigation{
   my $o=shift;
   my $r=shift;
   return if $r->{cid};
   print '<a href="/" class="p44">Главная:</a>&nbsp;';
   if ($o->{name} ne $o->site_name($r)){
      print '<a href="'.$o->site_href.'" class="p44">'.$o->{name}.'</a>&nbsp;
	<span class="p44">- &nbsp;'.$o->site_name($r).'</span>';
   } else {
      print '<span href="'.$o->site_href.'" class="p44">- &nbsp;'.$o->{name}.'</span>';
   }
}
sub site_name{
   my $o=shift;
   my $r=shift;
   return if $r->{cid};
   return 'Статистика' if $r->{page} eq 'otchet';
   return $o->{name} if (!$r->{id} && $ENV{QUERY_STRING} ne 'archive') || $r->{act} eq 'save';
   return 'Архив' if $ENV{QUERY_STRING} eq 'archive';
   my $client=hClient->new($r->{id});
   return $o->{name} if !$client->{ID};
   return 'В процессе' if !$client->{summ_vneseno};
   return 'Контроль заездов' if $client->{summ_vneseno} &&
	$client->{status} ne 't3_on' && $client->{status}!~/t4_/;
   return 'Контроль выездов' if $client->{status} eq 't3_on';
   return 'Ошибка!';
}
sub hpanel_auth{
   my $o=shift;
   my $r=shift;
   return 1 if ($user->papa->{hpanel} && $r->{act} ne 'logout');
   if ($r->{act} eq 'login'){
      if (plgnUsers->login($r->{'login'},$r->{'password'})){
	 print '<script>document.getElementById("user_panel").innerHTML="'.
		$user->{name}.'";
		document.getElementById("user_panel_form").style.display="";
		</script>';
	 return 1;
      } else {
	 print '<h4 style="color:red">Ошибка! Неверно введён логин/пароль, либо пользователь не существует</h4><p>'.$plgnUsers::errstr;
      }
   }
   elsif ($r->{act} eq 'logout'){
      plgnUsers->logout();
      undef $user;
      print '<script>document.getElementById("user_panel").innerHTML="'.
                ($user->{name} || 'Гость').'";
                document.getElementById("user_panel_form").style.display="none";
                </script>';
   }
   print
        '
	<div class="mod-registration" align="center">
           <form action="',$o->site_href(),'" method="post">
                <div>У вас нет прав для использования Панели бронирования.<br>
Пожалуйста, авторизуйтесь под пользователем, наделённым данными правами.</div>
                <div class="login">Логин: <input name="login" type="text"/></div>
                <div class="password">Пароль: <input name="password"
                 type="password"/></div>
                <button type="submit">Войти</button>
                <input type="hidden" name="act" value="login"/>
           </form>
	</div>

        ';
   return 0;
}
sub user_name{
   my $o=shift;
   return '<span id="user_panel">'.($user->{name} || 'Гость').'</span>'.
	'<br><br><table id="user_panel_form"><tr><td><form action="'.$o->site_href.'/"'.($user->{name} && !is_guest($user)?'':
	' style="display:none"').'><input type="hidden" name="act" value="logout"><input type="submit" 
	value="Выйти"></form></td><td><input type="button" value="Статистика"
	onclick="location.replace(\''.$o->site_href.'?page=otchet\')"></td></tr></table>';
}
sub manager_comment{
   my $o=shift;
   my $r=shift;
   my $client=hClient->new($r->{id});
   if (!$client->{ID}){
      print 'no';
      return;
   }
   $client->{mngr_comment}=$r->{manager_comment};
   $client->save;
   print 'yes';
}
sub hpanel_otchet{
   my $o=shift;
   my $r=shift;
   return 0 if $r->{page} ne 'otchet';
   if (!$r->{hotel}){
      $o->hpanel_otchet_table_hotels($r);
   } else {
      $o->hpanel_otchet_table_clients($r);
   }
   return 1;
}
sub hpanel_otchet_table_clients{
   my $o=shift;
   my $r=shift;
   my $table_name=shift;
   print '<span class="hpanel_table">
                <h1>Отчет по клиентам гостиницы</h1>
                <table><tr><th>Гостиница</th><th>Сумма</th>
                        <th>Комиссия</th></tr>';
   my $sql='SELECT c.fio,c.summ_period,h.comission,c.zayezd,c.otyezd from dbo_hClient as c,
	dbo_Page as p1,dbo_Page as p2,dbo_Hotel as h
	where c.roomID=p1.ID and p1.PAPA_CLASS="Page" and 
	p1.PAPA_ID=p2.ID and p2.PAPA_CLASS="Hotel" and p2.PAPA_ID=h.ID and 
	h.ID=? and c.zayezd<=? and otyezd>=?';
   my $dbs=$CMSBuilder::DBI::dbh->prepare($sql);
   my @date_ar=get_date_diapason();
   $dbs->execute($r->{hotel},$date_ar[1],$date_ar[0]);
   my ($row,$start,$end,$summ_period,$summ_comission,$res_period);
   my $trigger=0;
   my @date_ar_unix=(date2unix($date_ar[0]),date2unix($date_ar[1]));
   my $room_price=0;
   while($row=$dbs->fetchrow_hashref){
      Encode::_utf8_on($row->{fio});
      $row->{zayezd}=date2unix($row->{zayezd});
      $row->{otyezd}=date2unix($row->{otyezd});
      $start=$row->{zayezd}>$date_ar_unix[0]?$row->{zayezd}:$date_ar_unix[0];
      $end=$row->{otyezd}<$date_ar_unix[1]?$row->{otyezd}:$date_ar_unix[1];
      $room_price=$row->{summ_period}/(($row->{otyezd}-$row->{zayezd})/86400);#by day
      $res_period=(($end-$start)/86400)*$room_price;#day*room_price;
      print '<tr'.(!$trigger?' class="n_tr"':'').'><td>'.$row->{fio}.
	'</td><td>'.$res_period.' p</td><td>'.
	($res_period*$row->{comission}/100).' p</td></tr>';
      $summ_period+=$res_period;
      $summ_comission+=($res_period*$row->{comission}/100);
      $trigger=!$trigger;
   }
#!!!
   print '</table><hr>
<u>ИТОГО ПО КОЛ-ВУ:</u><br>
СУММА ЗА ВЕСЬ ПЕРИОД: '.$summ_period.' p<br>
СУММА ЗА КОМИССИЮ: '.$summ_comission.' p</span>';
}
sub hpanel_otchet_table_hotels{
   my $o=shift;
   my $r=shift;
   my $table_name=shift;
   print '<span class="hpanel_table">
                <h1>Отчет по гостиницам</h1>
                <table><tr><th>Гостиница</th><th>Сумма</th>
			<th>Комиссия</th><th>% комиссии</th></tr>
  ';
   my $sql='SELECT p1.ID as pID,h.ID as hID,h.name,h.comission
        from dbo_Hotel as h,dbo_Page as p1,dbo_Page as p2 where h.rekomenduem=1
        and p1.PAPA_CLASS="Page" and p1.PAPA_ID=p2.ID and p2.PAPA_CLASS="Hotel"
        and p2.PAPA_ID=h.ID order by h.ID';
   my $dbs=$CMSBuilder::DBI::dbh->prepare($sql);
   my ($row,$dbs2,$row2);
   $dbs->execute();
   my ($trigger,$summ_period,$summ_comission)=(0,0,0);
   my $last_hotel;
   my @rooms;
   my @res;
   while($row=$dbs->fetchrow_hashref){
      $last_hotel=$row if !$last_hotel;
      if ($last_hotel->{hID}!=$row->{hID}){
	 @res=$o->hpanel_otchet_table_tr($last_hotel,$trigger,@rooms);
	 $summ_period+=$res[0];
	 $summ_comission+=$res[1];
	 $trigger=!$trigger;
	 $last_hotel=$row;
	 @rooms=();
      } else {
	 push(@rooms,$row->{pID});
      }
   }
   @res=$o->hpanel_otchet_table_tr($last_hotel,$trigger,@rooms);
   print '</table><hr>
<u>ИТОГО ПО КОЛ-ВУ:</u><br>
СУММА ЗА ВЕСЬ ПЕРИОД: '.($summ_period+$res[0]).' p<br>
СУММА ЗА КОМИССИЮ: '.($summ_comission+$res[1]).' p</span>';
}
sub hpanel_otchet_table_tr{
   my $o=shift;
   my $row=shift;
   my $trigger=shift;
   my @rooms=@_;
   my $where=($#rooms!=-1?' (roomID='.join(' or roomID=',@rooms).') and':'');
#01.01.2009-01.10.2009
#zayezd<=01.10.2009 otyezd>=01.01.2009
   my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT summ_period,zayezd,otyezd 
	from dbo_hClient where'.$where.' zayezd<=? and otyezd>=?');
   my @date_ar=get_date_diapason();
   $dbs->execute($date_ar[1],$date_ar[0]);
   my $res;
   my ($res_period,$start,$end)=(0,0,0);
   my @date_ar_unix=(date2unix($date_ar[0]),date2unix($date_ar[1]));
   my $room_price=0;
   while ($res=$dbs->fetchrow_hashref){
      $res->{zayezd}=date2unix($res->{zayezd});
      $res->{otyezd}=date2unix($res->{otyezd});
      $start=$res->{zayezd}>$date_ar_unix[0]?$res->{zayezd}:$date_ar_unix[0];
      $end=$res->{otyezd}<$date_ar_unix[1]?$res->{otyezd}:$date_ar_unix[1];
      $room_price=$res->{summ_period}/(($res->{otyezd}-$res->{zayezd})/86400);#by day
      $res_period+=(($end-$start)/86400)*$room_price;#day*room_price;
   }
   Encode::_utf8_on($row->{name});
   print '<tr'.(!$trigger?' class="n_tr"':'').'><td><a href="'.
	$o->site_href.'?page=otchet&hotel='.$row->{hID}.
	'">'.$row->{name}.'</td><td>'.$res_period.' p</td><td>'.
	($res_period*$row->{comission}/100).' p</td><td>'.$row->{comission}.
	' %</td></tr>';
   return ($res_period,($res_period*$row->{comission}/100));
}
sub hpanel_otchet_period{
   my @date_ar=get_date_diapason();
   print '<div class="hpanel_otchet_period">За месяц с '.$date_ar[0].
	' по '.$date_ar[1].'</div>';
}
sub get_date_diapason{
   my ($day,$month,$year)=(localtime(time))[3,4,5];
   $month++;
   $year+=1900;
   $month=sprintf("%02d",$month);
   return ($year.'-'.$month.'-01',$year.'-'.$month.'-'.
        day_in_month($month,$year));
   #print "$day|$month|$year\n";
   #print day_in_month($month,$year)."|$month|$year\n";
}
sub day_in_month{
   my $month=shift;
   my $year=shift;
   return do{
        if ($month=~/(09|04|06|11)/){
           30;
        } elsif ($month eq '02'){
           $year&3?28:29;
        } else {
           31;
        }
   };
}
sub date2unix{
   #dddd-mm-yy to unix time stamp
   my $date=shift;
   my @ar=split('-',$date);
   $ar[1]--;$ar[0]-=1900;
   return timelocal(0,0,0,$ar[2],$ar[1],$ar[0])
}
1;
