package MusicBrainz::Server::Entity::Role::Quality;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Types qw( Quality );

has 'quality' => (
    isa => Quality,
    is  => 'rw',
);

1;
