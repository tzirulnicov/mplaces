# (с) Леонов П.А., 2005

package CMSBuilder::VType::webfile;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType';
our $filter = 1;
our $dont_html_filter = 1;
# Содержимое файла итак не фильтруется - $val содержит имя файла.
# А данные читаются из потока.

# 'file'		=> { 'type' => 'file', 'msize' => 100, 'ext' => [qw/zip doc xls txt/], 'name' => 'Картинка' },

# Любой файл ######################################################

use CMSBuilder::Utils;

sub table_cre {'VARCHAR(50)'}

sub filter_load
{
	my $c = shift;
	#my ($name,$val,$obj,$r) = @_;
	
	# my $c = shift;
	# return CMSBuilder::VType::webfile::object->new(@_);
}

sub filter_save
{
	my $c = shift;
	return $_[1]->name(@_);
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	#unless($obj->{$name}){ $obj->{$name} = $c->filter_load(@_); }

	return $obj->{$name}->aview(@_);
}

sub sview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	#unless($obj->{$name}){ $obj->{$name} = $c->filter_load(@_); }

	return $obj->{$name}->sview(@_);
}

sub aedit
{
	# my $c = shift;
	# my ($name,$val,$obj,$r) = @_;
	# # 
	# # unless($obj->{$name}){ $obj->{$name} = $c->filter_load(@_); }
	# # 
	# $obj->{$name}->aedit($name,$val,$obj,$r);
	# return $obj->{$name};
}

sub del
{
	# my $c = shift;
	# $_[1]->del(@_);
}

sub copy
{
	# my $c = shift;
	# my ($name,$val,$obj,$nobj) = @_;
	# 
	# return $val->copy(@_);
}


#———————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————————————————————————————————————————————


package CMSBuilder::VType::webfile::object;
use strict qw(subs vars);
use utf8;

use CMSBuilder::Utils;
use plgnUsers;

sub new
{
	my $c = shift;
	
	my $o = {};
	bless($o,$c);
	
	$o->init(@_);
	
	return $o;
}

sub ext_list
{
	my $o = shift;
	my $p = $o->{'_prop'};
	
	return @{$p->{'ext'}}
}

sub msize
{
	my $o = shift;
	my $p = $o->{'_prop'};
	
	return $p->{'msize'} || 256;
}

sub init
{
	my $o = shift;
	
	$o->{'_pname'} = shift;
	$o->{'_val'} = shift;
	$o->{'_obj'} = shift;
	
	unless($o->{'_obj'}){ return; }
	
	$o->{'_prop'} = $o->{'_obj'}->props()->{$o->{'_pname'}};
}

sub aedit
{
	my $o = shift;
	my $name = shift;
	my $val = CGI::param($name);shift();
	my $obj = shift;
	my $r = shift;
	
	unless ($group->{'files'})
	{
		if($val){ $obj->err_add('Запись файлов для Вашей группы не разрешена.') }
		return $obj->{$name};
	}
	
	if ($val)
	{
		$o->save_fh($val, $val);
		
		return;
	}
	else
	{
		if($r->{$name.'_todel'})
		{
			$o->del();
			return;
		}
	}
	
	return;
}

sub save_fname
{
	my $o = shift;
	my $fname = shift;
	
	open my $fh, '<', $fname or do { Carp::carp "Can`t open $fname"; return };
	
	$o->save_fh($fname, $fh);
	
	close $fh;
	
	return 1;
}

sub save_fh
{
	my $o = shift;
	my $fname = shift;
	my $fh = shift;
	
	my $obj = $o->{'_obj'};
	
	my $ext;
	
	$fname =~ s#\\#\/#g;
	$fname =~ s#.*\/##;
	$fname =~ m#^(.+)\.(\w+)$#;
	
	($fname,$ext) = ($1,$2);
	
	$fname = translit($fname);
	$fname =~ s/\W/_/g;
	
	$ext = lc($ext);
	
	if( indexA($ext,map {lc($_)} $o->ext_list) < 0 && ($o->ext_list)[0] ne '*' )
	{
		$obj->err_add('Расширение файла «'.$ext.'» недопустимо.');
		return;
	}
	
	$o->del();
	
	{
		my $num;
		do
		{
			$o->{'_val'} = $fname.$num.'.'.$ext;
			$num++;
		}
		while($o->exists())
	}
	
	my $newf;
	
	unless ( open $newf, '>', $o->path )
	{
		$obj->err_add('Невозможно открыть файл для записи: ' . $o->path . '.');
		return;
	}
	
	binmode $fh;
	binmode $newf;
	
	my $len;
	my $buff;
	
	while ( read $fh, $buff, 2048 )
	{
		print $newf $buff;
		$len += 2048;
		
		if ($len >= $o->msize * 1024)
		{
			$obj->err_add('Файл "' . $o->name . '" (' . $o->{_prop}->{name} . ') слишком велик: более ' . len2size($len) . '.');
			return;
		}
	}
	close $newf;
}

sub aview
{
	my $o = shift;
	
	my ($file_href,$file_del,$not_perm,$block);
	
	my $p = $o->{'_prop'};
	
	if($o->exists()){ $file_href = '<br/><a href="'.$o->href().'" target="_new">Показать в полный размер (в новом окне)</a>'; }
	
	return $file_href;
#	'
#	<input '.$block.' type="file" cols="30" name="'.$o->{'_pname'}.'">
#	<div class="file_acts">'.$file_del.'</div>
#	<div class="file_acts"><a href="#" onclick="alert(\'Допустимые расширения: '.$ext_list.'.\\nМаксимальный размер: '.$o->max_size_t().$not_perm .'\'); return false;">Справка... '.$file_href.'</a></div>
#	';
}

sub sview
{
	my $o = shift;
	
	my ($file_href,$file_del,$not_perm,$block);
	
	my $p = $o->{'_prop'};
	
	if($o->exists()){ $file_href = '<br/><a href="'.$o->href().'" target="_new">Показать в полный размер (в новом окне)</a>'; }
	
	return $file_href;
#	'
#	<input '.$block.' type="file" cols="30" name="'.$o->{'_pname'}.'">
#	<div class="file_acts">'.$file_del.'</div>
#	<div class="file_acts"><a href="#" onclick="alert(\'Допустимые расширения: '.$ext_list.'.\\nМаксимальный размер: '.$o->max_size_t().$not_perm .'\'); return false;">Справка... '.$file_href.'</a></div>
#	';
}

sub copy
{
	my $o = shift;
	my ($name,$val,$obj,$nobj) = @_;
	
	my $no = ref($o)->new($name,$o->{'_val'},$nobj);
	
	unless($o->exists()){ return $no; }
	
	$o->{'_val'} =~ m#^(.+)\.(\w+)$#;
	my ($fname,$ext) = ($1,$2);
	
	my $num;
	do
	{
		$no->{'_val'} = $fname.$num.'.'.$ext;
		$num++;
	}
	while($no->exists());
	
	my $fdata = f2var($o->path());
	var2f($fdata,$no->path());
	
	#print join(', ',%$no);
	return $no;
}

sub name
{
	my $o = shift;
	return $o->{'_val'};
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
	return $o->msize * 1024;
}

sub max_size_t
{
	my $o = shift;
	return len2size($o->max_size());
}

sub del
{
	my $o = shift;
	unlink($o->path());
	$o->{'_val'} = '';
}

sub exists
{
	my $o = shift;
	return -f $o->path();
}

1;
