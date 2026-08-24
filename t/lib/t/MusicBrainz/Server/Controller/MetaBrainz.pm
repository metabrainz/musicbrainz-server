package t::MusicBrainz::Server::Controller::MetaBrainz;

use strict;
use warnings;

use Digest::SHA qw( hmac_sha256_hex );
use HTTP::Request;
use HTTP::Status qw( :constants );
use JSON::XS qw( decode_json encode_json );
use LWP::UserAgent::Mockable;
use Test::Routine;
use Test::More;
use URI;
use URI::QueryParam;

use DBDefs;
use MusicBrainz::Server::Test qw( metabrainz_oauth2_response );

with 't::Mechanize', 't::Context';

sub _make_webhook_request {
    my (%args) = @_;

    my $req = HTTP::Request->new(POST => '/metabrainz/webhook/callback');
    $req->header('Content-Type' => 'application/json');
    $req->header('X-MetaBrainz-Event' => $args{event})
        if defined $args{event};

    my $body = encode_json($args{payload});
    my $signature = exists $args{signature}
        ? $args{signature}
        : ('sha256=' .
            hmac_sha256_hex($body, DBDefs->METABRAINZ_WEBHOOK_SECRET));
    $req->header('X-MetaBrainz-Signature-256' => $signature)
        if defined $signature;

    $req->content($body);
    return $req;
}

test 'The OAuth2 callback rejects a state from another session' => sub {
    my $test = shift;
    my $mech = $test->mech;

    no warnings 'redefine';
    local *DBDefs::LOCAL_ACCOUNTS_ENABLED = sub { 0 };
    use warnings 'redefine';

    $mech->max_redirect(0);
    $mech->get('/login');
    is($mech->status, HTTP_FOUND, '/login redirects to MetaBrainz');

    my $location = URI->new($mech->response->header('Location'));
    my $state = $location->query_param('state');

    $mech->cookie_jar->clear;
    $mech->get('/metabrainz/oauth2/callback?code=foo&state=' . $state);
    is($mech->status, HTTP_INTERNAL_SERVER_ERROR,
       'the callback is rejected outside the initiating session');
    $mech->content_contains('Invalid session_id in OAuth2 redirect state');
};

test 'The OAuth2 callback discards the state on provider errors' => sub {
    my $test = shift;
    my $mech = $test->mech;

    no warnings 'redefine';
    local *DBDefs::LOCAL_ACCOUNTS_ENABLED = sub { 0 };
    use warnings 'redefine';

    $mech->max_redirect(0);
    $mech->get('/login');

    my $location = URI->new($mech->response->header('Location'));
    my $state = $location->query_param('state');

    $mech->get('/metabrainz/oauth2/callback?error=access_denied&state=' . $state);
    is($mech->status, HTTP_FOUND, 'the callback redirects on error');
    is(
        URI->new($mech->response->header('Location'))->path,
        '/',
        'the redirect goes to the homepage',
    );

    $mech->get('/metabrainz/oauth2/callback?code=foo&state=' . $state);
    is($mech->status, HTTP_BAD_REQUEST, 'the redirect state was discarded');
    $mech->content_contains('This page has expired');
};

test 'OAuth2 redirects are rate limited by IP' => sub {
    my $test = shift;
    my $mech = $test->mech;

    no warnings 'redefine';
    local *DBDefs::LOCAL_ACCOUNTS_ENABLED = sub { 0 };
    use warnings 'redefine';

    my $max = $MusicBrainz::Server::Controller::MetaBrainz::MAX_REDIRECT_ATTEMPTS;
    $mech->max_redirect(0);

    my $redirects = 0;
    for (1 .. $max) {
        $mech->get('/login');
        ++$redirects if $mech->status == 302;
    }
    is($redirects, $max, "the first $max attempts are redirected");

    $mech->get('/login');
    is($mech->status, HTTP_BAD_REQUEST, 'the next attempt is rejected');
    $mech->content_contains('Too many login attempts',
                            'the error mentions too many login attempts');

    my $store = $test->c->store;
    my ($count_key) = $store->_connection->keys(
        $store->_prepare_key('oauth2_redirect_state:count:*'));
    ok(defined $count_key, 'a redirect count key exists');
    my $ttl = $store->_connection->ttl($count_key);
    cmp_ok($ttl, '>', 0, 'the redirect count key has a TTL');
    cmp_ok(
        $ttl, '<=',
        $MusicBrainz::Server::Controller::MetaBrainz::REDIRECT_STATE_EXPIRES,
        'the redirect count key expires within REDIRECT_STATE_EXPIRES',
    );
};

test 'POST parameters are preserved through an OAuth2 login' => sub {
    my $test = shift;
    my $mech = $test->mech;

    no warnings 'redefine';
    local *DBDefs::LOCAL_ACCOUNTS_ENABLED = sub { 0 };
    use warnings 'redefine';

    $mech->max_redirect(0);
    $mech->post('/release/add', { name => 'Seeded Release Name' });
    is($mech->status, HTTP_FOUND, 'the POST redirects to MetaBrainz');

    my $location = URI->new($mech->response->header('Location'));
    my $state = $location->query_param('state');

    LWP::UserAgent::Mockable->reset;
    LWP::UserAgent::Mockable->set_record_pre_callback(sub {
        metabrainz_oauth2_response(shift, {
            editor_id => 3000010,
            editor_name => 'metabrainz_seed_test',
        });
    });

    $mech->get('/metabrainz/oauth2/callback?code=foo&state=' . $state);
    is($mech->status, HTTP_OK, 'the callback renders the confirmation page');
    $mech->content_contains('Seeded Release Name', 'the POST parameters are preserved');
    $mech->content_contains(
        'originating from <strong>unknown</strong>',
        'an unknown request origin is displayed',
    );
    $mech->content_contains('/release/add', 'the request URI is displayed');

    $mech->cookie_jar->clear;
    $mech->post('/release/add', { name => 'very_large_name_' . ('x' x 70000) });
    is($mech->status, HTTP_FOUND, 'the POST redirects to MetaBrainz');

    $location = URI->new($mech->response->header('Location'));
    $state = $location->query_param('state');

    $mech->get('/metabrainz/oauth2/callback?code=foo&state=' . $state);
    is($mech->status, HTTP_OK,
       'the callback renders the confirmation page for an oversized POST');
    $mech->content_lacks('very_large_name_', 'oversized POST parameters are dropped');

    LWP::UserAgent::Mockable->finished;

    $mech->cookie_jar->clear;
    $mech->post(
        '/release/add',
        { name => 'Cross Origin Seeded Release Name' },
        Origin => 'https://seeder.example.com',
    );
    is($mech->status, HTTP_OK,
       'a cross-origin POST renders the confirmation page immediately');
    $mech->content_contains(
        'originating from <strong>https://seeder.example.com</strong>',
        'the request origin is displayed',
    );
    $mech->content_contains(
        'Cross Origin Seeded Release Name',
        'the POST parameters are preserved',
    );
};

test 'Webhooks returns 503 when the secret is not configured' => sub {
    my $test = shift;
    my $mech = $test->mech;

    no warnings 'redefine';
    local *DBDefs::METABRAINZ_WEBHOOK_SECRET = sub { '' };
    use warnings 'redefine';

    my $res = $mech->request(_make_webhook_request(
        event => 'user.created',
        payload => { user_id => 9000 },
        signature => 'sha256=foo',
    ));

    is($res->code, HTTP_SERVICE_UNAVAILABLE, 'webhook response is 503');
    like($res->content, qr/not properly configured/,
         'error message mentions misconfiguration');
};

test 'Webhooks returns 400 when required headers are missing' => sub {
    my $test = shift;
    my $mech = $test->mech;

    my $res = $mech->request(_make_webhook_request(
        payload => { user_id => 9000 },
        signature => undef,
    ));

    is($res->code, HTTP_BAD_REQUEST, 'missing headers response is 400');
    like($res->content, qr/Missing required headers/,
         'error message mentions missing headers');
};

test 'Webhooks returns 401 for invalid signatures' => sub {
    my $test = shift;
    my $mech = $test->mech;

    my $res = $mech->request(_make_webhook_request(
        event => 'user.created',
        payload => { user_id => 9000 },
        signature => 'sha256=foo',
    ));

    is($res->code, HTTP_UNAUTHORIZED, 'webhook response is 401');
    like($res->content, qr/Invalid signature/,
         'error message mentions invalid signature');
};

test 'Webhooks returns 400 for unknown event types' => sub {
    my $test = shift;
    my $mech = $test->mech;

    my $res = $mech->request(_make_webhook_request(
        event => 'foo',
        payload => {},
    ));

    is($res->code, HTTP_BAD_REQUEST, 'webhook response is 400');
    like($res->content, qr/Unknown event type/,
         'error message mentions unknown event type');
};

test 'Webhooks returns 400 for invalid user IDs' => sub {
    my $test = shift;
    my $mech = $test->mech;

    for my $event (qw( user.created user.updated user.deleted )) {
        my $res = $mech->request(_make_webhook_request(
            event => $event,
            payload => { user_id => -1 },
        ));

        is($res->code, HTTP_BAD_REQUEST, 'webhook response is 400');
        like($res->content, qr/Invalid user_id/,
             "$event error message mentions an invalid user_id");
    }
};

test 'The user.created webhook can insert an editor' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    my $new_id = 9000;
    my $editor = $c->model('Editor')->get_by_id($new_id);
    ok(!defined $editor, "editor $new_id does not exist");

    my $res = $mech->request(_make_webhook_request(
        event => 'user.created',
        payload => {
            user_id => $new_id,
            name => 'new_editor9000',
            member_since => '2020-01-01T00:00:00+00:00',
        },
    ));

    is($res->code, HTTP_OK, 'webhook response is 200');
    my $content = decode_json($res->content);
    is($content->{status}, 'success', 'response is successful');

    $editor = $c->model('Editor')->get_by_id($new_id);
    ok(defined $editor, "editor $new_id is created");
    is($editor->name, 'new_editor9000', "editor $new_id name is correct");
};

test 'The user.updated webhook can update an editor' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    no warnings 'redefine';
    local *DBDefs::DISCOURSE_SERVER = sub { '' };
    use warnings 'redefine';

    my $res = $mech->request(_make_webhook_request(
        event => 'user.updated',
        payload => {
            user_id => 1,
            old => {
                name => 'new_editor',
                email => 'test@email.com',
            },
            new => {
                name => 'very_new_name',
                email => 'test2@email.com',
            },
            updated_at => '2000-01-01T00:00:00+00:00',
        },
    ));

    is($res->code, HTTP_OK, 'webhook response is 200');

    my $editor = $c->model('Editor')->get_by_id(1);
    is($editor->name, 'very_new_name', 'editor name is updated');
    is($editor->email, 'test2@email.com', 'editor email is updated');
};

test 'The user.updated webhook ignores already applied values' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    no warnings 'redefine';
    local *DBDefs::DISCOURSE_SERVER = sub { '' };
    use warnings 'redefine';

    my $res = $mech->request(_make_webhook_request(
        event => 'user.updated',
        payload => {
            user_id => 1,
            old => { name => 'old_editor' },
            # same as the current name
            new => { name => 'new_editor' },
            updated_at => '2000-01-01T00:00:00+00:00',
        },
    ));

    is($res->code, HTTP_OK, 'webhook response is 200');

    my $editor = $c->model('Editor')->get_by_id(1);
    is($editor->name, 'new_editor', 'editor name is still new_editor');
};

test 'The user.updated webhook errors if neither the old or new values match' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    no warnings 'redefine';
    local *DBDefs::DISCOURSE_SERVER = sub { '' };
    use warnings 'redefine';

    my $res = $mech->request(_make_webhook_request(
        event => 'user.updated',
        payload => {
            user_id => 1,
            old => {
                name => 'unknown_editor',
                email => 'unknown1@email.com',
            },
            new => {
                name => 'unknown_new_name',
                email => 'unknown2@email.com',
            },
            updated_at => '2000-01-01T00:00:00+00:00',
        },
    ));

    is($res->code, HTTP_BAD_REQUEST, 'webhook response is 400');

    my $content = decode_json($res->content);
    is($content->{status}, 'error', 'response contains an error');
};

test 'The user.deleted webhook can delete an editor' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    no warnings 'redefine';
    local *DBDefs::DISCOURSE_SERVER = sub { '' };
    use warnings 'redefine';

    my $editor = $c->model('Editor')->get_by_id(2);
    ok(!$editor->deleted, 'editor 2 is not deleted');

    my $res = $mech->request(_make_webhook_request(
        event => 'user.deleted',
        payload => { user_id => 2 },
    ));

    is($res->code, HTTP_OK, 'webhook response is 200');

    $editor = $c->model('Editor')->get_by_id(2);
    ok($editor->deleted, 'editor 2 is deleted');

    $res = $mech->request(_make_webhook_request(
        event => 'user.deleted',
        payload => { user_id => 2 },
    ));
    is($res->code, HTTP_OK,
       'webhook response is 200 for already deleted editor');
};

test 'The user.updated webhook rejects an invalid username' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    no warnings 'redefine';
    local *DBDefs::DISCOURSE_SERVER = sub { '' };
    use warnings 'redefine';

    my $res = $mech->request(_make_webhook_request(
        event => 'user.updated',
        payload => {
            user_id => 1,
            old => { name => 'new_editor' },
            new => { name => 'invalid://name' },
            updated_at => '2000-01-01T00:00:00+00:00',
        },
    ));

    is($res->code, HTTP_BAD_REQUEST, 'webhook response is 400');

    my $editor = $c->model('Editor')->get_by_id(1);
    is($editor->name, 'new_editor', 'editor name is unchanged');
};

test 'The user.updated webhook can update the email alone' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    no warnings 'redefine';
    local *DBDefs::DISCOURSE_SERVER = sub { '' };
    use warnings 'redefine';

    my $res = $mech->request(_make_webhook_request(
        event => 'user.updated',
        payload => {
            user_id => 1,
            old => { email => 'test@email.com' },
            new => { email => 'test2@email.com' },
            updated_at => '2001-02-03T04:05:06+00:00',
        },
    ));

    is($res->code, HTTP_OK, 'webhook response is 200');

    my $editor = $c->model('Editor')->get_by_id(1);
    is($editor->email, 'test2@email.com', 'editor email is updated');
    is($editor->name, 'new_editor', 'editor name is unchanged');
    is(
        $editor->email_confirmation_date->iso8601,
        '2001-02-03T04:05:06',
        'the email confirmation date is updated',
    );
};

test 'The user.updated webhook can update the name alone' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    no warnings 'redefine';
    local *DBDefs::DISCOURSE_SERVER = sub { '' };
    use warnings 'redefine';

    my $res = $mech->request(_make_webhook_request(
        event => 'user.updated',
        payload => {
            user_id => 1,
            old => { name => 'new_editor' },
            new => { name => 'new_editor2' },
            updated_at => '2000-01-01T00:00:00+00:00',
        },
    ));

    is($res->code, HTTP_OK, 'webhook response is 200');

    my $editor = $c->model('Editor')->get_by_id(1);
    is($editor->name, 'new_editor2', 'editor name is updated');
    is($editor->email, 'test@email.com', 'editor email is unchanged');
};

test 'The user.updated webhook errors on an empty update' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    no warnings 'redefine';
    local *DBDefs::DISCOURSE_SERVER = sub { '' };
    use warnings 'redefine';

    my $res = $mech->request(_make_webhook_request(
        event => 'user.updated',
        payload => {
            user_id => 1,
            old => {},
            new => {},
            updated_at => '2000-01-01T00:00:00+00:00',
        },
    ));

    is($res->code, HTTP_BAD_REQUEST, 'webhook response is 400');

    my $content = decode_json($res->content);
    is($content->{status}, 'error', 'response contains an error');
    is(
        $content->{message},
        'Malformed user.updated payload (no updates?)',
        'response error mentions no updates',
    );
};

test 'The user.updated webhook ignores nonexistent or deleted users' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    no warnings 'redefine';
    local *DBDefs::DISCOURSE_SERVER = sub { '' };
    use warnings 'redefine';

    $c->model('Editor')->delete(1);
    $c->model('Editor')->delete(2);

    my $editor1 = $c->model('Editor')->get_by_id(1);
    # editor id=2 (Alice) has an annotation so won't be fully deleted
    my $editor2 = $c->model('Editor')->get_by_id(2);
    ok(!defined $editor1, 'editor 1 was fully deleted');
    ok(defined $editor2 && $editor2->deleted, 'editor 2 was deleted');

    my $res = $mech->request(_make_webhook_request(
        event => 'user.updated',
        payload => {
            user_id => 1,
            old => { name => 'new_editor' },
            new => { name => 'new_editor2' },
            updated_at => '2000-01-01T00:00:00+00:00',
        },
    ));
    is($res->code, HTTP_OK,
       'webhook response for nonexistent editor is 200');

    $res = $mech->request(_make_webhook_request(
        event => 'user.updated',
        payload => {
            user_id => 2,
            old => { name => 'Alice' },
            new => { name => 'Alice2' },
            updated_at => '2000-01-01T00:00:00+00:00',
        },
    ));
    is($res->code, HTTP_OK,
       'webhook response for deleted editor is 200');
};

test 'The user.created webhook ignores an existing editor' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    my $res = $mech->request(_make_webhook_request(
        event => 'user.created',
        payload => {
            user_id => 1,
            name => 'new_editor2',
            member_since => '2020-01-01T00:00:00+00:00',
        },
    ));

    is($res->code, HTTP_OK, 'webhook response is 200');

    my $editor = $c->model('Editor')->get_by_id(1);
    is($editor->name, 'new_editor', 'the existing editor is unchanged');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
