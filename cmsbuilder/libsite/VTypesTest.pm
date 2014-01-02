# (с) Леонов П.А., 2005

package VTypesTest;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::DBI::TreeModule';

sub _cname {'Тест для в-типов'}
sub _aview
{qw/
	string string1 string2 int checkbox
	ObjectsList ObjectsList1 ObjectsList2
	date timestamp time
	file object
	password password1
	select radio
	miniword text
/}

sub _props
{
	'string'		=> { 'type' => 'string', 'name' => 'Строка' },
	'string1'		=> { 'type' => 'string', 'big' => 1, 'name' => 'Строка (большая)' },
	'string2'		=> { 'type' => 'string', 'length' => 10, 'name' => 'Строка (10)' },
	'int'			=> { 'type' => 'int', 'name' => 'Число' },
	'checkbox'		=> { 'type' => 'checkbox', 'name' => 'Галочка' },
	'bool'			=> { 'type' => 'bool', 'name' => 'Булиево значение (наследник галочки)' },
	
	'ObjectsList'		=> { 'type' => 'ObjectsList', 'class' => 'User', 'name' => 'Перечень объектов (User)' },
	'ObjectsList1'	=> { 'type' => 'ObjectsList', 'class' => 'User', 'isnull' => 1, 'name' => 'Перечень объектов (User) Пустой' },
	'ObjectsList2'	=> { 'type' => 'ObjectsList', 'class' => 'User', 'once' => 1, 'name' => 'Перечень объектов (User) Однократно' },
	
	'date'			=> { 'type' => 'date', 'name' => 'Дата' },
	'timestamp'		=> { 'type' => 'timestamp', 'name' => 'Момент' },
	'time'			=> { 'type' => 'time', 'name' => 'Время' },
	
	'file'			=> { 'type' => 'file', 'msize' => 100, 'ext' => [qw/bmp jpg gif png/], 'name' => 'Файл' },
	'object'		=> { 'type' => 'object', 'class' => 'Page', 'name' => 'Объект' },
	'password'		=> { 'type' => 'password', 'name' => 'Пароль' },
	'password1'		=> { 'type' => 'password', 'check' => 1, 'name' => 'Пароль (с вводом текущего)' },
	
	'select'		=> { 'type' => 'select', 'variants' => [{'1'=>'Один'},{'2'=>'Два'},{'3'=>'Три'}], 'name' => 'Выпадающий список' },
	'radio'			=> { 'type' => 'radio', 'variants' => [{'1'=>'Один'},{'2'=>'Два'},{'3'=>'Три'}], 'name' => 'Переключатель' },
	
	'text'			=> { 'type' => 'text', 'name' => 'Блок текста' },
	
	'miniword'		=> { 'type' => 'miniword', 'toolbar' => 'Basic', 'name' => 'Миниворд' },
}

#-------------------------------------------------------------------------------


sub install_code {}
sub mod_is_installed {1}

1;