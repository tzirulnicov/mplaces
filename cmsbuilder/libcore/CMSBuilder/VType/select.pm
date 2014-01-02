# (с) Леонов П.А., 2005

package CMSBuilder::VType::select;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType';
# Список ####################################################

# 'prop'	=> { 'type' => 'select', 'variants' => [{'a' => 'Крутой'},{'b' => 'Некрутой'},{'c' => 'Простой'}], 'name' => 'Тип' },

sub table_cre
{
	my $c = shift;
	my $p = shift;
	my $vars = $p->{'variants'};
	
	return "ENUM('" . join("','",(map {keys %$_} @$vars)) . "')";
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	my @vars = map { {'key' => keys %$_, 'val' => values %$_} } @{$p->{$name}->{'variants'}};
	
	my $ret = '<select name="'.$name.'">';
	for my $var (@vars)
	{
		$ret .= '<option'.($var->{'key'} eq $val?' selected':'').' value="'.$var->{'key'}.'">'.$var->{'val'}.'</option>';
	}
	$ret .= '</select>';
	
	return $ret;
}

sub sview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	my @vars = map { {'key' => keys %$_, 'val' => values %$_} } @{$p->{$name}->{'variants'}};
	
	my $ret = '<select name="'.$name.'">';
	for my $var (@vars)
	{
		$ret .= '<option'.($var->{'key'} eq $val?' selected':'').' value="'.$var->{'key'}.'">'.$var->{'val'}.'</option>';
	}
	$ret .= '</select>';
	
	return $ret;
}

1;