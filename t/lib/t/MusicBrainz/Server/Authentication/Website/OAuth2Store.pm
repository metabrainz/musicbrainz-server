package t::MusicBrainz::Server::Authentication::Website::OAuth2Store;

use strict;
use warnings;

use HTTP::Response;
use HTTP::Status qw( :constants );
use LWP::UserAgent::Mockable;
use Test::Routine;
use Test::More;
use URI;
use URI::QueryParam;

use MusicBrainz::Server::Test qw( build_json_response );

with 't::Mechanize', 't::Context';

my $EDITOR_ID = 3000003;
my $EDITOR_NAME = 'auto_create_user_test';

sub _metabrainz_oauth2_response {
    my ($request) = @_;

    my $path = $request->uri->path;
    if ($path eq '/oauth2/token') {
        return build_json_response({
            access_token => 'meba_test_access_token',
            token_type => 'Bearer',
            expires_in => 3600,
            refresh_token => 'mebr_test_refresh_token',
        });
    } elsif ($path eq '/oauth2/introspect') {
        my $issued_at = time;
        return build_json_response({
            active => JSON::true,
            sub => $EDITOR_ID,
            username => $EDITOR_NAME,
            scope => ['profile'],
            token_type => 'Bearer',
            issued_at => $issued_at,
            expires_at => $issued_at + 3600,
        });
    } elsif ($path eq '/oauth2/userinfo') {
        return build_json_response({
            sub => $EDITOR_ID,
            username => $EDITOR_NAME,
            member_since => '2000-01-01T00:00:00+00:00',
        });
    }

    return HTTP::Response->new(
        HTTP_INTERNAL_SERVER_ERROR, "unexpected request to $path");
}

test 'Auto-create user on OAuth login' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    no warnings 'redefine';
    # Enable MetaBrainz OAuth login.
    local *DBDefs::LOCAL_ACCOUNTS_ENABLED = sub { 0 };
    use warnings 'redefine';

    ok(
        !defined $c->model('Editor')->get_by_id($EDITOR_ID),
        "editor $EDITOR_ID does not exist before logging in",
    );

    $mech->max_redirect(0);
    $mech->get('/login');
    is($mech->status, HTTP_FOUND, '/login redirects to MetaBrainz');

    my $redirect = URI->new($mech->response->header('Location'));
    my $state = $redirect->query_param('state');

    LWP::UserAgent::Mockable->reset;
    LWP::UserAgent::Mockable->set_record_pre_callback(\&_metabrainz_oauth2_response);

    $mech->get('/metabrainz/oauth2/callback?code=foo&state=' . $state);

    LWP::UserAgent::Mockable->finished;

    my $editor = $c->model('Editor')->get_by_id($EDITOR_ID);
    ok(
        defined $editor && $editor->name eq $EDITOR_NAME,
        "editor $EDITOR_ID was auto-created on login",
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
