# (с) Леонов П.А., 2005

package Comments;
use strict qw(subs vars);
use utf8;

use CMSBuilder;

sub _admin_right_panels {qw(admin_comments_view)}
sub _rpcs {qw(admin_comments_save admin_comments_add_comment)}

sub _props
{
	'comments'			=> { 'type' => 'object', 'class' => 'CommentsDir', 'name' => 'Свойства' },
}

#———————————————————————————————————————————————————————————————————————————————


sub mp_get
{
	my $o = shift;
	my $key = shift;
	
	map { return $_->{value} if $_->{name} eq $key } $o->{comments}->get_all;
	
	return;
}


sub admin_comments_add_comment
{
	my $o = shift;
	my $r = shift;
	
	do { print "<result><error>Не указано имя нового свойства.</error></result>"; return; } unless $r->{name};
	do { print "<result><error>Класс не публичный.</error></result>"; return; } unless cmsb_classOK($r->{class});
	
	my $to = $r->{class}->cre();
	$to->{name} = $r->{name};
	$o->{comments}->elem_paste($to);
	
	print
	'<result>
		<html><tr><td>' . $r->{name} . ':</td><td><input name="' . $r->{name} . '" class="winput"/></td></tr></html>
		<ok>Добавлено.</ok>
		<script>
		function (r)
		{
			var html = r.responseXML().getElementsByTagName("html")[0];
			var tbody = document.getElementById("comments_table").getElementsByTagName("tbody")[0];
			
			//tbody.appendChild(document.importNode(html, true));
			appendChildsContent(tbody, html);
			
			//alert(tbody.innerHTML);
		}
		</script>
	</result>';
}

sub admin_comments_save
{
	my $o = shift;
	my $r = shift;
	
	print '<result>';
	
	map { $_->admin_comment_save($r) } $o->{comments}->get_all();
	
	print '<ok>Данные успешно сохранены.</ok>';
	#print '<error>' . join(', ',%$r) . '</error>';
	
	print map {"<error>$_</error>"} $o->err_strs;
	
	print '</result>';
}

sub admin_comments_view
{
	my $o = shift;
	
	my $dsp = {CGI::cookie('admin_comments_view')}->{'s'};
	
	print
	'
	<fieldset><legend onmousedown="ShowHide(admin_comments_view,treenode_admin_comments_view)"/>
	<span class="objtbl"><img class="ticon" id="treenode_admin_comments_view" src="img/'.($dsp?'minus':'plus').'.gif"><span class="subsel">Комментарии</span></span></legend>
	<div class="padd" id="admin_comments_view" style="display:'.($dsp?'block':'none').'">
	
	<form action="/srpc/' . $o->myurl . '/admin_comments_save" method="post" onsubmit="return ajax_form_send(event,this)">
	<table class="prop_table" id="comments_table"><tbody>
	';
	
	for my $to ($o->{comments}->get_all()) #sort {$a->name cmp $b->name}
	{
		print '<tr><td width="20%">' . $to->{username} . ':</td><td>' . $to->admin_comment_view . '</td></tr>';
	}
	
	print
	'
	</tbody></table>
	<p align="center"><button type="submit" title="Сохранить изменения"><img src="icons/save.gif" /> Сохранить</button></p>
	</form>
	
	<div style="float:left;padding:1em">' . $o->{comments}->admin_comments_add_list . '</div>
	<div style="float:right;padding:1em"><small><a href="' . $o->{comments}->admin_right_href . '">Дополнительно...</a></small></div>
	
	</div>
	</fieldset>
	';
}
1;
