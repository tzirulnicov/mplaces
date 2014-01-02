# (с) Леонов П.А., 2005

package CMSBuilder::VType::ExportTo;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType';
# Тег ###################################################

use CMSBuilder;


our $filter = 1;

sub table_cre {'VARCHAR(255)'}


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

sub checked
{
	my $tag = shift;
	my $obj = shift;
	my $name = shift;

	map { return 'checked' if $_->myurl eq $tag } @{$obj->{$name}};
	return;
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
	my @tags = modMarket->new(1)->get_all();
	my $cbs;
	if($val){$val = 'checked'}
	
	
	map { $cbs .= '<label style="display: table; float:left; margin: 5px;" for="' . $_->name() . '"><input type="checkbox" name="' . $_->myurl . '" id="' . $_->name() . '" ' . checked($_->myurl, $obj, $name) . '/>' . $_->name() . '</label>' } grep{!$_->{hidden}} @tags;
	return $cbs;
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
	
	my @stags;
	
	my @alltags = modMarket->new(1)->get_all();
	
	map { push @stags, $_->name() if $r->{$_->myurl} } @alltags;
	
	$val = join ', ', @stags;
	
	map { $_->elem_relation_del($obj,'tag') } modMarket->new(1)->get_all();

	return [] unless $val;
	
	@stags = split /\s*,\s*/, $val;

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