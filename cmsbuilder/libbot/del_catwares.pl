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
sql_connect('deltovar',1);
$save_img_path='/www/evoo/evoo.ru/htdocs/ee/wwfiles';
sql_query('SELECT cws.ID,cws.name from dbo_CatDir as cd,dbo_CatWareSimple as cws 
	where cws.PAPA_CLASS="CatDir" and cws.PAPA_ID=cd.ID and cd.name="'.
	koi2win('музей').'"');
while($row=$db_shandle->fetchrow_hashref){
   sql_query('delete from relations where ','deltovar',1);
   print "Tovar: ".win2koi($row->{'name'})."\n";
}
sql_close(1);
sql_close();
