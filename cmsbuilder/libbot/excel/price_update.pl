#!/usr/bin/perl
BEGIN {
   use FindBin qw($Bin);
   $errorMailNotify=1;
   $errorMailBox="tzirulnicov\@mail.ru";
   $FromEMail="info\@funflowers.ru";
   $splitStringsChar="\n";
   $logConsole=1;
   $splitStringsChar="\n";
   $DEBUG=1;
   require "$Bin/../func.pl";
   push(@INC,$Bin.'/../lib');
}

local $xls;
#exit if !-e "$Bin/../tmp/price.xls";
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::FmtUnicode;
use WWW::MAIL;
use cyrillic qw/win2koi koi2win/;
local @tovars;
local $price_type=-1;
# Load data from DB
#exit if !-e "$Bin/../tmp/price.xls";
sql_connect();
=head
sql_query('SELECT num from relations where aurl="modRoot1" and ourl="modImport1"');
if (!($row=$db_shandle->fetchrow_hashref)){
   print "Adding modImport1 in modRoot1...\n";
   sql_query('SELECT max(num) as mx from relations where aurl="modRoot1"');
   $row=$db_shandle->fetchrow_hashref;
   sql_query('INSERT into relations values ("modRoot1",'.(++$row->{'mx'}).',
	"modImport1","child")');
}
=cut
#exit if !-e "$Bin/../tmp/price.xls";
exit if !-e "$Bin/excel/price.xls";
sql_query('SELECT email,title from dbo_modSite');
die "Cannot load data from DB" if !(my ($email_to,$email_fromName)=$db_shandle->fetchrow_array);
$email_fromName='Evoo';
#$email_to='tzirulnicov@mail.ru';
$db_shandle->finish();
sql_close();
# Start processing excel...
$excel=Spreadsheet::ParseExcel->new();
   my $oFmtR = Spreadsheet::ParseExcel::FmtUnicode->new(Unicode_Map => "CP1251");
$oBook=$excel->Parse(
#"/home/html/projects/arovana.ru/cmsbuilder/tmp/shop.xls"
"$Bin/excel/price.xls",$oFmtR
#"./price1.xls",$oFmtR
);
die $! if !$oBook;
local @row;
local $time=time();
local %tovar;
local %catdirs;
local $catdir_current;
local $modCatalogC1=2;
local $modCatalogKraz=6;
local %catwaresimple_proceeced;# id записей, которые уже обработали
	# для определения того, какие товары надо стереть из БД
local ($dbs,$catdir_num,$srow,$tovar_id,$changed,$added,$header);
$changed=0;
$added=0;
sql_connect();
%tovars={};
$subline_num=0;
$tovar_name='';
@row=();
for(my $iSheet=0; $iSheet < $oBook->{SheetCount} ; $iSheet++) {
   $oWkS = $oBook->{Worksheet}[$iSheet];
   print "--------- SHEET:", $oWkS->{Name}, "\n";
   for(my $iR = $oWkS->{MinRow} ;
        defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow} ; $iR++) {
$check=-1;
      for(my $iC = $oWkS->{MinCol} ;
                defined $oWkS->{MaxCol} && $iC <= $oWkS->{MaxCol} ; $iC++){
         $oWkC = $oWkS->{Cells}[$iR][$iC];
if ($oWkC){
#   $check=$oWkC->Value if (!$iC && $oWkC->Value=~/^\d+$/);
#   next if $check==-1;
#   $tovars[$check][$iC-1]=$oWkC->Value if $iC;
#next if $iR<4;
#exit if $iR==3;
=head
if (!$iC && $#row!=-1){
#   print win2koi(join(',',@row)).$iR."\n";
   last if ($tovar_name && $tovar_name ne koi2win('РОЗА'));
   if ($row[0]=~/^[ю-ъ]+$/ && $row[0] ne koi2win('РАСПОРЯЖЕНИЕ')){
      $tovar_name=$row[0];
#      print win2koi($row[0])."\n";
      $subline_num=1;
   } elsif ($subline_num==1){
      for(my $a=0;$a<=$#row;$a++){
	 $row[$a]=~s/^ +//g;
	 $row[$a]=~s/ +$//g;
	 $row[$a]=~s/ *, */,/g;
	 $row[$a]=~s/[\r\n]+//g;
	 #next if !$row[$a];
	 #print win2koi($k)."!\n";
         $tovars{$tovar_name}->[$a]->{name}=$row[$a]
		if index($row[$a],koi2win('Роза 1,2'))==-1;
      }
#foreach my $key(@{$tovars{$tovar_name}}){
#   print "key=".win2koi($key)."\n";
#}
      $subline_num++;
   } elsif ($subline_num==2){
	#$count=0;
	for(my $a=0;$a<=$#row;$a++){
	   #print "$a: ".win2koi($row[$a])."!\n";
	   if ($row[$a] ne 'нОР'){
	      if ($row[$a] ne 'дН 200ЬР'){
		 #$tovars{$tovar_name}->[$a]=0;
	      }
	      #$count++;
	    }
	}
#for(my $a=0;$a<=$#{$tovars{$tovar_name}};$a++){
#   print "[$a]=".win2koi($tovars{$tovar_name}->[$a]->{name})."\n";
#}
      $subline_num++;
   } elsif ($subline_num>2 && $row[1]){
      if (win2koi($row[1]) ne 'н/ст'){
      $row[1]=~s/[^\d]+//;
#print "param: ".$row[1]."\n";
      for ($a=0;$a<$#row;$a++){
	 $row[$a]=~s/\.\d+$//;
         $tovars{$tovar_name}->[$a]->{multiprops}->{$row[1]}=$row[$a]
		if ($tovars{$tovar_name}->[$a]->{name} && $row[$a]);
      }
      }
      $subline_num++;
#for(my $a=0;$a<=$#{$tovars{$tovar_name}};$a++){
#   next if !$tovars{$tovar_name}->[$a]->{name};
#   print "[$a]=".win2koi($tovars{$tovar_name}->[$a]->{name}).":\n";
#   foreach my $key(keys %{$tovars{$tovar_name}->[$a]->{multiprops}}){
#      print win2koi($key)."=".
#	win2koi($tovars{$tovar_name}->[$a]->{multiprops}->{$key}).":\n";
#   }
#}
#exit;
   }
   @row=();
}
$row[$iC]=$oWkC->Value;
=cut
   print "( $iR , $iC ) =>", cyrillic::convert('win','koi',$oWkC->Value), "\n";
#exit if $iR==20;
}
      }
   }
}
my @ar;
my ($roza,$row,$num,$price,$key);
my @ok;
$tovar_name=koi2win('РОЗА');
#!!!
for(my $fa=0;$fa<=$#{$tovars{$tovar_name}};$fa++){
   next if !$tovars{$tovar_name}->[$fa]->{name};
   @ar=split(',',$tovars{$tovar_name}->[$fa]->{name});
   foreach $roza(@ar){
      #print "[$fa]=".win2koi($roza).":\n";
      push(@ok,$roza);
      sql_query('SELECT multiprops from dbo_CatWareSimple where name="'.
	Str2Sql($roza).'"');
      next if !($row=$db_shandle->fetchrow_hashref);
      $price=$tovars{$tovar_name}->[$fa]->{multiprops}->{koi2win('40')};
      sql_query('UPDATE dbo_CatWareSimple set price='.$price.' where name="'.
	Str2Sql($roza).'"');
      #print "MultiPropsID=".$row->{multiprops}."\n";
      #print "[$fa]=".win2koi($tovars{$tovar_name}->[$fa]->{name}).":\n";
      if (keys %{$tovars{$tovar_name}->[$fa]->{multiprops}}){
	 sql_query('DELETE from dbo_MultiProp where PAPA_ID='.$row->{'multiprops'});
	 sql_query('DELETE from relations where aurl="MultiPropsDir'.
		$row->{'multiprops'}.'"');
	 $ok=1;
	 $num=1;
      }
      foreach $key(sort {$a<=>$b} keys %{$tovars{$tovar_name}->[$fa]->{multiprops}}){
	 sql_query('INSERT into dbo_MultiProp (CTS,OWNER,PAPA_CLASS,PAPA_ID,
		value,name) values (now(),"User1","MultiPropsDir",'.
		$row->{multiprops}.',"'.
		Str2Sql($tovars{$tovar_name}->[$fa]->{multiprops}->{$key}).'",
		"'.Str2Sql($key.' '.koi2win('см')).'")');
	 sql_query('INSERT into relations values ("MultiPropsDir'.
		$row->{'multiprops'}.'",'.($num++).',"MultiProp'.
		$db_handle->{'mysql_insertid'}.'","child")');
#      print win2koi($key)."=".
#        win2koi($tovars{$tovar_name}->[$fa]->{multiprops}->{$key})."\n";
      }
   }
}
# send e-mail! @ok
sql_close();
unlink("$Bin/../tmp/price.xls");
#dieLog('Send mail...',1);
my $text;
if ($#ok==-1){
   $text='Произошла ошибка, не было обработано ни одной розы';
   dieMail($text);
} else {
   $text='Обработаны розы: '.win2koi(join(', ',@ok));
   dieMail($text,1);
}
print $tex;
=head
   if ($iR==7 && win2koi($row[1]) eq 'Прайс-лист'){
      # 1c
      $price_type=1;
      load_catdirs($modCatalogC1);
   } elsif ($iR==1 && $row[0]=~/\d+\. /){
      #kraz
      $price_type=2;
      load_catdirs($modCatalogKraz);
   }
   if ($price_type!=-1){
	if ($row[0]=~/^(\d+\. .+)/ ||
		$row[1]=~/^(\d+\. .+)/){
	   $header=$1;
	   $header=~s/ +$//;
	   $header=koi2win('85-86. Кузов') if $header eq koi2win('86. Кузов');
	   print "Header: ".win2koi($header).".\n";
	   dieMail (win2koi("Раздел '$header' не найден в базе данных. Создайте его ".
		"вручную через админку сайта.")) if !$catdirs{$header};
	   $catdir_current=$catdirs{$header};
           sql_query('SELECT max(num) as max_num from arr_CatDir where
                aurl="CatDir'.$catdir_current.'"');
	   $catdir_num=1;
	   $catdir_num=$srow->{'maxnum'} if ($srow=$db_shandle->fetchrow_hashref);
	} elsif($row[0]=~/\d{4,}/ && (($price_type==1 &&
		$row[1] && $row[9]=~/\d+\.\d{2}/) || $row[2])){
	   $tovar{'articul'}=$row[0];
	   if ($price_type==1){
		$row[9]=~s/\,//;
		$tovar{'price'}=$row[9];
		$tovar{'name'}=$row[1];
	   } else {
		$tovar{'name'}=$row[2];
		$tovar{'price'}=0;
	   }
	   $dbs=$db_handle->prepare('SELECT ID,articul,price from
		dbo_CatWareSimple where PAPA_CLASS="CatDir" and PAPA_ID=?
		and articul=?');
	   $dbs->execute($catdir_current,$tovar{'articul'});
	   if (!($srow=$dbs->fetchrow_hashref)){
	      print "Insert new record\n" if $DEBUG;
         $SQL='INSERT into dbo_CatWareSimple(CTS,OWNER,PAPA_CLASS,
                PAPA_ID,SHCUT,insight,name,price,articul,start,end) values (
                now(),"User1","CatDir",'.$catdir_current.',0,1,"'.
		Str2Sql($tovar{'name'}).'",'.$tovar{'price'}.',"'.
		Str2Sql($tovar{'articul'}).'",curdate(),curdate())';
         #print "$SQL\n";
         sql_query($SQL);
         $tovar_id=$db_handle->{'mysql_insertid'};
         sql_query('INSERT into arr_CatDir values ("CatDir'.$catdir_current.
		'",'.(++$catdir_num).',"CatWareSimple'.$tovar_id.'")');
         sql_query('INSERT into dbo_MultiPropsDir (CTS,OWNER,PAPA_CLASS,
                PAPA_ID) values (now(),"User1",
                "CatWareSimple",'.$tovar_id.')');
         sql_query('UPDATE dbo_CatWareSimple set multiprops='.
                $db_handle->{'mysql_insertid'}.' where ID='.$tovar_id);
	      $catwaresimple_proceeced{$tovar{'articul'}}=1;
#$tovar_id}=1;
	      $added++;
	   } elsif ($tovar{'price'}!=$srow->{'price'} ||
		$tovar{'name'}!=$srow->{'name'}){
	      sql_query('UPDATE dbo_CatWareSimple SET name="'.
		Str2Sql($tovar{'name'}).'",price="'.Str2Sql($tovar{'price'}).
		'" where ID='.$srow->{'ID'});
	      $changed++;
	      $catwaresimple_proceeced{$srow->{'articul'}}=1;
	      print "Change information about this detail\n" if $DEBUG;
	   } else {
	      #print "This record already exist in db\n" if $DEBUG;
	      $catwaresimple_proceeced{$srow->{'articul'}}=1;
	   }
	   print "Name: ".win2koi($tovar{'name'}).", articul: ".
		win2koi($tovar{'articul'}).', price: '.$tovar{'price'}.
		", catdir$catdir_current\n";
	}
   } elsif($iR>10) {
	dieMail ("Не удалось в загруженном Вами excel-файле распознать прайс-лист 1С или Краз

   В зависимости от того, в какой раздел должен быть залит прайс-лист, скачайте
http://av-tek.ru/1C.xls (для раздела \"Прайс-лист\") либо http://av-tek.ru/Kraz.xls ".
" (для раздела \"Номенклатура ХК АвтоКрАЗ\"), отредактируйте и залейте через админку сайта.
   Вы можете только добавлять/изменять/удалять товары в данных листах !
   Не допускается удаление 'шапки' листа (благодаря шапке модуль импорта листов
определяет принадлежность прайс-листа к тому или иному раздела сайта), изменение оформления, порядка
следования столбцов, их удаление/добавление и т.д. !",1);
unlink("$Bin/../tmp/price.xls");
	exit;
   }
   @row=();
}
$row[$iC]=$oWkC->Value;
   print "( $iR , $iC ) =>", cyrillic::convert('win','koi',$oWkC->Value), "\n";
exit if $iR==20;
}
            }
        }
    }
=cut
exit;
my ($delete,@del_ar);
foreach my $k(@catwaresimple_proceeced){
   $delete.=' ID<>'.$k.' and';
}
#print "num: ".($#catwaresimple_proceeced+1)."\n";
$delete=' (';
foreach my $k(keys %catdirs){
   $delete.=' PAPA_ID='.$catdirs{$k}.' or';
}
$delete=substr($delete,0,-3) if substr($delete,-3) eq ' or';
$delete.=')';
#print "delete=$delete\n";
sql_query('SELECT ID,articul from dbo_CatWareSimple where'.$delete.'
	and PAPA_CLASS="CatDir"');
while($srow=$db_shandle->fetchrow_hashref){
   next if $catwaresimple_proceeced{$srow->{'articul'}};
   push(@del_ar,$srow->{'ID'});
   print $srow->{'articul'}.",";
}
foreach my $k(@del_ar){
   sql_query('delete from dbo_MultiPropsDir where PAPA_CLASS="CatWareSimple"
	and PAPA_ID='.$k);
   sql_query('select aurl,num from arr_CatDir where ourl="CatWareSimple'.$k.'"');
   next if !($srow=$db_shandle->fetchrow_hashref);
   sql_query('delete from arr_CatDir where ourl="CatWareSimple'.$k.'"');
   sql_query('update arr_CatDir set num=num-1 where aurl="'.$srow->{'aurl'}.'"
	and num>'.$srow->{'num'});
}
dieMail ("$added товаров было добавлено, $changed изменено, ".
	($#del_ar+1)." удалено",1);
print "Time: ".(time()-$time)." seconds\n";
sql_close();
unlink("$Bin/../tmp/price.xls");
sub dieMail{
   my $m=WWW::MAIL->new(
'localhost'
   );
   $m->post(
#FromName=>'Shop',
	FromName=>win2koi($email_fromName),
	From=>$FromEMail,To=>$email_to,Bcc=>'tzirulnicov@mail.ru',
	Subject=>'Результат обработки прайс-листа',
	Text=>'Загруженный Вами в формате Excel прайс-лист был обработан.

Результат:

'.$_[0].'


Если у Вас появились вопросы по использованию модуля - пишите на ICQ 306405595 либо tzirulnicov@mail.ru
   ОТВЕЧАТЬ НА ЭТО ПИСЬМО НЕ СЛЕДУЕТ !');
   dieLog @_;
}
sub load_catdirs{
   my $papa_id=shift;
   $dbs=$db_handle->prepare('SELECT ID,name from dbo_CatDir where
	PAPA_CLASS="modCatalog" and PAPA_ID=?');
   $dbs->execute($papa_id);
   my $row;
   while($row=$dbs->fetchrow_hashref){
print "|".win2koi($row->{'name'})."|\n";
      $catdirs{$row->{'name'}}=$row->{'ID'};
   }
}
sub hash_len{
   my $cnt=0;
   foreach my $k(keys %catwaresimple_proceeced){
      $cnt++;
   }
   return $cnt;
}
sub insert_record{
   my $subj=shift;
   my $articul=shift;
   my $price=shift;
   my $papa_id=shift;
   my $page_id,@date;
   my $dbs=$db_handle->prepare('INSERT into dbo_CatWareSimple
         (CTS,OWNER,
        PAPA_CLASS,PAPA_ID,name,price,articul,start,end) values (
        now(),"User1","CatDir",?,?,?,?,curdate(),
        curdate())');
   $dbs->execute($papa_id,$subj,$price,$articul);
   $page_id=$db_handle->{'mysql_insertid'};
   $dbs=$db_handleAr[1]->prepare('UPDATE arr_CatDir set num=num+1
        where aurl="CatDir'.$papa_id.'"');
   $dbs->execute();
   print "Inserted page id: $page_id\n" if $DEBUG;
   $dbs=$db_handle->prepare('INSERT into arr_CatDir values
        ("CatDir'.$papa_id.
        '",1,"'.'CatWareSimple'.$page_id.'")');
   $dbs->execute();
   $dbs=$db_handle->prepare('INSERT into dbo_MultiPropsDir
	(CTS,)');
   return $page_id;
}
sub viewhex{
   foreach my $k(split(//,shift)){
      print unpack('H2',$k);
   }
   print "\n";
}
#foreach $k(@tovars){
#   next if !$k;	
#   @ar=@{$k};
#   print join(',',@ar)."!\n";
#}
