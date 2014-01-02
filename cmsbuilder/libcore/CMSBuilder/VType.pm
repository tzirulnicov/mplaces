# (с) Леонов П.А., 2005

# Базовый класс для вируальных типов.
package CMSBuilder::VType;
use strict qw(subs vars);
use utf8;


our $filter;			# При загрузке этого виртуального типа, полю будет присвоено
					# автоматическое значение ( ф-ции filter_in() и filter_out() )

our $virtual;			# Не имеет столбца в таблице

our $admin_own_html;		# aview() возвращает не значение, а весь HTML код.
					# Пример: CMSBuilder::VType::miniword

our $property;			# чтение и запись переадресуется методам (как в Delphi)
					# (не реализовано)

#———————————————————————————————————————————————————————————————————————————————


sub table_cre
{
	return ' VARCHAR(255) ';
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	$val =~ s/\&/\&amp;/g;
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;
	
	return '<input type="text" class="winput" name="'.$name.'" value="'.$val.'">';
}

sub sview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	$val =~ s/\&/\&amp;/g;
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;
	
	return $val;
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	return $val;
}

#———————————————————————————————————————————————————————————————————————————————

sub prop_read
{
	my $c = shift;
	my ($name,$obj) = @_;
	
	return $obj->{$name.'_real'};
}

sub prop_write
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	return $obj->{$name.'_real'} = $val;
}

#———————————————————————————————————————————————————————————————————————————————


sub filter_insert
{
	my $c = shift;
	my $name = shift;
	
	return;
}

sub filter_load
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	return $val;
}

sub filter_save
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	return $val;
}


#———————————————————————————————————————————————————————————————————————————————

sub del
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
}

sub copy
{
	my $c = shift;
	my ($name,$val,$obj,$nobj) = @_;
	
	return $val;
}


1;