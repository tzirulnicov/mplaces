# (с) Леонов П.А., 2005

package CMSBuilder::DBI::Array::ACore;
use strict qw(subs vars);
use utf8;

sub _add_classes {}
sub _cname {'Массив (ядро)'}
sub _pages_direction {1}

sub _handle_elems {1}

#-------------------------------------------------------------------------------


use CMSBuilder;
use CMSBuilder::Utils;

sub copyto
{
	my $o = shift;
	my $no = shift;
	
	my $ret = $o->CMSBuilder::DBI::Object::copyto($no);
	
	for my $to ($o->get_all())
	{
		$no->elem_paste($to->copy());
	}
	
	return $ret;
}


#——————————————————— Методы реализации полноценного наследования ———————————————

sub pages_direction { return $_[0]->_pages_direction(@_); }

sub add_classes
{
	my $c = ref($_[0]) || $_[0];
	my $buff = $c.'::_add_classes_buff';
	
	if($$buff){ return @$$buff; }
	
	my @t = varr($c, '_add_classes', 0);
	my @res;
	
	for my $v (reverse @t)
	{
		if($v eq '-'){ last; }
		unshift(@res,$v)
	}
	
	$$buff = [@res];
	return @$$buff;
}


#——————————————————————— Методы для работы со страницами ———————————————————————

sub pages
{
	my $o = shift;
	my $len = $o->len();
	
	$len /= $o->array_onpage();
	if($len != int($len)){ $len = int($len); $len++; }
	
	return $len;
}

sub array_onpage
{
	my $o = shift;
	return ($o->{'onpage'} || $CMSBuilder::Config::array_def_on_page);
}

sub get_all
{
	my $o = shift;
	
	return $o->get_all_relation('child');
}

sub get_all_relation
{
	my $o = shift;
	my $type = shift;
	
	return $o->get_relation_interval(1,$o->len,$type);
}

sub get_all_class
{
	my $o = shift;
	
	return $o->get_all($o->get_class_wheresql(@_));
}

sub get_page
{
	my $o = shift;
	my $page = shift;
	
	$page =~ s/\D//g;
	
	if($page < 0){ return (); }
	
	my $ps = $o->pages();
	if($page >= $ps){ $page = $ps - 1; }
	
	my $beg = $o->array_onpage() * $page + 1;
	
	return $o->get_interval($beg,$beg + $o->array_onpage() - 1);
}

sub get_page_class
{
	my $o = shift;
	my $page = shift;
	
	return $o->get_page($page,$o->get_class_wheresql(@_));
}

sub get_class_wheresql
{
	my $o = shift;
	my($where,$cl);
	
	for $cl (@_)
	{
		unless(cmsb_classOK($cl)){ next; }
		$where .= ' CLASS = "'.$cl.'" OR';
	}
	
	if($where)
	{
		$where =~ s/OR$//;
		$where = ' ( '.$where.' ) ';
	}
	
	return $where;
}


#———————————————— Дополнительные методы для работы с элементами ————————————————

sub elem_del
{
	my $o = shift;
	my $eid = shift;
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	my $obj = $o->elem($eid);
	unless($obj){ $o->err_add('Элемент номер '.$eid.' в '.$o->myurl().' не существует.'); return; }
	unless($obj->access('w')){ $o->err_add('У Вас нет разрешения изменять удаляемый элемент.'); return; }
	
	$obj = $o->elem_cut($eid);
	
	if ($o->_handle_elems)
	{
		$obj->del();
	}
	
	$obj = '';
}

sub elem_moveup
{
	my $o = shift;
	my $num = shift;
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
	$o->elem_moveto($num,$num-2);
}

sub elem_movedown
{
	my $o = shift;
	my $num = shift;
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
	$o->elem_moveto($num,$num+1);
}

sub elem_paste
{
	my $o = shift;
	my $po = shift;
	unless($po){ $o->err_add('Попытка вставить undef.'); return; }
	unless($o->access('a')){ $o->err_add('У Вас нет разрешения добавлять в этот элемент.'); return; }
	unless($po->access('w')){ $o->err_add('У Вас нет разрешения изменять вставляемый элемент.'); return; }
	
	unless($o->{'ID'}){ return; }
	
	$o->elem_paste_ref($po);
	
	if ($o->_handle_elems)
	{
		$po->papa_set(ref($o)->new($o->{'SHCUT'} || $o->{'ID'}));
		delete $po->{'_ENUM'};
		
		$po->save();
	}
	
	return 1;
}

sub elem_can_paste
{
	my $o = shift;
	my $po = shift;
	unless($o->access('a')){ return 0; }
	if($o->myurl() eq $po->myurl()){ return 0; }
	#if($po->papa() && $po->papa()->myurl() eq $o->myurl()){ return 0; }
	
	my $papa = $o;
	my $i;
	while($papa = $papa->papa())
	{
		if($papa->myurl() eq $po->myurl()){ return 0; }
		$i++;
		if($i > 50){ return 0; } # Есть залупленные объекты
	}
	
	return $o->elem_can_add(ref($po));
}

sub elem_can_add
{
	my $o = shift;
	my $cn = shift;
	
	#my @ac = map { $_ eq '*'?cmsb_classes():($_ eq '!*'?(map {'!'.$_} cmsb_classes()):$_) } $o->add_classes();
	
	my $f;
	for(reverse $o->add_classes())
	{
		$f = $_ =~ s/^!//?0:1;
		
		if($cn->isa($_) || $_ eq '*' || ($_ eq '.' and ref($o) eq $cn)){ return $f; }
	}
	
	return 0;
}


1;