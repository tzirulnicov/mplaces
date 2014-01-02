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
local ($price_min,$price_max);
local $last_hotel=0;
sql_connect();
sql_query('SELECT child.ID from dbo_Page as child,dbo_Page as papa
        where child.PAPA_CLASS="Page" and child.PAPA_ID=papa.ID and
        papa.name="мНЛЕПЮ" and child.price<300');
while($row=$db_shandle->fetchrow_hashref){
   $rand=int(2000+3000*rand);
   $rand=~s/\d{2}$/50/;
   print $row->{ID}."\n";
   $dbs=$db_handle->prepare('UPDATE dbo_Page set price=? where ID=?');
   $dbs->execute($rand,$row->{ID});
}
sql_query('SELECT h.ID, p2.name, p2.price from dbo_Hotel as h, dbo_Page as p, 
	dbo_Page as p2 where p.PAPA_ID=h.ID and 
	p.PAPA_CLASS="Hotel" and p.name="мНЛЕПЮ" and p2.PAPA_ID=p.ID and 
	p2.PAPA_CLASS="Page" and p2.name<>"дНОНКМХРЕКЭМЮЪ ЙПНБЮРЭ"');
while($row=$db_shandle->fetchrow_hashref){
   if ($row->{ID}!=$last_hotel){
      $db_handle->do('UPDATE dbo_Hotel set price_from='.
	($price_min==-1?0:$price_min).
	',price_to='.$price_max.' where ID='.$last_hotel);
      $price_min=-1;
      $price_max=0;
      $last_hotel=$row->{ID};
   }
   $price_min=$row->{price} if $price_min==-1;
   $price_min=$row->{price} if $row->{price}<$price_min;
   $price_max=$row->{price} if $row->{price}>$price_max;
   print $row->{ID}."|".win2koi($row->{name})."price=$row->{price},$price_min->$price_max\n";
}
if ($last_hotel){
      $db_handle->do('UPDATE dbo_Hotel set price_from='.
        ($price_min==-1?0:$price_min).
        ',price_to='.$price_max.' where ID='.$last_hotel);
}
sql_close();

