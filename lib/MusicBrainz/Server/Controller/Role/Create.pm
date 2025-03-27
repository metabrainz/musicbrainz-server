package MusicBrainz::Server::Controller::Role::Create;
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( model_to_type );
use aliased 'MusicBrainz::Server::WebService::JSONSerializer';

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

parameter 'path' => (
    isa => 'Str',
);

parameter 'dialog_template' => (
    isa => 'Str',
);

role {
    my $params = shift;
    my %extra = @_;

    my %attrs = (
        RequireAuth => undef,
        Edit        => undef,
    );
    if ($params->path) {
        $attrs{Path}  = $params->path;
    }
    else {
        $attrs{Local} = undef;
    }

    $extra{consumer}->name->config(
        action => {
            create => \%attrs,
        },
        create_edit_type => $params->edit_type,
    );

    method 'create' => sub {
        my ($self, $c, %args) = @_;

        if ($params->dialog_template) {
            $c->stash( dialog_template => $params->dialog_template );
        }

        my $model = $self->config->{model};
        my $entity;
        my %props;

        if ($model eq 'Event' || $model eq 'Genre') {
            my $type = model_to_type($model);
            my $form = $c->form( form => $params->form );
            %props = ( form => $form->TO_JSON );

            $c->stash(
                component_path => $type . '/Create' . $model,
                component_props => \%props,
                current_view => 'Node',
            );
        }

        $self->edit_action($c,
            form        => $params->form,
            type        => $params->edit_type,
            on_creation => sub {
                my $edit = shift;

                $entity = $c->model($model)->get_by_id($edit->entity_id);

                return unless $args{within_dialog};

                $c->stash(
                    current_view => 'Node',
                    component_path => 'forms/DialogResult',
                    component_props => {
                        result => $c->json->encode(
                            JSONSerializer->serialize_internal($c, $entity),
                        ),
                    },
                );

                # XXX Delete the "Thank you, your edit has been..." message
                # so it doesn't weirdly show up on the next page.
                delete $c->flash->{message};
            },
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
                }
            },
            redirect => sub {
                $c->response->redirect($c->uri_for_action(
                    $self->action_for('show'), [ $entity->gid ]));
            },
            no_redirect => $args{within_dialog},
            edit_rels   => 1,
            $params->edit_arguments->($self, $c),
        );

        if ($model eq 'Recording') {
            $c->stash->{form}->field('artist_credit')->stash_field;
        }
    };
};

1;
