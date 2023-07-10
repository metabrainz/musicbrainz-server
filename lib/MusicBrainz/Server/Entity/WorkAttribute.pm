package MusicBrainz::Server::Entity::WorkAttribute;
use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation::Attributes qw( lp );

with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'WorkAttributeType' };

sub entity_type { 'work_attribute' }

has id => (
    isa => 'Maybe[Int]',
    required => 1,
    is => 'ro',
);

has value_id => (
    isa => 'Maybe[Int]',
    required => 1,
    is => 'ro',
);

has value_gid => (
    isa => 'Maybe[Str]',
    is => 'ro',
);

has value => (
    isa => 'Str',
    required => 1,
    is => 'ro',
);

sub l_value {
    my $self = shift;
    return $self->value_id ? lp($self->value, 'work_attribute_type_allowed_value') : $self->value;
}

sub TO_JSON {
    my ($self) = @_;
    return {
        id => $self->id,
        value_id => $self->value_id,
        value => $self->value,
    };
}

__PACKAGE__->meta->make_immutable;
1;
