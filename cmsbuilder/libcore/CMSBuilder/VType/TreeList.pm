# (с) Леонов П.А., 2005

package CMSBuilder::VType::TreeList;
use strict qw(subs vars);
use utf8;

use CMSBuilder;

our @ISA = 'CMSBuilder::VType';
# Список ####################################################

our $filter = 1;

sub table_cre {'VARCHAR(50)'}

sub filter_insert { return ''; }

sub filter_load
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	return $val ? cmsb_url($val) : undef;
}

sub filter_save
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	if($val && ref $val)
	{
		return $val->myurl();
	}
	else
	{
		return '';
	}
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	my $arr;
	eval { $arr = $p->{$name}{root}->($obj); };
	
	return 'ошибка: ' . $@ if $@;
	return 'не определено' if !$arr;
	
	if($p->{$name}{'once'} && $val)
	{
		return
		'
		<select disabled>
			<option>' . $val->name . '</option>
		</select>
		';
	}
	
	my $ret = '<select name="' . $name . '">';
	
	unless ($val)
	{
		$ret .= '<option value="" selected>' . $p->{$name}{nulltext} . '</option>';
	}
	elsif ($p->{$name}{'isnull'})
	{
		$ret .= '<option value="">' . $p->{$name}{nulltext} . '</option>';
	}
	
	my $val_myurl = $val ? $val->myurl : undef;
	
	$ret .= make_options($arr, $p->{$name}{leaves}, $val_myurl);
	
	$ret .= '</select>';
	
	return $ret;
}

sub sview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	my $arr;
	eval { $arr = $p->{$name}{root}->($obj); };
	
	return 'ошибка: ' . $@ if $@;
	return 'не определено' if !$arr;
	
	if($p->{$name}{'once'} && $val)
	{
		return
		'
		<select disabled>
			<option>' . $val->name . '</option>
		</select>
		';
	}
	
	my $ret = '<select name="' . $name . '">';
	
	unless ($val)
	{
		$ret .= '<option value="" selected>' . $p->{$name}{nulltext} . '</option>';
	}
	elsif ($p->{$name}{'isnull'})
	{
		$ret .= '<option value="">' . $p->{$name}{nulltext} . '</option>';
	}
	
	my $val_myurl = $val ? $val->myurl : undef;
	
	$ret .= make_options($arr, $p->{$name}{leaves}, $val_myurl);
	
	$ret .= '</select>';
	
	return $ret;
}


sub make_options
{
	my ($node, $lvs, $val, $deep) = @_;
	
	return if $deep > 50;
	
	my $ret;
	
	for my $to ($node->get_all)
	{
		$ret .= '<option' . ( $to->myurl eq $val && ' selected') . ' value="' . $to->myurl . '">' . $to->name . '</option>'
			if !@$lvs || grep { $to->isa($_) } @$lvs;
		
		if ($to->len)
		{
			$ret .= '<optgroup label="' . $to->name . '">' . make_options($to, $lvs, $val, $deep + 1) . '</optgroup>';
		}
	}
	
	return $ret;
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props;
	
	return $obj->{$name} if $obj->props()->{$name}{once} && $obj->{$name};
	
	return cmsb_url($val);
}

1;