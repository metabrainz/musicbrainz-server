package MusicBrainz::Server::Authentication::Utils;

use strict;
use warnings;

use base 'Exporter';
use DateTime;
use HTTP::Request::Common qw( POST );
use HTTP::Status qw( HTTP_OK );

use DBDefs;
use MusicBrainz::Server::Entity::EditorOAuthToken;
use MusicBrainz::Server::Constants qw( :access_scope );

our @EXPORT_OK = qw(
    find_metabrainz_oauth_access_token
    find_oauth_access_token
);

sub find_metabrainz_oauth_access_token {
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
    if ($res->code == HTTP_OK) {
        my $res_content = $c->json_utf8->decode($res->content);
        if ($res_content->{active}) {
            my $scope = 0;
            for my $scope_name (@{ $res_content->{scope} }) {
                $scope |= $ACCESS_SCOPE_BY_NAME{$scope_name};
            }
            return MusicBrainz::Server::Entity::EditorOAuthToken->new(
                access_token => $access_token,
                editor_id => $res_content->{sub},
                expire_time => DateTime->from_epoch($res_content->{expires_at}),
                granted => DateTime->from_epoch($res_content->{issued_at}),
                scope => $scope,
            );
        }
    }
    return;
}

sub find_musicbrainz_oauth_access_token {
    my ($c, $access_token) = @_;

    return $c->model('EditorOAuthToken')->get_by_access_token($access_token);
}

sub find_oauth_access_token {
    my ($c, $access_token) = @_;

    if ($access_token =~ /^meba_/) {
        return find_metabrainz_oauth_access_token($c, $access_token);
    }
    return find_musicbrainz_oauth_access_token($c, $access_token);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
