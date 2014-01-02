package WWW::RU::PILOTAGE_RC;
use WWW::GET;
use POSIX;
use Data::Date;
use CRC16;
use cyrillic qw/koi2win win2koi utf2win/;
sub new{
   my $pkg=shift;
   my $self={};
   my %arg=@_;
   $self->{sock}=WWW::GET->new('pilotage-rc.ru',%arg);
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
   # ������������� �������� �� ID � RESOURCE
   # ������������� ������� �� CRC
   # ��� ������ 'phones' �������� LIMIT �� ��������������
#   if ($arg{'GROUP'}!~/^nokia|samsung|motorola|sony\-ericsson|lg|philips|fly|communicators|bluetooth$/){
#      $self->{'errmsg'}="GROUP parameter not set or not nokia/samsung/motorola/sony-ericsson/lg/philips/fly/communicators/bluetooth";
#      return 0;
#   }
   $self->{'PREVIEW_IMG'}=1 if $arg{'PREVIEW_IMG'};
# SINCE_URL - "www.3dnews.ru/news/polzovateli_ne_dovolni_sensornoi_klaviaturoi_iphone-267413/", for example.
   my $url_base='catalogue/';
   #$url_base='catalog/mobile/'.$arg{'GROUP'}.'/' if $arg{'GROUP'} eq 'communicators' or $arg{'GROUP'} eq 'bluetooth';
   my $url=$url_base;
   my $url_tmp;
   my $html_tmp;
   my $tmp;
   my @cat_urls;
   my @date;
   my $check=0;
   my $news_to_id=0;
#   my @urls=qw/10_10 10_15 10_20 10_30 10_45 15_10 15_15 15_20 15_25 15_45 20_10 20_20 20_30 25_10 25_20 25_30 30_10/;
my @urls=qw/30_10/;
   my ($cur_page,$url_add);
   for $url(@urls){
      $cur_page=1;
   #$url=shift @cat_urls if $#cat_urls!=-1;
   $url=~/(\d+)_/;
   $url=$url_base.$1.'_/'.$url;
   $url_add='';
   PAGE_NEXT:
   print "url: $url/$url_add\n" if $arg{'DEBUG'};
   if (!$self->{sock}->get($url.'/'.$url_add,NoEncoding=>1)){
      #goto NEWS_NEXT if ($arg{'GROUP'} eq 'news' && $self->{sock}->{'net_http_code'}==404);
      $self->{'errmsg'}="Error in WWW::RU::PILOTAGE_RC->list_item (get 'http://www.pilotage-rc.ru$url')";
      return 0;
   }
   my $html=$self->{sock}->{'net_http_content'};
   if ($html!~/"\/$url\/RC\d+\/"/){
      $self->{'errmsg'}="Error in WWW::RU::PILOTAGE_RC->list_item (incorrect html code)";
      return 0;
   }
   while ($html=~/\/$url\/RC\d+\//){
      $html=~s/(\/$url\/RC\d+\/)//;
      return 1 if (($arg{'LIMIT'} && $#{$self->{links}}+1>$arg{'LIMIT'}-1));
      # get links on topics
      $tmp=$1;
      #$tmp=substr($tmp,0,index($tmp,"'")) if index($tmp,"'")!=-1;
      next if index(join(',',@{$self->{'links'}}),$tmp)!=-1;
      print "!$tmp!\n";
      push(@{$self->{'links'}},$tmp);
   }
   #$self->{links_head}->{$tmp}=$1 if $html=~/<div id\="ContentCenter">[\r\n ]+<h1>([^<]+)<\/h1>/;
   $cur_page++;
   if ($html=~/(\?page\=$cur_page\&count\=\d+)">/){
      $url_add=$1;
      goto PAGE_NEXT;
   }
   }
   # Calculate CRC
   foreach my $k(@{$self->{'links'}}){
      $self->{'item_crc'}.=$k;
   }
   $self->{'item_crc'}=crc16($self->{'item_crc'});
#print $self->{'item_crc'}.'|'.$arg{'SINCE_CRC'}."\n";
   @{$self->{'links'}}=() if ($arg{'SINCE_CRC'} && $self->{'item_crc'}==$arg{'SINCE_CRC'});
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
   my $url=${$self->{links}}[0];
#$url='/catalogue/15_/15_25/RC5694/';
   shift @{$self->{links}};
   $self->{'content_image'}='';
   @{$self->{'content_images'}}=();
   $self->{'content_subj'}='';
   $self->{'content_body'}='';
   $url=~/RC(\d+)\/$/;
   $self->{'content_id'}=$1;
   #$self->{'content_resource'}='';
   $self->{'content_url'}=$url;
   $self->{'content_previmg'}='';
   return 0 if $url!~/\/RC\d+\//;
   $self->{'content_resource'}='phones';
   %{$self->{'content_fields'}}=();
   #$self->{'content_url'}='www.euroset.ru'.$url;
   $self->{'content_date'}='';
   @{$self->{'content_nav'}}=();
   $url=~s/^[^\/]+//;
   local $html_tmp;
   local $check=0;
   local @fields_list=qw/smartphone gsm900 gsm1800 gsm1900 wcdma optstandart 
	os platform type opttype ant optfeauture camera photorec cameraob
	camerazoom cameralight videorec secondvideo stereo radio mp3 aplayback
	optaudio voicerec java games memory cards screentype screensize 
	screenrus irda usb wifi blue1 blue2 optinterface wap gprs edge modem
	gps pcconnect melodytype vibrocall melodyedit melodyspeaker orgclock
	orgcalc orgcal orgoffice realplayer flashplayer lifeblog orgchat
	orgkeys sms mms email powertype powersize powerwait powertime dims 
	weight sostav artikul/;
   my ($nav,$img,$img_small);
   my %p_ar=('�������� �����'=>1,'�����������'=>2,'���'=>6,
	'�������'=>5,'����� ���������'=>4,
	'����� ��������'=>3,'�������'=>14,'��� �������'=>15,
	'��� �������'=>8);
   NEXT_LOOP:
   print "url: $url\n" if $arg{'DEBUG'};
   if (!$self->{sock}->get($url,NoEncoding=>1)){
      $self->{'errmsg'}="Error in WWW::RU::PILOTAGE_RC->get_topic (get 'http://www.euroset.ru/$url')".$self->{sock}->{errmsg};
      return 0;
   }
   my $html=utf2win($self->{sock}->{'net_http_content'});
#   WWW::GET->debug_write($html);
   #goto NEXT_POST if (index($html,'<h2 class="')==-1);# Ignoring parse errors
   if (index($html,'<div id="ContentCenter">')==-1 &&
	index($html,'<td class="Price"><span class="Gray">')!=-1 &&
	index($html,'<div class="Record">')!=-1){
      $self->{'errmsg'}="Error in WWW::RU:PILOTAGE_RC->get_topic ('incorrect html code')";
      return 0;
   }
#   if ($self->{config}->{'PREVIEW_IMG'} && $self->{'links_img'}->{$url}){
#      $self->{'content_previmg'}=($self->{sock}->eval_links(\$self->{'links_img'}->{$url},
#	$arg{'PREVIEW_IMG_PATH'},$arg{'PREVIEW_IMG_URL'}))[0];
#   }
   $nav=$1 if ($html=~/<title>Pilotage\-RC\.ru \/ (.*?)<\/title>/);
   $img=$1 if $html=~/href\="($url.*?\.jpg)"/;
   $img_small=$1 if $html=~/src\="($url.*?\.jpg)"/;
   print "IMG big: $img, IMG small: $img_small\n";
   $html=substr($html,index($html,'<div id="ContentCenter">'));
   $html=substr($html,index($html,'<h1>')+4);
   $self->{'content_subj'}=substr($html,0,index($html,'</h1>'));
   print "Subject: |".win2koi($self->{'content_subj'})."|\n";
   $tmp=WWW::GET->str2regexp($self->{content_subj});
   $nav=~s/ \/ $tmp//;
   @{$self->{'content_nav'}}=split(/ \/ /,$nav);
   if ($self->{content_nav}->[$#{$self->{content_nav}}] eq koi2win('������� �������')){
      pop @{$self->{content_nav}};
      $self->{content_nav}->[$#{$self->{content_nav}}].=koi2win(' / ������� �������');
   }
   print "Navigation: |".win2koi(join(',',@{$self->{'content_nav'}}))."|\n";
   $html=substr($html,index($html,koi2win('���� � ��������-��������:'))) if index($html,'���� � ��������-��������:')!=-1;
   if (index($html,'<td class="Price"><span class="Gray">')!=-1){
      $html=substr($html,index($html,'<td class="Price"><span class="Gray">'));
   } else { 
      $html=substr($html,index($html,'<td class="Price">'));
   } 
   die "Cannot get price" if $html!~/(\d+ ?\d+)/;
   $self->{'content_price'}=$1;
   $self->{'content_price'}=~s/ //;
   print "Price: |".$self->{'content_price'}."|\n";
   $html=substr($html,index($html,'<div class="Record">')+20);
   $self->{'content_body'}=substr($html,0,index($html,'<hr/>'));
   $self->{'content_body'}=substr($self->{'content_body'},index($self->{'content_body'},'</p>')+4);
   $self->{'content_body'}=~s/<hr>//;
#print "Body: ".substr(win2koi($self->{'content_body'}),0)."\n";
   $html=substr($html,index($html,'</h4>')+5);
   @tmp=split(/<\/b><br>/,substr($html,0,index($html,'<hr/>')));
   for my $line(@tmp){
      $line=~s/<p>//;
      $line=~s/[\r\n]+//;
      $line=~s/^ +//;
      next if $line!~/([^\:]+)\: <b>(.+)/;
      print "Param ".win2koi($1."=!".$2)."!\n";
      $self->{content_fields}->{$1}=$2;
   }
   my $html_tmp='<img src="'.$img.'">';
   $self->{sock}->eval_links(\$html_tmp,
        $arg{'SAVE_IMG_PATH'},
        $arg{'SAVE_IMG_URL'},$self->{'content_subj'});
   if ($html_tmp=~/\"(.*?)\"/){
      $self->{'content_image'}=substr($1,rindex($1,'/')+1);
   }
   my $html_tmp='<img src="'.$img_small.'">';
   $self->{sock}->eval_links(\$html_tmp,
        $arg{'SAVE_IMG_PATH'},
        $arg{'SAVE_IMG_URL'},$self->{'content_subj'}.' small');
   if ($html_tmp=~/\"(.*?)\"/){
      $self->{'content_previmg'}=substr($1,rindex($1,'/')+1);
   }
return 1;
   # Images
   $tmp=substr($html,0,index($html,'<div class="description">'));
   while($tmp=~s/<img src="(\/f\/products\/\d+\/\d+\/[^\.]+\.jpg)"//){
      if (!$self->{'content_image'}){
	 $self->{'content_image'}=$1;
	 #print "Main img: |$1|\n";
	 next;
      }
      push(@{$self->{'content_images'}},$1);
      $self->{'content_images'}->[$#{$self->{'content_images'}}]=~s/_resized45//;
   }
   for(my $k=0;$k<=$#{$self->{'content_images'}};$k++){
      #print "foreign img $k: |".$self->{'content_images'}->[$k]."|\n";
   }
   #
   $self->{'content_body'}=substr($html,index($html,'<div class="description">'));
   $self->{'content_body'}=utf2win(substr($self->{'content_body'},0,index($self->{'content_body'},'</div>')));
   $self->{'content_body'}=~s/<[^>]+>//g;
   #print "Body: |".win2koi($self->{'content_body'})."|\n";
   #
#   $html=substr($html,index($html,'<h2>Цена:</h2>'));
#   $self->{'content_price'}=$1 if ($html=~/<span class="price_number">(.*?)<\/span>/);
#   $self->{'content_price'}=~s/\&nbsp;//;
   #print "Price: |".$self->{'content_price'}."|\n";
   # Params
   $html=~s/[\r\n]+/ /g;
#print "!!!!!!\n" if $html=~/Артикул: \d+/;
#  $self->{'type'}='smart';
   $self->{'content_fields'}->{'artikul'}=$1 if $html=~/Артикул: (\d+)/;
   ### ����� ������������� ###
   #$self->{'content_fields'}->{'smartphone'};
   $self->{'content_fields'}->{'gsm900'}=1 if $html=~/GSM[ \d\/]*900/;
   $self->{'content_fields'}->{'gsm1800'}=1 if $html=~/GSM[ \d\/]*1800/;
   $self->{'content_fields'}->{'gsm1900'}=1 if $html=~/GSM[ \d\/]*1900/;
   $self->{'content_fields'}->{'wcdma'}=1 if $html=~/WCDMA/;
   #$self->{'content_fields'}->{'optstandart'}
   $self->{'content_fields'}->{'os'}=utf2win($1) if $html=~/Операционная система: ([^<]+)/;
   $self->{'content_fields'}->{'platform'}=utf2win($1) if $html=~/Платформа: ([^<]+)/;
   $self->{'content_fields'}->{'type'}=$1 if $html=~/Тип корпуса: ([^<]+)/;
   if ($self->{'content_fields'}->{'type'}=~/(слайдер|раскладушка|моноблок)/){
      $self->{'content_fields'}->{'type'}='rasklad' if $self->{'content_fields'}->{'type'} eq 'раскладушка';
      $self->{'content_fields'}->{'type'}='mono' if $self->{'content_fields'}->{'type'} eq 'моноблок';
      $self->{'content_fields'}->{'type'}='slider' if $self->{'content_fields'}->{'type'} eq 'слайдер';
   } else {
      $self->{'content_fields'}->{'opttype'}=utf2win($self->{'content_fields'}->{'type'});
      undef $self->{'content_fields'}->{'type'};
   }
   #$self->{'content_fields'}->{'opttype'}
   $self->{'content_fields'}->{'ant'}='1' if $html=~/Антенна: встроенная/;
   #$self->{'content_fields'}->{'optfeauture'}
   ### ������ ###
   $self->{'content_fields'}->{'camera'}=$1 if ($html=~/Матрица, Мпикс: ([\d\.]+)/ || $html=~/Фотокамера: (\d+)/);
   $self->{'content_fields'}->{'photorec'}=$1 if $html=~/JPEG до (\d+x\d+)/;
   if ($html=~/Фотокамера: (\d+x\d+) \(([\d\.]+) /){
      $self->{'content_fields'}->{'camera'}=$2;
      $self->{'content_fields'}->{'photorec'}=$1;
   }
   $self->{'content_fields'}->{'cameraob'}=$1 if $html=~/бъектив ([^,]+)/;
   $self->{'content_fields'}->{'camerazoom'}=$1 if ($html=~/Цифровой Zoom (\d+)/ ||
	$html=~/Цифровой зум, X: (\d+)/);
   $self->{'content_fields'}->{'cameralight'}=1 if ($html=~/встроенная вспышк�/ ||
	$html=~/встроенная вспышка/);
   $self->{'content_fields'}->{'videorec'}=$1 if $html=~/Запись видео: ([^<]+)/;
   $self->{'content_fields'}->{'videorec'}='��' if $html=~/Запись видео/;
   $self->{'content_fields'}->{'videorec'}=utf2win($1) if $html=~/Запись видео: ([^<]+)/;
   $self->{'content_fields'}->{'secondvideo'}=1 if $html=~/Вторая камера для видеотелефонии/;
   ### ����������� ###
   $self->{'content_fields'}->{'stereo'}=1 if $html=~/стереодинамики/;
   $self->{'content_fields'}->{'radio'}=1 if $html=~/FM\-радиоприемник/;
   $self->{'content_fields'}->{'mp3'}=1 if ($html=~/аудио-плеер/ ||
	$html=~/MP3\-проигрыватель/);
   #$self->{'content_fields'}->{'aplayback'}
   #$self->{'content_fields'}->{'optaudio'}
   $self->{'content_fields'}->{'voicerec'}=1 if $html=~/Диктофон/;
   $self->{'content_fields'}->{'java'}=1 if $html=~/JAVA/;
   $self->{'content_fields'}->{'games'}=1 if $html=~/Игры/;
   ### ������ ###
   if ($html=~/Встроенная память, Мб: (\d+) (Mb|Gb|Мб|Гб)/i){
      $self->{'content_fields'}->{'memory'}=$1;
      $self->{'content_fields'}->{'memory'}*=1024 if ($2 eq 'Gb' or $2 eq 'Гб');
   }
   if (!$self->{'content_fields'}->{'memory'} &&
	$html=~/Встроенная память, Мб: (\d+)/){
      $self->{'content_fields'}->{'memory'}=$1;
   }
   $self->{'content_fields'}->{'cards'}='microSD' if $html=~/microSD/;
   $self->{'content_fields'}->{'cards'}='MMC' if $html=~/MMC/;
   ### ����� ###
   $self->{'content_fields'}->{'screentype'}='TFT';
   $self->{'content_fields'}->{'screensize'}=$1 if ($html=~/Размер экрана, пикс: (\d+x\d+)/i ||
	$html=~/\d, (\d+x\d+) пикс\./ || $html=~/Размер экрана, пикс: (\d+ *х *\d+)/);
   $self->{'content_fields'}->{'screensize'}=~s/ *х */x/;
   $self->{'content_fields'}->{'screenrus'}=1 if $html=~/Русификация/;
   ### ���������� ###
   $self->{'content_fields'}->{'irda'}=1 if $html=~/IRDA/;
   $self->{'content_fields'}->{'usb'}=1 if $html=~/USB/;
   $self->{'content_fields'}->{'wifi'}=1 if $html=~/Wi\-Fi/;
   $self->{'content_fields'}->{'blue2'}=1 if $html=~/Bluetooth 2\.0/i;
   $self->{'content_fields'}->{'blue1'}=1 if ($html=~/Bluetooth/ &&
	!$self->{'content_fields'}->{'blue2'});
   #$self->{'content_fields'}->{'optinterface'}
   $self->{'content_fields'}->{'wap'}=1 if $html=~/WAP 2\.0/;
   $self->{'content_fields'}->{'gprs'}=1 if $html=~/GPRS/;
   $self->{'content_fields'}->{'edge'}=1 if $html=~/EDGE/;
   $self->{'content_fields'}->{'modem'}=1 if $html=~/Модем/;
   $self->{'content_fields'}->{'gps'}=1 if $html=~/GPS/;
   $self->{'content_fields'}->{'pcconnect'}=1 if $html=~/Подключение к П�/;
   ### ������ ###
   $self->{'content_fields'}->{'melodytype'}=utf2win($1) if $html=~/Тип мелодий: ([^<]+)/;
   $self->{'content_fields'}->{'vibrocall'}=1 if $html=~/Виброзвонок/;
   $self->{'content_fields'}->{'melodyedit'}=1 if $html=~/Редактор мелодий/;
   $self->{'content_fields'}->{'melodyspeaker'}=1 if $html=~/Динамик для громкого звука/;
   ### ���������� ###
   $self->{'content_fields'}->{'orgclock'}=1 if $html=~/часы/;
   $self->{'content_fields'}->{'orgcalc'}=1 if $html=~/калькулятор/;
   $self->{'content_fields'}->{'orgcal'}=1 if $html=~/календарь/;
   $self->{'content_fields'}->{'orgoffice'}=1 if $html=~/офис/;
   $self->{'content_fields'}->{'realplayer'}=1 if $html=~/realplayer/;
   $self->{'content_fields'}->{'flashplayer'}=1 if $html=~/flash/;
   $self->{'content_fields'}->{'lifeblog'}=1 if $html=~/lifeblog/;
   $self->{'content_fields'}->{'orgchat'}=1 if $html=~/чат/;
   $self->{'content_fields'}->{'orgkeys'}=1 if $html=~/ключи/;
   ### ��������� ###
   $self->{'content_fields'}->{'sms'}=1 if $html=~/SMS/;
   $self->{'content_fields'}->{'mms'}=1 if $html=~/MMS/;
   $self->{'content_fields'}->{'email'}=1 if $html=~/SMTP/;
   ### ������� ###
   $self->{'content_fields'}->{'powertype'}='Li-Ion' if $html=~/Li-Ion/i;
   $self->{'content_fields'}->{'powersize'}=$1 if $html=~/Емкость аккумулятора, мАч: (\d+)/i;
   $self->{'content_fields'}->{'powerwait'}=$1 if $html=~/Время ожидания до, ч: (\d+:\d+)/;
   $self->{'content_fields'}->{'powertime'}=$1 if $html=~/Время разговора до, ч: (\d+:\d+)/;
   ### ������� � ��� ###
   $self->{'content_fields'}->{'dims'}=$1 if $html=~/Размеры, мм: ([\d\.]+x[\d\.]+x[\d\.]+)/;
   $self->{'content_fields'}->{'weight'}=$1 if $html=~/Вес, г: (\d+)/;
=head
   $self->{'content_fields'}->{'gps'}=1 if $html=~/GPS/;
   $self->{'content_fields'}->{'wifi'}=1 if $html=~/wi\-?fi/i;
   $self->{'content_fields'}->{'smsmmswapgprs'}=1 if $html=~/GPRS/;
   $self->{'content_fields'}->{'bluetooth'}='2.0' if $html=~/bluetooth/i;
   $self->{'content_fields'}->{'modem'}=1 if $html=~/GPRS/;
   $self->{'content_fields'}->{'ggg'}=1 if $html=~/3G /;
   $self->{'content_fields'}->{'edge'}=1 if $html=~/EDGE/;
#   $self->{'content_fields'}->{'standart'}=$1 if $html=~/(GSM [\d\/]+)/i;
#   $self->{'content_fields'}->{'standart'}.=', '.$1 if $html=~/(UMTS (.*?) МГц)/i;
   $self->{'content_fields'}->{'cards'}='MMC' if $html=~/mmc/i;
#   #$self->{'content_fields'}->{'cards_supported'}='SD' if $html=~/sd/i;
#   #$self->{'content_fields'}->{'cards_supported'}='MMC, ' if $html=~//i;
#   $self->{'content_fields'}->{'diktofon'}=1 if $html=~/Диктофон/i;
   $self->{'content_fields'}->{'radio'}=1 if $html=~/FM\-/;
   $self->{'content_fields'}->{'os'}=$1 if $html=~/Операционная система: (.*?)/i;
#   #$self->{'content_fields'}->{'kontaktov'}= if $html=~//i;
   $self->{'content_fields'}->{'java'}=1 if $html=~/JAVA/;
#   #$self->{'content_fields'}->{'programmy'}= if $html=~//i;
#   #$self->{'content_fields'}->{'games'}= if $html=~//i;
   $self->{'content_fields'}->{'mp3call'}=1 if $html=~/MP3-мелодии/;
   $self->{'content_fields'}->{'vibrocall'}=1 if $html=~/Виброзвонок/;
#   #$self->{'content_fields'}->{'videoformats'}= if $html=~//i;
#   #$self->{'content_fields'}->{'audioformats'}= if $html=~//i;
#   #$self->{'content_fields'}->{'image_read'}= if $html=~//i;
   $self->{'content_fields'}->{'touchscreen'}=1 if $html=~/сенсорный/i;
   $self->{'content_fields'}->{'screencolor'}=$1 if $html=~/(\d+) млн. цветов/;
#   #$self->{'content_fields'}->{'batery_time'}= if $html=~//i;
#   #$self->{'content_fields'}->{'usb_charge'}= if $html=~//i;
   if ($html=~/Размеры, мм: ([\d\.]+)x([\d\.]+)x([\d\.]+)/){
      $self->{'content_fields'}->{'width'}=$1;
      $self->{'content_fields'}->{'height'}=$2;
      $self->{'content_fields'}->{'depth'}=$3;
   }
=cut
   if ($html=~/<h3>Комлектация:/){
      $html=substr($html,index($html,'<h3>Комлектация:'));
      $html=substr($html,index($html,'<li>')+4);
      $self->{'content_fields'}->{'sostav'}=utf2win(substr($html,0,index($html,'</li>')));
   }
#!!!

   #foreach my $k(sort keys %{$self->{'content_fields'}}){
   #print "params: ".join(',',keys (%{$self->{'content_fields'}}))."\n";
   foreach my $k(@fields_list){
      next if !exists $self->{'content_fields'}->{$k};
      #print "param '$k'=|".win2koi($self->{'content_fields'}->{$k})."|\n";
   }
   $html_tmp='<img src="'.$self->{'content_image'}.'">';
   $self->{sock}->eval_links(\$html_tmp,
        $arg{'SAVE_IMG_PATH'},
        $arg{'SAVE_IMG_URL'},$self->{'content_subj'});
if ($html_tmp=~/\"(.*?)\"/){
   $self->{'content_image'}=substr($1,rindex($1,'/')+1);
}
   for (my $k=0;$k<=$#{$self->{'content_images'}};$k++){
      $html_tmp='<img src="'.$self->{'content_images'}->[$k].'">';
      $self->{sock}->eval_links(\$html_tmp,
        $arg{'SAVE_IMG_PATH'},
        $arg{'SAVE_IMG_URL'},$self->{'content_subj'});
if ($html_tmp=~/\"(.*?)\"/){
   $self->{'content_images'}->[$k]=substr($1,rindex($1,'/')+1);
}
   }
#exit;
return 1;
   foreach my $k(keys %p_ar){
      $tmp=koi2win($k);
      next if $html!~/\>$tmp\:\<\/td\>\<td valign\=top\>(.*?)\<\/td\>/;
      $tmp=$1;
      if ($p_ar{$k}==8){
	 if ($tmp=~/(\d+)x(\d+) ��������/){
	    $self->{'content_fields'}->{10}=$2.' px';
	    $self->{'content_fields'}->{9}=$1.' px';
	 }
	 $self->{'content_fields'}->{11}=$1 if ($tmp=~/(\d+) ������/);
         $tmp=~s/\,.+//;
      } elsif ($p_ar{$k}==5){
	 $tmp=~s/ //g;
	 $tmp.=' ��';
      } elsif ($p_ar{$k}=~/^3|4$/){
	 $tmp=~s/����//;
      } elsif ($p_ar{$k}==6){
	 $tmp=~s/\.$//;
      }
      $self->{'content_fields'}->{$p_ar{$k}}=$tmp;
   }
   $html_tmp=substr($html,index($html,koi2win('>��� �������:<')));
   $html_tmp=substr($html_tmp,0,index($html_tmp,'</table>'));
   @{$self->{'content_funcs'}}=$html_tmp=~/top\>(.*?)\:\<\/td\>\<td valign\=top\>(.*?)\</g;
#print win2koi(join(',',@{$self->{'content_funcs'}}))."\n";
#exit;
#WWW::GET->debug_write($html);
   #foreach my $k(keys %{$self->{'content_fields'}}){
   #   print win2koi("$k=".$self->{'content_fields'}->{$k}."\n");
   #}
   if (index($html,'<p align=justify>')!=-1){
      $self->{'content_body'}=substr($html,index($html,'<p align=justify>')+17);
      $self->{'content_body'}=substr($self->{'content_body'},0,
	index($self->{'content_body'},'</p>'));
   }
   return 1;
}
sub is_elm_in_str{
   # ����������, ���������� �� ��� �������� ������� $ar � ������ $str
   my $str=lc(shift);
   my @ar=@_;
   for (my $a=0;$a<=$#ar;$a++){
      return 0 if index($str,lc($ar[$a]))==-1;
   }
   return 1;
}
sub get_page_id{
   # ��ģ� ����������������� ����� ������� �� URL
   shift;
   return 0 if shift!~/\/cgi\-bin\/guide\.cgi\?table\_code\=\d+\&action\=show\&id\=(\d+)/;
   return $1;
}
1;
