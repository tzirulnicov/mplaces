# (c) Vadim Tzirulnicov, 2008

package CMSBuilder::VType::McwSelect;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType';
# Тег ###################################################

use CMSBuilder;


our $filter = 1;

sub table_cre {'BOOL'}


sub filter_load
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	# return $val;
	return [grep { $_ } map { cmsb_url($_) } split / /, $val ];
}

sub filter_save
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	if(ref $val)
	{
		return join ' ', map { $_->myurl() } @$val;
	}
	
	return '';
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	#### вводим сами ####
	#return '<input type="text" name="' . $name . '" value="">' unless ref $obj->{$name};
	#return '<input type="text" name="' . $name . '" value="' . (join ', ', map { $_->name() } @{$obj->{$name}}) . '">';
	####################
	
	#### выбираем чекбоксами ####
	my @tags = modMultiCatWare->new(1)->get_all();
	my $cbs;
	if($val){$val = 'checked'}
	
	
	map { $cbs .= '<option value="' . $_->{ID} . '"' . ($_->{ID}==$obj->{mcw_id}?' selected':'') . '/>' . $_->name().'</option>' } grep{!$_->{hidden}} @tags;
	return '<select name="mcw_id"><option value=0>Сотовый телефон</option>'.$cbs.'</select>';
}

sub sview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	return '<input type="text" name="' . $name . '" value="">' unless ref $obj->{$name};
	
	return '<input type="text" name="' . $name . '" value="' . (join ', ', map { $_->name() } @{$obj->{$name}}) . '">';
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	return;
	my @stags;
	
	my @alltags = modMultiCatWare->all();
	
	map { push @stags, $_->name() if $r->{$_->myurl} } @alltags;
	
	$val = join ', ', @stags;
	
	map { $_->elem_relation_del($obj,'tag') } modMultiCatWare->all();

	return [] unless $val;
	
	@stags = split /\s*,\s*/, $val;
=head
	my @tags;

	for (@stags)
	{
		my ($tag) = ExportList->find('name = ?', $_);
		if ($tag)
		{
			push @tags, $tag;
			$tag->elem_relation_del($obj,'tag');
			$tag->elem_relation_paste_ref($obj,'tag');
		}
		else
		{
			my $to = ExportList->cre();
			$to->{name} = $_;
			$to->save();
			modMarket->new(1)->elem_paste($to);
			
			$to->elem_relation_paste_ref($obj,'tag');
			
			push @tags, $to;
		}
	}
	return \@tags;
=cut
}

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
