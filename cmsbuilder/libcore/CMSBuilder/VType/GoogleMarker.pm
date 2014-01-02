# (с) http://www.technocat.ru/

package CMSBuilder::VType::GoogleMarker;
use strict qw(subs vars);
use utf8;
use CMSBuilder;

our @ISA = 'CMSBuilder::VType';
# Маркер на карте гугл ####################################################

sub table_cre {' VARCHAR(255) '}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;        
        
        return '
            <input type="hidden"  style="width : 100%" id="',$name,'" name="',$name,'" value="',$val,'">
	    <input type="text" id="search_address"><input type="button" onclick="searchAddress()" value="Найти адрес">
            <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAQjofXjf8rI6r4AogwRg24xTmEemehnhnLGpB4DW9SHQLbMAVIBTBS2gvP0KLYWgkyKkDuBGxIDkZhQ" type="text/javascript"></script>
            <div id="',$name,'_map" style="width : 100%; height : 300px">
            
            <script type="text/javascript">
		var map = null;
		var geocoder = null;
	    
		function searchAddress(){
		    var address = document.getElementById(\'search_address\').value;
		    
		    if (geocoder) {
			geocoder.getLatLng(
			  address,
			  function(point) {
			    if (!point) {
			      alert("Адрес \"" + address + "\" не найден.");
			    } else {
			      map.setCenter(point, 13);
			      var marker = new GMarker(point);
			      map.addOverlay(marker);
			      marker.openInfoWindowHtml(address);
			    }
			  }
			);
		      }
		}
	    
                if (GBrowserIsCompatible()) {
		    geocoder = new GClientGeocoder();
                    map = new GMap2(document.getElementById("',$name,'_map"));
                    
                    map.addControl(new GLargeMapControl());
                    map.setCenter(new GLatLng(' , (($val eq ',' || $val eq '') ? '59.940224,30.315742,12' : $val), '), 9);
                    
                    var marker = new GMarker(map.getCenter(), {draggable: true});
                    
                    GEvent.addListener(marker, "dragend", function() {
                        var t = this.getLatLng();
                        document.getElementById("',$name,'").value = (t.y + "," + t.x);
                    });
                    
                    map.addOverlay(marker);                            
                };
            </script>';        
}

sub sview
{
	
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
        my @val = split(',', $val);
        
        return '<input type="text" name="'.$name.'" value="'.@val[0].' || '.@val[1].'">';
}

1;
