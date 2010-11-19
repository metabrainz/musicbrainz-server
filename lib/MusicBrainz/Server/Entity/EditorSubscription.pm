package MusicBrainz::Server::Entity::EditorSubscription;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::Subscription';

has 'subscribededitor' => (
    isa => 'Editor',
    is => 'rw'
);

has 'subscribededitor_id' => (
    isa => 'Int',
    is => 'ro',
);

sub type { 'editor' }

1;
