package MusicBrainz::Server::EditSearch::Predicate::Role::LinkedEntity;
use MooseX::Role::Parameterized;
use namespace::autoclean;
use Scalar::Util qw( looks_like_number );

parameter type => (
    required => 1
);

role {
    my $params = shift;

    has name => (
        is => 'ro',
        isa => 'Str'
    );

    method operator_cardinality_map => sub {
        return (
            '=' => 1,
            '!=' => 1
        );
    };

    method combine_with_query => sub {
        my ($self, $query) = @_;
        my $table = join('_', 'edit', $params->type);
        my $column = $params->type;

        $query->add_where([
            ($self->operator eq '!=' ? 'NOT ' : '') .
            "EXISTS (SELECT 1 FROM $table WHERE edit = edit.id AND $column = ?)", $self->sql_arguments
        ]);
    };

    method valid => sub {
        my $self = shift;
        my @args = @{ $self->sql_arguments };
        return @args && looks_like_number($args[0]);
    };
};

1;
