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
my ($buf,$buf_name,$table,$id);
open(FILE,'/www/gogasat/headcall.ru/cmsbuilder/libbot/content-itog.txt') or die $!;
while(<FILE>){
   if ($_=~/ID\d+,.*?[\r\n]/){
      if ($buf_name=~/ID(\d+)/){
	 print "Processing $buf_name...\n";
	 $id=$1;
	 if ($buf_name!~/(йНМРЮЙРШ|мНЛЕПЮ|цНЯРХМХЖЮ)/){
	    print "Unknown element: ".win2koi($buf_name)."\n";
	    exit;
	 }
	 $table=($buf_name=~/цНЯРХМХЖЮ/?'Hotel':'Page');
	 sql_query('SELECT ID from dbo_'.$table.' where ID='.$id);
	 if (!($row=$db_shandle->fetchrow_hashref)){
	    print "Cannot find '".win2koi($buf_name)."' in database\n";
	    exit;
	 }
	 $db_shandle=$db_handle->prepare('UPDATE dbo_'.$table.
		' set content=? where ID=?');
	 $db_shandle->execute($buf,$id);
      }
      $buf_name=$_;
      $buf='';
   } else {
      $buf.=$_;
   }
}
