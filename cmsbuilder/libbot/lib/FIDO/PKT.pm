package FIDO::PKT;

BEGIN{
   require Exporter;
   $VERSION = "1.0";
   @ISA = qw( Exporter );
   my @ErrorCodeNames = qw( PKT_OK PKT_FILE_NOT_EXISTS PKT_NOT_PACKET PKT_BAD_BAUDRATE
	PKT_BAD_VERSION PKT_BAD_AUXILLARYNET PKT_BAD_CAPWORD PKT_BAD_CAPACIBILITIES
	PKT_BAD_QMAIL_ORIGZONE PKT_BAD_QMAIL_DESTZONE);
   %EXPORT_TAGS = (
	'ERROR_CODES'    => \@ErrorCodeNames
   );
   Exporter::export_ok_tags(
	'ERROR_CODES'
   );
}
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use FIDO::Functions;
use Data::Date;
use string;
my $uniqueNameOfPKT=time-1;
# ------------------------- begin exportable error codes -------------------

use constant PKT_OK			=> 0;
use constant PKT_FILE_NOT_EXISTS	=> 1;
use constant PKT_NOT_PACKET		=> 2;
use constant PKT_BAD_BAUDRATE		=> 3;
use constant PKT_BAD_VERSION		=> 4;
use constant PKT_BAD_AUXILLARYNET	=> 5;
use constant PKT_BAD_CAPWORD		=> 6;
use constant PKT_BAD_CAPACIBILITIES	=> 7;
use constant PKT_BAD_QMAIL_ORIGZONE	=> 8;
use constant PKT_BAD_QMAIL_DESTZONE	=> 9;

sub new{
   my $class=shift;
   my $self={};
   #$self->{'testStr'}=0;
   bless $self, $class;
}

sub open{
   my $self=shift;
   my $file=shift;
   return PKT_FILE_NOT_EXISTS if (!-e $file);
   $self->{'fileName'}=$file;    
   open(PKT,$file) or die "$!";
   binmode(PKT);
   my $str=join('',<PKT>);
   close(PKT);
   return PKT_NOT_PACKET if (length($str)<60);
   return PKT_BAD_BAUDRATE if (substr($str,16,2) ne "\x00\x00");
   return PKT_BAD_VERSION if (substr($str,18,2) ne "\x02\x00");
   #return PKT_BAD_AUXILLARYNET if (substr($str,38,2) ne "\x00\x00");
   return PKT_BAD_CAPWORD if (substr($str,40,2) ne "\x00\x01");
   return PKT_BAD_CAPACIBILITIES if (substr($str,44,2) ne "\x01\x00");
   return PKT_BAD_QMAIL_ORIGZONE if (getValue($str,34) ne getValue($str,46));
   return PKT_BAD_DEST_DESTZONE if (getValue($str,36) ne getValue($str,48));
   $self->{'fromAddress'}=getValue($str,46).':'.getValue($str,20).'/'.getValue($str,0).'.'.getValue($str,50);
   $self->{'toAddress'}=getValue($str,48).':'.getValue($str,22).'/'.getValue($str,2).'.'.getValue($str,52);
   $self->{'createDate'}=getValue($str,8).' '.getValue($str,6).' '.getValue($str,4). ' '.
	sprintf("%02d",getValue($str,10)).':'.sprintf("%02d",getValue($str,12)).':'.sprintf("%02d",getValue($str,14));
   $self->{'progCode'}=substr($str,42,1).substr($str,24,1);# High:Low
   $self->{'subProgVer'}=substr($str,25,1);
   $self->{'progModify'}=substr($str,43,1);
   $self->{'password'}=substr($str,26,8);
   $self->{'password'}=~s/\x00//g;
   $self->{'str'}=substr($str,58);
   $self->{'eof'}=0;
   return PKT_OK;
}

sub getValue{
   # Convert bin to dec
   # Input: string,start position
   # Output: decimal value
   return hex2dec(unpack("H4",substr($_[0],$_[1]+1,1).substr($_[0],$_[1],1)));
}

sub getNext{
   # Выдаёт следующее сообщение из пакета
   my $self=shift;
   return PKT_BAD_VERSION if (substr($self->{'str'},0,2) ne "\x02\x00" || substr($self->{'str'},33,1) ne "\x00");
   $self->{'date'}=substr($self->{'str'},14,19);
   $self->{'str'}=substr($self->{'str'},34);
   $self->{'str'}=~s/^([^\x00]+)\x00([^\x00]+)\x00([^\x00]+)\x00//;
   $self->{'from'}=$2;
   $self->{'to'}=$1;
   $self->{'subject'}=$3;
   $self->{'str'}=~s/AREA:([^\x0D]+)\x0D\x01/\x0D\x01/;
   $self->{'area'}=$1 if ($1 ne $self->{'to'});
   $self->{'msgid'}=kludge('MSGID:',$self->{'str'});
   $self->{'fromAddr'}=substr($self->{'msgid'},0,index($self->{'msgid'},' '));
   $self->{'msgid'}=substr($self->{'msgid'},index($self->{'msgid'},' ')+1);
   $self->{'pid'}=kludge('PID:',$self->{'str'});
   $self->{'tid'}=kludge('TID:',$self->{'str'});
   $self->{'fmpt'}=kludge('FMPT:',$self->{'str'});
   $self->{'topt'}=kludge('TOPT:',$self->{'str'});
   $self->{'intl'}=kludge('INTL:',$self->{'str'});
   $self->{'text'}=$self->{'str'};
   $self->{'text'}=~s/\x0D\x00\x02\x00.+$//;
   $self->{'text'}=~s/(\x01|\x00)[^\x0D]+\x0D//g;
   $self->{'text'}=~s/\x0D\x01PATH\:([^\x0D]+)\x0D?$//g;
   #$self->{'path'}=$1 if ($1 ne $self->{'area'});
   $self->{'text'}=~s/\x0DSEEN-BY\: .+$//g;
   $self->{'text'}=~s/^\x0D//g;
   #$self->{'text'}=substr($self->{'text'},0,rindex($self->{'text'},"\x01"));
   $self->{'str'}=substr($self->{'str'},index($self->{'str'},"\x02\x00"));
   $self->{'eof'}=1 if (index($self->{'str'},"\x02\x00")==-1);
   return PKT_OK;
}

sub start{
   # Начало создания пакета. Рисует "шапку" пакета.
   # * AddressFrom: Адрес отправителя
   # * AddressTo: Адрес получателя
   # * Password: Пароль на сессию
   $nodeFrom=sprintf("%04X",getNode(@_[1]));
   $nodeTo=sprintf("%04X",getNode(@_[2]));
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
   $yearOfCreate=sprintf("%04X",$year+1900);
   $monthOfCreate=sprintf("%04X",$mon);
   $dayOfCreate=sprintf("%04X",$mday);
   $hourOfCreate=sprintf("%04X",$hour);
   $minOfCreate=sprintf("%04X",$min);
   $secOfCreate=sprintf("%04X",$sec);
   $netFrom=sprintf("%04X",getNet(@_[1]));
   $netTo=sprintf("%04X",getNet(@_[2]));
   $zoneFrom=sprintf("%04X",getZone(@_[1]));
   $zoneTo=sprintf("%04X",getZone(@_[2]));
   $pointFrom=sprintf("%04X",getPoint(@_[1]));
   $pointTo=sprintf("%04X",getPoint(@_[2]));
   $sessionPassword=(scalar(@_)==3?"\x00":@_[3]);
#$sessionPassword="\x00";
   return eval('return "\x'.substr($nodeFrom,2,2).'\x'.substr($nodeFrom,0,2).'\x'.substr($nodeTo,2,2).'\x'.substr($nodeTo,0,2).
	'\x'.substr($yearOfCreate,2,2).'\x'.substr($yearOfCreate,0,2).
	'\x'.substr($monthOfCreate,2,2).'\x'.substr($monthOfCreate,0,2).
	'\x'.substr($dayOfCreate,2,2).'\x'.substr($dayOfCreate,0,2).
	'\x'.substr($hourOfCreate,2,2).'\x'.substr($hourOfCreate,0,2).
	'\x'.substr($minOfCreate,2,2).'\x'.substr($minOfCreate,0,2).
	'\x'.substr($secOfCreate,2,2).'\x'.substr($secOfCreate,0,2).
	'\x00\x00\x02\x00'.
	'\x'.substr($netFrom,2,2).'\x'.substr($netFrom,0,2).
	'\x'.substr($netTo,2,2).'\x'.substr($netTo,0,2).
	'\xFE\x00'.$sessionPassword.returnZeros(8-length($sessionPassword)).
	'\x'.substr($zoneFrom,2,2).'\x'.substr($zoneFrom,0,2).
	'\x'.substr($zoneTo,2,2).'\x'.substr($zoneTo,0,2).
	'\x'.substr($netTo,2,2).'\x'.substr($netTo,0,2).
	'\x00\x01\x00\x5F\x01\x00'.
	'\x'.substr($zoneFrom,2,2).'\x'.substr($zoneFrom,0,2).
	'\x'.substr($zoneTo,2,2).'\x'.substr($zoneTo,0,2).
	'\x'.substr($pointFrom,2,2).'\x'.substr($pointFrom,0,2).
	'\x'.substr($pointTo,2,2).'\x'.substr($pointTo,0,2).
	'\x00\x00\x00\x00";');
}

sub newPKTechoMessage{
   # Создание эхосообщения для добавления в пакет.
   # * AddressFrom: Адрес отправителя
   # * AddressTo: Адрес линка
   # * msgNameTo: Имя адресата эхописьма
   # * msgNameFrom: Наше имя
   # * msgSubject: Сабж письма
   # * msgArea: Эха, в которую шлём письмо
   # * msgID: Идентификатор письма
   # * msgText: Текст письма
   my $nodeFrom=sprintf("%04X",getNode(@_[1]));
   my $nodeTo=sprintf("%04X",getNode(@_[2]));
   my $netFrom=sprintf("%04X",getNet(@_[1]));
   my $netTo=sprintf("%04X",getNet(@_[2]));
   my $attributes='\x00\x00';#2 байта атрибутов сообщения (мл. разряд:ст.разряд)
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
   my $body=$_[8];
   my $toName=$_[3];
   my $ourName=$_[4];
   my $subj=$_[5];
   $toName=~s/"/\\"/g;
   $ourName=~s/\"/\\\"/g;
   $subj=~s/\"/\\\"/g;
   $body=~s/([^\r])\r\n/$1\r/g;
   $body=~s/\n/\r/g;
   $body=~s/\x0D\x00$//;
   # Win2Dos
   die ("FIDO::PKT: body of echomessage is binary !!! (uue code is not accepted)") if textType($body)==2;
   $subj=~tr/\xA8\xB8\xC0-\xDF\xE0-\xFF/\xF0\xF1\x80-\x9F\xA0-\xAF\xE0-\xEF/ if (!textType($subj));
   $body=~tr/\xA8\xB8\xC0-\xDF\xE0-\xFF/\xF0\xF1\x80-\x9F\xA0-\xAF\xE0-\xEF/ if (!textType($body));
   return eval('return "\x02\x00'.
	'\x'.substr($nodeFrom,2,2).'\x'.substr($nodeFrom,0,2).
	'\x'.substr($nodeTo,2,2).'\x'.substr($nodeTo,0,2).
	'\x'.substr($netFrom,2,2).'\x'.substr($netFrom,0,2).
	'\x'.substr($netTo,2,2).'\x'.substr($netTo,0,2).$attributes.
	'\x00\x00'.getFidoDate().'\x00'.$toName.'\x00'.$ourName.'\x00'.$subj.
	'\x00AREA:'.uc(@_[6]).'\x0D\x01TID: InternetFix 1.0/Win32\x0D\x01MSGID: '.
	@_[1].'\@fidonet '.lc(@_[7]).'\x0D\x01PID: Net::PKT\x0D\x01CHRS: '.
	'CP866 2\x0D";').$body."\x0DSEEN-BY: ".getNet(@_[1]).'/'.getNode(@_[1])."\x0D\x00";
}

sub newPKTmessage{
   # Создание сообщения для добавления в пакет.
   # * AddressFrom: Адрес отправителя
   # * AddressTo: Адрес получателя
   # * msgNameTo: Имя адресата эхописьма
   # * msgNameFrom: Наше имя
   # * msgSubject: Сабж письма
   # * msgID: Идентификатор письма
   # * msgText: Текст письма
   # * Значение клуджа "PID"
   # Если в поле "От" или "Кому" или "Тема письма" встретится символ '"', произойдёт сбой
   my $nodeFrom=sprintf("%04X",getNode(@_[1]));
   my $nodeTo=sprintf("%04X",getNode(@_[2]));
   my $netFrom=sprintf("%04X",getNet(@_[1]));
   my $netTo=sprintf("%04X",getNet(@_[2]));
   my $attributes=@_[3] || '\x01\x00';#2 байта атрибутов сообщения (мл. разряд:ст.разряд)
   $attributes='\x00\x00' if (length(@_[3])!=2);
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
   my $body=$_[7];
   my $pid=$_[8];
   $body=~s/([^\r])\r\n/$1\r/g;
   $body=~s/\n/\r/g;
   $body=~s/\x0D\x00$//;
   $year+=1900;
   $mon++;
   $mon='0'.$mon if $mon<10;
   $mday='0'.$mon if $mday<10;
   $hour='0'.$hour if $hour<10;
   $min='0'.$min if $min<10;
   $sec='0'.$sec if $sec<10;
   return eval('return "\x02\x00'.
	'\x'.substr($nodeFrom,2,2).'\x'.substr($nodeFrom,0,2).
	'\x'.substr($nodeTo,2,2).'\x'.substr($nodeTo,0,2).
	'\x'.substr($netFrom,2,2).'\x'.substr($netFrom,0,2).
	'\x'.substr($netTo,2,2).'\x'.substr($netTo,0,2).$attributes.
	'\x00\x00'.getFidoDate().'\x00'.@_[3].'\x00'.@_[4].'\x00'.@_[5].
	'\x00\x01INTL '.getZone($_[2]).':'.getNet($_[2]).'/'.getNode($_[2]).' '.
	getZone($_[1]).':'.getNet($_[1]).'/'.getNode($_[1]).'\x0D\x01TOPT '.
	getPoint($_[2]).'\x0D\x01FMPT '.getPoint($_[1]).
	'\x0D\x01TID: InternetFix 1.0/Win32\x0D\x01MSGID: '.
	@_[1].'\@fidonet '.lc(@_[6]).'\x0D\x01PID: '.($pid ne ''?$pid:"Net::PKT").'\x0D\x01CHRS: '.
	'CP866 2\x0D";').$body."\x0D\x01Via ".$_[1]."\@fidonet \@".$year.$mon.$mday.'.'.
	$hour.$min.$sec.".UTC+3 InternetFix 1.0 \x0D\x00";
}

sub end(){
   return "\x00\x00";
}

sub write(){
   # * PathToOutbound
   # * Package
   # * NodeAddress (куда шлём)
   # * MainNodeAddress (адрес, с соответствии с которым определяем суффикс оутбаунда)
   #1070722284
   #3FD1ECEC
   #N0028066.zip
   #0aad5c4c.zip
   #1449cf03.pkt
   #144baf01.pkt
   #3FC6CFC1.PKT
   return 0 if (!-d @_[1]);
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
   my $path=$_[1];
   my $body=$_[2];
   my $curDay=uc(substr(getNameOfDay($wday),0,2));
   my $fileName='';
   my $outbSuffix=(($_[4] ne '' && getZone($_[4])!=getZone($_[3]))?'.'.sprintf("%03X",getZone($_[3])):'');
   mkdir($path.$outbSuffix) or dieLog("Cannot create dir ".$path.$outbSuffix.": $!") if (!-d $path.$outbSuffix);
   return 0 if (-e $path.$outbSuffix.'/'.lc(sprintf("%04X",getNet($_[3])).sprintf("%04X",getNode($_[3]))).'.bsy' ||
		-e $path.$outbSuffix.'/'.sprintf("%04X",getNet($_[3])).sprintf("%04X",getNode($_[3])).'.BSY');
   opendir(DIRPKT,$path.$outbSuffix) or dieLog ("Cannot open dir $path.$outbSuffix !");
   while($file=readdir(DIRPKT)){
      $fileName=$file if ($file=~/\.$curDay\d$/i);
      $fileName=~/^N(....)/;
      last if (substr($fileName,0,1) eq 'N' && $1 eq sprintf("%04X",getNode($_[3])));
      $fileName='' if (substr($fileName,0,1) eq 'N' && $1 ne sprintf("%04X",getNode($_[3])));
   }
   closedir(DIRPKT);
   if ($fileName ne ''){
      #my $razsh=substr($fileName,-1);
      #$fileName=sprintf("%X",time).'.'.$curDay.genUniqueSymbol($razsh);
      # Максимальный размер бандла - 512419
      # N033E309.TU0 - для 0x033E (/830) узла
      # Вскрываем самый свежий бандл и вмещаем в него наш пакет
$zip_file='../../include/zip/zip.exe';
if (0){
open(PKT,">".$path.$outbSuffix.'/'.($uniqueNameOfPKT+1)) or die("FIDO::MSG: Cannot create file ".($uniqueNameOfPKT+1)." !");
binmode(PKT);
print PKT $body;
close(PKT);
my $command="$zip_file $path$outbSuffix/$fileName $path$outbSuffix/".($uniqueNameOfPKT+1);
open(BUNDLE,"|$command") or die($command);
print join("",<BUNDLE>)."\n";
close(BUNDLE);
unlink($command);
}
else
{
      $zip = Archive::Zip->new();
      return 0 unless $zip->read( $path.$outbSuffix.'/'.$fileName ) == AZ_OK;
      $member = $zip->addString( $body, sprintf("%X",$uniqueNameOfPKT+1).".PKT" );
      #unlink($path.$outbSuffix.'/'.$fileName);
      return 0 unless $zip->writeToFileNamed( $path.$outbSuffix.'/'.$fileName.'TMP' ) == AZ_OK;
      return 0 if !rename ($path.$outbSuffix.'/'.$fileName.'TMP',$path.$outbSuffix.'/'.$fileName);
}
      $uniqueNameOfPKT++;
      return 1;
   }
   else {
      my $tm=substr(sprintf("%2X",time),0,3);
      $fileName='N'.sprintf("%04X",getNode($_[3])).$tm.'.'.$curDay.'0';
      # Создаём новый бандл и швыряем в него пакет
      my $zip = Archive::Zip->new();
      $member = $zip->addString( $body, sprintf("%X",$uniqueNameOfPKT+1).".PKT" );
      $member->desiredCompressionMethod( COMPRESSION_DEFLATED );
      #return 0 unless $zip->writeToFileNamed( $path.$outbSuffix.'/'.$fileName ) == AZ_OK;
      $zip->writeToFileNamed( $path.$outbSuffix.'/'.$fileName );
      writeFLO($path.$outbSuffix,$fileName,@_[3]);
      $uniqueNameOfPKT++;
      return 1;
   }
}

sub genUniqueSymbol{
   return 0 if length(@_[0])!=1;
   my $symbols='0123456789qwertyuiopasdfghjklzxcvbnm';
   my @sym=split('',$symbols);
   my $check=0;
   foreach $s(@sym){
      if ($s eq @_[0]){
         $check=1;
         next;
      }
      next if !$check;
      return $s;
   }
   return 0;
}

sub writeFLO{
   # * PathToOutbound
   # * BundleFileName
   # * NodeAddress
   # Check Pathnames (Perhaps, files, which listed in this list, no longer actuality ?)
   #139C0028.FLO
   my $nodeAddress=sprintf("%04X",getNet(@_[2])).sprintf("%04X",getNode(@_[2]));
   if (-e @_[0]."/$nodeAddress.FLO"){
      open (FLO,@_[0]."/$nodeAddress.FLO");
      my @flo=<FLO>;
      close(FLO);
      my @flo2;
      my $recordRequired=1;
      foreach $fl(@flo){
	 $fl=~s/[\^\x0A\x0D]//g;
	 if (-e $fl){
	    $recordRequired=1 if $fl eq @_[0].'/'.@_[1];
	    push @flo2,"^".$fl;
	 }
      }
      push(@flo2,"^".@_[0].'/'.@_[1])."\r\n";
      if (join('',@flo) ne join('',@flo2)){
         open (FLO,">".@_[0]."/$nodeAddress.FLO") or return 0;
         print FLO join("\r\n",@flo2);
         close(FLO);
      }
      return 1;
   }
   open (FLO,">".@_[0]."/$nodeAddress.FLO") or return 0;
   print FLO "^".@_[0].'/'.@_[1]."\r\n";
   close(FLO);
   return 1;
}

sub PKTtoMSG{
   # @_[1] - обрабатываемый пакетный файл, @_[2] - путь к директории netmail
   shift;
   my $pktfile=shift;
   my $path2netmail=shift;
   open(FILE,$pktfile) or die "$!";
   binmode(FILE);
print "file=".$pktfile."\n";
   my @fl=<FILE>;
   close(FILE);
   my $fl=join("",@fl);
   $fl=substr($fl,57);# Отсекаем заголовок пакета
   @fl=split(/\x00\x02\x00/,$fl);
   my $str;
   my $msgid;
   my %pktInfo;
   my $dosTime=sprintf("%08X",unix2DosTime);
   $dosTime=eval('return "\x'.substr($dosTime,0,2).'\x'.substr($dosTime,2,2).'\x'.substr($dosTime,4,2).
	'\x'.substr($dosTime,6,2).'";');
   shift(@fl);
print "length=".scalar(@fl)."\n";
   foreach $str(@fl){
      if (scalar(searchMSGID($path2netmail,kludge('MSGID:',$str)))){
	 print "Ignore letter - msgid is loop...\n";
	 next;# Данное письмо уже лежит в директории netmail 
      }
      $pktInfo{'BinFromNode'}=substr($str,0,2);
      $pktInfo{'BinToNode'}=substr($str,2,2);
      $pktInfo{'BinFromZone'}=substr($str,4,2);
      $pktInfo{'BinToZone'}=substr($str,6,2);
      $pktInfo{'Flags'}=substr($str,8,2);
      $pktInfo{'Cost'}=substr($str,10,2);
      $pktInfo{'Date'}=substr($str,12,19);
      $str=substr($str,31);
      $str=~s/([^\x00]+)\x00//;
      $pktInfo{'ToName'}=$1;
      $str=~s/([^\x00]+)\x00//;
      $pktInfo{'FromName'}=$1;
      $str=~s/([^\x00]+)\x00//;
      $pktInfo{'Subject'}=$1;
      $pktInfo{'Text'}=$str;# Текст письма вместе с кладжами
      $pktInfo{'DosDateCreate'}="\x00\x00\x00\x00";# Дата создания (DOS формат)
      $pktInfo{'DosDateRcvd'}=$dosTime;# Дата приёма (DOS формат)
      $pktInfo{'ReplyTo'}="\x00\x00";# Указатель на предшествующее письмо
      $pktInfo{'ReplyNext'}="\x00\x00";# Указатель на следующее письмо
      #$str=~s/([^\x00])\x00([^\x00]{5,5})\x00\x00\x00(\d\d \w\w\w \d\d  \d\d\:\d\d\:\d\d)\x00([^\x00]+)\x00([^\x00]+)\x00([^\x01]+)//;
      open(PMFILE,">".getDirPath($path2netmail).getExceptionalFileName($path2netmail)) or die "PKTtoMSG: $!";
      binmode PMFILE;
      print PMFILE $pktInfo{'FromName'}.returnZeros(36-length($pktInfo{'FromName'})).
		$pktInfo{'ToName'}.returnZeros(36-length($pktInfo{'ToName'})).
		$pktInfo{'Subject'}.returnZeros(72-length($pktInfo{'Subject'})).$pktInfo{'Date'}.
		"\x00\x00\x00".$pktInfo{'BinToNode'}.$pktInfo{'BinFromNode'}.$pktInfo{'Cost'}.
		$pktInfo{'BinFromZone'}.$pktInfo{'BinToZone'}.$pktInfo{'DosDateCreate'}.$pktInfo{'DosDateRcvd'}.$pktInfo{'ReplyTo'}.$pktInfo{'Flags'}.$pktInfo{'ReplyNext'}.$pktInfo{'Text'};
#      print PMFILE $5.returnZeros(36-length($5)).$4.returnZeros(36-length($4)).substr($6,0,length($6)-1).returnZeros(72-length(substr($6,0,length($6)-1))).$3."\x00\x01\x00\x28\x00$1\x00\x00\x00$2\x2E\x39\x0C\x00\x00\x00\x00\x00\x00\x85\x00\x00\x00".substr($str,0,length($str)-1);;
      close(PMFILE);
   }
   unlink($pktfile);
}
sub get{
   open(FILE,@_[1]) or die "$!";
   my @fl=<FILE>;
   close(FILE);
   my $fl=join("",@fl);
   #$data=~/(\x00\x02\x00\(\x00k\x00\x9C\x13\x93\x13\x81)/;
   @fl=split(/\x00\x02\x00\(\x00[\s|\S]{3,3}\x13[\s|\S]{1,1}\x13\x81/,$fl);
   shift @fl;
   my $msgAr=();
   my $a;
   my @localAr;
   my @intl;
   foreach $a(@fl){
      $a=~/(\d\d \w\w\w \d\d  \d\d\:\d\d\:\d\d)\x00([^\x00]+)\x00([^\x00]+)\x00([^\x00]*)/;
      #Date,ToName,FromName,ToAddress,FromAddress,Subj,Text
      @intl=split(' ',kludge('INTL',$a));
      @localAr=($1,$2,$3,$intl[0].(kludge('TOPT',$a) ne ''?'.'.kludge('TOPT',$a):''),$intl[1].(kludge('FMPT',$a) ne ''?'.'.kludge('FMPT',$a):''),$4);
      $a=~/\x0D[^\x01]([^\x01]*)/;
      push(@localAr,$1);
      push(@msgAr,\@localAr);
      #print join(",",($1,$2,$3))."<br><br>\n\n";
   }
   return @msgAr;
=head
   $fromName=trim(substr($fl,0,20));
   @temp=split(/ /,kludge("INTL"));
   $fromAddress=$temp[1].".".kludge("FMPT");
   #$fromAddress=~/\x01FMPT (\d+)\x0D/;
   #$fromAddress="$1";
   $toName=trim(substr($fl,21,51));
   $toAddress=$temp[0].".".kludge("TOPT");
   $date=trim(substr($fl,144,19));
   $subject=trim(substr($fl,72,71));
   $fl=~/\x0D([^\x01]+)/;
   $text=$1;
=cut
}
=head
sub new{
#1-36:from name
#37-72:to name
#73-144:subject
#144-163:data
#($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
   my @time=localtime(time);
   my $msg=@_[1].returnZeros(36-length(@_[1])).@_[3].returnZeros(36-length(@_[3])).@_[5].
	returnZeros(72-length(@_[5])).sprintf("%02d",$time[3]).' '.nameDay($time[4]+1).' '.
	substr($time[5],length($time[5])-2,2).'  '.sprintf("%02d",$time[2]).':'.
	sprintf("%02d",$time[1]).':'.sprintf("%02d",$time[0])."\x00\x01\x00(\x00(\x00\x00".
	"\x00\x9C\x13\x9C\x13\xF9\x2E'S\x00\x00\x00\x00\x00\x00\x81\x01\x00\x00\x01INTL ";
   @_[4]=~/(\d\:\d+\/\d+)/;
   $msg.="$1 ";
   @_[2]=~/(\d\:\d+\/\d+)/;
   $msg.=$1;
   if (@_[4]=~/\d\:\d+\/\d+\.(\d+)/){
      $msg.="\x0D\x01TOPT $1";
   }
   if (@_[2]=~/\d\:\d+\/\d+\.(\d+)/){
      $msg.="\x0D\x01FMPT $1";
   }
   $msg.="\x0D\x01MSGID: @_[2]\@fidonet 3f21c043\x0D\x01CHRS: +7 FIDO 2\x0D@_[6]\x0D\x00";
   open(MSG,">".@_[7].(substr(@_[7],length(@_[7])-1,1) ne '/' && substr(@_[7],length(@_[7])-1,1) ne '\\'?'/':'').getExceptionalFileName(@_[7])) or die "$!";
   print MSG $msg;
   close(MSG);
}
=cut
