package MusicBrainz::Server::EditSearch::Predicate::EditVoteCount;

use Moose;
use MusicBrainz::Server::Constants qw( $VOTE_YES $VOTE_NO );

extends 'MusicBrainz::Server::EditSearch::Predicate::ID';

sub combine_with_query {
    my ($self, $query) = @_;

    my $sql = "COALESCE((
        SELECT SUM(CASE WHEN vote = ? THEN 1 ELSE 0 END)
        FROM vote
        WHERE superseded = FALSE AND edit = edit.id
        GROUP BY edit
    ), 0)";

    if ($self->operator eq 'BETWEEN') {
        $sql .= ' BETWEEN SYMMETRIC ? AND ?';
    } else {
        $sql .= ' ' . $self->operator . ' ?';
    }

    my $vote;
    if ($self->field_name eq 'yes_votes') {
        $vote = $VOTE_YES;
    } elsif ($self->field_name eq 'no_votes') {
        $vote = $VOTE_NO;
    }

    $query->add_where([$sql, [$vote, @{ $self->sql_arguments }]]);
}

1;
