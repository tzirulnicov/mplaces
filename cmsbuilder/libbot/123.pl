#!/usr/bin/perl
open(FILE,'/www/gogasat/headcall.ru/htdocs/comments.txt') or die $!;
 while(<FILE>){
print "456";
   if ($_=~/^time\=(\d+)$/){
print "123";
      $tm=$1;
   }
   elsif ($_=~/^ID\=\d+\, /){
      push(@file_ar,$_);
   } else {
      $fle_ar[$#fle_ar].=123#$_;
   }
}
close(FILE);
