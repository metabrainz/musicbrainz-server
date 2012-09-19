package MusicBrainz::Server::EditSearch::Predicate::RelationshipType;
use Moose;

with 'MusicBrainz::Server::EditSearch::Predicate';

use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_CREATE
    $EDIT_RELATIONSHIP_EDIT
);

sub operator_cardinality_map {
    return (
        '=' => undef,
    )
}

sub combine_with_query {
    my ($self, $query) = @_;
    $query->add_where([
        join(
            ' OR',
            "(edit.type = ? AND  extract_path_value(edit.data, 'link_type/id') = any(?))",
            "(edit.type = ? AND (extract_path_value(edit.data, 'link/link_type/id') = any(?) OR
                                 extract_path_value(edit.data, 'old/link_type/id') = any(?) OR
                                 extract_path_value(edit.data, 'new/link_type/id') = any(?)))",
        ),
        [
            $EDIT_RELATIONSHIP_CREATE => $self->sql_arguments,
            $EDIT_RELATIONSHIP_EDIT => ($self->sql_arguments) x 3,
        ]
    ]);
}

1;
