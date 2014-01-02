package cyrillic;
use Encode;
sub utf2win{
   my $str=shift;
   Encode::from_to($str,'cp1251','utf-8');
   return $str;
}
1;
