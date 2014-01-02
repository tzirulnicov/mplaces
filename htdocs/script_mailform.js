function mailform_change_type(){
    if (!jQuery("#mailform_type0").attr('checked')){
      jQuery('#tr_tel').css('display','');
      jQuery('#tr_email').css('display','none');
      jQuery('#tr_msg').css('display','none');
    }else{
      jQuery('#tr_tel').css('display','none');
      jQuery('#tr_email').css('display','');
      jQuery('#tr_msg').css('display','');
    }
}
function documentLoad(){
   jQuery("#submit_btn").attr('disabled',0);
   jQuery("[name='mailform_type']").change( function(){
      mailform_change_type();
   });
   mailform_change_type();
   jQuery("[name='msg']").attr('value','Введите что-нибудь...');
   jQuery("[name='msg']").css("color", "#777777");
   jQuery("[name='msg']").focus( function(){
        if (jQuery(this).attr('value') == 'Введите что-нибудь...'){
                jQuery(this).attr('value','');
                jQuery(this).css("color", "#000000");
        }
   });
   jQuery("[name='msg']").blur( function(){
        if (!jQuery(this).attr('value')){
                jQuery(this).attr('value','Введите что-нибудь...');
                jQuery(this).css("color", "#777777");
        }
   });
   jQuery("[name='tel']").attr('value','+7 495 789 99 09');
   jQuery("[name='tel']").css("color", "#777777");
   jQuery("[name='tel']").focus( function(){
        if (jQuery(this).attr('value') == '+7 495 789 99 09'){
                jQuery(this).attr('value','')
                jQuery(this).css("color", "#000000")
        }
   });
   jQuery("[name='tel']").blur( function(){
        if (!jQuery(this).attr('value')){
                jQuery(this).attr('value','+7 495 789 99 09')
                jQuery(this).css("color", "#777777")
        }
   });
   jQuery("[name='fio']").attr('value','Имя');
   jQuery("[name='fio']").css("color", "#777777");
   jQuery("[name='fio']").focus( function(){
        if (jQuery(this).attr('value') == 'Имя'){
                jQuery(this).attr('value','')
                jQuery(this).css("color", "#000000")
        }
   });
   jQuery("[name='fio']").blur( function(){
        if (!jQuery(this).attr('value')){
                jQuery(this).attr('value','Имя')
                jQuery(this).css("color", "#777777")
        }
   });
   jQuery('[name=email]').attr('value','Введите свой E-Mail');
   jQuery('[name=email]').css("color", "#777777");
   jQuery("[name='email']").focus( function(){
        if (jQuery(this).attr('value') == 'Введите свой E-Mail'){
                jQuery(this).attr('value','')
                jQuery(this).css("color", "#000000")
        }
   });
   jQuery("[name='email']").blur( function(){
        if (!jQuery(this).attr('value')){
                jQuery(this).attr('value','Введите свой E-Mail')
                jQuery(this).css("color", "#777777")
        }
   });

}
function sendMail(obj)
{
	var str='Проверьте правильность ввода поля: ';
	jQuery("[name=fio]").css('border','');
        jQuery("[name=tel]").css('border','');
        jQuery("[name=email]").css('border','');
        jQuery("[name=msg]").css('border','');
	if (
//!jQuery("[name=fio]").attr('value').match(/\w/) ||
		!jQuery("[name=fio]").attr('value') ||
		jQuery("[name=fio]").attr('value')=='Имя'){
		alert(str+'"Имя и фамилия"');
		jQuery("[name=fio]").css('border-color','red');
                jQuery("[name=fio]").focus();
		return false;
	}
        if (!jQuery("#mailform_type0").attr('checked') && (!jQuery("[name=tel]").attr('value').match(/\d/) ||
		!jQuery("[name=tel]").attr('value').match(/^[\d\(\) \+\-]+$/) ||
		jQuery("[name=tel]").attr('value')=='+7 495 789 99 09')){
                alert(str+'"Контактный телефон"');
                jQuery("[name=tel]").css('border-color','red');
                jQuery("[name=tel]").focus();
		return false;
        }
        if (jQuery("#mailform_type0").attr('checked') && !jQuery("[name=email]").attr('value').match(/^[\-\_\w\d]+\@[\-\_\w\d]+\.[\-\_\w\d\.]+$/)){
                alert(str+'"E-Mail"');
                jQuery("[name=email]").css('border-color','red');
                jQuery("[name=email]").focus();
                return false;
        }
        if (jQuery("#mailform_type0").attr('checked') && (jQuery("[name=msg]").attr('value').length<2 ||
		jQuery("[name=msg]").attr('value')=='Введите что-нибудь...')){
                alert(str+'"Текст сообщения"');
                jQuery("[name=msg]").css('border-color','red');
                jQuery("[name=msg]").focus();
                return false;
        }
        jQuery("#loading").css('display','');
        jQuery("#submit_btn").attr('disabled',1);
        jQuery.post(obj.action, jQuery('#mailform').serialize(),
function(data)
        {
		jQuery('#loading').css('display','none');
	        jQuery("#submit_btn").attr('disabled',0);
                if (data == 'yes')
                {
                        alert('Сообщение успешно отправлено.')
                        jQuery("[name='fio']").attr('value','')
                        jQuery("[name='tel']").attr('value','')
                        jQuery("[name='email']").attr('value','')
                        jQuery("[name='msg']").attr('value','')
//                        tb_remove()
                }
                else
                {
                        alert("Не удалось отправить сообщения.\nПожалуйста, повторите попытку позже.");
                }
        });
//        setTimeout("('#loading').css('display','none');",500);
        return false;
}

