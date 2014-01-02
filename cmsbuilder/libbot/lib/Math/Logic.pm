package Math::Logic;
use Exporter;
use string;
@ISA=qw(Exporter);
@EXPORT=qw(dechex sumhex floor round ceil);
#@EXPORT_OK=qw($fromName $fromAddress $toName $toAddress $date $subject $text);
sub ceil{
   # ¬озвращает ближайшее целое число, большее аргумента
   my $num=shift;
   $num++;
   $num=(split('\.',$num))[0];
   return $num;
}
sub dechex{
#ѕереводит числа из дес€тичной системы счислени€ в шестнадцатиричную
   my $m=@_[0];
   my $m2='';
   my $m3=0;
   while ($m>=16){
      $m3=($m%16).'';
      $m2.=replace(replace(replace(replace(replace(replace($m3,"/10/","A"),"/11/","B"),"/12/","C"),"/13/","D"),"/14/","E"),"/15/","F");
      $m=floor($m/16);
   }
   $m.='';
   $m2.=replace(replace(replace(replace(replace(replace($m,"/10/","A"),"/11/","B"),"/12/","C"),"/13/","D"),"/14/","E"),"/15/","F");
   return reverseString($m2);
}

sub sumhex{
#¬ыполн€ет сложение шестнадцатиричных чисел
   my $s=@_[0];
   my $retvl=0;
   @s=split(/\+/,$s);
   for ($sm=0;$sm<scalar(@s);$sm++){
      $retvl+=hex($s[$sm]);
   }
   return dechex($retvl);
}
sub floor{
   my $var=@_[0];
   $var.='';
   @var=split(/\./,$var);
   return $var[0];
}
sub round{
   my $var=@_[0];
   $var.='';
   @var=split(/\./,$var);
   if (substr($var[1],0,1)=~/[5-9]/){
      $var[0]++;
   }
   return $var[0];
}
=head
function ceblen(ll){
if (!isNaN(ll)){
ll+='';}
return ll.length;}
function math16_2(mth){
//ѕереводит числа из шестнадцатиричной системы счислени€ в двоичную
mth=mth.split(''), armth=new Array('0|0000','1|0001','2|0010','3|0011','4|0100','5|0101',
'6|0110','7|0111','8|1000','9|1001','A|1010','B|1011','C|1100','D|1101','E|1110','F|1111');
for (amth=0;amth<mth.length;amth++){
for (bmth=0;bmth<armth.length;bmth++){
if (mth[amth].toUpperCase()==armth[bmth].split('|')[0]){
mth[amth]=armth[bmth].split('|')[1];
break;}}}
return mth.join('');}
=cut