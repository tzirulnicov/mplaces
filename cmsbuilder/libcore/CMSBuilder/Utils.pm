# (с) Леонов П.А., 2005

package CMSBuilder::Utils;
use strict qw(subs vars);
use utf8;

use Encode;
use Carp;
use Digest::MD5;
use MIME::Base64 qw(encode_base64 decode_base64);
use POSIX ('strftime');
use Time::Local;
import POSIX ('locale_h');

use locale;
use Exporter;

our @ISA = 'Exporter';

our @EXPORT =
qw/
&listpms &listdirs &indexA &NOW &myNOW &myNOWhm &epoch2ts &ts2epoch &toDateTimeStr &toDateStr &toRusDate
&toEngDate &estrftime &rstrftime &varr &HTMLfilter &escape &MD5 &translit
&len2size &round2 &var2f &var2f_utf8 &f2var &f2var_utf8 &array2csv &str2csv &path_it &path_abs &parsetpl
&catch_out &decode_utf8_hashref
&sendmail &rus_case
/;

#———————————————————————————————————————————————————————————————————————————————

sub rus_case # < 1000, rus_case(n,[0 нет яблок, 1 яблоко, 2-3-4 яблока, х0-5-6-7-8-9 яблок])
{
	my $n = shift;
	my $wds = shift;
	my $z = shift @$wds;
	my $str;
	
	if($n)
	{
		my @pad = qw(2 0 1 1 1 2 2 2 2 2);
		my($h,$d,$e) = split('',sprintf('%03d',$n));
	
		$str = 10 <= $n && $n <= 19 ? $wds->[2] : $wds->[$pad[$e]]
	}
	else
	{
		$str = $z;
	}
	
	return sprintf($str,$n);
}

sub decode_utf8_hashref($)
{
	my $hr = shift;
	return unless ref $hr eq 'HASH';
	
	my $nhr;
	
	map { $nhr->{Encode::decode_utf8($_)} = Encode::decode_utf8($hr->{$_}) unless ref $hr->{$_}; } keys %$hr;
	
	return $nhr;
}

sub catch_out(&)
{
	my $code = shift;
	
	my $fh;
	my $buff = 'юникод вам';
	open($fh,'>:utf8',\$buff); #:utf8
	#binmode($fh);
	
	my $io = select($fh);
	my @ret = &$code;
	select($io);
	
	close($fh);
	
	return wantarray()?($buff,@ret):$buff;
}

sub parsetpl
{
	my $text = shift;
	my $vars = shift;
	
	$text =~ s/\${(.+?)}/$vars->{$1}/ge;
	
	return $text;
}

# Возвращает массив имен поддиректорий из указанной директории
sub listdirs
{
	my $dir = shift;
	
	my ($dh,@res);
	
	opendir($dh,$dir);
	while(my $file = readdir($dh))
	{
		next if $file eq '.' || $file eq '..';
		push @res, $file if -d $dir.'/'.$file;
	}
	closedir($dh);
	
	return @res;
}

# Возвращает массив имен файлов пакетов из указанной
# директории (без расширения ".pm")
sub listpms
{
	my $dir = shift;
	
	my ($dh,@res);
	
	opendir($dh,$dir);
	while(my $file = readdir($dh))
	{
		next unless -f $dir.'/'.$file;
		next unless $file =~ m/^\w+\.pm$/;
		
		$file =~ s/\.pm$//g;
		push @res, $file;
	}
	closedir($dh);
	
	return @res;
}

# Ищет значение (первый аргумент) в массиве (остальные аргументы)
# и возвращает индекс первого совпадения
sub indexA($@)
{
	my $val = shift;
	
	for(my $i=$[;$i<=$#_;$i++){ if($_[$i] eq "$val"){ return $i; } }
	
	return $[-1;
}

# Возвращает дату в формате MySQL TIMESTAMP
sub NOW(){ return strftime('%Y%m%d%H%M%S',localtime()); }
sub myNOW(){ return strftime('%Y-%m-%d',localtime()); }
sub myNOWhm(){ return strftime('%Y-%m-%d %H:%M',localtime()); }

# Преобразует дату в формате Unix в MySQL TIMESTAMP
sub epoch2ts($){ return strftime('%Y%m%d%H%M%S',localtime($_[0])); }

# Преобразует дату в формате MySQL TIMESTAMP в Unix
sub ts2epoch($)
{
	my $ts = shift;
	#open(FILE,'>/www/evoo/evoo.ru/cmsbuilder/tmp/test.log');
	#print FILE ">".$ts."!!!";
#close(FILE);
        $ts =~ s/\D//g;
	$ts =~	m/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)?(\d\d)?(\d\d)?$/;
	return timelocal($6,$5,$4,$3,$2-1,$1-1900);
}

# Преобразует дату в формате MySQL TIMESTAMP в удобочитаемый вид
# Например, для "20050816174452" вернёт "16 Августа 2005 г., 17:44:52"
sub toDateTimeStr($)
{
	my $ts = shift;
	$ts =~ s/\D//g;
	
	my @mnt = qw/января февраля марта апреля мая июня июля августа сентября октября ноября декабря/;
	
	$ts =~	m/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)?(\d\d)?(\d\d)?$/;
			#  YYYY1     MM2   DD3   HH4   MM5   SS6	
	
	my $date = "$3 ".$mnt[$2-1]." $1, $4:$5:$6";
	$date =~ s/^0+//;
	
	return $date;
}

sub toDateStr($)
{
	my $ts = shift;
	$ts =~ s/\D//g;
	
	my @mnt = qw/января февраля марта апреля мая июня июля августа сентября октября ноября декабря/;
	
	$ts =~	m/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)?(\d\d)?(\d\d)?$/;
			#  YYYY1     MM2   DD3   HH4   MM5   SS6	
	
	my $date = "$3 ".$mnt[$2-1]." $1";
	$date =~ s/^0+//;
	
	return $date;
}

sub toRusDate($)
{
	my $date = shift;
	
	$date =~ s/January/января/i;
	$date =~ s/February/февраля/i;
	$date =~ s/March/марта/i;
	$date =~ s/April/апреля/i;
	$date =~ s/May/мая/i;
	$date =~ s/June/июня/i;
	$date =~ s/July/июля/i;
	$date =~ s/August/августа/i;
	$date =~ s/September/сентября/i;
	$date =~ s/October/октября/i;
	$date =~ s/November/ноября/i;
	$date =~ s/December/декабря/i;
	
	$date =~ s/Jan/янв/i;
	$date =~ s/Feb/фев/i;
	$date =~ s/Mar/мар/i;
	$date =~ s/Apr/апр/i;
	$date =~ s/May/май/i;
	$date =~ s/Jun/июн/i;
	$date =~ s/Jul/июл/i;
	$date =~ s/Aug/авг/i;
	$date =~ s/Sep/сен/i;
	$date =~ s/Oct/окт/i;
	$date =~ s/Nov/ноя/i;
	$date =~ s/Dec/дек/i;
	
	$date =~ s/Mon/нн/i;
	$date =~ s/Tue/вт/i;
	$date =~ s/Wed/ср/i;
	$date =~ s/Thu/чт/i;
	$date =~ s/Fri/пт/i;
	$date =~ s/Sat/сб/i;
	$date =~ s/Sun/вс/i;
	
	return $date;
}

sub toEngDate($)
{
	my $date = shift;
	
	my $oldlcl;
	eval
	{
		$oldlcl = setlocale(&LC_CTYPE);
		setlocale(&LC_CTYPE,"ru_RU.CP1251");
	};
	
	$date =~ s/января/January/i;
	$date =~ s/февраля/February/i;
	$date =~ s/марта/March/i;
	$date =~ s/апреля/April/i;
	$date =~ s/мая/May/i;
	$date =~ s/июня/June/i;
	$date =~ s/июля/July/i;
	$date =~ s/августа/August/i;
	$date =~ s/сентября/September/i;
	$date =~ s/октября/October/i;
	$date =~ s/ноября/November/i;
	$date =~ s/декабря/December/i;
	
	$date =~ s/янв/Jan/i;
	$date =~ s/фев/Feb/i;
	$date =~ s/мар/Mar/i;
	$date =~ s/апр/Apr/i;
	$date =~ s/май/May/i;
	$date =~ s/июн/Jun/i;
	$date =~ s/июл/Jul/i;
	$date =~ s/авг/Aug/i;
	$date =~ s/сен/Sep/i;
	$date =~ s/окт/Oct/i;
	$date =~ s/ноя/Nov/i;
	$date =~ s/дек/Dec/i;
	
	$date =~ s/пн/Mon/i;
	$date =~ s/вт/Tue/i;
	$date =~ s/ср/Wed/i;
	$date =~ s/чт/Thu/i;
	$date =~ s/пт/Fri/i;
	$date =~ s/сб/Sat/i;
	$date =~ s/вс/Sun/i;
	
	eval
	{
		setlocale(&LC_CTYPE,$oldlcl);
	};
	
	return $date;
}

sub estrftime
{
	my $val = strftime(@_);
	
	$val = toEngDate($val);
	$val =~ s/\s+/ /g;
	
	return $val;
}

sub rstrftime
{
	my $val = strftime(@_);
	
	$val = toRusDate($val);
	$val =~ s/\s+/ /g;
	
	return $val;
}

sub varr($$;$)
{
	my $d = (!defined $_[2] && 1) || $_[2];
	
	_cmsb_varr($_[0], $_[1], $d, 0);
}

sub _cmsb_varr($$$$);
sub _cmsb_varr($$$$)
{
	no strict 'refs';
	
	my $c = shift;
	my $var = shift;
	my $d = shift;
	my $n = shift;
	
	return if $n > 50;
	
	my @sv;
	my @tv;
	
	@tv = &{$c . '::' . $var} if *{$c . '::' . $var}{'CODE'};
	
	if ($d)
	{
		push @sv, @tv;
		
		for my $pc (@{$c . '::ISA'})
		{
			push @sv, _cmsb_varr($pc, $var, $d, $n + 1);
		}
	}
	else
	{
		for my $pc (reverse @{$c . '::ISA'})
		{
			push @sv, _cmsb_varr($pc, $var, $d, $n + 1);
		}
		
		push @sv, @tv;
	}
	
	return @sv;
}

#sub varr($$@)
#{
#	my $c = shift;
#	my $var = shift;
#	my $d = shift;
#	my @sv;
#	
#	for my $pc (reverse @{$c.'::ISA'})
#	{
#		push(@sv,varr($pc,$var,$d));
#	}
#	
#	if(*{$c.'::'.$var}{'CODE'}){ $d?(unshift(@sv,&{$c.'::'.$var})):(push(@sv,&{$c.'::'.$var})); }
#	
#	return @sv;
#}

sub HTMLfilter($)
{
	my $val = shift;
	
	$val =~ s/\'/\&#039;/g;
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\&/\&amp;/g;
	$val =~ s/</\&lt;/g;
	$val =~ s/>/\&gt;/g;
	
	return $val;
}

sub escape
{
	my $val = shift;
	
	#$val = uri_escape_utf8($val);
	#$val =~ s/(.)/ord($1).' '/ges;
	#$val =~ s/([^\w ])/'\\x'.sprintf('%02x',ord($1))/ges;
	#$val =~ s/([\n\r"'\\])/'\\x'.sprintf('%02x',ord($1))/ges;
	$val =~ s/([\"\'\\])/\\$1/gs;
	$val =~ s/\s+/ /gs;
	#$val =~ s/\n/\\n/gs;
	#$val =~ s/\r/\\r/gs;
	
	return $val;
}

sub MD5($)
{
	return Digest::MD5::md5_hex($_[0]); #md5_hex md5_base64
}

sub translit($)
{
	my $val = shift;
	$val =~ tr/АБВГДЕЁЖЗИКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯабвгдеёжзиклмнопрстуфхцчшщьыъэюя/ABVGDEEJZIKLMNOPRSTUFHC4WWQIQEUYabvgdeejziklmnoprstufhc4wwqiqeuy/;
	return $val;
}

sub len2size($)
{
	my $len = shift;
	
	my $kb = 1024;
	my $mb = $kb*1024;
	my $gb = $mb*1024;
	my $tb = $gb*1024;
	
	if($len >= $tb){ return round2($len/$tb).' ТБ'; }
	if($len >= $gb){ return round2($len/$gb).' ГБ'; }
	if($len >= $mb){ return round2($len/$mb).' МБ'; }
	if($len >= $kb){ return round2($len/$kb).' КБ'; }
	return $len.' байт';
}

sub round2($) { return (int($_[0]*10)/10); }


sub var2f
{
	my $val = shift;
	my $fname = shift;
	
	my $fh;
	open($fh,'>',$fname);
	binmode($fh);
	print $fh $val;
	close($fh);
}

sub var2f_utf8
{
	my $val = shift;
	my $fname = shift;
	
	my $fh;
	open($fh,'>:utf8',$fname);
	print $fh $val;
	close($fh);
}

sub f2var
{
	my $fname = shift;
	local $/ = undef;
	
	my $fh;
	open($fh,'<',$fname);
	binmode($fh);
	my $val = <$fh>;
	close($fh);
	
	return $val;
}

sub f2var_utf8
{
	my $fname = shift;
	local $/ = undef;
	
	my $fh;
	open($fh,'<:utf8',$fname);
	my $val = <$fh>;
	close($fh);
	
	return $val;
}

sub array2csv($$$)
{
	my ($arr,$padw,$padh) = @_;
	my @es = @$arr;
	
	my %ps;
	for my $to (@es)
	{
		map {$ps{$_} = $to->props()->{$_}->{'name'};} $to->aview();
	}
	
	my @psa = keys %ps;
	
	my $csv = "\n" x $padh;
	
	$csv .= ';' x $padw;
	$csv .= '"Название";';
	for my $key (@psa)
	{
		if($key eq 'name'){ next; }
		$csv .= '"'.str2csv($ps{$key}).'";';
	}
	$csv .= "\n";
	
	for my $to (@es)
	{
		$csv .= ';' x $padw;
		$csv .= '"'.str2csv($to->name()).'";';
		for my $key (@psa)
		{
			if($key eq 'name'){ next; }
			$csv .= '"'.str2csv($to->{$key}).'";';
		}
		$csv .= "\n";
	}
	
	return $csv;
}

sub str2csv($)
{
	my $val = shift;
	$val =~ s/\"/\"\"/g;
	return $val;
}

sub path_it
{
	$_[0] =~ s#\\#\/#g;
	$_[0] =~ s#\.\.\/##g;
	$_[0] =~ s#\.\/##g;
	$_[0] =~ s#[^\w\_\/\.\- \(\)]##g;
	$_[0] =~ s#\/+#\/#g;
}

sub path_abs
{
	if($_[0] ne '/')
	{
		$_[0] =~ s#^\/##;
		$_[0] =~ s#\/$##;
		$_[0] = '/'.$_[0];
	}
}

sub sendmail
{
	my %opts = (ct => 'text/plain', @_);
	
	map { $opts{$_} =~ s/([^\x14-\x19\x21-\x7F]+)/base64m($1)/ge; } qw(to from subj); #[^a-zA-Z\.\_\-\@ <>]+
	
	my $mess =
"To: $opts{to}
From: $opts{from}
Subject: $opts{subj}
Content-type: $opts{ct}; charset=utf-8

$opts{'text'}";
	
	#print $mess;
	
	no warnings 'utf8';
	my $mail;
	return open($mail, '|-', '/usr/sbin/sendmail -t') && binmode($mail) && print($mail $mess) && close($mail);
}

sub base64m
{
	my $str = '=?UTF-8?B?' . encode_base64( encode('UTF-8', $_[0]) ) . '?=';
	$str =~ s/\s//g;
	
	return $str;
}

1;
