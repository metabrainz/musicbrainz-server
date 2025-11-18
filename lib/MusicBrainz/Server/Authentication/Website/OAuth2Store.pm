package MusicBrainz::Server::Authentication::Website::OAuth2Store;

use strict;
use warnings;

use JSON::XS qw( decode_json );

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

    my $user_info_uri = DBDefs->METABRAINZ_INTERNAL_URL . '/oauth2/userinfo';
    my $user_info_response = $lwp->request(GET $user_info_uri,
        'Authorization' => 'Bearer ' . $token->access_token,
    );
    unless ($user_info_response->is_success) {
        die 'An internal error occurred while fetching userinfo from ' .
            'MetaBrainz.';
    }

    my $user_info = decode_json($user_info_response->decoded_content);
    my $editor;

    $c->model('MB')->with_transaction(sub {
        $editor = $c->model('Editor')->insert_from_metabrainz(
            $user_info->{metabrainz_user_id},
            $user_info->{sub},
            $user_info->{member_since},
        );
        if (defined $editor) {
            $c->model('Editor')->load_preferences($editor);
        }
    });

    return MusicBrainz::Server::Authentication::User->new_from_editor($editor);
}

1;
