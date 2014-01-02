# (с) Леонов П.А., 2005

package CMSBuilder::VType::string;
use strict qw(subs vars);
use utf8;
use CMSBuilder;

our @ISA = 'CMSBuilder::VType';
# Строка ####################################################

sub table_cre {$_[1]->{'big'} ? 'TEXT' : 'VARCHAR('.($_[1]->{'length'} || 255).')'}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	$val =~ s/\'/\&#039;/g;
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;
	
	
	return '<input type=hidden name="'.$name.'" value="'.$val.'">' . cmsb_url($val)->admin_name() if cmsb_url($val);
	return '<input class="winput" type=text name="'.$name.'" value="'.$val.'">';
}

sub sview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	$val =~ s/\'/\&#039;/g;
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;
	
	return '<input class="winput" type=text name="'.$name.'" value="'.$val.'">';
}

1;