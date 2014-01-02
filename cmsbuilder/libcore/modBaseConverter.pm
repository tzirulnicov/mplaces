# (с) Леонов П.А., 2005

package modBaseConverter;
use strict qw(subs vars);
use utf8;

our @ISA = ('CMSBuilder::Plugin');

#———————————————————————————————————————————————————————————————————————————————


sub plgn_load
{
	my $c = shift;
	
	push @modControlPanel::ISA,'modBaseConverter::Object';
}


1;


package modBaseConverter::Object;
use strict qw(subs vars);
use utf8;

our @ISA = ('CMSBuilder::DBI::SimpleModule');

sub _cname {'Конвертер базы'}
sub _have_icon {0}
sub _one_instance {1}
sub _rpcs {keys %{{_simplem_menu()}}}

sub _simplem_menu
{
	'baseconv_do'				=> { -name => 'Конвертировать базу', -icon => 'icons/table.gif' },
}

#———————————————————————————————————————————————————————————————————————————————

use CMSBuilder;
use CMSBuilder::DBI;

our @tests =
(
	{-name => 'OID (User) -> OWNER', -sub => \&oid2owner},
	#{-name => 'success', -sub => sub {1}}, {-name => 'error', -sub => undef},
);

sub baseconv_do
{
	for my $cn (sort {$a->cname cmp $b->cname} cmsb_classes())
	{
			print '<div>',$cn->admin_cname,'</div>';
			
			print '<dir>';
			
			my($res,$met);
			for my $t (@tests)
			{
				print '<div><strong>', $t->{-name},'</strong>&nbsp;—&nbsp;';
				eval
				{
					$met = $t->{-sub};
					$res = $cn->$met();
				};
				if($@){ print '<span style="color:red">ошибка:</span> ' . $@; }
				elsif($res eq 'no'){ print '<span style="color:gray">нет.</span>'; }
				elsif($res){ print '<span style="color:green">успешно.</span>'; }
				else { print '<span style="color:blue">порядок.</span>'; }
				print '</div>';
			}
			
			print '</dir>';
		
	}
}

sub oid2owner
{
	my $c = shift;
	return 'no' unless $c->table_have;
	
	my $tbl = $c->table_name;
	my $cols = $dbh->selectall_arrayref('DESCRIBE ' . $tbl);
	
	return unless grep {$_->[0] eq 'OID'} @$cols;
	
	unless(grep {$_->[0] eq 'OWNER'} @$cols)
	{
		my %sys_cols = %CMSBuilder::DBI::Object::OBase::sys_cols;
		$dbh->do("ALTER TABLE $tbl ADD `OWNER` $sys_cols{'OWNER'}");
	}
	
	$dbh->do("UPDATE $tbl SET `OWNER` = CONCAT('User',OID)");
	$dbh->do("ALTER TABLE $tbl DROP `OID`");
	
	return 1;
}

1;