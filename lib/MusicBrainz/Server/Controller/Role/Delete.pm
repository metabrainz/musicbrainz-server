package MusicBrainz::Server::Controller::Role::Delete;
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;
use MusicBrainz::Server::ControllerUtils::Delete qw( cancel_or_action );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json model_to_type );

parameter 'edit_type' => (
    isa => 'Int',
    required => 1
);

parameter 'create_edit_type' => (
    isa => 'Int',
    required => 0
);

role {
    my $params = shift;
    my %extra = @_;

    $extra{consumer}->name->config(
        action => {
            delete => { Chained => 'load', Edit => undef }
        },
        delete_edit_type => $params->edit_type,
        ($params->create_edit_type ? (create_edit_type => $params->create_edit_type) : ())
    );

    after 'load' => sub {
        my ($self, $c) = @_;
        my $entity_name = $self->{entity_name};
        my $entity = $c->stash->{ $entity_name };
        $c->stash(
            can_delete => $c->model($self->{model})->can_delete($entity->id)
        );
    };

    method 'delete' => sub {
        my ($self, $c) = @_;
        my $entity_name = $self->{entity_name};
        my $edit_entity = $c->stash->{ $entity_name };
        my $model = $self->{model};
        my $can_delete = $c->model($model)->can_delete($edit_entity->id);

        if ($model eq 'Area' || $model eq 'Genre' || $model eq 'Release') {
            my $type = model_to_type($model);

            my %props = (
                entity => $edit_entity->TO_JSON,
            );

            if ($model eq 'Area') {
                $props{canDelete} = boolean_to_json($can_delete);

                $props{isReleaseCountry} = boolean_to_json(
                    $c->model('Area')->is_release_country_area(
                        $edit_entity->id,
                    ),
                );
            }

            $c->stash(
                component_path => $type . '/Delete' . $model,
                component_props => \%props,
                current_view => 'Node',
            );
        }

        if ($can_delete) {
            $c->stash( can_delete => 1 );
            # find a corresponding add edit and cancel instead, if applicable (MBS-1397)
            my $create_edit_type = $self->{create_edit_type};
            my $edit = $c->model('Edit')->find_creation_edit($create_edit_type, $edit_entity->id);
            cancel_or_action($c, $edit, undef, sub {
                $self->edit_action($c,
                    form        => 'Confirm',
                    form_args   => { requires_edit_note => 1 },
                    type        => $params->edit_type,
                    item        => $edit_entity,
                    edit_args   => { to_delete => $edit_entity },
                    on_creation => sub {
                        my $edit = shift;
                        my $url = $edit->is_open
                            ? $c->uri_for_action($self->action_for('show'), [ $edit_entity->gid ])
                            : $c->uri_for_action('/search/search');
                        $c->response->redirect($url);
                    },
                );
            });
        }
    };
};

1;
