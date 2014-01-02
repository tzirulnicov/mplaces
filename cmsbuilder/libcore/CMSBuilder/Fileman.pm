# (с) Леонов П.А., 2005

package CMSBuilder::Fileman;
use strict qw(subs vars);
use utf8;

import CGI 'param';
use plgnUsers;

our
(
	$act,$dolist,
	
	$uldir,$uhdir,$chdir
);

sub uldir { return $CMSBuilder::Config::path_userdocs.'/'.$user->myurl; }
sub uhdir { return $CMSBuilder::Config::http_userdocs.'/'.$user->myurl; }

sub action
{
	my $c = shift;
	unless($group->{'files'}){ return; }
	
	$act = param('act');
	$dolist = 1;
	
	$uldir = $c->uldir();
	$uhdir = $c->uhdir();
	unless(-d $uldir){ mkdir($uldir) }
	
	$chdir = param('chdir');
	path_it($chdir);
	$chdir = $chdir?'/'.$chdir.'/':'/';
	
	if($act)
	{
		my $iact = 'rpc_'.$act;
		if(__PACKAGE__->can($iact)){ __PACKAGE__->$iact(); }
		else{ print 'Нет такой функции.<br>'; }
	}
	
	print '<br>';
	
	if($dolist){ $c->list(); }
}

sub list
{
	my($fname,$act,$ahref,@fs,@ds,$ncd,$ud);
	
	print '<blockquote>';
	
	$ncd = $chdir;
	$ncd =~ s/[^\/]+\/*$//;
	
	opendir($ud,$uldir.$chdir) || print('!!!');
	while($fname = readdir($ud))
	{
		if($fname eq '.' or $fname eq '..'){ next; }
		
		if(-f $uldir.$chdir.$fname){ push @fs, $fname; }
		elsif(-d $uldir.$chdir.$fname){ push @ds, $fname; }
	}
	closedir($ud);
	
	$ahref = '<a ondrop="alert(event.dataTransfer.getData(\'text\'))" href="?chdir='.$ncd.'">';
	print $ahref,'<img border="0" width="16" height="16" src="'.fileman_icon($uldir,$uhdir,$chdir,'..').'"></a>&nbsp;&nbsp;',$ahref,'Вверх...','</a><br>';
	
	print '<br>';
	
	for $fname (@ds)
	{
		$ahref = '<a href="?chdir='.$chdir.$fname.'/">';
		print delicon($fname),$ahref,'<img border="0" width="16" height="16" src="'.fileman_icon($uldir,$uhdir,$chdir,$fname).'"></a>&nbsp;&nbsp;',$ahref,$fname,'</a><br>';
	}
	
	print '<br>';
	
	print '<table class="fileman"><tr><td valign="top">';
	
	for $fname (@fs){ print delicon($fname),'<br>'; }
	
	print '</td><td><div ondragend1="location.href = location.href" id="files_list">';
	
	for $fname (@fs)
	{
		$ahref = '<a ourl="'.$fname.'" href="'.$uhdir.$chdir.$fname.'">';
		print '<img border="0" align="left" src="'.fileman_icon($uldir,$uhdir,$chdir,$fname).'">&nbsp;&nbsp;',$ahref,$fname,'</a><br>';
	}
	
	print '</div></td></tr></table>';
	
	print '</blockquote><br><br>';
	
	print
	'
	<form action="?" method="post" enctype="multipart/form-data">
		<input type="hidden" name="chdir" value="',$chdir,'">
		<input type="hidden" name="act" value="add">
		<input type="file" name="file">
		<input type="submit" value="Сохранить">
	</form>
	
	<form action="?" method="post">
		<input type="hidden" name="chdir" value="',$chdir,'">
		<input type="hidden" name="act" value="mkdir">
		<input type="text" name="dname">
		<input type="submit" value="Создать">
	</form>
	';
}

sub delicon
{
	my $fname = shift;
	return '<a onclick="return doDel()" href="?act=del&fname='.$fname.'&chdir='.$chdir.'"><img src="img/x.gif"></a>&nbsp;';
}

sub rpc_del
{
	my $fname = param('fname');
	path_it($fname);
	$fname =~ s#.*\/##s;
	
	print( (unlink($uldir.$chdir.$fname)|rmdir($uldir.$chdir.$fname))?"Файл успешно удалён.":"Невозможно удалить файл" );
}

sub rpc_mkdir
{
	my $dname = param('dname');
	path_it($dname);
	$dname =~ s#.*\/##s;
	
	print mkdir($uldir.$chdir.$dname)?"Директория успешно создана.":"Невозможно создать директорию";
}

sub rpc_add
{
	my $nfile = param('file');
	my $nfname = "$nfile";
	my $nfh;
	
	path_it($nfname);
	$nfname =~ s#.*\/##s;
	
	$nfname =~ m/\.(\w+)$/;
	my $ext = $1;
	
	if(index(' eml ehtml asp php php3 phtml php4 php5 cgi pl ',' '.lc($ext).' ') >= 0){ print 'Расширение ',$ext,' недопустимо!'; return; }
	
	open($nfh,'>',$uldir.$chdir.$nfname);
	binmode($nfh);
	binmode($nfile);
	my $buff;
	while(read($nfile,$buff,2048)){ print $nfh $buff; }
	close($nfh);
	
	print 'Файл "',$nfname,'" успешно сохранён.<br>';
}



sub fileman_icon
{
	my $ldir = shift;
	my $hdir = shift;
	my $chdir = shift;
	my $fname = shift;
	my $lf = $ldir.$chdir.$fname;
	
	our %mime =
	(
		'jpg' => 'self',
		'gif' => 'self',
		'png' => 'self',
		'bmp' => 'self',
		'ico' => 'self'
	);
	
	if(-d $lf){ return $CMSBuilder::Config::http_userdocs.'/icons/directory.gif'; }
	
	my $ext = $fname;
	$ext =~ s/.*\.//;
	if($mime{$ext} eq 'self'){ return $hdir.$chdir.$fname; }
	if(-f $CMSBuilder::Config::path_userdocs.'/icons/'.$ext.'.gif'){ return $CMSBuilder::Config::http_userdocs.'/icons/'.$ext.'.gif'; }
	
	return $CMSBuilder::Config::http_userdocs.'/icons/default.gif';
}

sub path_it
{
	$_[0] =~ tr/абвгдеёжзийклмнопрстуфхцчшщьыъэюя/abvgdeejziyklmnoprstufhc4ww_i_eua/;
	$_[0] =~ tr/АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯ/ABVGDEEJZIYKLMNOPRSTUFHC4WW_I_EUA/;
	$_[0] =~ s/\\/\//g;
	$_[0] =~ s/\.\///g;
	$_[0] =~ s/\.\.\///g;
	$_[0] =~ s/[^\w\_\/\.\-]//g;
	$_[0] =~ s/(^\/)|(\/$)//g;
	$_[0] =~ s/\/+/\//g;
}


1;