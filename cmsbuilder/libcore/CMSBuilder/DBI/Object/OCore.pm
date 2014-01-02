# (с) Леонов П.А., 2005

package CMSBuilder::DBI::Object::OCore;
use strict qw(subs vars);
use utf8;

sub _cname {'Объект (ядро)'}
sub _have_icon {0}
sub _dont_list_me {0};
sub _props
{
	name		=> { type => 'string', name => 'Название' },
}
sub _aview {}
sub _one_instance {0}
sub _aview_tabs { ({-name => 'Данные элемента', -sub => 'admin_props'}, {-name => 'Дополнительно', -sub => 'admin_additional'}) }

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;
use CMSBuilder::Utils;


sub class_load {}

#————————— Методы реализующие копирование объектов и создание ярлыков ——————————

sub shcut_cre
{
	my $o = shift;
	
	my $tsh;
	$tsh = ref($o)->cre();
	$tsh->{'SHCUT'} = $o->{'ID'};
	$tsh->save();
	
	return $tsh;
}

sub shcut_obj
{
	my $o = shift;
	
	return $o->{'SHCUT'}?ref($o)->new($o->{'SHCUT'}):undef;
}

sub copy
{
	my $o = shift;
	
	my $no = ref($o)->cre();
	return $o->copyto($no);
}

sub copyto
{
	my $o = shift;
	my $no = shift;
	
	my $p = $o->props();
	my $vt;
	
	my $noid = $no->{'ID'};
	
	for my $key (keys %$o)
	{
		if(exists $p->{$key})
		{
			$vt = 'CMSBuilder::VType::'.$p->{$key}{'type'};
			$no->{$key} = $vt->copy($key,$o->{$key},$o,$no);
		}
		else
		{
			$no->{$key} = $o->{$key};
		}
	}
	
	$no->{'ID'} = $noid;
	
	$no->save();
	
	return $no;
}


#————————————————— Методы реализации полноценного наследования —————————————————

sub one_instance { return $_[0]->_one_instance(@_); }

sub have_icon { return $_[0]->_have_icon(@_); }

sub dont_list_me { return $_[0]->_dont_list_me(@_); }

sub cname { return $_[0]->_cname(@_); }

sub aview
{
	my $qw = $_[1];
	$qw = '_aview' unless $qw;
	
	
	my $c = ref($_[0]) || $_[0];
	$qw = '_aview' if $c ne 'CatWareSimple' && $qw eq '_all';
	
	my $buff = $c.'::' . $qw . '_buff';
	
	if($$buff){ return @$$buff; }
	
	my @t = varr($c,$qw,1);
	
	my @res;
	for my $v (reverse @t)
	{
		if($v eq '-'){ last; }
		unshift(@res,$v)
	}
	
	my $h = {};
	@res = grep {$h->{$_}?0:($h->{$_} = 1); } @res;
	
	$$buff = [@res];
	return @$$buff;
}

sub props
{
	my $c = ref($_[0]) || $_[0];
	my $buff = $c.'::_props_buff';
	
	if($$buff){ return $$buff; }
	
	$$buff = {varr($c,'_props',0)};
	return $$buff;
}


#——————————————————————— Методы создания объектов Perl —————————————————————————

sub cre
{
	my $c = shift;
	my $sender = shift;
	
	my $o = {};
	bless($o,$c);
	
	$o->{'ID'} = $o->insert();
	$o->reload();
	eval { $o->initobj($sender) } if $sender;
	
	return $o;
}

sub new
{
	my $c = shift;
	
	my $o = {};
	bless($o,$c);
	
	return $o->_init(@_);
}

sub _init
{
	my $o = shift;
	my $n = shift;
	
	unless($n){ return $o; }
	
	if($CMSBuilder::Config::do_dbo_cache)
	{
		my $sig = ref($o).$n;
		
		if(defined $CMSBuilder::dbo_cache{$sig})
		{
			return $CMSBuilder::dbo_cache{$sig};
		}
		$CMSBuilder::dbo_cache{$sig} = $o;
	}
	
	$o->{'ID'} = $n;
	$o->reload();
	
	return $o;
}

#———————————————————————————————————————————————————————————————————————————————

sub len {0}

sub myurl
{
	my $o = shift;
	
	my $cn = ref($o);
	$cn =~ s#\:\:#\_#g;
	
	return $cn.($o->{'ID'}?$o->{'ID'}:'0');
}

sub name
{
	my $o = shift;
	my $ret;
	
	if($o->{'name'}){ return $o->{'name'} }
	unless($o->{'ID'}){ return 'Объект не найден: '.$o->cname().' '.$o->{'ID'} }
	
	return $o->cname().' '.$o->{'ID'};
}

sub papa
{
	my $o = shift;
	
	if($o->{'PAPA_CLASS'} && $o->{'PAPA_ID'})
	{
		return $o->{'PAPA_CLASS'}->new($o->{'PAPA_ID'});
	}
	
	return undef;
}

sub root
{
	return $_[0]->papaN(0);
}

sub papaN
{
	my $o = shift;
	my $n = shift;
	
	my @path = $o->papa_path();
	
	if($n > $#path){ $n = $#path }
	
	return $path[$n];
}

sub isapapa
{
	my $o = shift;
	my $obj = shift;
	
	map {return 1 if $obj->myurl() eq $_->myurl()} $o->papa_path();
	
	return;
}

sub papa_path
{
	my $o = shift;
	my $n = shift;
	
	my(@path,$p,$cnt);
	
	$cnt = 0;
	$p = $o;
	
	while(($p = $p->papa()) && ($cnt < 50))
	{
		$cnt++;
		push(@path,$p);
	}
	
	return reverse($o,@path);
}

sub owner
{
	my $o = shift;
	return cmsb_url($o->{'OWNER'}) || cmsb_url($CMSBuilder::Config::user_admin);
}

sub access
{
	return length($_[1]) == 1?1:0;
}

sub enum
{
	my $o = shift;
	
	if(exists $o->{'_ENUM'}){ return $o->{'_ENUM'} }
	
	my $papa = $o->papa();
	unless($papa){ $o->{'_ENUM'} = 0; return 0; }
	unless($papa->isa('CMSBuilder::DBI::Array::ACore')){ $o->{'_ENUM'} = 0; return 0; }
	
	$o->{'_ENUM'} = $papa->elem_tell_enum($o);
	
	return $o->{'_ENUM'};
}

sub elem_can_add { return 0; }


1;