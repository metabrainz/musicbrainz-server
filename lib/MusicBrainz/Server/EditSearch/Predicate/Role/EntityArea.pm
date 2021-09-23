package MusicBrainz::Server::EditSearch::Predicate::Role::EntityArea;
use MooseX::Role::Parameterized;
use namespace::autoclean;

parameter 'type' => (
    isa => 'Str',
    required => 1
);

parameter 'column' => (
    isa => 'Str',
    required => 0
);

parameter 'extra_join' => (
    isa => 'HashRef[Str]',
    required => 0
);

role {
    my $params = shift;
    my $type = $params->type;
    my $column = $params->column // 'area';
    my $extra_join_params = $params->extra_join;

    requires 'arguments';

    method 'combine_with_query' => sub
    {
        my ($self, $query) = @_;
        return unless $self->arguments;

        my $clause = "EXISTS (SELECT 1 FROM edit_$type A JOIN $type B ON A.$type = B.id ";
        my $final_table_alias = 'B';

        if ($extra_join_params && $extra_join_params->{table}) {
            my $extra_join = $extra_join_params->{table};
            my $type_col = $extra_join_params->{type_col} // 'id';
            my $extra_col = $extra_join_params->{extra_col} // $type;
            $final_table_alias = 'C';

            $clause .= "JOIN $extra_join C ON B.$type_col = C.$extra_col ";
        }
        $clause .= 'WHERE A.edit = edit.id AND ';
        $query->add_where([
            $clause .
            join(' ', "$final_table_alias.$column", $self->operator,
                 $self->operator eq '='  ? 'any(?)' :
                 $self->operator eq '!=' ? 'all(?)' : die q(Shouldn't get here)) . ')',
            $self->sql_arguments
        ]) if $self->arguments > 0;
    };

};

1;
