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
sql_connect('Check Mobiles',1);
sql_query('SELECT ID,name from dbo_CatWareSimple');
while($row=$db_shandle->fetchrow_hashref){
   if ($row->{name}=~/[\r\n]/){
      print "Repairing name '".$row->{name}."'...\n";
      $row->{name}=~s/[\r\n]+/ /g;
      sql_query('update dbo_CatWareSimple set name="'.Str2Sql($row->{name}).
	'" where ID='.$row->{ID},'Check Mobiles',1);
   }
   if (!$row->{name}){
      print "Empty name with ID ".$row->{ID}."\n";
   }
}
sql_close(1);
sql_close();
exit;
sql_query('SELECT name,`desc` from dbo_CatWareSimple');
open (FILE,">/www/evoo/evoo.ru/htdocs/catalog.txt") or die $!;
while($row=$db_shandle->fetchrow_hashref){
   $html = HTML::TreeBuilder->new();
   $html->parse($row->{desc});

   $formatter = HTML::FormatText->new(leftmargin => 0, rightmargin => 50);
$row->{desc}=~s/<style>.*?<\/style>//gis;
$row->{desc}=~s/<[^>]+>//gs;
$row->{desc}=~s/[\r\n]+/\r\n/g;
$row->{desc}=~s/[\r\n](MicrosoftInternetExplorer4|false|Normal|0|X\-NONE|RU)[\r\n]//g;
   print FILE ("|".$row->{name}."|\r\n".
#utf2win($formatter->format(parse_html($row->{desc}))).
$row->{desc}.
"\r\n\r\n");
}
close(FILE);
sql_close();
