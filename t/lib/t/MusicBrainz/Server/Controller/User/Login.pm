package t::MusicBrainz::Server::Controller::User::Login;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Hook::LexWrap;
use MusicBrainz::Server::Test qw( html_ok );
use DBDefs;
use Encode;

with 't::Mechanize', 't::Context';

test all => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;
    my $enable_ssl = enable_ssl();

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
    $c->sql->do('UPDATE editor SET password = ? WHERE name = ?',
        Authen::Passphrase::BlowfishCrypt->new(
            cost => 8,
            salt_random => 1,
            passphrase => encode('utf-8', 'ıaa2'),
        )->as_rfc2307, 'new_editor');

    $mech->get_ok('https://localhost/login');
    html_ok($mech->content);
    $mech->submit_form( with_fields => { username => '', password => '' } );
    $mech->content_contains('Username field is required');
    $mech->content_contains('Password field is required');
    $mech->submit_form( with_fields => { username => 'new_editor', password => '' } );
    $mech->content_contains('Password field is required');
    $mech->submit_form( with_fields => { username => '', password => 'password' } );
    $mech->content_contains('Username field is required');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'ıaa' } );
    $mech->content_contains('Incorrect username or password');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'ıaa2' } );
    is($mech->uri->path, '/user/new_editor');
    $enable_ssl->DESTROY;
};

test 'https login' => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;
    my $enable_ssl = enable_ssl();

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get_ok('https://localhost/login');
    html_ok($mech->content);
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );
    is($mech->uri->path, '/user/new_editor');
    is($mech->uri->scheme, 'https', 'We started secure, should still be secure');
    $enable_ssl->DESTROY;
};

test 'http login with redirects to ssl' => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    my $enable_ssl = enable_ssl();

    $mech->get_ok('http://localhost/login');
    html_ok($mech->content);
    is($mech->uri->scheme, 'https', 'Redirected to secure login form');
    use Data::Dumper;
    warn $mech->cookie_jar->as_string."\n";
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );
    is($mech->uri->path, '/user/new_editor');
    is($mech->uri->scheme, 'https', 'We started insecure, but we have stayed on https');
    $enable_ssl->DESTROY;
};

test 'Can login with usernames that contain the "/" character' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $enable_ssl = enable_ssl();

    $test->c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, ha1)
            VALUES (100, 'ocharles/bot', '{CLEARTEXT}mb', 'f067d1b82bbf64c403cbbc996de73cda');
        SQL

    $mech->get_ok('/user/ocharles%2Fbot');
    html_ok($mech->content);
    $mech->content_contains('ocharles/bot');
    $mech->follow_link_ok({ url_regex => qr{/login} });
    $mech->submit_form(
        with_fields => { username => 'ocharles/bot', password => 'mb' },
    );
    like($mech->uri->path, qr{/user/ocharles%2Fbot});
    $enable_ssl->DESTROY;
};

test 'Deleted editors cannot login (even if they have a password)' => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;
    my $enable_ssl = enable_ssl();

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
    $c->sql->do('UPDATE editor SET password = ?, deleted = TRUE WHERE name = ?',
        Authen::Passphrase::BlowfishCrypt->new(
            cost => 8,
            salt_random => 1,
            passphrase => encode('utf-8', 'ıaa2'),
        )->as_rfc2307, 'new_editor');

    $mech->get_ok('https://localhost/login');
    html_ok($mech->content);
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'ıaa2' } );
    $mech->content_contains('Incorrect username or password');
    $enable_ssl->DESTROY;
};

test 'Spammer editors cannot log in' => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;
    my $enable_ssl = enable_ssl();

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO editor (
                        id, name, password,
                        privs, email, website, bio,
                        member_since, email_confirm_date, last_login_date,
                        ha1
                    )
             VALUES (
                        5, 'SPAMVIKING', '{CLEARTEXT}SpamBaconSausageSpam',
                        4096, 'spam@bromleycafe.com', '', 'spammy spam',
                        '2010-03-25', '2010-03-25', now(),
                        '1e30903480b84af674780f41ac54dfec'
                    )
        SQL

    $mech->get_ok('https://localhost/login');
    html_ok($mech->content);
    $mech->submit_form( with_fields => {
        username => 'SPAMVIKING',
        password => 'SpamBaconSausageSpam',
    } );
    $mech->content_like(qr/You cannot log in .* marked as a spam account/);
    $enable_ssl->DESTROY;
};

test 'MBS-12720: remember_login cookie is HttpOnly' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;
    my $enable_ssl = enable_ssl();

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get_ok('https://localhost/login');
    $mech->submit_form(
        with_fields => {
            username => 'new_editor',
            password => 'password',
            remember_me => '1',
        },
    );
    is($mech->uri->path, '/user/new_editor');
    my $cookies = $mech->cookie_jar->{COOKIES}{'localhost.local'}{'/'};
    ok(exists $cookies->{remember_login}->[7]->{HttpOnly});

    $enable_ssl->DESTROY;
};

test 'MBS-13548: obey returnto for already logged in users' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;
    my $enable_ssl = enable_ssl();

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
    $mech->get_ok('https://localhost/login');
    $mech->submit_form(
        with_fields => {
            username => 'new_editor',
            password => 'password',
            remember_me => '1',
        },
    );
    is($mech->uri->path, '/user/new_editor');

    $mech->get_ok('https://localhost/login?returnto=/doc/About');
    is($mech->uri->path, '/doc/About');

    $enable_ssl->DESTROY;
};

sub enable_ssl {
    my $dbdefs = ref(*DBDefs::SSL_REDIRECTS_ENABLED) ? 'DBDefs' : 'DBDefs::Default';
    my $wrapper = wrap "${dbdefs}::SSL_REDIRECTS_ENABLED",
        pre => sub { $_[-1] = 1 };

    # This returns a lexically scoped wrapper so the assignments are needed
    # See https://metacpan.org/pod/Hook::LexWrap#Lexically-scoped-wrappers
    return $wrapper;
}

1;
