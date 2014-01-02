package FIDO::Squish;
use Exporter();
use string;
#use FIDO::Functions;
@ISA=qw(Exporter);
#@EXPORT=qw();
#@EXPORT_OK=qw();
sub new{
   my $class=shift;
   my $self={};
   bless $self, $class;
   # For example, $file="C:/pic/fido3/files/echo/znakomst";
   my $file=shift;
   my $file=shift;
   my @strAr;
   my $str;
   my %ret;
   my $endPosOfCurLetter=0;
   my %messages;
   open(FILE,$file.'.sqd') or die "Cannot open $file echobase !";
   @strAr=<FILE>;
   close(FILE);
   $str=join('',@strAr);
   $self->{'num'}=getLongBinNum(substr($str,4,4));
   $self->{'maxNum'}=getLongBinNum(substr($str,8,4));
   $self->{'startPos'}=getLongBinNum(substr($str,16,4));
   $self->{'uid'}=getLongBinNum(substr($str,20,4));
   $self->{'path2base'}=substr($str,24,80);
   $self->{'path2base'}=~s/\x00//g;
   $self->{'first'}=getLongBinNum(substr($str,104,4));
   $self->{'last'}=getLongBinNum(substr($str,108,4));
   $self->{'firstFrame'}=getLongBinNum(substr($str,112,4));
   $self->{'lastFrame'}=getLongBinNum(substr($str,116,4));
   $self->{'endFile'}=getLongBinNum(substr($str,120,4));
   $self->{'maxMSG'}=hex2dec(unpack("H8",substr($str,127,1).substr($str,126,1)));
   $self->{'saveDays'}=hex2dec(unpack("H8",substr($str,129,1).substr($str,128,1)));
   $self->{'headSize'}=hex2dec(unpack("H8",substr($str,131,1).substr($str,130,1)));
   $self->{'messages'};
#print "Number of messages: ".$ret{'num'}."\n";
#print "Max number of message: ".$ret{'maxNum'}."\n";
#print "Start position of scanning: ".$ret{'startPos'}."\n";
#print "Next number of letter: ".$ret{'uid'}."\n";
#print "Full path to echobase: ".$ret{'path2base'}."\n";
#print "Size of message's headline: ".$ret{'headSize'}."\n";
#print "Number of days of save letters: ".$ret{'saveDays'}."\n";
#print "Max Number of messages: ".$ret{'maxMSG'}."\n";
#print "Displacement of begining of first letter: ".$ret{'first'}."\n";
#print "Displacement of begining of end letter: ".$ret{'last'}."\n";
#print "Displacement of first available frame: ".$ret{'firstFrame'}."\n";
#print "Displacement of last available frame: ".$ret{'lastFrame'}."\n";
#print "Index of end of file: ".$ret{'endFile'}."\n\n";
}
sub nextSQ{
   
$displacement=$ret{'first'};
while ($displacement!=$ret{'endFile'}){
return 0 if substr($str,$displacement,4) ne "\x53\x44\xAE\xAF";
#print "Error !\n" if substr($str,$displacement,4) ne "\x53\x44\xAE\xAF";
$endPosOfCurLetter=getLongBinNum(substr($str,$displacement+4,4));
print "Displacement of begining of next letter: ".$endPosOfCurLetter."\n";
print "Displacement of begining of last letter: ".getLongBinNum(substr($str,$displacement+8,4))."\n";
print "Length of frame: ".getLongBinNum(substr($str,$displacement+12,4))."\n";
print "Length of file: ".getLongBinNum(substr($str,$displacement+16,4))."\n";
print "Length of cludges: ".getLongBinNum(substr($str,$displacement+20,4))."\n";
print "Frame is ".(!getLongBinNum(substr($str,$displacement+24,2))?'un':'')."available\n";
print "FIDO flags: ".getLongBinNum(substr($str,$displacement+28,2))."\n";
print "SQFlag: ".getLongBinNum(substr($str,$displacement+30,2))."\n";
my $fromName=substr($str,$displacement+32,36);
$fromName=~s/\x00//g;
print "From name: ".$fromName."\n";
my $fromName=substr($str,$displacement+68,36);
$fromName=~s/\x00//g;
print "To name: ".$fromName."\n";
my $fromName=substr($str,$displacement+104,72);
$fromName=~s/\x00//g;
print "Subject: ".$fromName."\n";
print "From: ".getLongBinNum(substr($str,$displacement+176,2)).":".
	getLongBinNum(substr($str,$displacement+178,2))."/".
	getLongBinNum(substr($str,$displacement+180,2)).".".
	getLongBinNum(substr($str,$displacement+182,2))."\n";
print "To: ".getLongBinNum(substr($str,$displacement+184,2)).":".
	getLongBinNum(substr($str,$displacement+186,2))."/".
	getLongBinNum(substr($str,$displacement+188,2)).".".
	getLongBinNum(substr($str,$displacement+190,2))."\n";
print "Time of create this letter: ".getLongBinNum(substr($str,$displacement+192,4))."\n";
print "Time of create this later in base: ".getLongBinNum(substr($str,$displacement+196,4))."\n";
print "Flags of this leter in old version of Squish: ".getLongBinNum(substr($str,$displacement+200,2))."\n";
print "Reply-to: ".getLongBinNum(substr($str,$displacement+202,4))."\n";
print "Next reply: ".getLongBinNum(substr($str,$displacement+206,4))."\n";
print "Date and time of create: ".substr($str,$displacement+246,20)."\n\n";
$endPosOfCurLetter=$ret{'endFile'} if !$endPosOfCurLetter;
print substr($str,$displacement+266,$endPosOfCurLetter-266-$displacement);
$displacement=$endPosOfCurLetter;
   return $self;
}
sub getLongBinNum{
   my $num=shift;
   if (length($num)==4){
      return hex2dec(unpack("H8",substr($num,3,1).substr($num,2,1).substr($num,1,1).substr($num,0,1)));
   }
   else {
      return hex2dec(unpack("H4",substr($num,1,1).substr($num,0,1)));
   }
}

sub newSquish{
   # input parameters: num of letters
   my $num=shift;
   my $squish="\x00\x01\x00\x00";
}