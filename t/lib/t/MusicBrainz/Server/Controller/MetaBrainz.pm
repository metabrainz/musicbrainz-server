package t::MusicBrainz::Server::Controller::MetaBrainz;

use strict;
use warnings;

use Digest::SHA qw( hmac_sha256_hex );
use HTTP::Request;
use JSON::XS qw( decode_json encode_json );
use Test::Routine;
use Test::More;

use DBDefs;

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

    is($res->code, 503, 'webhook response is 503');
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

    is($res->code, 400, 'missing headers reponse is 400');
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

    is($res->code, 401, 'webhook response is 401');
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

    is($res->code, 400, 'webhook response is 400');
    like($res->content, qr/Unknown event type/,
         'error message mentions unknown event type');
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

    is($res->code, 200, 'webhook response is 200');
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

    is($res->code, 200, 'webhook response is 200');

    my $editor = $c->model('Editor')->get_by_id(1);
    is($editor->name, 'very_new_name', 'editor name is updated');
    is($editor->email, 'test2@email.com', 'editor email is updated');
};

test 'The user.updated webhook ignores already applied values' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');

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

    is($res->code, 200, 'webhook response is 200');

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

    is($res->code, 500, 'webhook response is 500');

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

    is($res->code, 200, 'webhook response is 200');

    $editor = $c->model('Editor')->get_by_id(2);
    ok($editor->deleted, 'editor 2 is deleted');

    $res = $mech->request(_make_webhook_request(
        event => 'user.deleted',
        payload => { user_id => 2 },
    ));
    is($res->code, 200,
       'webhook response is 200 for already deleted editor');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
