package MusicBrainz::Server::Model::User;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

use Carp;

sub load
{
    my ($self, $opts) = @_;

    croak 'Opts should be a hash reference'
        unless ref $opts eq 'HASH';

    croak 'Opts must contain either username or user id'
        unless (defined $opts->{username}) || (defined $opts->{id});

    my $us = new MusicBrainz::Server::Editor($self->dbh);
    my $user;

    if (defined $opts->{username})
    {
        $user = $us->newFromName($opts->{username});
    }
    else
    {
        $user = $us->newFromId($opts->{id});
    }

    return $user;
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

    my $user_stuff = MusicBrainz::Server::Editor->new($self->dbh);
    my ($user_obj, $error_messages) = $user_stuff->CreateLogin($username, $password);

    return undef
        unless @$error_messages == 0;

    return $user_obj;
}

sub find_by_email
{
    my ($self, $email) = @_;

    my $user_stuff = new MusicBrainz::Server::Editor($self->dbh);
    my $usernames = $user_stuff->LookupNameByEmail($email);

    return $usernames;
}

sub search
{
	my ($self, $query) = @_;
	
	my $editor = MusicBrainz::Server::Editor->new($self->dbh);
	return $editor->search(query => $query, limit => 0);
}

1;
