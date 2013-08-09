package MusicBrainz::Server::Entity::WorkAttribute;
use Moose;

has type => (
    isa => 'Object',
    required => 1,
    is => 'ro',
);

has value_id => (
    isa => 'Maybe[Int]',
    required => 1,
    is => 'ro',
);

has value => (
    isa => 'Str',
    required => 1,
    is => 'ro',
);

__PACKAGE__->meta->make_immutable;
1;
