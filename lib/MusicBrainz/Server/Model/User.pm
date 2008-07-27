package MusicBrainz::Server::Model::User;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use MusicBrainz::Server::Authentication::User;

use Carp;

sub load_user
{
    my ($self, $opts) = @_;

    croak 'Opts should be a hash reference'
        unless ref $opts eq 'HASH';

    croak 'Opts must contain either username or user id'
        unless (defined $opts->{username}) || (defined $opts->{id});

    my $us = new UserStuff($self->dbh);
    my $user;

    if (defined $opts->{username})
    {
        $user = $us->newFromName($opts->{username});
    }
    else
    {
        $user = $us->newFromId($opts->{id});
    }

    my $ret = MusicBrainz::Server::Authentication::User->new($user);

    return $ret;
}

sub get_preferences_hash
{
    my ($self, $user) = @_;

    my $prefs = UserPreference->newFromUser($self->dbh, $user->id);
    $prefs->load;

    return $prefs;
}

sub create
{
    my ($self, $username, $password) = @_;

    my $user_stuff = UserStuff->new($self->mbh);
    my ($user_obj, $error_messages) = $user_stuff->CreateLogin($username, $password);

    return undef
        unless @$error_messages == 0;

    return MusicBrainz::Server::Authentication::User->new($user_obj);
}

sub find_by_email
{
    my ($self, $email) = @_;

    my $user_stuff = new UserStuff($self->dbh);
    my $usernames = $user_stuff->LookupNameByEmail($email);

    return [ map { MusicBrainz::Server::Authentication::User->new($_) } @$usernames ];
}

1;
