package MusicBrainz::Server::Authentication::Store;

use strict;
use warnings;

use DateTime;
use MusicBrainz::Server::Authentication::User;
use MusicBrainz::Server::Authentication::Utils qw(
    find_oauth_access_token
);

sub new
{
    my ($class, $config, $app, $realm) = @_;
    bless { }, $class;
}

sub find_user
{
    my ($self, $authinfo, $c) = @_;
    my $editor;

    if (exists $authinfo->{oauth_access_token}) {
        my $token = find_oauth_access_token($c, $authinfo->{oauth_access_token});
        if (defined $token) {
            $editor = $c->model('Editor')->get_by_id($token->editor_id);
        }
    }
    else {
        $editor = $c->model('Editor')->get_by_name($authinfo->{username});
    }

    if (defined $editor && $editor->password) {
        $c->model('Editor')->load_preferences($editor);
        return _rebless_editor($editor);
    }
    return undef;
}

sub for_session
{
    my ($self, $c, $user) = @_;
    return { id => $user->id };
}

sub from_session
{
    my ($self, $c, $frozen) = @_;
    my $editor = $c->model('Editor')->get_by_id($frozen->{id});
    return unless ($editor && !$editor->deleted);
    return _rebless_editor($editor);
}

sub _rebless_editor {
    my $editor = shift or return undef;
    my $class = Class::MOP::Class->initialize('MusicBrainz::Server::Authentication::User');
    return $class->rebless_instance($editor);
}

1;
