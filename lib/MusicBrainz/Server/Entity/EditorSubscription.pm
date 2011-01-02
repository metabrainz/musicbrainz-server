package MusicBrainz::Server::Entity::EditorSubscription;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::Subscription';

has 'subscribed_editor' => (
    isa => 'Editor',
    is => 'rw'
);

has 'subscribed_editor_id' => (
    isa => 'Int',
    is => 'ro',
);

sub type { 'editor' }

1;
