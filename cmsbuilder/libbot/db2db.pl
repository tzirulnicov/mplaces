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
use WWW::GET;
#use Image::Magick;

$config{From}={
	Table=>'funflowers',
	Id=>2,#Catdir
	SaveImgPath=>'/www/funflowers/funflowers.ru/htdocs/ee/wwfiles',
	SaveImgUrl=>'http://funflowers.ru/ee/wwfiles'
	};# from CatDir3
$config{To}={
	Table=>'evoo',
        Id=>53,#Catdir
        SaveImgPath=>'/www/evoo/evoo.ru/htdocs/ee/wwfiles',
        SaveImgUrl=>'http://evoo.ru/ee/wwfiles',
	#WithMultiProps=>1,
	McwId=>4,#mcwWare
        };# to CatDir54
#From
$db_table=$config{From}{Table};
sql_connect();
#To
$db_table=$config{To}{Table};
my $sql_tag;
sql_connect('db2db',1);
sql_query('SELECT cws.*,mp.name as mp_name,mp.value as mp_value,mp.desc as mp_desc
	from dbo_CatWareSimple as cws left join dbo_MultiProp as mp on 
	mp.value=cws.price and mp.PAPA_ID=cws.multiprops
	where cws.PAPA_CLASS="CatDir" and cws.PAPA_ID="'.$config{From}{Id}.'"');
my $count=0;
my (@tags_name,$dbs,$row2);
while($row=$db_shandle->fetchrow_hashref){
   print "Processing '".win2koi($row->{name}."', multiprop: ".$row->{mp_name}."\n");
   sql_query('SELECT name from dbo_CatWareSimple where name="'.Str2Sql($row->{name}).'"','db2db',1);
   if ($row2=$db_shandleAr[1]->fetchrow_hashref){
      print "Ware already exist in destination's DB\n";
      next;
   }
   print "All tags: $row->{tag}\n";
   $sql_tag='';
   foreach my $tag(split(' ',$row->{tag})){
      $tag=~s/Tag//;
      $sql_tag.=' or' if ($sql_tag);
      $sql_tag.=' ID="'.$tag.'"';
   }
   if ($sql_tag){
   $SQL='SELECT name from dbo_Tag where'.$sql_tag;
   print "$SQL\n";
   $dbs=$db_handle->prepare($SQL);
   $dbs->execute();
   @tags_name=();
   while($row2=$dbs->fetchrow_hashref){
      push(@tags_name,$row2->{name});
   }
    @{$row->{tag}}=();
   foreach my $tag(@tags_name){
      print "Search tag '".win2koi($tag)."' in destination db...\n";
      sql_query("SELECT ID from dbo_Tag where name='".Str2Sql($tag)."'",'db2db',1);
      if (!($row2=($db_shandleAr[1]->fetchrow_array)[0])){
	 print "!!! Tag '".win2koi($tag)."' not found in destination db\n";
	 next;
      }
      push(@{$row->{tag}},$row2);
   }
   $row->{tag}=join(' ',@{$row->{tag}});
   }
   print "End tags line: $row->{tag}\n";
   $row->{sostav}='';
   while ($row->{mp_desc}=~/<a[^>]+>([^<]+)<\/a>/ && $row->{mp_desc}!~/НОЕПЮРНПЮ/){
      print "Procesing sostav, searching ware '".win2koi($1)."'...\n";
      $dbs=$db_handleAr[1]->prepare('SELECT ID from dbo_CatWareSimple where name=?');
      $dbs->execute($1);
#      die "Cannot find ware '$1'"
 if ($row2=$dbs->fetchrow_hashref){
      $row->{sostav}.=", <a href='/catwaresimple$row2->{ID}.html'>$1</a>";}
      $row->{mp_desc}=~s/<a[^>]+>([^<]+)<\/a>//;
   }
   $row->{desc}.="<br>".koi2win('Состав: ').substr($row->{sostav},2) if $row->{sostav};
   if ($config{To}{WithMultiProps}){
      print "Get multiprops...\n";
      @{$row->{multiprops}}=();
      $dbs=$db_handle->prepare('SELECT name,value from dbo_MultiProp 
	where PAPA_ID=?');
      $dbs->execute($row->{multiprops});
      while (@row2=$dbs->fetchrow_array){
         push(@{$row->{multiprops}},[@row2]);
      }
#foreach my $k(@{$row->{multiprops}}){
#print "multiprop: ".$k->[0]."->".$k->[1]."\n";
#}
   } else {
      $row->{multiprops}=0;
   }
   eval_images([qw/photo photo2 photo3 photo5/],$row,$config{From}{SaveImgPath},$config{To}{SaveImgPath});
   insert_record($row,$config{To}{Id},$config{To}{SaveImgUrl},$config{To}{McwId});
}
sub eval_images{
   my ($params,$row,$from_dir,$to_dir)=@_;
   foreach my $key(@$params){
      $row{$key."_new"}='';
      next if !$row->{$key};
#      die "Cannot find $from_dir/$row->{$key}"
next if !-e "$from_dir/$row->{$key}";
      $row->{$key}=~/^(.*?)\.([^\.]+)$/;
      $row->{$key."_new"}=WWW::GET->getExceptionalFileName($to_dir,$2,$1);
      print ++$count.". $key: ".$row->{$key}.($row->{$key} ne $row->{$key."_new"}?" save as ".$row->{$key."_new"}:'')."\n";
      # only for code debug:
      #die "File already exists: $to_dir/$row->{$key}" if -e "$to_dir/".$row->{$key.'_new'};
      open(PROG,"cp $from_dir/$row->{$key} $to_dir/$row->{$key.'_new'}|") or die $!;
      print <PROG>;
      close(PROG);
   }
}
sql_close(1);
sql_close();
exit;

sub insert_record{
   my $handle=shift;
   my $papa_id=shift;
   my $save_img_url=shift;
   my $mcw_id=shift;
#   my $subj=$handle->{'content_subj'};
   my ($page_id,$row);
   my @date;
   my ($tags,$catdir_id,$multiprop_id,$screenshots_id,$photo_id,$max_num);
   $dbs=$db_handleAr[1]->prepare('SELECT ID from dbo_CatDir where
	ID=?');
   $dbs->execute($papa_id);
   die "Can't find catdir for this item!" if !($catdir_id=$dbs->fetchrow_hashref);
   $dbs=$db_handleAr[1]->prepare('INSERT into dbo_CatWareSimple (CTS,OWNER,
	PAPA_CLASS,PAPA_ID,insight,name,photo,photobig2,photobig3,price,end,
	start,`desc`,tag,photosmall,title) values (
	now(),"User1","CatDir",?,1,?,?,?,?,?,curdate(),curdate(),?,?,?,?)');
#   $handle->{'content_image'}=~/^(.*?)\.(\w+)$/;
   # Tags
   my @tags=();
=head
   push(@tags,'Tag17') if $handle->{'content_fields'}->{'wifi'};
   push(@tags,'Tag21') if $handle->{'content_fields'}->{'gps'};
   push(@tags,'Tag2') if $handle->{'content_price'}<5000;
   push(@tags,'Tag9') if $handle->{'content_fields'}->{'mp3'};
   push(@tags,'Tag3') if $handle->{'content_fields'}->{'camera'}>=5;
   if ($handle->{'content_fields'}->{'dims'}=~/x(\d+)$/ && $1<18){
      push(@tags,'Tag20');
   }
=cut
   #
   $dbs->execute($papa_id,$handle->{'name'},
#$1.'_2.'.$2,
$handle->{'photo_new'},
	"".$handle->{'photo2_new'},
	"".($handle->{'photo3_new'} || $handle->{'photo5_new'}),
	$handle->{'price'},$handle->{'desc'},"".$handle->{tag},
	"".$handle->{'photo_new'},"".$handle->{title});
   $page_id=$db_handleAr[1]->{'mysql_insertid'};
#   foreach my $k(keys %{$handle->{'content_fields'}}){
#      sql_query('UPDATE dbo_CatWareSimple set '.$k.'="'.
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
   #begin MultiProps
   $dbs=$db_handleAr[1]->prepare('INSERT into dbo_MultiPropsDir (CTS,OWNER,
        PAPA_CLASS,PAPA_ID) values (
        now(),"User1","CatWareSimple",?)');
   $dbs->execute($page_id);
   $multiprop_id=$db_handleAr[1]->{'mysql_insertid'};
   $dbs=$db_handleAr[1]->prepare('UPDATE dbo_CatWareSimple set multiprops=? where
	ID=?');
   $dbs->execute($multiprop_id,$page_id);
   if ($handle->{multiprops}){
      $max_num=1;
      foreach $k(@{$handle->{multiprops}}){
         $dbs=$db_handleAr[1]->prepare('INSERT into dbo_MultiProp (CTS,OWNER,
		PAPA_CLASS,PAPA_ID,value,name) values (now(),"User1",
		"MultiPropsDir",?,?,?)');
         $dbs->execute($multiprop_id,$k->[1],$k->[0]);
	 $tmp=$db_handleAr[1]->{'mysql_insertid'};
	 $dbs=$db_handleAr[1]->prepare('INSERT into relations (aurl,num,ourl,
		type) values (?,?,?,"child")');
	 $dbs->execute("MultiPropsDir".$multiprop_id,$max_num++,"MultiProp$tmp");
      }
   }
   #end MultiProps
   #begin MultiCatWares
   if ($mcw_id && $handle->{mp_name}){
      $dbs=$db_handleAr[1]->prepare('SELECT w.ID as w_ID, whf.ID,
        whf.name from dbo_mcwWare as w,dbo_mcwWareHeader as wh,
        dbo_mcwWareHeaderField as whf where w.ID=? and wh.PAPA_ID=w.ID
        and whf.PAPA_ID=wh.ID');
      $dbs->execute($mcw_id);
      my ($dbs2,$w_id,$val);
      while($row=$dbs->fetchrow_hashref){
         $w_id=$row->{w_ID} if !$w_id;
         next if $row->{name} ne koi2win('Высота стебля') && $row->{name} ne 
	   koi2win('Количество Роз');
         if ($row->{name} eq koi2win('Высота стебля')){
	    $val=$handle->{mp_name};
         } else {
	    $val=1;
         }
       $dbs2=$db_handleAr[1]->prepare('INSERT into dbo_mcwWareBase
        (OWNER,field_id,field_value,ware_id) values ("User1",?,?,?)');
       $dbs2->execute($row->{ID},$val,$page_id);
      }
    dieLog("Cannot find MultiCatWare for ware '$handle->{name}'") if !$w_id;
    if ($w_id){
       $dbs=$db_handleAr[1]->prepare('UPDATE dbo_CatWareSimple set mcw_id=? where ID=?');
       $dbs->execute($w_id,$page_id);
    }
   }
   #end MultiCatWares
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
