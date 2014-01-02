# (с) Леонов П.А., 2005

package CMSBuilder::VType::ObjectsList;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType';
# Список ####################################################

our $filter = 1;

sub table_cre {'INT(11)'}

sub filter_load
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	my $to;
	my $p = $obj->props();
	
	if($val)
	{
		$to = $p->{$name}{'class'}->new($val);
	}
	
	return $to;
}

sub filter_save
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	my $p = $obj->props();
	
	return 0 unless ref($val) eq $p->{$name}{'class'};
	return $val->{'ID'};
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	my $cn = $p->{$name}{'class'};
	
	if($p->{$name}{'once'} && $val)
	{
		return
		'
		<select disabled>
			<option>'.$val->name().'</option>
		</select>
		';
	}
	
	my $ret = '<select name="'.$name.'">';
	
	unless($val){ $ret .= '<option value="" selected>'.$p->{$name}{'nulltext'}.'</option>'; }
	elsif($p->{$name}{'isnull'}){ $ret .= '<option value="">'.$p->{$name}{'nulltext'}.'</option>'; }
	
	for my $to ($cn->sel_where(' 1 '))
	{
		$ret .= '<option'.($to->{'ID'} == $val->{'ID'}?' selected':'').' value="'.$to->{'ID'}.'">'.$to->name().'</option>';
	}
	
	$ret .= '</select>';
	
	return $ret;
}

sub sview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	my $cn = $p->{$name}{'class'};
	
	if($p->{$name}{'once'} && $val)
	{
		return
		'
		<select disabled>
			<option>'.$val->name().'</option>
		</select>
		';
	}
	
	my $ret = '<select name="'.$name.'">';
	
	unless($val){ $ret .= '<option value="" selected>'.$p->{$name}{'nulltext'}.'</option>'; }
	elsif($p->{$name}{'isnull'}){ $ret .= '<option value="">'.$p->{$name}{'nulltext'}.'</option>'; }
	
	for my $to ($cn->sel_where(' 1 '))
	{
		$ret .= '<option'.($to->{'ID'} == $val->{'ID'}?' selected':'').' value="'.$to->{'ID'}.'">'.$to->name().'</option>';
	}
	
	$ret .= '</select>';
	
	return $ret;
}


sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	return $obj->{$name} if $obj->props()->{$name}{'once'} && $obj->{$name};
	
	return $p->{$name}{'class'}->new($val);
}

1;