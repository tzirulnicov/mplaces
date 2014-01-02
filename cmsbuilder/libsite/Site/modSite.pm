# (с) Леонов П.А., 2006

package modSite;
use strict qw(subs vars);
use utf8;
use CMSBuilder::IO;#for headers manipulating

our @ISA = qw(plgnSite::Member CMSBuilder::DBI::TreeModule);

our $VERSION = 1.0.0.0;

sub _cname {'Сайт'}
sub _aview {qw(name bigname title_index title email address icq skype content)}
sub _have_icon {1}
sub _add_classes {qw/!Tag !Payment !Station/}
sub _template_export {qw(mainmenu onmain onpage print_tree city_excursies city_contacts)}
sub _props
{
	bigname		=> { type => 'string', name => 'Название проекта' },
	title_index		=> { type => 'string', name => 'Заголовок на главной' },
	title			=> { type => 'string', name => 'Постоянная часть заголовка' },
	email			=> { type => 'string', length => 50, name => 'E-mail администратора' },
	address		=> { type => 'string', length => 50, name => 'Адрес сайта' },
	content		=> { type => 'miniword', name => 'Текст' },
	icq		=> { type => 'int', length=>11, name=> 'ICQ' },
	skype		=> { type => 'string', name=> 'Skype' }
}

sub _rpcs{qw/postmail view_captcha check_captcha/}

#———————————————————————————————————————————————————————————————————————————————

#(c) tz
sub postmail
{
        my $o = shift;
        my $r = shift;
#print 'yes';
#return;
        my $sended = CMSBuilder::Utils::sendmail
        (
                to              => $o->root->{email},
                from    => $r->{'email'},
                subj    => 'Новое сообщение с сайта HeadCall.Ru',
                text    => 'ФИО: '.$r->{'fio'}.'<br>Телефон: '.$r->{tel}.
                        '<br>E-Mail: '.$r->{email}.
                        '<br>Текст сообщения:<br><br>'.$r->{msg},,
                ct              => 'text/html'
        );
	print 'yes';
}


#(c) tz
sub print_tree
{
	my $o=shift;
#print $o->myurl;
	print '		<UL>
				<LI Class="activ"><A HREF="/page42.html">О компании</A></LI>
				<LI><a href="/page44.html">Проекты</a></li>
				<LI><A HREF="/page43.html">Услуги</A></LI>
				<LI><A HREF="">контакты</A></LI>
			</UL>';
}

sub onpage
{
	my $c = shift;
	my $obj = shift;
	my $r = shift;
	my $h = shift;
	
	if($r->{'eml'}->{'uri'} ne '/')
	{
		print $h;
	}
}

sub onmain
{
	my $c = shift;
	my $obj = shift;
	my $r = shift;
	my $h = shift;
	
	if($r->{'eml'}->{'uri'} eq '/')
	{
		print $h;
	}
}

sub install_code
{
	my $mod = shift;
	
	my $mr = modRoot->new(1);
	
	my $to = $mod->cre();
	$to->{'name'} = 'Главная';
	$to->{'address'} = 'http://'.$ENV{'SERVER_NAME'}.'/';
	$to->{'email'} = 'info@'.join('.',grep {$_} reverse ((reverse split /\./, $ENV{'SERVER_NAME'})[0,1]));
	$to->save();
	
	$mr->elem_paste($to);
}

sub site_title
{
	my $o = shift;
	
	return $o->SUPER::site_title(@_) unless $o->{'title_index'};
	print $o->{'title_index'};
	
	return;
}

sub site_href
{
	return '/';
}
sub city_excursies{
   shift;
   Page->city_excursies(shift,1);
}
sub city_contacts{
   CMSBuilder::cmsb_url("Page141")->city_contacts();
}
sub view_captcha{
   my $tempdir = $CMSBuilder::Config::path_tmp.'/captcha';
   my $imagedir = $CMSBuilder::Config::path_htdocs."/i2/captcha";
   # open image dir choose a random image
   opendir IMGDIR, "$imagedir"; 
   my @allimgfiles = readdir IMGDIR;
   #$totalimages = @allimgfiles;
   # define each image
   my ($countimages,$IMAGE,$randomnumber,$randomimage,$imagetext,$date,$expirecookie,%IMAGE);
   foreach my $imgfile(@allimgfiles) {
	# count and use only the gif images
	if ($imgfile =~ /\.gif/i){
	   $countimages++;
	   $IMAGE{$countimages} = $imgfile;}
	}

        # choose a random image	
        $randomnumber = int rand ($countimages);
        if ($randomnumber < 1){$randomnumber = 1;}

        $randomimage = $IMAGE{$randomnumber};

        # images are named the same as the random text
        # remove the filetype extension so we have the text only
        $imagetext = $randomimage;
        $imagetext =~ s/\.gif//g; # remove .gif extension

        # set to lower case for case insensitivity
        $imagetext = lc($imagetext);

        # get ip and create an id file with the text on the image
        open (TMPDATA, ">$tempdir/$ENV{'REMOTE_ADDR'}");
        print TMPDATA "$imagetext";
        close TMPDATA;
        chmod 0777, "$tempdir/$ENV{'REMOTE_ADDR'}";

        # set date for cookie
        $date = (time + 86400);
        $expirecookie = gmtime($date);
        # set a cookie with ip for any proxy servers used for image caching
        $headers{"Set-Cookie"}=" checkme=$ENV{'REMOTE_ADDR'}; expires=$expirecookie";
#$headers{"Content-Length"}=1257;
#$headers{"Accept-Ranges"}="bytes";
#$randomimage="LR4I.gif";
# print the image to the page
binmode(select());
#binmode select(), ':utf8';
open(IMAGE, "$imagedir/$randomimage");
print <IMAGE>;
close(IMAGE);
}
sub check_captcha{
   my $r=shift;
   my $tempdir = $CMSBuilder::Config::path_tmp.'/captcha';
   my $nofile;
   my @tmpfile;
   my $ret=0;
   # lets block direct access that is not via the form post
   #if ($ENV{"REQUEST_METHOD"} ne "POST"){
   #   print "Внутренняя ошибка верификации";
   #   return 0;
   #}
   # use this program to remove all old temp files
   # this keeps the director clean without setting up a cron job
   opendir TMPDIR, "$tempdir"; 
   my @alltmpfiles = readdir TMPDIR;
   foreach my $oldtemp (@alltmpfiles) {
	my $age = 0;
	$age = (stat("$tempdir/$oldtemp"))[9];
	# if age is more than 300 seconds or 5 minutes	
	if ((time - $age) > 300){unlink "$tempdir/$oldtemp";}
   }
   # open the temp datafile for current user based on ip
   my $tempfile = "$tempdir/$ENV{'REMOTE_ADDR'}";
   open (TMPFILE, "<$tempfile") || ($nofile = 1);
   (@tmpfile) = <TMPFILE>;
   close TMPFILE;
   # if no matching ip file check for a cookie match
   # this will compensate for AOL proxy servers accessing images
   if ($nofile == 1){
      my $cookieip = $ENV{HTTP_COOKIE};
      $cookieip =~ /checkme=([^;]*)/;
      $cookieip = $1;
      if ($cookieip ne ""){
	$tempfile = "$tempdir/$cookieip";
	open (TMPFILE, "<$tempdir/$cookieip") || eval{
		print "Сессия устарела.<br> Обновите страницу.";
		$ret=1;};
	return 0 if $ret;
	(@tmpfile) = <TMPFILE>;
	close TMPFILE;
      }
   }
   my $imagetext = $tmpfile[0];
   chomp $imagetext;
   # set the form input to lower case
   my $verifytext = lc(CGI::param('comment_verifytext'));
   # compare the form input with the file text
   if ($verifytext ne "$imagetext"){
      print "Введёный Вами код не соответствует коду на картинке";
      unlink "$tempdir/$ENV{'REMOTE_ADDR'}";
      return 0;
   }
   # now delete the temp file so it cannot be used again by the same user
   unlink "$tempfile";
   # if no error continue with the program
   #print "sucessful verification";
   return 1;
}
1;
