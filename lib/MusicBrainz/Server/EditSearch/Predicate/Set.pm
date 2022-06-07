package MusicBrainz::Server::EditSearch::Predicate::Set;
use Moose;
use namespace::autoclean;
use List::AllUtils qw( any );
use MusicBrainz::Server::Validation qw( is_integer );

with 'MusicBrainz::Server::EditSearch::Predicate';

sub operator_cardinality_map {
    return (
        '=' => undef,
        '!=' => undef
    )
}

sub valid {
    my ($self) = @_;

    return 0 unless $self->arguments > 0;

    # If you want to allow non-integer sets, please create ::IntegerSet, etc
    return 0 if any { !is_integer($_) } $self->arguments;

    return 1;
}

sub combine_with_query {
    my ($self, $query) = @_;
    return unless $self->arguments;
    $query->add_where([
        join(' ', 'edit.'.$self->field_name, $self->operator,
             $self->operator eq '='  ? 'any(?)' :
             $self->operator eq '!=' ? 'all(?)' : die 'Shouldnt get here'),
        $self->sql_arguments
    ]) if $self->arguments > 0;
}

sub sql_arguments {
    my $self = shift;
    return [
        [ map { split /,/, $_ } $self->arguments ]
    ];
}

1;
