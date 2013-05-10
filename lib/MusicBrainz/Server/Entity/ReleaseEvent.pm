package MusicBrainz::Server::Entity::ReleaseEvent;
use Moose;

use MusicBrainz::Server::Entity::Types;

has date => (
    is => 'ro',
    isa => 'PartialDate'
);

has country_id => (
    is => 'ro',
    isa => 'Maybe[Int]'
);

has country => (
    is => 'rw',
    isa => 'Maybe[Area]'
);

1;
