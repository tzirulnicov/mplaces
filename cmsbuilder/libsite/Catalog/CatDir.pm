# (с) Леонов П. А., 2005

package CatDir;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnCatalog::Member','CMSBuilder::DBI::Array');

sub _cname {'Раздел'}
sub _aview {qw/name photo desc onpage previewtype title_child dont_view_props dont_view_second_price/}
sub _have_icon {1}
sub _template_export{qw/block_content_rand/}
use CMSBuilder;
sub _props
{
	'previewtype'	=> { 'type' => 'select', 'variants' => [{'text'=>'текст'},{'list'=>'список подразделов'}], 'name' => 'Краткое описание' },
	'title_child'	=> {'type'=>'string',name=>'Заголовок детей'},
	'dont_view_props' => {'type'=>'bool',name=>'Не отображать тех. хар-ки'},
	'dont_view_second_price' => {'type'=>'bool',name=>'Не отображать вторую цену'}
}

#———————————————————————————————————————————————————————————————————————————————

sub block_content_rand
{
# delete this function!
print "Function block_content_rand() not exist!";
return 1;
        my $o = shift;
        my $r = shift;
	my $count=2;
        my $inc = 0;
	my @ware;
	my $dbh=$CMSBuilder::DBI::dbh->prepare('SELECT ID from 
		dbo_CatWareSimple where PAPA_CLASS="CatDir" and PAPA_ID=?
		order by rand() limit 4');
	$dbh->execute($o->{ID});
        while (@ware=$dbh->fetchrow_array)
        {
                $inc++;
   print '</div>' if (($inc%2) && $inc!=1);
   print '<div class="container">' if ($inc%2);
   cmsb_url('CatWareSimple'.$ware[0])->site_preview($count);
        }
print '</div>';
        return;
}

sub catalog_preview_text
{
	my $o = shift;
	
	if($o->{'previewtype'} eq 'list')
	{
		return join('', map { $_->site_aname() } $o->get_page(0));
	}
	else
	{
		return $o->SUPER::catalog_preview_text(@_);
	}
}

1;
