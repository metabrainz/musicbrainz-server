package MusicBrainz::Server::Entity::EditorSubscription;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Entity::Subscription';

has 'subscribededitor' => (
    isa => 'Editor',
    is => 'ro',
);

has 'subscribededitor_id' => (
    isa => 'Int',
    is => 'ro',
);

1;
