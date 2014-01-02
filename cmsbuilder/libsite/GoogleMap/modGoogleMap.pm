# (с) http://www.technocat.ru/

package modGoogleMap;
use strict qw(subs vars);
use utf8;
use CMSBuilder;
use CMSBuilder::IO;
use IPC::Open2;

our @ISA = qw(plgnSite::Member CMSBuilder::DBI::Array CMSBuilder::DBI::TreeModule);

sub _cname {'GoogleMap'}
sub _add_classes {qw/!* GoogleMapPoint/}
sub _have_icon {0}
sub _pages_direction {1}

sub _aview{qw/name coords/}


#my $rootdir	= $CMSBuilder::Config::path_wwfiles;

sub _props{
	'coords' => { 'type' => 'string', 'length' => 50, 'name' => 'Координаты центра города'};
}
#sub _props
#{
#	opendir(DIR, $rootdir) || die "can't opendir $rootdir: $!";
#	my @results = grep {-d "$rootdir/$_"} readdir(DIR);
#	my @dirs;
#	foreach(@results)
#	{
#		if ($_ ne '.')
#		{
#			if ($_ ne '..')
#			{
#				my $hash = { };
#				$hash->{$_} = $_;
#				push(@dirs, $hash);
#			}
#		}
#	}
#	closedir DIR;
#	return 'name' => { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
#	'dir'	=> { type => 'select2', variants => \@dirs, name => 'Директория' }
#}

#———————————————————————————————————————————————————————————————————————————————

#sub imgsearch
#{ 
#	my $dir = shift;
#	my @ra;
#
#	opendir ( DIR, $rootdir.$dir ) or die( "can't open $dir" );
#	foreach ( readdir( DIR ) )
#	{
#		push( @ra,$_ ) if tmpscan( $_,qw(jpg png jpeg gif JPG) );
#	}
#	return @ra;
#}
#
#sub tmpscan
#{  
#     my $textstring = shift;
#     my @template = @_;
#     foreach(@template)
#     {
#		if ( $textstring =~ m/$_/ and $textstring !~ m/smallphoto/)
#          {   
#               return $_;
#          }
#     }
#}
#
#sub admin_edit
#{
#	my $o = shift;
#	my $r = shift;
#	
#	my $res = $o->SUPER::admin_edit($r,@_);
#
#	#map { $o->elem_cut($_); $_->del(); } $o->get_all();
#	
#	my $dir = $o->{'dir'};
#	my @arrayimg = imgsearch( '/' . $dir );
#	
#	if (!$o->len)
#	{
#	foreach(@arrayimg)
#	{
#		#my $arimg = $_;
#		#if $dir.'/'.$_->{'photo'} eq $dir.'/'.$arimg;
#
#		my $photo = Photo->cre();
#		$photo->{'photo'}->{'_val'} = $dir . '/' . $_;
#		#$photo->{'name'} = $_;
#		$photo->save();
#		$o->elem_paste($photo);
#		
#		# my $comments = modFeedback->cre();
#		# $comments->{name} = 'Комментарии';
#		# $comments->save();
#		# $photo->elem_paste($comments);
#		# 
#		# my $theme = fbTheme->cre();
#		# $theme->{name} = 'Комментарии к фотографии ' . $photo->{name};
#		# $theme->save();
#		# $comments->elem_paste($theme);
#	}
#	$sess->{admin_refresh_left} = 1;
#	}
#	
#	return $res;
#}
#


sub site_content
{
	my $o = shift;
	my $r = shift;	
        
        my @all = grep {!$_->{hidden}} $o->get_all();       
	my ($writer, $reader,$flatlist);
#	IPC::Open2::open2($reader, $writer, "cat");        
        print 'var markers = new Array(Array()';
        for my $t (@all){      
        	my $descr = $t->{'descr'};
$descr=~s/(\$\{page(\d+)\.site_flatlist)\};/\1\("nobr"\)\};/s;
#cmsb_url("Page$1")->site_flatlist2($r);/e;
        	$descr =~ s/'/\'/ig;
        	$descr =~ s/[\n\r]/'\./ig;
#open(FILE,'>/www/gogasat/headcall.ru/cmsbuilder/tmp/google.log');
#binmode(FILE);
#print FILE $descr.'|'.$flatlist;
#close(FILE);
            print ', Array(' , $t->{'location'} , ',\'' ,  '<b>'.$t->{'name'}.'</b>' , '\', \'', $t->{'link'},'\', \'' , $t->{'img'}->href() , '\', \'','<div class="google_ul">'.$descr.'</div>','\')';
        }
        print ');';
        
        return;
}

sub install_code {}
sub mod_is_installed {1}

	1;
