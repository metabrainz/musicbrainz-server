package MusicBrainz::Server::Entity::Role::Quality;
use Moose::Role;

use MusicBrainz::Server::Types;

has 'quality' => (
    isa => 'Quality',
    is  => 'rw',
);

1;
