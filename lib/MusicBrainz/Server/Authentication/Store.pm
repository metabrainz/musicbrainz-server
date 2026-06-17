package MusicBrainz::Server::Authentication::Store;

use strict;
use warnings;

use DateTime;
use MusicBrainz::Server::Authentication::User;

sub new
{
    my ($class, $config, $app, $realm) = @_;
    bless { }, $class;
}

sub find_user
{
    my ($self, $authinfo, $c) = @_;

    my $editor = $c->model('Editor')->get_by_name($authinfo->{username});

    if (defined $editor && $editor->password) {
        $c->model('Editor')->load_preferences($editor);
        return MusicBrainz::Server::Authentication::User->new_from_editor($editor);
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
    return MusicBrainz::Server::Authentication::User->new_from_editor($editor);
}

1;
