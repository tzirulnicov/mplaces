# (с) Леонов П.А., 2006

package plgnTemplates::Interface;
use strict qw(subs vars);
use utf8;

sub _template_export {}

sub _aview {qw(template)}

sub _props
{
	template			=> { type => 'TreeList', root => 'Template', root => sub {modTemplates->first}, leaves => [qw(Template)], isnull => 1, nulltext => 'Наследовать', name => 'Шаблон страницы' },
}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;
use CMSBuilder::Utils;

sub site_template_object
{
	my $o = shift;
	my $r = shift;
	return $o->{template} || ( $o->papa ? $o->papa->site_template_object : TextTemplate->first );
}

sub template_call
{
	my $o = shift;
	my $val = shift;
	my @arg = @_;

	if(indexA($val,$o->template_export()) >= 0)
	{
		my $retval;
		my $out = catch_out
		{
			unless (join '', $o->event_call('template_call:' . $val . ':begin', @arg))
			{
				$retval = eval { $o->$val(@arg) };
				$o->event_call('template_call:' . $val . ':end', @arg);
			};
		};
		
		$out = $@ if $@;
		$out = $retval unless $out;
		
		return $out;
	}
	else
	{
		return "[метод шаблона $val не поддерживается]";
	}
}

sub template_export
{
	my $c = ref($_[0]) || $_[0];
	my $buff = $c.'::_template_export_buff';
	
	if($$buff){ return @$$buff; }
	
	my @t = varr($c,'_template_export',1);
	
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

1;
