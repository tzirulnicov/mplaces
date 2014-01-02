# (с) Леонов П.А., 2005

package CMSBuilder::IO::Ini;
use strict qw(subs vars);
use utf8;

use Fcntl ':flock';

our %fnames;

sub new
{
	my $class = shift;
	my $fname = shift;
	
	my $o = {};
	bless($o,$class);
	
	if($fname){ $o->cread($fname); }
	
	return $o;
}

sub read_data
{
	my $o = shift;
	my $f = shift;
	
	seek($f,0,0);
	my($var,$val,$cnt);
	while(my $str = <$f>)
	{
		($var,$val) = split(/=/,$str,2);
		chomp($val);
		$o->{$var} = $val;
		$cnt++;
	}
	
	return $cnt;
}

sub cread
{
	my $o = shift;
	my $fname = shift;
	
	$fnames{$o.'.name'} = $fname;
	
	return 2 if !-f $fname;
	open(my $f,'<:utf8',$fname) || warn "Cannot open(<:utf8) '$fname': $!";
	flock($f,LOCK_SH);
	
	$o->read_data($f);
	
	flock($f,LOCK_UN);
	close($f);
	
	$fnames{$o.'.keys'} = [keys %$o];
	
	return 1;
}

sub write_data
{
	my $o = shift;
	my $f = shift;
	
	seek($f,0,0);
	truncate($f,0);
	my $cnt;
	for my $key (keys(%$o))
	{
		print $f $key,'=',$o->{$key},"\n";
		$cnt++;
	}
	
	return $cnt;
}

sub cwrite
{
	my $o = shift;
	my $fname = $fnames{$o.'.name'};
	
	my @deleted = grep { !exists $o->{$_} } @{$fnames{$o.'.keys'}};
	
	touch($fname) unless -f $fname;
	open(my $f,'+<:utf8',$fname) || warn "Cannot open(+<:utf8) '$fname': $!";
	flock($f,LOCK_EX);
	
	my %tvals = %$o;
	$o->read_data($f);
	%$o = (%$o,%tvals);
	map {delete $o->{$_}} @deleted;
	$o->write_data($f);
	
	unlink $fname unless keys %$o;
	
	flock($f,LOCK_UN);
	close($f);
}

sub touch
{
	my $fname = shift;
	
	open(my $f,'>>:utf8',$fname) || warn "Cannot 'touch' open(>>:utf8) '$fname': $!";
	close($f);
}

sub DESTROY
{
	my $o = shift;
	$o->cwrite();
}


return 1;







