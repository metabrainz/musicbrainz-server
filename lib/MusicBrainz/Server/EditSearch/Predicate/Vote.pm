package MusicBrainz::Server::EditSearch::Predicate::Vote;
use Moose;
use namespace::autoclean;
use feature 'switch';
use Scalar::Util qw( looks_like_number );

use MusicBrainz::Server::Constants qw( :vote );

no if $] >= 5.018, warnings => "experimental::smartmatch";

with 'MusicBrainz::Server::EditSearch::Predicate';

has name => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

has user => (
    is => 'ro',
    isa => 'MusicBrainz::Server::Authentication::User',
    required => 1
);

has voter_id => (
    is => 'ro',
    isa => 'Int',
    required => 1
);

sub operator_cardinality_map {
    return (
        '=' => undef,
        '!=' => undef,
        'me' => undef,
        'not_me' => undef,
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
    my $voter_id = $self->operator eq '=' || $self->operator eq '!=' ? $self->voter_id : $self->user->id;

    given ($self->operator) {
        when (/^(=|me)$/) {
            if (@votes && $no_vote_option) {
                $query->add_where([
                    join(' OR ',
                         sprintf($sql, "vote.vote = any(?)"),
                         sprintf("NOT $sql", "TRUE")
                    ),
                    [
                        $voter_id,
                        \@votes,
                        $voter_id
                    ]
                ]);
            }
            elsif (@votes && !$no_vote_option) {
                $query->add_where([
                    sprintf($sql, "vote.vote = any(?)"),
                    [
                        $voter_id,
                        \@votes,
                    ]
                ]);
            }
            elsif (!@votes && $no_vote_option) {
                $query->add_where([
                    sprintf("NOT $sql", "TRUE"),
                    [
                        $voter_id,
                    ]
                ]);
            }
        }

        when (/^(!=|not_me)$/) {
            if (!@votes && $no_vote_option) {
                my @query_votes = ($VOTE_ABSTAIN, $VOTE_NO, $VOTE_YES);
                $query->add_where([
                    sprintf("$sql", "vote.vote = any(?)"),
                    [
                        $voter_id,
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
                        $voter_id,
                        \@votes,
                        $voter_id,
                    ]
                ]);
            }
            else {
                $query->add_where([
                    sprintf($sql, "vote.vote != all(?)"),
                    [
                        $voter_id,
                        \@votes,
                    ]
                ]);
            }
        }
    };
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
