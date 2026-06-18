package MusicBrainz::Server::Authentication::Utils;

use strict;
use warnings;

use base 'Exporter';
use DateTime;
use HTTP::Request::Common qw( POST );
use HTTP::Status qw( is_server_error is_success );

use DBDefs;
use MusicBrainz::Server::Entity::EditorOAuthToken;
use MusicBrainz::Server::Constants qw( :access_scope );

our @EXPORT_OK = qw(
    find_active_metabrainz_oauth_access_token
    find_active_oauth_access_token
);

sub find_active_metabrainz_oauth_access_token {
    my ($c, $access_token) = @_;

    my $ctx = $c->model('MB')->context;
    my $introspect_url = DBDefs->METABRAINZ_URL . '/oauth2/introspect';
    my $res = $ctx->lwp->request(
        POST $introspect_url,
        {
            client_id => DBDefs->METABRAINZ_OAUTH_CLIENT_ID,
            client_secret => DBDefs->METABRAINZ_OAUTH_CLIENT_SECRET,
            token => $access_token,
        },
    );
    if (is_success($res->code)) {
        my $res_content = $c->json_utf8->decode($res->content);
        if ($res_content->{active}) {
            my $scope = 0;
            for my $scope_name (@{ $res_content->{scope} }) {
                $scope |= $ACCESS_SCOPE_BY_NAME{$scope_name};
            }
            my $token_instance = MusicBrainz::Server::Entity::EditorOAuthToken->new(
                access_token => $access_token,
                editor_id => $res_content->{metabrainz_user_id},
                expire_time => DateTime->from_epoch($res_content->{expires_at}),
                granted => DateTime->from_epoch($res_content->{issued_at}),
                scope => $scope,
            );
            if ($token_instance->is_expired) {
                return;
            }
            return $token_instance;
        }
    } elsif (is_server_error($res->code)) {
        die 'An internal error occurred while attempting to introspect ' .
            'the access token.';
    }
    return;
}

sub find_active_musicbrainz_oauth_access_token {
    my ($c, $access_token) = @_;

    my $token_instance = $c->model('EditorOAuthToken')->get_by_access_token($access_token);
    if (defined $token_instance && !$token_instance->is_expired) {
        return $token_instance;
    }
    return;
}

sub find_active_oauth_access_token {
    my ($c, $access_token) = @_;

    return unless defined $access_token;

    if ($access_token =~ /^meba_/) {
        return find_active_metabrainz_oauth_access_token($c, $access_token);
    }
    return find_active_musicbrainz_oauth_access_token($c, $access_token);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
