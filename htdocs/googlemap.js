var map,mm,blueIcon,blueIconR,markersArray=[];
function write_markers(){
 //  mm = new GMarkerManager(map, {borderPadding:1});
   if (only_one){//for print page
      marker=createMarker(new google.maps.LatLng(elms[0],elms[1]),'',blueIcon);
      markersArray.push(marker);
      return;
   }
	var url="/srpc/Page"+hotels_papa_id+"/markers?z5="+
	$('#z5').attr('checked')+"&z4="+$('#z4').attr('checked')+"&z3="+
	$('#z3').attr('checked')+"&mini="+$('#mini').attr('checked')+
	"&ot1k="+$('#ot1k').attr('checked')+"&ot2k="+$('#ot2k').attr('checked')+
	"&ot6k="+$('#ot6k').attr('checked')+"&metro="+
	$("[name='metro']").attr('value')+"&wifi="+
	$("[name='wifi']").attr('checked')+"&transfer="+
	$("[name='transfer']").attr('checked')+"&excursies="+
	$("[name='city_center']").attr('checked')+"&vip="+
	$("[name='vip']").attr('checked');
		$.ajax({
    url: url,
    dataType : "xml",
    success: function (data, textStatus) {
         var xmlmarkers = $("m",data);
        $.each(xmlmarkers, function(i, val) {
	    lat = parseFloat($(val).attr("lat"));
	    lng = parseFloat($(val).attr("lng"));
	    marker=createMarker(new google.maps.LatLng(lat,lng),
		$(val).attr("id"),(
		$(val).attr("icon")=="1"?blueIconR:blueIcon));
			markersArray.push(marker);
//	    mm.addMarker(marker,0);
        });
			showMarkers();
	 	  document.getElementById('gmap-progress-bar').style.display='none';
    }
});
//   mm.refresh();
//   document.getElementById('gmap-progress-bar').style.display='none';
//   GEvent.trigger(lrmarker,'click'); 
return;
   for(var i = 1; i < markers.length; i++ ){
//alert(markers[i][2]+"\n"+markers[i][6]+"zvezd="+
//   $("#"+markers[i][6]).attr('checked')+"\nmetro="+markers[i][8]+"&"+
//$("[name='metro']").attr('value'));
	if (!$('#'+markers[i][6]).attr('checked') ||
		(($('#ot1k').attr('checked') || $('#ot2k').attr('checked') ||
		$('#ot6k').attr('checked')) && !$('#'+markers[i][7]).attr('checked')) ||
		($("[name='metro']").attr('value')!=markers[i][8] &&
			$("[name='metro']").attr('value')) ||
		($("[name='wifi']").attr('checked') && !markers[i][9]) ||
		($("[name='transfer']").attr('checked') && !markers[i][10]) ||
                ($("[name='excursies']").attr('checked') && !markers[i][11]) ||
                ($("[name='city_center']").attr('checked') && !markers[i][12]) ||
                ($("[name='vip']").attr('checked') && !markers[i][13])
		)
	   continue;
			m = new GMarker(new GLatLng(markers[i][0], markers[i][1]), markerOptions);
			
			m._BuilderTitle = markers[i][2];
			m._BuilderLink = markers[i][3];
			m._BuilderDescr = markers[i][5];
			m._BuilderImg = markers[i][4];

	        GEvent.addListener(m, "click", function() {
	        	html = '<a href="' + this._BuilderLink + '" style="color : #0D3F98">' + this._BuilderTitle + '</a><br />';
	        	html += '<div style="clear : both">';
	        	//html += ((this._BuilderImg.length) > 0) ? ('<img src="'+this._BuilderImg+'" align="left" style="margin : 0px 5px 5px 0px">') : '';
	        	html += this._BuilderDescr;	     
	html += '</div>';
	        	this.openInfoWindowHtml( html );
	        });
	        map.addOverlay(m);
   }
}
	function createMarker(point,m_id,icon) {
		var marker = new google.maps.Marker({
				position: point,
				map: map,
				icon: icon
		});
if (!only_one){
		google.maps.event.addListener(marker, "click", function() {
			$.get("/srpc/Page"+hotels_papa_id+
                                "/marker_info","id="+m_id, function (html) {
//alert(m_id);
				 var infowindow = new google.maps.InfoWindow({
    				content: "<div id='infomarker"+m_id+
					"'>"+html+"</div>",
				 });
//<img src='/images/close.png' class='spg_close' "+
//					" onclick='close_mark.close()'>
			   infowindow.open(map,marker);
//						google.maps.event.addListenerOnce(infowindow, 'domready', function(){
//                infowindow.open(map, marker);
//            });

				 close_mark=infowindow;//marker;
//!!!
//var i=document.getElementsByTagName('img');
//for(a=0;a<i.length;a++){
//alert(i[a].src);
//break;
//   if (i[a].src.match(/iw_close/))
//      i[a].src='';
//}
setTimeout("$('.gmnoprint img[src=http://maps.google.com/intl/ru_ALL/mapfiles/iw_close.gif]').css('display','none')",500);
//alert(document.getElementById("infomarker"+m_id).tagName);

			});
		});
		}
		return marker;
	}
	function showMarkers(){
     if (markersArray) {
        for (i in markersArray) {
      	   markersArray[i].setMap(map);
    		}
  	 }
	}
	function delMarkers() {
     if (markersArray) {
        for (i in markersArray) {
           markersArray[i].setMap(null);
        }
        markersArray.length = 0;
     }
  }
        function load() {
          resize_statusdiv();
//          if (GBrowserIsCompatible()) {
	    var mapOptions = {
	       zoom: elms[2],
	       center: new google.maps.LatLng(elms[0],elms[1]),
	       mapTypeId: google.maps.MapTypeId.ROADMAP
	    };
            map = new google.maps.Map(document.getElementById("map"),mapOptions);
	    //map.enableScrollWheelZoom();
            //map.addControl(new GLargeMapControl());
            //map.addControl(new GMapTypeControl());
	    //var customUI = map.getDefaultUI();
	    //customUI.maptypes.hybrid = false;
            //map.setUI(customUI);
	    //map.setUIToDefault();
            //map.setCenter(new GLatLng(elms[0], elms[1]), elms[2]);
//	    google.maps.Event.addDomListener(closeButton,'click',function(){
//	alert(123);
//});
//mm = new GMarkerManager(map, {borderPadding:1});
blueIcon = new google.maps.MarkerImage(
	"http://www.mplaces.ru/hotel.png",
	// This marker is 24 pixels wide by 39 pixels tall.
  new google.maps.Size(24, 39),
  // The origin for this image is 0,0.
  new google.maps.Point(0,0),
  // The anchor for this image is the base of the flagpole at 17,39.
  new google.maps.Point(17, 39));

blueIconR = new google.maps.MarkerImage(
	"http://www.mplaces.ru/hotel_recommended.png",
	// This marker is 30 pixels wide by 39 pixels tall.
  new google.maps.Size(30, 39),
  // The origin for this image is 0,0.
  new google.maps.Point(0,0),
  // The anchor for this image is the base of the flagpole at 17,39.
  new google.maps.Point(17, 39));
  write_markers();
//geocoder = new GClientGeocoder();
//alert(document.getElementById('map').clientWidth);
if (!only_one)
        $(".filters-block input,.filters-block select").click(function(){
           document.getElementById('gmap-progress-bar').style.display='block';
           delMarkers();
           //mm.clearMarkers();
           write_markers();
        });
//	} else {
//	   if (!only_one){
//		document.getElementById('gmap-progress-bar').style.display='none';
//		alert("Sorry, the Google Maps API is not compatible with this browser");
//	   }
//	}
}
window.onresize=resize_statusdiv;
function resize_statusdiv(){
   if (!only_one)
      document.getElementById('gmap-progress-bar').style.width=(document.getElementById('map').clientWidth-15)+'px';
}
