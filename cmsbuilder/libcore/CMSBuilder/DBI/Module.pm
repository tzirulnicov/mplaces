# (с) Леонов П.А., 2005

package CMSBuilder::DBI::Module;
use strict qw(subs vars);
use utf8;

sub _cname {'Модуль'}
sub _one_instance {0}	# Если установлено в 1, то нельзя создавать два экземпляра модуля
sub _have_icon {0}
sub _have_funcs {0}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;

sub admin_arrayline
{
	my $o = shift;
	my $a = shift;
	
	unless($a->isa('modRoot')){ return; }
	
	unless($a->access('w')){ return; }
	unless($o->access('w')){ return; }
	
	my $enum = $a->elem_tell_enum($o);
	
	print '<a onclick="return doDel()" href="'.$a->admin_right_href().'&act=cms_array_elem_delete&enum='.$enum.'"><img alt="Удалить" src="img/x.gif"></a>';
	
	print '<img src="img/nx.gif">';
	
	print( ($enum == $a->len())?('<img src="img/nx.gif">'):('<a href="'.$a->admin_right_href().'&act=cms_array_elem_down&enum='.$enum.'"><img alt="Переместить ниже" src="img/down.gif"></a>') );
	print( ($enum == 1)?('<img src="img/nx.gif">'):('<a href="'.$a->admin_right_href().'&act=cms_array_elem_up&enum='.$enum.'"><img alt="Переместить выше" src="img/up.gif"></a>') );
	
	print '<img src="img/nx.gif">';
}

sub have_funcs { return $_[0]->_have_funcs(@_); }

sub install_code
{
	my $mod = shift;
	
	my $mr = modRoot->new(1);
	
	my $to = $mod->cre();
	$to->{'name'} = $mod->cname();
	$to->save();
	
	$mr->elem_paste($to);
}

sub install
{
	my $c = shift;
	
	if($c->mod_is_installed())
	{
		print $c->admin_cname(),' (+)<br>';
		return 0;
	}
	
	$c->install_code();
	print $c->admin_cname(),' (OK)<br>';
	
	return 1;
}

sub mod_is_installed
{
	my $c = shift;
	
	my $mr = modRoot->new(1);
	my @tos = grep {$_->isa($c)} $mr->get_all();
	
	return (@tos > 0);
}

1;