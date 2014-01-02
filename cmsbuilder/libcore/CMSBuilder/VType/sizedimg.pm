# (с) Леонов П.А., 2005

package CMSBuilder::VType::sizedimg;
use strict qw(subs vars);
use utf8;

# 'smallphoto'	=> { 'type' => 'sizedimg', 'for' => 'photo', 'size' => '*x100', 'quality' => 0-9|10-0, 'format' => 'png'|'jpeg', 'truecolor' => 0|1},

our @ISA = 'CMSBuilder::VType';
our $filter = 1;

sub table_cre {'VARCHAR(100)'}

sub filter_load
{
	my $c = shift;
	return CMSBuilder::VType::sizedimg::object->new(@_);
}

sub filter_save
{
	my $c = shift;
	return eval{$_[1]->val};
}

sub aview
{
	return;
}

sub sview
{
	return;
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	return $obj->{$name};
}

sub del
{
	my $c = shift;
	$_[1]->del(@_);
}

sub copy
{
	my $c = shift;
	my ($name,$val,$obj,$nobj) = @_;
	
	return;
}


#———————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————————————————————————————————————————————


package CMSBuilder::VType::sizedimg::object;
use strict qw(subs vars);
use utf8;

use CMSBuilder::Utils;
use CMSBuilder::IO;

sub new
{
	my $c = shift;
	
	my $o = {};
	bless($o,$c);
	
	$o->init(@_);
	
	return $o;
}

sub init
{
	my $o = shift;
	
	$o->{'_pname'} = shift;
	$o->{'_val'} = shift;
	$o->{'_obj'} = shift;
	
	$o->{'_fname'} = $modules_ini->{$o->ininame.'.fn'};
	
	unless($o->{'_obj'}){ return; }
	
	$o->{'_prop'} = $o->{'_obj'}->props()->{$o->{'_pname'}};
	
	$o->{'_val'} = $o->forimg->name . $o->suffix if $o->make;
}

sub val
{
	my $o = shift;
	return; #$o->name;
}

sub bounds
{
	my $o = shift;
	my $sw = shift;
	my $sh = shift;
	
	return(50,50) if $o->{'_prop'}->{'size'} !~ m/\D*(\d+|\*)\D+(\d+|\*)\D*/ || ($1 eq '*' && $2 eq '*') || !$1 || !$2;
	return($1,$2) if $1 ne '*' && $2 ne '*';
	return($1*1 || $2*1) x 2 unless $sw && $sh;
	
	my ($w,$h) = ($1,$2);
	
	return($w,$w*$sh/$sw) if $h eq '*';
	return($sw/$sh*$h,$h) if $w eq '*';
	
	return($w,$h);
}

sub name
{
	my $o = shift;
	return $o->{'_fname'};
}

sub signature
{
	my $o = shift;
	my $p = $o->{'_prop'};
	return $p->{'size'} . '-' . $p->{'quality'} . '-' . $p->{'format'} . '-' . $p->{'truecolor'} . '-' . $p->{'for'};
}

sub suffix
{
	my $o = shift;
	return '_' . $o->{'_pname'} . '.' . $o->format;
}

sub format
{
	my $o = shift;
	return lc($o->{'_prop'}->{'format'} =~ m/(jpeg|png)/i) ? $1 : 'jpeg';
}

sub quality
{
	my $o = shift;
	return $o->{'_prop'}->{'quality'} =~ m/(\d+)/ ? $1 : 7;
}

sub truecolor
{
	my $o = shift;
	return $o->format eq 'jpeg' || $o->{'_prop'}->{'truecolor'} ? 1 : 0;
}

sub forimg
{
	my $o = shift;
	return $o->{'_obj'}->{$o->{'_prop'}->{'for'}};
}

sub ininame
{
	my $o = shift;
	return ref($o) . '.' . $o->{'_obj'}->myurl . '.' . $o->{'_pname'}
}

sub make
{
	my $o = shift;
	
	my $img = $o->forimg;
if ($o->ininame=~/2785.photosmallest/){
open(FILE,'>>/www/evoo/evoo.ru/cmsbuilder/tmp/sizedimg.log') or die $!;
print FILE $img,'&',$o->ininame,'|',$o->forimg,'|',($img && $img->exists?1:0)."\n";
close(FILE);
}
	return unless $img && $img->exists;
	if (($modules_ini->{$o->ininame.'.fn'} && !(-e $CMSBuilder::Config::path_wwfiles.'/'.$modules_ini->{$o->ininame.'.fn'})) ||
	    ($modules_ini->{$o->ininame.'.sig'} && !($modules_ini->{$o->ininame.'.fn'}))){
#	    delete $modules_ini->{$o->ininame.'.sig'};
#	    delete $modules_ini->{$o->ininame.'.fn'};
	}
	
	my ($format,$qlt,$tc,$suff) = ($o->format,$o->quality,$o->truecolor,$o->suffix);
	my $fp = $img->path . $suff;
#	return 1 if -f $fp && (stat $fp)[9] >= (stat $img->path)[9] && $modules_ini->{$o->ininame.'.sig'} eq $o->signature;
	
	$o->del();
		#print '[' . $img->path . ']' if $o->{'_pname'} eq 'miniphoto';
	eval
	{
		warn 'sizing image: ' . $img->path if $^W;
		require GD;
		my $nm = GD::Image->new($img->path()) || die ref($o->{'_obj'}) . ' in ' . $o->{'_pname'} . " Cannot GD::Image->new: $!";
		my $cm = GD::Image->new($o->bounds($nm->getBounds),$tc);
		
		$cm->copyResampled
		(
			$nm,
			0,0,0,0,
			$cm->getBounds,$nm->getBounds
		);
		
		var2f($cm->$format($format eq 'jpeg' ? $qlt * 10 : 9 - $qlt),$fp);
	};
	warn $@ if $@;
	return if $@;
	
	$modules_ini->{$o->ininame.'.sig'} = $o->signature;
	$modules_ini->{$o->ininame.'.fn'} = $o->{'_fname'} = $img->name . $suff;
	
	return 1;
}

sub href
{
	my $o = shift;
	return $CMSBuilder::Config::http_wwfiles.'/'.$o->name();
}

sub path
{
	my $o = shift;
	return $CMSBuilder::Config::path_wwfiles.'/'.$o->name();
}

sub size
{
	my $o = shift;
	return (stat($o->path()))[7];
}

sub size_t
{
	my $o = shift;
	return len2size( ( stat($o->path()) )[7] );
}

sub max_size
{
	my $o = shift;
	return $o->{'_prop'}->{'msize'}*1024;
}

sub max_size_t
{
	my $o = shift;
	return len2size($o->max_size());
}

sub del
{
	my $o = shift;
return if $o->ininame=~/3280/;
	unlink $o->path if $o->name;
	delete $o->{'_val'};
	delete $modules_ini->{$o->ininame.'.sig'};
	delete $modules_ini->{$o->ininame.'.fn'};
}

sub exists
{
	my $o = shift;
	return -f $o->path();
}

1;
