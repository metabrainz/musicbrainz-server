package MusicBrainz::Server::EditSearch::Predicate;
use Moose::Role;

use MooseX::Types::Moose qw( Any ArrayRef Str );
use MusicBrainz::Server::EditSearch::Exceptions;
use MusicBrainz::Server::Translation;

requires qw(
    operator_cardinality
    combine_with_query
);

sub supports_operator {
    my ($class, $operator) = @_;
    my %operator_cardinality = $class->operator_cardinality;
    return exists $operator_cardinality{$operator};
}

has operator => (
    isa => Str,
    is => 'ro',
    required => 1
);

has arguments => (
    isa => ArrayRef[Any],
    is => 'bare',
    required => 1,
    traits => [ 'Array' ],
    handles => {
        arguments => 'elements',
    }
);

has field_name => (
    isa => Str,
    is => 'ro',
    required => 1
);

sub transform_user_input {
    my ($self, $user_input) = @_;
    return $user_input;
}

sub cross_validate { }

sub new_from_input {
    my ($class, $field_name, $input) = @_;

    MusicBrainz::Server::EditSearch::Exceptions::UnsupportOperator->throw(
        l('This operator is not supported')
    ) unless $class->supports_operator($input->{operator});

    return $class->new(
        field_name => $field_name,
        operator => $input->{operator},
        arguments => [
            map { $class->transform_user_input($_) } @{ $input->{args} }
        ]
    );
}

sub sql_arguments {
    my $self = shift;
    return [ $self->arguments ];
}

1;
