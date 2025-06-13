package MusicBrainz::Server::Controller::Role::Edit;
use List::AllUtils qw( any );
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( model_to_type );

parameter 'form' => (
    isa => 'Str',
    required => 1,
);

parameter 'edit_type' => (
    isa => 'Int',
    required => 1,
);

parameter 'edit_arguments' => (
    isa => 'CodeRef',
    default => sub { sub { } },
);

role {
    my $params = shift;
    my %extra = @_;

    $extra{consumer}->name->config(
        action => {
            edit => { Chained => 'load', Edit => undef },
        },
        edit_edit_type => $params->edit_type,
    );

    method 'edit' => sub {
        my ($self, $c) = @_;

        my @react_models = qw( Event Genre);
        my $entity_name = $self->{entity_name};
        my $edit_entity = $c->stash->{ $entity_name };
        my $model = $self->{model};
        my $type = model_to_type($model);
        my %props;

        if (any { $_ eq $model } @react_models) {
            my $form = $c->form(
                form => $params->form,
                init_object => $edit_entity,
            );

            %props = (
                entity => $edit_entity->TO_JSON,
                form => $form->TO_JSON,
            );

            $c->stash(
                component_path => $type . '/Edit' . $model,
                component_props => \%props,
                current_view => 'Node',
            );
        } else {
            $c->stash->{template} = 'entity/edit.tt';
        }

        $self->edit_action($c,
            form        => $params->form,
            type        => $params->edit_type,
            item        => $edit_entity,
            edit_args   => { to_edit => $edit_entity },
            edit_rels   => 1,
            pre_validation => sub {
                my $form = shift;
                if ($model eq 'Event') {
                    my %event_descriptions = map {
                        $_->id => $_->l_description
                    } $c->model('EventType')->get_all();

                    $props{eventTypes} = $form->options_type_id;
                    $props{eventDescriptions} = \%event_descriptions;
                }
                if ($self->does('MusicBrainz::Server::Controller::Role::IdentifierSet')) {
                    $self->munge_compound_text_fields($c, $form);
                    $self->stash_current_identifier_values($c, $edit_entity->id);
                }
            },
            redirect    => sub {
                $c->response->redirect(
                    $c->uri_for_action($self->action_for('show'), [ $edit_entity->gid ]));
            },
            $params->edit_arguments->($self, $c, $edit_entity),
        );

        if ($ENTITIES{$type}{artist_credits}) {
            $c->stash->{form}->field('artist_credit')->stash_field;
        }
    };
};

1;
