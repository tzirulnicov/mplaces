#  (с) Вадим Цырульников, 2009

package Page;
use strict qw(subs vars);
use utf8;
use Encode;
our @ISA = qw(plgnSite::Member CMSBuilder::DBI::Array);

use CMSBuilder;
use CMSBuilder::Utils;
use CMSBuilder::IO;

sub _cname {'Страница'}
sub _aview {qw(name content price submenu photo1 photo2 photo3 photo4 photo5 photo6 photo7 photo8 photo9 photo10 contacts link_text)}
sub _have_icon {1}
sub _template_export{qw/comments_preview view_in_hotels city_rekomenduem_hotels city_where city_rekomenduem_name city_contacts city_flatlist stations_select hotel_name images hotel_all city_excursies city_hotels city_rekomenduem city_map googlemap papa_hotel_info papa_hotel_id root_icq root_skype papa_hotel_site_name smotri_takge site_myurl select_stars city_rekhotels hotel_href link_exchange hotels_another comments_all site_footer_link/}
sub _rpcs{qw/markers marker_info print_contacts/};
sub _props
{
	name		=> { type => 'string', length => 100, 'name' => 'Название' },
	content	=> { type => 'miniword', name => 'Текст' },
	price => { type=>'int',name=>'Цена'},
	submenu	=> { type => 'select', variants => [ {before => 'выводить перед текстом'}, {after => 'выводить после текста'}, {no => 'не выводить'}, {only => 'выводить без текста'} ], name => 'Вложенные страницы' },
	script => { type => 'html', name => 'Скрипты' },
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
        link_text           => { 'type'=>'string',length=>70,name=>'Текст ссылки на главную'},
}

#———————————————————————————————————————————————————————————————————————————————

#sub city_contacts{
#   print '<address>'.join('</address><address>',split(',',shift->{contacts})).'</address>';
#}

sub comments_all{
   # only for page3462
   my ($parent,$row,$desc,@ar);
   my $dbh=$CMSBuilder::DBI::dbh->prepare('SELECT c.username,c.desc,h.name,h.ID 
	from dbo_Comment as c,dbo_Hotel as h
	where c.PAPA_ID=h.comments');
   $dbh->execute();
   while ($row=$dbh->fetchrow_hashref){
      Encode::_utf8_on($row->{username});
      Encode::_utf8_on($row->{desc});
      Encode::_utf8_on($row->{name});
      @ar=split(' ',$row->{desc},10);
      $ar[$#ar]=~s/ +.*?$//;
      print "<br>";
        print '
        <div>
                <dl id="comments_div">
                        <dt><span style="color:red">'.$row->{username}.' - '.
                                '<a href="/hotel'.$row->{ID}.
				'.html" style="color: #43A100;text-decoration:none">'.
                                $row->{name}.'</a></dt>
                        <dd>'.join(' ',@ar).'...</dd>
                        <dd><a href="/hotel'.$row->{ID}.
                        '.html?comments">Все отзывы: '.
                        $row->{name}.'</a></dd>
                </dl>
        </div>
';
   }
#   map {
#      $parent=$_->papa;
#   } CommentsDir->all;
}

sub city_contacts{
   my $o=shift;
   shift;
   my $mode=shift;
   my $cont_url;
   while(1){
      last if $o->{contacts} || $o->myurl eq $o->root->myurl;
      $cont_url=$o->site_href;
      $o=$o->papa;
   }
   #print $o->site_aname if shift ne 'no_city';
#   my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT ID from dbo_Page 
#	where name="Контакты" and PAPA_CLASS="Page" and PAPA_ID='.$o->{ID});
#   $dbs->execute();
#   my $row=$dbs->fetchrow_hashref;
   print '<a href="page1607.html">Подробнее</a></h3><address>'.join('</address><address>',split(',',$o->{contacts})).'</address>';
}

sub city_flatlist{
   my $o=shift;# $o is city page (moscow, psb, etc)
   my $r=shift;
   while(1){
      last if $o->{contacts} || $o->myurl eq $o->root->myurl;
      $o=$o->papa;
   }
   map {print '<li>
	<a href="'.$_->site_href.'"'.($o->myurl eq $_->myurl?' class="current"':'').'>
		<span class="nav-left"></span>
		<span class="nav-inner">'.$_->name.'</span>
		<span class="nav-right"></span>
	</a>
</li>' if !$_->{hidden}} $o->papa->get_all;
}

sub stations_select{
   my $o=shift;
   my $metro;
   foreach my $k($o->get_all){
      next if $k->myurl!~/Metro/;
      $metro=$k;
   }
   my $val='<select name="metro"><option value="">Все станции</option>';
   map{$val.='<option value="'.$_->myurl.'">'.$_->name.'</option>'} sort{ $a->name cmp $b->name } $metro->get_all;
   print $val.'</select>';
}
sub googlemap{
   # � Łώڈ ŌϠДЂӁׅωϠ́Ӕ׫яŇДЗ́ Łώڈ ŌϠcity_rekomenduem_hotels()
   my $o=shift;
   my $sql;
   $o->{hotels}=0;
   foreach my $hotels($o->get_all){
     $o->{modgooglemap}=$hotels->{coords} if $hotels->{coords};
     next if $hotels->{name} ne 'Гостиницы';
     $o->{hotels}=$hotels;
   }
   if (!$o->{hotels}){
      print 'alert("Error: Hotels on this city not found")';
   } else {
      foreach my $k($o->{hotels}->get_all){
	 next if $k->{name}!~/(3 звезды|4 звезды|5 звезд|Мини отели)/;
	 $sql.='h.PAPA_ID='.$k->{ID}.' or ';
      }
      $sql=substr($sql,0,-4);
   }
   print 'var hotels_papa_id='.$o->{hotels}->{ID}.";
";
   print 'var elms=new Array('.($o->{modgooglemap} || '59.940224,30.315742,12').');
';
   print 'var markers=new Array(Array());';
   my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT h.rekomenduem,h.ID,
	p.name as hotel_type,h.ID,
	h.location,h.name,h.hotel_price,h.wifi,h.transfer,h.metro,
	h.excursies,h.city_center,h.vip from dbo_Hotel as h,
	dbo_Page as p where p.ID=h.PAPA_ID and 
	h.PAPA_CLASS="Page" and ('.$sql.') and h.rekomenduem=1 order by h.num desc');
   $dbs->execute();
   @{$CMSBuilder::Config::hotels_rekomenduem}=();
   while(my $row=$dbs->fetchrow_hashref()){
#      Encode::_utf8_on($row->{name});
      #$CMSBuilder::hotels_rekomenduem.='h.ID='.$row->{ID}.' or ' if $row->{rekomenduem};
      push(@{$CMSBuilder::Config::hotels_rekomenduem},$row->{ID}) if $row->{rekomenduem};
#      next if !$row->{location};
#      #Encode::_utf8_on($row->{station});
#      $row->{hotel_type}=($row->{hotel_type}=~/(\d)/?'z'.$1:'mini');
#      $sql2.="Array(".$row->{location}.",'<b>".$row->{name}."</b>','/hotel".
#	$row->{ID}.".html','','','$row->{hotel_type}',
#	'$row->{hotel_price}','$row->{metro}',$row->{wifi},
#	$row->{transfer},$row->{excursies},$row->{city_center},$row->{vip}),";
   }
#   print substr($sql2,0,-1).');';
   $CMSBuilder::hotels_rekomenduem=substr($CMSBuilder::hotels_rekomenduem,0,-4);
}

sub site_content
 {
 	my $o = shift;
 	my $r = shift;
	my $new_line=0;
	my ($dbs,$row);
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
	if ($o->{name}=~/^(5 звезд|4 звезды|3 звезды|Мини отели|Рекомендуем)$/){
	   print '<div class="recommended-inner"><ul>';
	   my @uslovie=(' and is_link=1',' order by rekomenduem desc,num desc');
	   my $check;
	   USL_LOOP:
	   $check=0;
	   $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT ID,name,photo1,price_from,price_to
		from dbo_Hotel
		where PAPA_CLASS="Page" and PAPA_ID=?'.shift(@uslovie));
	   $dbs->execute($o->{ID});
	   while($row=$dbs->fetchrow_hashref){
	      $check=1;
	      Encode::_utf8_on($row->{name});
	      $row->{papa_name}=$o->{name};
	      Hotel->site_preview($row);
	      $new_line++;
	      if ($new_line==3){
		 print '</ul><ul>';
		 $new_line=0;
	      }
	   }
	   print '</ul></div>' if $check;
	   goto USL_LOOP if $#uslovie!=-1;
	}
	if ($o->{name} eq 'Номера'){
	   my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT ID from dbo_modFeedback where PAPA_ID='.$o->papa->{ID});
	   $dbs->execute();
	   my $row=$dbs->fetchrow_hashref;
	   $o->view_rooms_table;
	   print '<a href="modfeedback'.$row->{ID}.'.html" style="position:relative;top:10px"><img src="/images/bron.jpg"></a> <a href="modfeedback'.$row->{ID}.'.html" style="color:#DF6951">Бронировать номер  в гостинице "'.$o->papa->{name}.'"</a>';
	} elsif ($o->papa->{name} eq 'Номера') {
           my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT ID from dbo_modFeedback where PAPA_ID='.$o->papa->papa->{ID});
           $dbs->execute();
           my $row=$dbs->fetchrow_hashref;
           print '<a href="modfeedback'.$row->{ID}.'.html" style="position:relative;top:10px"><img src="/images/bron.jpg"></a> <a href="modfeedback'.$row->{ID}.'.html" style="color:#DF6951">Бронировать номер "'.$o->{name}.'" в гостинице "'.$o->papa->papa->{name}.'"</a>';
	}
	return '';
}
sub images{
   my $o=shift;
   if ($o->{name} eq 'Номера'){
      $o->images_all();
      return;
   }
   $o=$o->papa if ($o->{PAPA_CLASS} eq 'Hotel');
   my $hotel_name=$o->papa->papa->site_name.' - '.$o->site_name;
   print '<ul>';
   for(my $a=1;$a<=10;$a++){
      print '<li><a href="'.$o->{'photo'.$a}->href.'" id="mb'.$a.
	'" class="mb" title=\''.$hotel_name.'\'><img src="'.$o->{'small'.$a}->href.
	'" border=0></a><div class="multiBoxDesc mb'.$a.'" style="display:none"></div></li>' if $o->{'photo'.$a}->exists && $o->{'small'.$a}->exists;
   }
   print '</ul>';
   return;
}
sub images_all{
   my $o=shift;
   my $hotel_name=$o->papa->site_name.' - ';
   print '<ul>';
   for my $k($o->get_all){
    for(my $a=1;$a<=10;$a++){
      print '<li><a href="'.$k->{'photo'.$a}->href.'" id="mb'.$a.
        '" class="mb" title=\''.$hotel_name.$k->{name}.'\'><img src="'.$k->{'small'.$a}->href.
        '" border=0></a><div class="multiBoxDesc mb'.$a.'"></div></li>' if $k->{'photo'.$a}->exists && $k->{'small'.$a}->exists;
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
      $o->site_flatlist(shift,'','','',shift || 'ol_span');
   } else {
      $o->papa->site_flatlist(shift,0,'','',shift || 'ol_span');
   }
}
#sub contacts{
#   foreach my $k(split(',',shift->{contacts})){
#      print '<span>'.$k.'</span>';
#   }
#}
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
   # 疎̃ʑ ԉ͘Ϗ ՏӍКʔ
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
sub city_where{
   my $name=shift->{name};
   $name=~s/а$//;
   print $name.'е';
}
sub city_rekomenduem_name{
   my $name=shift->{name};
   $name=~s/а$//;
   print uc($name).'Е';
}
sub city_rekomenduem_hotels{
   my $o=shift;#$o is city
   my $new_line=0;
=head
   my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT hotel.ID 
	from dbo_Hotels as hotel, dbo_Page as stars,dbo_Page as nomera
	where hotel.PAPA_ID=? and hotel.PAPA_CLASS="Page" and 
	stars.PAPA_ID=hotel.ID ans stars.PAPA_CLASS="Page" and
	('.$CMSBuilder::hotels_rekomenduem.')');
   my $dbs->execute($o->{ID},);
=cut
   print '<ul>';
   my ($dbs,$row);
   foreach my $k(@{$CMSBuilder::Config::hotels_rekomenduem}){
      $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT papa.name as papa_name,
	hotel.photo1,hotel.name,hotel.ID,hotel.price_from,hotel.price_to
	from dbo_Hotel as hotel,dbo_Page as papa where hotel.PAPA_ID=papa.ID
	and hotel.ID=?');
      $dbs->execute($k);
      $row=$dbs->fetchrow_hashref;
      Encode::_utf8_on($row->{papa_name});
      Encode::_utf8_on($row->{name});
      Hotel->site_preview($row);
      $new_line++;
      if ($new_line==3){
	 print '</ul><ul>';
	 $new_line=0;
      }
   }
           while($row=$dbs->fetchrow_hashref){
              Encode::_utf8_on($row->{name});
              $row->{papa_name}=$o->{name};
              Hotel->site_preview($row);
              $new_line++;
              if ($new_line==3){
                 print '</ul><ul>';
                 $new_line=0;
              }
           }

   print '</ul>';
#   undef $CMSBuilder::hotels_rekomenduem;
   undef @{$CMSBuilder::Config::hotels_rekomenduem};
}
sub view_in_hotels{
   my $o=shift;
   if ($o->{name}!~/^(5 звезд|4 звезды|3 звезды|Мини отели|Рекомендуем)$/){
      print '
					<div class="hotel">
						<div class="place-lt" style="margin: 0 0 20px 3px;">
							<div class="place-rt">
								<div class="place-lb">

									<div class="onemore">
										<h2>'.($o->papaN(2)->{ID}==141?'Категории':'В гостинице').':</h2>
											';
   $o->site_flatlist(shift,0,'','','ol_span');

   print '									</div>
								</div>
							</div>
						</div>
					</div>
';
   } else {
      print '<style>.inner-page{margin:0 10px 0 0px};</style>';
   }
}
sub comments_preview{
   my $o=shift;
   shift;
   my $count=shift;# Number of hotels. For ex.,'5'
   my $is_city=shift;
   if($o->{name}=~/^(5 звезд|4 звезды|3 звезды|Мини отели|Гостиницы)$/ || $is_city){
      $o->comments_preview_hotels($count,$is_city);
      return;
   }
   my $view_hotel_div=shift;
   my ($dbs,$row,$count);
   $o=$o->papa if $o->myurl!~/Hotel/;
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
      print '<div class="hotel">' if $view_hotel_div;
      print '                                           <div class="guestbook">
                                                        <h3>Отзывы</h3>
                                                        <div>';
   while ($row=$dbs->fetchrow_hashref){
      Encode::_utf8_on($row->{username});
      Encode::_utf8_on($row->{desc});
      print '   <div>
                        <span>'.$row->{username}.'</span>
                        <p>'.$row->{desc}.'</p>
                </div>
      ';
   }
   print '                                              </div>
<span style="float:right;color:green;font-size:11px"><i>Всего '.$count.'</i></span>                                                </div>
   ';
   print '</div>' if $view_hotel_div;
}
sub marker_info{
   my $o=shift;
   my $r=shift;
   return unless $r->{id};
   my $row;
   #print '<ul>';
   my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT h.ID,h.name,h.photo1,
	h.price_from,h.price_to,p.name as papa_name
       from dbo_Hotel as h,dbo_Page as p where h.PAPA_CLASS="Page" and 
	h.PAPA_ID=p.ID and h.ID=?');
   $dbs->execute($r->{id});
   if($row=$dbs->fetchrow_hashref){
      $row->{info_href}=1;
      Encode::_utf8_on($row->{name});
      Encode::_utf8_on($row->{papa_name});
      Hotel->site_preview($row);
   } else {
      print "Hotel ".$r->{id}." not found";
   }
   #print '</ul>';
   return;
}
sub markers{
   my $o=shift;
   my $r=shift;
   my $sql;
#   my %headers =
#        (
#                'Content-type'          => 'plain/xml',
#                'Content-Disposition'   => 'filename=price.xml'
#        );
#   $CMSBuilder::IO::headers{'Content-type'}='plain/xml';
   my ($where,$row);
   #o->{hotels_id} - id of "Gostinicy" element
   my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT ID from dbo_Page 
	where PAPA_CLASS="Page" and PAPA_ID='.$o->{ID});
   $dbs->execute();
   while($row=$dbs->fetchrow_hashref){
      $where.='p.ID='.$row->{ID}.' or ';
   }
   $where=' and ('.substr($where,0,-4).')';
   if ($r->{z5} eq 'true' || $r->{z4} eq 'true' || $r->{z3} eq 'true' || 
	$r->{mini} eq 'true'){
      $where.=' and p.name not like "5%"' if $r->{z5} eq 'false';
      $where.=' and p.name not like "4%"' if $r->{z4} eq 'false';
      $where.=' and p.name not like "3%"' if $r->{z3} eq 'false';
      $where.=' and p.name<>"Мини отели"' if $r->{mini} eq 'false';
   }
   if ($r->{ot1k} eq 'true'){
      $where.=' and h.price_from>1000';
   } elsif($r->{ot2k} eq 'true'){
      $where.=' and h.price_from>2000';
   } elsif($r->{ot6k} eq 'true') {
      $where.=' and h.price_from>6000';
   }
   $where=' and h.metro="'.$r->{metro}.'"' if $r->{metro};
   foreach my $k(qw/wifi transfer excursies city_center vip/){
      $where=" and $k=1" if $r->{$k} eq 'true';
   }
#open(FILE,">/www/gogasat/headcall.ru/cmsbuilder/tmp/marker.log") or die $!;
#print FILE "!".$where;
#close(FILE);
   print '<markers>';
   $o->rpc_query('SELECT h.id,h.location,p.name
        from dbo_Hotel as h,dbo_Page as p
        where h.rekomenduem=1 and h.location<>"" and p.ID=h.PAPA_ID'.$where.' limit 10',1);
   $o->rpc_query('SELECT h.id,h.location,p.name
        from dbo_Hotel as h,dbo_Page as p
        where h.location<>"" and p.ID=h.PAPA_ID'.$where.' order by rand() limit 5');
   print "</markers>\n";
}
sub rpc_query{
   my $o=shift;
   my $sql=shift;
   my $icon=shift || 0;
   my $row;
   my $dbs=$CMSBuilder::DBI::dbh->prepare($sql);
   $dbs->execute();
   while($row=$dbs->fetchrow_hashref){
      ($row->{lat},$row->{lng})=split(",",$row->{location});
      print "<m id=\"$row->{id}\" lat=\"$row->{lat}\" lng=\"$row->{lng}\" icon=\"$icon\" />\n";
   }
}
sub comments_preview_hotels{
   #call from comments_preview only
   my $o=shift;
   my $count=shift;# Number of hotels. '5',etc
   my $is_city=shift;#$o is city object
   my ($row,$check,$sql1,$sql2);
   if ($o->{name} eq 'Гостиницы' || $is_city){
      $sql1='dbo_Page as p,'.($is_city?'dbo_Page as p2,':'');
      $sql2='p.PAPA_ID='.($is_city?'p2.ID and p2.PAPA_CLASS="Page" and p2.PAPA_ID=':'').$o->{ID}.' and p.PAPA_CLASS="Page" and h.PAPA_ID=p.ID';
   } else {
      $sql2='h.PAPA_ID='.$o->{ID};
   }
   my $dbs=$CMSBuilder::DBI::dbh->prepare('select c.username,c.desc,h.name,h.ID 
	from '.$sql1.'dbo_Hotel as h,dbo_CommentsDir as cd,
	dbo_Comment as c where h.rekomenduem=1 and '.$sql2.' and 
	cd.PAPA_ID=h.ID and c.PAPA_ID=cd.ID group by h.ID order by rand() limit '.$count);
   $dbs->execute();
   print '                                           <div class="v_news-block" style="'.($o->{name} eq 'Гостиницы'?'margin-left:7px;margin-right:0px;width:70%':'').'">
                                                        <div class="v_block-title">Отзывы</div>
                                                        ';
   while ($row=$dbs->fetchrow_hashref){
      Encode::_utf8_on($row->{username});
      Encode::_utf8_on($row->{desc});
      Encode::_utf8_on($row->{name});
      print '   <div class="v_news">
			<div class="v_title">'.$row->{name}.'</div>
                        <div class="v_text-reviews">'.$row->{username}.': '.$row->{desc}.'
<div><a href="/hotel'.$row->{ID}.'.html?comments">остальные отзывы..</a></div></div></div>
      ';
      $check=1;
   }
   print '<div class="v_news">Пока отсутствуют</div>' if !$check;

   print '                                              </div>
   ';
}
sub papa_hotel_info{
   my $o_orig=shift;
   my $o=$o_orig->papa;
   my $tel=(split(',',$o->papa->papa->papa->{contacts}))[1];
   print '<p>Контакты гостиницы &quot;';
   $o_orig->papa_hotel_site_name;
   print '&quot; в Санкт-Петербурге:</p>
<span style="color:#cd0017;font-size:16pt">Телефон бронирования: '.$tel.'</span>
<p><strong>Адрес:</strong> '.($o->{address} || '(no data)').'<br />
<strong>Ближайшее метро:</strong> '.CMSBuilder::cmsb_url($o->{metro})->{name}.'<br>
';
}
sub papa_hotel_id{
   print shift->papa->{ID};
}
sub root_icq{
   print shift->root->{icq};
}
sub root_skype{
   print shift->root->{skype};
}
sub papa_hotel_site_name{
   my $hotel_name=shift->papa->site_name;
   $hotel_name=~s/Гостиница //;
   print $hotel_name;
}
sub smotri_takge{
   my $o=shift;
   my $o_text;
   if ($o->myurl!~/Hotel/){
      $o_text=' - '.lc($o->{name}).' отеля';
      $o=$o->papa;
   } elsif ($ENV{QUERY_STRING} eq 'comments') {
      $o_text=' - отзывы об отеле';
   }
   return if $o->myurl!~/Hotel/;
   my $dbs=$CMSBuilder::DBI::dbh->prepare('select max(h1.ID) as h1id,min(h2.ID) as h2id 
	from dbo_Hotel as h1,dbo_Page as p1items,dbo_Page as p1hotels, 
	dbo_Hotel as h2,dbo_Page as p2items,dbo_Page as p2hotels where 
	h1.ID<? and h2.ID>? and p1items.ID=h1.PAPA_ID and 
	p1hotels.ID=p1items.PAPA_ID and p1hotels.PAPA_ID=141 and 
	p2items.ID=h2.PAPA_ID and p2hotels.ID=p2items.PAPA_ID and 
	p2hotels.PAPA_ID=141');
#'select max(h1.ID) as h1id,min(h2.ID) as h2id from dbo_Hotel as h1,dbo_Hotel as h2 where h1.ID<? and h2.ID>?');
   $dbs->execute($o->{ID},$o->{ID});
   next if !(my $row=$dbs->fetchrow_hashref);
   print '<br><br><b style="color:#41BDE3">Смотрите также:</b><p>';
   my $o2;
   foreach my $k(1..2){
    if ($row->{"h${k}id"}){
      $o2=CMSBuilder::cmsb_url('Hotel'.$row->{"h${k}id"});
      print '<a href="'.$o2->site_href.'">'.$o2->{name}.
	' Санкт-Петербург'.$o_text.'</a><br>';
    }
   }
}
sub get_img_alt{
   my $o=shift;
   my $name=$o->{name};
   my @ar;
   srand();
   if (POSIX::floor(rand()*10)%2==0){
      # {фото|фотография} {номера|спальни}
      $name.=' '.(POSIX::floor(rand()*10)%2==0?'фото':'фотография').' '.
        (POSIX::floor(rand()*10)%2==0?'номера':'спальни');
   } else {
      # {отели|гостиницы|мини отели|минигостиницы}
      # {Санкт-Петербурга|Петербурга|Питера|СПб}
      $name.=' ';
      @ar=('отели','гостиницы');
      if ($o->papa->{name}!~/^\d/){
         push(@ar,'мини отели');
         push(@ar,'мини гостиницы');
      }
      $name.=$ar[int(rand()*$#ar)].' ';
      @ar=('Санкт-Петербурга','Петербурга','Питера','СПб');
      $name.=$ar[int(rand()*$#ar)];
   }
   return $name;
}
sub site_footer_link{
   print shift->{link_text};
   return;
}
sub view_rooms_table{
   my $o=shift;
   print '<table class="rooms_table"><tr><th align="left">Название комнаты</th><th>&nbsp;</th><th align="left">Цена</th></tr>';
   foreach my $k($o->get_all){
      print '<tr><td>'.$k->{name}.'</td><td>&nbsp;</td><td>'.$k->{price}.'p</td></tr>';
   }
   print '</table>';
}
sub site_myurl{
   print shift->myurl;
}
sub print_contacts{
   my $o=shift;
   my $o_papa=$o->papa;
   print '<html><head><title>Печать контактов гостиницы</title>
	<script language="JavaScript" src="/googlemap.js"></script>
	<script src="http://maps.google.com/maps?hl=ru&file=api&amp;v=2&amp;key=ABQIAAAAQjofXjf8rI6r4AogwRg24xTmEemehnhnLGpB4DW9SHQLbMAVIBTBS2gvP0KLYWgkyKkDuBGxIDkZhQ"
	      type="text/javascript"></script>
    <script type="text/javascript">    
	var map = null;
	var geocoder = null;
	only_one=1;
        var hotels_papa_id=0;
	var elms=new Array('.$o_papa->{location}.',15);
    </script>
<style>.map{height:400px;clear:both}</style>
	</head><body onload="load();window.print()"><div style="float:right">
	<a href="#" onclick="window.print()"><img border=0 
	src="http://maps.google.ru/intl/ru_ru/mapfiles/transparent.png" 
	style="background:transparent url(http://maps.google.ru/mapfiles'.
	'/hpimgs11.png) no-repeat scroll -124px -43px;width:16px;height:'.
	'16px"></a> <a href="#" onclick="window.print()">Печать</a></div><br>
	<img src="/i2/logo.png" height="22" width="136" style="background:gray">
	<br><p>Контакты гостиницы &quot;';
	$o->papa_hotel_site_name;
	print '&quot;:
	<table><tr><td style="width:60%">';
   my $tel=(split(',',$o_papa->papa->papa->papa->{contacts}))[1];
   print '<span style="color:#cd0017;font-size:16pt">Контактный телефон:<br>'.$tel.'</span>
<p><strong>Адрес:</strong> '.($o_papa->{address} || '(no data)').'<br />
<strong>Ближайшее метро:</strong> '.CMSBuilder::cmsb_url($o_papa->{metro})->{name}.'<br>
';
   print '</td><td>Примечания<br><textarea cols="30" rows="4"></textarea>';
   print '</td></tr></table><p><div style="height:600px"><div id="map" 
	class="map"></div></div></body></html>';
}
sub select_stars{
   my $o=shift;
print '	<li><label><input type="checkbox"  name="hotel_type" id="z5" /><span class="star5"></span></label></li>
	<li><label><input type="checkbox" name="hotel_type" id="z4" /><span class="star4"></span></label></li>
	<li><label><input type="checkbox" name="hotel_type" id="z3" '.($o->{name} eq 'Москва'?'checked':'').' /><span class="star3"></span></label></li>
	<li><label><input type="checkbox" name="hotel_type" id="mini" '.($o->{name} eq 'Москва'?'':'checked').' />Мини отели</label></li>
';
}
sub city_rekhotels{
   #view N rand hotels
   my $o=shift;
   return '' if $o->{name} ne 'Контакты';
   my $dbs=$CMSBuilder::DBI::dbh->prepare('SELECT h.ID,
        p.name as hotel_type,h.ID,
        h.location,h.name,h.hotel_price,h.wifi,h.transfer,h.metro,
        h.excursies,h.city_center,h.vip from dbo_Hotel as h,
        dbo_Page as p where p.ID=h.PAPA_ID and
        h.PAPA_CLASS="Page" and h.rekomenduem=1 order by rand() limit 5');
   $dbs->execute();
   @{$CMSBuilder::Config::hotels_rekomenduem}=();
   while(my $row=$dbs->fetchrow_hashref()){
      push(@{$CMSBuilder::Config::hotels_rekomenduem},$row->{ID});
   }
   print '<span class="recommended"><h2>Рекомендуем:</h2></span><br><br><br><span class="contacts_rekhotels">';
   $o->city_rekomenduem_hotels;
   print '</span>';
}
sub hotel_href{
   my $o=shift;
   $o=$o->papa if ($o->myurl!~/Hotel/);
   print '/'.lc($o->myurl).'.html';
}
sub link_exchange{
   my $o=shift;
   
my @xtext=('Сайт является привелигированным участником <a href=http://www.mplaces.ru/>службы бронирования {отелей|гостиниц} {Петербурга|Санкт-Петербурга} mplaces.ru</a>',
'Информацию о нашем сайты вы также можете найти на страницах <a href=http://www.mplaces.ru/>сервиса бронирования {гостиниц|отелей} {Петербурга|Санкт-Петербурга} mplaces.ru</a>',
'Рекомендации нашей гостиницы вы можете посмотреть <a href=http://www.mplaces.ru/>на сайте {гостиниц|отелей} {Петербурга|Санкт-Петербурга} mplaces.ru</a>',
'Наш отель добавлен в базу данных <a href=http://www.mplaces.ru/>{лучших|рекомендованных} {гостиниц|отелей} {Петербурга|Санкт-Петербурга} mplaces.ru</a>',
'Описания и рекомендации отеля представлены <a href=http://www.mplaces.ru/>в {каталоге|справочнике} {гостиниц|отелей} {Петербурга|Санкт-Петербурга} mplaces.ru</a>',
'Отель состоит в числе рекомендованных участников <a href=http://www.mplaces.ru/>системы бронирования {отелей|гостиниц} {Петербурга|Санкт-Петербурга} mplaces.ru</a>'
);
my $use_cookie=(time-$sess->{links_time}>60*60*24?0:1);
my $img='ok5_32x32_'.sprintf("%.0f",4*rand()).'.jpg';
my @ar;
foreach my $a(0..5){
#   $xtext[$a]=~s/</\&lt;/g;
#   $xtext[$a]=~s/>/\&gt;/g;
   @ar=($use_cookie?@{$sess->{"links_$a"}}:());
#print join(',',@{$sess->{"links_$a"}}).": ".join(',',@ar)."!!!<br>";
   @ar=view_synonim($xtext[$a],@ar);
   $xtext[$a]=shift @ar;
#print join(',',@ar)."!<br>";
   $sess->{"links_$a"}=\@ar if !$use_cookie;
#print join(',',@{$sess->{"links_$a"}})."<br><br>";
}
if (!$use_cookie){
   $sess->{"links_img"}=$img;
   $sess->{links_time}=time();
} else {
   $img=$sess->{"links_img"};
}
my $txt='<p><textarea name="1" style="width: 530px; background-color: rgb(234, 244, 196);" rows="2" cols="1">';
my $lnk='<a href="http://mplaces.ru/"><img src="http://mplaces.ru/images/'.$img.'"> ';
print $xtext[0].$txt.$xtext[0]."</textarea><p>".
      $xtext[1].$txt.$xtext[1]."</textarea><p>".
      $xtext[2].$txt.$xtext[2]."</textarea><p>".
      $xtext[3].$txt.$xtext[3]."</textarea><p>".
      $xtext[4].$txt.$xtext[4]."</textarea><p>".
      $xtext[5].$txt.$xtext[5]."</textarea><p><b>Вариант с иконой-питограмой</b><p>".
      $lnk.$xtext[0].'</a>'.$txt.$lnk.$xtext[0]."</a></textarea><p>".
      $lnk.$xtext[1].'</a>'.$txt.$lnk.$xtext[0]."</a></textarea><p>".
      $lnk.$xtext[2].'</a>'.$txt.$lnk.$xtext[0]."</a></textarea><p>".
      $lnk.$xtext[3].'</a>'.$txt.$lnk.$xtext[0]."</a></textarea><p>".
      $lnk.$xtext[4].'</a>'.$txt.$lnk.$xtext[0]."</textarea><p>".
      $lnk.$xtext[5].'</a>'.$txt.$lnk.$xtext[0]."</textarea><p>";
}
sub view_synonim{
   my $text=shift;
   my @val=@_;
   my ($tmp,$rnd,@res);#res-́̉àϏ΅Ӂ яœՁϏ؏ɠÙ͉ ؙÒ׍
   while($text=~/\{([^\|]+)\|([^\|]+)\}/){
      $rnd=($#val!=-1?shift @val:sprintf("%.0f",rand()));
      $tmp=($1,$2)[$rnd];
      $text=~s/\{[^\|]+\|[^\|]+\}/$tmp/;
      push(@res,$rnd);
   }
   return ($text,@res);
}
sub hotels_another{
   my $o=shift;
   shift;
   my $name=$o->papaN(2)->{name};
   if (substr($name,-1) eq 'а'){# ԋ͏ϑƍ ρۗʅ ȏӏŁ
      $name=substr($name,0,-1).'ы';
   } else {
      $name.='а';
   }
   print "<a href='".$o->papaN(3)->site_href."'>
<span class='nav-left'></span>
<span class='nav-inner'>
Каталог гостиниц ".$name."</a>
</span>
<span class='nav-right'></span>
";
}
