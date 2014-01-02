# (с) Леонов П.А., 2005

package plgnCatalog::Interface;
use strict qw(subs vars);
use utf8;
use CMSBuilder;

sub _template_export {qw(cat_content prices)}
sub _rpcs {qw(cat_content)}
#———————————————————————————————————————————————————————————————————————————————

sub catalog_props
{
	my $o = shift;
	my $r = shift;
	
	my $p = $o->props();
	
	return '<div class="props">' . join('', map { '<div class="' . $_ . '">' . $o->{$_} . '</div>' } keys %$p) . '</div>';
}

sub catalog_preview_text
{
	my $o = shift;
	
	my $len = eval { $o->catalog_root->{'ptextlen'} } || 30;
	
	my $desc = $o->{'desc'};
	
	$desc =~ s/<.*?>/ /sg;
	$desc =~ s/&\w+;?/ /g;
	$desc =~ s/^\s+|\s+$//g;
	
	my @words = split /\s+/, $desc;
	
	$desc = join ' ', @words[0 .. $len-1];
	$desc =~ s/([\.\?\!]+$)|([\,\;\:\-]+$)/$1 || '…'/e || ($desc .= '…') if @words > $len;
	
	return $desc;
}

sub site_preview
{
	my $o = shift;
	
	my $photo_href;
	if ($o->{'smallphoto'} && $o->{'smallphoto'}->exists)
	{
		$photo_href = $o->{'smallphoto'}->href
	}
	elsif ((my $cr = $o->catalog_root)->{'shownophoto'})
	{
		$photo_href = $cr->{'nophotoimg'}->href;
	}
	my $photo = $photo_href ? '<a href="' . $o->site_href . '"><img class="photo" src="' . $photo_href . '"></a>' : undef;
	
	print
	'
		<div class="cat_block">
			<a class="cat_img" href="' . $o->site_href . '"><img alt="'.$o->site_name.'" src="'.$photo_href.'"></a>
			<div class="cat_descr">
				<h3><a href="'.$o->site_href.'">' . $o->site_aname . '</a></h3>
				<p>' . $o->catalog_preview_text(@_) . '</p>
				<span class="price">&nbsp;</span>
			</div>
		</div>
	';
	
	return;
}

sub catalog_currency
{
	my $o = shift;
	my $r = shift;
	
	return $o->{'currency'} || ($o->papa ? $o->papa->catalog_currency($r) : undef);
}

sub catalog_root
{
	my $o = shift;
	
	map { return $_ if $_->isa('modCatalog') } reverse $o->papa_path;
	return undef;
}

sub round
{
	my($number) = shift;
	return int($number + .5);
}

sub site_content
{
	my $o = shift;
	my $r = shift;
	my $count = shift;
	my $class = shift;
	$count = $o->len_relation('child') unless $count;
	my $inc = 0;
	my @wares=$o->get_all; # = grep {!$_->{hidden}} $o->get_relation_interval(1,$count,'child');
	#выводим теги, которые указаны у товаров данного каталога или раздела
	
	print '<div class="text">
							<p class="p1">' . $o->name . '</h1>';
	for my $k(@wares)
	{
print $k->site_preview.'<p>';
next;
		$inc++;
		if (($inc+2) % 3 == 0)
		{
			print '<div class="cat_container" ' . ($class ? $class : '') . '>';
			print '' . ($wares[$inc-1]) ? $wares[$inc-1]->site_preview : '' . '';
			print '' . ($wares[$inc]) ? $wares[$inc]->site_preview : '' . '';
			print '' . ($wares[$inc+1]) ? $wares[$inc+1]->site_preview : '' . '';
			print '</div>';
			print '<div class="cat_line"></div>' if ($inc+2) < @wares;
		}
	}
	print '</div>
		<div class="description">' . $o->{desc} . '</div>';
	return;
}

1;
