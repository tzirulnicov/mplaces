# (с) Леонов П.А., 2006

package plgnForms::Interface;
use strict qw(subs vars);
use utf8;

use CMSBuilder;
use CMSBuilder::Utils;
#use CMSBuilder::IO;

sub _sview {}

sub class_load
{
#	cmsb_event_reg('template_call:site_content:begin', \&forms_site_content_begin, 'plgnForms::Interface');
#	cmsb_event_reg('template_call:site_content:end', \&forms_site_content_end, 'plgnForms::Interface');
}

sub _rpcs {qw(forms_site_check_xml forms_site_save)}

#———————————————————————————————————————————————————————————————————————————————


sub sview { return shift()->_sview(@_); }

sub forms_site_save
{
	my $o = shift;
	my $r = shift;
	
	print '<result>';
	
	my $res = $o->forms_site_check($r);
	if($res->{'error'})
	{
		print '<error>Ошибка заполнения формы.<error>';
	}
	else
	{
		$o->site_edit($r);
		if ($o->save()) # тут будет проверка на $o->access('w')
		{
			print '<ok>Данные успешно сохранены.</ok>';
		}
	}
	
	print map {"<error>$_</error>"} $o->err_strs;
	
	print '</result>';
}

sub forms_site_check_xml
{
	my $o = shift;
	my $r = shift;
	
	my $res = $o->forms_site_check($r);
	
	print '<response>', (map {"<require>$_</require>"} @{$res->{'require'}}), (map {"<ok>$_</ok>"} @{$res->{'ok'}}), (map {"<normal>$_</normal>"} @{$res->{'normal'}}), (map {"<error>$_</error>"} @{$res->{'error'}}), '</response>';
}

sub forms_site_content_end
{
	my $o = shift;
	my $r = shift;
	
	print '<p>Вы можете <a href="' . $o->site_href . '?form-act=edit">редактировать</a> этот элемент.</p>' if $o->access('r') && $o->access('w');
}

sub forms_site_content_begin
{
	my $o = shift;
	my $r = shift;
	
	if($o->access('w')) #&& $r->{'form-act'} eq 'edit')
	{
		print '<div class="message">Данные введены не полностью.</div>' unless $o->forms_site_valid();
		
		print
		'
		<div class="plgn-forms">
		<form action="/srpc/' . $o->myurl . '/forms_site_save" method="post" plgn-forms-check-href="/srpc/' . $o->myurl . '/forms_site_check_xml" onsubmit="return plgnForms_check(this)" plgn-forms-onload="color">
		<input type="hidden" name="form-act" value="save"/>
		';
		
		$o->site_props($r);
		
		print
		'
		<div class="submit"><button type="submit">Сохранить</button></div>
		</form>
		</div>
		';
		
		return 1;
	}
	
	return;
}

sub forms_site_valid
{
	my $o = shift;
	
	return $o->forms_site_check($o)->{'error'} ? 0 : 1;
}

sub site_edit
{
	my $o = shift;
	my $r = shift;
	
	$o->admin_edit($r,-keys => [$o->_sview()]);
}

sub forms_site_check_self
{
	my $o = shift;
	my $r = shift;
	
	return $o->forms_site_check($o);
}

sub forms_site_check
{
	my $o = shift;
	my $r = shift;
	
	my(@err,@nrml,@ok,@rqr);
	
	my $ps = $o->props();
	
	my $ck;
	for my $p ($o->sview())
	{
		$ck = $ps->{$p}->{'check'};
		
		if($ps->{$p}->{'require'})
		{
			push @rqr, $p;
			$ck ||= qr/\S+/;
		}
		else
		{
			undef $ck unless $r->{$p};
		}
		
		if(ref $ck eq 'CODE')
		{
			if($ck->($r->{$p}))
			{
				push @ok, $p;
			}
			else
			{
				push @err, $p;
			}
		}
		elsif(ref $ck eq 'Regexp')
		{
			if($r->{$p} =~ $ck)
			{
				push @ok, $p;
			}
			else
			{
				push @err, $p;
			}
		}
		else
		{
			push @nrml, $p;
		}
	}
	
	return {@rqr?(require => [@rqr]):(), @ok?(ok => [@ok]):(), @nrml?(normal => [@nrml]):(), @err?(error => [@err]):()};
}

1;