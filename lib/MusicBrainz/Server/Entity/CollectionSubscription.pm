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

has 'unavailable' => (
    isa => 'Bool',
    is => 'ro'
);

has 'last_seen_name' => (
    isa => 'Str',
    is => 'ro'
);

sub target_id { shift->collection_id }
sub type { 'collection' }

1;
