package MusicBrainz::Server::EditSearch::Predicate::SubscribedEntity;
use 5.10.0;
use MooseX::Role::Parameterized;
use namespace::autoclean;

no if $] >= 5.018, warnings => "experimental::smartmatch";

parameter type => (
    required => 1
);

role {
    my $params = shift;
    my $type = $params->type;

    has user_id => (
        is => 'ro',
        isa => 'Int'
    );

    around operator_cardinality_map => sub {
        my ($orig, $self) = @_;
        return (
            $self->$orig,
            'subscribed' => undef
        );
    };

    around combine_with_query => sub {
        my ($orig, $self) = splice(@_, 0, 2);
        my ($query) = @_;

        given($self->operator) {
            when('subscribed') {
                my $column = $params->type;

                my $entity_join_idx = $query->inc_joins;
                my $entity_table    = join('_', 'edit', $params->type);
                my $entity_alias    = $entity_table . $entity_join_idx;

                my $sub_join_idx = $query->inc_joins;
                my $sub_table    = join('_', 'editor_subscribe', $params->type);
                my $sub_alias    = $sub_table . $sub_join_idx;

                $query->add_join("JOIN $entity_table $entity_alias ON $entity_alias.edit = edit.id");
                $query->add_join("JOIN $sub_table $sub_alias ON $sub_alias.$column = $entity_alias.$column");

                $query->add_where([
                    "$sub_alias.editor = ?", [ $self->user_id ]
                ]);
            }

            default {
                $self->$orig(@_);
            }
        }
    };

    around valid => sub {
        my ($orig, $self) = @_;
        return $self->operator eq 'subscribed' || $self->$orig;
    };
}
