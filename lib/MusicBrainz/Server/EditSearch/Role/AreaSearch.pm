package MusicBrainz::Server::EditSearch::Role::AreaSearch;
use MooseX::Role::Parameterized;
use namespace::autoclean;
use feature 'switch';

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

        my $join_e_idx = $query->inc_joins;
        my $edit_alias = "edit_${type}_$join_e_idx";
        $query->add_join("JOIN edit_$type $edit_alias ON $edit_alias.edit = edit.id");

        my $join_r_idx = $query->inc_joins;
        my $type_alias = "${type}_$join_r_idx";
        $query->add_join("JOIN $type $type_alias ON $type_alias.id = $edit_alias.$type");

        my $final_table_alias = $type_alias;
        if ($extra_join_params && $extra_join_params->{table}) {
            my $extra_join = $extra_join_params->{table};
            my $type_col = $extra_join_params->{type_col} // 'id';
            my $extra_col = $extra_join_params->{extra_col} // $type;

            my $join_l_idx = $query->inc_joins;
            my $extra_alias = "${extra_join}_$join_l_idx";
            $query->add_join("JOIN $extra_join $extra_alias ON $type_alias.$type_col = $extra_alias.$extra_col");

            $final_table_alias = $extra_alias;
        }

        $query->add_where([
            join(' ', "$final_table_alias.$column", $self->operator,
                 $self->operator eq '='  ? 'any(?)' :
                 $self->operator eq '!=' ? 'all(?)' : die 'Shouldn\'t get here'),
            $self->sql_arguments
        ]) if $self->arguments > 0;
    };

};

1;
