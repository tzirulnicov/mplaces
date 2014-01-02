#!/usr/bin/perl
BEGIN{
   push(@INC,'/home/tz/lib');
}
use WWW::RU::HOTELLTD;
use cyrillic qw/win2koi/;
#use CRC16;
#print crc16('testddddddddddsda4cic45icu5453%$%#%#$@#$#$@%VGHGFHGFHFHGHGFFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGFGHFG  &&&$#^^%@^^@^@^@^@^%^$^$%^%$^$^%$GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGFGDGDGF%$%$%$%$%$%#%$#%   $% $#% $%$%#%$');
#exit;
$h=WWW::RU::HOTELLTD->new();
if (!$h->list_item(#Since_id=>239000,
#	SAVE_IMG_PATH=>'/www/gogasat/headcall.ru/cmsbuilder/tmp',
#	SAVE_IMG_URL=>'http://headcall.ru',
	GROUP=>'hotels1',
	LIMIT=>1,
	DEBUG=>1)){
   die $h->{'errmsg'};
}
while($h->get_topic(DEBUG=>1)){
#   next if $h->{content_body}!~/(с|С)енсор/;
#next if $h->{content_body}=~/несенсор/;
#   print "!!!!!!!!!!\n".$h->{'id'}.'. |'.win2koi($h->{'content_body'}.$h->{'content_body_add'})."|\n--------------\n";
#print "!".$h->{'content_image'}."!\n";
#exit;
}
print $h->{errmsg}."\n";
