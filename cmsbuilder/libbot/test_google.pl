BEGIN{
   push(@INC,'/home/tz/lib');
}
use WWW::COM::GOOGLE::MAPS;
use cyrillic qw/koi2win/;
$h=WWW::COM::GOOGLE::MAPS->new();
$h->get_topic(
	ADDRESS=>koi2win('г. Москва ул. Большая Садовая, 5')
);
print $h->{content_point}."!!!".$h->{errmsg};
