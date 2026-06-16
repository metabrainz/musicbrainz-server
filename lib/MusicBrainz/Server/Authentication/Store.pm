package MusicBrainz::Server::Authentication::Store;

use strict;
use warnings;

use MusicBrainz::Server::Authentication::User;

sub new
{
    my ($class, $config, $app, $realm) = @_;
    bless { }, $class;
}

sub find_user
{
    my ($self, $authinfo, $c) = @_;

    my $editor;
    if (exists $authinfo->{username}) {
        $editor = $c->model('Editor')->get_by_name($authinfo->{username});
    } elsif (exists $authinfo->{editor_id}) {
        $editor = $c->model('Editor')->get_by_id($authinfo->{editor_id});
    }

    if (defined $editor) {
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
    return $self->find_user({ editor_id => $frozen->{id} }, $c);
}

1;
