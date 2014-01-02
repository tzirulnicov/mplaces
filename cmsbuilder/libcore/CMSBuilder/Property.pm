# (с) Леонов П.А., 2005

package CMSBuilder::Property;
use strict qw(subs vars);
use utf8;

# tie $obj->{'prop'}, 'Property', $obj, 'prop';

sub TIESCALAR
{
	my $c = shift;
	my($obj,$pname) = @_;
	my $o = {};
	
	$o->{'obj'} = $obj;
	$o->{'pname'} = $pname;
	
	bless($o,$c);
}

sub STORE
{
	my $o = shift;
	my $val = shift;
	
	my $vt = 'CMSBuilder::VType::'.$o->{'obj'}->props()->{$o->{'pname'}}->{'type'};
	return $vt->prop_write($o->{'pname'},$val,$o->{'obj'});
}

sub FETCH
{
	my $o = shift;
	
	my $vt = 'CMSBuilder::VType::'.$o->{'obj'}->props()->{$o->{'pname'}}->{'type'};
	return $vt->prop_read($o->{'pname'},$o->{'obj'});
}

1;