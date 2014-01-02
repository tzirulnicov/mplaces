var otkaz=0;
function check_save(){
   if (otkaz)
      return confirm('Вы подтверждаете отказ клиента?')?true:false;
   if (jQuery('[name=status]').val()=='t3_on' && 
	jQuery('#summ_period').html()!=jQuery('#summ_vneseno').val()){
      alert('Для заезда клиента необходимо, чтобы была полная оплата номера');
      return false;
   }
   return true;
}
function hpanel_mngrcomment_send(){
   if (!jQuery('[name=manager_comment]').val()){
      alert("Пожалуйста, введите что-нибудь");
      return false;
   }
        jQuery('#manager_comment_loading').css('display','');
        jQuery("#manager_comment_submitbtn").attr('disabled',1);
        jQuery.post(jQuery('#manager_comment_form').attr('action'), jQuery('#manager_comment_form').serialize(),
function(data)
        {
                jQuery('#manager_comment_loading').css('display','none');
                jQuery("#manager_comment_submitbtn").attr('disabled',0);
                if (data == 'yes')
                {
			alert('Комментарий успешно сохранён');
                } else {
			alert('Не удалось сохранить комментарий');
		}
        });
  return false;
}
