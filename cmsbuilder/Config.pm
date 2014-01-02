# конфиг билдера

package CMSBuilder::Config;
use strict qw(subs vars);
use utf8;

use lib '/home/httpd/mplaces.ru/cmsbuilder/libcore';
use lib '/home/httpd/mplaces.ru/cmsbuilder/libsite';

#$^W = 1;
use CGI::Carp qw(fatalsToBrowser);

# Пути HTTP

our $server_main				='mplaces.ru';
our $http_eroot					= '/ee';
our $http_wwfiles				= $http_eroot.'/wwfiles';
our $http_errors				= $http_eroot.'/errors';
our $http_userdocs				= $http_eroot.'/userdocs';
our $http_aroot					= '/admin';
our $http_adress				= 'http://'.$ENV{'SERVER_NAME'};


# Пути FS

our $path_home					= '/home/httpd/mplaces.ru';
our $path_cmsb					= $path_home.'/cmsbuilder';

our $path_libcore				= $path_cmsb . '/libcore';
our $path_libsite				= $path_cmsb . '/libsite';
our $path_etc					= $path_cmsb . '/etc';
our $path_tmp					= $path_cmsb . '/tmp';
our $path_backup				= $path_cmsb . '/backup';

our $path_htdocs				= $path_home . '/htdocs';
our $path_aroot					= $path_htdocs.$http_aroot;
our $path_wwfiles				= $path_htdocs.$http_wwfiles;
our $path_userdocs				= $path_htdocs.$http_userdocs;


# Файлы

our $file_errorlog				= $path_etc.'/error.log';


# Сервер

our $server_type				= 'cgi-server';
our $server_addres				= 'local:'.$path_etc.'/cgi_server_socket'; # 'tcp:127.0.0.1:9079';
our $server_cmd_start			= $path_home.'/cgi-bin/cmsb.pl server';
our $server_pidfile				= $path_etc.'/server_pid';
our $server_autostart			= 1;
our $server_daemon				= 1;
our $server_shdown				= 50;


# MySQL

our $mysql_base					= 'mplaces';
our $mysql_user					= 'tz';
our $mysql_pas					= 'vt50al';
our $mysql_port					= 3306;

our $mysql_charset				= 'utf8'; # cp1251
our $mysql_colcon				= 'utf8_general_ci'; # cp1251_general_ci

our $mysql_data_source			= 'DBI:mysql:'.$mysql_base.';port='.$mysql_port;
our $mysql_dumpcmd				= '/usr/local/mysql/bin/mysqldump -u' . $mysql_user . ' -p' . $mysql_pas . ' -P' . $mysql_port . ' -Q --compatible=mysql40 --default-character-set=' . $mysql_charset . ' --add-drop-table ' . $mysql_base;
our $mysql_importcmd			=     '/usr/local/mysql/bin/mysql -u' . $mysql_user . ' -p' . $mysql_pas . ' -P' . $mysql_port . ' --default-character-set=' . $mysql_charset . ' ' . $mysql_base;


# CMSBuilder::DBI

our $access_on					= 1;
our $access_auto_off			= 0;
our $users_login_list			= 0;
our $users_pasoff				= 0;
our $users_module				= 'modUsers2';
our $user_admin					= 'User1';
our $user_guest					= 'User3';
our $admin_max_view_name_len	= 25;
our $admin_max_left				= 30;
our $autosave					= 0;
our $do_dbo_cache				= 1;
our $lfnexrow_error500			= 0;
our $array_def_on_page			= 20;
our $dbi_inactivedestroy		= 0;
our $dbi_keepalive				= 1;

our $access_on_e = $access_on;


# CMSBuilder

our $enable_io					= 1;
our @io_filters					= qw(fltGZIP); #fltXSLT fltGZIP
our @process_classes			= qw(CMSBuilder::MYURL CMSBuilder::EML CMSBuilder::SimpleRPC CMSBuilder::MY4);
#our $redirect_status			= '200';
#our $slashobj_myurl			= 'modSite1'; 
our @slashobj_myurl				= qw(modSite1);
our @slashobj_my4				= qw(modSite1 Page68 Page42 Page44 Page84);


# CMS

our $array_pages_width			= 5;
our $have_left_frame			= 1;
our $have_left_tree				= 1;
our $admin_left_width			= 280;
our $admin_max_left				= 280;
our $cloudFontSizeMin			= 10;
our $cloudFontSizeMax			= 20;

our $err404				= '/page41.html';

our $booking_url = 'http://www.booking.com/index.html?aid=370554';

1;
