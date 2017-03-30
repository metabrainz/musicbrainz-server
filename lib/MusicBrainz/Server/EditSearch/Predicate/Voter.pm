package MusicBrainz::Server::EditSearch::Predicate::Voter;
use Moose;
use namespace::autoclean;
use Scalar::Util qw( looks_like_number );

use MusicBrainz::Server::Constants qw( :vote );
use MusicBrainz::Server::Validation qw( is_database_row_id );

with 'MusicBrainz::Server::EditSearch::Predicate';

has name => (
    is => 'ro',
    isa => 'Str'
);

has user => (
    is => 'ro',
    isa => 'MusicBrainz::Server::Authentication::User',
    required => 1
);

has voter_id => (
    is => 'ro'
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
    return unless $self->arguments > 0;
    return $self->operator ne '=' && $self->operator ne '!=' || is_database_row_id($self->voter_id);
}

sub combine_with_query {
    my ($self, $query) = @_;

    my $sql_op = $self->operator =~ /!=|not_me/ ? '!=' : '=';
    my $sql = "EXISTS (
        SELECT TRUE FROM vote
        WHERE vote.editor $sql_op ?
        AND vote.superseded = FALSE
        AND %s
        AND vote.edit = edit.id
    )";

    my @votes = grep { looks_like_number($_) } @{ $self->sql_arguments };
    my $no_vote_option = grep { $_ eq 'no' } @{ $self->sql_arguments };
    my $voter_id = $self->operator =~ /=|!=/ ? $self->voter_id : $self->user->id;

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
    } elsif (@votes && !$no_vote_option) {
        $query->add_where([
            sprintf($sql, "vote.vote = any(?)"),
            [
                $voter_id,
                \@votes,
            ]
        ]);
    } elsif (!@votes && $no_vote_option) {
        $query->add_where([
            sprintf("NOT $sql", "TRUE"),
            [
                $voter_id,
            ]
        ]);
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
