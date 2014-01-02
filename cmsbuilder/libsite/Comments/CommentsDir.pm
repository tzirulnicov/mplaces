package CommentsDir;
use strict qw(subs vars);
use utf8;

use CMSBuilder;

our @ISA = qw(CMSBuilder::DBI::Array);

use CMSBuilder::Utils;

sub _add_classes {qw(Comment)}

sub _cname {'Комментарии'}

sub _rpcs {qw(comment_add)}

#———————————————————————————————————————————————————————————————————————————————

sub admin_comments_add_list
{
	my $o = shift;
	
	unless($o->access('a')){ return; }
	
	return '<form action="/srpc/' . $o->papa->myurl . '/admin_comments_add_comment" method="post" onsubmit="ret = ajax_form_send(event,this); this.name.value = \'\'; return ret">Тип:&nbsp;<select name="class">' . join
	(
		'',
		map { '<option value="' . $_ . '">' . $_->cname . '</option>' }
		grep { $o->elem_can_add($_) && !$_->one_instance } cmsb_classes()
	)
	. '</select>&nbsp;название:&nbsp;<input type="text" name="name">&nbsp;<button type="submit">Добавить...</button></form>';
}

sub site_content{
   my $o=shift;
   my $r=shift;
   #use Captcha::reCAPTCHA;
   #my $c=Captcha::reCAPTCHA->new;
   print '	<h3>Отзывы</h3>
	<form class="otzivi_form" action="/srpc/'.$o->myurl.'/comment_add" onsubmit="return otzivi_submit(this)" method="post">
				<input type="hidden" name="comments_mode" value="save"><br>
				<input type="text" name="comment_username" class="text_form" value="Ваше имя" /><br>
				<input type="text" name="comment_email" class="text_form" value="E-mail" /><br>
				<textarea name="comment_desc" class="text_form">Ваш отзыв</textarea>
				<table>
					<tr>
						<td><div><table><tr><td><img src="/srpc/modSite1/view_captcha?'.time().'" height="24px"></td><td>&nbsp;&nbsp;&nbsp;</td><td><input type="text" size="4" id="verifytext" name="verifytext"></td></tr></table></div></td>
						<td><br><br><input id="comment_submit" type="image" src="/i2/comment.png" name="comment_emailme" />
						<img src="/i2/indicator.gif" id="comment_indicator" style="display:none"></td>
					</tr>
				</table>
				
				
				
			</form></td></tr></table>';
print '<div>
                                <dl id="comments_div">';
   print "<dt>Нет отзывов о гостинице</dt>" if !($o->len);
   foreach my $k($o->get_all){
      $k->site_preview;
   }
   print '                              </dl>
                        </div>';
}
sub comment_add{
   my $o=shift;
   my $r=shift;
   my $desc;
   print '<div style="font-weight:bold">';
if ($r->{comments_mode} eq 'save' && $r->{comment_desc} &&
        $r->{comment_desc} ne 'Ваш отзыв'){
   my $err;
        #use Captcha::reCAPTCHA;
        #my $c=Captcha::reCAPTCHA->new;
        #my $result = $c->check_answer(
        #        '6LfxpAQAAAAAABObicIfK0c0ZiFpd0IlxRm7_aaF', $ENV{'REMOTE_ADDR'},
        #        $r->{recaptcha_challenge_field}, $r->{recaptcha_response_field}
        #);
        #if (!($result->{is_valid})){
        #	$err='Ошибка ! Неверно введё�
#� код подтверждения';
#        } else {
   $desc=$r->{comment_desc};
   $desc=~s/</&lt;/g;
   $desc=~s/>/&gt;/g;
   Encode::_utf8_on($desc);
   foreach my $k($o->get_all){
      $err='Такой отзыв уже существует' if $k->{desc} eq $desc;
   }
#   }
   #$err=123;
   if (!modSite::check_captcha($r)){
      $err='Ошибка авторизации';
   }
   elsif ($desc=~/a href\=['"]?http\:\/\//i){
#!!!
      $err='Использование внених ссылок запрещено';
   }
   if ($err){
      print "<h4 style='color:red'>$err</h4><p style='padding:10px'>";
   } else {
      my $to=Comment->cre();
      $to->{username}=$r->{comment_username};
      $to->{email}=$r->{comment_email};
      $to->{emailme}=$r->{comment_emailme};
      $to->{desc}=$desc;
      $o->elem_paste($to);
      open(FILE,'>>'.$CMSBuilder::Config::path_htdocs.'/comments.txt') or die "Cannot write file comments.txt: ".$!;
      print FILE $o->papa->myurl.": ".$desc."\r\n";
      close(FILE);
      print "Спасибо, ваш отзыв добавлен<p><p style='padding:10px'>";
   }
} else {
   print "Ошибка при добавлении отзыва, проверьте введённые данные";
}
   print '</div>';
   foreach my $k($o->get_all){
      if ($k->{emailme} && $k->{desc} ne $desc){
         sendmail(
            to => $k->{'email'},
            from    => 'Evoo <'.$o->root->{'email'}.'>',
            subj    => 
		'Поступил новый отзыв по товару: '.
		$o->papa->name(),
            text    => "Вы получили это письмо, поскольку просили нас уведомить о новых отзывов по товару ".$o->papa->name().
		"\n\nТекст отзыва:\n\n".$k->{'desc'}.
		"\n\nС остальными отзывами Вы можете ознакомиться на странице:\n\n".
		"http://$ENV{HTTP_HOST}/".lc($o->papa->myurl).".html",
            ct              => 'text/plain; charset=windows-1251'
         );
      }
      $k->site_preview;
   }
}
1;
