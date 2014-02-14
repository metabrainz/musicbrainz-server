package MusicBrainz::Server::Entity::WorkAttributeType;
use Moose;

extends 'MusicBrainz::Server::Entity';

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

has 'child_order' => (
    is => 'rw',
    isa => 'Int',
);

has 'parent_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'parent' => (
    is => 'rw',
    isa => 'WorkAttributeType',
);

has 'children' => (
    is => 'rw',
    isa => 'ArrayRef[WorkAttributeType]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_children => 'elements',
        add_child => 'push',
        clear_children => 'clear'
    }
);

has 'description' => (
    is => 'rw',
    isa => 'Str',
);

__PACKAGE__->meta->make_immutable;
1;
