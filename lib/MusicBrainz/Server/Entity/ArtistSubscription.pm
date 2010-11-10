package MusicBrainz::Server::Entity::ArtistSubscription;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Entity::Subscription';

with qw(
    MusicBrainz::Server::Entity::Role::Subscription::Delete
    MusicBrainz::Server::Entity::Role::Subscription::Merge
);

has 'artist_id' => (
    isa => 'Int',
    is => 'ro',
);

has 'artist' => (
    isa => 'Artist',
    is => 'rw',
);

1;
