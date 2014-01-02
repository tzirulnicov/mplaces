# (с) Леонов П.А., 2005

package CMSBuilder::VType::webimg;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType::webfile';
our $filter = 1;
our $dont_html_filter = 1;

# 'photo'		=> { 'type' => 'img', 'msize' => 100, 'ext' => [qw/bmp jpg jpeg gif png/], 'name' => 'Картинка' },


sub filter_load
{
	my $c = shift;
	return CMSBuilder::VType::webimg::object->new(@_);
}


#———————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————————————————————————————————————————————


package CMSBuilder::VType::webimg::object;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType::webfile::object';

sub ext_list
{
	my $o = shift;
	my $p = $o->{'_prop'};
	
	return $p->{'ext'} ? @{$p->{'ext'}} : qw/bmp jpg jpeg gif png gd gd2 xbm/;
}

sub aview
{
	my $o = shift;
	
	return ($o->exists()?'<img width="300" src="'.$o->href().'"/>':()) . $o->SUPER::aview(@_);
}

sub sview
{
	my $o = shift;
	
	return ($o->exists()?'<img width="300" src="'.$o->href().'"/>':()) . $o->SUPER::sview(@_);
}

1;
