# (с) Леонов П.А., 2005

package CMSBuilder::DBI::EventsInterface;
use strict qw(subs vars);
use utf8;

sub event_call
{
	my $o = shift;
	my $type = shift;
	
	local $o->{'event_call_cancel'} = 0;
	
	my @res;
	
	for my $code (@{$CMSBuilder::oevents{$type}})
	{
		next unless $o->isa($code->{'class'});
		my $sub = $code->{'sub'};
		push @res, $o->$sub(@_);
		last if $o->{'event_call_cancel'};
	}
	
	return @res;
}


1;