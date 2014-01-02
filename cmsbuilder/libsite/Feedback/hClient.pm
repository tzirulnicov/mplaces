#  (с) Вадим Цырульников, 2009

package hClient;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnSite::Object','CMSBuilder::DBI::Object');

sub _cname {'Клиент'}
sub _aview {qw/status summ_period summ_vneseno summ_oplate zayezd otyezd roomID persons fio company fax phone email visa_supp transfer_supp excurs_supp paym_type came_from comments mngr_comment/}
sub _props
{
	'status'		=> { 'type'=>'select', variants=>[
		{t1_no=>'Нет подтверждения брони'},
		{t1_ok=>'Бронь подтверждена'},
		{t1_cancel=>'Бронь аннулирована'},
		{t2_predop=>'Внес предоплату'},
		{t2_oplata=>'Оплатил полностью'},
		{t2_no=>'Не оплачен'},
		{t3_on=>'Въехал'},
		{t4_on=>'Выехал'},
		{t4_otkaz=>'Отказ клиента'}],
#{0=>'Не подтверждён'},
#		{1=>'Заехал'},{2=>'Выехал'}
	name=>'Статус'},
	'summ_period'		=> { 'type'=>'int', length=>15, name=>'Сумма за период'},
	'summ_vneseno'		=> { 'type'=>'int', length=>15, name=>'Сумма внесённая'},
	'summ_oplate'		=> { 'type'=>'int', length=>15, name=>'Сумма к оплате'},
	'zayezd'		=> { 'type'=>'date', name=>'Дата приезда'},
	'otyezd'                => { 'type'=>'date', name=>'Дата отъезда'},
	'roomID'		=> { 'type'=>'int', name=>'Тип комнаты'},
	'persons'		=> { 'type'=>'int', length=>2, name=>'Количество человек'},
	'fio'			=> { 'type'=>'string', name=>'Ф.И.О.'},
	'company'		=> { 'type'=>'string', name=>'Компания'},	
	'fax'			=> { 'type'=>'string', name=>'Факс'},
	'phone'			=> { 'type'=>'string', name=>'Телефон'},
	'email'			=> { 'type'=>'string', name=>'E-Mail'},
	'visa_supp'		=> { 'type'=>'checkbox', name=>'Нужна визовая поддержка'},
	'transfer_supp'		=> { 'type'=>'checkbox', name=>'Нужен трансфер'},
	'excurs_supp'		=> { 'type'=>'checkbox', name=>'Нужна экскурсия'},
	'paym_type'		=> { 'type'=>'select', variants=>[{assist=>'Кредитная карта он-лайн Assist'},
		{fax=>'Кредитная карта по факсу'},
		{sberbank=>'По квитанции Сбербанка'},
		{cash=>'Наличные при въезде в отель'}], 
		name=>'Способ оплаты'},
	'came_from'		=> { 'type'=>'select', variants=>[
		{hz=>'А хрен знает'},
		{guest=>'Он наш постоянный гость'},
		{rekomend=>'По рекомендации знакомых'},
		{yandex=>'Поисковая система Yandex'},
		{rambler=>'Поисковая система Rambler'},
		{google=>'Поисковая система Google'},
		{begun=>'Поисковая система Begun'},
		{rating=>'Отзывы в сети. Рейтинговый сайт'},
		{catalog=>'Специализированный каталог отелей'},
		{book=>'Телефонный справочник'},
		{svadba=>'Свадебный сайт'},
		{press=>'Прочая реклама в печатных изданиях'}], name=>'Как клиент узнал о нас'},
	'comments'		=> { 'type' => 'text', name=>'Комментарий'},
	'mngr_comment'		=> { 'type' => 'text', name=>'Комментарий менеджера'}
}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;
use CMSBuilder::IO::Session;

sub _have_icon 
{
	my $o = shift;
	
	return $o->{'answer'}?'icons/fb_quest.gif':'icons/fb_quest_new.gif';
}

sub name
{
	my $o = shift;
	return $o->{ID}.'. '.substr($o->{'fio'},0,25).(length($o->{'fio'})>25?'...':'');
}

sub site_head {}
=head
sub admin_edit
{
	my $o = shift;
	my $r = shift;
	
	my $res = $o->SUPER::admin_edit($r,@_);
	
	if($o->{'emailme'} && $o->{'email'} && $o->{'answer'} && !$o->{'emailed'})
	{
		my $sended = sendmail
		(
			to		=> $o->{'email'},
			from	=> $o->root->{'email'},
			subj	=> '['.$o->root->{'bigname'}.'] Re: '.$o->papa()->name(),
			text	=> '<strong>Вопрос:</strong><p><dir>' . $o->{'question'} . '</dir></p><strong>Ответ:</strong><p><dir>' . $o->{'answer'} . '</dir></p> -- <p>Оригинал: <a href="' . $o->site_abs_href . '">' . $o->site_abs_href . '</a></p>',
			ct		=> 'text/html; charset=utf-8'
		);
		
		if($sended)
		{
			$o->notice_add('Пользователю отправлено уведомление.');
			$o->{'emailed'} = 1;
		}
		else
		{
			$o->err_add('Ошибка отправки уведомления.');
		}
	}
	
	$sess->{'admin_refresh_left'} = 1;
	
	return $res;
}
=cut
1;
