package MusicBrainz::Server::Entity::Role::Subscription::Merge;
use Moose::Role;
use namespace::autoclean;

has 'merged_by_edit' => (
    is => 'ro',
    isa => 'Int',
);

1;
