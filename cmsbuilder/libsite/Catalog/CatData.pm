# (с) Леонов П.А., 2005

package plgnCatalog::Data;
use strict qw(subs vars);
use utf8;

sub _aview {qw/photo desc/}

sub _props
{
	'photo'			=> { 'type' => 'img', 'msize' => 10000, 'name' => 'Картинка' },
	'smallphoto'	=> { 'type' => 'sizedimg', 'for' => 'photo', 'size' => '155x107', 'quality' => 8, 'format' => 'jpeg'},
	'desc'			=> { 'type' => 'miniword', 'name' => 'Описание в каталоге' },
}
#———————————————————————————————————————————————————————————————————————————————

1;