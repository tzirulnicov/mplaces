package WWW::GET;
#use Exporter();
#@ISA=qw(Exporter);
#@EXPORT=qw(new);
#use vars qw(@ISA $VERSION);
#use Socket 1.3;
use IO::Socket qw(:DEFAULT :crlf);
use URI;
use URI::Escape;
use HTML::Parser;
use Archive::Zip;
use Encoding;
use WWW::RemoteTypograf;
#use Net::Cmd;
#use Net::Config;
#use Fcntl qw(O_WRONLY O_RDONLY O_APPEND O_CREAT O_TRUNC);
$VERSION="1.0";
#@ISA     = qw(Exporter Net::Cmd IO::Socket::INET);
$/=CRLF;

sub new{
   my $pkg=shift;
   my $self={};
   my $host=shift;
   my %arg=@_;
   my $param,$folder;
   $self->{'errmsg'}='';
   $host=~s/http\:\/\///;
   if ($host=~/\//){
      $host=~/^([\w\d\-\_\.]+)\/(.*)/;
      $host=$1;
      $folder=$2;
      if (index($folder,'/')==-1){
	 $folder='';
      }
      else {
	 $folder=substr($folder,0,rindex($folder,'/')+1);
      }
   }
   #$host=~s/\///;
   #print "host=$host,folder=$folder\n";
   $self->{'net_http_host'}=$host;
   $self->{'net_http_folder'}='/'.$folder;
   $self->{'net_http_port'}=$arg{Port} || 'http(80)';
   $self->{'net_proxy_host'}=$arg{Proxy} || 0;
   $self->{'net_proxy_port'}=$arg{ProxyPort} || 'http(80)';
   $self->{'net_repeatcon_num'}=$arg{ConnectRepeatNum} || 0;
   $self->{'net_http_timeout'}=defined $arg{Timeout}
   						? $arg{Timeout}
						: 120;
   $self->{'net_http_user-agent'}="User-Agent: ".(defined $arg{UserAgent}
					? $arg{UserAgent}
					: "Mozilla/4.0 (compatible; MSIE 6.0; Windows XP)").CRLF;
   $self->{'net_cookie'}=0;
   bless $self, $pkg;
   $self->connect($self) or return undef;
   $self;
}

sub get{
   my $self=shift;
   my $url=shift;
   $url=~s/^\///;
   # $arg{'AllowOnlyImg'} - if content is not image, quiting
   my %arg=@_;
   my $sock=$self->connect($self);
   #print "connect...\n";
   return undef if !$sock;
   #print "connect ok\n";
   my $data;
   my $headers;
   my $get_params='';
   if ($arg{'Method'} eq 'POST'){
      my $params=\$arg{'Params'};
      my $key;
      if ($arg{'Enctype'} eq 'x-www-form-urlencoded'){
	 foreach $key(keys %{$$params}){
	    $data.=$key."=".uri_escape($self->recode($arg{'Params'}{$key})).'&';
	 }
	 $data=substr($data,0,-1) if $data;
      }
      else {
	 foreach $key(keys %{$$params}){
	    $data.='-----------------------------7d2172161ac'.CRLF.
		'Content-Disposition: form-data; name="'.$key.'"';
	    if ($arg{'Params'}{$key}=~/HASH/){
	       $data.=($arg{'Params'}{$key}{'Filename'}?'; filename="'.
		$arg{'Params'}{$key}{'Filename'}.'"':'').
		($arg{'Params'}{$key}{'ContentType'}?CRLF.'Content-Type: '.
		$arg{'Params'}{$key}{'ContentType'}:'').CRLF.CRLF;
		if ($arg{'Params'}{$key}{'Filename'}){
		   my $size=(stat($arg{'Params'}{$key}{'Filename'}))[7],$ok;
		   if (!$size){
                      $self->{'errmsg'}='Can\'t open file "'.
				$arg{'Params'}{$key}{'Filename'}.'"';
		      return 0;
		   }
		   open(FILE,$arg{'Params'}{$key}{'Filename'});
		   return 0 if $self->{'errmsg'};
		   binmode(FILE);
		   sysread(FILE,$ok,$size);		   
		   close(FILE);
		   $data.=$ok;
		}
		else{
		   $data.=$arg{'Params'}{$key}{'Data'};
		}
	    }
	    else {
	        $data.=CRLF.CRLF.$self->recode($arg{'Params'}{$key});
	    }
	    $data.=CRLF;
	 }
	 $data.='-----------------------------7d2172161ac--'.CRLF;
      }
      $headers="Content-Type: ".($arg{'Enctype'} eq 'x-www-form-urlencoded'?'application/x-www-form-urlencoded':'multipart/form-data; boundary=---------------------------7d2172161ac').CRLF.
		"Content-Length: ".length($data).CRLF.
		"Connection: Keep-Alive".CRLF.
		"Cache-Control: no-cache".CRLF;
   }
   if (defined($arg{'GetParams'}) || ($arg{'Method'} ne 'POST' &&
	keys(%{$arg{'Params'}}))){
      my $params;
      if (defined($arg{'GetParams'})){
	 $params=\$arg{'GetParams'};
      } else {
	 $params=\$arg{'Params'};
      }
      my $key;
      foreach $key(keys %{$$params}){
            $get_params.=$key."=".uri_escape(${$$params}{$key}).'&';
      }
      $get_params='?'.substr($get_params,0,-1) if ($get_params);
   }
=head
   print $sock "POST /cgi-bin/post.cgi HTTP/1.1".CRLF.
	"Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, */*".CRLF.
	"Accept-Language: ru".CRLF.
	"Content-Type: application/x-www-form-urlencoded".CRLF.
	($self->{'net_cookie'}''?'Cookie: '.$self->{'net_cookie'}.CRLF:'').
	"Accept-Encoding: gzip, deflate".CRLF.
	"User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)".CRLF.
	"Host: komok.com".CRLF.
	"Content-Length: 361".CRLF.
	"Connection: Keep-Alive".CRLF.
	"Cache-Control: no-cache".CRLF.CRLF.
	"UserName=%C2%E0%E4%E8%EC-2&Password=030686&thread_email=&thread_subject=%CA%D3%EF%EB%FE+%ED%EE%F3%F2%E1%F3%EA+386-486&forum=15&product_company=-&city_message=%CC%EE%F1%EA%E2%E0&type_message=sale&status_message=other&price_message=&code=3iykgD7At4Hvl9NdwmMwPujn741wgH&message=%C4%EE+500+%F0%F3%E1%EB%E5%E9.&without_smilies=yes&number=&id=donewtopic%3A&url=&name=";
=cut
#print "OK!!!|".$self->{'net_proxy_host'}."|\n";
   local $relocation_antiloop=3;
   SEND_REQUEST:
   local $http_str=(defined($arg{'Method'})?$arg{'Method'}:'GET')." ".
		($self->{'net_proxy_host'}?'http://'.
		$self->{'net_http_host'}:'').($url!~/^http\:\/\//?$self->{'net_http_folder'}:'').
		"$url".$get_params." HTTP/1.0".CRLF.
		"Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, */*".CRLF.
		"Accept-Language: ru".CRLF.
		($arg{'NoEncoding'}?"":"Accept-Encoding: gzip, deflate".CRLF).
		$self->{'net_http_user-agent'}.
		(getCookie($self)?'Cookie: '.getCookie($self).CRLF:'').$arg{'AddHeaders'}.
		"Host: ".$self->{'net_http_host'}.CRLF.$headers.CRLF.$data;
=head
$http_str='POST /posting.php HTTP/1.1
Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, application/vnd.ms-excel, application/msword, application/vnd.ms-powerpoint, */*
Accept-Language: ru
Content-Type: application/x-www-form-urlencoded
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows 98; .NET CLR 1.1.4322)
Host: forum.orexovo.pike
Content-Length: 245
Connection: Keep-Alive
Cache-Control: no-cache
Cookie: phpbb2mysql_data=a%3A2%3A%7Bs%3A11%3A%22autologinid%22%3Bs%3A32%3A%22e3afed0047b08059d0fada10f400c1e5%22%3Bs%3A6%3A%22userid%22%3Bi%3A2%3B%7D

subject=%F2%E5%F1%F2&addbbcode18=%23444444&addbbcode20=12&helpbox=%C6%E8%F0%ED%FB%E9+%F2%E5%EA%F1%F2%3A+%5Bb%5D%F2%E5%EA%F1%F2%5B%2Fb%5D++%28alt%2Bb%29&soobshenie=%F2%E5%EA%F1%F2+%F2%E5%F1%F2%E0&mode=reply&t=7009&post=%CE%F2%EF%F0%E0%E2%E8%F2%FC' if $url=~/posting/;
=cut
   print $sock $http_str;
#   print $http_str."\n";

   $self->{'net_http_content'}='';
   $self->{'net_http_content_type'}='';
   $self->{'net_http_content'}.=$data while (read($sock,$data,1024)>0);
   if ($arg{'Relocation'} && $self->{'net_http_content'}=~/\nLocation\: (.*?)\n/){
      #print "RELOCATION!!!\n";
      $sock=$self->connect($self);
      return undef if !$sock;
      $headers='';# Delete Content-type, Content-length, etc.
      $arg{'Method'}='GET';
      $url=$1;#substr($1,1);
      $url=~s/\r//g;
      $data='';
      return undef if !$relocation_antiloop;
      $relocation_antiloop--;
      goto SEND_REQUEST;
   }
#print "HTTP answer: ".$self->{'net_http_content'}."\n";

   my $head_cookie=(split(/\r?\n\r?\n/,$self->{'net_http_content'}))[0];
   #print "!!!\n$head_cookie\n!!!\n";
   while ($head_cookie=~/[\r\n]Set\-Cookie\: (.*)?[\r\n]/){
      setCookie($self,$1);
      $head_cookie=~s/[\r\n]Set\-Cookie\: (.*)?[\r\n]//;
   }
#print "Cookie=|".getCookie($self)."|\n";
   #$self->{'net_http_content_code'}=$1 if $self->{'net_http_content'}=~/^HTTP\/1\.\d (\d{3}) /;
   $self->{'net_http_headers'}=substr(
			$self->{'net_http_content'},0,
			index($self->{'net_http_content'},CRLF.CRLF));
   if ($arg{'AllowOnlyImg'} && $self->{'net_http_headers'}!~/Content\-type\: image/i){
      $self->{'errmsg'}="Server return no-image data and parameter AllowOnlyImg is set";
      return 0;
   }
   $self->{'net_http_content'}=substr(
			$self->{'net_http_content'},
			index($self->{'net_http_content'},CRLF.CRLF)+length(CRLF.CRLF));
   $self->{'net_http_headers'}=~/HTTP\/1\.\d (\d{3})/;
   #$self->{'net_http_content'}.='!!!';
   $self->{'net_http_code'}=$1;
   if ($1!=200 && $1!=301 && $1!=302){
      $self->{'errmsg'}="Unknown server answer (server code $1)";
      return 0;
   }
   if (defined $arg{WriteToFile}){
      #$arg{WriteToFile}=~s/\\/\//g;
      #$arg{WriteToFile}.='/' if substr($arg{WriteToFile},-1) ne '/';
      open(CONTENT_FILE,">".$arg{WriteToFile}) or die "WWW::GET: Cannot write image file ".$arg{WriteToFile}.": $!";
      binmode(CONTENT_FILE);
      print CONTENT_FILE $self->{'net_http_content'};
      close(CONTENT_FILE);
   }
   if ($self->{'net_http_headers'}=~/content\-encoding\: gzip/i){
=head
      my $zip=Archive::Zip->new();
      my $member=$zip->addString($self->{'net_http_content'});
      $member->desiredCompressionMethod(COMPRESSION_STORED);
      $member->writeToFileHandle($txt);
#open(FILE,'>/home/html/logs/site.zip') or die $!;
#binmode(FILE);
#print FILE $self->{'net_http_headers'};
#close(FILE);
#exit(0);
=cut
   }
   if ($self->{'net_http_headers'}=~/\nContent\-type\: ?(.*?)\n?/i){
      $self->{'net_http_content_type'}=$1;
      if (substr($self->{'net_http_content'},6,4) eq 'JFIF'){
	 $self->{'net_http_content_type'}="image/jpeg";
      }
      elsif (substr($self->{'net_http_content'},0,2) eq 'BM'){
	 $self->{'net_http_content_type'}="image/bmp";
      }
      elsif (substr($self->{'net_http_content'},0,3) eq 'GIF'){
	 $self->{'net_http_content_type'}="image/gif";
      }
   }
   # Auto recode 2 cp1251
   if ($arg{'AutoRecode'}){
      my $charset=0;
      if  ($self->{'net_http_headers'}=~/content\-type\: ?text\/\w?html\; ?charset\=([\w\d\-]+)/i){
         $charset=$1;
      } else {
	 my $p=HTML::Parser->new(api_version=>3);
	 $p->handler(start=>\&search_meta,'self,tagname,attr');
	 $p->parse($self->{'net_http_content'});
	 $charset=$p->{'charset'};
      }
      if ($charset){
         $self->{'net_http_content'}=Encoding->utf2win($self->{'net_http_content'}) if $charset=~/utf/i;
         $self->{'net_http_content'}=Encoding->koi2win($self->{'net_http_content'}) if $charset=~/koi/i;
	 $self->{'net_http_charset'}=$charset;
         #print "Charset: $charset\n";
      }
   }
   return 1;
}

sub search_meta{
   # Ищет тёги <meta> на предмет определения кодировки страницы
   my ($p,$tag,$attr)=@_;
   return if $tag ne 'meta';
   $p->{'charset'}=$attr->{'charset'} if $attr->{'charset'};
   $p->{'charset'}=$1 if ($attr->{'content'}=~/text\/\w?html\; ?charset\=([\w\d\-]+)/i);
}

sub list{
   my $self=shift;
   my %arg=@_;
   my $data=$self->{'net_http_content'};
   my $fields=\$arg{'Fields'};
   my $line;
   my $key;
   my @resultAr;
   my $count=0;
   my $check=0;
   $data=substr($data,index($data,$arg{StartPos})) if defined $arg{StartPos};
   $data=substr($data,0,index($data,$arg{EndPos})) if defined $arg{EndPos};
   $data=~s/[\r\n]+//g;# хМЮВЕ "$line!~/$arg{'Fields'}{$key}/" МЕ АСДЕР ПЮАНРЮРЭ.
   foreach $line (split(/$arg{'LineSeparator'}/,$data)){
      $check=0;
      foreach $key(keys %{$$fields}){
	 next if $line!~/$arg{'Fields'}{$key}/;
	 $resultAr[$count]->{$key}=$1;
	 $check=1;
      }
      $count++ if $check;
   }
   @resultAr;
}

sub connect{
   my $self=shift;
   local $exit=0,$repeat_num=$self->{'net_repeatcon_num'},$sock;
   #print "$repeat_num|Start connect...\n";
   REPEAT_CONN:
   $sock = IO::Socket::INET->new(PeerAddr => 
	($self->{'net_proxy_host'}?$self->{'net_proxy_host'}:$self->{'net_http_host'}), 
			    PeerPort => ($self->{'net_proxy_host'}?$self->{'net_proxy_port'}:$self->{'net_http_port'}),
			    Proto    => 'tcp',
			    Timeout  => $self->{'net_http_timeout'}
			   );
   #print "Probe connect...\n";
   $repeat_num--;
   goto REPEAT_CONN if (!$sock && $repeat_num>0);
   #print "Connect fail !\n" if !$sock;
   #print "End connect...\n";
   #$sock->autoflush(1);
   $self->{'errmsg'}='Couldnt connect to "'.
	($self->{'net_proxy_host'}?$self->{'net_proxy_host'}:$self->{'net_http_host'}).
	'": '.$@ if (!$sock);
   $sock;
}
sub setCookie(\$,$){
   my ($self,$str)=@_;
   $str=~s/[\r\n]//g;
   my @strAr=split(/\;/,$str);
   my @strAr2;
   foreach (my $a=0;$a<($#strAr+1);$a++){
      $strAr[$a]=~s/^ +//g;
      $strAr[$a]=~s/ +$//g;
      @strAr2=split(/\=/,$strAr[$a]);
      $self->{'cookie_hash'}{$strAr2[0]}=$strAr2[1];
      #print "cookie|".$strAr2[0]."=".$strAr2[1]."|\n";
   }
#print "Cookie: |".$self->{'net_http_host'}."|$str|\n";
}
sub getCookie{
   my $self=shift;
   my $str='';
   foreach my $k(keys %{$self->{'cookie_hash'}}){
      next if ($k eq 'expires' || $k eq 'path');
      $str.=$k.'='.$self->{'cookie_hash'}{$k}."; ";
   }
   $str=substr($str,0,-2) if $str;
   return $str;
}
sub rel2abs_uri{
   # Relative to absolute url
   $self=shift;
   # For Example:
   # "http://zlavick.ints.ru/tr/","get.php" -> "http://zlavick.ints.ru/tr/get.php"
   # "ixbt.com/news/123.htm","../test.htm" -> "http://ixbt.com/test.htm"
   # "aaa.com/123/","/get.php" -> "http://aaa.com/get.php"
   my $hostpath=shift;
   my $path=shift,$url,$hostname,$hosturl,@ar,$a;
   $path=~s/\&amp\;/\&/g;
   return $path if (substr($path,0,7) eq 'http://');
   $hostpath=~/(http\:\/\/)?([\w\d\.\-\_]+)\/?(.+)/;
   $hostname=$2;# 'zlavick.ints.ru'
   return 'http://'.$hostname.$path if (substr($path,0,1) eq '/');
   $hosturl=$3;# 'tr/'
   $hosturl=~s/\/[^\/]+\.[^\/]+$/\//;
   $hosturl=~s/\/$//;
   return 'http://'.$hostname.'/'.$hosturl.'/'.$path if (substr($path,0,3) ne '../');
   @ar=split('../',$path);
   foreach $a(@ar){
      last if $a;
      if ($hosturl eq ''){
	 $self->{errmsg}='WWW::GET->rel2abs_url error: Invalid uri args ("'.$hostpath.'","'.$path.'")';
	 return 0;
      }
      $hosturl='' if (index($hosturl,'/')==-1);
      $hosturl=~s/\/[^\/]+$//g;
      $path=~s/^\.\.\///;
   }
   $hosturl.="/" if $hosturl ne '';
   return "http://$hostname/$hosturl"."$path";
}
sub eval_links(){
   # Переводим все относительные ссылки в абсолютные.
   # Если $dr задан, то выкачиваем все картинки и заменяем ссылки
   # на них на локальные ссылки
   # Картинки выкачиваются в $dr, а URL картинки заменяется
   # на $dr_url/[имя_файла]
   # Именуем картинки по названию темы, если задано
   my $self=shift;
   my $html=shift;
   my $img_subj=$_[2];#Шаблон для именования картинок
   return 0 if !$html;
   $img_subj=~tr/a-zA-Z0-9\-/_/c if $img_subj;
   $img_subj=~s/_{2,}/_/g;
   my $p=HTML::Parser->new(api_version => 3);
   $p->{'img_subj'}=$img_subj;
   $p->{'host'}=$self->{'net_http_host'};
   $p->{'html'}=($$html?$$html:$html);
   $p->{'dr'}=shift;
   $p->{'dr_url'}=shift;
   return 0 if (!$p->{dr} || !$p->{'dr_url'});
   $p->handler(start=>\&eval_links_start,'self,tagname,attr');
   $p->parse(($$html?$$html:$html));
   $$html=$p->{'html'};
   return @{$p->{'images'}};
}
sub eval_links_start{
   my ($p,$tag,$attr)=@_;
   my ($param,$before,$gt,$file,$tmp);
   return if (!$attr->{'href'} && !$attr->{'src'});
   $param=$attr->{'href'} if $attr->{'href'};
   $param=$attr->{'src'} if $attr->{'src'};
   if ($param!~/^http\:\/\//i){
      $before=$param;
      #print "|$tag,before:".$before."|,after:";
      $param=~s/^\///;
      $param='http://'.$p->{'host'}.'/'.$param;
      $before=~s/([\/\.\&\+\-\_\?])/\\\1/g;
      $p->{'html'}=~s/(href|src)\=([\'\"])?$before/\1\=\2$param/i;
      #print $param."!\n";
   }
   if ($p->{'dr'} && $p->{'dr_url'}){
      # Download fotos
      $param=~/http\:\/\/([^\/]+)(.+)/i;
      $gt=WWW::GET->new($1);
      return if !$gt;
      if ($gt->get($2,AllowOnlyImg=>1)){
	 $gt->{'net_http_headers'}=~/Content\-type\: image\/(\w+)/i;
	 $tmp=$1;
	 $tmp=~s/jpeg/jpg/;
	 $file=WWW::GET->getExceptionalFileName($p->{'dr'},$tmp,$p->{img_subj});
	 print "Write file: ".$p->{'dr'}.'/'.$file."\n";
	 open(FILE,">".$p->{'dr'}.'/'.$file) or return;
	 binmode(FILE);
	 print FILE $gt->{'net_http_content'};
	 close(FILE);
	 $param=~s/([\/\.\&\+\-\_\?])/\\\1/g;
	 $p->{'html'}=~s/$param/$p->{'dr_url'}\/$file/;
	 push(@{$p->{'images'}},$file);
      }
   }
}
sub debug_write{
   shift;
   my $a=shift;
   my $file=shift || '/home/html/logs/site.htm';
   #print "Content-type: text/html\n\n";
   open(FILE,">$file") or die "Cannot write file $file: ".$!;
   #print FILE '<xmp>';
   print FILE $a;
#print '<xmp>'.$a.'</xmp>';
   #print FILE '</xmp>';
   close(FILE);
   print "Content has been writed to $file\n";
   exit;
}
sub getExceptionalFileName{
   shift;
   my $path=shift,$razsh=shift,$template=shift,$file,$count=0;
   return 0 if (!-d $path || !$razsh);
   return "$template.$razsh" if !-e "$path/$template.$razsh";
   opendir(DIRExc,$path) or return 0;
   while($file=readdir(DIRExc)){
      if ($file=~/$template(\d+)\.$razsh/i){
	 if ($1>$count){
	    $count=$1;
	 }
      }
   }
   closedir(DIRExc);
   $count++;
   return "$template$count.$razsh";
}
sub getUrls{
   # Get all urls from page
   my $self=shift;
   my $html=shift;
   my $p=HTML::Parser->new(api_version => 3);
   $p->handler(start=>\&getUrls_start,'self,tagname,attr');
   $p->parse($html);
   return @{$p->{'links'}};
}
sub getUrls_start{
   my ($p,$tag,$attr)=@_;
   return if $tag ne 'a';
#   print "|$tag,".$attr->{'href'}."|\n";
   push(@{$p->{'links'}},$attr->{'href'});
}
sub filename{
   # get filename (with get params) form url
   shift;
   $url=shift;
   return substr($url,rindex($url,'/')+1) if (index($url,'/')!=-1);
   return $url;
}
sub url2abs{
   # get absolute url
   shift;
   $papa_url=shift;#  Опорный URL для $child_url, обязательно с именем домена
   $child_url=shift;# Юрл, который требуется сделать абсолютным
   return $child_url if $child_url=~/http\:\/\//;
   my $host;
   #print "papa_url=$papa_url, child_url=$child_url\n";
   return 0 if $papa_url!~/http\:\/\//;
   $papa_url=~s/\?.*?$//;
   # Если опорный юрл с названием файла, то удаляем его, оставляя домен с путём
   $papa_url=substr($papa_url,0,rindex($papa_url,'/')) if $papa_url=~/[\w\d]\/[^\/\.]*?\.\w{2,5}?$/;
   $papa_url=~s/\/$//;
   # "/abc"
   if ($child_url=~/^\//){
      #print "return: ".WWW::GET->hostname($papa_url).$child_url."\n";
      return WWW::GET->hostname($papa_url).$child_url;
   }
   # "./abc" || "abc"
   if ($child_url=~/^\.\// || $child_url!~/^\./){
      $child_url=~s/^\.\///;
      #print "return !1! ".$papa_url.'/'.$child_url."\n";
      return $papa_url.'/'.$child_url;
   }
   # "../"
   while ($child_url=~/\.\.\//){
      $child_url=~s/\.\.\///;
      $papa_url=substr($papa_url,0,rindex($papa_url,'/')) if index($papa_url,'/')!=-1;
   }
   #print "return !2!".$papa_url.'/'.$child_url."\n";
   return $papa_url.'/'.$child_url;
}

sub hostname{
   shift;
   return 0 if shift!~/(http\:\/\/[\w\d\-\_\.]+)/;
   return $1;
}
sub url_path{
   # cut filename with get params from url
   shift;
   my $url=shift;
   $url=~s/\?.+$//;# cut get params
   $url=~s/([\w\d])\/[^\/]+\.[\w\d]+$/\1\//;
   return $url;
}
sub recode{
   # Recode data from cp1251 to net_http_charset
   my $self=shift;
   my $text=shift;
   if ($self->{'net_http_charset'}){
      $text=Encoding->win2utf($text) if $self->{'net_http_charset'}=~/utf/i;
      $text=Encoding->win2koi($text) if $self->{'net_http_charset'}=~/koi/i;
   }
   return $text;
}
sub typograf{
   # 1) Пропускает текст через типограф Артёмия Лебедева
   # 2) Заключает ссылки в <noindex> для исключения их индексирования
   #	поисковыми системами
   # 3) Вырезает все атрибуты всех тёгов
   # 4) Удаляет все тёги <table>, <tr>, <th>, <td>, <tbody>, <thead>
   my $self=shift;
   my $html=shift;
   my $html_temp;
   my $remoteTypograf=new WWW::RemoteTypograf('Windows-1251');   
   $remoteTypograf->xmlEntities();
   $remoteTypograf->p (1);
   $remoteTypograf->br (1);
   $remoteTypograf->nobr (3);
   $html_temp=$remoteTypograf->ProcessText ($html);
   $html=$html_temp if $html_temp ne 'Размер текста ограничен 32 КБ';
   $html=~s/\<(a|img)/\<\!\1/g;
   $html=~s/(\<\w+).*?\>/\1\>/gs;
   $html=~s/\<\/?(table|tr|th|td|tbody|thead).*?\>//gs;
   $html=~s/\<\!a/\<noindex\>\<a/g;
   $html=~s/(\<\/a\>)/\1\<\/noindex\>/g;
   $html=~s/\<\!img/\<img/g;
   return $html;
}
sub cut_html{
   # cut all html tags from text
   shift;
   my $html=shift;
   $html=~s/\<\/?\w+.*?\>//g;
   return $html;
}
sub getDate{
   # Преобразует даты различного вида к дате в формате "YYYY-MM-DD"
   shift;
   my $html=shift;
   my $date;
   if ($html=~/(\d+) (ЪМБЮПЪ|ТЕБПЮКЪ|ЛЮПРЮ|ЮОПЕКЪ|ЛЮЪ|ХЧМЪ|ХЧКЪ|ЮБЦСЯРЮ|ЯЕМРЪАПЪ|НЙРЪАПЪ|МНЪАПЪ|ДЕЙЮАПЪ) (\d{4})/){
      $date=$3.'-'.$2.'-'.$1;
      $date=~s/ЪМБЮПЪ/01/;
      $date=~s/ТЕБПЮКЪ/02/;
      $date=~s/ЛЮПРЮ/03/;
      $date=~s/ЮОПЕКЪ/04/;
      $date=~s/ЛЮЪ/05/;
      $date=~s/ХЧМЪ/06/;
      $date=~s/ХЧКЪ/07/;
      $date=~s/ЮБЦСЯРЮ/08/;
      $date=~s/ЯЕМРЪАПЪ/09/;
      $date=~s/НЙРЪАПЪ/10/;
      $date=~s/МНЪАПЪ/11/;
      $date=~s/ДЕЙЮАПЪ/12/;
      return $date;
   }
   return 0;
}
sub preview_text{
   # Возвращает краткую аннотацию к тексту (первое предложение)
   shift;
   my $html=shift;
   $html=~s/\<h\d+.*?\>.*?\<\/h\d+\>//gs;# Вырезаем все заголовки
   $html=WWW::GET->cut_html($html);
   return substr($html,0,index($html,'.')).'...';
}
sub str2regexp{
   shift;
   my $str=shift;
   $str=~s/([\:\(\)\/\-\*\?\+\.])/\\\1/g;
   return $str;
}
sub substr_idx(){
   shift;
   my $text=shift;
   my $subtext=shift;
   return $text=substr($text,index($text,$subtext)+length($subtext));
}
=head
Описание функций модуля
   get() - получает заданный вэб-документ. Устанавливаемые параметры:
   net_http_content_code - Код ответа сервера
   net_http_content_type - Content-type документа вида type/subtype(; charset=charset)
      Значение данного параметра может отличаться от Content-type'а,
      который вернул сервер - функция на основе собственного анализа
      (пока-только картинок) документа
      определяет его контент-тип и заносит в данный параметр
   net_http_content - сам документ
   net_http_headers - техническая информация ("заголовок" документа)
   net_cookie - плюшки, возвращаемые сервером
   net_http_charset - кодировка страницы, автоматически определяемая, если
	задан параметр AutoRecode
   ...
      Отправляемые и принимаемые данные должны быть в cp1251 ! Модуль сам по
   необходимости перекодирует их.
=cut
1;
