# (с) Леонов П.А., 2005

package TemplateDir;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::DBI::Array';

sub _cname {'Раздел шаблонов'}
sub _aview {keys %{{_props()}}}
sub _add_classes {qw(Template)}

sub _props
{
	name		=> { type => 'string', length => 25, name => 'Название' },
}

#———————————————————————————————————————————————————————————————————————————————



1;