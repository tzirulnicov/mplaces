# (с) Леонов П.А., 2006

package Station;
use strict qw(subs vars);
use utf8;

our @ISA = qw(plgnSite::Member CMSBuilder::DBI::Array);

sub _cname {'Станция'}
sub _aview {qw(name)}
#sub _have_icon {1}
#sub _template_export{qw/hotel_name images hotel_all contacts city_excursies city_hotels city_rekomenduem city_map/}
sub _props
{
	name	=> { type => 'string', length => 100, 'name' => 'Название' },
}

#———————————————————————————————————————————————————————————————————————————————

 sub site_content
 {
 	my $o = shift;
 	my $r = shift;
 	
 	if($o->{'submenu'} eq 'only')
 	{
 		$o->site_submenu($r);
 		print $o->{'script'};
 	}
 	elsif($o->{'submenu'} eq 'after')
 	{
 		print $o->{'content'} . $o->{'script'};
 		$o->site_submenu($r);
 	}
 	elsif($o->{'submenu'} eq 'before')
 	{
 		$o->site_submenu($r);
 		print $o->{'content'} . $o->{'script'};
 	}
 	else
 	{
 		print $o->{'content'} . $o->{'script'};
 	}
}
sub images{
   my $o=shift;
   if ($o->{name} eq 'Номера'){
      $o->images_all();
      return;
   }
   my $hotel_name=$o->papa->papa->site_name.' - '.$o->site_name;
   print '<ul>';
   for(my $a=1;$a<=10;$a++){
      print '<li><a href="'.$o->{'photo'.$a}->href.'" id="mb'.$a.
	'" class="mb" title="'.$hotel_name.'"><img src="'.$o->{'small'.$a}->href.
	'" border=0></a><div class="multiBoxDesc mb'.$a.'"></div></li>' if $o->{'small'.$a}->exists;
   }
   print '</ul>';
   return;
}
sub images_all{
   my $o=shift;
   my $hotel_name=$o->papa->site_name.' - ';
   print '<ul>';
   for my $k($o->get_all){
    for(my $a=1;$a<=10;$a++){
      print '<li><a href="'.$k->{'photo'.$a}->href.'" id="mb'.$a.
        '" class="mb" title="'.$hotel_name.$k->{name}.'"><img src="'.$k->{'small'.$a}->href.
        '" border=0></a><div class="multiBoxDesc mb'.$a.'"></div></li>' if $k->{'small'.$a}->exists;      
    }
   }
   print '</ul>';
   return;
}
sub hotel_name{
   my $o=shift;
   if ($o->{name} eq 'Номера'){
   print $o->papa->site_name;
 } else {
   print $o->papa->papa->site_name;
 }
}
sub hotel_all{
   my $o=shift;
   if ($o->{name} eq 'Номера'){
      $o->site_flatlist(shift,0);
   } else {
      $o->papa->site_flatlist(shift,0);
   }
}
sub contacts{
   foreach my $k(split(',',shift->{contacts})){
      print '<span>'.$k.'</span>';
   }
}
sub city_excursies{
   my $o=shift;
   my $r=shift;
   my $mode=shift || 0;
   $o=Page->new(42) if $mode;
   foreach my $k($o->get_all){
      next if $k->{name} ne 'Экскурсии';
      $k->site_flatlist($r,1,0,(!$mode?"hotel":"<ol>"));
      last;
   }
}
sub city_hotels{
   my $o=shift;
   my $name='';
   $o->{hotels}=0;
   foreach my $hotels($o->get_all){
     next if $hotels->{name} ne 'Гостиницы';
     $o->{hotels}=$hotels;
     last;
   }
   if (!$o->{hotels}){
      print "Error: Hotels on this city not found";
      return;
   }
   foreach my $num(qw/5 4 3 2/){
      print '<ul class="stars'.$num.'">';
      $name=$num.' звезды' if $num==3 || $num==4;
      $name=$num.' звезд' if $num==5;
      $name='Мини отели' if $num==2;
      foreach my $k($o->{hotels}->get_all){
	 next if $k->{name} ne $name;
	 foreach my $k2($k->get_all){
	    print '<li><a href="'.$k2->site_href.'">'.$k2->site_name.
		'</a> <sup>'.($num!=2?'+'.$num:'Мини отели').'</sup></li>';
	 }
	 last;
      }
      print '</ul>';
   }
}
sub city_rekomenduem{
   my $o=shift;
   foreach my $k($o->get_all){
      next if $k->{my4} ne 'hotels';
      foreach my $k2($k->get_all){
	  next if $k2->{name} ne 'Рекомендуем';
	  print $k2->{content};
	  last;
      }
      last;
   }
}
sub city_map{
   my $o=shift;
   my @coords;
   for my $k($o->get_all){
      next if $k->myurl!~/GoogleMap/;
      @coords=split(/[ ,]+/,$k->{coords});
      @coords=('55.7394','37.6446') if $#coords<1;
      $coords[2]=9 if $#coords<2;
      print 'var elms=new Array('.
	join(',',@coords).');
';
      $k->site_content(shift);
      last;
   }
}
1;
