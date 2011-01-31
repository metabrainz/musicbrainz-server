package MusicBrainz::Server::Entity::Subscription;
use Moose;
use namespace::autoclean;

has 'editor_id' => (
    isa => 'Int',
    is => 'ro'
);

has 'last_edit_sent' => (
    isa => 'Int',
    is => 'ro'
);

1;
