# (с) Леонов П.А., 2005

package CMSBuilder::VType::ClassesList;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::VType);

#—————————————————————————————————— Список —————————————————————————————————————

use CMSBuilder;

sub table_cre
{
	return " VARCHAR(50) ";
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	if($p->{$name}{'once'} && $val)
	{
		return
		'
		<select disabled>
			<option>'.$val->cname().'</option>
		</select>
		';
	}
	
	my $ret = '<select name="'.$name.'">';
	
	unless($val){ $ret .= '<option value="" selected>'.$p->{$name}{'nulltext'}.'</option>'; }
	elsif($p->{$name}{'isnull'}){ $ret .= '<option value="">'.$p->{$name}{'nulltext'}.'</option>'; }
	
	for my $cn (grep {$_->isa($p->{$name}{'class'})} cmsb_classes())
	{
		$ret .= '<option'.($cn eq $val?' selected':'').' value="'.$cn.'">'.$cn->cname().'</option>';
	}
	
	$ret .= '</select>';
	
	return $ret;
}

sub sview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	if($p->{$name}{'once'} && $val)
	{
		return
		'
		<select disabled>
			<option>'.$val->cname().'</option>
		</select>
		';
	}
	
	my $ret = '<select name="'.$name.'">';
	
	unless($val){ $ret .= '<option value="" selected>'.$p->{$name}{'nulltext'}.'</option>'; }
	elsif($p->{$name}{'isnull'}){ $ret .= '<option value="">'.$p->{$name}{'nulltext'}.'</option>'; }
	
	for my $cn (grep {$_->isa($p->{$name}{'class'})} cmsb_classes())
	{
		$ret .= '<option'.($cn eq $val?' selected':'').' value="'.$cn.'">'.$cn->cname().'</option>';
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
	return unless cmsb_classOK($val) && $val->isa($p->{$name}{'class'});
	
	return $val;
}

1;