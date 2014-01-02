# (с) Леонов П.А., 2005

package CMSBuilder::VType::int;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType';
# Число ####################################################

sub table_cre {'INT('.($_[1]->{'length'} || 11).')';
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	return '<input size="4" type="text" name="'.$name.'" value="'.$val.'">';
}

sub sview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	return '<input size="4" type="text" name="'.$name.'" value="'.$val.'">';
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	$val =~ s/\D//g;
	if($val eq ''){ $val = 0; }
	
	return $val;
}

1;