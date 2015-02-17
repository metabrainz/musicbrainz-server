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

        given ($self->operator) {
            when ('subscribed') {
                my $column = $params->type;

                my $entity_table    = join('_', 'edit', $params->type);
                my $sub_table    = join('_', 'editor_subscribe', $params->type);

                $query->add_where([
                    "EXISTS (SELECT 1 FROM $entity_table A JOIN $sub_table B USING ($column) WHERE A.edit = edit.id AND B.editor = ?)",
                    [ $self->user_id ]
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
