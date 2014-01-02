($day,$month,$year)=(localtime(time))[3,4,5];
$month++;
$year+=1900;
$day=sprintf("%02d",$day);
$month=sprintf("%02d",$month);
print "$day|$month|$year\n";


