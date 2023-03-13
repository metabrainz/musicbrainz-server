package t::MusicBrainz::Server::Controller::Errors;
use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use HTTP::Request;
use JSON qw( decode_json );
use Sentry::Raven;
use Test::Deep qw( cmp_deeply );
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test;
use MusicBrainz::Errors;
use DBDefs;

with 't::Mechanize';

test 'Controller error handling' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $MusicBrainz::Errors::_sentry_enabled = 1; ## no critic (ProtectPrivateVars)

    # Need ctx_request here rather than $mech->get to get $ctx for
    # passing to register_action_methods.
    my ($res, $ctx) = ctx_request('/');

    # Overrides ua_obj on the Sentry::Raven client to intercept
    # the request and remove gzip encoding from the response.
    my $sentry_ua = bless {
        ctx_request => \&ctx_request,
        posted_error => undef,
    }, 'SentryUserAgent';

    my $git_branch = DBDefs->GIT_BRANCH;
    my $git_sha = DBDefs->GIT_SHA;

    $MusicBrainz::Errors::sentry = Sentry::Raven->new(
        ua_obj => $sentry_ua,
        sentry_dsn => 'http://user:password@localhost/sentry-test/1',
        environment => $git_branch,
        tags => {
            git_commit => $git_sha,
        },
    );

    ($res, $ctx) = ctx_request('/die-die-die');

    my $stack_trace_pattern = '^Error: die die ' .
        'at lib/MusicBrainz/Server/Controller/Root\.pm line [0-9]+. ' .
        'at lib/MusicBrainz/Server/Controller/Root\.pm line [0-9]+ ' .
        'Class::MOP::Method::Wrapped::__ANON__\(\?\) called at lib/MusicBrainz/Server\.pm line [0-9]+ ' .
        'MusicBrainz::Server::__ANON__ at lib/MusicBrainz/Server\.pm line [0-9]+ ' .
        'MusicBrainz::Server::with_translations\(\?, \?\) called at lib/MusicBrainz/Server\.pm line [0-9]+ ' .
        'Class::MOP::Method::Wrapped::__ANON__\(\?\) called at lib/MusicBrainz/Server\.pm line [0-9]+ ' .
        'Class::MOP::Method::Wrapped::__ANON__\(\?\) called at lib/MusicBrainz/Server\.pm line [0-9]+$';

    my $mbs_root = DBDefs->MB_SERVER_ROOT;

    my $stack_trace = $mech->scrape_text_by_id('errors', $res->content);
    $stack_trace =~ s|\Q$mbs_root/\E||g;
    like($stack_trace, qr/$stack_trace_pattern/);

    my $sentry_error = decode_json($sentry_ua->{posted_error});
    my $exception_value = $sentry_error->{'sentry.interfaces.Exception'}{value};
    $exception_value =~ s|\Q$mbs_root/\E||g;

    like(
        $exception_value,
        qr{^die die at lib/MusicBrainz/Server/Controller/Root\.pm line [0-9]+\.$},
    );

    cmp_deeply(
        [map {
            [$_->{filename}, $_->{function}]
        } @{ $sentry_error->{'sentry.interfaces.Stacktrace'}{frames} }],
        [
            ['Server.pm', undef],
            ['Server.pm', 'Class::MOP::Method::Wrapped::__ANON__'],
            ['Server.pm', 'Class::MOP::Method::Wrapped::__ANON__'],
            ['Server.pm', 'MusicBrainz::Server::with_translations'],
            ['Server.pm', 'MusicBrainz::Server::__ANON__'],
            ['Root.pm', 'Class::MOP::Method::Wrapped::__ANON__'],
        ],
    );

    is($sentry_error->{tags}{git_commit}, DBDefs->GIT_SHA);
};

test 'Respond with Bad Request for "invalid session ID"' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->request(HTTP::Request->new('GET', '/', [
        'Cookie' => 'musicbrainz_server_session=heheh',
    ]));
    is(
        $mech->response->code,
        400,
        'bad request is returned for an invalid session ID',
    );
    is(
        $mech->response->content,
        q(Invalid session ID 'heheh'),
        'an error message is returned in the response',
    );

    # Try with beta=on, since that triggers a redirect before
    # any action is dispatched.
    $mech->request(HTTP::Request->new('GET', '/', [
        'Cookie' => 'musicbrainz_server_session=hahah; beta=on',
    ]));
    is(
        $mech->response->code,
        400,
        'bad request is returned for an invalid session ID with beta=on',
    );
    is(
        $mech->response->content,
        q(Invalid session ID 'hahah'),
        'an error message is returned in the response',
    );
};

package SentryUserAgent;

use HTTP::Response;
use IO::Uncompress::Gunzip qw( gunzip $GunzipError );

sub timeout {}

sub request {
    my ($self, $req) = @_;

    my $content;
    gunzip(\($req->content), \$content)
        or die "gunzip failed: $GunzipError\n";

    $req->content($content);
    $req->headers('Content-Encoding' => 'utf8');
    $self->{posted_error} = $content;

    my $res = HTTP::Response->new;
    $res->code(200);
    $res->content('{"id":1}');
    return $res;
}

1;
