# (с) Леонов П.А., 2005

package CMSBuilder::DBI::SimpleModule;
use strict qw(subs vars);
use utf8;

our @ISA =
(
	'CMSBuilder::DBI::Module',
	'CMSBuilder::DBI::Object::ONoBase',
	'CMSBuilder::DBI::Object'
);

sub _one_instance {1}
sub _cname {'Простой базовый модуль'}
sub _simplem_menu {}

# Простой модуль, состоит из функций (не содержит дерева)

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;
use CMSBuilder::Utils;

sub simplem_menu
{
	my $o = shift;
	my $buff = ref($o).'::_simplem_menu_buff';
	
	if($$buff){ return $$buff; }
	
	$$buff = {varr(ref($o),'_simplem_menu')};
	return $$buff;
}

sub name { return $_[0]->_cname(@_); }

sub smodule_make_tree
{
	my $o = shift;
	my $obj = shift;
	
	my $ret;
	
	if($obj->{'-obj'})
	{
		my $to = ref($obj->{'-obj'})?$obj->{'-obj'}:cmsb_url($obj->{'-obj'});
		$ret = {-name => $to->admin_name(), -id => $o->myurl().'_'.$to->myurl()};
	}
	elsif($obj->{'-sub'})
	{
		$ret = {-name => $o->name(), -id => $o->myurl().'_'.lc($obj->{'-sub'}), $obj->{'-sub'}->($o,$obj)};
	}
	else
	{
		my $name = CMSBuilder::IO::GUI::admin_name_ex
		(
			-name	=> $obj->{'-name'},
			-href	=> $o->admin_right_href().'&act='.$obj->{'-func'},
			-icon	=> $obj->{'-icon'} || 'icons/default.gif',
			-selid	=> 'id_'.$o->myurl().'_'.$obj->{'-func'}
		);
		
		$ret = {-name => $name, -id => $o->myurl().'_'.$obj->{'-func'}};
	}
	
	if($obj->{'-sas'})
	{
		for my $to (@{$obj->{'-sas'}})
		{
			push @{$ret->{'-elems'}},$o->smodule_make_tree($to);
		}
	}
	
	return $ret;
}

sub smodule_func_tree
{
	my $o = shift;
	my $c = ref($o) || $o;
	
	my $buff = ref($o).'::_smodule_func_tree_buff';
	if($$buff){ return $$buff; }
	
	my $smm = $o->simplem_menu();
	
	my $fs = {%$smm};
	
	for my $val (values %$fs)
	{
		if($val->{'-papa'} && !$val->{'-hide'})
		{
			push @{$fs->{$val->{'-papa'}}->{'-sas'}}, $val;
		}
	}
	
	for my $key (keys %$fs)
	{
		$fs->{$key}->{'-func'} = $key;
		
		if($fs->{$key}->{'-papa'} || $fs->{$key}->{'-hide'})
		{
			delete $fs->{$key};
		}
	}
	
	$$buff = {-sas => [values %$fs]};
	
	return $$buff;
}

sub admin_view_left
{
	my $o = shift;
	
	my $tree = $o->smodule_make_tree($o->smodule_func_tree());
	my $norooticon;
	
	if($o->isa('CMSBuilder::DBI::TreeModule'))
	{
		$norooticon = 1;
		$tree->{'-id'} = $o->myurl().'_func';
	}
	else
	{
		$tree->{'-name'} = $o->admin_name();
		$tree->{'-id'} = $o->myurl();
	}
	
	$tree->{'-root'} = 1;
	
	print
	'
		<div class="togpanell">
			<div class="content">',CMSBuilder::IO::GUI::tree_build($tree, -norooticon => $norooticon),'</div>
		</div>
	';
}

sub admin_path_html
{
	my $o = shift;
	my $r = shift;
	
	my $ret = $o->SUPER::admin_path_html(@_);
	
	unless($r->{'act'}){ return $ret; }
	
	my $rpcf = $o->simplem_menu();
	my $func = $r->{'act'};
	
	unless(exists $$rpcf{$func}){ return $ret; }
	
	return $ret.' / '.$o->admin_cname($rpcf->{$func}->{'-name'},$o->admin_right_href().'&act='.$func,'admin_right',$rpcf->{$func}->{'-icon'}||'icons/default.gif');
}

sub admin_path_js
{
	my $o = shift;
	my $r = shift;
	
	$o->SUPER::admin_path_js(@_);
	
	print 'parent.admin_left.CMS_SelectLO("id_'.$o->myurl().'_'.$r->{'act'}.'");';
	print 'parent.admin_left.CMS_ShowMe("'.$o->myurl().'_'.$r->{'act'}.'");';
}

sub default { print 'Приветствие простого модуля.'; }

1;