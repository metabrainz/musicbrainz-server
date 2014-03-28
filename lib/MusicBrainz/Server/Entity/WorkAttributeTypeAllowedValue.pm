package MusicBrainz::Server::Entity::WorkAttributeTypeAllowedValue;
use Moose;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation::Attributes qw( lp );

extends 'MusicBrainz::Server::Entity';

has work_attribute_type_id => (
    is => 'rw',
    isa => 'Int',
);

has value => (
    is => 'rw',
    isa => 'Str',
);

has child_order => (
    is => 'rw',
    isa => 'Int',
);

has parent_id => (
    is => 'rw',
    isa => 'Maybe[Int]',
);

has parent => (
    is => 'rw',
    isa => 'Maybe[WorkAttributeTypeAllowedValue]',
);

has children => (
    is => 'rw',
    isa => 'ArrayRef[WorkAttributeTypeAllowedValue]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_children => 'elements',
        add_child => 'push',
        clear_children => 'clear'
    }
);

has description => (
    is => 'rw',
    isa => 'Maybe[Str]',
);

sub l_value {
    my $self = shift;
    return lp($self->value, 'work_attribute_type_allowed_value')
}

sub to_json_hash {
    my $self = shift;

    return {
        id => $self->id,
        workAttributeTypeID => $self->work_attribute_type_id,
        value => $self->l_value,
        parentID => $self->parent_id,
        description => $self->description,
    };
}

__PACKAGE__->meta->make_immutable;
1;
