package string;
use Exporter();
use HTML::Parser;
use cyrillic;
use MIME::Base64;
use URI::Escape;
@ISA=qw(Exporter);
@EXPORT=qw(mimeDecode toFidoFormat textType substring reverseString replace charAt toUpperCase toLowerCase strBtfsc strBcf hex2dec returnSymbolLoop);
#@EXPORT_OK=qw();
my %STRING;
sub mimeDecode{
   my $text=shift;
   my %arg=@_;
   #$arg{'Encoding'} - quoted-printable || base64
   #$arg{'Charset'} - koi || win || utf || dos
   #$arg{'OutputCharset'} - /
   my $charset=$arg{'Charset'};
   my $encoding=$arg{'Encoding'};
   my $output_charset=$arg{'OutputCharset'}?$arg{'OutputCharst'}:'win';
   $charset='win' if $charset=~/w|1251/i;
   $charset='koi' if $charset=~/k/i;
   $charset='win' if $charset=~/us\-ascii/i;
   $charset='utf' if $charset=~/u/i;
   $charset='dos' if $charset=~/d|866/i;
   $charset=0 if $charset!~/win|koi|utf|dos/;
#print "encoding=$encoding, charset=$charset, output_charset=$output_charset\n";
#exit;
   return $text if $encoding!~/q|b/i && !$charset;

   if ($encoding=~/quoted/i){
      $text=~s/\_/ /g;
      $text=~s/\=([A-Z0-9]{2})/\%\1/g;
      $text=~s/\=[\r\n]//g;
      $text=URI::Escape::uri_unescape($text);
   }
   elsif ($encoding=~/base/i){
      $text=MIME::Base64::decode_base64($text);
   }
   return $text if $charset eq $output_charset;
   $text=cyrillic::convert($charset,$output_charset,$text) if $charset;
   return $text;
}
sub toFidoFormat{
# config.pl:
#---------------------
# HTML::Parse используется всегда. Использование же модулей HTML::TreeBuilder
# и HTML::FormatText включается нижеприведённой переменной. Если они не используется,
# робот пытаетя своими силами выполнить преобразование HTML->Plain Text.
# При этом конвертирование заключается лишь в удалении тёгов, без их обработки.
#$downloadManagerUseHTMLModules=0;

   # $htmlFormat='html' - входные данные в html-формате, иначе в обычном
   my $str=shift;
   my $htmlFormat=shift || 0;
   $STRING{'EndStr'}='';
   $str=~s/\r\n/\r/g;
   $str=~s/\n/\r/g;
   #$str=~s/\r+/\r/g;
   $str=~s/\&nbsp;/ /g;
   $str=~s/\&amp;/\&/g;
   $str=~s/\&lt;/</g;
   $str=~s/\&gt;/>/g;
   # Убираем символы, при которых голдед виснет

   if ($htmlFormat=~/htm/i){
      my $parser=HTML::Parser->new(api_version=>3);
      $parser->handler(start=>\&parseHtml_start,'self,tagname,attr');
      $parser->handler(text=>\&parseHtml_extract,'self,dtext');
      $parser->handler(end=>\&parseHtml_end,'self,tagname');
      $parser->parse($str);
      $parser->eof;
=head
   # Убираем HTML-форматирование
   $str=~s/<\!--.*?-->//g;
   $str=~s/\&nbsp;/ /g;
   $str=~s/\&lt;/</g;
   $str=~s/\&gt;/>/g;
   $str=~s/\&amp;/\&/g;
   $str=~s/<li>/ * /gi;
   $str=~s/<http\:/< http\:/gi;
   $str=~s/<ftp\:/< ftp\:/gi;
   $str=~s/<hr>/---------------------------------------------/gi;
   $str=~s/<[\/]?[a-z]+[^\>]*>//gi;
   $str=~s/\{\/?NOBR\}//gi;
   $str=~s/<xmp[^>]*>(.*?)<\/xmp>/$1/gi;
=cut
#print $STRING{'EndStr'}."\n";
      $STRING{'EndStr'}=~s/\n/\r/g;
      return $STRING{'EndStr'};
   }
   return $str;
}

sub parseHtml_start{
   my ($parser,$tag,$attr)=@_;
#   $parser->{last_tag}=$tag;
   $parser->{$tag}++;
#   return unless $tag eq 'body';
   return if ($parser->{'html'} && !$parser->{'body'});
   SWITCH:{
      if ($tag eq 'br'){$STRING{'EndStr'}.="\n".($parser->{'center'}?'               ':'');last SWITCH;}
      if ($tag eq 'hr'){$STRING{'EndStr'}.="\n".("-"x79)."\n";last SWITCH;}
      if ($tag eq 'p'){$STRING{'EndStr'}.="\n\n";last SWITCH;}
      if ($tag eq 'b'){$STRING{'EndStr'}.="*";last SWITCH;}
      if ($tag eq 'i'){$STRING{'EndStr'}.="*/";last SWITCH;}
      if ($tag eq 'u'){$STRING{'EndStr'}.="_";last SWITCH;}
      if ($tag eq 'a'){$parser->{'a_href'}=$attr->{href};last SWITCH;}
      if ($tag eq 'table'){$STRING{'EndStr'}.="\n\n";last SWITCH;}
      if ($tag eq 'td'){$STRING{'EndStr'}.=" ";last SWITCH;}
      if ($tag eq 'th'){$STRING{'EndStr'}.=" ";last SWITCH;}
      if ($tag eq 'tr'){$STRING{'EndStr'}.="\n";last SWITCH;}
      if ($tag eq 'pre'){$STRING{'EndStr'}.="\n";last SWITCH;}
      if ($tag eq 'center'){$STRING{'EndStr'}.="\n               ";last SWITCH;}
      if ($tag eq 'div'){$STRING{'EndStr'}.="\n".parseHtml_checkAttr($attr);last SWITCH;}
      if ($tag eq 'img'){$STRING{'EndStr'}.=($attr->{alt} ne ''?"[".$attr->{alt}:"[IMAGE").", \"".parseHTML_getTopic($attr->{src})."\"]";last SWITCH;}
      if ($tag eq 'ol'){$STRING{'EndStr'}.="\n";$parser->{'li_count'}=0;last SWITCH;}
      if ($tag eq 'ul'){$STRING{'EndStr'}.="\n";last SWITCH;}
      if ($tag eq 'li'){$parser->{'li_count'}++;$STRING{'EndStr'}.="\n ".($parser->{'ol'}?$parser->{'li_count'}.".":"*")." ";last SWITCH;}
      if ($tag=~/^h\d$/){$STRING{'EndStr'}.="\n\n                 ";last SWITCH;}
      if (index($tag,'://')!=-1){$STRING{'EndStr'}.='<'.$tag.'>';}
      if (index($tag,'@')!=-1){$STRING{'EndStr'}.='<mailto:'.$tag.'>';}
      $STRING{'EndStr'}.=' ' if substr($STRING{'EndStr'},-1) ne ' ';
   }
#   $parser->handler(text=>\&parseHtml_extract,'self,dtext');
#   $parser->handler(end=>\&parseHtml_end,'self,tagname');
}

sub parseHtml_end{
   my ($parser,$tag)=@_;
   $parser->{$tag}--;
   return if ($parser->{'html'} && !$parser->{'body'});
   SWITCH:{
      if ($tag eq 'p'){$STRING{'EndStr'}.="\n\n";last SWITCH;}
      if ($tag eq 'b'){$STRING{'EndStr'}.="* ";last SWITCH;}
      if ($tag eq 'i'){$STRING{'EndStr'}.="/* ";last SWITCH;}
      if ($tag eq 'u'){$STRING{'EndStr'}.="_ ";last SWITCH;}
      if ($tag eq 'a'){$STRING{'EndStr'}.=(($parser->{'a_href'} ne '' && $parser->{'a_href'} ne '#')?' <'.$parser->{'a_href'}.'>':'');$parser->{'a_href'}='';last SWITCH;}
      if ($tag eq 'table'){$STRING{'EndStr'}.="\n\n";last SWITCH;}
      if ($tag eq 'td'){$STRING{'EndStr'}.=" ";last SWITCH;}
      if ($tag eq 'th'){$STRING{'EndStr'}.=" ";last SWITCH;}
      if ($tag eq 'tr'){$STRING{'EndStr'}.="\n";last SWITCH;}
      if ($tag eq 'pre'){$STRING{'EndStr'}.="\n";last SWITCH;}
      if ($tag eq 'center'){$STRING{'EndStr'}.="\n";last SWITCH;}
      if ($tag eq 'div'){$STRING{'EndStr'}.="\n";last SWITCH;}
      if ($tag eq 'ol' || $tag eq 'ul'){$STRING{'EndStr'}.="\n\n";last SWITCH;}
      if ($tag=~/^h\d$/){$STRING{'EndStr'}.="\n                 ================\n\n";last SWITCH;}
   }
   $STRING{'EndStr'}.=' ' if (substr($STRING{'EndStr'},-1)!~/[ \r\n\_\*\/]/);
#undef $parser->{last_tag};
#return if $parser->{'body'};
#$parser->handler(text=>undef);
#$parser->handler(end=>undef);
}

sub parseHtml_extract{
   my ($parser,$text)=@_;
   return if ($parser->{'html'} && !$parser->{'body'} || $parser->{'script'});
   if (!$parser->{'xmp'} && !$parser->{'pre'} && !$parser->{'code'}){
      $text=~s/[ \t]+/ /g;
      $text=~s/^[\r\n]+//g;
      $text=~s/[\r\n]+/ /g;
   }
   $STRING{'EndStr'}.=' ' if (substr($STRING{'EndStr'},-1)!~/[ \r\n\_\*\/]/);
   $STRING{'EndStr'}.=$text;
}

sub parseHtml_checkAttr{
   my $attr=shift;
   if ($attr->{align} eq 'center'){return '             ';}
}

sub parseHTML_getTopic{
   # Выдаёт название топика Фак-сервера
   my $topic=shift;
   $topic=~s/\\/\//g;
   return substr($topic,rindex($topic,'/')+1,rindex($topic,'.'));
}

sub textType{
# Input: text
# Output: 0 - win, 1 - dos, 2 - bin
#Win:09-0A,0D,20-2F,30-3F,40-4F,50-5F,60-6F,70-7E,A8,B9,C0-CF,D0-DF,E0-EF,F0-FF
my $str=shift;
my $sym=0;# Число небуквенных символов
my $word=0;# Число буквенных символов
#WinToDos
#$body=~tr/\xA8\xB8\xC0-\xDF\xE0-\xFF/\xF0\xF1\x80-\x9F\xA0-\xAF\xE0-\xEF/;
#Анг. буквы: \x41-\x4F\x50-\x5A\x61-\x6F\x70-\x7A
#  for (my $count=0;$count<length($str);$count++){
#      if (substr($str,$count,1)!~/^[\x09\x0A\x0D\x20-\x2F\x30-\x3F\x40-\x4F\x50-\x5F\x60-\x6F\x70-\x7E\xA8\xB8\xC0-\xCF\xD0-\xDF\xE0-\xEF\xF0-\xFF]+$/){
#print "OK\n";
#open(FL,">C:/localhost/www/phpmyweb/internetfix/delthis.dat");
#print FL substr($str,0,$count+1);
#close(FL);
#exit;
#}}
if ($str=~/^[\x09\x0A\x0D\x20-\x2F\x30-\x3F\x40-\x4F\x50-\x5F\x60-\x6F\x70-\x7E\xA8\xB8\xB9\xC0-\xCF\xD0-\xDF\xE0-\xEF\xF0-\xFF]+$/){
   for (my $count=0;$count<length($str);$count++){
      if (substr($str,$count,1)=~/[\x20\x30-\x39\x41-\x4F\x50-\x5A\x61-\x6F\x70-\x7A\xA8\xB8\xB9\xC0-\xDF\xE0-\xFF]/){
	 $word++;
      }
      else {
	 $sym++ if (substr($str,$count,1) ne ' ');
      }
   }
   return 0 if ($word>$sym);
}
$sym=0;
$word=0;
if ($str=~/^[\x01-\xFE]+$/i){
   for (my $count=0;$count<length($str);$count++){
      if (substr($str,$count,1)=~/[\x20\x30-\x39\x41-\x4F\x50-\x5A\x61-\x6F\x70-\x7A\xF0\xF1\x80-\x9F\xA0-\xAF\xE0-\xEF]/){
	 $word++;
      }
      else {
	 $sym++ if (substr($str,$count,1) ne ' ');
      }
   }
   return 1 if ($word>$sym);
}
return 2;
}
sub returnSymbolLoop{
   my $ret='';
   for (my $a=0;$a<$_[1];$a++){
      $ret.=$_[0];
   }
   return $ret;
}
sub hex2dec{
   #Переводит числа из шестнадцатиричной системы счисления в десятичную
   my $m60=shift;
   $m60=~s/^[0]+//;
   my $m60sm3=0;
   my $m60sm4=0;
   my $temp;
   for (my $m60sm2=length($m60)-1;$m60sm2>=0;$m60sm2--){
      $temp=uc(substr($m60,$m60sm4,1));
      $temp=~s/A/10/g;
      $temp=~s/B/11/g;
      $temp=~s/C/12/g;
      $temp=~s/D/13/g;
      $temp=~s/E/14/g;
      $temp=~s/F/15/g;
      $temp+=0;# string2dec
      $temp*=(16**$m60sm2);
      $m60sm3+=$temp;
      $m60sm4++;
   }
   return $m60sm3;
}
sub strBtfsc{
   # Равняется ли указанный бит еденицей в двоичном представлении кода символа @[0]
   my $value=unpack("B8",shift);
   my $num=shift;# 0-7
   return undef if $num!~/^[0-7]$/;
   $value.='';
   return 1 if (substr($value,7-$num,8-$num) eq '1');
   return 0;
}
sub strBcf{
   # Принимаемое значение:
   # * Двоичное значение (Символ, десятичное число, и т.д.)
   # Возвращаемое значение:
   # * Двоичное значение
   my $value=unpack("B8",shift);
   my $num=shift;
   return undef if $num!~/^[0-7]$/;
   $value=substr($value,0,7-$num).'0'.substr($value,8-$num);
   $value=pack("B8",$value);
   return $value;
}

sub substring{
   return substr(@_[0],@_[1],@_[2]-@_[1]);
}
sub reverseString{
#Переворачивает слова и числа
   my $r2='';
   my $r2b='';
   my $r3=0;
   my $r=@_[0];
   my $a=0;
   $r.='';
   if (length($r)%2==0){
      $r3=length($r)/2;
   }
   else {
      $r3=(length($r)-1)/2;
   }
   for ($a=0;$a<$r3;$a++){
      $r2=substr($r,$a,1);
      $r2b=substr($r,length($r)-$a-1,1);
      if ($a!=0){
	 $r=substr($r,0,$a).$r2b.substring($r,$a+1,length($r)-$a-1).$r2.substring($r,length($r)-$a,length($r));
      }
      else {
	 $r=substr($r,0,$a).$r2b.substring($r,$a+1,length($r)-$a-1).$r2;
      }
   }
   return $r;
}
sub replace{
   my $var=@_[0];
   my $param=@_[1];
   $param=~/\/([^\/]+)\/(\w+)?/;
   eval("\$var=~s/$1/@_[2]/$2");
   return $var;  
}
sub charAt{
   return substr($_[0],$_[1],1);
}
sub toUpperCase{
   return uc($_[0]);
}
sub toLowerCase{
   return lc($_[0]);
}
1;
