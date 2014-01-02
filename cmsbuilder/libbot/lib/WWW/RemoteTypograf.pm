package WWW::RemoteTypograf;

use vars qw ($VERSION);
$VERSION = '1.0';

#	WWW::RemoteTypograf.pm
#	Perl-implementation of WWW.RemoteTypograf class (web-service client)
#	
#	Copyright (c) Art. Lebedev Studio | http://www.artlebedev.ru/
#
#	Typograf homepage: http://typograf.artlebedev.ru/
#	Web-service address: http://typograf.artlebedev.ru/webservices/typograf.asmx
#	WSDL-description: http://typograf.artlebedev.ru/webservices/typograf.asmx?WSDL
#	
#	Default charset: UTF-8
#
#	Version: 1.0 (August 30, 2005)
#	Author: Andrew Shitov (ash@design.ru)
#
#
#	Example:
#		use WWW::RemoteTypograf;
#		my $remoteTypograf = new WWW::RemoteTypograf ('Windows-1251');
#		#my $remoteTypograf = new WWW::RemoteTypograf();
#		print $remoteTypograf->ProcessText ("\"Вы все еще кое-как верстаете в \"Ворде\"?\n - Тогда мы идем к вам!\"");

use LWP::UserAgent;

sub new
{
	my $who = shift;
	my $encoding = shift;

	my $class = ref ($who) || $who;
	my $this = {
		'entityType' => 4,
		'useBr' => 1,
		'useP' => 1,
		'maxNobr' => 3,
		'encoding' => $encoding ? $encoding : 'UTF-8'
	};
	bless $this, $class;

	return $this;
}

sub htmlEntities
{
	my $this = shift;
	$this->{'entityType'} = 1;
}

sub xmlEntities
{
	my $this = shift;
	$this->{'entityType'} = 2;
}

sub mixedEntities
{
	my $this = shift;
	$this->{'entityType'} = 4;
}

sub noEntities
{
	my $this = shift;
	$this->{'entityType'} = 3;
}

sub br
{
	my $this = shift;
	my $value = shift;
	$this->{'useBr'} = $value ? 1 : 0;
}

sub p
{
	my $this = shift;
	my $value = shift;
	$this->{'useP'} = $value ? 1 : 0;
}

sub nobr
{
	my $this = shift;
	my $value = shift;
	$this->{'maxNobr'} = $value ? $value : 0;
}

sub ProcessText
{
	my $this = shift;
	my $text = shift;

	$text =~ s{&}{&amp;}gm;
	$text =~ s{<}{&lt;}gm;
	$text =~ s{>}{&gt;}gm;

	my $typographed = $this->SOAPProcessText ($text);
	
	$typographed =~ s{&amp;}{&}gm;
	$typographed =~ s{&lt;}{<}gm;
	$typographed =~ s{&gt;}{>}gm;

	return $typographed;
}

sub SOAPProcessText
{
	my $this = shift;
	my $text = shift;

	my $SOAPBody = <<"SOAPBODY";
<?xml version="1.0" encoding="$this->{'encoding'}"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
	<ProcessText xmlns="http://typograf.artlebedev.ru/webservices/">
	  <text>$text</text>
      <entityType>$this->{'entityType'}</entityType>
      <useBr>$this->{'useBr'}</useBr>
      <useP>$this->{'useP'}</useP>
      <maxNobr>$this->{'maxNobr'}</maxNobr>
	</ProcessText>
  </soap:Body>
</soap:Envelope>
SOAPBODY

	my $userAgent = LWP::UserAgent->new;
	my $request = HTTP::Request->new ('POST' => 'http://typograf.artlebedev.ru/webservices/typograf.asmx');
	$request->content ($SOAPBody);
	my $response = $userAgent->request ($request);

	my $SOAPResponse = $response->content;

	my ($processTextResult) = $SOAPResponse =~ m{<ProcessTextResult>\s*(.*?)\s*</ProcessTextResult>}ms;
	return $processTextResult;
}

1;
