package MusicBrainz::Server::Entity::CollectionSubscription;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Entity::Subscription';

has 'collection_id' => (
    isa => 'Int',
    is => 'ro',
);

has 'collection' => (
    isa => 'Collection',
    is => 'rw',
);

sub target_id { shift->collection_id }
sub type { 'collection' }

1;
