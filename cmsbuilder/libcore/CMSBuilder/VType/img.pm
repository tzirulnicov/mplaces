# (с) Леонов П.А., 2005

package CMSBuilder::VType::img;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType::file';
our $filter = 1;
our $dont_html_filter = 1;

# 'photo'		=> { 'type' => 'img', 'msize' => 100, 'ext' => [qw/bmp jpg jpeg gif png/], 'name' => 'Картинка' },


sub filter_load
{
	my $c = shift;
	return CMSBuilder::VType::img::object->new(@_);
}


#———————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————————————————————————————————————————————


package CMSBuilder::VType::img::object;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType::file::object';

sub ext_list
{
	my $o = shift;
	my $p = $o->{'_prop'};
	
	return $p->{'ext'} ? @{$p->{'ext'}} : qw/bmp jpg jpeg gif png gd gd2 xbm/;
}

sub aview
{
	my $o = shift;
	
	return ($o->exists()?'<img class="preview" src="'.$o->href().'"/>':()) . $o->SUPER::aview(@_);
}

sub sview
{
	my $o = shift;
	
	return ($o->exists()?'<img class="preview" src="'.$o->href().'"/>':()) . $o->SUPER::sview(@_);
}

1;
