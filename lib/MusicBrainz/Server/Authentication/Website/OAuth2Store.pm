package MusicBrainz::Server::Authentication::Website::OAuth2Store;

use strict;
use warnings;

use LWP::UserAgent;

use DBDefs;
use HTTP::Request::Common qw( GET );
use MusicBrainz::Server::Authentication::User;

use parent 'MusicBrainz::Server::Authentication::Store';

sub auto_create_user {
    my ($self, $auth_info, $c) = @_;

    my $token = $auth_info->{editor_oauth_token};
    return unless defined $token;

    my $lwp = LWP::UserAgent->new;
    $lwp->env_proxy;
    $lwp->timeout(5);
    $lwp->agent(DBDefs->LWP_USER_AGENT);

    my $user_info_uri = DBDefs->METABRAINZ_URL . '/oauth2/userinfo';
    my $user_info_response = $lwp->request(GET $user_info_uri,
        'Authorization' => 'Bearer ' . $token->access_token,
    );
    unless ($user_info_response->is_success) {
        die 'An internal error occurred while fetching userinfo from ' .
            'MetaBrainz.';
    }

    my $user_info = $c->json_utf8->decode($user_info_response->content);
    my $editor;

    $c->model('MB')->with_transaction(sub {
        $editor = $c->model('Editor')->insert_from_metabrainz(
            $user_info->{sub},
            $user_info->{username},
            $user_info->{member_since},
        );
        if (defined $editor) {
            $c->model('Editor')->load_preferences($editor);
        }
    });

    return MusicBrainz::Server::Authentication::User->new_from_editor($editor);
}

1;

=head1 DESCRIPTION

An extension of C<MusicBrainz::Server::Authentication::Store> which
auto-creates new users from a MetaBrainz OAuth token.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
