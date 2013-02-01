package MusicBrainz::Server::Entity::Tree::Work;
use Moose;

has work => (
    is => 'rw',
    predicate => 'work_set',
);

has aliases => (
    is => 'rw',
    predicate => 'aliases_set',
);

has iswcs => (
    is => 'rw',
    predicate => 'iswcs_set',
);

has annotation => (
    is => 'rw',
    predicate => 'annotation_set'
);

has relationships => (
    is => 'rw',
    predicate => 'relationships_set'
);

sub merge {
    my ($self, $tree) = @_;

    $self->work($tree->work)
        if ($tree->work_set);

    $self->aliases($tree->aliases)
        if ($tree->aliases_set);

    $self->iswcs($tree->iswcs)
        if ($tree->iswcs_set);

    $self->annotation($tree->annotation)
        if ($tree->annotation_set);

    $self->relationships($tree->relationships)
        if ($tree->relationships_set);

    return $self;
}

sub complete {
    my $tree = shift;
    return $tree->work_set && $tree->aliases_set && $tree->iswcs_set;
}

1;
