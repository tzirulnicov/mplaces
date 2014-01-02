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
my ($model,$desc);
open(FILE,'/www/gogasat/headcall.ru/cmsbuilder/libbot/1090.txt') or die $!;
@ar=<FILE>;
close(FILE);

#$sql='select h.ID from dbo_Hotel as h,dbo_Page as p1,dbo_Page as p2 where p1.ID=h.PAPA_ID and p2.ID=p1.PAPA_ID and p2.PAPA_ID=141 and p1.PAPA_CLASS="Page" and p2.PAPA_CLASS="Page"';
#$sql='select p_sub.ID from dbo_Page as p_sub,dbo_Hotel as h,dbo_Page as p1,dbo_Page as p2 where p_sub.PAPA_ID=h.ID and p1.ID=h.PAPA_ID and p2.ID=p1.PAPA_ID and p2.PAPA_ID=141 and p1.PAPA_CLASS="Page" and p2.PAPA_CLASS="Page" and p_sub.PAPA_CLASS="Hotel"';
$sql='select p_rooms.ID from dbo_Page as p_sub,dbo_Hotel as h,dbo_Page as p1,dbo_Page as p2,dbo_Page as p_rooms where p_sub.ID=p_rooms.PAPA_ID and p_sub.PAPA_ID=h.ID and p1.ID=h.PAPA_ID and p2.ID=p1.PAPA_ID and p2.PAPA_ID=141 and p_rooms.PAPA_CLASS="Page" and p_sub.PAPA_CLASS="Hotel" and p1.PAPA_CLASS="Page" and p2.PAPA_CLASS="Page";';
sql_query($sql);
while($row=$db_shandle->fetchrow_hashref){
   goto END if $#ar==-1;
   $dbs=$db_handle->prepare('UPDATE dbo_Page set link_text=? where ID=?');
   $dbs->execute(shift @ar,$row->{ID});
}
END:
open(FILE,'>/www/gogasat/headcall.ru/cmsbuilder/libbot/1090.txt') or die $!;
print FILE join('',@ar);
close(FILE);

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
