package MusicBrainz::Server::Authentication::Store;

use strict;
use warnings;

use MusicBrainz::Server::Authentication::User;
use MusicBrainz::Server::Entity::Editor;
use UserPreference;

sub new
{
    my ($class, $config, $app, $realm) = @_;
    bless { }, $class;
}

sub find_user
{
    my ($self, $authinfo, $c) = @_;
    my $editor = $c->model('Editor')->get_by_name($authinfo->{username});
    if (defined $editor) {
        my $class = Class::MOP::Class->initialize('MusicBrainz::Server::Authentication::User');
        return $class->rebless_instance($editor);
    }
    return undef;
}

sub for_session
{
    my ($self, $c, $user) = @_;

    return {
        id => $user->id,
        name => $user->name,
        privs => $user->privileges,
        email => $user->email,
        emailconf => $user->email_confirmation_date,
        accepted_edits => $user->accepted_edits,
    };
}

sub from_session
{
    my ($self, $c, $frozen) = @_;

    my %args = (
        id => $frozen->{id},
        name => $frozen->{name},
        accepted_edits => $frozen->{accepted_edits},
    );
    $args{email} = $frozen->{email}
        if defined $frozen->{email};
    $args{email_confirmation_date} = $frozen->{emailconf}
        if defined $frozen->{emailconf};

    return MusicBrainz::Server::Authentication::User->new(%args);
}

1;
