package MusicBrainz::Server::EditSearch::Predicate::Date;
use Moose;
use namespace::autoclean;
use feature 'switch';

with 'MusicBrainz::Server::EditSearch::Predicate::Role::NaturalDate';

sub combine_with_query {
    my ($self, $query) = @_;

    my $sql;
    my @arguments = @{ $self->sql_arguments };

    given ($self->operator) {
        when ('BETWEEN') {
            $sql = 'edit.' . $self->field_name . ' BETWEEN SYMMETRIC ? AND ?';
        }
        when ('=') {
            $sql = 'edit.' . $self->field_name . ' BETWEEN '.
            q[date_trunc('day', ? AT TIME ZONE 'UTC') AND ] .
            q[date_trunc('day', ? AT TIME ZONE 'UTC') + interval '1 day'];
            unshift @arguments, $arguments[0];
        }
        default {
           $sql = join(' ', 'edit.'.$self->field_name, $self->operator, '?')
       }
    }

    $query->add_where([ $sql, \@arguments ]);
}

1;
