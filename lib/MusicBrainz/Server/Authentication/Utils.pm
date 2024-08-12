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
    find_oauth_access_token
);

sub find_oauth_access_token {
    my ($c, $oauth_access_token) = @_;

    if (
        DBDefs->METABRAINZ_OAUTH_URL &&
        $oauth_access_token =~ /^meba_/
    ) {
        my $ctx = $c->model('MB')->context;
        my $introspect_url = DBDefs->METABRAINZ_OAUTH_URL . '/introspect';
        my $res = $ctx->lwp->request(
            POST $introspect_url,
            {
                client_id => DBDefs->METABRAINZ_OAUTH_CLIENT_ID,
                client_secret => DBDefs->METABRAINZ_OAUTH_CLIENT_SECRET,
                token => $oauth_access_token,
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
                    access_token => $oauth_access_token,
                    editor_id => $res_content->{metabrainz_user_id},
                    expire_time => DateTime->from_epoch($res_content->{expires_at}),
                    granted => DateTime->from_epoch($res_content->{issued_at}),
                    scope => $scope,
                );
            }
        }
    } else {
        return $c->model('EditorOAuthToken')->get_by_access_token($oauth_access_token);
    }
    return;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
