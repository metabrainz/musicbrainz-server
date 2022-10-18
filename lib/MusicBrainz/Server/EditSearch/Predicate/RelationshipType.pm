package MusicBrainz::Server::EditSearch::Predicate::RelationshipType;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::EditSearch::Predicate';

use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_CREATE
    $EDIT_RELATIONSHIP_EDIT
    $EDIT_RELATIONSHIP_DELETE
    $EDIT_RELATIONSHIPS_REORDER
);

sub operator_cardinality_map {
    return (
        '=' => undef,
        '!=' => undef,
    )
}

sub combine_with_query {
    my ($self, $query) = @_;

    my $and_condition = $self->operator eq '!=' ? 'AND NOT' : 'AND';
    $query->add_where([
        "type IN ($EDIT_RELATIONSHIP_CREATE, $EDIT_RELATIONSHIP_EDIT, $EDIT_RELATIONSHIP_DELETE, $EDIT_RELATIONSHIPS_REORDER)
         $and_condition (? && array_remove(ARRAY[
                                   (data#>>'{link_type,id}')::int,
                                   (data#>>'{link,link_type,id}')::int,
                                   (data#>>'{old,link_type,id}')::int,
                                   (data#>>'{new,link_type,id}')::int,
                                   (data#>>'{relationship,link,type,id}')::int
                               ], NULL))",
        [ $self->sql_arguments ],
    ]);
}

1;
