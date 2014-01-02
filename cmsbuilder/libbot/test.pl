BEGIN{
   push(@INC,'/home/tz/lib');
}
srand();
foreach my $k(1..10){
$rand=int(2000+3000*rand);
$rand=~s/\d{2}$/50/;
print $rand."\n";
}
