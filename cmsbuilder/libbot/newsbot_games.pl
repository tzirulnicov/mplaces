#!/usr/bin/perl
# Из-за использования системного date() скрипт работает только в *nix !
# Радиоуправляемые модели
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
local $save_img_path='/www/evoo/evoo.ru/htdocs/ee/wwfiles';
local $save_img_url='http://evoo.ru/ee/wwfiles';
# Если при запуске нижеперечисленные модули получают контент,
#уже имеющийся в базе, то уже имеющийся обновляется параметрами этого контента 
# т.е., происходит обновление контента. Нап.: 'RU::Sharerector'
local @update_by=(
#'RU::BESTKINO'
);
# Модули, которые игнорируем
local @ignore=(
'NL::ORIENTALGROWERS'
#'RU::PILOTAGE_RC'
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
#sql_connect('NewsBot',1);
sql_query('SELECT news_id,news_PAPA_PAGE,news_driver,news_status,
	news_group,news_lastpostid,news_resource,news_url,news_crc
	from news_hosts where news_enable=1');
while ($row=$db_shandle->fetchrow_hashref()){
   #next if grep($_ eq $row->{'news_driver'},@ignore);
   next if $row->{'news_driver'} ne 'RU::PILOTAGE_RC' and 
	$row->{'news_driver'} ne 'NL::ORIENTALGROWERS';
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
        #LIMIT=>10
        )){
#@{$handle->{links}}='/film/man_of_the_year.html';
      while ($handle->get_topic(
	SAVE_IMG_PATH=>$save_img_path,SAVE_IMG_URL=>$save_img_url,
	DEBUG=>$DEBUG)){
	 $count++;
         sql_connect('NewsBot',1);
         #last if $loop_count>$news_per_circuit;
	 $handle->{'content_subj'}=~s/[\r\n]+/ /;
	 $handle->{'content_subj'}=~s/ +$//;
         $handle->{'content_subj'}=~s/^ +//;
         $subj=substr($handle->{'content_subj'},0,50);#limit in db
         next if !$subj;# || !-e $save_img_path."/".$handle->{'content_image'}
		#|| !$handle->{'content_image'};
	 #next if $handle->{'content_year'}!~/200[678]/;
	 #$body=WWW::GET->typograf($handle->{'content_body'});
	 print "Subject: ".win2koi($subj)."\n" if $DEBUG;
	 # Запоминаем, что данный фильм уже обрабатывали
         if ($handle->{'content_id'}>$max_id || $count==1){
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
	 # Проверяем, имеется ли такой фильм в базе
         $ds=$db_handleAr[1]->prepare('SELECT * from dbo_CatWareSimple
		where name=? and artikul=?');#,photo
         $ds->execute($subj,"".$handle->{content_artikul});
         #next if ($ds_row=$ds->fetchrow_hashref);
=head

	if ($ds_row=$ds->fetchrow_hashref){
        if (0&& grep($_ eq $row->{'news_driver'},@update_by)){
	  #  dieLog("Change information about this film...",1);
	  #  update_record($handle,$ds_row);
          #  next;
	 } else {
	    # Удаляем картинки поста, который игнорим
#	    dieLog("Ignoring...",1);
	    dieLog("Updating...",1);
	    foreach my $k(($handle->{'content_image'},@{$handle->{'content_images'}})){
	       dieLog("Can't delete $k!",1) if !unlink($save_img_path."/$k");
	    }
	    update_record($handle,$ds_row);
	    next;
	 }}
=cut
if (!$handle->{content_previmg}){
    foreach my $k(($handle->{'content_image'},@{$handle->{'content_images'}})){
	 next if !$handle->{'content_image'};
	 # resize image to 365x252
	 my($image, $x);
	 print "Resizing image: |".$k."|\n";
         $image = Image::Magick->new;
$k=~/^(.*?)(\.[^\.]+)$/;
$tmp=$1."_big$2";
`cp $save_img_path/$k $save_img_path/$tmp`;
print "Copy $k to $tmp\n";
$handle->{'content_imagebig'}=$tmp;
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
    }}
 if ($ds_row=$ds->fetchrow_hashref){
print "Update...\n";
#update_record($handle,$ds_row);
next;
}
	 # insert content in DB
print "Insert...\n";
         $page_id=insert_record($handle,$row->{'news_PAPA_PAGE'});
print "Succesfully inserted with id $page_id\n";
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
return;
   my $handle=shift;
   my $ds_row=shift;
   my ($ds,$ds_row2,$temp,$insert_id);
#update photos
   my @img=grep{$_}($handle->{'content_image'},@{$handle->{'content_images'}});
   my @img_ds=grep{$_}($ds_row->{photo},$ds_row->{photobig2},$ds_row->{photobig3});
   # Картинки,которые будем забивать в БД
   my @img2db;
   my $check=0;# Если уже существующие в базе фотки заменяем на выкачанные, то 
   # ставим $check=1. $check=0 - это означает, что при забивке недостающих точек мы берём
   # выкачанные фотки с последними номерами (5,4,...), а не первыми (1,2,...)
   if ($#img_ds<2 && $#img>$#img_ds){
      # Нужно ли перезаливать первую/вторую картинку из базы ? (Да, если она меньше той, которую мы загрузили)
      for (my $a=0;$a<2;$a++){
         if (-e $save_img_path.'/'.$img_ds[$a] && -e $save_img_path.'/'.$img[$a]){
            ($x1,$y1)=get_img_xy($img[$a]);
            ($x2,$y2)=get_img_xy($img_ds[$a]);
            if ($x1<$x2 and $y1<$y2){
	       dieLog("Can't delete ".$img[$a]."!",1) if !unlink($save_img_path."/".$img[0]);
	       $img2db[$a]=$img_ds[$a];
	       $img_ds[$a]=0;# впоследствии не удалять эту фотку
	       $check=1;
            }
         }
      }
      for (my $a=0;$a<3;$a++){
	 if ($img[$a] && -e $save_img_path.'/'.$img[$a]){
	    if ($check){
	       $img2db[$a]=$img[$a];
	    } else {
	       $img2db[$a]=pop @img;
	    }
	 } elsif ($img_ds[$a] && -e $save_img_path.'/'.$img_ds[$a]){
            $img2db[$a]=$img_ds[$a];
	    $img_ds[$a]=0;
            dieLog("Can't delete ".$img[$a]."!",1) if ($img[$a] && !unlink($save_img_path."/".$img_ds[$a]));
	 }
      }
      for (my $a=0;$a<=$#img_ds;$a++){
	 dieLog("Can't delete ".$img_ds[$a]."!",1) if ($img_ds[$a] && !unlink($save_img_path.'/'.$img_ds[$a]));
      }
   } else {
      @img2db=@img_ds;
      for (my $a=0;$a<=$#img;$a++){
         dieLog("Can't delete ".$img[$a]."!",1) if ($img[$a] && !unlink($save_img_path.'/'.$img[$a]));
      }
   }
   sql_query('UPDATE dbo_CatWareSimple set photo="'.$img2db[0].
	'",photobig2="'.$img2db[1].'",photobig3="'.
	$img2db[2].'" where id='.$ds_row->{ID},'NewsBot',1);
   my $init=WWW::GET->new(WWW::GET->hostname($save_img_url));
   $init->get('/catwaresimple'.$ds_row->{ID}.'.html?init=1',NoEncoding=>1);
   #if (index($init->{'net_http_content'},'<html')==-1){
   #   print "##########################";
   #   print "Problem with get /catwaresimple".$ds_row->{ID}.".html\n";
   #   print "##########################";
   #}
#update tech. params
   $handle->{'content_fields'}->{'price'}=$handle->{'content_price'};
   #$handle->{'content_fields'}->{'desc'}=$handle->{'content_body'};
   foreach my $k(keys %{$handle->{'content_fields'}}){
      # Апдейтим только те поля, которые ещё не заполнены
      next if ($k eq 'type' || $ds_row->{$k});
      sql_query('UPDATE dbo_CatWareSimple set `'.$k.'`="'.
        Str2Sql($handle->{'content_fields'}->{$k}).'"
        where ID='.$ds_row->{ID},'NewsBot',1);
   }
return 1;
   # Delete images
   dieLog("Delete $save_img_path/".$ds_row->{'photo'},1) if $DEBUG;
   unlink($save_img_path."/".$row->{'photo'});
   if ($ds_row->{screenshots}){
      sql_query('SELECT loadedphoto from dbo_Photo where
	PAPA_CLASS="modGallery" and PAPA_ID='.$ds_row->{'screenshots'},1,1);
      if ($ds_row2=$db_shandleAr[1]->fetchrow_hashref){
         dieLog("Delete $save_img_path/".$ds_row2->{loadedphoto},1) if $DEBUG;
         unlink($save_img_path."/".$ds_row2->{loadedphoto});
      }
      sql_query('DELETE from dbo_Photo where PAPA_CLASS="modGallery" and
	PAPA_ID="'.$ds_row->{screenshots}.'"',1,1);
      sql_query('DELETE from relations where aurl="modGallery'.
	$ds_row->{screenshots}.'"',1,1);
   } else {
      sql_query('INSERT into dbo_modGallery (CTS,OWNER,
        PAPA_CLASS,PAPA_ID) values (now(),"User1","Film","'.
	$ds_row->{ID}.'")',1,1);
      $ds_row->{screenshots}=$db_handleAr[1]->{'mysql_insertid'};
   }
   # Adding screenshots in DB
   sql_query('SELECT max(num) as mx from relations where aurl="modGallery'.
        $ds_row->{screenshots}.'"',1,1);
   $temp=1;
   $temp=$ds_row2->{mx} if ($ds_row2=$db_shandleAr[1]->fetchrow_hashref);
   foreach my $k(@{$handle->{content_images}}){
      $ds=$db_handleAr[1]->prepare('INSERT into dbo_Photo (CTS,OWNER,PAPA_CLASS,
	PAPA_ID,loadedphoto) values (now(),"User1","modGallery",?,?)');
      $ds->execute($ds_row->{screenshots},$k);
      $insert_id=$db_handleAr[1]->{'mysql_insertid'};
      $ds=$db_handleAr[1]->prepare('INSERT into relations values (?,?,?,"child")');
      $ds->execute("modGallery".$ds_row->{screenshots},++$temp,"Photo$insert_id");
   }
   $ds=$db_handleAr[1]->prepare('UPDATE dbo_Film set photo=?,screenshots=?
	where ID=?');
   $ds->execute($handle->{content_image},$ds_row->{screenshots},$ds_row->{ID});
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
   sql_query("UPDATE news_hosts set news_status=0,news_errmsg=\"".Str2Sql.'"
	where news_driver="'.$errmsg.'"','NewsBot',1);
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
print "|>$subj<|";
   my ($page_id,$row,$tmp);
   my @date;
   my ($tags,$catdir_id,$multiprop_id,$screenshots_id,$photo_id,$max_num);
   $dbs=$db_handleAr[1]->prepare('SELECT ID from dbo_CatDir where
	ID=?');
   $dbs->execute($papa_id);
   die "Can't find catdir for this item!" if !($catdir_id=$dbs->fetchrow_hashref);
   #begin Tags
    my @tags=();
    $dbs=$db_handleAr[1]->prepare('SELECT t.ID from dbo_modTags as mt,dbo_Tag as t 
	where (mt.name=? or mt.name=?) and t.PAPA_ID=mt.ID and t.name=?');
    $dbs->execute($handle->{'content_nav'}->[$#{handle->{'content_nav'}}-1].'-'.
        koi2win('теги'),$handle->{'content_nav'}->[$#{handle->{'content_nav'}}-1],
	$handle->{'content_nav'}->[$#{handle->{'content_nav'}}]);
    push(@tags,'Tag'.$row->{ID}) if ($row=$dbs->fetchrow_hashref);
#print win2koi($handle->{'content_nav'}->[$#{handle->{'content_nav'}}-1]).'-'."\n";
print "tags: |",join(',',@tags),"|";
#exit;
   #end Tags
   #begin modCatalog
    my $tmp=$handle->{'content_nav'}->[$#{$handle->{'content_nav'}}-1];
    $tmp=koi2win('Вертолеты') if $tmp eq koi2win('Модели вертолетов');
    $tmp=koi2win('Железная дорога') if $tmp eq koi2win('Модели железных дорог');
    $tmp=koi2win('Деревья Бонсай') if $tmp eq koi2win('Бонсай');
    $dbs=$db_handleAr[1]->prepare('SELECT ID from dbo_CatDir where 
	PAPA_CLASS="modCatalog" and PAPA_ID=? and name=?');
    $dbs->execute($papa_id,$tmp);
    if ($row=$dbs->fetchrow_hashref){
       $papa_id=$row->{ID};
    } else {
       dieLog("Can't find PAPA_ID for ware '$handle->{content_subj}'");
    }
   #end modCatalog
   $dbs=$db_handleAr[1]->prepare('INSERT into dbo_CatWareSimple (CTS,OWNER,
	PAPA_CLASS,PAPA_ID,insight,name,photo,photosmall,photobig2,photobig3,price,end,
	start,`desc`,tag,artikul) values (
	now(),"User1","CatDir",?,1,?,?,?,?,?,?,curdate(),curdate(),?,?,?)');
#   $handle->{'content_image'}=~/^(.*?)\.(\w+)$/;
   $dbs->execute($papa_id,$subj,
#$1.'_2.'.$2,
$handle->{'content_image'},
$handle->{'content_previmg'},
	"".$handle->{'content_images'}->[1],
	"".$handle->{'content_images'}->[2],
	"".$handle->{'content_price'},'<p>'.
	$handle->{content_body}.$handle->{content_body_add}.
	'</p>',join(' ',@tags),"".$handle->{content_artikul});
   $page_id=$db_handleAr[1]->{'mysql_insertid'};
   #begin MultiCatWares
    $dbs=$db_handleAr[1]->prepare('SELECT w.ID as w_ID, whf.ID,
	whf.name from dbo_mcwWare as w,dbo_mcwWareHeader as wh,
	dbo_mcwWareHeaderField as whf where w.name4newsbot=? and wh.PAPA_ID=w.ID
	and whf.PAPA_ID=wh.ID');
    $dbs->execute($handle->{'content_nav'}->[$#{$handle->{'content_nav'}}-1]);
    my ($dbs2,$w_id);
    while($row=$dbs->fetchrow_hashref){
#print "w_id=$row->{w_ID}\n";
       $w_id=$row->{w_ID} if !$w_id;
       $row->{name}=~s/\://;
       $tmp=$handle->{content_fields}->{$row->{name}};
       #$tmp=$handle->{content_fields}->{$row->{name}} if !$tmp;
       next if !$tmp;
       $dbs2=$db_handleAr[1]->prepare('INSERT into dbo_mcwWareBase 
	(OWNER,field_id,field_value,ware_id) values ("User1",?,?,?)');
       $dbs2->execute($row->{ID},$tmp,$page_id);
    }
    dieLog("Cannot find MultiCatWare for ware '$handle->{content_subj}'") if !$w_id;
    if ($w_id){
       $dbs=$db_handleAr[1]->prepare('UPDATE dbo_CatWareSimple set mcw_id=? where ID=?');
       $dbs->execute($w_id,$page_id);
    }
   #end MultiCatWares
   #foreach my $k(keys %{$handle->{'content_fields'}}){
   #   sql_query('UPDATE dbo_CatWareSimple set '.$k.'="'.
#	Str2Sql($handle->{'content_fields'}->{$k}).'" 
#	where ID='.$page_id,'NewsBot',1);
#   }
   $dbs=$db_handleAr[1]->prepare('UPDATE relations set num=num+1
	where aurl="CatDir'.$papa_id.'"');
   $dbs->execute();
   print "Inserted page id: $page_id\n" if $DEBUG;
   $dbs=$db_handleAr[1]->prepare('INSERT into relations values
	("CatDir'.$papa_id.'",1,"CatWareSimple'.$page_id.'","child",curdate())');
   $dbs->execute();
   for my $k(@tags){
      $dbs=$db_handleAr[1]->prepare('UPDATE relations set num=num+1
	where aurl="'.$k.'"');
      $dbs->execute();
      $dbs=$db_handleAr[1]->prepare('INSERT into relations values
	("'.$k.'",1,"CatWareSimple'.$page_id.'","tag",curdate())');
      $dbs->execute();
   }
   $dbs=$db_handleAr[1]->prepare('INSERT into dbo_MultiPropsDir (CTS,OWNER,
        PAPA_CLASS,PAPA_ID) values (
        now(),"User1","CatWareSimple",?)');
   $dbs->execute($page_id);
   $multiprop_id=$db_handleAr[1]->{'mysql_insertid'};
   $dbs=$db_handleAr[1]->prepare('UPDATE dbo_CatWareSimple set multiprops=? where
	ID=?');
   $dbs->execute($multiprop_id,$page_id);
=head
   # Adding screenshots
   sql_query('INSERT into dbo_modGallery (CTS,OWNER,
        PAPA_CLASS,PAPA_ID) values (now(),"User1","Film","'.
        $page_id.'")',1,1);
   $screenshots_id=$db_handleAr[1]->{'mysql_insertid'};
   sql_query('SELECT max(num) as mx from relations where aurl="modGallery'.
        $screenshots_id.'"',1,1);
   $max_num=1;
   $max_num=$row->{mx} if ($row=$db_shandleAr[1]->fetchrow_hashref);
   foreach my $k(@{$handle->{content_images}}){
      $dbs=$db_handleAr[1]->prepare('INSERT into dbo_Photo (CTS,OWNER,PAPA_CLASS,
        PAPA_ID,loadedphoto) values (now(),"User1","modGallery",?,?)');
      $ds->execute($screenshots_id,$k);
      $photo_id=$db_handleAr[1]->{'mysql_insertid'};
      $dbs=$db_handleAr[1]->prepare('INSERT into relations values (?,?,?,"child")');
      $dbs->execute("modGallery".$screenshots_id,++$max_num,"Photo$photo_id");
   }
   $dbs=$db_handleAr[1]->prepare('UPDATE dbo_Film set screenshots=?
        where ID=?');
   $dbs->execute($screenshots_id,$page_id);
=cut
   my $init=WWW::GET->new(WWW::GET->hostname($save_img_url));
   $init->get('/catwaresimple'.$page_id.'.html?init=1',NoEncoding=>1);
   if (index($init->{'net_http_content'},'<html')==-1){
      print "##########################";
      print "Problem with get /catwaresimple$page_id.html\n";
      print "##########################";
   }
   return $page_id;


   # Получаем unix time stamp для текущего дня с 00:00:00 (ч:м:с), для
   # последующей сортировки новостей по дням при выводе в page13.ehtml
   @date=(localtime(time))[5,4,3];
   $date[2].='';
   $date[2]='0'.$date if (length $date[2]==1);
   $date[1]++;
   $date[1].='';
   $date[1]='0'.$date if (length $date[1]==1);
   $date[0]+=1900;
   open(DATE,'date -j '.join('',@date).'0000 "+%s"|') or die "Cannot convert date: ".$!;
   $date=<DATE>;
   close(DATE);
   $date=~s/[\r\n]+//g;
   $dbs=$db_handleAr[1]->prepare('INSERT into news_text (newst_postid,
      newst_host,newst_PAPA_PAGE,newst_title,newst_msg,newst_day) values
      (?,?,?,?,?,?)');
   $dbs->execute($handle->{'content_id'},$row->{'news_id'},
      $page_id,$subj,$text,$date);
   $loop_count++;
   dieLog($loop_count.". subject: ".cyrillic::convert('win','koi',
      $subj),1) if $DEBUG;
   return $page_id;
}
1;
