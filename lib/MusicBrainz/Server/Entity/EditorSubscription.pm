package MusicBrainz::Server::Entity::EditorSubscription;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;

with 'MusicBrainz::Server::Entity::Subscription::Active';

has 'subscribed_editor' => (
    isa => 'Editor',
    is => 'rw'
);

has 'subscribed_editor_id' => (
    isa => 'Int',
    is => 'ro',
);

sub type { 'editor' }

sub target_id { shift->subscribed_editor_id }

1;
