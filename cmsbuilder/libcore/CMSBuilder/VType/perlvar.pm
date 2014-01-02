# (с) Леонов П.А., 2005

package CMSBuilder::VType::perlvar;
use strict qw(subs vars);
use utf8;

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