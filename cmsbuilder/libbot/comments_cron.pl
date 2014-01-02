#!/usr/bin/perl
#Выгружает комментарии с headcall.ru, которых нет в текстовом файле, в файл.
#Смотрит,какие коммнтарии пользователь удалил из файла, и удаляет их из БД
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
use Time::Local;
my (@file_ar,$tm);
sql_connect();
sql_query('SELECT ATS,ID,`desc` from dbo_Comment');
open(FILE,'/www/gogasat/headcall.ru/htdocs/comments.txt') or die $!;
while(<FILE>){
   if ($_=~/^time\=(\d+)$/){
      $tm=$1;
   }
   elsif ($_=~/^ID\=\d+\, /){
      push(@file_ar,$_);
   } elsif ($#file_ar!=-1){
      $file_ar[$#file_ar].=$_;
   }
}
close(FILE);
my $check;
while($row=$db_shandle->fetchrow_hashref){
   $check=0;
   # Смотрим, есть ли данный комментарий в файле...
   foreach my $k(@file_ar){
#print "search |, $row->{desc}| in |$k|\n";
      if (index($k,", ".$row->{desc}."\n\n")!=-1){
         $check=1;
         last;
      }
   }
   # Нету? Смотрим дату...
   if (!$check){
      @ats=split(/[\- \:]/,$row->{ATS});
      if (timelocal($ats[5],$ats[4],$ats[3],$ats[2],--$ats[1],$ats[0])>$tm){
         print "Adding comment '$row->{desc}'\n";
         push(@file_ar,"ID=$row->{ID}, $row->{desc}\n\n");
      } else {
         print "Delete comment '$row->{desc}'\n";
	 $db_handle->do('DELETE from dbo_Comment where ID='.$row->{ID});
         $db_handle->do('DELETE from relations where ourl="Comment'.$row->{ID}.'"');
      }
   }
#   print FILE "ID=$row->{ID}, $row->{desc}\n\n";
}
open(FILE,'>/www/gogasat/headcall.ru/htdocs/comments.txt') or die $!;
sql_query('select max(ATS) from dbo_Comment');
$tm=0;
$tm=$row[0] if (@row=$db_shandle->fetchrow_array);
@ats=split(/[\- \:]/,$tm);
print FILE "time=".timelocal($ats[5],$ats[4],$ats[3],$ats[2],--$ats[1],$ats[0])."\n".join('',@file_ar);
close(FILE);
sql_close();
