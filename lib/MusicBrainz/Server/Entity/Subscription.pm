package MusicBrainz::Server::Entity::Subscription;
use Moose;
use namespace::autoclean;

has 'id' => (
    isa => 'Int',
    is => 'ro'
);

has 'editor_id' => (
    isa => 'Int',
    is => 'ro'
);

has 'last_edit_sent' => (
    isa => 'Int',
    is => 'ro'
);

1;
