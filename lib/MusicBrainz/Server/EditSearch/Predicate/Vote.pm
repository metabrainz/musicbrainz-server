package MusicBrainz::Server::EditSearch::Predicate::Vote;
use Moose;
use namespace::autoclean;
use feature 'switch';

with 'MusicBrainz::Server::EditSearch::Predicate';

has voter_id => (
    is => 'ro',
    required => 1
);

sub operator_cardinality_map {
    return (
        '=' => undef,
        '!=' => undef
    );
};

sub combine_with_query {
    my ($self, $query) = @_;

    my $sql = "EXISTS (
        SELECT TRUE FROM vote
        WHERE vote.editor = ?
        AND vote.superseded = FALSE
        AND %s
        AND vote.edit = edit.id
    )";

    my $args = [
        $self->voter_id,
        $self->sql_arguments
    ];

    given($self->operator) {
        when('=') {
            $query->add_where([
                sprintf($sql, "vote.vote = any(?)"), $args
            ]);
        }

        when ('!=') {
            $query->add_where([
                sprintf($sql, "vote.vote != all(?)"), $args
            ]);
        }
    };
}

1;
