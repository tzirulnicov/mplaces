#!/usr/bin/perl
use DBI;
use CGI::Carp qw/fatalsToBrowser/;
require "/www/gogasat/headcall.ru/cmsbuilder/Config.pm";
print "Content-type: text/xml; charset=windows-1251\n\n";
my $dbh=DBI->connect($CMSBuilder::Config::mysql_data_source,
	$CMSBuilder::Config::mysql_user,$CMSBuilder::Config::mysql_pas) or die $DBI::errstr;
my $dbs=$dbh->prepare('SELECT h.id,h.location,p.name from dbo_Hotel as h,
	dbo_Page as p where h.rekomenduem=1 and h.location<>"" and p.ID=h
.PAPA_ID');
$dbs->execute();
my $count=0;
my $row;
print "<m>\n";
while($row=$dbs->fetchrow_hashref){
   print "   <m id=\"$row->{id}\" location=\"$row->{location}\"/>\n";
   $count++;
}
print "   <info count=$count/>\n</m>\n";
$dbh->disconnect();
print $CMSBuilder::Config::path_htdocs;
