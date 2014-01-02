package Comment;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::DBI::Object);

sub _cname {'Комментарий'}

sub _props
{
	username		=> { type => 'string', name => 'Имя юзера' },
	email		=> { type => 'string', name => 'E-Mail'},
	emailme		=> {type=>'bool',name=>'Имя юзера'},
	desc		=> { type => 'miniword', 'name' => 'Текст' },
}

sub _aview {qw(username email emailme desc)}

#———————————————————————————————————————————————————————————————————————————————

sub admin_comment_save
{
	my $o = shift;
	my $r = shift;
	
	$o->{desc} = $r->{$o->{username}};
	$o->save();
}

sub admin_comment_view
{
	my $o = shift;
	
	return '<input class="winput" type=text name="' . $o->{username} . '" value="' . $o->{desc} . '">';
}

sub admin_comment_add
{
	my $c = shift;
	
	return '<input class="winput" type=text name="" value="">';
}

sub site_preview{
   my $o=shift;
   print '				<dt style="color:red">'.$o->{username}.'</dt>
					<dd>'.$o->{desc}.'</dd>';
}

1;
