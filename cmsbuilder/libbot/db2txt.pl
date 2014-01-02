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
use HTML::TreeBuilder;
use HTML::FormatText;
use HTML::Parse;

local $DEBUG=1;
sql_connect();
#$sql='SELECT ID,name,`content` from dbo_Hotel';
$sql='SELECT ID,name,content from dbo_Page where name="мНЛЕПЮ" or name="йНМРЮЙРШ"';
sql_query($sql);
open (FILE,">>/www/gogasat/headcall.ru/htdocs/contents.txt") or die $!;
while($row=$db_shandle->fetchrow_hashref){
   print FILE "ID".$row->{ID}.",".$row->{name}."\r\n".$row->{content}."\r\n\r\n";
}
close(FILE);
sql_close();
