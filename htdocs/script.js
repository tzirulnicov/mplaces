/* (с) Вадим Цырульников, 2009 */
function sendMail(obj){
	if (!jQuery('#zayezd').val().match(/^\d{1,2}\.\d{1,2}\.\d{4}$/)){
	   alert('Заполните правильно поле "Дата приезда"');
	   jQuery('#zayezd').focus();
	   return false;
	}
	if (!jQuery('#otyezd').val().match(/^\d{1,2}\.\d{1,2}\.\d{4}$/)){
	   alert('Заполните правильно поле "Дата отъезда"');
	   jQuery('#otyezd').focus();
	   return false;
	}
	if (!jQuery("#fm-email").attr('value').match(/^[a-z0-9\_\-\.]+\@[a-z0-9\_\-\.]+$/i)){
	   alert('Проверьте правильность заполнения поля E-Mail');
	   jQuery("#fm-email").focus();
	   return false;
	}
	if (!jQuery("#fm-fio").attr('value')){
	   alert("Проверьте правильность заполнения поля \"Ф.И.О.\"");
           jQuery("#fm-fio").focus();
	   return false;
	}
  if (!jQuery("#fm-phone").attr('value').match(/\d{2}/)){
	   alert("Проверьте правильность заполнения поля \"Телефон\"");
           jQuery("#fm-phone").focus();
     return false;
  }
	if (0&&!days){
	   alert("Установите правильно дату заезда/отъезда");
           jQuery("#zayezd_day").focus();
	   return false;
	}
        jQuery("#loading").css('display','');
//	jQuery("#mailform").css('display','none');
//        jQuery("#submit_btn").attr('disabled',1);
        jQuery.post(obj.getAttribute('action'), jQuery('#mailform').serialize(),
function(data)
        {
                jQuery('#loading').css('display','none');
                jQuery("#submit_btn").attr('disabled',0);
//alert(data);
		jQuery("#mailform_span").html(data);
/*
                if (data == 'yes')
                {
		   alert('Спасибо. В ближайшее время с Вами свяжется наш администратор');
                }
                else
                {
		   alert('Произошла ошибка, попробуйте повторить ваш запрос позже');
                }*/
        });
//        setTimeout("jQuery('#loading').css('display','none');",500);
        return false;
}
//###Comments######
function documentLoad(){
	if ($('#date'))
	{
		jQuery("#date").calendar({buttonImageOnly: true, yearRange: '2008:2010', defaultDate: 0 })

	}
   jQuery("#OverlayContainer").css('height','0px');
   jQuery("[name='comment_username']").focus( function(){
        if (jQuery(this).attr('value') == 'Ваше имя'){
                jQuery(this).attr('value','')
                jQuery(this).css("color", "#000000")
        }
   });
   jQuery("[name='comment_username']").blur( function(){
        if (!jQuery(this).attr('value')){
                jQuery(this).attr('value','Ваше имя')
                jQuery(this).css("color", "#777777")
        }
   });
   jQuery("[name='comment_email']").focus( function(){
        if (jQuery(this).attr('value') == 'E-mail'){
                jQuery(this).attr('value','')
                jQuery(this).css("color", "#000000")
        }
   });
   jQuery("[name='comment_email']").blur( function(){
        if (!jQuery(this).attr('value')){
                jQuery(this).attr('value','E-mail')
                jQuery(this).css("color", "#777777")
        }
   });
   jQuery("[name='comment_desc']").focus( function(){
        if (jQuery(this).attr('value') == 'Ваш отзыв'){
                jQuery(this).attr('value','')
                jQuery(this).css("color", "#000000")
        }
   });
   jQuery("[name='comment_desc']").blur( function(){
        if (!jQuery(this).attr('value')){
                jQuery(this).attr('value','Ваш отзыв')
                jQuery(this).css("color", "#777777")
        }
   });
   if (document.getElementById('mailform')){
      //jQuery('.inner-page').css('margin-left','25px');
      if (jQuery('[name=roomID]').val()==null)
	jQuery('#mailform').html('<h3 style="color:red">Извините, но бронирование номеров в указанной гостинице в данный момент невозможно</h3>');
   }
   if (jQuery("#manager_comment_submitbtn").attr('disabled')==1)
      jQuery("#manager_comment_submitbtn").attr('disabled',0);
//123
}
function otzivi_submit(box){
   if (jQuery('[name=comment_desc]').attr('value').match(/[<>]+/)){
      alert("В комментариях не допустим HTML код.\nЛибо, в тексте комментарияиспользуются угловые скобки, что запрещено.");
      return false;
   }
        var act = box.getAttribute("action")+
        '?comments_mode=save&comment_desc='+
        jQuery('[name=comment_desc]').attr('value')+'&comment_username='+
        jQuery('[name=comment_username]').attr('value')+'&comment_email='+
        jQuery('[name=comment_email]').attr('value')+'&comment_emailme='+
        (document.getElementsByName('comment_emailme')[0].checked?1:0)+
	'&comment_verifytext='+jQuery('#verifytext').val();;
        if (!act) return;
        document.getElementById('comment_submit').style.display='none';
        document.getElementById('comment_indicator').style.display='';

        var r = asyncGet(act + "&checked=" + (box.checked ? 1 : 0));

        r.onload = function ()
        {
                jQuery('#comments_div').html(r.responseText()+'<p style="padding:5px">');
        }
        setTimeout("document.getElementById('comment_submit').style.display=''",500);
        setTimeout("document.getElementById('comment_indicator').style.display='none'",500);

   return false;
}

