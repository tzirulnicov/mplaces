#!/usr/bin/perl
$db_enable=1;
$db_host='localhost';
$db_type='mysql';
$db_login='goga';
$db_password='07080900';
$db_table='bchotels';
$db_prefix='phpmw';
#------------------
$ourName="Vadim Tzirulnicov";# ���� ��� � �������� �� ����������
$systemAddress='2:550/278.400';# netmail ����� ������
$ourAddress='2:5020/1665.4';# ����� ��������� ������
$linkAddress='2:550/278';#����� ����, ���� ������� �����
$ifix_language='russian';# ���� ("rus" ��� "eng")
#$systemAddress='2:5020/1665.4';# netmail ����� ������
#$ourAddress='2:5020/1665.4';# ����� ��������� ������
#$linkAddress='2:5020/1665';#����� ����, ���� ������� �����
$SMTPServer='tz.ints.ru';#SMTP-������, ������� ����� ������������ ��� �����������
$sessionPassword='';#������ �� ������. �� ����� 8 ��������
#$pathToMSG='C:/pic/fido3/netmail';
$pathToMSG='files/netmail';# ���� � ���������� NETMAIL
# ���� � ���������� �������� ��������� NETMAIL � ���-����� (������������ ��������)
$pathToPKT='files/inbox';
#$pathToPKT='C:\pic\FIDO3\FILES\inbox';# INBOUND
$pathToOutbound='files/outbox';
#$pathToOutbound='C:\pic\FIDO3\FILES\outbox';
# ���� ������ � MySQL ���� ���������, �� ������ ������ � ������ ����������
#$pathToTemp='C:\pic\FIDO3\TEMP';
$pathToTemp='files/temp';
#$pathToPasswordList='';# ���� � �����, � ������� �������� ������ �������
$pathToLog='logs';# ���������� �������� ���-������.
$originFile='files/origin.txt';
$originEnable=1;#1 or 0
$tearlineEnable=1;#1 or 0
$tearlineText="InternetFix v%VERSION%";
# For newsbot.pl
$pathToImages='logs/images';
$newsbot_from="robot\@tz.ints.ru";# Only email, without fromname !
#$newsbot_forumurl="http://tz.ints.ru/forum/viewforum.php?f=8";
# !!! This username must be exist in datatable phpmw_users !!!
$newsbot_bloguser='InternetFix';
#------------------
$maxLogFileSize='32k';# ����. ������ ���-�����
$errorMailNotify=1;# �������� �� �� ������� �� �����
$errorMailBox='tz@tz.ints.ru';# ��� E-Mail. ���� �������, ������ �������� �� NetMail.
#$errorMailFrom='"InternetFix" <tzirulnicov@webclass.ru>';
$errorMailSubject='Error in my code';
# ���� ������ ����� ��� ������ ������� "Web" � Questionaire Tools

$quoteDailyUser=300;# ������� ����� �� ������� ������������ ����������, � ����������
$quoteDailyAllUsers=1200;# ������� ����� �� ���� ������������� ����������, � ����������
$quoteDailyLimit=10485760;# ������� ����� �� ��������� ������, � ������
$quoteBaseLimit=1000;# ����� �� ���������� ������� � ���� ������� ���� �� ���. ������, � ������

# ��� "1" ����� ������������ ������, ��������� �� ����� �����, � �� ������ �� $systemAddress
$evalMailToAllAddress=1;# �������� ������ � ���-�������
# ���� ������� �������� $pathToSquishCFG, �� ���������� � ���� ����� ������� ������
$pathToSquishCFG='/home/html/files/squish.cfg';
# ���� �� ����������� Net::Binkd, ������� ���� � ������� ������:
$pathToBinkdCFG='files/binkd.cfg';

$defaultChmod='777';# ��������� �����, � �������� ����� ����������� ����������

###########################################Links#####################################
# �������� ������� ���������� ������ �� ��������.
# ��, � ����� ������ ����� ��� �����, ������� � ����� Squish.cfg (��. $pathToSquishCFG)
# �������-������ ������� � $linkAddress. ��������� ��� ���� �� �������.
# ���� � Squish.cfg ����� ������ ����, �� ������������� ����, �� ������ � ���������������
# ��� ��� ����� ���������� �� $linkAddress.
# ���� ��������� ����� ����� �����������.
# ������� ��������� ���������� ����� ��������
# ���� �����-���� �������� �� ������, �� ��� �������� ��������� ������ ("no" ��� "0")
# LinkName - �� ����� 36 ��������
# Password - �� ����� 8 ��������

# �������
$links_link[0]->{'LinkAddress'}='2:5020/1665';
$links_link[0]->{'OurAddress'}='2:5020/1665.4';
$links_link[0]->{'LinkName'}='Katya Khodak';
$links_link[0]->{'Password'}='';
$links_link[0]->{'AutoAreaCreate'}=1;

$links_link[1]->{'LinkAddress'}='2:550/278';
$links_link[1]->{'OurAddress'}='2:550/278.400';
$links_link[1]->{'LinkName'}='Vladislav Mushchinskih';
$links_link[1]->{'Password'}='';
$links_link[1]->{'Host'}='xpge.homeip.net';
$links_link[1]->{'AutoAreaCreate'}=1;

$links_link[2]->{'LinkAddress'}='2:2432/260';
$links_link[2]->{'OurAddress'}='2:2432/260.400';
$links_link[2]->{'LinkName'}='Oleg Lobachev';
$links_link[2]->{'Password'}='';
$links_link[2]->{'Host'}='oal-fido.no-ip.org';
$links_link[2]->{'AutoAreaCreate'}=1;

# ���������
#$links_link[2]->{'LinkAddress'}='36:5020/36';
#$links_link[2]->{'OurAddress'}='36:5020/0';
#$links_link[2]->{'LinkName'}='Lala Lalaev';
#$links_link[2]->{'Password'}='';
#$links_link[2]->{'Downlink'}=1;

#######################################Internet Wizard#################################

$useInternet=0;

#######################################Zakaz Wizard#################################

# ���������� ���������� �� �������� �� ������ � ��������� ����/��������, ���� ������������ � ������� ������

$useZakaz=1;

$zakaz_dayUserInternetLimit=700;# ������� ����������� �� ������� ��������-������������ � ���������� (0 - ��� �����������)
$zakaz_weekUserInternetLimit=0;# ���������
$zakaz_monthUserInternetLimit=0;# ��������
$zakaz_dayInternetLimit=14000;# ��������� ������� �����������
$zakaz_weekInternetLimit=0;# ��������� ���������
$zakaz_monthInternetLimit=0;# ��������� ��������
#
#$zakaz_dayUserFIDOLimit=700;# ������� ����������� �� ������� ��������-������������ � ���������� (0 - ��� �����������)
#$zakaz_weekUserFIDOLimit=0;# ���������
#$zakaz_monthUserFIDOLimit=0;# ��������
#$zakaz_dayFIDOLimit=14000;# ��������� ������� �����������
#$zakaz_weekFIDOLimit=0;# ��������� ���������
#$zakaz_monthFIDOLimit=0;# ��������� ��������
#
#$zakaz_workTime='1:00-9:00';# �������� �������, � ������� ����� �������� �����
$zakaz_resultServer='10.102.31.6';# ������, �� ������� ����� ����������� ���������� ����� (���� �������� � e-mail, �������� � ������ �����������)
$zakaz_resultServerDir='/incoming/Zakaz';# � ����� ����� ������� ����� ����������� ���������
$zakaz_tempDir='/home/ftp/incoming/zakaz/temp';# ����� �� �������, � ������� ����� ����������� ������, ������� ����� ������� ���������� ����� ���������� �� ������ $resultServer
$zakaz_timeout='30';# ������� �������� ������ �� ��������, � ��������
$zakaz_resultServerHash=1;
#
$zakaz_mailSendingFromEMail='tz@tz.ints.ru';
$zakaz_mailSendingFromName='Downloader Robot';# � ������ e-mail'� ����� ���������� ����������� � ��������� �������� �������������
$zakaz_mailSendingSubj="��������� ������� URL� %url";# ���� ������ � ������������ � ���������� ������� ������������
$zakaz_mailSendingText=<<ZAKAZ_END;
         ������������ !
 ��������, ��� ����� � ����������� ���� ������� %query_url ��������,
� �� ��� ������ �� ������� � ������� %ftp_server.
 ������ � ����, ��� ���� ����� �� ���� ������� ����� �������� ������
2 ���, ����� ���� ����� �������.
ZAKAZ_END
$zakaz_mailSendingTextNotFound=<<ZAKAZ_END2;
         ������������ !
 ��������, ��� ��� ����������� ����������� ���� ������� %query_url
��������� ������. ��������� ������� �����: ���� ��� ������ �������
�� ��������� ���� �����, ��� ���������� ������
������ �������� ���� ��������� (��������, ��� ���������),
���� ������ �� ������, ���� ����� ����� ���������� ������ ������.
���� �� �������, ��� ��� ������ ������, �������� ��� ������������:
tz (������) ints.ru.

   � ����� ������, ����������� ��������� ���� �����: %ftp_server.
�����, �� �� ����-�� ����� ��� � �������. :)
ZAKAZ_END2

############################################Binkd######################################

$useBinkd=1;
#"1" - ������ "Binkd", "2" - ���������� ������ Net::Binkd. ��� ���� ��������� ���. Binkd
$binkd_type=1;
# ���� � ����� (������������ ��� $binkd_type, �������� �� ����)
$binkd_path='files/binkd';
# ���� binkd_type!=2
$binkd_conf='files/binkd.cfg';
# �������� ��������� � �������. �������� ! ������ ����� ����������� ��� ������
# ������ �������, ���� � ������� ������ ���� � ���� �� ����_�_config.pl/logs/binkd.log !
$binkd_poll=30;

############################################Tosser#####################################

# �����������: ������ �� ������������ ����� ".*UT" � �������� � ��������� �������

# ������������ �� ���������� ������
$useTosser=0;
# ������� ����� � ��������, �� ���������� ������������ ��������.
# ��������, ���� �������� � ���������� ������, � �� ������������� ��������� �� ��� �
#���� �����. ����� �� �������� ���� ������� �������, ����� �� �������.
$tosser_delNonNetmail=0;

############################################Tracker#####################################

$useTracker=0;
# �������� �� ��, ��� ���� �������� �� ����������. ��� ���� ��� �����, ������������
# �� ������, ����� ������������ ������� ���� (�� $ourAddress)
$autopiloteMode=1;
# ������������� ���� � ��������� ������������ ������� ���������� ���� ���������� ����
$pathToNodelist='files/nodelist';

########################################Download Manager################################

# ��� "0" ����� ������������ ������� �� ������� ������.
# ���� � ��� ��� ����������� ������� � ��������, � ������� ������ �� ���������� �� �����,
# �� ������ ��� ��������� ������� ������� ����� �������� �� �����, �������� �
# �������� �� ��������� ����������
$downloadManagerEnable=1;
# ��� ������������ ������ ���������� � ��������� ������� ����� ������������ � ������,
# ������� ������� ����������� � �������������� ����������.
$downloadManagerSVKludgesPrefix='RFC';
# HTML::Parse ������������ ������. ������������� �� ������� HTML::TreeBuilder
# � HTML::FormatText ���������� �������������� ����������. ���� ��� �� ������������,
# ����� ������� ������ ������ ��������� �������������� HTML->Plain Text.
# ��� ���� ��������������� ����������� ���� � �������� ����, ��� �� ���������.
$downloadManagerUseHTMLModules=0;
$socketTimeOut=10;#������� ��������� ���������� � ��������
$socketWaitResponse=30;#����� �������� ������ ����� ����� ��� ���������� � ��������

###########################################FaqServer####################################

# ����, ������ �� ������� ��������� ������ �� ����� ������������ (����� ������� ��� ������)
# ������� ��������� �� ����� ��������
@ignoreFrom=('Mail Delivery Subsystem','FTrack','MS Network Security Section',
		'Network Message System',"MAILER-DAEMON\@mail1.newsletters.net");
# �������� �� ����� � ���������� �������� ������������
$faqServerSendReports=1;

#########################################Log Analizer###################################

$logAnalyzerEnable=1;
# ���� �������. ��������� �������� - ��. �����. ����� � "Posting Wizard"
$postReportsIn='2:5020/1665.4';
$postReportsSubject='�����';
$numOfTopReports=10;# top n �������
$postReportsPeriod='7';# 1(���������)/7(������ ������)/30(������ �����)/365(��������)
# ������ �����������, ������ �� ���������� � ������� ������� ���������
# ������: ['�����������',�������������_�������� (��.����)]
$logLevel=2;# 0 - �� �������� �� ������� ���������� ���������,
#1 - �������� ��������� ������ �������� ����������, 2 - ���� �����������
$logConsole=1;# ���� $logLevel=1: 1 - �������� � � ���, � �� �������, 0 - ������ �� �������
@logAnalyzerEchos=(
['ru.znakomstva>����������',7],
['mo.apartments>����������',7],
['mo.apartments.talk>����������',7]
);
#######################################Posting Wizard#################################

$postingEnable=1;# 'yes' or 'no'
$postingInNewsFromEmail='tz@tz.ints.ru';# E-Mail ��� �������� � �������� ��������� ��� �������� ������� � news-������
$postingInNewsFromName='InternetFix';
# ������: [���_�������,����_�������,������������� (����)]
# ��������� �������� "���_�������":
# usenet-����������� (��������:news_server), ���� (���_�����)
# 				E-Mail (e-mail:pop_server:login:password)
# ��������� �������� "����_�������":
# ��� ���� (��������/����_������), E-Mail (e-mail/����) (������ ��� ����������� ������� $errorMailServer),
# �������� 'test.txt' ����� �������� � templates/posting, 'files/faq/test.txt' -
# - ����:/�������_����������/files/faq/test.txt, ����� ����� ������� ���������� ����
@postingItems=(
['apartments.rls','mo.apartments>Rules',7],
['apartments_talk.rls','mo.apartments.talk>Rules',7],
['znakomstva.rls','ru.znakomstva>Rules',7],
['files.bbs','su.chainik.faq>List of topics',30],
['filesInet.bbs','ru.internet.faq>Internet FAQ',30],
['files/faq/hmr/files.bbs','su.chainik.faq>����',30]
);
#['filesNew.bbs','su.chainik.faq>New topics',7],
#['sucompold.faq','su.comp.old>������ ������� FAQ-������� Su.Comp.Old',7]
#);
=head
['files/faq/oldpcfaq.htm','su.comp.old>FAQ Of Su.Comp.Old',30],
['files/faq/oldpcfaq_cpu.htm','su.comp.old>FAQ I. CPU. i4004-P233MMX',30],
['files/faq/oldpcfaq_cpu2.htm','su.comp.old>FAQ I - 2. CPU. Cyrix 6x86-PIII Xeon',30],
['files/faq/oldpcfaq_cpu3.htm','su.comp.old>FAQ I - 3. CPU. Pentium 4',30],
['files/faq/oldpcfaq_mb.htm','su.comp.old>FAQ II. Motherboards: chipsets',30],
['files/faq/oldpcfaq_mb2.htm','su.comp.old>FAQ II - 2. Motherboards: test, bus, repair',30],
['files/faq/oldpcfaq_rom.txt','su.comp.old>FAQ III. Operating memory',30],
['files/faq/oldpcfaq_ram.htm','su.comp.old>FAQ IV. ARVID, HDD Functionality',30],
['files/faq/oldpcfaq_ram2.htm','su.comp.old>FAQ IV - 2. HDD size questions',30],
['files/faq/oldpcfaq_ram3.htm','su.comp.old>FAQ IV - 3. Zero track, MHDD, Bad Blocks',30],
['files/faq/oldpcfaq_mpg.htm','su.comp.old>FAQ IV - 4. Fujitsu MPG: History, Device, Notice',30],
['files/faq/oldpcfaq_mpg2.htm','su.comp.old>FAQ IV - 5. Fujitsu MPG',30],
['files/faq/oldpcfaq_ram4.htm','su.comp.old>FAQ IV - 6. HDD repair',30],
['files/faq/oldpcfaq_snd.htm','su.comp.old>FAQ V. Sound system',30],
['files/faq/oldpcfaq_lan.htm','su.comp.old>FAQ VI. Nets. Lan cards',30],
['files/faq/oldpcfaq_ms.htm','su.comp.old>FAQ VII. History of Microsoft',30],
['files/faq/oldpcfaq_dos.txt','su.comp.old>FAQ VII - 2. DOS life. Arachne. Select of soft',30],
['files/faq/oldpcfaq_soft.txt','su.comp.old>FAQ VII - 3. Multimedia under DOS. Tuning OS/2',30],
['files/faq/oldpcfaq_another.txt','su.comp.old>FAQ VIII. Connectors. Multicards. IRPR<->Centronix',30],
['files/faq/oldpcfaq_another2.htm','su.comp.old>FAQ VIII-2. Old 5,25" Diskets, IBM PC XT Clock',30],
['files/faq/oldpcfaq_pc.htm','su.comp.old>FAQ IX. MITS Altair 8800. Sun SparcStation ELC/IPX',30],
['files/faq/oldpcfaq_ps2.htm','su.comp.old>FAQ IX - 2. IBM PS/2',30],
['files/faq/oldpcfaq_vax.txt','su.comp.old>FAQ IX - 3. Vax Station 2000',30],
['files/faq/oldpcfaq_agat.htm','su.comp.old>FAQ IX - 5. Agat',30],
['files/faq/oldpcfaq_spectrum.htm','su.comp.old>FAQ IX - 4. Spectrum and ATM-Turbo',30],
['files/faq/oldpcfaq_spectrum2.htm','su.comp.old>FAQ IX - 4. Spectrum - 2',30],
['files/faq/oldpcfaq_printers.htm','su.comp.old>FAQ X. ��������',30],
['files/faq/oldpcfaq_cards.htm','su.comp.old>FAQ XI. ����� ����������',30],
['files/faq/rudosfaq.txt','ru.dos>FAQ Of Ru.Dos',30],
['files/faq/rudosfaq_view.txt','ru.dos>FAQ Of Ru.Dos: Part II. ����� �� ��������� DOS',30],
['files/faq/rudosfaq_cmnd.txt','ru.dos>FAQ Of Ru.Dos: Part III. ������� DOS',30],
['files/faq/rudosfaq_soft.txt','ru.dos>FAQ Of Ru.Dos: Part IV. ����. ������',30],
['files/faq/rudosfaq_nolist.txt','ru.dos>FAQ Of Ru.Dos: Part V. ������������������� ����������� MS-DOS',30],
);
=cut
#
['files/faq/jfaq_changes.txt','2:5030/922>��������� ��������� � FAQ',7],

#['party830.tpl','titanic.pvt>Our Party List',30]
#['files.bbs','su.chainik.faq>List of files',30],
#['filesNew.bbs','su.chainik.faq>New topics',7],
#['filesInet.bbs','ru.internet.faq>Internet Faq',30],

#['apartments.rls','ru.moderator>Wellcome to Mo.Apartments !',30],
#['apartments_talk.rls','ru.moderator>Wellcome to Mo.Apartments.Talk !',30],
#['znakomstva.rls','ru.moderator>Wellcome to Ru.Znakomstva !',30],
#['Radio-Antenna-PRO:news.yahoogroups.com','rv3bz@mail.ru',1]
########################################Party robot####################################

$partyRobot_enable=1;# ��� ���������� ������ ��������� templates/party.tpl.
$partyRobot_subject='������� ��������� ����';
$partyRobot_echo='3BEPCTBO.LOCAL';

####################################Questionaire Tools#################################
# ��� ������ ������� ������ ��������� ���� ������ (��. $db*) � ������ tosser.pl (������)
# � ������ ���. ��
$questionaireEnable=0;# 'yes' or 'no'
$questionaireSearchYearFrom='17';
$questionaireSearchYearTo='38';
$questionaireSearchSex='f';#'m' (male) or 'f' (female) or 'm/f' (male and female)
$questionaireEcho='RU.ZNAKOMSTVA';# � ����� ��� ������� ����������.

###################Moderatorial Tools (Rules Poster, Rules Check, etc.)################

$useModeratorTools=1;

#####################################For debug only####################################

$global_var=0;# '0' - debug, another value - this script location on a internet

1;# Do not remove this !!!
