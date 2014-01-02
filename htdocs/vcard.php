<?php
//HTTP_USER_AGENT = Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; ru; rv:1.9.0.6) Gecko/2009011912 Firefox/3.0.6
$res=mysql_connect('localhost','goga','07080900');
mysql_select_db('bchotels',$res);
if (preg_match("/^\d+$/",$_SERVER['QUERY_STRING'])){
   $dbs=mysql_query('SELECT h.name,h.address,p3.contacts,p3.name as city,p1.name as pname from dbo_Hotel as h,dbo_Page as p1,
	dbo_Page as p2,dbo_Page as p3 where h.ID='.$_SERVER['QUERY_STRING'].'
	and p1.ID=h.PAPA_ID and p2.ID=p1.PAPA_ID and p3.ID=p2.PAPA_ID');
} else {
   $dbs=mysql_query('SELECT contacts from dbo_Page where contacts like "%-%"');
}
$row=mysql_fetch_object($dbs);
$dbs=mysql_query('SELECT icq,skype,email from dbo_modSite limit 1');
$o=mysql_fetch_object($dbs);
mysql_close();
header('Content-type: application/vcf');
header('Content-disposition: inline; filename=vcard'.$_SERVER['QUERY_STRING'].'.vcf');;
   $tel=split(',',$row->contacts);
   print 'BEGIN:VCARD
VERSION:3.0
N:'.str_replace('Мини','мини-отель',@$row->pname).';;;;
FN:'.(@$row->name?@$row->name:'Headcall.ru служба бронирования отелей').'
ORG:'.(@$row->name?@$row->name:'Headcall.ru служба бронирования отелей').';
EMAIL;type=INTERNET;type=WORK;type=pref:'.$o->email.'
TEL;type=WORK;type=pref:'.$tel[0].'
TEL;type=CELL:'.$tel[1].'
item1.ADR;type=WORK;type=pref:;;'.preg_replace("/,/","\\,",@$row->address).';'.@$row->city.';;;Россия
item1.X-ABADR:ru
item2.URL;type=pref:http\://www.'.$_SERVER['HTTP_HOST'].($_SERVER['QUERY_STRING']?'/hotel'.$_SERVER['QUERY_STRING']:'').'.html
item2.X-ABLabel:_$!<HomePage>!$_
item3.URL:'.$o->skype.'
item3.X-ABLabel:Skype
X-ICQ;type=WORK;type=pref:'.$o->icq.'
X-ABShowAs:COMPANY
X-ABUID:D9E71EEC-1D91-469C-8E65-9B251B3B33FB\:ABPerson
END:VCARD
';
?>
