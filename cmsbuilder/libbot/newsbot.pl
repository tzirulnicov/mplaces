# Поломан, bquestion вместо catwaresimple
#!/usr/bin/perl
# Из-за использования системного date() скрипт работает только в *nix !
BEGIN{
   use FindBin qw($Bin);
   $errorMailNotify=1;
   $errorMailBox="tz\@tz.ints.ru";
   $FromEMail="tz\@tz.ints.ru";
   $splitStringsChar="\n";
   $logConsole=1;
   $splitStringsChar="\n";
   $DEBUG=1;
   require "$Bin/func.pl";
}
use cyrillic qw/win2koi koi2win/;
use Image::Magick;

local $DEBUG=1;
# По сколько новостей с каждого из сайтов мы вытягиваем при каждом запуске скрипта
local $news_per_circuit=5;
local $save_img_path='/www/gogasat/headcall.ru/htdocs/ee/wwfiles';
local $save_img_url='http://headcall.ru/ee/wwfiles';
# Если при запуске нижеперечисленные модули получают контент,
#уже имеющийся в базе, то уже имеющийся обновляется параметрами этого контента 
# т.е., происходит обновление контента. Нап.: 'RU::Sharerector'
local @update_by=(
#'RU::BESTKINO'
);
# Модули, которые игнорируем
local @ignore=(
'RU::PILOTAGE_RC'
#'RU::Sharereactor'
);
# ignore urls
local @ignore_urls=(
#'/wiki/test'
);
local ($handle,$row,$db_shandleAr,$row_lastpostid,$dbs,$loop_count,$subj,$body,$check);
#local $check_first=1;
local $max_id=0;
my ($link,$link_id,$record_id,@row_foreign,$ds,$ds_row);
local $total_news=0;# Сколько всего мы скачали новостей.
#Если менее 5, то недостающие раскрываем из архива в БД
local ($first_page_id,$num);
sql_connect();
sql_connect('NewsBot',1);
=head
@elms=elm_search(class=>'Hotel',select=>'name,count(ID) as cnt',
	where=>'1 group by name having cnt>1');
foreach my $k(@elms){
   @elms2=elm_search(class=>'Hotel',where=>'name="'.$k->{name}.'" limit 1,100');
   foreach my $k2(@elms2){
      elm_del('Hotel'.$k2->{ID});
      print $k2->{ID}."!\n";
   }
}
sql_close(1);
sql_close();
exit;
=cut
sql_query('SELECT news_id,news_PAPA_PAGE,news_driver,news_status,
	news_group,news_lastpostid,news_resource,news_url,news_crc
	from news_hosts where news_enable=1');
while ($row=$db_shandle->fetchrow_hashref()){
   next if grep($_ eq $row->{'news_driver'},@ignore);
   dieLog('Getting news from '.$row->{'news_driver'}.'...',1) if $DEBUG;
   eval("use WWW::".$row->{'news_driver'}.";");
   die $@ if $@;
   $handle=eval("return WWW::".$row->{'news_driver'}."->new();");
   next if news_die($@,$row->{'news_driver'});
   #$check_first=1;
   $max_id=0;
   $count=0;
   if ($handle->list_item(GROUP=>$row->{'news_group'},
        SINCE_ID=>$row->{'news_lastpostid'}+1,DEBUG=>$DEBUG,
        SINCE_RESOURCE=>$row->{'news_resource'},
        SINCE_URL=>$row->{'news_url'},
	SINCE_CRC=>$row->{'news_crc'},
	IGNORE_URLS=>\@ignore_urls,
#        LIMIT=>1
        )){
#@{$handle->{links}}='/film/man_of_the_year.html';
      while ($handle->get_topic(
	SAVE_IMG_PATH=>$save_img_path,SAVE_IMG_URL=>$save_img_url,
	DEBUG=>$DEBUG,
	SLEEP=>2)){
	 $count++;
         sql_connect('NewsBot',1);
         #last if $loop_count>$news_per_circuit;
	 $handle->{'content_subj'}=~s/[\r\n]+/ /;
	 $handle->{'content_subj'}=~s/ +$//;
         $handle->{'content_subj'}=~s/^ +//;
         $subj=substr($handle->{'content_subj'},0,100);#limit in db
         next if !$subj;# || !-e $save_img_path."/".$handle->{'content_image'}
		#|| !$handle->{'content_image'};
	 #next if $handle->{'content_year'}!~/200[678]/;
	 #$body=WWW::GET->typograf($handle->{'content_body'});
	 print "Subject: ".win2koi($subj)."\n" if $DEBUG;
         # Запоминаем, что данный фильм уже обрабатывали
         if ($handle->{content_id}>$max_id || $count==1){
            # Если идентификация по content_id, и id поста более max_id;
            # Либо если идентификация по content_url, и пост-первый
            $max_id=$handle->{'content_id'};
            ## Только что обработали первый пост, содержащий самый большой ID,
            ## заносим его в БД в lastpostid
            $ds=$db_handleAr[1]->prepare('UPDATE news_hosts set
                news_lastpostid=?,news_resource=?,news_url=?,news_crc=? where news_id=?');
            $ds->execute($max_id,$handle->{'content_resource'},
                $handle->{'content_url'},$handle->{'item_crc'},$row->{'news_id'});
         }
         $ds=$db_handleAr[1]->prepare('SELECT * from dbo_Hotel
		where name=?');#,photo
         $ds->execute("цНЯРХМХЖЮ $subj");
         #next if ($ds_row=$ds->fetchrow_hashref);
=head
    foreach my $k(($handle->{'content_image'},@{$handle->{'content_images'}})){
	 # resize image to 365x252
	 my($image, $x);
	 print "Resizing image: |".$k."|\n";
         $image = Image::Magick->new;
	 $x = $image->Read($save_img_path."/".$k);
	 ($ox,$oy)=$image->Get('base-columns','base-rows'); 
	 next if !$ox || !$oy;
	 if ($ox>182){
	    $ny=int(($oy/$ox)*182);
	    $image->Resize(geometry=>geometry, width=>182, height=>$ny);
	 #if ($nx>365){
	 #   $nnx=int(($nx-365)/2);
	 #   $image->Crop(x=>$nnx, y=>0);
   	 #   $image->Crop('365x252');
	 #}
	 #$k=~/^(.*?)\.(\w+)$/;
	    $x = $image->Write($save_img_path."/".$k);
	 }
    }
=cut
 if ($ds_row=$ds->fetchrow_hashref){
print "Update...\n";
foreach my $k(@{$handle->{'content_images'}}){
   unlink($save_img_path.'/'.$k);
}
update_record($handle,$ds_row);
next;
}
	 # insert content in DB
#print "Insert...\n";
#         $page_id=insert_record($handle,$row->{'news_PAPA_PAGE'});
#print "Succesfully inserted with id $page_id\n";
	 sql_close(1);
      }
   }
   next if news_die($handle->{'errmsg'},$row->{'news_driver'});
   if (!$row->{'news_status'} || !$row->{'news_lastpostid'}){
      sql_connect('NewsBot',1);
      sql_query("UPDATE news_hosts set news_status=1,news_errmsg=''
	where news_id=".$row->{'news_id'},'NewsBot',1);
      sql_close(1);
   }
}
if ($total_news<5){
   # Раскрываем на главную (5-$total_news) новостей из архива
=head
   sql_query('update dbo_News set hidden=1'.
	($first_page_id?' where ID<'.$first_page_id:''));
   sql_query('select ID,name from dbo_News order by rand() limit '.
	(5-$total_news));
   my $sql='UPDATE dbo_News set hidden=0 where ';
   while($row=$db_shandle->fetchrow_hashref){
      print "Extracting ".win2koi($row->{name}." for main page\n") if $DEBUG;
      $sql.='ID='.$row->{ID}.' or ';
   }
   $sql=substr($sql,0,-4);
=cut
#   $sql='UPDATE dbo_News set hidden=0 where hidden=1 limit '.
#	(5-$total_news);
#   sql_query($sql);
}
print "\nOK\n";
#sql_close(1);
sql_close();
sub update_record{
   my $handle=shift;
   my $ds_row=shift;
   my ($ds,$ds_row2,$temp,$insert_id,$room_id);
   sql_query('SELECT ID from dbo_Page where PAPA_CLASS="Hotel" and PAPA_ID='.
	$ds_row->{ID}.' and name="мНЛЕПЮ"','NewsBot',1);
   next if !($row=$db_shandleAr[1]->fetchrow_hashref);
   $room_id=$row->{ID};
   foreach my $room(@{$handle->{content_hotel_nomera}}){
      sql_query('SELECT ID,price from dbo_Page
	where name="'.Str2Sql($room->{name}).'" and PAPA_CLASS="Page" and 
	PAPA_ID='.$room_id,'NewsBot',1);
      if ($row=$db_shandleAr[1]->fetchrow_hashref){
	 next if $row->{price};
	 sql_query('UPDATE dbo_Page set price="'.$room->{price}.'" where ID='.
		$row->{ID},'NewsBot',1);
      } else {
         elm_add(
           papa=>"Page$room_id",
           child=>"Page",
           name=>$room->{name},
           price=>$room->{price}
         );
      }
   }
   return if $ds_row->{address};
#!!
print ".address: ".win2koi($handle->{content_hotel_address})."\n";
   sql_query('UPDATE dbo_Hotel set address="'.$handle->{content_hotel_address}.
	'" where ID='.$ds_row->{ID},'NewsBot',1);
   #my $init=WWW::GET->new(WWW::GET->hostname($save_img_url));
   #$init->get('/catwaresimple'.$ds_row->{ID}.'.html?init=1',NoEncoding=>1);
   #if (index($init->{'net_http_content'},'<html')==-1){
   #   print "##########################";
   #   print "Problem with get /catwaresimple".$ds_row->{ID}.".html\n";
   #   print "##########################";
   #}
   return 1;
}
sub get_img_xy{
   my $path=shift;
   my $image = Image::Magick->new;
   my $x = $image->Read($save_img_path.'/'.$path);
   my ($ox,$oy)=$image->Get('base-columns','base-rows');
   return ($ox,$oy);
}
sub news_die{
   my $errmsg=shift;
   return 0 if !$errmsg;
   my $driver=shift;
   print "Error: $errmsg\n";
   #sql_query(
   $db_handle->do("UPDATE news_hosts set news_status=0,news_errmsg=\"".Str2Sql($errmsg).'"
	where news_driver="'.$driver.'"');
   1;
}
sub getUrls{
   # Get all local urls from page
   my $html=shift;
   my $site='www.vch.ru';
   my $p=HTML::Parser->new(api_version => 3);
   $p->handler(start=>\&getUrls_start,'self,tagname,attr');
   $p->parse($html);
   return @{$p->{'links'}};
}
sub getUrls_start{
   my ($p,$tag,$attr)=@_;
   return if $tag ne 'a';
   #print "|$tag,".$attr->{'href'}."|\n";
   push(@{$p->{'links'}},$attr->{'href'});
}
sub insert_record{
   my $handle=shift;
   my $papa_id=shift;
   my $subj=$handle->{'content_subj'};
   my ($page_id,$row);
   my @date;
   my ($tags,$multiprop_id,$screenshots_id,$photo_id,$max_num,$metro_id);
   my $old_papa_id=$papa_id;
   # Get stars page
   my $dbs=$db_handleAr[1]->prepare('SELECT ID from dbo_Page where PAPA_ID=? '.
	'and PAPA_CLASS="Page" and name=?');
   $handle->{content_hotel_type}=~s/z5/5 ГБЕГД/;
   $handle->{content_hotel_type}=~s/z4/4 ГБЕГДШ/;
   $handle->{content_hotel_type}=~s/z3/3 ГБЕГДШ/;
   $handle->{content_hotel_type}=~s/mini/лХМХ/;
   $dbs->execute($papa_id,$handle->{content_hotel_type});
   die "Can't find papa for this item!" if !($row=$dbs->fetchrow_hashref);
   $papa_id=$row->{ID};
   print "Papa page: $papa_id\n" if $DEBUG;
   # Get metro station
   my $dbs=$db_handleAr[1]->prepare('SELECT metro.ID as mID,station.ID as sID
	from dbo_Metro as metro,dbo_Page as page
	left join dbo_Station as station on 
	station.PAPA_ID=metro.ID and station.name=?
	where page.ID=? and metro.PAPA_ID=page.PAPA_ID');
   $dbs->execute($handle->{content_hotel_metro},$old_papa_id);
   die "Can't find metro for this item!" if !($row=$dbs->fetchrow_hashref);
   print "metro id: $row->{mID}, station id: $row->{sID}\n";
   if ($row->{sID}){
      $metro_id=$row->{sID};
   } else {
      $metro_id=elm_add(
	papa=>"Metro$row->{mID}",
	child=>'Station',
	name=>$handle->{content_hotel_metro}
      );
   }
   # Adding hotel in DB
   $handle->{content_body}=~s/<a .*?<\/a>//g;
   $handle->{content_body_room}=~s/<a .*?<\/a>//g;
   $handle->{content_body_contacts}=~s/<a .*?<\/a>//g;
   $page_id=elm_add(
	papa=>"Page$papa_id",
	child=>"Hotel",
	photo1=>$handle->{content_images}->[0],
	photo2=>$handle->{content_images}->[1],
	photo3=>$handle->{content_images}->[2],
	photo4=>$handle->{content_images}->[3],
	photo5=>$handle->{content_images}->[4],
	photo6=>$handle->{content_images}->[5],
	photo7=>$handle->{content_images}->[6],
	photo8=>$handle->{content_images}->[7],
	photo9=>$handle->{content_images}->[8],
	photo10=>$handle->{content_images}->[9],
	name=>'цНЯРХМХЖЮ '.$handle->{content_subj},
	content=>$handle->{content_body},
	metro=>"Station$metro_id",
	price_from=>$handle->{content_price_from},
	price_to=>$handle->{content_price_to},
#	hotel_price=>($handle->{content_hotel_price}>=6000?'ot6k':
#		($handle->{content_hotel_price}>=2000?'ot2k':'ot1k')),
	template=>'TextTemplate7',
	address=>$handle->{content_hotel_address}
   );
   # Adding rooms of hotel in DB
   my $room_id=elm_add(
	papa=>"Hotel$page_id",
	child=>"Page",
	name=>"мНЛЕПЮ",
	template=>'TextTemplate6',
	content=>$handle->{content_body_room}
   );
   foreach my $room(@{$handle->{content_hotel_nomera}}){
      elm_add(
	papa=>"Page$room_id",
	child=>"Page",
	name=>$room->{name},
	price=>$room->{price}
      );
   }
   # Adding contacts
   elm_add(
	papa=>"Hotel$page_id",
	child=>"Page",
	name=>"йНМРЮЙРШ",
	content=>"<strong>пЮИНМ:</strong> ".$handle->{content_hotel_rayon}."<br>".$handle->{content_body_contacts},
	template=>"TextTemplate17"
   );
   # Adding feedback
   elm_add(
	papa=>"Hotel$page_id",
	child=>"modFeedback",
	name=>"аПНМХПНБЮМХЕ"
   );
   my $init=WWW::GET->new(WWW::GET->hostname($save_img_url));
   $init->get('/hotel'.$page_id.'.html?init=1',NoEncoding=>1);
   if (index($init->{'net_http_content'},'<html')==-1){
      print "##########################";
      print "Problem with get /catwaresimple$page_id.html\n";
      print "##########################";
   }
   return $page_id;
}
sub elm_add{
   my %arg=@_;
   # Usage: elm_add(papa=>'Page45',child=>'Page',check_papa=>,[...another args...]);
   # check_papa should be '1' for checking if papa exists
   die "Bad papa '$arg{papa}'" if $arg{papa}!~/^[a-zA-Z]+\d+$/;
   die "Bad child '$arg{child}'" if $arg{child}!~/^\w+$/;
   my ($sql1,@sql2,$sql3,$insert_id);

   foreach my $key(keys %arg){
      next if $key=~/^(papa|child)$/;
      $sql1.=$key.',',
      push(@sql2,"".$arg{$key});
      $sql3.='?,';
   }
   $sql1=substr($sql1,0,-1);
   $sql3=substr($sql3,0,-1);
   $sql1='INSERT into dbo_'.$arg{child}.' (CTS,OWNER,
        PAPA_CLASS,PAPA_ID,start,end'.($sql1?',':'').$sql1.') values (
	now(),"User1",?,?,curdate(),curdate()'.($sql1?',':'').$sql3.')';
   $arg{papa}=~/^([a-zA-Z]+)(\d+)$/;
#print "\n".$sql1."\n\n$1,$2,".join(',',@sql2)."\n";
#exit;
   $db_handleAr[1]->do($sql1,undef,$1,$2,@sql2);

   $insert_id=$db_handleAr[1]->{'mysql_insertid'};

   $sql1='UPDATE relations set num=num+1 where aurl=?';
   $db_handleAr[1]->do($sql1,undef,$arg{papa});
   $sql1='INSERT into relations(aurl,num,ourl,type,date) values (?,1,?,
	"child",curdate())';
   $db_handleAr[1]->do($sql1,undef,$arg{papa},$arg{child}.$insert_id);
   return $insert_id;
}
sub elm_del{
   my $myurl=shift;
   # Usage: elm_del('Page45')
   if ($myurl!~/^([A-Z][a-z]+)(\d+)$/){
      die("elm_del(): bad element '$myurl'");
   }
   my ($elm_class,$elm_id)=($1,$2);
   my $sql='SELECT ourl from relations where aurl=?';
   my $dbs=$db_handleAr[1]->prepare($sql);
   my $row;
   $dbs->execute();
   while($row=$dbs->fetchrow_hashref){
      elm_del($row->{ourl});
   }
   $sql='DELETE from dbo_'.$elm_class.' where ID='.$elm_id;
   $db_handleAr[1]->do($sql);
#SELECT name, count( ID ) AS cnt FROM dbo_Hotel GROUP BY name HAVING cnt >=1
}
sub elm_search{
   my %arg=@_;#usage:elm_search{class=>'Page'[,where=>'sql_where'][,select=>'tel,count(ID) as cnt']}
   my $sql='SELECT ID'.($arg{'select'}?','.$arg{'select'}:'').' from dbo_'.$arg{class}.' where '.$arg{where};
#print $sql."\n";
   my $dbs=$db_handleAr[1]->prepare($sql);
   my ($row,@res);
   $dbs->execute();
   while($row=$dbs->fetchrow_hashref){
      push(@res,$row);
   }
   return @res;
}
1;
