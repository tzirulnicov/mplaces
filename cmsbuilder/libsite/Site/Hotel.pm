# (с) Вадим Цырульников, 2009

package Hotel;
use strict qw(subs vars);
use cyrillic qw/utf2win/;
use utf8;

our @ISA = qw(plgnSite::Member CMSBuilder::DBI::Array Comments Page);

sub _cname {'Гостиница'}
sub _aview {qw(name content address location email metro comission price_from price_to rekomenduem is_link wifi transfer excursies city_center vip submenu photo1 photo2 photo3 photo4 photo5 photo6 photo7 photo8 photo9 photo10 contacts link_text panorama_photo1 panorama_url1 panorama_photo2 panorama_url2 num)}
#sub _have_icon {1}
sub _template_export{qw/comments_preview city_flatlist hotel_name images hotel_all contacts city_excursies city_hotels city_rekomenduem city_map panorama/}
sub _rpcs{qw/vcard/}
sub _props
{
	name		=> { type => 'string', length => 100, 'name' => 'Название' },
	content	=> { type => 'miniword', name => 'Текст' },
	address => { type => 'string', name => 'Адрес' },
        location      => { 'type' => 'GoogleMarker', 'name' =>'Координаты'},
	submenu	=> { type => 'select', variants => [ {before => 'выводить перед текстом'}, {after => 'выводить после текста'}, {no => 'не выводить'}, {only => 'выводить без текста'} ], name => 'Вложенные страницы' },
	#hotel_price=>{type=>'select',variants=>[{ot1k=>'От 1000'},{ot2k=>'От 2000'},{ot6k=>'От 6000'}],name=>'Цена номера'},
	metro=>{type=>'InMetro',name=>'Станция метро'},
	script => { type => 'html', name => 'Скрипты' },
	price_from => {type=>'int',name=>'Цена номеров от'},
	price_to=> {type=>'int',name=>'Цена номеров до'},
	wifi	=> {type=>'bool',name=>'Wi-Fi интернет'},
        transfer    => {type=>'bool',name=>'Собственный трансфер'},
        excursies    => {type=>'bool',name=>'Экскурсии'},
        city_center    => {type=>'bool',name=>'Центр города'},
	vip		=> {type=>'bool',name=>'VIP'},
	rekomenduem	=> {'type'=>'bool',name=>'Рекомендуем'},
	is_link		=> {'type'=>'bool',name=>'Ссылка'},
	email		=> {'type'=>'string',name=>'E-Mail администратора'},
        photo1               => { 'type' => 'img', 'msize' => 10000,'name' => 'Gallery photo 1' },
        small1             => { 'type' => 'sizedimg', 'for' =>'photo1', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
        photo2               => { 'type' => 'img', 'msize' => 10000,'name' => 'Gallery photo 2' },
        small2             => { 'type' => 'sizedimg', 'for' =>'photo2', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
        photo3               => { 'type' => 'img', 'msize' => 10000,'name' => 'Gallery photo 3' },
        small3             => { 'type' => 'sizedimg', 'for' =>'photo3', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
        photo4               => { 'type' => 'img', 'msize' => 10000,'name' => 'Gallery photo 4' },
        small4             => { 'type' => 'sizedimg', 'for' =>'photo4', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
        photo5               => { 'type' => 'img', 'msize' => 10000,'name' => 'Gallery photo 5' },
        small5             => { 'type' => 'sizedimg', 'for' =>'photo5', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
        photo6               => { 'type' => 'img', 'msize' => 10000,'name' => 'Gallery photo 6' },
        small6             => { 'type' => 'sizedimg', 'for' =>'photo6', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
        photo7               => { 'type' => 'img', 'msize' => 10000,'name' => 'Gallery photo 7' },
        small7             => { 'type' => 'sizedimg', 'for' =>'photo7', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
        photo8               => { 'type' => 'img', 'msize' => 10000,'name' => 'Gallery photo 8' },
        small8             => { 'type' => 'sizedimg', 'for' =>'photo8', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
        photo9               => { 'type' => 'img', 'msize' => 10000,'name' => 'Gallery photo 9' },
        small9             => { 'type' => 'sizedimg', 'for' =>'photo9', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
        photo10               => { 'type' => 'img', 'msize' => 10000,'name' => 'Gallery photo 10' },
        small10             => { 'type' => 'sizedimg', 'for' =>'photo10', 'size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
	contacts	    => { 'type'=>'string','name'=>'Контакты'},
	comission	    => { 'type'=>'int',length=>3,name=>'Комиссия'},
	link_text	    => { 'type'=>'string',length=>70,name=>'Текст ссылки на главную'},

        panorama_photo1          => { 'type' => 'img', 'msize' => 10000,'name' =>'Panorama photo 1' },
        panorama_small1             => { 'type' => 'sizedimg', 'for' =>'panorama_photo1','size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
	panorama_url1		=> {'type'=>'string',name=>'Panorama 1 url'},
        panorama_photo2          => { 'type' => 'img', 'msize' => 10000,'name' =>'Panorama photo 2' },
        panorama_small2             => { 'type' => 'sizedimg', 'for' =>'panorama_photo2','size' => '*x51', 'quality' => 8, 'format' => 'jpeg'},
	panorama_url2           => {'type'=>'string',name=>'Panorama 1 url'},
	num			=>{'type'=>'int',size=>3,name=>'Порядок следования в "рекомендуемых"'}
}

#———————————————————————————————————————————————————————————————————————————————
 sub site_content
 {
 	my $o = shift;
 	my $r = shift;
        if ($r->{init}){
           CMSBuilder::VType::sizedimg->filter_load('small1',$o->{small1},$o);
           CMSBuilder::VType::sizedimg->filter_load('small2',$o->{small2},$o);
           CMSBuilder::VType::sizedimg->filter_load('small3',$o->{small3},$o);
           CMSBuilder::VType::sizedimg->filter_load('small4',$o->{small4},$o);
           CMSBuilder::VType::sizedimg->filter_load('small5',$o->{small5},$o);
           CMSBuilder::VType::sizedimg->filter_load('small6',$o->{small6},$o);
           CMSBuilder::VType::sizedimg->filter_load('small7',$o->{small7},$o);
           CMSBuilder::VType::sizedimg->filter_load('small8',$o->{small8},$o);
           CMSBuilder::VType::sizedimg->filter_load('small9',$o->{small9},$o);
           CMSBuilder::VType::sizedimg->filter_load('small10',$o->{small10},$o);
	}
	if ($ENV{'QUERY_STRING'}=~/^comments/){
		$o->{comments}->site_content;
		return;
	}
 	if($o->{'submenu'} eq 'only')
 	{
 		$o->site_submenu($r);
 		print $o->{'script'};
 	}
 	elsif($o->{'submenu'} eq 'after')
 	{
 		print $o->{'content'} . $o->{'script'};
 		$o->site_submenu($r);
 	}
 	elsif($o->{'submenu'} eq 'before')
 	{
 		$o->site_submenu($r);
 		print $o->{'content'} . $o->{'script'};
 	}
 	else
 	{
 		print $o->{'content'} . $o->{'script'};
 	}
	$o->{name}=~s/Гостиница //;
#HTTP_USER_AGENT = Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; ru; rv:1.9.0.6) Gecko/2009011912 Firefox/3.0.6
	print '<p><a href="/vcard.php?'.$o->{ID}.'"><img border="0" align="middle" src="/i2/vcard.png" alt="Скачать vCard" /></a> <a href="/vcard.php?'.$o->{ID}.'" style="color:#df6951">Скачайте vCard для удобной связи с гостиницей "'.$o->{name}.'"</a></p>';
}
sub images{
   my $o=shift;
   if ($o->{name} eq 'Номера'){
      $o->images_all();
      return;
   }
   my $hotel_name;#=$o->papa->papa->site_name.' - '.$o->site_name;
   print '<ul>';
   foreach my $a(1..10){
      $hotel_name=$o->get_img_alt;
#      print '<li><a href="'.$o->{'photo'.$a}->href.'" rel="photo"  id="mb'.$a.
#	'" class="mb" title="'.$hotel_name.'"><img src="'.$o->{'small'.$a}->href.
#	'" border=0 alt="'.$hotel_name.'"></a><div class="multiBoxDesc mb'.$a.
#'"></div></li>' if $o->{'small'.$a}->exists;
      print '<li><a href="'.$o->{'photo'.$a}->href.'" rel="gallery[mygallery]" id="mb'.$a.
       '" class="lightview" title="'.$hotel_name.'"><img src="'.$o->{'small'.$a}->href.
       '" border=0 alt="'.$hotel_name.'"></a></li>' if $o->{'small'.$a}->exists;

   }
   print '</ul>';
   return;
}
sub panorama{
   my $o=shift;
#print $o->{panorama_small1}->exists."!!!!";
   return if !(($o->{panorama_small1} && $o->{panorama_small1}->exists &&
	$o->{panorama_code1}) ||
	($o->{panorama_small2} | $o->{panorama_small2}->exists ||
	$o->{panorama_code2}));
   print '
	<div class="photos" style="top:-120px">
		<div>
			<h4>Панорама</h4>
			<ul>';
   foreach my $k(1..2){
      next if (!$o->{"panorama_small$k"} || !$o->{"panorama_small$k"}->exists || !$o->{"panorama_url$k"});
      print '<li><a class="lightview" title=":: :: fullscreen: true, scrolling: false, menubar: top" href="'.$o->{"panorama_url$k"}.'" target="_blank"><img border="0" src="'.$o->{"panorama_small$k"}->href.'"/></a></li>
';
   }
   print '
			</ul>
		</div>
	</div>';				
}
sub images_all{
   my $o=shift;
   my $hotel_name=$o->papa->site_name.' - ';
   print '<ul>';
   for my $k($o->get_all){
    for(my $a=1;$a<=10;$a++){
      print '<li><a href="'.$k->{'photo'.$a}->href.'" id="mb'.$a.
        '" class="mb" title="'.$hotel_name.$k->{name}.'"><img src="'.$k->{'small'.$a}->href.
        '" border=0></a><div class="multiBoxDesc mb'.$a.'"></div></li>' if $k->{'small'.$a}->exists;      
    }
   }
   print '</ul>';
   return;
}
sub hotel_name{
   my $o=shift;
   if ($o->{name} eq 'Номера'){
   print $o->papa->site_name;
 } else {
   print $o->papa->papa->site_name;
 }
}
sub hotel_all{
   my $o=shift;
   if ($o->{name} eq 'Номера'){
      $o->site_flatlist(shift,0);
   } else {
      $o->papa->site_flatlist(shift,0);
   }
}
sub contacts{
   foreach my $k(split(',',shift->{contacts})){
      print '<span>'.$k.'</span>';
   }
}
sub city_excursies{
   my $o=shift;
   my $r=shift;
   my $mode=shift || 0;
   $o=Page->new(42) if $mode;
   foreach my $k($o->get_all){
      next if $k->{name} ne 'Экскурсии';
      $k->site_flatlist($r,1,0,(!$mode?"hotel":"<ol>"));
      last;
   }
}
sub city_hotels{
   my $o=shift;
   my $name='';
   $o->{hotels}=0;
   foreach my $hotels($o->get_all){
     next if $hotels->{name} ne 'Гостиницы';
     $o->{hotels}=$hotels;
     last;
   }
   if (!$o->{hotels}){
      print "Error: Hotels on this city not found";
      return;
   }
   foreach my $num(qw/5 4 3 2/){
      print '<ul class="stars'.$num.'">';
      $name=$num.' звезды' if $num==3 || $num==4;
      $name=$num.' звезд' if $num==5;
      $name='Мини отели' if $num==2;
      foreach my $k($o->{hotels}->get_all){
	 next if $k->{name} ne $name;
	 foreach my $k2($k->get_all){
	    print '<li><a href="'.$k2->site_href.'">'.$k2->site_name.
		'</a> <sup>'.($num!=2?'+'.$num:'Мини отели').'</sup></li>';
	 }
	 last;
      }
      print '</ul>';
   }
}
sub city_rekomenduem{
   my $o=shift;
   foreach my $k($o->get_all){
      next if $k->{my4} ne 'hotels';
      foreach my $k2($k->get_all){
	  next if $k2->{name} ne 'Рекомендуем';
	  print $k2->{content};
	  last;
      }
      last;
   }
}
sub city_map{
   my $o=shift;
   my @coords;
   for my $k($o->get_all){
      next if $k->myurl!~/GoogleMap/;
      @coords=split(/[ ,]+/,$k->{coords});
      @coords=('55.7394','37.6446') if $#coords<1;
      $coords[2]=9 if $#coords<2;
      print 'var elms=new Array('.
	join(',',@coords).');
';
      $k->site_content(shift);
      last;
   }
}
sub site_preview{
   shift;
   my $o=shift;
   #my $stars;#=$o->papa->{name};
   my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT ourl from relations
	where aurl="Hotel'.$o->{ID}.'" and ourl like "modFeedback%"');
   $dbs->execute;
   my $row=$dbs->fetchrow_hashref;
   $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT count(c.ID) 
	from dbo_CommentsDir as cd,dbo_Comment as c
        where cd.PAPA_CLASS="Hotel" and cd.PAPA_ID=? and c.PAPA_ID=cd.ID');
   $dbs->execute($o->{ID});
   my @row2=$dbs->fetchrow_array;
   $o->{papa_name}=~s/[^\d]+//g;
   $o->{name}=~s/Гостиница // if $o->{info_href};
#($o->{small1}->exists?$o->{small1}->href:'/uploads2/photo.jpg').
   if ($o->{info_href}){
      Hotel::site_preview_google($o,$row2[0]);
      return;
   }
   print '	<li>
		<div class="rec-lt">
		<div class="rec-rt">
		<div class="rec-lb">
		<div class="rec-rb">
 			<div class="left">
				<a href="hotel'.$o->{ID}.'.html" class="rec-img"><img src="/ee/wwfiles/'.$o->{photo1}.'_small1.jpeg" alt="" /></a>
				'.($o->{papa_name}?'<div 
class="stars star'.$o->{papa_name}.'"></div>':'Мини отели').'

				<noindex><a href="hotel'.$o->{ID}.'.html?comments"  
class="comments">Отзывы <span>('.($row2[0] || 0).')</span></a></noindex>
			</div>
			<div class="rec-inner"><div class="header-inner">
				<h4><a href="hotel'.$o->{ID}.'.html">'.$o->{name}.'</a></h4>
				<ul>';
=head
   $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT min(nomer.price) as price_from,
	max(nomer.price) as price_to
	from dbo_Page as nomer, dbo_Page as nomers where nomer.PAPA_ID=nomers.ID
	and nomer.PAPA_CLASS="Page" and nomers.PAPA_CLASS="Hotel" and 
		nomers.PAPA_ID=?');
# and nomers.name="ή����);
   $dbs->execute($id);
   $row2=$dbs->fetchrow_hashref;
=cut
#   @{$o->{price}}=split('-',$o->{price});
   print '
					<li>Номера от <b>'.($o->{price_from} || 0).'</b> 
до <b>'.($o->{price_to} || 0).'</b> рублей</li>
				</ul>
				<!--'.($row->{ourl}?'<a href="'.lc($row->{ourl}).'.html" class="bron">Бронируем</a>':'').'-->
				<a href="'.$CMSBuilder::Config::booking_url.'" class="bron">Бронируем</a>
			</div></div>
 		</div>
		</div>
		</div>

		</div>		
	</li>';
#.CMSBuilder::cmsb_url($row->{ourl})->site_href
}
sub site_preview_google{
  my $o=shift;
  my $comments=shift || 0;
  print '<table class="site_preview_google" id="spg'.$o->{ID}.'">
	<tr>
	   <td align="center">
	         <a href="hotel'.$o->{ID}.'.html" class="rec-img">
		<img src="/ee/wwfiles/'.$o->{photo1}.'_small1.jpeg" alt="" /></a>'.
($o->{papa_name}?'<div class="stars star'.$o->{papa_name}.'"></div>':'Мини отели').'
<br>  <a href="hotel'.$o->{ID}.'.html?comments"
class="comments">Отзывы <span>('.$comments.')</span></a>

	   </td><td valign="top" style="padding-left:6px">
		<h4><a href="hotel'.$o->{ID}.'.html">'.$o->{name}.'</a></h4>
<span class="spg_price">Номера от <b>'.($o->{price_from} || 0).'</b>
до <b>'.($o->{price_to} || 0).'</b> рублей</nobr><br><br>
<a href="hotel'.$o->{ID}.'.html" class="bron">Подробнее</a></span>
	   </td>
	</tr>
</table>';
}
=head
sub comments_preview{
   my $o=shift;
   my ($dbs,$row,$count);
   $o=$o->papa if $o->myurl!~/Hotel/;
   return if ($ENV{'QUERY_STRING'}=~/^comments/);
      $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT count(c.ID)
        from dbo_Comment as c,dbo_CommentsDir as cd
        where c.PAPA_ID=cd.ID and cd.PAPA_CLASS="Hotel" and cd.PAPA_ID=?');
      $dbs->execute($o->{ID});
      $count=($dbs->fetchrow_array)[0] || return;       
      $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT c.username,c.desc 
	from dbo_Comment as c,dbo_CommentsDir as cd 
	where c.PAPA_ID=cd.ID and cd.PAPA_CLASS="Hotel" and cd.PAPA_ID=? limit 3');
      $dbs->execute($o->{ID});
      print '						<div class="guestbook">
							<h3>Отзывы</h3>
							<div>';
   while ($row=$dbs->fetchrow_hashref){
      Encode::_utf8_on($row->{username});
      Encode::_utf8_on($row->{desc});
      print '	<div>
			<span>'.$row->{username}.'</span>
			<p>'.$row->{desc}.'</p>
		</div>
      ';
   }
   print '						<p><i>Всего '.$count.'</i></div>
						</div>
   ';
}
sub vcard{
   my $o=shift;
   my @tel=split(',',$o->papa->papa->papa->{contacts});
   $tel[0]=~s/[\- ]//g;
   $tel[1]=~s/[\- ]//g;
   my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT name from dbo_Hotel 
	where ID='.$o->{ID});
   $dbs->execute();
   my $row=$dbs->fetchrow_hashref;
Encode::from_to($row->{name},'utf-8','cp1251');
use Encode qw(encode decode);
my $str1251 = encode('cp1251', decode('UCS-2', $o->{name}));
   print 'BEGIN:VCARD
VERSION:3.0
N:;;;;
FN:'.$str1251.'
ORG:'.$row->{name}.';
EMAIL;type=INTERNET;type=WORK;type=pref:'.$o->root->{email}.'
item1.EMAIL;type=INTERNET:http://www.'.$ENV{HTTP_HOST}.$o->site_href.'
item1.X-ABLabel:Ҡ갍
TEL;type=WORK;type=pref:'.$tel[0].'
TEL;type=CELL:'.$tel[1].'
X-ICQ;type=WORK:'.$o->{icq}.'
item2.X-ICQ;type=pref:'.$o->{skype}.'
item2.X-ABLabel:Skype
X-ABShowAs:COMPANY
X-ABUID:28932CB7-5EC2-4CD4-867D-421B07F58F7E\:ABPerson
END:VCARD
';
}
=cut
1;
