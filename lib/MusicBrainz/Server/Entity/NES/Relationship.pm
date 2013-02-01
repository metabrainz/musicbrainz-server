package MusicBrainz::Server::Entity::NES::Relationship;
use Moose;

has target => (
    is => 'ro',
    required => 1
);

has link_type_id => (
    is => 'ro',
    required => 1
);

1;
