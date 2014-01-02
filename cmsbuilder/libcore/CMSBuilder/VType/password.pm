# (с) Леонов П.А., 2005

package CMSBuilder::VType::password;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType';
# Пароль ####################################################

our $filter = 1;

use CMSBuilder::Utils;

sub table_cre {'VARCHAR(32)'}


sub filter_load
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	$obj->{'_pashash_'.$name} = $val;
}

sub filter_save
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	unless($val){ return ''; }
	
	if($obj->{'_pashash_'.$name} ne $val)
	{
		$val = MD5($val);
	}
	
	return $val;
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	my ($ret,$do);
	
	if($val)
	{
		$ret = 'Установлен.';
		$do = 'Изменить...';
	}
	else
	{
		$ret = '<span style="color:#ff0000">НЕ УСТАНОВЛЕН.</span>';
		$do = 'Установить...';
	}
	
	$ret .= '
	&nbsp;&nbsp;&nbsp;&nbsp;
	<button onclick="
		'.$name.'_input.style.display = \'inline\';
		'.$name.'_ch.style.display = \'none\';
		'.$name.'_doch.value = \'yes\';
		return false;
		"
	id="'.$name.'_ch">'.$do.'</button>
	<span style="display: none" id="'.$name.'_input"><br>';
	
	if($obj->props()->{$name}{'check'} && $obj->{$name})
	{
		$ret .=
		'
			<input class="ainput" type="password" name="'.$name.'_check"> (текущий пароль)<br><br>
		';
	}
	
	$ret .=
	'
	<input class="ainput" type="password" name="'.$name.'"> (пароль)<br>
	<input class="ainput" type="password" name="'.$name.'_verif"> (подтверждение)
	</span>
	<input type="hidden" id="'.$name.'_doch" name="'.$name.'_doch">
	';
	
	return $ret;
}

sub sview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	my ($ret,$do);
	
	if($val)
	{
		$ret = 'Установлен.';
		$do = 'Изменить...';
	}
	else
	{
		$ret = '<span style="color:#ff0000">НЕ УСТАНОВЛЕН.</span>';
		$do = 'Установить...';
	}
	
	$ret .= '
	&nbsp;&nbsp;&nbsp;&nbsp;
	<button onclick="
		'.$name.'_input.style.display = \'inline\';
		'.$name.'_ch.style.display = \'none\';
		'.$name.'_doch.value = \'yes\';
		return false;
		"
	id="'.$name.'_ch">'.$do.'</button>
	<span style="display: none" id="'.$name.'_input"><br>';
	
	if($obj->props()->{$name}{'check'} && $obj->{$name})
	{
		$ret .=
		'
			<input class="ainput" type="password" name="'.$name.'_check"> (текущий пароль)<br><br>
		';
	}
	
	$ret .=
	'
	<input class="ainput" type="password" name="'.$name.'"> (пароль)<br>
	<input class="ainput" type="password" name="'.$name.'_verif"> (подтверждение)
	</span>
	<input type="hidden" id="'.$name.'_doch" name="'.$name.'_doch">
	';
	
	return $ret;
}


sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	unless($r->{$name.'_doch'}){ return $obj->{$name} }
	
	my $verif = $r->{$name.'_verif'};
	
	if($obj->props()->{$name}{'check'} && $obj->{$name})
	{
		if(MD5($r->{$name.'_check'}) ne $obj->{$name})
		{
			$obj->err_add('Текущий пароль введен неверно.');
			return $obj->{$name};
		}
	}
	
	if($val ne $verif)
	{
		$obj->err_add('Введенный пароль и подтверждение не совпадают.');
		return $obj->{$name};
	}
	
	return $val;
}

sub copy { return ''; }


1;