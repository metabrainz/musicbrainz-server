package MusicBrainz::Server::Entity::EditorSubscription;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Entity::Subscription';

has 'subscribededitor_id' => (
    isa => 'Int',
    is => 'ro',
);

1;
