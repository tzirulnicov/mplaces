# (с) Леонов П.А., 2005

package UserGroup;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::DBI::Array';

sub _cname {'Группа пользователей'}
sub _add_classes {qw/plgnUsers::UserMember/}
sub _aview {qw/name html files cms root cpanel hpanel/}
sub _have_icon {1}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => 'Имя группы' },
	'html'		=> { 'type' => 'checkbox', 'name' => '<b>HTML</b>' },
	'files'		=> { 'type' => 'checkbox', 'name' => 'Загрузка файлов' },
	'root'		=> { 'type' => 'checkbox', 'name' => 'Суперпользователи' },
	'cms'		=> { 'type' => 'checkbox', 'name' => 'Доступ в <b>СА</b>' },
	'cpanel'	=> { 'type' => 'checkbox', 'name' => 'Доступ в <b>Панель управления</b>' },
	'hpanel'	=> { 'type' => 'checkbox', 'name' => 'Доступ в <b>Панель бронирования</b>'}
}

#———————————————————————————————————————————————————————————————————————————————


1;
