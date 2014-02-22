package MusicBrainz::Server::Entity::WorkAttribute;
use Moose;
use MusicBrainz::Server::Translation qw( l );

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

sub l_value {
    my $self = shift;
    return $self->value_id ? l($self->value) : $self->value;
}

__PACKAGE__->meta->make_immutable;
1;
