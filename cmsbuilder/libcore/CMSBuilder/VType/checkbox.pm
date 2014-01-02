# (с) Леонов П.А., 2005

package CMSBuilder::VType::checkbox;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType';

#———————————————————————————————————— Галочка ——————————————————————————————————

our $admin_own_html = 1;

sub table_cre
{
	return ' INT(1) ';
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	if($val){$val = 'checked'}
	
	my $ret = '
		<tr>
			<td></td>
			<td valign=top>
				<input id="checkbox_'.$name.'" type="checkbox" name="'.$name.'" '.$val.'><label for="checkbox_'.$name.'">'.$p->{$name}{'name'}.'</label>
			</td>
		</tr>
	';
	
	return $ret;
}

sub sview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	return $val ? 'да' : 'нет';
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	if($val){$val = 1}
	
	return $val;
}

1;