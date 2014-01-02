package Data::Log;
#@ISA=qw(Exporter);
#@EXPORT=qw(new $test print);
#@EXPORT_OK=qw{$test};
use FIDO::Functions;
use Data::Date;
use Time::Local;
sub write{
   my $self=shift;
   my $path=shift;
   $path=~s/\\/\//g;
   my $message=shift;
   my $maxLogFileSize=shift;
   #$message=~s/\n/ /g;
#[Mon Mar 8 13:29:07 2004] [error] System error (DB result: xxxx; Interbase answer: yyyyy) [c:\localhost\www\phpmyweb\func.php] [665] 8
#   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);

   if (-e $path || -d substr($path,0,rindex($path,'/'))){
         #[28/Apr/2003:21:51:23 +0400]
	 $maxLogFileSize=sprintf("%d",substr($maxLogFileSize,0,-1))*1024 if $maxLogFileSize=~/[kкKК]/;
	 $maxLogFileSize=sprintf("%d",substr($maxLogFileSize,0,-1))*1024*1024 if $maxLogFileSize=~/[mмMМ]/;
         if ((stat($path))[7]>$maxLogFileSize){
	    open(LOG,">".$path) or die ("Cannot write $path logfile: $!");
	    print LOG '['.getDate().'] NewSysLog: logfile turned over due to size > '.$maxLogFileSize." bytes\n";
	    close(LOG);
	 }
	 else {
	    open(LOG,"$path");
	    my @logStr=<LOG>;
	    close(LOG);
	    foreach my $str(@logStr){
	       $str=~s/[\r\n]//g;
	    }
	    foreach my $str(@logStr){
	       last if $path!~/error[\.\w]+$/;
#print "\nOK|$message\n\n";
$message2=$message;
$message2=~s/([\:\\\/\.\[\]\{\}\|\&\+\?])/\\$1/;
	       if ($str=~/\[\w+ \w+ \d+ \d+\:\d+\:\d+ \d+\] \[error\] Unrecognized \[/){
#print "\n------->$str<---------\n\n";
		  $str='['.getDate().substr($str,index($str,']'),-1).eval("return ".substr($str,-1)."+1;");
#$message2 \[
		  open(LOG,">".$path) or die ("Cannot write $path logfile: $!");
		  print LOG join("\n",@logStr)."\n";
		  close(LOG);
		  return 1;
	       }
	    }
	 }
#[05 Mar 04  23:16:12] syntax error at c:/localhost/www/php
#getNameOfDay nameDay
         open(LOG,">>".$path) or die ("Cannot write $path logfile: $!");
	 if ($path=~/error[\.\w]+$/){
            print LOG '['.getDate().'] [error] '.$message.' ['.__FILE__.']'.' ['.__LINE__."] 1\n";
	 }
	 else {
            print LOG '['.getDate().'] '.$message."\n";
	 }
         close(LOG);
	 return 1;
   }
   else {
      die $message.'; File '.$path.' not found';
   }
}

sub getDate(){
   my @time=localtime(time);
   return substr(getNameOfDay($time[6]),0,3).' '.nameDay($time[4]+1).' '.sprintf("%02d",$time[3]).
	' '.sprintf("%02d",$time[2]).':'.sprintf("%02d",$time[1]).':'.sprintf("%02d",$time[0]).
	' '.($time[5]+1900);
}

sub var2regexp($var){
   # Парсит строку для для использования её в шаблоне регулярного выражения
   $var=~s/([\&\:\[\]\{\}\\\/])/$1/g;
   return $var;
}

sub getLogRecords{
#	 my @topTopics=Data::Log->analyze($Bin.'/'.$pathToLog.'/users.log','1.1.2004-7.1.2004',3,10)
   # get log records, which are created in date between current date-$period days and current date
   # Input parameters:
   # * Full path to log file
   # * Period (in days)
   # * Number of best topics
   # * Column, which we sorted (may be not present)
   my $path=$_[1];
   my $period=$_[2];
   my $topicsNum=$_[3];
   my $columnNum=$_[4] || -1;
   my @content;
   my @values;
   my $temp;
   my $date;
   return 0 if (!-e $path);
   open(LOG_AN,$path);
   @content=<LOG_AN>;
   close(LOG_AN);
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
   my $y;
   foreach $temp(@content){
      $temp=~s/[\r\n]$//g;
      $temp=~/^[-\+\?\[ ]? ?\w+ (\w+) (\d+) \d\d\:\d\d\:\d\d (\d+)/;
      $y=$3;
      $y=substr($year,-2) if !defined($3);
      $date="$2 $1 $y";
      if (Data::Date->isInInterval($date,Data::Date->subDateDay(Data::Date->curDate(),$period).'-'.Data::Date->curDate())==1){
	 push(@values,$temp) if (index($temp,'] NewSysLog: ')==-1);
      }
   }
   return @values;
}
sub intervalOut{
   #Data::Log->intervalOut($Bin.'/logs/binkd.log',$binkd_poll);
   # "1", если в логе нет записи, датированной позже, чем (текущее время - $interval)
   my $path=$_[1];# Путь к логу
   my $interval=time-$_[2]*60;#$_[2] - В минутах
#print "Path: $path; Interval: $_[2]\n";
   return 1 if (!-e $path);
   open(LOG_AN,$path);
   @content=<LOG_AN>;
   close(LOG_AN);
   my $temp;
   my $sec;
#print "Interval time: $interval\n";
   foreach $temp(@content){
      $temp=~s/[\r\n]$//g;
      #$temp=~/^[-\+\?\[ ]* ?\w+ (\w+) (\d+) (\d\d)\:(\d\d)\:(\d\d) (\d+)/;
      next if ($temp!~/^[-\+\?\[ ]+ \d+ \w+ \d\d\:\d\d\:\d\d /);
      $temp=~/^[-\+\?\[ ]+ (\d+) (\w+) (\d\d)\:(\d\d)\:(\d\d) /;
#print "Temp=$temp\n";
      #$sec=$5+$4*60+$3*3600+Data::Date->daysInMonth(num2month($1))*86400+(($6-1970)*(($6-1970)%4==0?366:365)*86400);
      $sec=timelocal($5,$4,$3,$1,(Data::Date->monthName2Number($2)-1),(localtime(time))[5]);
#print "return 0\n";
#exit;
      return 0 if ($sec>$interval && time()>$sec);
   }
@secTime=localtime($sec);
@intervalTime=localtime($interval);
#print "sec=".$secTime[3].'.'.($secTime[4]+1).'.'.($secTime[5]+1900).' '.$secTime[2].':'.$secTime[1].':'.$secTime[0].
#	"; interval=".$intervalTime[3].'.'.($intervalTime[4]+1).'.'.($intervalTime[5]+1900).' '.$intervalTime[2].':'.$intervalTime[1].':'.$intervalTime[0]."\n\n";

#print "return 1\n";
#exit;
   return 1;
}
1;