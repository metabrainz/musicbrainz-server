package MusicBrainz::Server::EditSearch::Role::CountrySearch;
use MooseX::Role::Parameterized;
use namespace::autoclean;
use feature 'switch';

parameter 'type' => (
    isa => 'Str',
    required => 1
);

role {
    my $params = shift;
    my $type = $params->type;

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

        $query->add_where([
            join(' ', "$type_alias.country", $self->operator,
                 $self->operator eq '='  ? 'any(?)' :
                 $self->operator eq '!=' ? 'all(?)' : die 'Shouldnt get here'),
            $self->sql_arguments
        ]) if $self->arguments > 0;
    };

};

1;
