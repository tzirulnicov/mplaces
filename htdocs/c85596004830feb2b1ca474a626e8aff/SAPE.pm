package SAPE;
use strict;

=pod
SAPE.ru - Интеллектуальная система купли-продажи ссылок, библиотека на Perl.
Программист: Никита Дедик <meneldor@metallibrary.ru>, ICQ: 23057061
 Дополнения: Антон Сущев, Фёдор Филиппов
=cut

our $VERSION = '0.9';

use Fcntl qw(:flock :seek);
use File::stat;
use LWP::UserAgent;

# user            => код пользователя SAPE.ru
# host            => (необязательно) сервер пользователя
# uri             => (необязательно) адрес запрашиваемой страницы, по умолчанию: $ENV{REQUEST_URI}
# remote_ip       => (необязательно) IP-адрес пользователя (для определения робота SAPE)
# force_show_code => (необязательно) всегда ли показывать код SAPE для новых страниц, по умолчанию - только для робота SAPE
# filename        => (необязательно) имя файла для кэша, по умолчанию: $ENV{HOSTNAME}/$user/links.db
# charset         => (необязательно) кодировка для выдачи ссылок: windows-1251, koi8-r, iso8859-5, x-cp866, x-mac-cyrillic, etc.
# server          => (необязательно) сервер выдачи ссылок SAPE.ru
sub new {
    my ($class, %args) = @_;

    my $self = bless {
        user            => undef,
        host            => $ENV{HOSTNAME} || $ENV{HTTP_HOST},
        uri             => $ENV{REQUEST_URI},
        remote_ip       => $ENV{REMOTE_ADDR},
        force_show_code => 0,
        filename        => "$ENV{DOCUMENT_ROOT}/$args{user}/links.db",
        charset         => 'windows-1251',
        server          => 'dispenser-01.sape.ru',
        timeout         => 60 * 60 * 1, # таймаут для обновления ссылок в секундах
        %args
    }, $class;
    !$self->{$_} and die qq|SAPE.pm error: missing parameter "$_" in call to "new"!|
		foreach qw(user host uri remote_ip filename charset server timeout);
	$self->{uri_alt} = substr($self->{uri}, -1) eq '/'
		? substr($self->{uri}, $[, -1)
		: $self->{uri} . '/';

    return $self;
}

# count => (необязательно) количество ссылок, которые следует показать (будут удалены из очереди)
sub get_links {
    my ($self, %args) = @_;

    $self->_fetch_links
        unless ref $self->{_links} eq 'ARRAY';

    if (ref $self->{_links} eq 'ARRAY') {
        $args{count} ||= scalar @{ $self->{_links} };
        return join($self->{_delimiter}, splice @{ $self->{_links} }, $[, $args{count});
    } else {
        return $self->{_links};
    }
}

sub _fetch_links {
    my $self = shift;

    my $links;

    local $/ = "\n";

    if (open my $fh, $self->{filename}) {
        my $links_charset = <$fh>;
        close $fh;
        chomp $links_charset;

        utime 0, 0, $self->{filename}
            unless $links_charset eq $self->{charset};
    }

    my $stat = -f $self->{filename} ? stat $self->{filename} : undef;
    if (!$stat || $stat->mtime < time - $self->{timeout} || $stat->size == 0) {
        open my $fh, '>>', $self->{filename}
            or return $self->_croak("Can't write to cache file ($self->{filename}): $!");
        if (flock $fh, LOCK_EX | LOCK_NB) {
            my $ua = LWP::UserAgent->new;
            $ua->agent("SAPE_Client Perl $VERSION");
            $ua->timeout(10);

            my $links_url = "http://$self->{server}/code.php?user=$self->{user}&host=$self->{host}&as_txt=true&charset=$self->{charset}&no_slash_fix=true";
            my $response = $ua->get($links_url);
            return $self->_croak("Unable to retrieve links text from $links_url: " . $response->status_line)
	            unless $response->is_success;
            my $links_text = $self->{charset} . "\n" . $response->content;
            $links = $self->_parse_links(\$links_text);

            if ($links->{__sape_new_url__}) {
                seek $fh, 0, SEEK_SET;
                truncate $fh, 0;
                print $fh $links_text;
                close $fh;
            } else {
                close $fh;
                utime $stat->atime, time - $self->{timeout} + 60 * 5, $self->{filename}
                    if $stat;
                return $self->_croak("No '__sape_new_url__' parameter found in links text at $links_url");
            }
        }
    }

    unless ($links) {
        local $/;
        open my $fh, $self->{filename}
            or return $self->_croak("Can't read from cache file ($self->{filename}): $!");
        my $links_text = <$fh>;
        close $fh;

        $links = $self->_parse_links(\$links_text);
    }

    $self->{_links} = $links->{ $self->{uri} } || $links->{ $self->{uri_alt} };
    $self->{ips} = $links->{__sape_ips__} || [];
    $self->{_links} ||= $links->{__sape_new_url__}
        if $self->{force_show_code} || grep { $self->{remote_ip} eq $_ } @{ $self->{ips} };

    return;
}

sub _parse_links {
    my $self = shift;
    my $links_text = shift;

    my $links = {};
    (undef, undef, $self->{_delimiter}, my @links_raw) = split(/\n/, $$links_text);
    foreach my $page_raw (@links_raw) {
        my ($page_url, @page_links) = split('\|\|SAPE\|\|', $page_raw);
        $links->{$page_url} = \@page_links;
    }

    return $links;
}

sub _croak {
    my ($self, $error) = @_;

    $self->{_links} = "<!-- SAPE.ru error: $error -->";

    return;
}

1;
