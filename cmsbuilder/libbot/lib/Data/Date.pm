package Data::Date;
@ISA=qw(Exporter);
@EXPORT=qw(unix2DosTime);
#@EXPORT_OK=qw{unix2DosTime};
#use FIDO::Functions;

sub getDate{
   shift;
   my $format=shift;
   my ($sec,$min,$hour,$mday,$mon,$year) = (localtime(time))[0,1,2,3,4,5];
   $mon++;
   $year+=1900;
   $format=~s/YYYY/$year/;
   $year=substr($year,2);
   $format=~s/YY/$year/;
   $mon='0'.$mon if length($mon)==1;
   $format=~s/MM/$mon/;
   $mday='0'.$mday if length($mday)==1;
   $format=~s/DD/$mday/;
   $hour='0'.$hour if length($hour)==1;
   $format=~s/HH/$hour/;
   $min='0'.$min if length($min)==1;
   $format=~s/mm/$min/;
   $sec='0'.$sec if length($sec)==1;
   $format=~s/ss/$sec/;
   return $format;
}

sub unix2DosTime{
   my $unixtime= (!$_[0] ? time : shift);
   my ($sec,$min,$hour,$mday,$mon,$year) = (localtime($unixtime))[0,1,2,3,4,5];
   $mon++;
   $year+=1900;
   if ($year<1980){
      $year=1980;
      $mon=1;
      $mday=1;
      $hour=0;
      $min=0;
      $sec=0;
   }
   return (($year - 1980) << 25) | ($mon << 21) | ($mday << 16) |
	($hour << 11) | ($min << 5) | ($sec >> 1);
}

sub isInInterval{
   # Входит ли дата в заданные пределы. Возвращает: "-1" - нет. "1" - да. "0" - ошибка
   # Входные параметры:
   # * Дата
   # * Пределы
   # Пример: Data::Date->inInterval('1.1.2003','23 Jun 1980-4/5/2005');
   my $date=$_[1];
   my ($start_date,$end_date)=split("-",$_[2]);
   my ($start_days,$end_days,$cur_days,$start_year,$end_year,$cur_year)=('','','','','','');
   return 0 if (!Data::Date->check($date) || !Data::Date->check($start_date) || !Data::Date->check($end_date));
   $start_days=Data::Date->date2days($start_date);
   $end_days=Data::Date->date2days($end_date);
   $cur_days=Data::Date->date2days($date);
   $start_year=Data::Date->date2year($start_date);
   $end_year=Data::Date->date2year($end_date);
   $cur_year=Data::Date->date2year($date);
   # Позднее ли текущая дата минимальной из диапазона
   return -1 if ($start_year>$cur_year);
   return -1 if ($start_year==$cur_year && $start_days>$cur_days);
   return -1 if ($end_year<$cur_year);
#print $end_days."|".$cur_days."\n";
   return -1 if ($end_year==$cur_year && $end_days<$cur_days);
   return 1;
}

sub difDates(){
   # Differents from dates in days. Input parameters: date1 and date 2
   # Return values: Value of different or "-1" if error has occured
   my $date1=$_[1];
   my $date2=$_[2];
   return 0 if (!Data::Date->check($date1) || Data::Date->check($date2));
   my $date1_year=Data::Date->date2year($date1);
   my $date2_year=Data::Date->date2year($date2);
   return -1 if ($date1_year<$date2_year);
   my $date1_days=Data::Date->date2days($date1);
   my $date2_days=Data::Date->date2days($date2);
   my $days=$date1_days-$date2_days;
   return -1 if ($days<0);
   return $days;
}

sub subDateDay{
   # Subtraction from date a days. Input parameters: date and days. Return value is date
   my $date=$_[1];
   my $days=$_[2];
   return 0 if (!Data::Date->check($date));
   my $year=Data::Date->date2year($date);
   $date=Data::Date->date2days($date);
   return Data::Date->days2date(($date-$days),$year);
}

sub plusDateDay{
   # Subtraction from date a days. Input parameters: date and days. Return value is date
   my $date=$_[1];
   my $days=$_[2];
   return 0 if (!Data::Date->check($date));
   my $year=Data::Date->date2year($date);
   $date=Data::Date->date2days($date);
   return Data::Date->days2date(($date+$days),$year);
}

sub date2year{
   # Return a year from date
   my $year;
   return 0 if ($_[1]!~/(\d+)\D{1,1}([\d]+|[\w]+)\D{1,1}(\d+)/);
   $year=$3;
   $year+=2000 if length($year)==2;
   return $year;
}

sub days2date{
   # Input parameters: days and year
   my $days=$_[1];
   my $year=$_[2];
   return "31.12.".($year-1) if !$days;
   my $curMonth=1;      
   my $dayInMonth;
   my $increment=($days>=0?1:0);
   my $curDay=($increment?0:1);
   $year+=2000 if length($year)==2;
   while ($days){
      $dayInMonth=Data::Date->daysInMonth($curMonth,$year);
      if ($increment){
	 if ($days-$dayInMonth>0){
	    $days-=$dayInMonth;
	    $curDay=0;
	    $curMonth++;
	 }
	 else {
	    $curDay+=$days;
	    $days=0;
	 }
	 if ($curMonth==13){
	    $curMonth=1;
	    $year++;
	 }
      }
      else {
	 if ($curDay==1 && $days+$dayInMonth<0){
	    $days+=$dayInMonth;
	    $curDay=$dayInMonth;
	    $curMonth--;
	 }
	 else {
	    $dayInMonth=Data::Date->daysInMonth(($curMonth-1==0?12:$curMonth-1),$year);
	    $curDay=$dayInMonth+$days;
	    $curMonth--;
	    $days=0;
	 }
	 if ($curMonth==0){
	    $curMonth=12;
	    $year--;
	 }
      }
   }
   return $curDay.'.'.$curMonth.'.'.$year.'';
}

sub curDate{
   my ($mon,$year,$mday)=(localtime(time))[4,5,3];
   return $mday.'.'.(++$mon).'.'.($year+1900);
}

sub daysInMonth{
   return ($_[2]%4==0?29:28) if $_[1]==2;
   return 30 if ($_[1]==4 || $_[1]==6 || $_[1]==9 || $_[1]==11);
   return 31 if ($_[1]==1 || $_[1]==3 || $_[1]==5 || $_[1]==7 || $_[1]==8 || $_[1]==10 || $_[1]==12);
   return 0;
}

sub date2days{
   # Convert date in number of days since the start of year
   my $days=0;
   return 0 if ($_[1]!~/(\d+)\D{1,1}([\d]+|[\w]+)\D{1,1}(\d+)/);
   my ($day,$month,$year)=($1,$2,$3);
   $year+=2000 if length($year)==2;
   my $dayInMonth=0;
   my $curMonth=1;
   $month=Data::Date->monthName2Number($month) if $month=~/\D+/;
   return 0 if !$month;
   while ($curMonth<$month){
      $dayInMonth=Data::Date->daysInMonth($curMonth,$year);
      $days+=$dayInMonth;
      $curMonth++;
   }
   $days+=$day;
   return $days;
}

sub check{
   # Return values: "0" - date is incorrect, "1" - OK
   if ($_[1]=~/(\d+)\D{1,1}([\d]+|[\w]+)\D{1,1}(\d+)/){
      my $day=$1;
      my $month=$2;
      my $year=$3;
      return 0 if (length($year)!=4 && length($year)!=2);
      $year+=2000 if length($year)==2;
      $month=Data::Date->monthName2Number($month) if $month=~/\D+/;
      return 0 if (!$month || $month>12);
      return 0 if (($day>29 && $month==2) || (!$year%4 && $month==2 && $day>28));
      return 0 if ($day>30 && ($month==4 || $month==6 || $month==9 || $month==11));
      return 0 if ($day>31 && ($month==1 || $month==3 || $month==5 || $month==7 || $month==8 || $month==10 || $month==12));
      return 1;
   }
   return 0;
}

sub monthName2Number{
   return 1 if $_[1]=~/^Jan/i;
   return 2 if $_[1]=~/^Feb/i;
   return 3 if $_[1]=~/^Mar/i;
   return 4 if $_[1]=~/^Apr/i;
   return 5 if $_[1]=~/^May/i;
   return 6 if $_[1]=~/^Jun/i;
   return 7 if $_[1]=~/^Jul/i;
   return 8 if $_[1]=~/^Aug/i;
   return 9 if $_[1]=~/^Sep/i;
   return 10 if $_[1]=~/^Oct/i;
   return 11 if $_[1]=~/^Nov/i;
   return 12 if $_[1]=~/^Dec/i;
   return 0;
}

sub number2monthName{
   return 'Jan' if (@_[1]==1);
   return 'Feb' if (@_[1]==2);
   return 'Mar' if (@_[1]==3);
   return 'Apr' if (@_[1]==4);
   return 'May' if (@_[1]==5);
   return 'Jun' if (@_[1]==6);
   return 'Jul' if (@_[1]==7);
   return 'Aug' if (@_[1]==8);
   return 'Sep' if (@_[1]==9);
   return 'Oct' if (@_[1]==10);
   return 'Nov' if (@_[1]==11);
   return 'Dec';
}

1;
