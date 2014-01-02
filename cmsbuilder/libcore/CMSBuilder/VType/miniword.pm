# (с) Леонов П.А., 2005

package CMSBuilder::VType::miniword;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType';
# Миниворд #####################################################

our $admin_own_html = 1;

sub table_cre {'TEXT'}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	$val =~ s/\"/\\\"/g;
	$val =~ s/script/scr"+"ipt/g;
	$val =~ s/\n/\\n/g;
	$val =~ s/\r//g;
	
	my $tool_bar = $p->{$name}{'toolbar'} || 'CMSBuilder';
	my $full = exists $p->{$name}{'full'}?($p->{$name}{'full'}?'true':'false'):undef;
	my $w = $p->{$name}{'width'};
	my $h = $p->{$name}{'height'};
	
	my $ret = '
	<tr><td colspan="2">
	'.$p->{$name}{'name'}.':<br>
	<script language="JavaScript">
	var '.$name.'_oFCKeditor = new FCKeditor("'.$name.'",'.($w?'"'.$w.'"':'"100%"').','.($h?'"'.$h.'"':'"500px"').',"'.$tool_bar.'","'.$val.'");
	'.$name.'_oFCKeditor.BasePath	= "'.$CMSBuilder::Config::http_aroot.'/fckeditor/";
	'.($full?$name.'_oFCKeditor.Config.FullPage = '.$full.';':'').'
	'.$name.'_oFCKeditor.Create();
	</script>
	</td></tr>
	';
	
	return $ret;
}

sub sview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	$val =~ s/\"/\\\"/g;
	$val =~ s/script/scr"+"ipt/g;
	$val =~ s/\n/\\n/g;
	$val =~ s/\r//g;
	
	my $tool_bar = $p->{$name}{'toolbar'} || 'CMSBuilder';
	my $full = exists $p->{$name}{'full'}?($p->{$name}{'full'}?'true':'false'):undef;
	my $w = $p->{$name}{'width'};
	my $h = $p->{$name}{'height'};
	
	my $ret = '
	<tr><td colspan="2">
	'.$p->{$name}{'name'}.':<br>
	<script language="JavaScript">
	var '.$name.'_oFCKeditor = new FCKeditor("'.$name.'",'.($w?'"'.$w.'"':'"100%"').','.($h?'"'.$h.'"':'"500px"').',"'.$tool_bar.'","'.$val.'");
	'.$name.'_oFCKeditor.BasePath	= "'.$CMSBuilder::Config::http_aroot.'/fckeditor/";
	'.($full?$name.'_oFCKeditor.Config.FullPage = '.$full.';':'').'
	'.$name.'_oFCKeditor.Create();
	</script>
	</td></tr>
	';
	
	return $ret;
}


sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $sname = $ENV{'SERVER_NAME'};
	$val =~ s#((href=|src=)('|"|))http://$sname/#$1/#ig;
	
	return $val;
}

sub aview_old
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	$val =~ s/\&/\&amp;/g;
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;
	$val =~ s/\n/\\n/g;
	$val =~ s/\r//g;
	
	my $ret = '
	<tr><td colspan="2">
	'.$p->{$name}{'name'}.':</b><br>
	<script language="JavaScript">
	var '.$name.'_oFCKeditor;
	'.$name.'_oFCKeditor = new FCKeditor("'.$name.'");
	'.$name.'_oFCKeditor.ToolbarSet = "Basic";
	'.$name.'_oFCKeditor.Width  = "100%";
	'.$name.'_oFCKeditor.Height = 350;
	'.$name.'_oFCKeditor.Value  = "'.$val.'";
	'.$name.'_oFCKeditor.Create();
	</script>
	<br>
	</td></tr>
	';
	
	return $ret;
}

1;