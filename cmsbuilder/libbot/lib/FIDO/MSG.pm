package FIDO::MSG;
use Exporter;
use Math::Logic;
use FIDO::Functions;
use Data::Date;
use string;
@ISA=qw(Exporter);
#@EXPORT=qw($fromName $fromAddress $toName $toAddress $date $subject $text $filePath);
#@EXPORT_OK=qw();

sub getVar{
   return eval("\$@_[1]");
}

sub open{
   open(FILE,@_[1]) or die "$!";
   # Обязательно binmode ! Иначе кодировка в ifix_template() неверно обрабатываться будет
   binmode(FILE);
   @fl=<FILE>;
   close(FILE);
   $fl=join("",@fl);
   $fromName=trim(substr($fl,0,36));
   @temp=split(/ /,kludge("INTL",$fl));
   $fromAddress=$temp[1].(kludge("FMPT",$fl) ne ''?".".kludge("FMPT",$fl):'');#Клуджа "FMPT" может и не быть
   #$fromAddress=~/\x01FMPT (\d+)\x0D/;
   #$fromAddress="$1";
   $toName=trim(substr($fl,36,36));
   $toAddress=$temp[0].(kludge("TOPT",$fl) ne ''?".".kludge("TOPT",$fl):'');# То же самое
   $date=trim(substr($fl,144,20));
   $subject=trim(substr($fl,72,72));
   $MSGID_orig=kludge("MSGID:",$fl);
   $MSGID=substr($MSGID_orig,index($MSGID,' ')+1);
   $REPLYADDR=kludge("REPLYADDR:",$fl);
   $REPLYTO=kludge("REPLYTO:",$fl);
   $REPLY=kludge("REPLY:",$fl);
   $PID=kludge("PID:",$fl);
   $fl=~/\x0D([^\x01]+)/;
   $text=$1;
}

sub new{
=head
Письмо с файл-аттачом: Uns Kfs Pvt Loc K/s Att
Обычное письмо: Uns Pvt Loc K/s

1-36:from name
37-72:to name
73-144:subject
144-163:data
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
=cut
   my $fromName=$_[1];
   my $fromAddress=$_[2];
   my $toName=$_[3];
   my $toAddress=$_[4];
   my $subj=$_[5];
   my $body=$_[6];
   my $path=$_[7];
   my $attributes=$_[8];
   # логическое значение параметра. При true MSGID исходного письма и
   # адрес отправителя берётся из getVar() (из ранее открытого письма)
   my $replyKludge=$_[9] || 0;
   # $addKludges="\x01SERVER_NAME=localhost", etc
   my $addKludges=$_[10] || '';

   $fromName=substr($fromName,0,36);
   $fromName=~s/(["\\\@\$\%])/\\$1/g;
   # В качестве "toName" может фигурировать E-Mail
   $toName=substr($toName,0,36);
   $toName=~s/(["\\\@\$\%])/\\$1/g;
   $subj=substr($subj,0,72);# Обрезаем сабж, если его длина более 72 символов
   $subj=~s/(["\\\@\$\%])/\\$1/g;
   # \r\n to \r
   $body=~s/\r\n/\r/g;
   $body=~s/\n/\r/g;
   $addKludges='' if substr($addKludges,0,1) ne "\x01";
   $addKludges="\r$addKludges" if $addKludges ne '';
   # В $attributes передаются не строки типа "file", а должны двоичные флажки...
   # Ставим атрибуты PVT UNS LOC K/S, не внимая $attributes
   $attributes='0181';
   return 0 if !outboxQuote(length($body));
   my $netFrom=sprintf("%04X",getNet($fromAddress));
   my $netTo=sprintf("%04X",getNet($toAddress));
   my $zoneFrom=sprintf("%04X",getZone($fromAddress));
   my $zoneTo=sprintf("%04X",getZone($toAddress));
   my $nodeFrom=sprintf("%04X",getNode($fromAddress));
   my $nodeTo=sprintf("%04X",getNode($toAddress));
   my $pointFrom=sprintf("%04X",getPoint($fromAddress));
   my $pointTo=sprintf("%04X",getPoint($toAddress));
   my $dosTime=sprintf("%08X",unix2DosTime);
   my $msg=eval('return "'.$fromName.returnZeros(36-length(replace($fromName,'/\\\\/g'))).$toName.returnZeros(36-length(replace($toName,'/\\\\/g'))).$subj.
	returnZeros(72-length(replace($subj,'/\\\\/g'))).getFidoDate().'\x00\x00\x00'.
	'\x'.substr($nodeTo,2,2).'\x'.substr($nodeTo,0,2).
	'\x'.substr($nodeFrom,2,2).'\x'.substr($nodeFrom,0,2).'\x00\x00'.
	'\x'.substr($netFrom,2,2).'\x'.substr($netFrom,0,2).
	'\x'.substr($netTo,2,2).'\x'.substr($netTo,0,2).
	'\x'.substr($dosTime,0,2).'\x'.substr($dosTime,2,2).'\x'.substr($dosTime,4,2).'\x'.substr($dosTime,6,2).
	'\x00\x00\x00\x00\x00\x00'.
	'\x'.substr($attributes,2,2).'\x'.substr($attributes,0,2).
	'\x00\x00\x01INTL ";');
	#'\x00\x00\x00\x00\x00\x00'.(index($attributes,'file')!=-1?'\x91':'\x81').'\x01\x00\x00\x01INTL ";');
   $toAddress=~/(\d\:\d+\/\d+)/;
   $msg.="$1 ";
   $fromAddress=~/(\d\:\d+\/\d+)/;
   $msg.=$1;
   if ($toAddress=~/\d\:\d+\/\d+\.(\d+)/){
      $msg.="\x0D\x01TOPT $1";
   }
   if ($fromAddress=~/\d\:\d+\/\d+\.(\d+)/){
      $msg.="\x0D\x01FMPT $1";
   }
   $msg.="\x0D\x01MSGID: $fromAddress\@fidonet ".getExceptionalID($path).($replyKludge?"\x0D\x01REPLY: ".$MSGID_orig:'').
	"\x0D\x01PID: Net::MSG\x0D\x01CHRS: CP866 2$addKludges\x0D$body\x0D\x00";
   $filePath=getDirPath($path).getExceptionalFileName($path);
   open(MSG,">$filePath") or die "$!";
   binmode(MSG);
   print MSG $msg;
   close(MSG);
   return 1;
}
1;