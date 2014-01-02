# (с) Леонов П.А., 2005

package CMSBuilder::VType::date;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType';
# Дата ####################################################

use CMSBuilder::Utils;

sub table_cre {'DATE'}

sub sview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	$val =~ s/\'/\&#039;/g;
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;
	
	return '<input type=text class="dateinput" name="'.$name.'" value="'.$val.'">';
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	my $ret;
	
	my @a = split(/\-/,$val);
	
	unless($val && $val ne '0000-00-00')
	{
		my $nts = NOW();
		$nts =~ m/^(\d\d\d\d)(\d\d)(\d\d)/;
		$a[0] = $1;
		$a[1] = $2;
		$a[2] = $3;
	}
	
	$a[1] =~ s/^0+//;
	$a[2] =~ s/^0+//;
	
	$ret =
	'
	<div style="white-space: nowrap;">
	
	<input style="WIDTH: 25px" type="text" name="'.$name.'_d" id="'.$name.'_d" value="'.$a[2].'">
	<input style="WIDTH: 25px" type="text" name="'.$name.'_m" id="'.$name.'_m" value="'.$a[1].'">
	<input style="WIDTH: 37px" type="text" name="'.$name.'_y" id="'.$name.'_y" value="'.$a[0].'">
	<img style="cursor: pointer" src="icons/calendar.gif" onclick="return OnContext(\''.$name.'_calendar\',event)">
	
	<script language="JavaScript">
	all_menus_static["'.$name.'_calendar"] = 1;
	all_menus["'.$name.'_calendar"] = JCalendar("'.$name.'_d","'.$name.'_m","'.$name.'_y");
	with(all_menus["'.$name.'_calendar"]){  }
	</script>
	
	</div>
	';
	
	return $ret;
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	my $d = $r->{$name.'_d'};
	my $m = $r->{$name.'_m'};
	my $y = $r->{$name.'_y'};
	$val = $y.'-'.($m).'-'.$d;
	return $val;
}

1;
