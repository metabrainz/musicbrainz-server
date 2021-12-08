package MusicBrainz::Server::MergeQueue;
use Moose;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use namespace::autoclean;

has 'type' => (
    isa => 'Str',
    is => 'ro',
    required => 1
);

has 'entities' => (
    isa => 'ArrayRef',
    is => 'rw',
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        _add_entities => 'push',
        entity_count => 'count',
        all_entities => 'elements'
    }
);

sub ready_to_merge {
    my $self = shift;
    return $self->entity_count >= 2;
}

sub add_entities {
    my ($self, @entities) = @_;
    my %all_existing = map { $_ => 1 } grep { $_ } $self->all_entities;
    my %new = map { $_ => 1 }
        grep { !exists $all_existing{ $_ } } @entities;
    $self->_add_entities(keys %new);
}

sub remove_entities {
    my ($self, @entities) = @_;
    my %to_remove = map { $_ => 1 } grep { $_ } @entities;
    my %all_existing = map { $_ => 1 } grep { $_ } $self->all_entities;
    $self->entities([
        grep { !exists $to_remove{$_} } keys %all_existing
    ])
}

sub TO_JSON {
    my ($self) = @_;

    return {
        type => $self->type,
        entities => $self->entities,
        ready_to_merge => boolean_to_json($self->ready_to_merge),
    };
}

1;
