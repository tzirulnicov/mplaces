# (с) Леонов П.А., 2005

package plgnUsers;
use strict qw(subs vars);
use utf8;

our @ISA = ('Exporter','CMSBuilder::Plugin');

use Exporter;

our @EXPORT =
qw/
$user $group

&access_off &access_on &access_ret
&acs_off &acs_on &su_start &su_stop
&is_guest &user_classes
&user_classes_sel_one
/;

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;
use CMSBuilder::IO;
use CMSBuilder::Utils;

our
(
	@users_s,@udo_s,
	$errstr,
	
	$user,$group,
	@user_classes,
);



#————————————————————— Экпортируемые вспомогательные функции ———————————————————

sub is_guest
{
	my $u = shift;
	
	return ($u->papa() && $u->papa()->myurl() eq cmsb_url($CMSBuilder::Config::user_guest)->papa()->myurl())?1:0;
}

sub admin_additional
{
	my $o = shift;
	
	my $chown = $o->access('o')?'&nbsp;(<a href="?url='.$o->myurl().'&act=cms_chown"><u>изменить&nbsp;владельца</u></a>)':'';
	
	print '<tr><td valign="top">Владелец:</td><td valign="top">',$o->owner ? $o->owner->name : 'не определен',$chown,'</td></tr>';
}

sub user_classes
{
	return grep {$_->isa('plgnUsers::UserMember')} cmsb_classes()
}

#—————————————————————— Экпортируемые базовые функции ——————————————————————————

sub access_off
{
	CMSBuilder::ocache_clear();
	push @udo_s, $CMSBuilder::Config::access_on_e;
	$CMSBuilder::Config::access_on_e = 0;
}

sub access_on
{
	CMSBuilder::ocache_clear();
	push @udo_s, $CMSBuilder::Config::access_on_e;
	$CMSBuilder::Config::access_on_e = 1;
}

sub access_ret
{
	CMSBuilder::ocache_clear();
	unless(@udo_s){ return; }
	$CMSBuilder::Config::access_on_e = pop @udo_s;
}

sub acs_off(&)
{
	my $code = shift;
	access_off();
	my $ret = &$code;
	access_ret();
	return $ret;
}

sub acs_on(&)
{
	my $code = shift;
	access_on();
	my $ret = &$code;
	access_ret();
	return $ret;
}

sub su_start
{
	my $url = shift || $CMSBuilder::Config::user_admin;
	return unless $url;
	
	push @users_s, $user->myurl() if $user;
	
	# Обнуляем для того, чтобы $user или $group не сохранялись
	# во время access_off(), что может привести к пересеченю зон
	$user = $group = undef;
	CMSBuilder::ocache_clear();
	
	acs_off
	{
		$user = cmsb_url($url);
		return su_stop() unless $user;
		$group = $user->papa();
	};
	
	return 1;
}

sub su_stop
{
	unless(@users_s){ return 0; }
	
	# Обнуляем с той же целью, что и в su_start()
	$user = $group = undef;
	CMSBuilder::ocache_clear();
	
	my $url = pop @users_s;
	
	acs_off
	{
		$user = cmsb_url($url);
		$group = $user->papa();
	};
}


sub user_classes_sel_one
{#print STDERR '[',@user_classes,']';
	for my $cl (@user_classes)
	{
		my $to = $cl->sel_one(@_);
		return $to if $to;
	}
	
	return;
}

#—————————————————————————— Дополнительные функции —————————————————————————————

sub login
{
	my $c = shift;
	my $l = shift;
	my $p = shift;
	
	return err('Пустое имя пользователя или пароль.') unless $l && $p;
	
	my $tu;
	acs_off { $tu = user_classes_sel_one(' login = ? ',$l); };
	return err('Неверное имя пользователя.') unless $tu;
	
	unless($CMSBuilder::Config::users_pasoff)
	{
		return err('Неверный пароль.') unless $tu->{'pas'} eq MD5($p);
	}
	
	my $tg;
	my $ur;
	acs_off { $tg = $tu->papa; $ur = $tg->papa; };
	return err('Вы не состоите в группе.') unless $tg;
	return err('Группа не принадлежит авторизированному модулю.') unless $ur && $ur->myurl eq $CMSBuilder::Config::users_module;
	
	# Логин и пароль в порядке
	
	$sess->{'plgnUsers.uurl'} = $tu->myurl;
	su_start($tu->myurl);
	
	return 1;
}

sub logout
{
	my $c = shift;
	
	my $tu = cmsb_url($sess->{'plgnUsers.uurl'});
	return err("Вы не вошли в систему.") unless $tu;
	
	delete $sess->{'plgnUsers.uurl'};
	
	return 1;
}

sub verif
{
	my $c = shift;
	
	my $tu;
	acs_off { $tu = cmsb_url($sess->{'plgnUsers.uurl'}) };
	return unless $tu;
	
	my $tg;
	acs_off { $tg = $tu->papa() };
	return unless $tg;
	
	su_start($tu->myurl);
	
	return 1;
}

sub last_error
{
	return $errstr;
}

sub err
{
	$errstr = shift;
	return 0;
}

#——————————————————————————— Интерфейс механизма плагинов ——————————————————————

sub plgn_load
{
	my $c = shift;
	
	cmsb_coreload('plgnUsers');
	
	cmsb_event_reg('admin_view_additional',\&admin_additional);
}

sub plgn_init
{
	my $c = shift;
	
	$user = $group = undef;
	$errstr = undef;
	@user_classes = @users_s = @udo_s = ();
	
	@user_classes = user_classes();
	
	
	if($CMSBuilder::Config::access_auto_off && $CMSBuilder::Config::access_on_e)
	{
		$CMSBuilder::Config::access_on_e = 0;
		
		if(modUsers->table_have())
		{
			my $tu = cmsb_url($CMSBuilder::Config::user_admin);
			
			if($tu)
			{
				$CMSBuilder::Config::access_on_e = 1;
			}
		}
	}
	
	if($CMSBuilder::Config::access_on_e)
	{
		su_start($CMSBuilder::Config::user_guest);
		$c->verif();
	}
	else
	{
		$user  = User->new();
		$user->{'ID'}		= $CMSBuilder::Config::user_admin;
		$user->{'name'}		= 'Монопольный режим';
		
		$group = UserGroup->new();
		$group->{'ID'}		= 1;
		$group->{'name'}	= 'Администраторы';
		
		$group->{'html'}	= 1;
		$group->{'files'}	= 1;
		$group->{'cms'}		= 1;
		$group->{'root'}	= 1;
		$group->{'cpanel'}	= 1;
	}
}

sub plgn_destruct
{
	my $c = shift;
	
	$user = $group = undef;
	$errstr = undef;
	@users_s = @udo_s = ();
}

1;