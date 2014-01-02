use CMSBuilder::IO;

sub dynoprops
{
	my $o = shift;
	
	return split(/\|/,$system_ini->{ref($o).'.dynoprops'});
}

sub admin_dynoprops
{
	my $o = shift;
	
	my $dsp = {CGI::cookie('aview_dynoprops')}->{'s'} eq '0'?0:1;
	
	print
	'
	<fieldset>
	<legend onmousedown="ShowHide(aview_dynoprops,treenode_aview_dynoprops)"><span class="objtbl"><img class="ticon" id="treenode_aview_dynoprops" src="img/'.($dsp?'minus':'plus').'.gif"><span class="subsel">Добавить/удалить свойство</span></span></legend>
	<div class="padd" id="aview_dynoprops" style="display:'.($dsp?'block':'none').'">
	
	</div>
	</fieldset>
	';
}

sub admin_view
{
	my $o = shift;
	
	$o->SUPER::admin_view(@_);
	
	$o->admin_dynoprops();
}

sub aview
{
	my $o = shift;
	
	my $i;
	return (map {'dynoprop'.++$i} $o->dynoprops()),$o->SUPER::aview(@_);
}

sub props
{
	my $o = shift;
	
	my $p = $o->SUPER::props(@_);
	
	my $i;
	map {$p->{'dynoprop'.++$i} = {'type' => 'string', 'name' => $_} } $o->dynoprops();
	
	return $p;
}