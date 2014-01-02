@ar=(1,2,3);
$t{k}=\@ar;
@ar2=@{$t{k}};
#print join(',',@ar2);
print join(',',@{$t{k}});
exit;
@ar=view_synonim('Сайт является привелигированным участником
 <a href=http://www.headcall.ru/>службы бронирования {отелей|гостиниц}
 {Петербурга|Санкт-Петербурга} headcall.ru</a>',0,0);
print $ar[0];
view_synonim('Информацию о нашем сайты вы также можете найти на 
страницах <a href=http://www.headcall.ru/>сервиса бронирования 
{гостиниц|отелей} {Петербурга|Санкт-Петербурга} headcall.ru</a>');
view_synonim('Рекомендации нашей гостиницы вы можете посмотреть 
<a href=http://www.headcall.ru/>на сайте {гостиниц|отелей} 
{Петербурга|Санкт-Петербурга} headcall.ru</a>');
view_synonim('Наш отель добавлен в базу данных 
<a href=http://www.headcall.ru/>{лучших|рекомендованных} {гостиниц|отелей} 
{Петербурга|Санкт-Петербурга} headcall.ru</a>');
view_synonim('Описания и рекомендации отеля представлены 
<a href=http://www.headcall.ru/>в {каталоге|справочнике} 
{гостиниц|отелей} {Петербурга|Санкт-Петербурга} headcall.ru</a>');
view_synonim('Отель состоит в числе рекомендованных участников 
<a href=http://www.headcall.ru/>системы бронирования {отелей|гостиниц} 
Петербурга|Санкт-Петербурга} headcall.ru</a>');
sub view_synonim{
   my $text=shift;
   my @val=@_;
   my ($tmp,$rnd,@res);#res-какие номера подстановок были выбраны
   while($text=~/\{([^\|]+)\|([^\|]+)\}/){
      $rnd=($#val!=-1?shift @val:sprintf("%.0f",rand()));
      $tmp=($1,$2)[$rnd];
      $text=~s/\{[^\|]+\|[^\|]+\}/$tmp/;
      push(@res,$rnd);
   }
   return ($text,@res);
}


