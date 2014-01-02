# (с) http://www.technocat.ru/
package GoogleMapPoint;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::DBI::Array plgnSite::Object);

sub _cname {'Точка'}
sub _aview {qw/name location link descr img/}
sub _add_classes {qw/!*/}
sub _have_icon {0}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => 'Имя' },
	'location'	=> { 'type' => 'GoogleMarker', 'name' => 'Координаты'},
	'link'		=> { 'type' => 'string', 'length' => 100, 'name' => 'Ссылка на страницу' },
	'descr'		=> { 'type' => 'miniword', 'name' => 'Краткое описание'},
	'img'		=> { 'type' => 'img', 'msize' => 9999, 'name' => 'Картинка' }
}

#———————————————————————————————————————————————————————————————————————————————

#sub site_content
#{
#	my $o = shift;
#	my $r = shift;
#	
#	my $href = '';
#	$href = ' href="' . $o->papa->elem($o->enum + 1)->site_href . '" title="Следующая фотография…"' if $o->papa && $o->enum < $o->papa->len;
#	print '<a' . $href . '><img src="' . $o->{'photo'}->href . '"/></a>';
#
#	#выведем ссылочку на предыдущий объект, если он, конечно, существует
#	print '<a href="' . $o->papa->elem($o->enum - 1)->site_href . '" title="Предыдущая фотография…">&larr;</a>'
#		if $o->enum > 1;
#		
#	#выведем ссылочку на следующий объект, если он, конечно, существует
#	print '<a href="' . $o->papa->elem($o->enum + 1)->site_href . '" title="Следующая фотография…">&rarr;</a>'
#		if $o->papa && $o->enum < $o->papa->len;
#	
#	#map { map { $_->site_content } grep { !$_->{hidden} } $_->get_all() } grep { !$_->{hidden} } $o->get_all();
#	
#	return;
#}
#
#sub site_preview
#{
#	my $o = shift;
#	
#	my $photo_href;
#	if ($o->{'smallphoto'} && $o->{'smallphoto'}->exists)
#	{
#		$photo_href = $o->{'smallphoto'}->href;
#	}
#	
#	#my $photo = $photo_href ? '<a href="' . $o->site_href . '"><img class="photo" src="' . $photo_href . '"></a>' : undef;
#	
#	print '<a href="' . $o->site_href . '" class="photopreview" style="background-image: url(' . $photo_href . ')"></a>';
#	
#	return;
#}

1;
