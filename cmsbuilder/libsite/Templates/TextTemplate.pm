# (с) Леонов П. А., 2005

package TextTemplate;
use strict qw(subs vars);
use utf8;

our @ISA = qw(Template CMSBuilder::DBI::Object);

use CMSBuilder;
use CMSBuilder::Utils;

sub _cname {'Текстовый шаблон'}
sub _aview {qw(name content)}

sub _props
{
	name		=> { type => 'string', length => 25, name => 'Название' },
	content	=> { type => 'html', name => 'Страница' },
}

#———————————————————————————————————————————————————————————————————————————————

sub first
{
   my $o=shift;
   my $obj_name=shift;
   my $k;
   foreach $k(modSite->all){
      next if $k->{address} ne $ENV{'SERVER_NAME'};
$CMSBuilder::site_id=$k->{ID};
      foreach my $k2($k->{template}->papa->get_all){
	 return $k2;
      }
   }
   return $k->{template};
#   return TextTemplate->new(3);
}

sub parse
{
	my $o = shift;
	my $obj = shift;
	my $r = shift;
	my $cont = shift;
	
	$cont = defined $cont ? $cont : $o->{content};
	
	my ($i,$m);
	do
	{
		$m = 0;
		$m ||= $cont =~ s/(?<!\\)\${(.*?)}/$o->exec($obj,$1,$r)/sge;
	}
	while $m && $i++ < 50;
	
	return $cont;
}

sub exec
{
	my $o = shift;
	my $obj = shift;
	my $str = shift;
	my $r = shift;
	
	my $old_str = $str;

	$obj = cmsb_url($1) || $1 if $str =~ s/^(\w+)//;
	
	my $ret;
	my $cnt;
	
	while($str =~ s/^\.(\w+)(?:\((.*?)\))?//)
	{
		#warn "$obj, $1, $r, $2";
		$cnt++;
		#$ret = $o->call($obj, $1, $r, split('\s*,\s*',));
		$ret = eval { $obj->template_call($1, $r, split('\s*,\s*',$2)) };
		
		if ($@) { warn $@; return $^W ? "Error in '$old_str'" : undef };
		
		$obj = cmsb_url($ret) || $ret;
	}
	
	return "No method name found in \\\${$old_str}" unless $cnt;
	
	return $ret;
}


1;
