package MusicBrainz::Server::EditSearch::Predicate::LinkedEntity;
use MooseX::Role::Parameterized;
use namespace::autoclean;
use feature 'switch';
use Scalar::Util qw( looks_like_number );

use MooseX::Types::Moose qw( Str );

parameter type => (
    required => 1
);

role {
    my $params = shift;
    my $type = $params->type;

    has name => (
        is => 'ro',
        isa => Str,
        required => 1
    );

    method operator_cardinality_map => sub {
        return (
            '=' => 1,
            '!=' => 1
        );
    };

    method combine_with_query => sub {
        my ($self, $query) = @_;
        my $join_idx = $query->inc_joins;
        my $table = join('_', 'edit', $params->type);
        my $column = $params->type;
        my $alias = $table . $join_idx;

        given($self->operator) {
            when('=') {
                $query->add_join("JOIN $table $alias ON $alias.edit = edit.id");
                $query->add_where([
                    "$alias.$column = ?", $self->sql_arguments
                ]);
            }

            when ('!=') {
                $query->add_where([
                    "NOT EXISTS (SELECT TRUE from $table edit_entity WHERE edit_entity.edit = edit.id AND edit_entity.$column = ?)",
                    $self->sql_arguments
                ]);
            }
        };
    };

    method valid => sub {
        my $self = shift;
        my @args = @{ $self->sql_arguments };
        return @args && looks_like_number($args[0]);
    };
};

1;
