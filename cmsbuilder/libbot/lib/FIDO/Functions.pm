package FIDO::Functions;
use Exporter;
use Math::Logic;
@ISA=qw(Exporter);
@EXPORT=qw(getFidoDate num2month setQuote outboxQuote getPoint getNode getNet getZone trim kludge returnZeros getExceptionalFileName getDirPath getExceptionalID searchMSGID nameDay getNameOfDay checkNetMail);
#@EXPORT_OK=qw();
sub getFidoDate{
   my @time=localtime(time);
   return sprintf("%02d",$time[3]).' '.nameDay($time[4]+1).' '.
	substr($time[5],length($time[5])-2,2).'  '.sprintf("%02d",$time[2]).':'.
	sprintf("%02d",$time[1]).':'.sprintf("%02d",$time[0]);
}
sub setQuote{
   # Обращение только из исходных программ. Не из других модулей !
   shift;
   $quoteDBPath=shift;# Путь к каталогу, в котором будет хранится файл базы
   $quoteLimit=shift || 1048576;# Дневной лимит
   $quoteArrayLimit=shift || 1000;# Квота на количество записей в quote.db
}
sub outboxQuote{
   # Проверяет, не превышена ли дневная квота на исходящий трафик
   # Формат файла quote.db: кол-во_дней_с_начала_года|дневной_трафик_в_байтах
   my $addSum=shift;# Количество отсылаемых байт, которые будут учтены
   return -1 if !-e $path;
   open(QUOTE,$quoteDBPath.'/quote.db');
   my @q=<QUOTE>;
   close(QUOTE);
   while (scalar(@q)>$quoteArrayLimit){
      shift @q;
   }
   my $yday=(localtime(time))[7];
   push(@q,"$yday|0") if (join(',',@q)!~/$yday\|\d+/);
   foreach my $str(@q){
      next if $str!~/^$yday\|(\d+)/;
      my $sum=$1+$addSum;
      return 0 if $sum>$quoteLimit;
      $str="$yday|$sum";
      last;
   }
   open(QUOTE,">".$quoteDBPath.'/quote.db') or die $!;
   print QUOTE join("\n",@q);
   close(QUOTE);
   return 1;
}
sub checkNetMail{
   my $netmail=shift;
   return 1 if $netmail=~/^\d\:\d+\/\d+(\.\d+)?$/;
   return 0;
}
sub getPoint{
   if (index(@_[0],'.')==-1){
      return 0;
   }
   else {
      return substr(@_[0],index(@_[0],'.')+1);
   }
}
sub getNode{
   my $node=substr(@_[0],index(@_[0],'/')+1);
   if (index($node,'.')!=-1){
      $node=substr($node,0,index($node,'.'));
   }
   if (index($node,'@')!=-1){
      $node=substr($node,0,index($node,'@'));
   }
   return $node;
}

sub getNet{
   my $net=substr(@_[0],index(@_[0],':')+1);
   return substr($net,0,index($net,'/'));
}

sub getZone{
   return substr(@_[0],0,index(@_[0],':'));
}

sub getNameOfDay{
   if (@_[0]==1){
      return 'Monday';
   }
   if (@_[0]==2){
      return 'Tuesday';
   }
   if (@_[0]==3){
      return 'Wednesday';
   }
   if (@_[0]==4){
      return 'Thursday';
   }
   if (@_[0]==5){
      return 'Friday';
   }
   if (@_[0]==6){
      return 'Saturday';
   }
   if (@_[0]==0){
      return 'Sunday';
   }
}

sub num2month{
   my $num=shift;
   $num=shift if ref($num);
   return 1 if $num=~/^Jan/i;
   return 2 if $num=~/^Feb/i;
   return 3 if $num=~/^Mar/i;
   return 4 if $num=~/^Apr/i;
   return 5 if $num=~/^May/i;
   return 6 if $num=~/^Jun/i;
   return 7 if $num=~/^Jul/i;
   return 8 if $num=~/^Aug/i;
   return 9 if $num=~/^Sep/i;
   return 10 if $num=~/^Oct/i;
   return 11 if $num=~/^Nov/i;
   return 12 if $num=~/^Dec/i;
   return 0;
}

sub nameDay{
   # Sorry, invalid name of function :)
   if (@_[0]==1){
      return 'Jan';
   }
   if (@_[0]==2){
      return 'Feb';
   }
   if (@_[0]==3){
      return 'Mar';
   }
   if (@_[0]==4){
      return 'Apr';
   }
   if (@_[0]==5){
      return 'May';
   }
   if (@_[0]==6){
      return 'Jun';
   }
   if (@_[0]==7){
      return 'Jul';
   }
   if (@_[0]==8){
      return 'Aug';
   }
   if (@_[0]==9){
      return 'Sep';
   }
   if (@_[0]==10){
      return 'Oct';
   }
   if (@_[0]==11){
      return 'Nov';
   }
   if (@_[0]==12){
      return 'Dec';
   }
}
sub searchMSGID{
   # Осуществляет поиск писем с заданным MSGID'ом.
   #@_[0] - путь к директории netmail, @_[1] - искомый идентификатор
   my $file;
   my @retAr;
   opendir(SDIR,$_[0]) or die "searchMSGID: $!";
   while($file=readdir(SDIR)){
      if ($file=~/(\d+)\.msg/i){
	 open(SFILE,getDirPath($_[0]).$file) or die "searchMSGID: $!";
	 my @fl=<SFILE>;
	 my $fl=join('',@fl);
	 close(SFILE);
	 if (@_[1] eq kludge("MSGID:",$fl)){
	    push(@retAr,$file);
	 }
      }
   }
   closedir(SDIR);
   return @retAr;
}
sub getExceptionalFileName{
   my $file;
   my $count=0;
   if (!-d @_[0]){
      die "Module CGI::MSG. Function getExceptionalFileName(). Invalid directory name (@_[0])";
   }
   opendir(DIRExc,$_[0]) or die "Cannot open".$_[0].": $!";
   while($file=readdir(DIRExc)){
      if ($file=~/(\d+)\.msg/i){
	 if ($1>$count){
	    $count=$1;
	 }
      }
   }
   closedir(DIRExc);
   $count++;
   return "$count.MSG";
}
sub getDirPath{
   # Вставляет по необходимости слэш после @_[0] в случае, если его нет в последней позиции @_[0].
   return @_[0].(substr(@_[0],length(@_[0])-1,1) ne '/' && substr(@_[0],length(@_[0])-1,1) ne '\\'?'/':'');
}
my $uniqueNameOfMSG=0;
sub getExceptionalID{
   @_[0]=(@_[0] eq 'FIDO::MSG'?@_[1]:@_[0]);
   if ($lastEID ne '' && $lastEID!~/ffffffff/i){
      $lastEID=sumhex($lastEID."+1");
      return $lastEID;
   }
   my $value=substr(sprintf("%x",time),0,8);# 3f200000 ?
   my @values;# Массив всех MSGID'ов в директории хранения netmail-писем.
   my $countFiles=0;
   opendir(DIRID,$_[0]) or die "$! (".$_[0].")";
   while($file=readdir(DIRID)){
      if ($file=~/.msg/i){
	 $countFiles++;
	 open(FID,getDirPath(@_[0]).$file) or die "$! (".getDirPath(@_[0]).$file.")";
	 @data=<FID>;
	 close(FID);
	 $data=join("",@data);
	 $data=~/\x0D\x01MSGID\: [\d\:\d+\/[\d|\.]+\@fidonet]|[\w|\.]+ ([0-9a-fA-F]{8,8})/;
	 $values[$#values+1]=$1;
      }
   }
   closedir(DIRID);
   if ($countFiles==0){# Если *.msg-файлов в netmail-директории нет, выходим.
      $lastEID=sprintf("%08x",time());
      return $lastEID;
   }
   my $count=1;
   my $check=1;
   my $wr='';
   my $a=0;
=head
   for ($a=0;$a<scalar(@values);$a++){
      $wr.='['.$values[$a].']|';
   }
   $wr=substr($wr,0,rindex($wr,'|'));
=cut
   if ($lastEID eq ''){
      $lastEID=$value;
   }
   my $checkCount=0;
   my $count=0;
   my $check=1;
   my $trigger=0;
=head
Алгоритм работы цикла таков: Пробегаемся по MSGID'ам всех *.msg файлов в заданной директории.
Если MSGID совпадает с $lastEID, то $trigger изменяет своё значение, сигнализируя,
что после инкрементирования $lastEID необходимо заново пробежатся по всем файлам, иначе
возможна ситуация, когда последняя ячейка массива @values содержит значение, совпадающее
с $lastEID, последняя переменная в этом случае инкрементируется, и окажется равной
значению одной из первых ячеек массива @values.
=cut
   while (1){
      if ($values[$count]=~/$lastEID/i){
	 $check=0;
	 $trigger=1;
      }
      if ($check==0){
         if ($lastEID=~/ffffffff/i){
	    $lastEID='00000000';
         }
	 $lastEID=sumhex($lastEID."+1");
	 $check=1;
      }
      $count++;
      $checkCount++;
      if ($count==$countFiles){
	 if ($trigger==0){
	    last;
 	 }
	 $count=0;
 	 $trigger=0;
      }
      last if $checkCount>10000;# Если писем хранится больше 10000, то возникнет ошибка...
   }
   return $lastEID;
}
$lastEID='';#Если данная переменная пуста - генерим уникальный ID, иначе инкрементируем
#значение данной переменной и заносим его в MSGID создаваемого письма. Т.е. считается,
#что во время работы InternetFix'а работа с netmail-директорий со стороны других
#приложений не ведётся
sub trim{
   my $text=@_[0];
   $text=~s/\x00//g;
   return $text;
}
sub kludge{
   my $fl=@_[1];
   if ($fl=~/\x01$_[0] ([^\x0D]+)\x0D/){
      return $1;
   }
   else {
      return '';
   }
}
sub returnZeros{
   my $a;
   my $str='';
   for ($a=0;$a<@_[0];$a++){
      $str.="\x00";
   }
   return $str;
}
1;