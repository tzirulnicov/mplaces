
// Каркас appendChildsContent взял с блога Marzhill Musings
// http://jeremy.marzhillstudios.com/index.php/software-development/using-ajax/
function appendChildsContent(parent, node)
{
	var childNodes = node.childNodes;
	for (var i=0;i<childNodes.length;i++)
	{
		var childNode = childNodes.item(i);
		
		//alert(childNode.nodeName);
		
		if(childNode.nodeType == 1)
		{
			var elem = parent.ownerDocument.createElement(childNode.nodeName);
			
			elem.nodeValue = childNode.nodeValue;
			
			var attrs = childNode.attributes;
			for(var j=0;j<attrs.length;j++)
			{
				elem.setAttribute(attrs.item(j).name, attrs.item(j).nodeValue);
				//alert(elem.nodeName + ":" + attrs.item(j).name + " = " + attrs.item(j).nodeValue);
			}
			
			appendChildsContent(elem, childNode);
			parent.appendChild(elem);
		}
		else if(childNode.nodeType == 2)
		{
			var attr = parent.ownerDocument.createAttribute(childNode.nodeName);
			attr.nodeValue = childNode.nodeValue;
			parent.setAttribute(attr);
		}
		else if (childNode.nodeType == 3)
		{
			parent.appendChild(parent.ownerDocument.createTextNode(childNode.nodeValue + " "));
			continue;
		}
	}
}

function ajax_form_send(e, form)
{
	if(!form) return false;
	e = e ? e : window.event;
	
	var data = stringifyForm(form);
	//alert(data);
	
	var r;
	if(form.method == "post") r = asyncPost(form.action, data);
	else if(form.method == "get") r = asyncGet(form.action + "?" + data);
	
	r.form = form;
	r.onload = function ()
	{
		//alert(this.responseText());
		form_unlock(this.form);
		
		var notice = document.createElement('div');
		notice.className = "form-message";
		this.form.appendChild(notice);
		
		//notice.innerText = this.responseText();
		
		var errs = this.tagTextValues("error");
		for(var i=0;i<errs.length;i++)
		{
			var mes = document.createElement('div');
			mes.className = "error";
			mes.appendChild(document.createTextNode(errs[i]));
			notice.appendChild(mes);
		}
		
		var oks = this.tagTextValues("ok");
		for(var i=0;i<oks.length;i++)
		{
			var mes = document.createElement('div');
			mes.className = "ok";
			mes.appendChild(document.createTextNode(oks[i]));
			notice.appendChild(mes);
		}
		
		//alert(this.form.innerHTML);
		
		var scrs = this.tagTextValues("script");
		for(var i=0;i<scrs.length;i++)
		{
			var func = eval("[" + scrs[i] + "]")[0];
			func(this);
		}
		
		window.setTimeout(function () {form.removeChild(notice)}, errs.length ? 15000 : 3000);
	}
	
	form_lock(form);
	
	return false;
}

function form_lock(fobj)
{
	for(var i=0;i<fobj.elements.length;i++)
	{
		el = fobj.elements[i];
		el.disabled = "disabled";
	}
}

function form_unlock(fobj)
{
	for(var i=0;i<fobj.elements.length;i++)
	{
		el = fobj.elements[i];
		el.disabled = "";
	}
}

//———————————————————— Удобная обертка для XMLHttpRequest ——————————————————————

function HttpRequest()
{
	var http_request = false;

	if(window.XMLHttpRequest) // Mozilla, Safari, ...
	{
		http_request = new XMLHttpRequest();
		if(http_request.overrideMimeType) http_request.overrideMimeType('text/xml');
	}
	else if(window.ActiveXObject) // IE
	{
		try
		{
			http_request = new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch(T)
		{
			try
			{
				http_request = new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch(T) {}
		}
	}
	
	// полезные придумки
	this.hro = http_request;
	this.lastReq = {};
	this.lastRequest = function() { return this.lastReq }
	this.onload = function() {}
	this.onerror = function()
	{
		var errtext = this.tagTextValues('error');
		alert("Во время запроса (" + this.lastRequest().uri + ") возникла проблема (" + this.status() + "):\n" + errtext);
	}
	
	// бесполезные придумки
	this.tagTextValues = function(tname)
	{
		var elems = this.responseXML().getElementsByTagName(tname);
		var res = new Array();
		
		for(var i=0;i<elems.length;i++) res[i] = elems[i].firstChild ? elems[i].firstChild.nodeValue : "";
		
		return res;
	}
	this.tagTextValue = function(tname)
	{
		return this.responseXML().getElementsByTagName(tname)[0].firstChild.nodeValue;
	}
	
	// методы XMLHttpRequest
	this.open = function(method, uri, async, user, password) { this.lastReq = {method:method,uri:uri,async:async,user:user,password:password}; return this.hro.open(method, uri, async, user, password) }
	this.setRequestHeader = function(header, value) { return this.hro.setRequestHeader(header,value) }
	this.send = function(data) { return this.hro.send(data) }
	this.abort = function() { return this.hro.abort() }
	this.getAllResponseHeaders = function() { return this.hro.getAllResponseHeaders() }
	this.getResponseHeader = function(header) { return this.hro.getResponseHeader(header) }
	
	// свойства XMLHttpRequest
	this.readyState = function() { return this.hro.readyState }
	this.responseText = function() { return this.hro.responseText }
	this.responseXML = function()
	{
		var result = this.hro.responseXML;
		if(!result.documentElement && this.hro.responseStream)
		{
			result.load(this.hro.responseStream);
		}
		return result;
	}
	this.status = function() { return this.hro.status }
	this.statusText = function() { return this.hro.statusText }
	
	
	this.onreadystatechange = function()
	{
		if(this.readyState() == 4)
		{
			//if(this.getResponseHeader("XML-RPC-Error")) alert(this.getResponseHeader("XML-RPC-Error"));
			
			if(this.status() == 200)
				this.onload();
			else
				this.onerror();
		}
	}
	
	if(http_request)
	{
		var to = this;
		http_request.onreadystatechange = function()
		{
			to.onreadystatechange();
		}
	}
	else alert('Ошибка! Невозможно создать екземпляр XMLHTTP');
}



function asyncPost(url, params)
{
	var hr = new HttpRequest();
	
	if(!hr) return false;
	
	hr.open('POST', url, true);
	hr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	hr.setRequestHeader("Content-length", params.length);
	hr.send(params);
	
	return hr;
}

function asyncGet(url)
{
	var hr = new HttpRequest();
	
	if(!hr) return false;
	
	hr.onload = function() { alert(this.responseText()); }
	
	hr.open('GET', url, true);
	hr.send(null);
	
	return hr;
}

function syncPost(url, params)
{
	var hr = new HttpRequest();
	
	if(!hr) return false;
	
	hr.open('POST', url, false);
	hr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	hr.setRequestHeader("Content-length", params.length);
	hr.send(params);
	
	return hr.responseText();
}

function syncGet(url)
{
	var hr = new HttpRequest();
	
	if(!hr) return false;
	
	hr.open('GET', url, false);
	hr.send(null);
	
	return hr.responseText();
}


//————————————————————————————— Ручная обработка форм ——————————————————————————

function stringifyForm(fobj)
{
	var val, el;
	var arr = new Array();
	
	for(var i=0;i<fobj.elements.length;i++)
	{
		el = fobj.elements[i];
		
		if(el.type == "select-one") val = el.options[el.selectedIndex];
		if(el.type == "checkbox") val = el.checked?el.value:"";
		if(el.type == "radio") if(el.checked) val = el.value; else continue;
		else val = el.value;
		
		if(el.name) arr.push(encodeURI(el.name) + "=" + encodeURI(val));
	}
	
	return arr.join(";");
}
