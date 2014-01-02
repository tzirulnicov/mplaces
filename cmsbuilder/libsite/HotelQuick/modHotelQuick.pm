# (с) Леонов П.А., 2005

package modHotelQuick;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnSite::Member','CMSBuilder::DBI::TreeModule');

sub _cname {'Рекомендованные отели'}
sub _have_icon {0}
sub _aview{qw/name/}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
}

#———————————————————————————————————————————————————————————————————————————————

sub install_code {}
sub mod_is_installed {1}

1;
