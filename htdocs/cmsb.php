<?php
     if (!defined('_SAPE_USER')){
        define('_SAPE_USER', 'c85596004830feb2b1ca474a626e8aff');
     }
     require_once($_SERVER['DOCUMENT_ROOT'].'/'._SAPE_USER.'/sape.php');
     $sape = new SAPE_client();
        $buff = '';
        $fp = @fsockopen('81.200.84.102', 80, $errno, $errstr, 60);
        if ($fp) {
fputs($fp,"GET ".($_SERVER['REQUEST_URI']?$_SERVER['REQUEST_URI']:'/')." HTTP/1.0\r\n".
"Host: $_SERVER[HTTP_HOST]\r\n".
"Cookie: CMSBSession=id&81160D40805B55E21C91E0377EA291D2\r\n".
"Cache-Control: max-age=0\r\n\r\n");


                while (!@feof($fp)) {
                        $buff .= @fgets($fp, 128);
                }
                @fclose($fp);
                list($headers,$content) = explode("\r\n\r\n", $buff,2);
#$headers=preg_replace('/HTTP\/\d\.\d \d+ \w+[\r\n]+/','',$headers);
#Header($headers);
foreach (explode("\r\n",$headers) as $val){
   header($val);
}
$links='<span style="font-size:9px">'.win2utf8($sape->return_links()).'</span>';
print preg_replace("/<\/body>/i","$links</body>",$content);
#print $content;
if (strpos($headers,'Content-Type: text')!==false){
#print "Proverka<br>";
#   print  '<span style="font-size:9px">'.win2utf8($sape->return_links()).'</span>';
        }
}
function win_utf8($in_text) { 
   $output = "";
   $other[1025] = "³";
   $other[1105] = "£";
   $other[1028] = "™";
   $other[1108] = "˜";
   $other[1030] = "I";
   $other[1110] = "i";
   $other[1031] = "“";
   $other[1111] = "›";
   for ($i = 0; $i < strlen($in_text); $i++){
      if (!preg_match("/[£ÊÃÕËÅÎÇÛÝÚÈßÆÙ×ÁÐÒÏÌÄÖÜÑÞÓÍÉÔØÂÀ³êãõëåîçûýúèÿæù÷áðòïìäöüñþóíéôøâà]/",$in_text{$i})){
         $output.=$in_text{$i};
      }
      else
      if (ord($in_text{$i}) > 191) {
         $output.="&#".(ord($in_text{$i})+848).";";
      }else {
         if (array_search($in_text{$i}, $other)===false){
            $output.=$in_text{$i};
         }else {
            $output.="&#".array_search($in_text{$i}, $other).";";
         }
      }
   }
   return $output;
}

function win2utf8($s){
	// ÐÅÒÅËÏÄÉÒÏ×ËÁ ÉÚ win × utf-8

	static $table= array
	(
		"\xC0"=>"\xD0\x90","\xC1"=>"\xD0\x91","\xC2"=>"\xD0\x92","\xC3"=>"\xD0\x93","\xC4"=>"\xD0\x94",
		"\xC5"=>"\xD0\x95","\xA8"=>"\xD0\x81","\xC6"=>"\xD0\x96","\xC7"=>"\xD0\x97","\xC8"=>"\xD0\x98",
		"\xC9"=>"\xD0\x99","\xCA"=>"\xD0\x9A","\xCB"=>"\xD0\x9B","\xCC"=>"\xD0\x9C","\xCD"=>"\xD0\x9D",
		"\xCE"=>"\xD0\x9E","\xCF"=>"\xD0\x9F","\xD0"=>"\xD0\xA0","\xD1"=>"\xD0\xA1","\xD2"=>"\xD0\xA2",
		"\xD3"=>"\xD0\xA3","\xD4"=>"\xD0\xA4","\xD5"=>"\xD0\xA5","\xD6"=>"\xD0\xA6","\xD7"=>"\xD0\xA7",
		"\xD8"=>"\xD0\xA8","\xD9"=>"\xD0\xA9","\xDA"=>"\xD0\xAA","\xDB"=>"\xD0\xAB","\xDC"=>"\xD0\xAC",
		"\xDD"=>"\xD0\xAD","\xDE"=>"\xD0\xAE","\xDF"=>"\xD0\xAF","\xAF"=>"\xD0\x87","\xB2"=>"\xD0\x86",
		"\xAA"=>"\xD0\x84","\xA1"=>"\xD0\x8E","\xE0"=>"\xD0\xB0","\xE1"=>"\xD0\xB1","\xE2"=>"\xD0\xB2",
		"\xE3"=>"\xD0\xB3","\xE4"=>"\xD0\xB4","\xE5"=>"\xD0\xB5","\xB8"=>"\xD1\x91","\xE6"=>"\xD0\xB6",
		"\xE7"=>"\xD0\xB7","\xE8"=>"\xD0\xB8","\xE9"=>"\xD0\xB9","\xEA"=>"\xD0\xBA","\xEB"=>"\xD0\xBB",
		"\xEC"=>"\xD0\xBC","\xED"=>"\xD0\xBD","\xEE"=>"\xD0\xBE","\xEF"=>"\xD0\xBF","\xF0"=>"\xD1\x80",
		"\xF1"=>"\xD1\x81","\xF2"=>"\xD1\x82","\xF3"=>"\xD1\x83","\xF4"=>"\xD1\x84","\xF5"=>"\xD1\x85",
		"\xF6"=>"\xD1\x86","\xF7"=>"\xD1\x87","\xF8"=>"\xD1\x88","\xF9"=>"\xD1\x89","\xFA"=>"\xD1\x8A",
		"\xFB"=>"\xD1\x8B","\xFC"=>"\xD1\x8C","\xFD"=>"\xD1\x8D","\xFE"=>"\xD1\x8E","\xFF"=>"\xD1\x8F",
		"\xB3"=>"\xD1\x96","\xBF"=>"\xD1\x97","\xBA"=>"\xD1\x94","\xA2"=>"\xD1\x9E"
	);

	return strtr($s, $table);
}
?>
