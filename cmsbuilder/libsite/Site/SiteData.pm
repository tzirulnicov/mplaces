# (с) Леонов П.А., 2006

package plgnSite::Data;
use strict qw(subs vars);
use utf8;

sub _aview {qw(name template hidden title my4 description usetime start end)}

sub _props
{
	name			=> { type => 'string', length => 50, name => 'Название' },
	hidden		=> { type => 'checkbox', name => 'Скрыть' },
	title			=> { type => 'string', name => 'Заголовок' },
	my4				=>	{ type => 'string', name => 'ЧПУ'  },
	description		=> { type => 'string', name => 'Описание для поисковых роботов' },
	usetime		=> {type => 'checkbox', name => 'Использовать даты публикации и устаревания' },
	start           		 => { type => 'date', name => 'Дата публикации (включительно)' },
	end              		=> { type => 'date', name => 'Дата устаревания (включительно)' }
}

#———————————————————————————————————————————————————————————————————————————————



1;
