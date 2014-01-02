#!/usr/bin/perl
#http://www.mobilegroup.su/files/price.xls
BEGIN {
   use FindBin qw($Bin);
   $errorMailNotify=1;
   $errorMailBox="tzirulnicov\@mail.ru";
   $FromEMail="info\@evoo.ru";
   $splitStringsChar="\n";
   $logConsole=1;
   $splitStringsChar="\n";
   $DEBUG=1;
   require "$Bin/func.pl";
   push(@INC,$Bin.'/lib');
}

local $xls;
#exit if !-e "$Bin/../tmp/price.xls";
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::FmtUnicode;
use WWW::MAIL;
use WWW::GET;
use Time::Local;
use cyrillic qw/win2koi koi2win/;
local @tovars;
local $price_type=-1;
# Load data from DB
#exit if !-e "$Bin/../tmp/price.xls";
sql_connect();
#sql_query('SELECT num from relations where aurl="modRoot1" and ourl="modImport1"');
#if (!($row=$db_shandle->fetchrow_hashref)){
#   print "Adding modImport1 in modRoot1...\n";
#   sql_query('SELECT max(num) as mx from relations where aurl="modRoot1"');
#   $row=$db_shandle->fetchrow_hashref;
#   sql_query('INSERT into relations values ("modRoot1",'.(++$row->{'mx'}).',
#	"modImport1","child")');
#}
exit if !-e "$Bin/../tmp/price.xls";

sql_query('SELECT email,title from dbo_modSite');
die "Cannot load data from DB" if !(my ($email_to,$email_fromName)=$db_shandle->fetchrow_array);
$email_fromName='Evoo';
#$email_to='tzirulnicov@mail.ru';
$db_shandle->finish();
sql_query('SELECT disable,period,rules,sopostavil,times from dbo_modImport');
die "Cannot load data from DB" if !(my $modimport=$db_shandle->fetchrow_hashref);
$modimport->{times}="1980-01-01 11:22:33" if $modimport->{times} eq "0000-00-00 00:00:00";
my @times=split(/[\- \:]/,$modimport->{times});
$modimport->{period}*=60*60;#*min*sec
my $unixtime=timelocal($times[5],$times[4],$times[3],$times[2],--$times[1],$times[0]);
#print join(',',localtime());
exit(0) if ($modimport->{disable} || $unixtime+$modimport->{period}>time());
$modimport->{sopostavil}=~s/<br>/\r\n/g;
$modimport->{sopostavil}=~s/������� ������� //g;
$modimport->{sopostavil}=~s/��������� ��������� //g;
$modimport->{sopostavil}=~s/� �������� GSM-�������� //g;
my @sopostavil=split(/[;\r\n]+/,$modimport->{sopostavil});
my @rules=split(/[,\r\n]+/,$modimport->{rules});
my @list;#wares in our database
$db_shandle->finish();
sql_close();
#download
my $wget=WWW::GET->new('www.mobilegroup.su');
die "Cannot connect to mobilegroup.su" if !$wget;
die $wget->{errmsg} if !$wget->get('/files/price.xls');
open(FILE,">/www/evoo/evoo.ru/cmsbuilder/tmp/price.xls") or die $!;
binmode(FILE);
print FILE $wget->{'net_http_content'};
close(FILE);
# Start processing excel...
$excel=Spreadsheet::ParseExcel->new();
   my $oFmtR = Spreadsheet::ParseExcel::FmtUnicode->new(Unicode_Map => "CP1251");
$oBook=$excel->Parse(
#"/home/html/projects/arovana.ru/cmsbuilder/tmp/shop.xls"
"$Bin/../tmp/price.xls",$oFmtR
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
local %catwaresimple_proceeced;# id �������, ������� ��� ����������
	# ��� ����������� ����, ����� ������ ���� ������� �� ��
local ($dbs,$catdir_num,$srow,$tovar_id,$changed,$added,$header);
$changed=0;
$added=0;
sql_connect();
%tovars={};
$tovar_name='';
my $header='';
my $header_root='';
@row=();
my %tovars_old;

#Get all records from previous download (dbo_CatWareSimple_old)
sql_query('SELECT * from dbo_CatWareSimple_old');
while($row=$db_shandle->fetchrow_hashref){
   $tovars_old{$row->{ID}}={price=>$row->{price},name=>$row->{name}};
}
#
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
	    if (!$iC && $#row!=-1){
#   print win2koi(join(',',@row)).$iR."\n";
#   last if ($tovar_name && $tovar_name ne koi2win('����'));
#for(my $a=0;$a<=$#{$tovars{$tovar_name}};$a++){
#   next if !$tovars{$tovar_name}->[$a]->{name};
#   print "[$a]=".win2koi($tovars{$tovar_name}->[$a]->{name}).":\n";
#   foreach my $key(keys %{$tovars{$tovar_name}->[$a]->{multiprops}}){
#      print win2koi($key)."=".
#	win2koi($tovars{$tovar_name}->[$a]->{multiprops}->{$key}).":\n";
#   }
#}
#exit;
	       if (!$row[3] && !$row[4]){
		  if ($row[0]=~/\d+\. /){
		     $header_root=$row[0];# ��������� (�������, �������������, ...)
		  } else {
		     $header=$row[0];# ������������� (Nokia, HTC, Sony, ...)
		  }
	       } else {
	          $row[0]=~s/������� ������� //;
		  $row[0]=~s/��������� ��������� //;
		  $row[0]=~s/� �������� GSM-�������� //;

		  $row[3]=~s/\,//;
for (my $a=0;$a<=$#rules;$a++){
   $rules[$a]=~/\+(\d+)\D+(\d+)(\D+(\d+))?/;
 #  print "+$1, ot $2, do $4\n";
   if ($row[3]>=$2 && (!$4 || $row[3]<=$4)){
      $row[3]+=$1;
      last;
   }
}
	          $tovars{$row[0]}=$row[3] if (($header_root eq '1. ������� �������� ' || 
			$header_root eq '8. �������������') && grep{$_=~/^$row[0][ \t]*>/} @sopostavil);
	       }
	       @row=();
	    }
	 $row[$iC]=$oWkC->Value if $iR>12;
#   print "( $iR , $iC ) =>|", cyrillic::convert('win','koi',$oWkC->Value), "|\n";
#if ($iR==30){
#   foreach my $key(keys %tovars){
#      print win2koi($key)."=".
#       win2koi($tovars{$key}).":\n";
#   }
#   exit;
#}
	 }
      }
   }
}
  # foreach my $key(keys %tovars){
  #    print win2koi($key)."=".
  #     win2koi($tovars{$key}).":\n" if exists $tovars{$key};
  # }
my @ar;
my ($roza,$row,$num,$price,$key);
my @ok;
#$tovar_name=koi2win('����');
#!!!
sql_connect('price_update',1);
sql_query('SELECT ourl from relations where aurl="modCatalog1"');
my $papa_id;
while($row=$db_shandle->fetchrow_hashref){
   next if $row->{ourl}!~/CatDir(\d+)/;
   $papa_id.=($papa_id?' or ':'').'PAPA_ID='.$1;
}
my $key;
sql_query('SELECT ID,name from dbo_CatWareSimple'.
	($papa_id?' where '.$papa_id:''));
my ($mail_text_added,$mail_text_changed,$mail_text_deleted);
while ($row=$db_shandle->fetchrow_hashref){
   if ($key=find_key($row->{'name'})){
      print "Item $key was found in our DB\n";
      die "bad price" if $tovars{$key}!~/^\d+$/;
      sql_query('UPDATE dbo_CatWareSimple set insight=1,price="'.
	Str2Sql($tovars{$key}).'" where ID='.$row->{ID},'price_update',1);
      if (!defined $tovars_old{$row->{ID}}){
	 $mail_text_added.=$row->{name}." (".$tovars{$key}."p)<br>";
	 sql_query('INSERT into dbo_CatWareSimple_old (ID,name,price) values (
		'.$row->{ID}.',"'.Str2Sql($row->{name}).'","'.
		Str2Sql($tovars{$key}).'")','price_update',1);
      } elsif ($tovars_old{$row->{ID}}{price}!=$tovars{$key}){
         $mail_text_changed.=$row->{name}." - � ".
         $tovars_old{$row->{ID}}{price}."� �� ".$tovars{$key}."�<br>";
         $mail_text.='�������� ����� �����: '.$row->{name}."\n";
         sql_query('UPDATE dbo_CatWareSimple_old SET name="'.
		Str2Sql($row->{name}).'",price="'.Str2Sql($tovars{$key}).
		'" where ID='.$row->{ID},'price_update',1);
      }
      undef $tovars_old{$row->{ID}};
   } else {
      sql_query('UPDATE dbo_CatWareSimple set insight=0 where ID='.
	$row->{ID},'price_update',1);
   }
}
foreach $key(keys %tovars_old){
   next if !$tovars_old{$key};
   $mail_text_deleted.=$tovars_old{$key}{name}."<br>";
   sql_query('DELETE from dbo_CatWareSimple_old where ID='.$key);
}
my ($sec,$min,$hour,$mday,$mon,$year)=(localtime(time))[0,1,2,3,4,5];
$mon++;
$year+=1900;
print "$year-$mon-$mday $hour:$min:$sec\n";
sql_query('UPDATE dbo_modImport set times="'.
	"$year-$mon-$mday $hour:$min:$sec".'"');
sql_close(1);
sql_close();
END:
print "Sending mail...\n";
mail("<h3>��������� ������:</h3><p>".($mail_text_added || '(��� �����������)').
	"<p><h3>��������� ���</h3><p>".($mail_text_changed || '(��� ����Σ����)').
	"<p><h3>�������</h3><p>".($mail_text_deleted || '(��� ���̣����)'));
sub find_key{
 my $fkey=shift;
 for my $key (%tovars){
   next if !$tovars{$key};
   my $tmp=WWW::GET->str2regexp($key);
   my $dbname=(grep{$_=~/$tmp[ \t]*>/} @sopostavil)[0];
   $dbname=~s/^[^>]+>[ \t]*//;
   $dbname=~s/[ \t]*$//;
   #print "Processing |$key|, searching in DB '$dbname'...\n";
   return $key if $dbname eq $fkey;
=head
   sql_query('SELECT ID,price from dbo_CatWareSimple where name="'.Str2Sql($dbname).'"');
   if (!($row=$db_shandle->fetchrow_hashref)){
      print "Can't find '$dbname' in database!\n";
      next;
   } else {
      print "+OK, id=$row->{'ID'}. Changing price from $row->{price} to $tovars{$key}\n";
      sql_query('UPDATE dbo_CatWareSimple set price='.$tovars{$key}.' where ID='.$row->{ID});
   }
=cut
  }
  return 0;
}
sub mail{
   my $body=shift;
   my $m=WWW::MAIL->new(
'localhost'
   );
   die $m->{errmsg} if !$m->post(
#FromName=>'Shop',
        FromName=>win2koi($email_fromName),
        From=>$FromEMail
,To=>$email_to,
Cc=>'tz@big-bossa.com',
	ContentType=>'html',
        Subject=>'��������� ��������� �����-�����',
        Text=>'<b>Excel �����-���� � mobilecenter.ru ���������.

���������:</b>

'.$body.'

<p><p>
���� � ��� ��������� ������� �� ������������� ������ - ������ �� ICQ 306405595 ���� �� tzirulnicov@mail.ru
   �������� �� ��� ������ �� ������� !');
}
exit;
############################################################################
#unlink("$Bin/../tmp/price.xls");
#dieLog('Send mail...',1);
my $text;
=head
if (!keys %tovars==-1){
   $text='��������� ������, �� ���� ���������� �� ������ ������';
   dieMail($text);
} else {
   $text='���������� ������: '.win2koi(join(', ',keys %tovars));
   dieMail($text,1);
}
=���
print $tex;
=head
   if ($iR==7 && win2koi($row[1]) eq '�����-����'){
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
	   $header=koi2win('85-86. �����') if $header eq koi2win('86. �����');
	   print "Header: ".win2koi($header).".\n";
	   dieMail (win2koi("������ '$header' �� ������ � ���� ������. �������� ��� ".
		"������� ����� ������� �����.")) if !$catdirs{$header};
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
	dieMail ("�� ������� � ����������� ���� excel-����� ���������� �����-���� 1� ��� ����

   � ����������� �� ����, � ����� ������ ������ ���� ����� �����-����, ��������
http://av-tek.ru/1C.xls (��� ������� \"�����-����\") ���� http://av-tek.ru/Kraz.xls ".
" (��� ������� \"������������ �� ��������\"), �������������� � ������� ����� ������� �����.
   �� ������ ������ ���������/��������/������� ������ � ������ ������ !
   �� ����������� �������� '�����' ����� (��������� ����� ������ ������� ������
���������� �������������� �����-����� � ���� ��� ����� ������� �����), ��������� ����������, �������
���������� ��������, �� ��������/���������� � �.�. !",1);
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
dieMail ("$added ������� ���� ���������, $changed ��������, ".
	($#del_ar+1)." �������",1);
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
	Subject=>'��������� ��������� �����-�����',
	Text=>'����������� ���� � ������� Excel �����-���� ��� ���������.

���������:

'.$_[0].'


���� � ��� ��������� ������� �� ������������� ������ - ������ �� ICQ 306405595 ���� tzirulnicov@mail.ru
   �������� �� ��� ������ �� ������� !');
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
