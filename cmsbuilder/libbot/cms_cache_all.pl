#!/usr/bin/perl
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
   require "$Bin/../Config.pm";
}
use WWW::GET;
use Encode;
use MIME::Base64 qw(encode_base64 decode_base64);
exit if !-e "$Bin/../tmp/start_cache";
sql_connect();
@elms=qw/CatDir modCatalog/;
$wg=WWW::GET->new('evoo.ru'
#'v6177.vps.masterhost.ru'
	);
@result=();
$loop_num=0;
foreach my $elm(@elms){
 sql_query('SELECT * from dbo_'.$elm.' where my4<>""');
 while($row=$db_shandle->fetchrow_hashref){
   $loop_num=0;
   LOOP:
   $loop_num++;
   $url="/".lc($elm).$row->{ID}.".html?cache_init";
   print "Getting page $url, attempt number $loop_num\n";
   $res=0;
   $res=1 if $wg->get($url,NoEncoding=>1) && $wg->{net_http_content}=~/<html/;
   print ($res?':-)':':-(');
   print "\n";
   if ($res){
      $html=$wg->{net_http_content};
      $html=~s/(<div class\="catalog_mini_basket">).*?<\/div>(<\/div>)/\{\.show_basket\}\2/s;
      if ($html=~/<\/html>/i){
         open(FILE,'>'.$CMSBuilder::Config::path_tmp.'/cache/'.$row->{my4}) or die $!;
         print FILE $html;
         close(FILE);
	 push(@result,'http://'.$CMSBuilder::Config::server_main.'/'.$row->{my4});
      }
   }
#print $wg->{net_http_content};
#exit;
   goto LOOP if !$res and $loop_num<10;
 }
}
sql_close();
sendmail(
	to => 'tzirulnicov@mail.ru',
	from => 'tzirulnicov@mail.ru',
	subj => 'Кеширование завершено',
	ct => 'text/plain',
	text => 'Кеширование завершено. Обработаны следующие страницы:

'.($#results!=-1?join("\n",@results):'(нет таких)').'

Спасибо за пользование нашим сервисом.

С уважением, Михаил Ляличкин, компания Еву.Ру'
);

sub sendmail
{
        my %opts = (ct => 'text/plain', @_);

        map { $opts{$_} =~ s/([^\x14-\x19\x21-\x7F]+)/base64m($1)/ge; } qw(to from subj); #[^a-zA-Z\.\_\-\@ <>]+

        my $mess =
"To: $opts{to}
From: $opts{from}
Subject: $opts{subj}
Content-type: $opts{ct}; charset=utf-8

$opts{'text'}";

        #print $mess;

        no warnings 'utf8';
        my $mail;
        return open($mail, '|-', '/usr/sbin/sendmail -t') && binmode($mail) && print($mail $mess) && close($mail);
}

sub base64m
{
        my $str = '=?UTF-8?B?' . encode_base64(  $_[0] ) . '?=';
        $str =~ s/\s//g;

        return $str;
}


