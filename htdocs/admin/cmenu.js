

//——————————————————————————————— Базовые переменные ———————————————————————————

var all_menus = new Object();
var all_menus_code = new Object();
var all_menus_static = new Object();
var last_onclick;
var now_menu;
var body = document.body;
var doc = document;


//——————————————————————————— Вспомогательные функции ——————————————————————————

function OnContext(cmenu,e)
{
	e = e?e:event;
	if(cmenu == undefined) return true;
	try
	{
		if(e.ctrlKey) return true;
	}
	catch(T){}
	
	
	var x,y;
	
	try
	{
		if(!x && !y)
		x = e.clientX + window.pageXOffset, y = e.clientY + window.pageYOffset;
	}
	catch(Error){}
	
	try
	{
		if(!x && !y)
		x = event.x + body.scrollLeft, y = event.y + body.scrollTop;
	}
	catch(Error){}
	
	try
	{
		ShowCMenu(cmenu,x,y);
	}
	catch(Error){}
	
	return false;
}

function ShowCMenu(name,x,y)
{
	if(!all_menus_static[name])
	{
		if(all_menus_code[name] == undefined)
		{
			//if(parent.admin_right == document) alert(parent.tellXY("admin_right"));
			
			rpcall("cmenu.ehtml?url="+name+"&mx="+x+"&my="+y);
			return false;
		}
		else
		{
//alert(all_menus_code[name]);
			eval(all_menus_code[name]);
			all_menus_code[name] = undefined; //
		}
	}
	
	if(all_menus[name] == undefined) return false;
	
	if(now_menu) OnClickAfterContext();
	
	last_onclick = document.body.onclick;
	document.onmousedown = OnClickAfterContext;
	now_menu = all_menus[name];
	
	
	now_menu.show(x,y);
	
	return true;
}

function OnClickAfterContext()
{
	if(now_menu == undefined) return true;
	
	document.body.onclick = last_onclick;
	now_menu.hide();
	now_menu = undefined;
	
	return false;
}

body.elem_del = function(elem)
{
	elem.hide();
}

document.onkeypress = function(e)
{
	e = e || window.event;
	if(e.keyCode != 27) return true;
	
	OnClickAfterContext();
}

//——————————————————————————————— Собственно менюхи ————————————————————————————

//————————————————————— Базовый класс замороченных боксов ——————————————————————

function JBox_show(nx,ny)
{
	if(this.visible) return;
	this.visible = 1;
	this.papa.appendChild(this);
	this.moveto(nx || 0, ny || 0);
}

function JBox_hide()
{
	if(!this.visible) return;
	if(this.son){ this.son.hide(); }
	
	this.visible = 0;
	this.papa.removeChild(this);
}

function JBox_togle()
{
	if(this.visible) this.hide();
	else this.show();
}

function JBox_moveto(nx,ny)
{
	var dw = 0;
	var dh = 0;
	
	//alert(this.style.left);
	
	this.style.left = nx+"px";
	this.style.top = ny+"px";
	
	try
	{
		if(this.visible)
		{
			var thisr = this.getBoundingClientRect();
			var bodyr = document.body.getBoundingClientRect();
			
			dw = thisr.right - bodyr.right + 20;
			dw = (dw>0)?dw:0;
			
			dh = thisr.bottom - bodyr.bottom + 20;
			dh = (dh>0)?dh:0;
		}
	}
	catch(Error){}
	
	this.style.left = (nx - dw)+"px";
	this.style.top = (ny - dh)+"px";
}

function JBox_onmouseover(){ this.ismouseon = 1; }

function JBox_onmouseout(){ this.ismouseon = 0; }

function JBox_elem_add(elem)
{
	if(elem.papa != this)
	{
		elem.papa.elem_del(elem);
		elem.papa = this;
	}
	
	elem.show();
	
	return elem;
}

function JBox_elem_del(elem)
{
	if(elem.papa != this) return;
	
	elem.hide();
	elem.papa = document.body;
}

function JBox_oncontextmenu()
{
	return false;
}

function JBox_onclick()
{
	window.event.cancelBubble = true;
	return false;
}

function JBox_onmouseup(e)
{
	try{ e.stopPropagation() }catch(T){}
	window.event.cancelBubble = true;
	return false;
}

function JBox_onmousedown(e)
{
	try{ e.stopPropagation() }catch(T){}
	window.event.cancelBubble = true;
	return false;
}

function JBox_onselectstart(e)
{
	try{ e.stopPropagation() }catch(T){}
	window.event.cancelBubble = true;
	return false;
}

function JBox_ondragstart(e)
{
	try{ e.stopPropagation() }catch(T){}
	window.event.cancelBubble = true;
	return false;
}

function JBox(tag)
{
	var nobj;
	nobj = document.createElement(tag || "DIV");
	nobj.className = 'cmenu_menu';
	nobj.visible = 0;
	nobj.ismouseon = 0;
	nobj.papa = document.body;
	nobj.son = undefined;
	
	nobj.show			= nobj.JBox_show			= JBox_show;
	nobj.hide			= nobj.JBox_hide			= JBox_hide;
	nobj.togle			= nobj.JBox_togle			= JBox_togle;
	nobj.moveto			= nobj.JBox_moveto			= JBox_moveto;
	nobj.onselectstart	= nobj.JBox_onselectstart	= JBox_onselectstart;
	nobj.ondragstart	= nobj.JBox_ondragstart		= JBox_ondragstart;
	nobj.onclick		= nobj.JBox_onclick			= JBox_onclick;
	nobj.onmouseover	= nobj.JBox_onmouseover		= JBox_onmouseover;
	nobj.onmouseout		= nobj.JBox_onmouseout		= JBox_onmouseout;
	nobj.onmouseup		= nobj.JBox_onmouseup		= JBox_onmouseup;
	nobj.onmousedown	= nobj.JBox_onmousedown		= JBox_onmousedown;
	nobj.elem_add		= nobj.JBox_elem_add		= JBox_elem_add;
	nobj.elem_del		= nobj.JBox_elem_del		= JBox_elem_del;
	nobj.oncontextmenu	= nobj.JBox_oncontextmenu	= JBox_oncontextmenu;
	
	return nobj;
}


//——————————————————————————— Класс меню. Основан на: JBox —————————————————————

function JMenu_hide()
{
	if(this.my_JMISubMenu)
		this.my_JMISubMenu.deselect();
	
	return this.JBox_hide();
}

function JMenu_appendChild(chld)
{
	return this.td.appendChild(chld);
}

function JMenu_onclick()
{
	if(this.sel)
		this.sel.onmouseout();
	
	return this.JBox_onclick();
}

function JMenu()
{
	var nobj;
	nobj = JBox("TABLE");
	
	var ntd = document.createElement('td');
	var ntr = document.createElement('tr');
	var ntbody = document.createElement('tbody');
	
	ntr.appendChild(ntd);
	ntbody.appendChild(ntr);
	nobj.appendChild(ntbody);
	
	nobj.td = ntd;
	
	nobj.cellPadding = 0;
	nobj.cellSpacing = 0;
	
	nobj.hide			= nobj.JMenu_hide			= JMenu_hide;
	nobj.appendChild	= nobj.JMenu_appendChild	= JMenu_appendChild;
	nobj.onclick		= nobj.JMenu_onclick		= JMenu_onclick;
	
	return nobj;
}


//—————————————————— Класс элемента меню. Основан на: JBox —————————————————————

function JMenuItem_onmouseover()
{
	if(this.papa.son)
		this.papa.son.hide();
		
	this.select();
	
	return this.JBox_onmouseover();
}

function JMenuItem_onmouseout()
{
	this.deselect();
	
	return this.JBox_onmouseout();
}

function JMenuItem_deselect()
{
	if(this.papa)
		this.papa.sel = undefined;
	
	this.className = "cmenu_item_out";
}

function JMenuItem_select()
{
	if(this.papa)
		this.papa.sel = this;
	
	this.className = "cmenu_item_on";
}

function JMenuItem_onmousedown()
{
	this.className = "cmenu_item_down";
}

function JMenuItem_relese()
{
	this.deselect();
	window.status = "";
	OnClickAfterContext();
}

function JMenuItem(itext)
{
	var nobj;
	nobj = JBox("DIV");
	
	nobj.className = "cmenu_item_out";
	nobj.innerHTML = itext;
	
	nobj.onmouseover	= nobj.JMenuItem_onmouseover	= JMenuItem_onmouseover;
	nobj.onmouseout		= nobj.JMenuItem_onmouseout		= JMenuItem_onmouseout;
	nobj.deselect		= nobj.JMenuItem_deselect		= JMenuItem_deselect;
	nobj.select			= nobj.JMenuItem_select			= JMenuItem_select;
	nobj.relese			= nobj.JMenuItem_relese			= JMenuItem_relese;
	nobj.onmousedown	= nobj.JMenuItem_onmousedown	= JMenuItem_onmousedown;
	
	return nobj;
}


//—————————— Класс элемента меню с подменю. Основан на: JMenuItem ——————————————

function JMISubMenu_onmouseover(e)
{
	this.JMenuItem_onmouseover();
	this.papa.son = this.smenu;
	
	this.smenu.my_JMISubMenu = this;
	this.smenu.show();
	
	var x,y,w;
	
	try
	{
		if(!x && !y)
		{
			x = this.getBoundingClientRect().left + body.scrollLeft - 2;
			y = this.getBoundingClientRect().top - (this.smenu.getBoundingClientRect().bottom - this.smenu.getBoundingClientRect().top)/2 + body.scrollTop;
			w = this.getBoundingClientRect().right - this.getBoundingClientRect().left;
		}
	}
	catch(T){}
	
	try
	{
		if(!x && !y)
		{
			w = this.clientWidth;
			x = this.papa.style.left.replace(/\D/g,"")*1+2;
			y = this.papa.style.top.replace(/\D/g,"")*1 + this.papa.clientHeight/2 - this.smenu.clientHeight/2;
		}
		
	}
	catch(T){}
	
	this.smenu.moveto(x+w,y);
}

function JMISubMenu_onmouseout()
{
	if(this.papa.son == this.smenu) return;
	return this.JMenuItem_onmouseout();
}

function JMISubMenu_onclick()
{
}

function JMISubMenu_onmousedown()
{
}

function JMISubMenu(itext,smenu)
{
	var nobj;
	nobj = JMenuItem('<div class="cmenu_JMISubMenu">'+itext+'<span class="cmenu_4">&#9658;</span></div>');
	
	nobj.smenu = smenu;
	
	nobj.onmouseover	= nobj.JMISubMenu_onmouseover	= JMISubMenu_onmouseover;
	nobj.onmouseout		= nobj.JMISubMenu_onmouseout	= JMISubMenu_onmouseout;
	nobj.onclick		= nobj.JMISubMenu_onclick		= JMISubMenu_onclick;
	nobj.onmousedown	= nobj.JMISubMenu_onmousedown	= JMISubMenu_onmousedown;
	
	return nobj;
}


//——————————— Класс элемента меню — ссылки. Основан на: JMenuItem ——————————————

function JMIHref_onclick()
{
	this.JMenuItem_relese();
	
	if(this.target)
	{
		this.target.location.href = this.href;
	}
	else
	{
		if(this.targ) this.targ.location.href = this.href;
		
		if(CMS_HaveParent()) parent.admin_right.location.href = this.href;
		else admin_right.location.href = this.href;
	}
}

function JMIHref_onmouseover()
{
	window.status = this.href;
	this.JMenuItem_onmouseover();
}

function JMIHref_onmouseout()
{
	window.status = "";
	this.JMenuItem_onmouseout();
}

function JMIHref(itext,ihref,targ)
{
	var nobj;
	nobj = JMenuItem(itext);
	nobj.href = ihref;
	nobj.target = targ;
	
	nobj.onclick		= nobj.JMIHref_onclick		= JMIHref_onclick;
	nobj.onmouseover	= nobj.JMIHref_onmouseover	= JMIHref_onmouseover;
	nobj.onmouseout		= nobj.JMIHref_onmouseout	= JMIHref_onmouseout;
	
	return nobj;
}


//------------------------------------------------------------------------------
// Класс элемента меню с подтверждением (eval).
// Основан на: JMenuItem
//------------------------------------------------------------------------------

function JMIConfirmCode_onclick()
{
	this.JMenuItem_relese();
	if(!eval(this.code)) return;
	
	return this.JMIHref_onclick();
}

function JMIConfirmCode(itext,ihref,targ,code)
{
	var nobj;
	nobj = JMIHref(itext,ihref,targ);
	nobj.href = ihref;
	nobj.target = targ;
	nobj.code = code;
	
	nobj.onclick		= nobj.JMIConfirmCode_onclick	= JMIConfirmCode_onclick;
	nobj.onmouseover	= JMIHref_onmouseover;
	
	return nobj;
}


//——— Класс элемента меню с подтверждением (confirm). Основан на: JMenuItem ————

function JMIConfirm_onclick()
{
	this.JMenuItem_relese();
	if(!window.confirm(this.text)) return;
	
	return this.JMIHref_onclick();
}

function JMIConfirm(itext,ihref,targ,text)
{
	var nobj;
	nobj = JMIHref(itext,ihref,targ);
	nobj.href = ihref;
	nobj.target = targ;
	nobj.text = text;
	
	nobj.onclick		= nobj.JMIConfirm_onclick	= JMIConfirm_onclick;
	nobj.onmouseover	= JMIHref_onmouseover;
	
	return nobj;
}

//———————————————— Класс линии-разделителя. Основан на: JBox ———————————————————

function JHR()
{
	var nobj;
	nobj = JBox('DIV');
	nobj.className = 'cmenu_hr';
	
	return nobj;
}

//—————————————————— Класс заголовка меню. Основан на: JBox ————————————————————

function JTitle(str)
{
	var nobj;
	nobj = JBox('DIV');
	nobj.className = 'cmenu_title';
	nobj.innerHTML = str;
	
	return nobj;
}


//——————————————————— Класс календарика. Основан на: JBox ——————————————————————

function JCalendar_inc_year()
{
	this.yv++;
	this.refresh()
}

function JCalendar_dec_year()
{
	this.yv--;
	this.refresh()
}

function JCalendar_inc_month()
{
	this.mv++;
	
	if(this.mv > 11)
	{
		this.mv = 0;
		this.inc_year();
	}
	
	this.refresh()
}

function JCalendar_dec_month()
{
	this.mv--;
	
	if(this.mv < 0)
	{
		this.mv = 11;
		this.dec_year();
	}
	
	this.refresh()
}

function JCalendar_refresh()
{
	var d = new Date(0);
	d.setDate(1);
	d.setMonth(this.mv);
	d.setFullYear(this.yv);
	
	var tda = this.net.getElementsByTagName('TD');
	
	var beg = d.getDay()?(d.getDay()):7;
	//alert(d);
	
	
	for(var i=0;i<tda.length;i++)
	{
		tda[i].innerHTML = "";
		tda[i].className = "";
		
		tda[i].onclick = function () {};
		tda[i].onmouseover = function () {};
		tda[i].onmouseout = function () {};
	}
	
	for(var i=beg-1;(i<tda.length)&&(d.getMonth()==this.mv);i++)
	{
		tda[i].innerHTML = d.getDate();
		tda[i].date = d.getDate();
		
		if(d.getDate() == this.dv)
		{
			tda[i].className = "dtd dtd_on";
			tda[i].onclick = function () { this.papa.save(this); }
			tda[i].onmouseover = function () { this.className = "dtd dtd_on" };
			tda[i].onmouseout = function () { this.className = "dtd dtd_on" };
		}
		else
		{
			tda[i].className = "dtd";
			tda[i].onclick = function () { this.papa.save(this); }
			tda[i].onmouseover = function () { this.className = "dtd dtd_on" };
			tda[i].onmouseout = function () { this.className = "dtd" };
		}
		
		d.setDate(d.getDate()+1);
	}
	
	var mnts = ["Январь","Февраль","Март","Апрель","Май","Июнь","Июль","Август","Сентябрь","Октябрь","Ноябрь","Декабрь",];
	
	this.datestr.innerText = mnts[this.mv] + ", " + this.yv + "г.";
	//alert();
}

function JCalendar_save(obj)
{
	this.df.value = obj?obj.date:this.dv;
	this.mf.value = this.mv+1;
	this.yf.value = this.yv;
	
	OnClickAfterContext();
}

function JCalendar_show(x,y)
{
	this.dv = this.df.value;
	this.mv = this.mf.value-1;
	this.yv = this.yf.value;
	
	this.refresh();
	return this.JBox_show(x,y);
}

function JCalendar(df,mf,yf)
{
	var nobj;
	nobj = JMenu();
	
	nobj.td.className = "jcalendar";
	
	nobj.df = document.all[df];
	nobj.mf = document.all[mf];
	nobj.yf = document.all[yf];
	
	var nowtable,nowtbody,nowtr,nowtd;
	
	// Заголовок
	
	nowtable = document.createElement('table');
	nowtable.className = "head";
	nobj.td.appendChild(nowtable);
	nobj.head = nowtable;
	
	nowtbody = document.createElement('tbody');
	nowtable.appendChild(nowtbody);
	
	nowtr = document.createElement('tr');
	nowtbody.appendChild(nowtr);
	
	nowtd = document.createElement('td');
	nowtd.colSpan = 7;
	nowtd.className = "buttons";
	nowtr.appendChild(nowtd);
	
	// Кнопки
	
	var datestr = document.createElement('div');
	datestr.innerHTML = "***";
	datestr.className = "datestr";
	datestr.papa = nobj;
	nowtd.appendChild(datestr);
	nobj.datestr = datestr;
	
	var ltbtn = document.createElement('button');
	ltbtn.innerHTML = "&lt;&lt;";
	ltbtn.papa = nobj;
	ltbtn.onclick = function(){ this.papa.dec_year(); };
	nowtd.appendChild(ltbtn);
	
	ltbtn = document.createElement('button');
	ltbtn.innerHTML = "&lt;";
	ltbtn.papa = nobj;
	ltbtn.onclick = function(){ this.papa.dec_month(); };
	nowtd.appendChild(ltbtn);
	
	ltbtn = document.createElement('button');
	ltbtn.innerHTML = "OK";
	ltbtn.papa = nobj;
	ltbtn.onclick = function(){ this.papa.save(); };
	nowtd.appendChild(ltbtn);
	
	ltbtn = document.createElement('button');
	ltbtn.innerHTML = "&gt;";
	ltbtn.papa = nobj;
	ltbtn.onclick = function(){ this.papa.inc_month(); };
	nowtd.appendChild(ltbtn);
	
	var ltbtn = document.createElement('button');
	ltbtn.innerHTML = "&gt;&gt;";
	ltbtn.papa = nobj;
	ltbtn.onclick = function(){ this.papa.inc_year(); };
	nowtd.appendChild(ltbtn);
	
	// Дни недели
	
	nowtable = document.createElement('table');
	//nowtable.cellPadding = 0;
	//nowtable.cellSpacing = 0;
	nobj.td.appendChild(nowtable);
	nobj.days = nowtable;
	
	nowtbody = document.createElement('tbody');
	nowtable.appendChild(nowtbody);
	
	var wdays = ["Пн","Вт","Ср","Чт","Пт","Сб","Вс",];
	
	nowtr = document.createElement('tr');
	nowtbody.appendChild(nowtr);
	
	for(var ci=0;ci<7;ci++)
	{
		nowtd = document.createElement('td');
		nowtd.innerHTML = wdays[ci];
		nowtd.className = "day";
		
		nowtr.appendChild(nowtd);
	}
	
	// Сетка
	
	nowtable = document.createElement('table');
	//nowtable.cellPadding = 0;
	//nowtable.cellSpacing = 0;
	nobj.net = nowtable;
	nobj.td.appendChild(nowtable);
	
	nowtbody = document.createElement('tbody');
	nowtable.appendChild(nowtbody);
	nowtbody.className = "jcalendar";
	
	for(var ri=0;ri<6;ri++)
	{
		nowtr = document.createElement('tr');
		nowtbody.appendChild(nowtr);
		
		for(var ci=0;ci<7;ci++)
		{
			nowtd = document.createElement('td');
			nowtd.papa = nobj;
			nowtr.appendChild(nowtd);
		}
	}
	
	nobj.refresh	= nobj.JCalendar_refresh	=	JCalendar_refresh;
	nobj.show		= nobj.JCalendar_show		=	JCalendar_show;
	nobj.save		= nobj.JCalendar_save		=	JCalendar_save;
	
	nobj.inc_year		= nobj.JCalendar_inc_year		=	JCalendar_inc_year;
	nobj.dec_year		= nobj.JCalendar_dec_year		=	JCalendar_dec_year;
	nobj.inc_month		= nobj.JCalendar_inc_month		=	JCalendar_inc_month;
	nobj.dec_month		= nobj.JCalendar_dec_month		=	JCalendar_dec_month;
	
	return nobj;
}
