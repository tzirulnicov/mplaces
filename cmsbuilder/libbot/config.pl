#!/usr/bin/perl
$db_enable=1;
$db_host='localhost';
$db_type='mysql';
$db_login='goga';
$db_password='07080900';
$db_table='bchotels';
$db_prefix='phpmw';
#------------------
$ourName="Vadim Tzirulnicov";# Ваше имя с фамилией на английском
$systemAddress='2:550/278.400';# netmail Адрес робота
$ourAddress='2:5020/1665.4';# Адрес владельца робота
$linkAddress='2:550/278';#Адрес того, кому сливаем почту
$ifix_language='russian';# Язык ("rus" или "eng")
#$systemAddress='2:5020/1665.4';# netmail Адрес робота
#$ourAddress='2:5020/1665.4';# Адрес владельца робота
#$linkAddress='2:5020/1665';#Адрес того, кому сливаем почту
$SMTPServer='tz.ints.ru';#SMTP-сервер, которым можно пользоваться без авторизации
$sessionPassword='';#Пароль на сессию. Не более 8 символов
#$pathToMSG='C:/pic/fido3/netmail';
$pathToMSG='files/netmail';# Путь к директории NETMAIL
# Путь к директории хранения исходящей NETMAIL и эхо-почты (обработанной тоссером)
$pathToPKT='files/inbox';
#$pathToPKT='C:\pic\FIDO3\FILES\inbox';# INBOUND
$pathToOutbound='files/outbox';
#$pathToOutbound='C:\pic\FIDO3\FILES\outbox';
# Если запись в MySQL базу разрешена, то тоссим бандлы в данную директорию
#$pathToTemp='C:\pic\FIDO3\TEMP';
$pathToTemp='files/temp';
#$pathToPasswordList='';# Путь к файлу, в котором хранятся пароли пойнтов
$pathToLog='logs';# Директория хранения лог-файлов.
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
$maxLogFileSize='32k';# Макс. размер лог-файла
$errorMailNotify=1;# Сообщать ли об ошибках по почте
$errorMailBox='tz@tz.ints.ru';# Ваш E-Mail. Если неверен, письмо получите по NetMail.
#$errorMailFrom='"InternetFix" <tzirulnicov@webclass.ru>';
$errorMailSubject='Error in my code';
# База данных нужна для работы модулей "Web" и Questionaire Tools

$quoteDailyUser=300;# Дневная квота на каждого пользователя факсервера, в килобайтах
$quoteDailyAllUsers=1200;# Дневная квота на всех пользователей факсервера, в килобайтах
$quoteDailyLimit=10485760;# Дневная квота на исходящий трафик, в байтах
$quoteBaseLimit=1000;# Квота на количество записей в базе дневных квот на исх. трафик, в байтах

# При "1" будет обрабатывать письма, пришедшие на любой адрес, а не только на $systemAddress
$evalMailToAllAddress=1;# Работает только в ФАК-сервере
# Если валидно значение $pathToSquishCFG, то информация о эхах будет браться оттуда
$pathToSquishCFG='/home/html/files/squish.cfg';
# Если вы используете Net::Binkd, укажите путь к конфигу бинкда:
$pathToBinkdCFG='files/binkd.cfg';

$defaultChmod='777';# Дефолтные права, с которыми будут создаваться директории

###########################################Links#####################################
# Возможно задание нескольких линков на эхопочту.
# То, с каких линков какие эхи тянем, задаётся в файле Squish.cfg (см. $pathToSquishCFG)
# Нетмейл-аплинк задаётся в $linkAddress. Указывать его ниже не следует.
# Если в Squish.cfg будет найден линк, не перечисленный ниже, то письма в соответствующую
# ему эху будут паковаться на $linkAddress.
# Наши даунлинки также здесь указываются.
# Регистр написания параметров имеет значение
# Если какой-либо параметр не указан, то его значение считается ложным ("no" или "0")
# LinkName - не более 36 символов
# Password - не более 8 символов

# Аплинки
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

# Даунлинки
#$links_link[2]->{'LinkAddress'}='36:5020/36';
#$links_link[2]->{'OurAddress'}='36:5020/0';
#$links_link[2]->{'LinkName'}='Lala Lalaev';
#$links_link[2]->{'Password'}='';
#$links_link[2]->{'Downlink'}=1;

#######################################Internet Wizard#################################

$useInternet=0;

#######################################Zakaz Wizard#################################

# Скачивание информации из Интернет на сервер в локальной сети/Интернет, либо пользователю в нетмейл ююками

$useZakaz=1;

$zakaz_dayUserInternetLimit=700;# Дневное ограничение на каждого интернет-пользователя в мегабайтах (0 - без ограничений)
$zakaz_weekUserInternetLimit=0;# Недельное
$zakaz_monthUserInternetLimit=0;# Месячное
$zakaz_dayInternetLimit=14000;# Суммарное дневное ограничение
$zakaz_weekInternetLimit=0;# Суммарное недельное
$zakaz_monthInternetLimit=0;# Суммарное месячное
#
#$zakaz_dayUserFIDOLimit=700;# Дневное ограничение на каждого интернет-пользователя в мегабайтах (0 - без ограничений)
#$zakaz_weekUserFIDOLimit=0;# Недельное
#$zakaz_monthUserFIDOLimit=0;# Месячное
#$zakaz_dayFIDOLimit=14000;# Суммарное дневное ограничение
#$zakaz_weekFIDOLimit=0;# Суммарное недельное
#$zakaz_monthFIDOLimit=0;# Суммарное месячное
#
#$zakaz_workTime='1:00-9:00';# Диапазон времени, в котором может работать робот
$zakaz_resultServer='10.102.31.6';# Сервер, на который будут скидываться заказанные файлы (если заказаны с e-mail, входящим с список разрешённых)
$zakaz_resultServerDir='/incoming/Zakaz';# В какую папку сервера будет скидываться результат
$zakaz_tempDir='/home/ftp/incoming/zakaz/temp';# Папка на сервере, в которую будут скачиваться заказы, которые после полного скачивания будут перекинуты на сервер $resultServer
$zakaz_timeout='30';# Таймаут ожидания ответа от серверов, в секундах
$zakaz_resultServerHash=1;
#
$zakaz_mailSendingFromEMail='tz@tz.ints.ru';
$zakaz_mailSendingFromName='Downloader Robot';# С какого e-mail'а будут отсылаться уведомления о выполении запросов пользователям
$zakaz_mailSendingSubj="Результат закачки URLа %url";# Сабж письма с уведомлением о выполнении запроса пользователю
$zakaz_mailSendingText=<<ZAKAZ_END;
         Здравствуйте !
 Сообщаем, что файлы с заказанного вами ресурса %query_url выкачаны,
и вы уже можете их скачать с сервера %ftp_server.
 Имейте в виду, что ваши файлы на этом сервере будут хранится только
2 дня, после чего будут удалены.
ZAKAZ_END
$zakaz_mailSendingTextNotFound=<<ZAKAZ_END2;
         Здравствуйте !
 Сообщаем, что при выкачивании заказанного вами ресурса %query_url
произошла ошибка. Возможные причины этого: Сайт был скачан успешно
до указанной вами квоты, при скачивании файлов
сервер перестал быть доступным (например, его выключили),
либо сервер не найден, либо имела место внутренняя ошибка робота.
Если вы уверены, что это ошибка робота, напишите его разработчику:
tz (собака) ints.ru.

   В любом случае, рекомендуем проверить вашу папку: %ftp_server.
Может, всё же чего-то робот вам и выкачал. :)
ZAKAZ_END2

############################################Binkd######################################

$useBinkd=1;
#"1" - мейлер "Binkd", "2" - встроенный модуль Net::Binkd. При иных значениях исп. Binkd
$binkd_type=1;
# Путь к бинкд (используется при $binkd_type, отличном от двух)
$binkd_path='files/binkd';
# Если binkd_type!=2
$binkd_conf='files/binkd.cfg';
# Интервал прозвонки в минутах. Внимание ! Мейлер будет запускаться при каждом
# Вызове скрипта, если в конфиге бинкда путь к логу не путь_к_config.pl/logs/binkd.log !
$binkd_poll=30;

############################################Tosser#####################################

# Отступление: тоссер не обрабатывает файлы ".*UT" в инбаунде и пакованый нетмейл

# Использовать ли встроенный тоссер
$useTosser=0;
# Удаляет файлы в инбаунде, не являющиеся нетмейловыми пакетами.
# Например, узел работает в автономном режиме, и вы принудительно подписаны на эхи и
#фэхи босса. Чтобы не засорять диск данными файлами, можно их удалять.
$tosser_delNonNetmail=0;

############################################Tracker#####################################

$useTracker=0;
# Указание на то, что узел работает на автопилоте. При этом вся почта, адресованная
# не роботу, будет пересылаться хозяину узла (на $ourAddress)
$autopiloteMode=1;
# Относительный путь к нодлистам относительно текущей директории либо абсолютный путь
$pathToNodelist='files/nodelist';

########################################Download Manager################################

# При "0" будет игнорировать запросы на выкачку файлов.
# Если у вас нет постоянного доступа в интернет, и получен запрос на скачивание из инета,
# то скрипт при обработке каждого запроса будет зависать на время, указаное в
# таймауте на установку соединения
$downloadManagerEnable=1;
# При формировании ответа переменные с удалённого сервера будут сформированы в клуджи,
# префикс которых указывается в нижеприведённой переменной.
$downloadManagerSVKludgesPrefix='RFC';
# HTML::Parse используется всегда. Использование же модулей HTML::TreeBuilder
# и HTML::FormatText включается нижеприведённой переменной. Если они не используется,
# робот пытаетя своими силами выполнить преобразование HTML->Plain Text.
# При этом конвертирование заключается лишь в удалении тёгов, без их обработки.
$downloadManagerUseHTMLModules=0;
$socketTimeOut=10;#Таймаут установки соединения в секундах
$socketWaitResponse=30;#Время ожидания ответа хоста после его нахождения в секундах

###########################################FaqServer####################################

# Лица, письма от которых факсервер робота не будет обрабатывать (будет удалять без ответа)
# Регистр написания не имеет значения
@ignoreFrom=('Mail Delivery Subsystem','FTrack','MS Network Security Section',
		'Network Message System',"MAILER-DAEMON\@mail1.newsletters.net");
# Высылать ли отчёт о выполнении запросов пользователю
$faqServerSendReports=1;

#########################################Log Analizer###################################

$logAnalyzerEnable=1;
# Куда постить. Возможные значения - см. соотв. пункт в "Posting Wizard"
$postReportsIn='2:5020/1665.4';
$postReportsSubject='Отчёт';
$numOfTopReports=10;# top n топиков
$postReportsPeriod='7';# 1(ежедневно)/7(каждую неделю)/30(каждый месяц)/365(ежегодно)
# Список конференций, отчёты по активности в которых следует создавать
# Формат: ['конференция',периодичность_постинга (см.выше)]
$logLevel=2;# 0 - не выводить на консоль отладочные сообщения,
#1 - выводить сообщений только высокого приоритета, 2 - всех приоритетов
$logConsole=1;# Если $logLevel=1: 1 - выводить и в лог, и на консоль, 0 - только на консоль
@logAnalyzerEchos=(
['ru.znakomstva>Статистика',7],
['mo.apartments>Статистика',7],
['mo.apartments.talk>Статистика',7]
);
#######################################Posting Wizard#################################

$postingEnable=1;# 'yes' or 'no'
$postingInNewsFromEmail='tz@tz.ints.ru';# E-Mail для указания в качестве обратного при постинге роботом в news-группы
$postingInNewsFromName='InternetFix';
# Формат: [что_постить,куда_постить,периодичность (дней)]
# Возможные значения "что_постить":
# usenet-конференция (название:news_server), Файл (имя_файла)
# 				E-Mail (e-mail:pop_server:login:password)
# Возможные значения "куда_постить":
# эха фидо (название/Тема_письма), E-Mail (e-mail/Тема) (только при доступности сервера $errorMailServer),
# Документ 'test.txt' будет искаться в templates/posting, 'files/faq/test.txt' -
# - диск:/текущая_директория/files/faq/test.txt, также можно указать абсолютный путь
@postingItems=(
['apartments.rls','mo.apartments>Rules',7],
['apartments_talk.rls','mo.apartments.talk>Rules',7],
['znakomstva.rls','ru.znakomstva>Rules',7],
['files.bbs','su.chainik.faq>List of topics',30],
['filesInet.bbs','ru.internet.faq>Internet FAQ',30],
['files/faq/hmr/files.bbs','su.chainik.faq>Юмор',30]
);
#['filesNew.bbs','su.chainik.faq>New topics',7],
#['sucompold.faq','su.comp.old>Список топиков FAQ-сервера Su.Comp.Old',7]
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
['files/faq/oldpcfaq_printers.htm','su.comp.old>FAQ X. Принтеры',30],
['files/faq/oldpcfaq_cards.htm','su.comp.old>FAQ XI. Карты расширения',30],
['files/faq/rudosfaq.txt','ru.dos>FAQ Of Ru.Dos',30],
['files/faq/rudosfaq_view.txt','ru.dos>FAQ Of Ru.Dos: Part II. Обзор ОС семейства DOS',30],
['files/faq/rudosfaq_cmnd.txt','ru.dos>FAQ Of Ru.Dos: Part III. Команды DOS',30],
['files/faq/rudosfaq_soft.txt','ru.dos>FAQ Of Ru.Dos: Part IV. Софт. Ссылки',30],
['files/faq/rudosfaq_nolist.txt','ru.dos>FAQ Of Ru.Dos: Part V. Недокументированные возможности MS-DOS',30],
);
=cut
#
['files/faq/jfaq_changes.txt','2:5030/922>Последние изменения в FAQ',7],

#['party830.tpl','titanic.pvt>Our Party List',30]
#['files.bbs','su.chainik.faq>List of files',30],
#['filesNew.bbs','su.chainik.faq>New topics',7],
#['filesInet.bbs','ru.internet.faq>Internet Faq',30],

#['apartments.rls','ru.moderator>Wellcome to Mo.Apartments !',30],
#['apartments_talk.rls','ru.moderator>Wellcome to Mo.Apartments.Talk !',30],
#['znakomstva.rls','ru.moderator>Wellcome to Ru.Znakomstva !',30],
#['Radio-Antenna-PRO:news.yahoogroups.com','rv3bz@mail.ru',1]
########################################Party robot####################################

$partyRobot_enable=1;# Для нормальной работы требуется templates/party.tpl.
$partyRobot_subject='Сегодня необычный день';
$partyRobot_echo='3BEPCTBO.LOCAL';

####################################Questionaire Tools#################################
# Для работы данного модуля требуется база данных (см. $db*) и модуль tosser.pl (только)
# в случае исп. БД
$questionaireEnable=0;# 'yes' or 'no'
$questionaireSearchYearFrom='17';
$questionaireSearchYearTo='38';
$questionaireSearchSex='f';#'m' (male) or 'f' (female) or 'm/f' (male and female)
$questionaireEcho='RU.ZNAKOMSTVA';# В какую эху постить результаты.

###################Moderatorial Tools (Rules Poster, Rules Check, etc.)################

$useModeratorTools=1;

#####################################For debug only####################################

$global_var=0;# '0' - debug, another value - this script location on a internet

1;# Do not remove this !!!
