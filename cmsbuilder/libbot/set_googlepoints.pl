#!/usr/bin/perl
# Из-за использования системного date() скрипт работает только в *nix !
BEGIN{
   push(@INC,'/home/tz/lib');
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
use WWW::COM::GOOGLE::MAPS;
$h=WWW::COM::GOOGLE::MAPS->new();
local $DEBUG=1;
sql_connect();
sql_query('SELECT h.ID,h.address,city.name from dbo_Hotel as h,dbo_Page as p1,
	dbo_Page as p2,dbo_Page as city where h.address<>"" 
	and h.location="" and p1.ID=h.PAPA_ID and p2.ID=p1.PAPA_ID and city.ID=p2.PAPA_ID');
while($row=$db_shandle->fetchrow_hashref){
   print "Address: ".win2koi($row->{name}.', '.$row->{address});
   $res=$h->get_topic(
        ADDRESS=>$row->{name}.', '.$row->{address}
   );
   print ", location: ".(!$res?'unknown':$h->{content_point})."\n";
   if ($res){
      $dbs=$db_handle->prepare('UPDATE dbo_Hotel set location=? 
	where ID=?');
      $dbs->execute($h->{content_point},$row->{ID});
   }
}
sql_close();

