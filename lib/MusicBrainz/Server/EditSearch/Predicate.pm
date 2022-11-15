package MusicBrainz::Server::EditSearch::Predicate;
use Moose::Role;

use MooseX::Types::Moose qw( Any ArrayRef Str );
use MusicBrainz::Server::EditSearch::Exceptions;
use MusicBrainz::Server::Translation qw( l );

requires qw(
    operator_cardinality_map
    combine_with_query
);

sub operator_cardinality {
    my ($class, $operator) = @_;
    my %operator_cardinality = $class->operator_cardinality_map;
    return $operator_cardinality{$operator};
}

sub supports_operator {
    my ($class, $operator) = @_;
    my %operator_cardinality = $class->operator_cardinality_map;
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
        argument => 'get',
        _find_argument => 'first'
    }
);

sub find_argument {
    my ($self, $argument) = @_;
    return $self->_find_argument(sub { $_ eq $argument });
}

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
    my ($class, $field_name, $input, $user) = @_;

    my $op = $input->{operator};
    MusicBrainz::Server::EditSearch::Exceptions::UnsupportOperator->throw(
        l('This operator is not supported')
    ) unless $class->supports_operator($op);

    my $cardinality = $class->operator_cardinality($op);
    my @args = grep { defined } (ref($input->{args}) ? @{ $input->{args} } : $input->{args});
    @args = splice(@args, 0, $cardinality)
        if defined $cardinality;

    return $class->new(
        %{ $input },
        field_name => $field_name,
        operator => $op,
        arguments => [ @args ],
        user => $user,
    );
}

sub sql_arguments {
    my $self = shift;
    return [ map { $self->transform_user_input($_) } $self->arguments ];
}

sub valid {
    my $self = shift;
    # Uncounted cardinality means anything is valid (or more than classes should implement this themselves)
    my $cardinality = $self->operator_cardinality($self->operator) or return 1;
    for my $arg_index (1..$cardinality) {
        my $arg = $self->argument($arg_index - 1);
        defined $arg or return;
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
