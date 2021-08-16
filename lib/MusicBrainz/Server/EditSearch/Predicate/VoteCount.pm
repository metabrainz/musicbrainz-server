package MusicBrainz::Server::EditSearch::Predicate::VoteCount;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( :vote );
use MusicBrainz::Server::Types qw( VoteOption );

extends 'MusicBrainz::Server::EditSearch::Predicate::ID';

has vote => (
    is => 'ro',
    isa => 'Int',
    required => 1
);

sub combine_with_query {
    my ($self, $query) = @_;

    my $sql = 'COALESCE((
        SELECT SUM(CASE WHEN vote = ? THEN 1 ELSE 0 END)
        FROM vote
        WHERE superseded = FALSE AND edit = edit.id
        GROUP BY edit
    ), 0)';

    if ($self->operator eq 'BETWEEN') {
        $sql .= ' BETWEEN SYMMETRIC ? AND ?';
    } else {
        $sql .= ' ' . $self->operator . ' ?';
    }

    $query->add_where([ $sql, [ $self->vote, @{ $self->sql_arguments } ] ]);
}

around valid => sub {
    my ($orig, $self) = @_;
    return VoteOption->check($self->vote) && $self->$orig;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
