package MusicBrainz::Server::EditSearch::Predicate::ID;
use Moose;
use MusicBrainz::Server::Validation qw( is_database_row_id is_integer );
use namespace::autoclean;
use feature 'switch';

no if $] >= 5.018, warnings => 'experimental::smartmatch';

with 'MusicBrainz::Server::EditSearch::Predicate';

sub operator_cardinality_map {
    return (
        BETWEEN => '2',
        map { $_ => 1 } qw( = < > >= <= != )
    );
}

sub combine_with_query {
    my ($self, $query) = @_;

    my $sql;
    given ($self->operator) {
        when ('BETWEEN') {
            $sql = 'edit.' . $self->field_name . ' BETWEEN SYMMETRIC ? AND ?';
        }
        default {
           $sql = join(' ', 'edit.'.$self->field_name, $self->operator, '?')
       }
    }

    $query->add_where([ $sql, $self->sql_arguments ]);
}

sub valid {
    my $self = shift;
    # Uncounted cardinality means anything is valid (or more than classes should implement this themselves)
    my $cardinality = $self->operator_cardinality($self->operator) or return 1;
    for my $arg_index (1..$cardinality) {
        my $arg = $self->argument($arg_index - 1);
        return unless is_database_row_id($arg) || (is_integer($arg) && $arg == 0);
    }

    return 1;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
