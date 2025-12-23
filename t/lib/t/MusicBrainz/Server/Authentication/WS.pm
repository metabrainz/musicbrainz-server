package t::MusicBrainz::Server::Authentication::WS;
use utf8;
use strict;
use warnings;

use Encode qw( encode_utf8 );
use HTTP::Status qw( :constants );
use Test::Routine;
use Test::More;

use URI;
use URI::QueryParam;

with 't::Context', 't::Mechanize';

=head1 DESCRIPTION

This test checks OAuth/Digest authentication in the web service, by attempting
to request data for a private collection.

=cut

test 'Authenticate WS bearer' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my $path = '/ws/2/collection/181685d4-a23a-4140-a343-b7d15de26ff7';
    # No authentication
    $test->mech->get($path);
    is($test->mech->status, HTTP_UNAUTHORIZED, 'GET with no auth is rejected');

    # Invalid token
    $test->mech->get("$path?access_token=xxxx");
    is($test->mech->status, HTTP_UNAUTHORIZED, 'Invalid token is rejected');
    $test->mech->get($path, Authorization => 'Bearer xxx');
    is($test->mech->status, HTTP_UNAUTHORIZED, 'Invalid bearer is rejected');

    # Correctly authenticated
    $test->mech->get_ok(
        "$path?access_token=Nlaa7v15QHm9g8rUOmT3dQ",
        'Correct token is accepted',
    );
    $test->mech->get_ok(
        $path,
        { Authorization => 'Bearer Nlaa7v15QHm9g8rUOmT3dQ' },
        'Correct bearer is accepted',
    );

    # MAC tokens can't be used as bearer
    $test->mech->get("$path?access_token=NeYRRMSFFEjRoowpZ1K59Q");
    is($test->mech->status, HTTP_UNAUTHORIZED, 'MAC token is rejected');
    $test->mech->get($path, { Authorization => 'Bearer NeYRRMSFFEjRoowpZ1K59Q' });
    is($test->mech->status, HTTP_UNAUTHORIZED, 'MAC bearer is rejected');

    # Drop the profile scope
    $test->c->sql->do(<<~'SQL');
        UPDATE editor_oauth_token
           SET scope = 0
         WHERE access_token = 'Nlaa7v15QHm9g8rUOmT3dQ'
        SQL
    $test->mech->get("$path?access_token=Nlaa7v15QHm9g8rUOmT3dQ");
    is(
        $test->mech->status,
        HTTP_UNAUTHORIZED,
        'Token with dropped scope is rejected',
    );
    $test->mech->get($path, Authorization => 'Bearer Nlaa7v15QHm9g8rUOmT3dQ');
    is(
        $test->mech->status,
        HTTP_UNAUTHORIZED,
        'Bearer with dropped scope is rejected',
    );
    $test->c->sql->do(<<~'SQL');
        UPDATE editor_oauth_token
           SET scope = 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128
         WHERE access_token = 'Nlaa7v15QHm9g8rUOmT3dQ'
        SQL

    # Expire the token
    $test->c->sql->do(<<~'SQL');
        UPDATE editor_oauth_token
           SET expire_time = now() - interval '1 hour'
         WHERE access_token = 'Nlaa7v15QHm9g8rUOmT3dQ'
        SQL
    $test->mech->get("$path?access_token=Nlaa7v15QHm9g8rUOmT3dQ");
    is($test->mech->status, HTTP_UNAUTHORIZED, 'Expired token is rejected');
    $test->mech->get($path, Authorization => 'Bearer Nlaa7v15QHm9g8rUOmT3dQ');
    is($test->mech->status, HTTP_UNAUTHORIZED, 'Expired bearer is rejected');
};

test 'Digest authentication' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+oauth');

    my $path = '/ws/2/collection/906dddc8-91c8-4a1c-8237-31b6d24c988d';
    $mech->get($path);
    is($mech->status, HTTP_UNAUTHORIZED, 'GET with no auth is rejected');

    my $username = 'æditorⅣ';
    my $username_utf8 = encode_utf8($username);
    $mech->credentials('localhost:80', 'musicbrainz.org', $username_utf8, 'pass');
    $mech->get_ok($path, 'Account password is accepted');

    $mech->credentials('localhost:80', 'musicbrainz.org', $username_utf8, 'wrongpass');
    $mech->get($path);
    is($mech->status, HTTP_UNAUTHORIZED, 'Wrong account password is rejected');

    my $editor = $c->model('Editor')->get_by_name($username);
    $c->model('Editor')->disable_digest_auth_token($editor->id);
    $mech->credentials('localhost:80', 'musicbrainz.org', $username_utf8, 'pass');
    $mech->get($path);
    is($mech->status, HTTP_UNAUTHORIZED, 'Account password is rejected after disabling digest auth');

    $mech->credentials('localhost:80', 'musicbrainz.org', $username_utf8, '');
    $mech->get($path);
    is($mech->status, HTTP_UNAUTHORIZED, 'Empty password is rejected after disabling digest auth');

    # The `ha1` column is `CHAR(32)`, so an empty value will consist of 32 spaces.
    $mech->credentials('localhost:80', 'musicbrainz.org', $username_utf8, ' ' x 32);
    $mech->get($path);
    is($mech->status, HTTP_UNAUTHORIZED, 'Blank password is rejected after disabling digest auth');

    my $token = $c->model('Editor')->reset_digest_auth_token($editor->id);
    $mech->credentials('localhost:80', 'musicbrainz.org', $username_utf8, $token);
    $mech->get_ok($path, 'New digest auth token is accepted');

    $mech->credentials('localhost:80', 'musicbrainz.org', $username_utf8, 'pass');
    $mech->get($path);
    is($mech->status, HTTP_UNAUTHORIZED, 'Account password is rejected after setting new digest auth token');
};

1;
