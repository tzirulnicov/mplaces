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
use cyrillic qw/win2koi koi2win utf2win/;
local $DEBUG=1;
sql_connect();
sql_query('SELECT ID,location from dbo_Hotel where location like "%.30.%"');
while($row=$db_shandle->fetchrow_hashref){
$row->{location}=~s/\.(30\.)/\,\1/;
   #@ar=split("",$row->{location});
   $dbs=$db_handle->prepare('UPDATE dbo_Hotel set location=? where ID=?');
   $dbs->execute($row->{location},$row->{ID});
}
sql_close();

