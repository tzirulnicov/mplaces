# (с) Леонов П.А., 2005

package CMSBuilder::DBI;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::Plugin Exporter);

use DBI;
use Carp;
use Exporter;

our @EXPORT = qw($dbh);

require CMSBuilder::DBI::Object::OBase;
require CMSBuilder::DBI::Object::ONoBase;
require CMSBuilder::DBI::Object::OCore;
require CMSBuilder::DBI::Object::OAdmin;
require CMSBuilder::DBI::Object;

require CMSBuilder::DBI::Array::ABase;
require CMSBuilder::DBI::Array::ACore;
require CMSBuilder::DBI::Array::AAdmin;
require CMSBuilder::DBI::FilteredArray;
require CMSBuilder::DBI::Array;

require CMSBuilder::DBI::RPC;
require CMSBuilder::DBI::EventsInterface;
require CMSBuilder::DBI::CMS;
require CMSBuilder::DBI::Module;
require CMSBuilder::DBI::SimpleModule;
require CMSBuilder::DBI::TreeModule;

use CMSBuilder;
use CMSBuilder::Utils;


#———————————————————————————————————————————————————————————————————————————————

our
(
	$dbh,%cmenus,
);

#————————————————————————————— Интерфейсные функции ————————————————————————————

sub plgn_init
{
	my $c = shift;
	
	if($CMSBuilder::Config::dbi_keepalive && $dbh)
	{
		$c->fix_connection();
	}
	else
	{
		$c->connect();
	}
}

sub plgn_destruct
{
	$dbh->disconnect() unless $CMSBuilder::Config::dbi_keepalive;
}

#———————————————————————————————— Базовые функции ——————————————————————————————

sub connect
{
	my $c = shift;
	my($dbd,$u,$p);
	
	if(@_)
	{
		($dbd,$u,$p) = @_;
	}
	else
	{
		($dbd,$u,$p) = ($CMSBuilder::Config::mysql_data_source,$CMSBuilder::Config::mysql_user,$CMSBuilder::Config::mysql_pas);
	}
	
	$dbh = DBI->connect($dbd,$u,$p);
	
	die $DBI::errstr unless $dbh;
	
	if($CMSBuilder::Config::dbi_inactivedestroy)
	{
		$dbh->{'InactiveDestroy'} = 1;
	}
	
	if($CMSBuilder::Config::mysql_charset)
	{
		$dbh->do('SET character_set_client=\''.$CMSBuilder::Config::mysql_charset.'\'');
		$dbh->do('SET character_set_results=\''.$CMSBuilder::Config::mysql_charset.'\'');
	}
	
	if($CMSBuilder::Config::mysql_colcon)
	{
		$dbh->do('SET collation_connection=\''.$CMSBuilder::Config::mysql_colcon.'\'');
	}
	
	$dbh->{'HandleError'} = sub	{ croak($_[0]);	};
	$dbh->{'RaiseError'} = 1;
}

sub fix_connection
{
	my $c = shift;
	
	eval { $dbh->do('SELECT NOW()'); };
	if($@){ $c->connect(); warn 'DBI reconnected'; }
}

#—————————————————————————————— Дополнительные функции —————————————————————————

sub table_create_system
{
	$dbh->do
	('
		CREATE TABLE IF NOT EXISTS `access`
		(
			`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
			`url` VARCHAR(50) NOT NULL,
			`memb` VARCHAR(50) DEFAULT \'\' NOT NULL,
			`code` INT DEFAULT 0 NOT NULL,
			
			INDEX(`memb`), INDEX(`url`)
		)
	');
	
	#Добавили проверку "не создана ли таблица"
	$dbh->do
	('
		CREATE TABLE IF NOT EXISTS `relations` 
		(
			`aurl` VARCHAR(50),
			`num` INT NOT NULL,
			`ourl` VARCHAR(50),
			`type` VARCHAR(50),
			`date` DATE,
			
			INDEX(`aurl`), INDEX(`num`), INDEX(`ourl`), INDEX(`type`), INDEX(`date`)
		)
	');
}

sub tables_dropall
{
	my @tables = ('`access`', '`relations`', map { $_->table_name } cmsb_classes());
	$dbh->do('DROP TABLE IF EXISTS ' . join(', ', @tables));
}

sub table_exists
{
	my $tn = shift;
	return 0 unless $tn || $dbh;
	
	my $sql;
	
	if($tn =~ m/`(.+)`.`(.+)`/)
	{
		$sql = "SHOW TABLES FROM `$1` LIKE '$2'";
	}
	elsif($tn =~ m/`(.+)`/)
	{
		$sql = "SHOW TABLES LIKE '$1'";
	}
	
	return $sql && $dbh->selectrow_array($sql);
}

1;