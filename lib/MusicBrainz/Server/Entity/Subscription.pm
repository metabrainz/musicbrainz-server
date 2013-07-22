package MusicBrainz::Server::Entity::Subscription;
use Moose::Role;
use namespace::autoclean;

has 'id' => (
    isa => 'Int',
    is => 'ro'
);

has 'editor_id' => (
    isa => 'Int',
    is => 'ro'
);

1;
