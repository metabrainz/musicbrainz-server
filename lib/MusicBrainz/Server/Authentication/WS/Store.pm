package MusicBrainz::Server::Authentication::WS::Store;

use strict;
use warnings;

use DateTime;
use MusicBrainz::Server::Authentication::WS::User;

sub new
{
    my ($class, $config, $app, $realm) = @_;
    bless { }, $class;
}

sub find_user
{
    my ($self, $authinfo, $c) = @_;
    my $user;

    if (exists $authinfo->{oauth_access_token}) {
        my $token = $c->model('EditorOAuthToken')->get_by_access_token($authinfo->{oauth_access_token});
        if (defined $token) {
            my $editor = $c->model('Editor')->get_by_id($token->editor_id);
            if (defined $editor) {
                $user = MusicBrainz::Server::Authentication::WS::User->new_from_editor($editor);
                $user->oauth_token($token);
            }
        }
    }
    else {
        my $editor = $c->model('Editor')->get_by_name($authinfo->{username});
        if (defined $editor) {
            $user = MusicBrainz::Server::Authentication::WS::User->new_from_editor($editor);
        }
    }

    return $user;
}

sub for_session
{
    die 'Not supported';
}

sub from_session
{
    die 'Not supported';
}

1;
