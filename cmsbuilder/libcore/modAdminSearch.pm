# (с) Леонов П.А., 2005

package modAdminSearch;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::DBI::SimpleModule CMSBuilder::Plugin);

use CMSBuilder;
use CMSBuilder::Utils;
use plgnUsers;

sub _cname {'Поиск в админке'}
sub _have_icon {1}
sub _one_instance {1}
sub _rpcs {keys %{{_simplem_menu()}}}

sub _simplem_menu
{
	'modsearch_search'		=> { -name => 'Искать', -icon => 'icons/table.gif' },
}

#———————————————————————————————————————————————————————————————————————————————

sub plgn_load
{
	push @CMSBuilder::DBI::Object::ISA, 'modAdminSearch::Object';
}

sub default
{
	my $o = shift;
	my $r = shift;
	#print 'Внутренний поисковик.';
	$o->modsearch_search($r);
}

sub mod_is_installed { return 1; }
sub install_code {}

sub modsearch_search
{
	my $o = shift;
	my $r = shift;
	
	print
	'
	<p>
		<form action="?">
			<input type="hidden" name="url" value="' . $o->myurl() . '">
			<input type="hidden" name="act" value="modsearch_search">
			
			<input style="width: 50%" type="text" name="str" value="' . $r->{'str'} . '" />
			<button type="submit">Искать…</button>
		</form>
	</p>
	';
	
	if($r->{'str'})
	{
		print '<hr/>';
		
		my @res;
		
		{
			my $to = cmsb_url($r->{'str'});
			push @res, $to if $to;
		}
		
		{
			my @keys = split /\s+/, $r->{'str'};
			map { push @res, $_->search(keys => [@keys]) } cmsb_classes();
		}
		
		if(@res)
		{
			print "<p>Найдено объектов: " . scalar(@res) . '<p><dir>';
			print map {'<div>' . $_->admin_name . '</div>'} @res;
			print '</dir></p></p>';
		}
		else
		{
			print 'Ничего не найдено.';
		}
	}
}

package modAdminSearch::Object;
use strict qw(subs vars);
use utf8;

sub search_props {[qw/name/]} #[qw/name nick tel/] [keys %{$_[0]->props}]

sub search
{
	my $o = shift;
	my $opts =
	{
		props => $o->search_props(),
		logic => 'and',
		@_
	};
	
	my @keys  = @{$opts->{'keys'}};
	my @props = @{$opts->{'props'}};
	
	unless(@props && @keys){ return; }
	
	my $fds = '('.join(' OR ',map {"`$_` LIKE ?"} @props).')';
	
	my(@sql,@vals);
	for my $key (@keys)
	{
		push @sql, $fds;
		push @vals, ('%' . $key . '%') x @props;
	}
	
	#print join(' OR ',@sql),'<br>',join(', ',@vals),"\n";
	#return;
	my $lgc = $opts->{'logic'};
	$lgc =~ s/\W//;
	return $o->sel_where(join(' '.uc($lgc).' ',@sql),@vals);
}

1;