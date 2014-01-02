#!/usr/bin/perl
use Time::Local;
$zayezd='2009-02-01';
$otyezd='2009-03-01';
@zayezd=split('-',$zayezd);
$zayezd[1]--;
$zayezd[0]-=1900;
@otyezd=split('-',$otyezd);
$otyezd[1]--;
$otyezd[0]-=1900;
$days = (timelocal(0,0,0,$otyezd[2],$otyezd[1],$otyezd[0])-
	timelocal(0,0,0,$zayezd[2],$zayezd[1],$zayezd[0]))/86400;
#print timelocal(0,0,0,$zayezd[2],$zayezd[1],$zayezd[0]);
print "$days\n";

