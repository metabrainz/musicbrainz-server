package MusicBrainz::Server::Entity::Role::Subscription::Delete;
use Moose::Role;
use namespace::autoclean;

has 'deleted_by_edit' => (
    isa => 'Int',
    is => 'ro'
);

1;
