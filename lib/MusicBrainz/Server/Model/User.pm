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

    my $us = new UserStuff($self->{_dbh});
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

    my $prefs = UserPreference->newFromUser($self->{_dbh}, $user->id);
    $prefs->load;

    return $prefs;
}

1;
