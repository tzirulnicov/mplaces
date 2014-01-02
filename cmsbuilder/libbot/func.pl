#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser set_message);
#use FindBin qw($Bin);

sub checkMail{
   my $mail=shift;
   return 1 if $mail=~/^[\w\.\d\_]+@[\w\.\d\_]+$/;
   return 0;
}

sub dieLog{
   return if ($_[1]!=-1 && scalar(@_)==2 && (!$logLevel || ($logLevel==1 && $_[1]!=1)));
   Data::Log->write($pathToLog.'/'.(scalar(@_)!=2?'error':'action').'.log',@_[0],$maxLogFileSize) if $logConsole;
   print STDOUT $_[0].$splitStringsChar if (scalar(@_)==2 && $logConsole && $_[1]!=-1);
   exit if $_[1]==-1;
   die $_[0] if scalar(@_)!=2;
}

BEGIN{
   # Если у вас Perl 5.0, то могут возникнуть проблемы с вычислением путей, при некорректных
   # правах доступа на сервере. Если при запуске робота выводится сообщение вида
   # "Не могу найти файл .//config.pl", укажите в нижеприведённой переменной полный путь,
   # по которому расположен данный файл ("config.pl"). Пример: $pathToBin="/home/html";
   $pathToBin="C:/localhost/www/phpmyweb";
   $Bin.='/..' if (!-e $Bin.'/config.pl');
   if (!-e $Bin."/config.pl"){
      die "Incorrect path to Bin: '$pathToBin' !!!" if !-d $pathToBin;
      $pathToBin=substr($pathToBin,0,-1) if substr($pathToBin,-1)=~/[\\\/]/;
      $Bin=$pathToBin;
   }
   push(@INC,"/home/tz/lib");
   require $Bin."/config.pl";
if (defined($ENV{'DOCUMENT_ROOT'})){
#charset=CP866
   print "Content-type: text/html;charset=windows-1251\nPragma: No-Cache\n\n";
   $splitStringsChar="<br>";
}
else {
   $splitStringsChar="\n";
}
=head
[Thu Jun 3 11:07:42 2004] SMTP.pm: Can't locate Net/SMTP.pm in @INC (@INC contains: /usr/libdata/perl/5.00503/mach /usr/libdata/perl/5.00503 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd /usr/local/lib/perl5/site_perl/5.005 .) at fido.pl line 38. BEGIN failed--compilation aborted at fido.pl line 38. 
=cut
   sub evalPath{
      # Преобразует относительные пути в абсолютные
      my $path=shift;
      $path=~s/\\/\//g;
      $path=$Bin.'/'.$path if (($^O=~/Win/io && $path!~/^\w{1}\:[\/|\\]/) || ($^O!~/Win/io && substr($path,0,1) ne '/'));
      $path=substr($path,0,-1) if $path=~/\/$/;
      return $path;
   }
   $pathToLog=evalPath($pathToLog);
   use Net::SMTP;
   sub mail {
      my $to=shift;
      my $subj=shift;
      my $msg=shift;
      my $smtp=Net::SMTP->new($SMTPServer);
      	    dieLog($msg.'; Error to connect '.$SMTPServer.' ('.$smtp->message.')') unless $smtp;
	    dieLog($msg.'; Error to send mail: bad "from" address ('.$smtp->message.')') unless $smtp->mail('InternetFix '.defined($FromEMail)?$FromEMail:$ENV{USER});
	    dieLog($msg.'; Error to send mail: bad address "'.$to.'" ('.$smtp->message.')') unless ($smtp->to($to));
	    $smtp->data("To: $to\nFrom: ".(defined($FromEMail)?$FromEMail:$ENV{USER})."\nContent-type: text/plain;charset=windows-1251\nSubject: ".$subj."\n\n$msg");
	    #$smtp->datasend("To: $to\rSubject: ".$subj."\r\r$msg");
	    dieLog($msg.'; Error to send mail: Connection wouldn\'t accept data ('.$smtp->message.')') unless ($smtp->dataend());
	    dieLog($msg.'; Error to send mail: Couldn\'t close connection to server ('.$smtp->message.')') unless ($smtp->quit());
   }
   sub handle_errors {
      my $msg = shift;
      $msg=~s/\n//;
      $msg=substr($msg,0,-1);
      print "<h1>Software Error</h1>\n";
      print "<p>Cause of error: $msg</p>\n";
      if ($errorMailNotify){
	 # Отправляем уведомление об ошибке
	 if (checkMail($errorMailBox)){
	    print "Send error mail...\n";
	    # Отправка по E-Mail
	    # Если 5.6.1, то Net::SMTP берётся из [ifix]/lib/Net/SMTP
	    my $smtp=Net::SMTP->new($SMTPServer);
	    dieLog($msg.'; Error to connect '.$errorMailServer.' ('.$smtp->message.')') unless $smtp;
	    dieLog($msg.'; Error to send mail: bad "from" address ('.$smtp->message.')') unless $smtp->mail('InternetFix '.defined($errorMailBox)?$errorMailBox:$ENV{USER});
	    dieLog($msg.'; Error to send mail: bad address "'.$errorMailBox.'" ('.$smtp->message.')') unless ($smtp->to($errorMailBox));
	    $smtp->data();
	    $smtp->datasend("Subject: ".(defined($errorMailSubject)?$errorMailSubject:'Error in my code')."\r\r$msg");
	    dieLog($msg.'; Error to send mail: Connection wouldn\'t accept data ('.$smtp->message.')') unless ($smtp->dataend());
	    dieLog($msg.'; Error to send mail: Couldn\'t close connection to server ('.$smtp->message.')') unless ($smtp->quit());
	 }
	 else {
	    print "Send FIDO MSG error mail\n";
#	    FIDO::MSG->new('InternetFix',$systemAddress,'Boss',(checkNetMail($ourAddress)?$ourAddress:$linkAddress),(defined($errorMailSubject)?$errorMailSubject:'Error in my code'),$msg,$pathToMSG,'');
	 }
      }
      dieLog($msg,-1);
   }
   set_message(\&handle_errors);
}
use Data::Log;
use Data::Date;
use DBI;
local $db_handle;
local @db_handleAr;
sub sql_connect{
   # Example: sql_connect("Tosser");
   my $module_name=shift || "Unknown Module";
   my $connect_num=shift;
   dieLog ($module_name.": Variable \$db_enable must be set to '1' !") if (!$db_enable);
   return 1 if (($db_handle && !$connect_num) || ($db_handleAr[$connect_num] && $connect_num));
   #eval("use DBI;");
   #dieLog($@) if $@ ne '';
   (!$connect_num?$db_handle:$db_handleAr[$connect_num])=DBI->connect("dbi:".lc($db_type).":database=".$db_table.";host=".$db_host,$db_login,$db_password);
   dieLog ("Error connecting to database ".$DBI::errstr) if ((!$db_handle && !$connect_num) || (!$db_handleAr[$connect_num] && $connect_num));
}

sub sql_query{
   # Example: sql_query("SELECT * from test.db","Tosser");
   my $query=shift;
   print "SQL=$query\n";
   my $module_name=shift || "Unknown Module";
   my $connect_num=shift;
   my $dont_reconnect=shift;
   my $check=0;
   (!$connect_num?$db_shandle:$db_shandleAr[$connect_num])=($connect_num?$db_handleAr[$connect_num]->prepare($query):$db_handle->prepare($query));
   if (!$connect_num){
      $db_shandle->execute;
      goto RECONNECT if (!$dont_reconnect && $db_shandle->err=~/Lost connection/);
      dieLog ("$module_name: Error. ".$db_shandle->errstr) if ($db_shandle->err);
   }
   if ($connect_num){
      $db_shandleAr[$connect_num]->execute;
      goto RECONNECT if (!$dont_reconnect && $db_shandleAr[$connect_num]->err=~/Lost connection/);
      dieLog ("$module_name: Error. ".$db_shandleAr[$connect_num]->errstr) if ($db_shandleAr[$connect_num]->err);
   }
   return;
   RECONNECT:
   dieLog ("$module_name: ".$db_shandle->errstr.". Ignoring...",1);
   sql_connect($module_name,$connect_num);
   sql_query($query,$module_name,$connect_num,1);   
}

sub sql_close{
   my $connect_num=shift;
   if (!$connect_num && $db_handle){
   #   $db_shandle->finish();
      $db_handle->disconnect;
      $db_handle=0;
   }
   if ($connect_num && $db_handleAr[$connect_num]){
   #   $db_shandleAr[$connect_num]->finish();
      $db_handleAr[$connect_num]->disconnect;
      $db_handleAr[$connect_num]=0;
   }
}


sub lang{
   my $key=shift;
   my $rnd;
   my $tst=$lang{$key};
   if (defined($tst->[0])){
      $rnd=int(rand()*lengthOfArrayInHash($lang{$key}));
      return $lang{$key}->[$rnd];
   }
   elsif(defined($lang{$key})){
      $lang{$key};
   }
   else {
      $key=~s/_/ /g;
      return ucfirst(substr($key,0,1)).substr($key,1);
   }
}

sub lengthOfArrayInHash{
   # Вычисляет длину вложенного в эхе массива
   # Пример: lengthOfArrayInHash($lang{'test'}) вернёт "3" при $lang{'test'}=['1','2','3'];
   $count=0;
   while(1){
      return $count if !defined($_[0]->[$count]);
      $count++;
   }
}

sub Str2Sql{
   # Ставит слэш перед символами, которые могут представлять опасность в SQL-зап
   my $str=shift;
   $str=~s/([\$\\\'\"\@])/\\$1/g;
   return $str;
}

1;
