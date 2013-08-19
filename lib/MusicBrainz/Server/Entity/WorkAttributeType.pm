package MusicBrainz::Server::Entity::WorkAttributeType;
use Moose;

extends 'MusicBrainz::Server::Entity';

use MusicBrainz::Server::Translation qw( lp );

has name => (
    isa => 'Str',
    is => 'ro',
    required => 1
);

has comment => (
    isa => 'Str',
    is => 'ro',
    required => 1
);

sub l_name {
    my $self = shift;
    return lp($self->name, 'work_attribute_type')
}

__PACKAGE__->meta->make_immutable;
1;
