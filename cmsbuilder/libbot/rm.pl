#!/usr/bin/perl
if (!-d $ARGV[0] || $ARGV[0]!~/cache/){
   print "rm: $ARGV[0]: No such directory\n";
   exit(0);
}
my $fl;
opendir(DIR,$ARGV[0]);
while ($fl=readdir(DIR)){
   next if $fl eq '.' or $fl eq '..';
   if (!unlink("$ARGV[0]/$fl")){
      print "rm: $ARGV[0]: delete file $fl fault\n";
   }
   print "Delete $fl successful\n";
}
closedir(DIR);

