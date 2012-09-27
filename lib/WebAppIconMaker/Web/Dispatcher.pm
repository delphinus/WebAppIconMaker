package WebAppIconMaker::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;

use DBI qw!:sql_types!;
use Digest::MD5 qw!md5_hex!;
use Encode;
use JSON;
use Log::Minimal;
use LWP::UserAgent;

my $top = '';
my %sites = (
    'google-maps' => +{
        icon_url => '/static/img/map.png',
    },
);

any "$top/" => sub { my $c = shift;
    my %stash = (
        pages => [qw!top icon-maker!],
    );
    $c->render('index.tt', \%stash);
};

get "$top/getAddress" => sub { my $c = shift;
    my $p = $c->req->parameters;
    my $icon_url = $p->{'icon-url'};
    my $site_url = $p->{'site-url'};
    my $title = _get_title($c, $p->{'site-url'});

    if ($sites{$p->{site}}) {
        $icon_url = $c->config->{app_url} . $sites{$p->{site}}{icon_url};
    }

    if (!$icon_url || $icon_url eq 'http://') {
        my $md5 = _get_favicon($c, $site_url);
        $icon_url = $c->config->{app_url} . "/img/$md5";
    }

    my $address = "data:text/html;charset=UTF-8,<title>$title</title>"
        . qq!<meta name="apple-mobile-web-app-capable" content="yes">!
        . qq!<link rel="apple-touch-icon" href="$icon_url">!
        . qq!<script>if(window.navigator.standalone){!
        . qq!location.href="$site_url";}else{!
        . qq!document.write("ホーム画面に追加")}</script>!;

    $c->create_response(
        200,
        ['Content-type' => 'application/json'],
        encode(utf8 => to_json({result => $address})),
    );
};

get "$top/img/{id}" => sub { my ($c, $args) = @_;
    my ($ext, $data) = $c->dbh->selectrow_array(<<SQL, undef, $args->{id});
        SELECT ext, content FROM icons WHERE id = ?;
SQL

    if ($data) {
        $c->create_response(
            200,
            [
                'Content-Type' => "image/$ext",
                'Content-Length' => length $data,
            ],
            [$data],
        );
    } else {
        $c->res_404;
    }
};

sub _get_title { my $c = shift;
    my $site_url = shift;

    my $ua = LWP::UserAgent->new(agent => 'AppleWebKit/536.26'
        . ' (KHTML, like Gecko) Version/6.0 Mobile/10A405 Safari/8536.25');
    my $res = $ua->get($site_url);
    my ($title) = $res->decoded_content =~ m!<title>([^<]+)</title>!;

    return $title;
}

sub _get_favicon { my $c = shift;
    my $site_url = shift;
    my ($top_url) = $site_url =~ m!^(https?://[^/]+)!;
    my @icons = qw!
        apple-touch-icon-precomposed.png
        apple-touch-icon.png
        favicon.ico
    !;

    my $ua = LWP::UserAgent->new(agent => 
        'Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) '
        . 'AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 '
        . 'Mobile/10A405 Safari/8536.25');
    my $res = $ua->get($site_url);
    my $icon_url;
    if ($res->content) {
        my ($apple_touch_icon) = $res->content =~ m!
            <link\s*rel="apple-touch-icon"\s*href="([^"]+)"
        !x;
        $icon_url = $apple_touch_icon if $apple_touch_icon;
    }
    unless ($icon_url) {
        for my $i (@icons) {
            my $res = $ua->head("$top_url/$i");
            infof($res->header('Content-Type'));
            if ($res->header('Content-Type') =~ /image/) {
                $icon_url = "$top_url/$i";
                last;
            }
        }
    }
    unless ($icon_url) {
        return;
    }
    infof($icon_url);

    my $md5 = md5_hex($icon_url);

    my ($count) = $c->dbh->selectrow_array(<<SQL, undef, $md5);
        SELECT COUNT(*) FROM icons WHERE id = ?
SQL

    unless ($count) {
        my $res = $ua->get($icon_url);
        my ($ext) = $icon_url =~ /[^.]+$/;

        my $sth = $c->dbh->prepare(<<SQL);
            INSERT INTO icons VALUES (?, ?, ?, ?);
SQL

        $sth->bind_param(1, $md5, SQL_VARCHAR);
        $sth->bind_param(2, $ext, SQL_VARCHAR);
        $sth->bind_param(3, $res->content, SQL_BLOB);
        $sth->bind_param(4, time, SQL_INTEGER);
        $sth->execute;
    }

    return $md5;
}

1;
