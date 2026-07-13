package MusicBrainz::Server::EditSearch::Predicate::EditNoteDate;
use Moose;
use namespace::autoclean;
use feature 'switch';

with 'MusicBrainz::Server::EditSearch::Predicate::Role::NaturalDate';

sub combine_with_query {
    my ($self, $query) = @_;

    my $condition = '';
    my @arguments = @{ $self->sql_arguments };

    given ($self->operator) {
        when ('BETWEEN') {
            $condition = 'BETWEEN SYMMETRIC ? AND ?';
        }
        when ('=') {
            $condition = <<~'EOSQL';
                BETWEEN
                    date_trunc('day', ? AT TIME ZONE 'UTC')
                AND 
                    date_trunc('day', ? AT TIME ZONE 'UTC') + interval '1 day'
                EOSQL
            unshift @arguments, $arguments[0];
        }
        default {
            $condition = $self->operator . ' ?';
        }
    }

    my $sql = <<~"EOSQL";
            EXISTS (
                SELECT TRUE FROM edit_note
                WHERE post_time
                    $condition
                AND edit_note.edit = edit.id
            )
            EOSQL

    $query->add_where([ $sql, \@arguments ]);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
