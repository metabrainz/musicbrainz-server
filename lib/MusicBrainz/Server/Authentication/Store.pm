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
    if (defined $editor) {
        $c->model('Editor')->load_preferences($editor);
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
        emailconf => defined $user->email_confirmation_date
            ? $user->email_confirmation_date->epoch
            : undef,
        registered => $user->registration_date->epoch,
        accepted_edits => $user->accepted_edits,
        prefs => $user->preferences,
    };
}

sub from_session
{
    my ($self, $c, $frozen) = @_;

    my %args = (
        id => $frozen->{id},
        name => $frozen->{name},
        accepted_edits => $frozen->{accepted_edits},
        preferences => $frozen->{prefs},
        privileges => $frozen->{privs},
        registration_date => DateTime->from_epoch( epoch => $frozen->{registered} )
    );
    $args{email} = $frozen->{email}
        if defined $frozen->{email};
    $args{email_confirmation_date} = DateTime->from_epoch( epoch => $frozen->{emailconf} )
        if defined $frozen->{emailconf};

    return MusicBrainz::Server::Authentication::User->new(%args);
}

1;
