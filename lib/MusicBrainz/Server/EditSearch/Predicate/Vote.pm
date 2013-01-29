package MusicBrainz::Server::EditSearch::Predicate::Vote;
use Moose;
use namespace::autoclean;
use feature 'switch';
use Scalar::Util qw( looks_like_number );
use MusicBrainz::Server::Constants qw( :vote );

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

sub valid {
    my ($self) = @_;
    return $self->arguments > 0;
}

sub combine_with_query {
    my ($self, $query) = @_;

    my $sql = "EXISTS (
        SELECT TRUE FROM vote
        WHERE vote.editor = ?
        AND vote.superseded = FALSE
        AND %s
        AND vote.edit = edit.id
    )";

    my @votes = grep { looks_like_number($_) } @{ $self->sql_arguments };
    my $no_vote_option = grep { $_ eq 'no' } @{ $self->sql_arguments };

    given($self->operator) {
        when('=') {
            if (@votes && $no_vote_option) {
                $query->add_where([
                    join(' OR ',
                         sprintf($sql, "vote.vote = any(?)"),
                         sprintf("NOT $sql", "TRUE")
                    ),
                    [
                        $self->voter_id,
                        \@votes,
                        $self->voter_id
                    ]
                ]);
            }
            elsif (@votes && !$no_vote_option) {
                $query->add_where([
                    sprintf($sql, "vote.vote = any(?)"),
                    [
                        $self->voter_id,
                        \@votes,
                    ]
                ]);
            }
            elsif (!@votes && $no_vote_option) {
                $query->add_where([
                    sprintf("NOT $sql", "TRUE"),
                    [
                        $self->voter_id,
                    ]
                ]);
            }
        }

        when ('!=') {
            if (!@votes && $no_vote_option) {
                my @query_votes = ($VOTE_ABSTAIN, $VOTE_NO, $VOTE_YES);
                $query->add_where([
                    sprintf("$sql", "vote.vote = any(?)"),
                    [
                        $self->voter_id,
                        \@query_votes, 
                    ]
                ]);
            }
            elsif (@votes && !$no_vote_option) {
                $query->add_where([
                    join(' OR ',
                         sprintf($sql, "vote.vote != all(?)"),
                         sprintf("NOT $sql", "TRUE")
                    ),
                    [
                        $self->voter_id,
                        \@votes,
                        $self->voter_id,
                    ]
                ]);
            }
            else {
                $query->add_where([
                    sprintf($sql, "vote.vote != all(?)"),
                    [
                        $self->voter_id,
                        \@votes,
                    ]
                ]);
            }
        }
    };
}

1;
