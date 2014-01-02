#!/usr/bin/perl
BEGIN{
   push(@INC,'/www/evoo/evoo.ru/cmsbuilder/libbot/lib');
}
use WWW::GET;
use cyrillic qw/win2koi/;
$path='/www/gnutoff/gnutoff.ru/htdocs/macromates.com';
$url='http://macromates.com/';

$h=WWW::GET->new('66.102.9.104');
$temp_url=$url;

$h->get('translate_c?hl=ru&sl=en&tl=ru&u='.$temp_url.'&usg='.get_google_code(),NoEncoding=>1,
#AddHeaders=>'Cookie: __utma=179389752.690433884.1220787107.1220787107.1220787107.1; __utmc=179389752; __utmz=179389752.1220787107.1.1.utmccn=(referral)|utmcsr=66.102.9.104|utmcct=/translate_c|utmcmd=referral'."\n"
);
print $h->{'net_http_content'}."!\n";

sub get_google_code(){
   my $h=WWW::GET->new('translate.google.ru');
   $h->get('/translate?u=macromates.com&hl=ru&ie=UTF-8&sl=en&tl=ru',NoEncoding=>1);
   die "Error while get start link: ".$h->{errmsg} if $h->{'net_http_content'}!~/\&amp;usg\=([^"]+)/;
   print "code: $1\n";
   return $1;
}
