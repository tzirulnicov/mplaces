package WWW::MAIL;
# Внимание ! Если письмо многокомпонентное, и имеются несколько версий
# текста (напр., html и plain text), то будет отдано только первая из них !
use Net::POP3;
use Net::SMTP;
use MIME::Words;
use MIME::Base64 qw(encode_base64 decode_base64);
use Encoding;
use cyrillic;
use string;
sub new{
   my $pkg=shift;
   my $self={};
   my $host=shift;
   my %arg=@_;
   my $host1=$host;
   my $host2=$host;
   if (index($post,'|')!=-1){
      $host1=substr($post,0,index($post,'|'));
      $host2=substr($post,index($post,'|')+1);
   }
   $self->{sock}=Net::POP3->new($host1);
   $self->{sock2}=Net::SMTP->new($host2);
   $self->{user}=$arg{'User'};
   $self->{pass}=$arg{'Pass'};
   undef if !$sock->{sock};
   bless $self,$pkg;
   $self;
}
sub auth{
   my $self=shift;
   #return 1 if (!$self->{user} || !$self->{pass});
   if (!$self->{sock}->login($self->{user},$self->{pass})){
      $self->{'errmsg'}="Couldn't login, bad username or password";
      return 0;
   }
   $self->{'auth_ok'}=1;
}
sub list_item{
   # GROUP - E-Mail
   # SINCE_ID - начиная с какого ID начинаем обрабатывать сообщения
   # LIMIT - максимальное количество сообщений, которое дозволено обработать
   my $self=shift;
   my %arg=@_,$url;
   if ($arg{'GROUP'}!~/^[\w\d\-\.\_]+\@[\w\d\-\_\.]+$/){
      $self->{'errmsg'}='GROUP is not e-mail !';
      return 0;
   }
   return 0 if (!auth($self));
   $self->{links}=$self->{sock}->list();
   return 1;
}

sub get_topic{
   my $self=shift;
   my %arg=@_;
   my $msgnum;
   $self->{'content_subj'}='';
   $self->{'content_body'}='';
   $self->{'text'}='';
   return 0 if !keys %{$self->{links}};
   foreach $msgnum(sort keys %{$self->{links}}){
      $self->{text}=join('',@{$self->{sock}->get(
	$msgnum
	)});
      if (!$self->{'text'}){
	 $self->{'errmsg'}='WWW::MAIL->get_topic(): Cannot get mail';
	 $self->{'errcode'}='10';
	 return 0;
      }
      delete $self->{links}->{$msgnum};
      $self->{'msg_num'}=$msgnum;
      $self->{sock}->delete($msgnum) if $arg{'Delete'};
      last;
   } 
   $self->{'content_subj'}=$self->get_subject();
   $self->{'content_body'}=$self->get_body();
   print $self->{'msg_num'}.": ".cyrillic::convert('win','koi',$self->get_subject())."\n";
#   print "body: ".cyrillic::convert('win','koi',$self->get_body())."\n";
   return 1;
}
sub end{
   my $self=shift;
   $self->{sock}->quit();
   $self->{sock2}->close();
}
sub get_body{
   my $self=shift;
   my $text=shift || '';
   $text=$self->{text} if !$text;
   my $text_body=substr($text,index($text,"\n\n"));
   my $type=$self->get_field('Content-Type',$text);
   my $encode=$self->get_field('Content-Transfer-Encoding');
   if ($type=~/text\//){
      $text=substr($text,index($text,"\n\n")+2);
      if ($self->{'partname'}){
	 $text=mimeDecode(substr($text,0,index($text,"\n--".$self->{'partname'})),
		Charset=>$type,Encoding=>$encode);
      } else {
	 $text=mimeDecode($text,Charset=>$type,Encoding=>$encode);
      }
      $self->{'partname'}='';
#print "Type: $text\n";
#print $text;
      return $text;
   }
   elsif ($type=~/multipart\// && $type=~/boundary\=\"(.*?)\"/){
      $text=substr($text,index($text,"\n--".$1)+length($1)+3);
      $self->{'partname'}=$1;
      $self->get_body($text);
#      $text=substr($text);
#print "multipart\n";
#exit(0);
#print substr($text,0,300);
   }
#exit(0);
}
sub get_subject{
   my $self=shift;
   my ($subj,$line,$encod,$format,$tmp);
   my $str=$self->get_field('Subject');
#print "string: |$str|\n";
#exit;
   return '' if !$str;
   foreach $line (split(/\n/,$str)){
      if ($line=~/\=\?(.*?)\?(\w)\?([^\?]+)\?/i){
	 $encod=lc($1);
	 $format=lc($2);
#print "string=$1&$2&$3\n";
	 $tmp=$3;
	 #if ($format eq 'q'){
	 #   $tmp=~s/\_/ /g;
	 #   $tmp=~s/\=/\%/g;
	 #   $tmp=URI::Escape::uri_unescape($tmp);
	 #}
	 $line=~s/^[ \t]+//;
	 $tmp=MIME::Words::decode_mimewords($line);
         #$tmp=MIME::Base64::decode_base64($tmp) if $format eq 'b';
         $tmp=cyrillic::convert('utf','win',$tmp) if $encod=~/utf/;
         $tmp=cyrillic::convert('koi','win',$tmp) if $encod=~/koi/;
	 $subj.=$tmp;
      }
      else {
	 $subj.=$line;
      }
   }
   return $subj;
}
sub get_field{
   my $self=shift;
   my $field=shift;
   my $text=shift || $self->{text};
   my $check=0;
   return 0 if ($text!~/\n$field\: /);
   my ($line,$field_lines);
   $text=substr($text,index($text,"\n$field: ")+3+length($field));
   $text=substr($text,0,index($text,"\n\n"));
   foreach $line (split(/\n/,$text)){
      last if $line=~/^[A-Z][\w\d\-\_]+\:/ && $check;
      $check=1;
      $line=~s/^ +//g;
      $field_lines.=$line."\n";
   }
   return $field_lines;
}
sub post {
   my $self=shift;
   my %arg=@_;
   #$arg{'ContentType'}='plain' if !$arg{'ContentType'};
   #$arg{'Charset'}='koi8-r' if !$arg{'Charset'};
   if (!$self->{sock2}){
      $self->{'errmsg'}='WWW::MAIL->post(): Error connect to server: '.
	$self->{sock2}->message;
      $self->{'errcode'}='20';
      return 0;
   }
#$from=$arg{'FromName'}.'kaka '.$arg{'From'}.'';
#print "From: ".$from."\n";
#print "User: $self->{user},pass:$self->{pass}\n";
   if ($self->{user} && $self->{pass} &&
        !$self->{sock2}->auth($self->{user},$self->{pass})){
      $self->{'errcode'}='23';
      $self->{'errmsg'}='WWW::MAIL->post(): authorisation fails';
      return 0;
   }
   if (!$arg{'From'} || !$self->{sock2}->mail($arg{'From'})){
      $self->{'errmsg'}='WWW::MAIL->post(): Bad "From" address. '.
        $self->{sock2}->message;
      $self->{'errcode'}='21';
      return 0;
   }
   if (!$arg{'To'} || !$self->{sock2}->to($arg{'To'})){
      $self->{'errmsg'}='WWW::MAIL->post(): Bad "To" address. '.
        $self->{sock2}->message;
      $self->{'errcode'}='22';
      return 0;
   }
   if ($arg{'Cc'} && !$self->{sock2}->cc($arg{'Cc'})){
      $self->{'errmsg'}='WWW::MAIL->post(): Bad "Cc" address. '.
        $self->{sock2}->message;
      $self->{'errcode'}='22';
      return 0;
   }
   map { $arg{$_} =~ s/([^\x14-\x19\x21-\x7F]+)/base64m($1)/ge; } qw(FromName Subject);
   $self->{sock2}->data();
#print "To: ".$arg{'To'}."\n".($arg{'FromName'}?'From: '.$arg{'FromName'}.
#        '<'.$arg{'From'}.'>'."\n":'').(($arg{'ContentType'} ||
#        $arg{'Charset'})?"Content-Type: text/".($arg{'ContentType'} || 'plain').
#        ($arg{'Charset'}?"; charset=\"".$arg{'Charset'}."\"":'')."\n":'').
#        "Subject: ".$arg{'Subject'}."\n\n".substr($arg{Text},0,400);
   $self->{sock2}->datasend("To: ".$arg{'To'}."\n".($arg{'FromName'}?'From: '.$arg{'FromName'}.
	'<'.$arg{'From'}.'>'."\n":'').($arg{'Cc'}?"Cc: $arg{'Cc'}\n":'').(($arg{'ContentType'} || 
	$arg{'Charset'})?"Content-Type: text/".($arg{'ContentType'} || 'plain').
	($arg{'Charset'}?"; charset=\"".$arg{'Charset'}."\"":'')."\n":'').
	"Subject: ".$arg{'Subject'}."\n\n".$arg{'Text'});
   if (!$self->{sock2}->dataend()){
      $self->{'errmsg'}='WWW::MAIL->post(): Connection wouldn\'t accept data. '.
        $self->{sock2}->message;
      $self->{'errcode'}='23';
      return 0;
   }
   return 1;
}
sub get_mail{
   # Cut e-mail from input string
   my $self=shift;
   my $mail=shift;
   $mail=$self->get_field('From') if !$mail;
   return $1 if ($mail=~/([\w\d\.\-\_]+\@[\w\d\.\-\_]+)/);
   return 0;
}
sub base64m{
        my $str = '=?KOI-8R?B?' . encode_base64(shift) . '?=';
        $str =~ s/\s//g;
        return $str;
}
1;
