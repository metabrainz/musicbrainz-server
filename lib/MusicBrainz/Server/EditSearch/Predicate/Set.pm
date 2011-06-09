package MusicBrainz::Server::EditSearch::Predicate::Set;
use Moose;
use namespace::autoclean;
use feature 'switch';

use MusicBrainz::Server::Data::Utils qw( placeholders );

with 'MusicBrainz::Server::EditSearch::Predicate';

sub operator_cardinality {
    return (
        IN => undef
    )
}

sub combine_with_query {
    my ($self, $query) = @_;
    $query->add_where({
        join(' ', $self->field_name, 'IN (', placeholders($self->arguments) ,')'),
        $self->sql_arguments
    }) if $self->arguments > 0;
}

1;
