package Data::DB;
sub start{
   my $class=shift;
   my $dbfile=shift;
   my $self={};
   $self->{dbfile}=$dbfile;
   if (!-e $dbfile){
      open(DB,">$dbfile") or die("Cannot write '$dbfile': $!");
      close(DB);
   }
   #my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
   ($self->{mday},$self->{mon},$self->{year},$self->{yday})=(localtime(time))[3,4,5,7];
   $self->{mon}++;
   $self->{year}+=1900; 
   $self->{writeRequired}=0;
   open(DB,$self->{dbfile}) or die("Cannot open $!");
   my @db=<DB>;
   close(DB);
   foreach my $value(@db){
      $value=~s/[\r\n]//g;
      $self->{content}{substr($value,0,index($value,'|'))}=substr($value,index($value,'|')+1);
   }
   bless $self, $class;
}
sub checkDate{
   my $self=shift;
   my $days=shift;
   my $key=shift;
   return 1 if !$key;
   my $lineYDay=substr($self->{content}->{$key},rindex($self->{content}{$key},':')+1);
   $lineYDay+=0;
   my $lineYear=substr($self->{content}->{$key},rindex($self->{content}{$key},'.')+1,rindex($values{'lastUpdate'},':')-rindex($values{'lastUpdate'},'.')-1);
   $lineYear+=0;
   # Если с момента последнего постинга в данную эху правил прошло более 7 недель...
   if (($lineYear==$self->{year} && $lineYDay+$days<=$self->{yday}) ||
	($lineYear!=$self->{year} && $self->{year}-$lineYear>1) ||
	($lineYear+1==$self->{year} && $lineYDay+$days<=$self->{yday}+$lineYDay)){
	$self->{content}{$key}=$self->{mday}.'.'.$self->{mon}.'.'.$self->{year}.':'.$self->{yday};
      $self->{writeRequired}=1;
      return 1;
   }
   return 0;
}
sub end{
   my $self=shift;
   my @db;
   my $hash=\$self->{content};
   if ($self->{writeRequired}){
      @db=();
      foreach my $key(keys %{$$hash}){
         push(@db,$key.'|'.$self->{content}{$key});
      }
      open(DB,">".$self->{dbfile}) or die "Cannot write $!";
      print DB join("\n",@db);
      close(DB);
   }
}
1;