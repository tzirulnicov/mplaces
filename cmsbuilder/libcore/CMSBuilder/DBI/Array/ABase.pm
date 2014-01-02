# (с) Леонов П.А., 2005

package CMSBuilder::DBI::Array::ABase;
use strict qw(subs vars);
use utf8;

#———————————————————————————————————————————————————————————————————————————————

use CMSBuilder;
use CMSBuilder::DBI;
use CMSBuilder::IO;
use CMSBuilder::Utils;

sub get_interval
{
	my $o = shift;
	my $beg = shift;
	my $end = shift;
	
	
	return $o->get_relation_interval($beg,$end,'child');
}

sub elem_paste_ref
{
	my $o = shift;
	my $po = shift;
	
	
	return $o->elem_relation_paste_ref($po,'child');
}

sub elem_tell_enum
{
	my $o = shift;
	my $to = shift;
	
	return $o->elem_relation_tell_enum($to,'child');
}

sub elem_relation_tell_enum
{
	my $o = shift;
	my $to = shift;
	my $type = shift;
	
	unless($o->access('r')){ $o->err_add('У Вас нет разрешений просматривать этот элемент.'); return 0; }
	unless($o->{'ID'}){ return 0; }
	
	my $str = $dbh->prepare('SELECT num FROM `relations` WHERE aurl = ? AND ourl = ? AND type = ? LIMIT 1');
	$str->execute($o->myurl, $to->myurl, $type);
	
	my ($res) = $str->fetchrow_array();
	
	return $res || 0;
}

sub elem
{
	my $o = shift;
	my $enum = shift;

	
	my ($to) = $o->get_interval($enum,$enum);
	
	unless($to)
	{
		Carp::carp('Trying to get not existed element "' . $enum . '", from "' . $o->myurl . '"');
	}
	
	return $to;
}

sub elem_cut
{
	my $o = shift;
	my $eid = shift;
	
	return $o->elem_relation_cut($eid,'child');
}

sub elem_relation_cut
{
	my $o = shift;
	my $eid = shift;
	my $type = shift;
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
	unless($o->{'ID'}){ return; }
	
	my $to = $o->elem($eid);
	unless($to){ return undef; }
	
	if ($o->_handle_elems)
	{
		delete $to->{'_ENUM'};
		
		unless($to->access('w')){ $o->err_add('У Вас нет разрешения изменять вырезаемый элемент.'); return; }
	}
	
	$dbh->do('LOCK TABLES `relations` WRITE');
	$dbh->do('DELETE FROM `relations` WHERE aurl = ? AND num = ? AND type = ? LIMIT 1', undef, $o->myurl, $eid, $type);
	$dbh->do
	(
		'UPDATE `relations` SET num = num - 1 WHERE aurl = ? AND num > ? AND type = ?',
		undef, $o->myurl, $eid, $type
	);
	$dbh->do('UNLOCK TABLES');
	
	return $to;
}


sub elem_moveto
{
	my $o = shift;
	my $enum = shift;
	my $place = shift;
	
	return $o->elem_relation_moveto($enum,$place,'child');
}

sub elem_relation_moveto
{
	my $o = shift;
	my $enum = shift;
	my $place = shift;
	my $type = shift;
	if(!$o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
	unless($o->{'ID'}){ return; }
	
	if($place eq ''){ $o->err_add('Новая позиция пуста.'); return; }
	if($place < 0){ $o->err_add('Новая позиция меньше 1.'); return; }
	#if($place == $enum){ $o->err_add('Новая позиция равна старой.'); return; }
	if($place > $o->len()){ $o->err_add('Новая позиция больше или равна количеству элементов ('.$place.').'); return; }
	
	my $elem = $o->elem($enum);
	unless($elem){ $o->err_add('Указанный элемент не существует (' . $enum . ').'); return; }
	
	
	my $str = $dbh->prepare('UPDATE `relations` SET num = ? WHERE aurl = ? AND num = ? AND type = ? LIMIT 1' );
	
	$dbh->do('LOCK TABLES `relations` WRITE');
	
	$str->execute(0, $o->myurl, $enum, $type);
	$dbh->do('UPDATE `relations` SET num = num - 1 WHERE aurl = ? AND num > ? AND type = ?', undef, $o->myurl, $enum, $type);
	$dbh->do('UPDATE `relations` SET num = num + 1 WHERE aurl = ? AND num >= ? AND type = ?', undef, $o->myurl, $place, $type);
	$str->execute($place, $o->myurl, 0, $type);
	
	$dbh->do('UNLOCK TABLES');
}



#——————————————— Методы для непосредственной работы с Базой Данных —————————————

sub len
{
	my $o = shift;
	
	return $o->len_relation('child');
}

sub del
{
	my $o = shift;
	
	unless($o->{'ID'}){ return; }
	
	my $papa = $o->papa();
	
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
	unless($o->{'SHCUT'})
	{
		for (reverse 1 .. $o->len){ $o->elem_del($_); }
	}
	
	return $o->CMSBuilder::DBI::Object::del();
}

sub reverse
{
	my $o = shift;
	
	return $o->reverse_relation('child');
}

sub reverse_relation
{
	my $o = shift;
	my $type = shift;
	
	$dbh->do('UPDATE `relations` SET num = ' . $o->len . ' - num + 1 WHERE aurl = ? AND type = ?', undef, $o->myurl, $type);
}


#—————————————————————— Методы использующиеся при сортировке ———————————————————




1;