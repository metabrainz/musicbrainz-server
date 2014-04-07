package MusicBrainz::Server::EditSearch::Predicate::ID;
use Moose;
use namespace::autoclean;
use feature 'switch';

use Scalar::Util qw( looks_like_number );

no if $] >= 5.018, warnings => "experimental::smartmatch";

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
    given($self->operator) {
        when('BETWEEN') {
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
        looks_like_number($arg) or return;
    }

    return 1;
}

1;
