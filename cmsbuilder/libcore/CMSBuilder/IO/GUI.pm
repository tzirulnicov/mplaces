# (с) Леонов П.А., 2005

package CMSBuilder::IO::GUI;
use strict qw(subs vars);
use utf8;
use CMSBuilder::Utils;

our @ISA = 'Exporter';
our @EXPORT = qw/&admin_name_ex &tree_build &aname/;

sub confirm
{
	my($q,$y,$n) = @_;
	
	return	'
	<p align="center">
	<table class="message_normal">
	<tr><td colspan=2>',$q,'</td></tr>
	<tr><td><button onclick="location.href=\''.$y.'\'">Да</button></td><td><button onclick="location.href=\''.$n.'\'">Нет</button></td></tr>
	</table>
	</p>';
}

sub print_info
{
	my $obj = shift;
	
	my $ne = $obj->err_cnt() > 1?'Возникли ошибки!':'Возникла ошибка!';
	
	if($obj->notice_cnt())
	{
		print '<div onmousedown="this.style.display=\'none\'" class="message"><div class="normal">';
		$obj->notice_print();
		print '</div></div>';
	}
	
	if($obj->err_cnt())
	{
		print '<div onmousedown="this.style.display=\'none\'" class="message"><div class="error"><div class="head">',$ne,'</div>';
		$obj->err_print();
		print '</div></div>';
	}
}

sub aname
{
	my ($name,$icon,$href,$targ) = @_;
	
	return admin_name_ex(-name => $name, -icon => $icon, -href => $href, -target => $targ);
}

sub admin_name_ex
{
	my %opt =
	(
		-name => 'Без имени',
		-icon => 'icons/default.gif',
		-target => 'admin_right',
		@_
	);
	
	if(length($opt{'-name'}) > $CMSBuilder::Config::admin_max_view_name_len){ $opt{'-name'} = substr($opt{'-name'},0,$CMSBuilder::Config::admin_max_view_name_len).'...' }
	
	my $icon	= '<img src="'.$opt{'-icon'}.'"/>';
	my $hicon	= $opt{'-hicon'}?('<img class="shcut_icon" src="'.$opt{'-hicon'}.'"/>'):'';
	
	my $targ = $opt{'-target'}?(' target="'.$opt{'-target'}.'" '):'';
	my $ahref = $opt{'-href'}?('<a href="'.$opt{'-href'}.'"'.$targ.'>'):'';
	
	my $props = ' ';
	if($opt{'-props'})
	{
		my $ph = $opt{'-props'};
		for my $key (keys %$ph)
		{
			$props .= $key.'="'.$ph->{$key}.'" ';
		}
	}

	# проверки, нужно ли перечеркивать элемент, или же менять его фон в зависимости от его свойств (срытый, неопубликован)

	my $mystyle = '';
	my $spanbackcolor = '';
	my $myhint = '';
	my $my4 = '';
	my $disp = '';
	my $tagcount = '';

	# проверяем надо ли проверять на даты устаревания и публикации
	if ( $opt{'-myobject'}->{'usetime'} ) 
	{
		$myhint = 'title="С ' . toDateStr($opt{'-myobject'}->{'start'}) . ' по ' . toDateStr($opt{'-myobject'}->{'end'}) . '"';
		# пришло ли время публиковать или все просрочено
		if ( $opt{'-myobject'}->{'start'} le myNOW() && myNOW() le $opt{'-myobject'}->{'end'} )
		{
			$spanbackcolor = 'background-color: #BBCE9B;';
		}
		else
		{
			$spanbackcolor = 'background-color: #CE9B9B;';
		}
	}

	if ( $opt{'-myobject'}->{'hidden'} )
	{
		$mystyle = 'style="text-decoration: line-through;' . $spanbackcolor . '"';
	}
	else
	{
		$mystyle = 'style="' . $spanbackcolor . '"';
	}
	
	if ( $opt{'-myobject'}->{'status'} )
	{
		if ( $opt{'-myobject'}->{'status'} eq 'new' )
		{
			$spanbackcolor = 'background-color: #BBCE9B;';
		}

		if ( $opt{'-myobject'}->{'status'} eq 'archive' )
		{
			$spanbackcolor = 'background-color: #CE9B9B;';
		}

		$mystyle = 'style="' . $spanbackcolor . '"';
	}
	
	$my4 = '<sup>' . $opt{'-myobject'}->{'my4'} . '</sup>' if ( $opt{'-myobject'}->{'my4'} );
	$disp = '<sup>' . $opt{'-myobject'}->{'disp'}->name() . '</sup>' if ( $opt{'-myobject'}->{'disp'} );
	
	$tagcount = '<sub>' . $opt{'-myobject'}->len_relation('tag') . '</sub>' if ref $opt{'-myobject'} eq 'Tag';

	return '<table class="objtbl"'.($opt{'-selid'}?' id="'.$opt{'-selid'}.'"':'').'><tr><td'.$props.'>'.$ahref.$hicon.$icon.'<span class="subsel" ' . $mystyle . ' ' . $myhint . '>'.$opt{'-name'}. $my4 . $disp . $tagcount . '</span>' . ($ahref?'</a>':'') . '</td></tr></table>';

}

sub tree_build
{
	my $obj = shift;
	my $opts = {@_};
	my $cnt = $opts->{'-cnt'};
	
	return if ++$opts->{'-cnt'} > 50;
	
	unless($obj){ return; }
	
	my $ret = '';
	
	my $nstyle = 'line';
	$nstyle = $obj->{'-last'}?'line_last':$nstyle;
	$nstyle = $obj->{'-first'}?'line_first':$nstyle;
	$nstyle = $obj->{'-first'}&&$obj->{'-last'}?'':$nstyle;
	$nstyle = $obj->{'-root'}?'':$nstyle;
	
	if($obj->{'-elems'} && @{$obj->{'-elems'}} > 0)
	{
		my %node;# = CGI::cookie('dbi_'.$obj->{'-id'});
		my $disp = $node{'s'}?'block':'none';
		my $pic  = $node{'s'}?'minus':'plus';
		my $style = $obj->{'-last'}?'dir_noline':'dir_line';
		
		unless ($opts->{'-flat'})
		{
			if($opts->{'-norooticon'})
			{
				$obj->{'-elems'}->[0]->{'-first'} = 1;
				$ret .= '<div class="'.$style.'">'."\n";
			}
			else
			{
				my $icon;
				
				if($opts->{'-openroot'} && $obj->{'-root'})
				{
					$icon = '<img class="ticon" src="img/nx.gif"/>';
				}
				else
				{
					$icon = '<img class="ticon" id="treenode_'.$obj->{'-id'}.'" src="img/'.$pic.'.gif" onmousedown="ShowHide(dbi_'.$obj->{'-id'}.',treenode_'.$obj->{'-id'}.', 1)"/>';
				}
				
				$ret .= '<div class="'.$nstyle.'">'.$icon.$obj->{'-name'}.'</div>';
				$ret .= '<div id="dbi_'.$obj->{'-id'}.'" myurl="' . $obj->{'-myurl'} . '" class="'.$style.'" style="display: '.$disp.';">';
			}
		}
		
		my $len = @{$obj->{'-elems'}};
		
		for my $i (0 .. $len-2)
		{
			$ret .= tree_build($obj->{'-elems'}->[$i],-cnt => $opts->{'-cnt'});
		}
		
		my $last = $obj->{'-elems'}->[$len-1];
		$last->{'-last'} = 1;
		$ret .= tree_build($last,-cnt => $opts->{'-cnt'});
		
		$ret .= '</div>' unless $opts->{'-flat'};
	}
	else
	{
		$ret .= '<div class="'.$nstyle.'"><img class="ticon" src="img/nx.gif" />'.$obj->{'-name'}.'</div>';
	}
	
	return $ret;
}

1;