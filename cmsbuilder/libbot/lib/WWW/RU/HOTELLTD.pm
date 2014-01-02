# [фЕНБФЙЛБ] зПУФЙОЙГЩ
package WWW::RU::HOTELLTD;
use WWW::GET;
use POSIX;
use Data::Date;
use CRC16;
use cyrillic qw/koi2win win2koi/;
# Version 2.0, for evoo.ru
# Old version: 1.0, for bestphones.ru
sub new{
   my $pkg=shift;
   my $self={};
   my %arg=@_;
   $self->{sock}=WWW::GET->new('www.hotelltd.ru',%arg);
   undef if !$sock->{sock};
   bless $self,$pkg;
   $self;
}
sub list_item{
   my $self=shift;
   my %arg=@_;
   %{$self->{'config'}}=%arg;
   @{$self->{'links'}}=();
   %{$self->{'item_top100'}}=();
   $self->{'item_crc'}=0;
   %{$self->{'links_img'}}=();
   # $arg{'GROUP'} - only 'news' or 'phones' values are allowed
   # йДЕОФЙЖЙЛБГЙС ОПЧПУФЕК РП ID Й RESOURCE
   # йДЕОФЙЖЙЛБГЙС ФПЧБТПЧ РП CRC
   # дМС ЗТХРРЩ 'phones' РБТБНЕФТ LIMIT ОЕ РПДДЕТЦЙЧБЕФУС
   if ($arg{'GROUP'}!~/^hotels(1|2)$/){
      $self->{'errmsg'}="GROUP parameter not set or not 'hotels1' and not 'hotels2'";
      return 0;
   }
   $self->{'PREVIEW_IMG'}=1 if $arg{'PREVIEW_IMG'};
# SINCE_URL - "www.3dnews.ru/news/polzovateli_ne_dovolni_sensornoi_klaviaturoi_iphone-267413/", for example.
   my $url_base=$arg{'GROUP'}.'.php';
   my $url=$url_base;
   my $url_tmp;
   my $html_tmp;
   my $tmp;
   my @cat_urls;
   my @date;
   my $check=1;
   my $news_to_id=0;
   my $page_num=0;
   my $html;
#   $url='/news/'.Data::Date->getDate('DD_MM_YYYY').'.html' if $arg{'GROUP'} eq 'news';
#   $url.='all.html' if $arg{'GROUP'}=~/nokia|samsung|sonyericsson|motorola/;
   CAT_LOOP:
   $url=$url_base.'?p='.$page_num.'&l=50' if $page_num;
   print "url: $url\n" if $arg{'DEBUG'};
   if (!$self->{sock}->get($url,NoEncoding=>1)){
      $self->{'errmsg'}="Error in WWW::RU::HOTELLTD->list_item (get 'http://www.hotelltd.ru$url')";
      return 0;
   }
   $html=$self->{sock}->{'net_http_content'};
   while($html=~/$arg{GROUP}\.php\?i\=(\d+).*?>([^<]+)<\/a>[ \r\n]*<\/td><td>(.*?)<\/td><td>([^<]+)<\/td><td>[^<]+<\/td><td>([^<]+)<\/td><td class\="price">(\d+)/s){
#   while($html=~/$arg{GROUP}\.php\?i\=(\d+).*?>([^<]+)<\/a>[ \r\n]*<\/td><td><b>/){
      return 1 if (($arg{'LIMIT'} && $#{$self->{links}}+1>$arg{'LIMIT'}-1)) ||
	$arg{SINCE_ID}>$1;
      push(@{$self->{'links'}},["/$arg{GROUP}.php?i=$1",$2,$3,$4,$5,$6*32]);
      print "url=/$arg{GROUP}.php?i=$1, name=".win2koi($2).", type=".win2koi($3).
	", address=".win2koi($4).", metro=".win2koi($5).", price_from=".($6*32)."p\n";
      $html=~s/$arg{GROUP}\.php\?i\=($1)//g;
   }
   goto CAT_LOOP if index($html,'<a href="?p='.(++$page_num).'&l=50">')!=-1;
   return 1;
}
sub get_topic{
   my $self=shift;
   my %arg=@_,$url;
   foreach my $k(keys %{$self->{'config'}}){
      $arg{$k}=$self->{'config'}->{$k} if !exists $arg{$k};
   }
   $arg{'PREVIEW_IMG_PATH'}=$arg{'SAVE_IMG_PATH'} if !exists $arg{'PREVIEW_IMG_PATH'};
   $arg{'PREVIEW_IMG_URL'}=$arg{'SAVE_IMG_URL'} if !exists $arg{'PREVIEW_IMG_URL'};
   return 0 if $#{$self->{links}}==-1;
   my @url;
   ($url,$self->{'content_subj'},$self->{content_hotel_type},
	$self->{content_hotel_address},$self->{content_hotel_metro},
	$self->{content_hotel_price})=@{${$self->{links}}[0]};
#$url='/hotels1.php?i=98';
   shift @{$self->{links}};
   @{$self->{content_hotel_nomera}}=();
   @{$self->{'content_images'}}=();
   #$self->{'content_subj'}='';
   $self->{'content_body'}='';
   $self->{'content_body_add'}='';
   $url=~/(\d+)$/;
   $self->{'content_id'}=$1;
   #$self->{'content_resource'}='';
   $self->{'content_url'}='';
   $self->{'content_previmg'}='';
   return 0 if $url!~/\/\w+/;
#   $self->{'content_resource'}=($url=~/^\/news/?'news':'phones');
   %{$self->{'content_fields'}}=();
   #$self->{'content_url'}='www.mobiguru.ru'.$url;
   $self->{'content_date'}='';
   $self->{'content_price'}='';
   $url=~s/^[^\/]+//;
   local $html_tmp;
   local $check=0;
   local $is_news=($url=~/^\/news/?1:0);
   print "url: $url\n" if $arg{'DEBUG'};
   if (!$self->{sock}->get($url,NoEncoding=>1)){
      $self->{'errmsg'}="Error in WWW::RU::HOTELLTD->get_topic (get 'http://www.hotelltd.ru/$url')".$self->{sock}->{errmsg};
      return 0;
   }
   my $html=$self->{sock}->{'net_http_content'};
   #goto NEXT_POST if (index($html,'<h2 class="')==-1);# Ignoring parse errors
   if (index($html,'<IMG SRC="images/discountbook.gif"></a></p>')==-1 ||
	index($html,'<div class="hotel-menu bottom"><noindex>')==-1){
      $self->{'errmsg'}="Error in WWW::RU::HOTELLTD->get_topic ('incorrect html code')";
      return 0;
   }
   $html=WWW::GET->substr_idx($html,'<IMG SRC="images/discountbook.gif"></a></p>');
   $self->{content_body}=substr($html,0,index($html,'<div class="hotel-menu bottom"><noindex>'));
$self->{content_hotel_type}=~s/<img src\="\/i\/star\.gif" alt\="\*" \/><img src\="\/i\/star\.gif" alt\="\*" \/><img src\="\/i\/star\.gif" alt\="\*" \/><img src\="\/i\/star\.gif" alt\="\*" \/><img src\="\/i\/star\.gif" alt\="\*" \/>/z5/;
$self->{content_hotel_type}=~s/<img src\="\/i\/star\.gif" alt\="\*" \/><img src\="\/i\/star\.gif" alt\="\*" \/><img src\="\/i\/star\.gif" alt\="\*" \/><img src\="\/i\/star\.gif" alt\="\*" \/>/z4/;
$self->{content_hotel_type}=~s/<img src\="\/i\/star\.gif" alt\="\*" \/><img src\="\/i\/star\.gif" alt\="\*" \/><img src\="\/i\/star\.gif" alt\="\*" \/>/z3/;
$self->{content_hotel_type}='mini' if $self->{content_hotel_type}!~/z\d/;
print "Subject: ".win2koi($self->{content_subj})."\n";
print "Type: ".$self->{content_hotel_type}."\n";
print "Address: ".win2koi($self->{content_hotel_address})."\n";
print "Metro: ".win2koi($self->{content_hotel_metro})."\n";
print "Price: ".win2koi($self->{content_hotel_price})."\n";
print "Body: ".win2koi($self->{content_body})."\n";
#!!!
   my $city=($arg{GROUP} eq 'hotels1'?'spb':'msk');
#Process rooms
   $url=~s/hotels\d/hotel${city}_price/;
print "Get $url\n";
   if (!$self->{sock}->get($url,NoEncoding=>1)){
      $self->{'errmsg'}="Error in WWW::RU::HOTELLTD->get_topic (get 'http://www.hotelltd.ru/$url')".$self->{sock}->{errmsg};
      return 0;
   }
   $html=$self->{sock}->{'net_http_content'};
   if ($html!~/(<table class\="?room\-price"?>)/i){
      print "Error in WWW::RU::HOTELLTD->get_topic ('incorrect html code)\n";
#      $self->{'errmsg'}="Error in WWW::RU::HOTELLTD->get_topic ('incorrect html code')";
#      return 0;
   } else {
   $html=substr($html,index($html,$1));
   $html=substr($html,0,index($html,'</table>'));
   my ($tmp,$tmp2);
   while($html=~/<strong>([^<]+)<\/strong>/i){
      $tmp=$1;
      $tmp2=WWW::GET->str2regexp($1);
      $html=~s/<strong>($tmp2)<\/strong>//gi;
      push(@{$self->{content_hotel_nomera}},$tmp);
      print "Nomer \"".win2koi($tmp)."\"\n";
   }}
#Process images
   $url=~s/hotel${city}_price/hotel${city}_photo/;
   print "Get $url\n";
   if (!$self->{sock}->get($url,NoEncoding=>1)){
      $self->{'errmsg'}="Error in WWW::RU::HOTELLTD->get_topic (get 'http://www.hotelltd.ru/$url')".$self->{sock}->{errmsg};
      return 0;
   }
   $html=$self->{sock}->{'net_http_content'};
   while($html=~/pictures\/sm\/h_sm(\-\d+\-\d+\.jpg)/){
      $html=~s/($1)//g;
      $html_tmp="<img src=\"/pictures/h$1\">";
      $self->{sock}->eval_links(\$html_tmp,
        $arg{'SAVE_IMG_PATH'},
        $arg{'SAVE_IMG_URL'},$self->{'content_subj'});
      $html_tmp=~/\"(.*?)\"/;
      push(@{$self->{content_images}},substr($1,rindex($1,'/')+1));
      print "Photo \"".substr($1,rindex($1,'/')+1)."\"\n";
   }
return 1;
#print ">".win2koi($self->{'content_subj'})."<\n";
   # main image
   $html_tmp=substr($html,index($html,'<img src="http://web.mobiguru.ru/web/photo/'));
   $html_tmp=substr($html_tmp,0,index($html_tmp,'>')+1);
   $self->{sock}->eval_links(\$html_tmp,
        $arg{'SAVE_IMG_PATH'},
        $arg{'SAVE_IMG_URL'},$self->{'content_subj'});
   $html_tmp=~/\"(.*?)\"/;
   $self->{'content_image'}=substr($1,rindex($1,'/')+1);
#print "img: |$1|\n";
   # foreign images
   $html=~/document\.images\.photo\.src\= '(.*?)'\+img/;
   $tmp=$1;
   while($html=~/photo\('\d\.jpg'\)">\[\d\]<\/a>/){
      $html=~s/photo\('(\d\.jpg)'\)">\[\d\]<\/a>//;
      $html_tmp="<img src=\"".$tmp.$1."\">";
      $self->{sock}->eval_links(\$html_tmp,
        $arg{'SAVE_IMG_PATH'},
        $arg{'SAVE_IMG_URL'},$self->{'content_subj'});
      $html_tmp=~/\"(.*?)\"/;
      push(@{$self->{'content_images'}},substr($1,rindex($1,'/')+1));
   }
   for(my $k=0;$k<=$#{$self->{'content_images'}};$k++){
      #print "foreign img $k: |".$self->{'content_images'}->[$k]."|\n";
   }
   # price
   $self->{'content_price'}=$1 if $html=~/\_price">([\d ]+)/;
   $self->{'content_price'}=~s/ +//g;
   #print "Price: |".$self->{'content_price'}."|\n";
   # fields
   #%{$self->{'content_fields'}}=();
   # пВЭЙЕ ИБТБЛФЕТЙУФЙЛЙ
   #$self->{'content_fields'}->{'smartphone'}
   #$self->{'content_fields'}->{'gsm900'}
   #$self->{'content_fields'}->{'gsm1800'}
   #$self->{'content_fields'}->{'gsm1900'}
   #$self->{'content_fields'}->{'wcdma'}
   if (!$self->{'content_fields'}->{'gsm900'} &&
	!$self->{'content_fields'}->{'gsm1800'} &&
	!$self->{'content_fields'}->{'gsm1900'} &&
	!$self->{'content_fields'}->{'wcdma'}){
      $self->{'content_fields'}->{'gsm900'}=1;
      $self->{'content_fields'}->{'gsm1800'}=1;
      $self->{'content_fields'}->{'gsm1900'}=1;
   }
   #$self->{'content_fields'}->{'optstandart'}
   #$self->{'content_fields'}->{'os'}
   #$self->{'content_fields'}->{'platform'}
   #$self->{'content_fields'}->{'type'}
   #   $self->{'content_fields'}->{'opttype'}
   $self->{'content_fields'}->{'ant'}=1 if $html=~/Антенна\:<\/td><td valign\=top>Встроенная/;
   #$self->{'content_fields'}->{'optfeauture'}
   $self->{'content_fields'}->{'year'}=$1 if $html=~/>Год выпуска\:<\/td><td valign\=top>(\d+)/;
   # лБНЕТБ
   if ($html=~/>Цифровая камера\:<\/td><td valign\=top>([\d\.]+) Мп \(До (\d+x\d+)\), оптика ([^,]+),/){
      $self->{'content_fields'}->{'camera'}=$1;
      $self->{'content_fields'}->{'photorec'}=$2;
      $self->{'content_fields'}->{'cameraob'}=$3;
   } elsif ($html=~/>Цифровая камера\:<\/td><td valign\=top>([\d\.]+) ?Мп,( до)? (\d+x\d+),/){
      $self->{'content_fields'}->{'camera'}=$1;
      $self->{'content_fields'}->{'photorec'}=$3;
   } elsif ($html=~/>Цифровая камера:<\/td><td valign\=top>([\d\.]+)\-мегапиксельная камера \((\d+x\d+)\),/){
      $self->{'content_fields'}->{'camera'}=$1;
      $self->{'content_fields'}->{'photorec'}=$2;
   }
   $self->{'content_fields'}->{'camerazoom'}=$1 if $html=~/(\d+)\-кратный цифровой зум/;
   $self->{'content_fields'}->{'cameralight'}=1 if $html=~/ вспышка/;
   #$self->{'content_fields'}->{'videorec'}=$1 if $html=~//;
   $self->{'content_fields'}->{'secondvideo'}=1 if $html=~/доп\. CIF\-камера для видеотелефонии/;
   # нХМШФЙНЕДЙБ
   #$self->{'content_fields'}->{'stereo'}=1 if $html=~//;
   $self->{'content_fields'}->{'radio'}=1 if $html=~/>FM\-приемник\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'mp3'}=1 if $html=~/>MP3 плеер:</;
   #$self->{'content_fields'}->{'aplayback'}
   #$self->{'content_fields'}->{'optaudio'}
   $self->{'content_fields'}->{'voicerec'}=1 if $html=~/>Диктофон\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'java'}=1 if $html=~/>Java приложения\:</;
   $self->{'content_fields'}->{'games'}='Да' if $html=~/>Игры\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'games'}=$1 if (!$self->{'content_fields'}->{'games'} && 
	$html=~/>Игры\:<\/td><td valign\=top>([^>]+)</);
   # рБНСФШ
   if ($html=~/>Память\:<\/td><td valign\=top>(\d+) (Мб|Гб)/i){
      $self->{'content_fields'}->{'memory'}=$1;
      $self->{'content_fields'}->{'memory'}*=1024 if $2 eq 'Гб';
   }
   $self->{'content_fields'}->{'cards'}='microSD' if $html=~/micro ?SD/;
   $self->{'content_fields'}->{'cards'}='MMC' if $html=~/MMC/;
   $self->{'content_fields'}->{'cards'}='Memory Stick' if $html=~/Memory Stick/;
   # ьЛТБО
   if ($html=~/>Тип дисплея\:<\/td><td valign\=top>(\w+), \d+ (млн\. )?цветов, (\d+x\d+)/){
      $self->{'content_fields'}->{'screentype'}=$1;
      $self->{'content_fields'}->{'screensize'}=$3;
   }
   #$self->{'content_fields'}->{'screenrus'}=1 if $html=~/т_у_у_тЈу_тЈттњу_тЈу_/;
   $self->{'content_fields'}->{'screenlight'}=1 if $html=~/>Подсветка\:<\/td><td valign\=top>\+<\/td>/;
   # йОФЕТЖЕКУЩ
   #$self->{'content_fields'}->{'irda'}=1 if $html=~/IRDA/;
   $self->{'content_fields'}->{'usb'}=1 if $html=~/microUSB interface/;
   $self->{'content_fields'}->{'wifi'}=1 if $html=~/WiFi \- /;
   $self->{'content_fields'}->{'blue2'}=1 if $html=~/>Bluetooth\:<\/td><td valign\=top>2\./;
   $self->{'content_fields'}->{'blue1'}=1 if ($html=~/>Bluetooth\:<\/td><td valign\=top>/ &&
	!$self->{'content_fields'}->{'blue2'});
   #$self->{'content_fields'}->{'optinterface'}
   $self->{'content_fields'}->{'wap'}=1 if $html=~/>WAP\:<\/td><td valign\=top>/;
   $self->{'content_fields'}->{'gprs'}=1 if $html=~/>GPRS\:<\/td><td valign\=top>/;
   $self->{'content_fields'}->{'edge'}=1 if $html=~/EDGE Class /;
   #$self->{'content_fields'}->{'optinternet'}
   $self->{'content_fields'}->{'modem'}=1 if $html=~/>Встроенный модем\:<\/td><td valign\=top>\+</;
   #$self->{'content_fields'}->{'gps'}=1 if $html=~/GPS/;у_у_т_т_тЈт_ т т_т/;
   $self->{'content_fields'}->{'pcconnect'}=1 if ($html=~/>Синхронизация с ПК\:<\/td><td valign\=top>\+</ ||
	$html=~/>Связь с ПК\:<\/td><td valign\=top>/);
   # ъЧПОЛЙ;
   $self->{'content_fields'}->{'melodytype'}='Полифония' if $html=~/>Полифония\:<\/td><td valign\=top>\+<\/td>/;
   $self->{'content_fields'}->{'melodytype'}='Полифония '.$1 if $html=~/>Полифония\:<\/td><td valign\=top>(\d[^<]+)/;
   $self->{'content_fields'}->{'vibrocall'}=1 if $html=~/>Виброзвонок\:<\/td><td valign\=top>\+</;
   #$self->{'content_fields'}->{'melodyedit'}=1 if $html=~//;
   $self->{'content_fields'}->{'melodyspeaker'}=1 if $html=~/>Громкоговорящая связь\:<\/td><td valign\=top>\+</;
   #$self->{'content_fields'}->{'melodymute'}=1
   $self->{'content_fields'}->{'coding'}=1 if $html=~/>Кодирование речи\:<\/td><td valign\=top>\+</;
   # хРТБЧМЕОЙЕ ЪЧПОЛБНЙ
   $self->{'content_fields'}->{'uder'}=1 if $html=~/>Удержание звонка\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'conf'}=1 if $html=~/>Конференц-связь\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'pere'}=1 if $html=~/>Переадресация звонка\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'opred'}=1 if $html=~/>Определение номера\:<\/td><td valign\=top>\+</;
   # лМБЧЙБФХТБ
   $self->{'content_fields'}->{'joy'}=1 if $html=~/>Джойстик\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'keylight'}=1 if $html=~/>Подсветка\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'keyblock'}=1 if $html=~/>Блокировка\:<\/td><td valign\=top>\+</;
   #$self->{'content_fields'}->{'keysound'}=1 if $html=~//;
   $self->{'content_fields'}->{'t9'}=1 if $html=~/>T9\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'keyrus'}=1 if $html=~/>Ввод русскими буквами\:<\/td><td valign\=top>\+</;
   # пТЗБОБКЪЕТ
   $self->{'content_fields'}->{'orgclock'}=1 if $html=~/>Часы\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'orgcalc'}=1 if $html=~/>Калькулятор\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'orgcal'}=1 if $html=~/>Календарь\:<\/td><td valign\=top>\+</;
   #$self->{'content_fields'}->{'orgoffice'}=1 if $html=~//;
   #$self->{'content_fields'}->{'realplayer'}=1 if $html=~//;
   #$self->{'content_fields'}->{'flashplayer'}=1 if $html=~//;
   #$self->{'content_fields'}->{'lifeblog'}=1 if $html=~//;
   #$self->{'content_fields'}->{'orgchat'}=1 if $html=~//;
   #$self->{'content_fields'}->{'orgkeys'}=1 if $html=~//;
   $self->{'content_fields'}->{'orgsec'}=1 if $html=~/>Секундомер\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'orgconv'}=1 if $html=~/>Конвертер валют\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'bud'}=1 if $html=~/>Будильник\:<\/td><td valign\=top>\+</;
   # уППВЭЕОЙС
   $self->{'content_fields'}->{'sms'}=1 if $html=~/>SMS\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'mms'}=1 if $html=~/>MMS\:<\/td><td valign\=top>\+</;
   $self->{'content_fields'}->{'email'}=1 if $html=~/>E\-Mail\:<\/td><td valign\=top>/;
   # рЙФБОЙЕ
   $self->{'content_fields'}->{'powertype'}='Li-Ion' if $html=~/>Li\-Ion /;
   $self->{'content_fields'}->{'powersize'}=$1 if $html=~/ (\d+) мАч ?</;
   $self->{'content_fields'}->{'powertime'}=$1 if $html=~/>Время разговора\:<\/td><td valign\=top>До ([\d\.]+)/;
   $self->{'content_fields'}->{'powerwait'}=$1 if $html=~/>Время ожидания\:<\/td><td valign\=top>До ([\d\.]+)/;
   # тБЪНЕТЩ Й ЧЕУ
   $self->{'content_fields'}->{'dims'}=$1 if $html=~/>Размеры\:<\/td><td valign\=top>([\d\.x]+)/;
   $self->{'content_fields'}->{'weight'}=$1 if $html=~/>Вес\:<\/td><td valign\=top>(\d+)/;
#!!!
=head
   foreach my $k(keys %p_ar){
      $tmp=koi2win($k);
      next if $html!~/\>$tmp\:\<\/td\>\<td valign\=top\>(.*?)\<\/td\>/;
      $tmp=$1;
      if ($p_ar{$k}==8){
	 if ($tmp=~/(\d+)x(\d+) пикселей/){
	    $self->{'content_fields'}->{10}=$2.' px';

	    $self->{'content_fields'}->{9}=$1.' px';
	 }
	 $self->{'content_fields'}->{11}=$1 if ($tmp=~/(\d+) цветов/);
         $tmp=~s/\,.+//;
      } elsif ($p_ar{$k}==5){
	 $tmp=~s/ //g;
	 $tmp.=' мм';
      } elsif ($p_ar{$k}=~/^3|4$/){
	 $tmp=~s/асов//;
      } elsif ($p_ar{$k}==6){
	 $tmp=~s/\.$//;
      }
      $self->{'content_fields'}->{$p_ar{$k}}=$tmp;
   }
=cut
   $html_tmp=substr($html,index($html,koi2win('>фЙР ДЙУРМЕС:<')));
   $html_tmp=substr($html_tmp,0,index($html_tmp,'</table>'));
   @{$self->{'content_funcs'}}=$html_tmp=~/top\>(.*?)\:\<\/td\>\<td valign\=top\>(.*?)\</g;
#print "Funcs: ".win2koi(join(',',@{$self->{'content_funcs'}}))."\n";
#exit;
#WWW::GET->debug_write($html);
  # print "params: ".join(',',keys (%{$self->{'content_fields'}}))."\n";
   foreach my $k(@fields_list){
      next if !exists $self->{'content_fields'}->{$k};
      #print "param '$k'=|".win2koi($self->{'content_fields'}->{$k})."|\n";
   }
   #foreach my $k(keys %{$self->{'content_fields'}}){
   #   print win2koi("$k=".$self->{'content_fields'}->{$k}."\n");
   #}
   if (index($html,'<p align=justify>')!=-1){
return 1 if (index($html,'<img src="http://web.mobiguru.ru/web/gadget_week.gif"')!=-1 && 
	index($html,'<img src="http://web.mobiguru.ru/web/gadget_week.gif"')<index($html,'<p align=justify>'));
      $self->{'content_body'}=substr($html,index($html,'<p align=justify>')+17);
      $self->{'content_body'}=substr($self->{'content_body'},0,
	index($self->{'content_body'},'</p>'));
   }
   return 1;
}
sub is_elm_in_str{
   # пРТЕДЕМСЕФ, УПДЕТЦБФУС МЙ ЧУЕ ЬМЕНЕОФЩ НБУУЙЧБ $ar Ч УФТПЛЕ $str
   my $str=lc(shift);
   my @ar=@_;
   for (my $a=0;$a<=$#ar;$a++){
      return 0 if index($str,lc($ar[$a]))==-1;
   }
   return 1;
}
sub get_page_id{
   # пФДЈФ ЙДЕОФЙЖЙЛБГЙПООЩК ОПНЕТ ОПЧПУФЙ РП URL
   shift;
   return 0 if shift!~/\/cgi\-bin\/guide\.cgi\?table\_code\=\d+\&action\=show\&id\=(\d+)/;
   return $1;
}
1;
