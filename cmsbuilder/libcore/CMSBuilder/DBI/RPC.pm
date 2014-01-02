# (с) Леонов П.А., 2005

package CMSBuilder::DBI::RPC;
use strict qw(subs vars);
use utf8;

sub _rpcs {'default'}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;
import CGI 'param';

sub rpclist
{
	my $o = shift;
	my $buff = ref($o).'::_rpcs_buff';
	
	if(@$buff){ return @$buff; }
	
	@$buff = varr(ref($o),'_rpcs');
	return @$buff;
}

sub rpc_exec
{
	my $o = shift;
	my $fn = shift;
	
	my @rpcf = $o->rpclist();
	
	unless($fn){ $o->err_add('Указано пустое имя функции.'); return; }
	unless(indexA($fn,@rpcf)>=0){ $o->err_add('Функция <b>'.$fn.'</b> не разрешена как RPC.'); return; }
	unless($o->can($fn)){ $o->err_add('Функция <b>'.$fn.'</b> не определена.'); return; }
	
	return $o->$fn(@_);
}

1;