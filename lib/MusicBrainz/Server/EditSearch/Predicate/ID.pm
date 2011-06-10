package MusicBrainz::Server::EditSearch::Predicate::ID;
use Moose;
use namespace::autoclean;
use feature 'switch';

with 'MusicBrainz::Server::EditSearch::Predicate';

sub operator_cardinality_map {
    return (
        BETWEEN => '2',
        map { $_ => 1 } qw( = < > >= <= )
    );
}

sub combine_with_query {
    my ($self, $query) = @_;

    my $sql;
    given($self->operator) {
        when('BETWEEN') {
            $sql = $self->field_name . ' BETWEEN ? AND ?';
        }
        default {
           $sql = join(' ', $self->field_name, $self->operator, '?')
       }
    }

    $query->add_where([ $sql, $self->sql_arguments ]);
}

1;
