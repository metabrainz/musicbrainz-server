package MusicBrainz::Server::Controller::Role::Create;
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;
use aliased 'MusicBrainz::Server::WebService::JSONSerializer';

parameter 'form' => (
    isa => 'Str',
    required => 1
);

parameter 'edit_type' => (
    isa => 'Int',
    required => 1
);

parameter 'edit_arguments' => (
    isa => 'CodeRef',
    default => sub { sub { } }
);

parameter 'path' => (
    isa => 'Str'
);

parameter 'dialog_template' => (
    isa => 'Str'
);

parameter 'dialog_template_react' => (
    isa => 'Str'
);

role {
    my $params = shift;
    my %extra = @_;

    my %attrs = (
        RequireAuth => undef,
        Edit        => undef
    );
    if ($params->path) {
        $attrs{Path}  = $params->path;
    }
    else {
        $attrs{Local} = undef;
    }

    $extra{consumer}->name->config(
        action => {
            create => \%attrs
        },
        create_edit_type => $params->edit_type
    );

    method 'create' => sub {
        my ($self, $c, %args) = @_;
        my $entity;

        if ($params->dialog_template) {
            $c->stash( dialog_template => $params->dialog_template );
        }

        my %props;
        $props{entityType} = $params->form;

        if ($params->dialog_template_react) {
            $c->stash(
                component_path => $params->dialog_template_react,
                component_props => \%props,
                current_view => 'Node'
            )
        }

        my $model = $self->config->{model};

        $self->edit_action($c,
            form        => $params->form,
            type        => $params->edit_type,
            on_creation => sub {
                my $edit = shift;

                $entity = $c->model($model)->get_by_id($edit->entity_id);

                return unless $args{within_dialog};

                $c->stash( dialog_result => $c->json->encode(JSONSerializer->serialize_internal($c, $entity)) );

                # XXX Delete the "Thank you, your edit has been..." message
                # so it doesn't weirdly show up on the next page.
                delete $c->flash->{message};
            },
            redirect => sub {
                $c->response->redirect($c->uri_for_action(
                    $self->action_for('show'), [ $entity->gid ]));
            },
            no_redirect => $args{within_dialog},
            edit_rels   => 1,
            $params->edit_arguments->($self, $c),
            pre_validation => sub {
                my $form = shift;
                $props{form} = $form;
                $props{optionsTypeId} = $form->options_type_id if $params->form eq 'Place';
                $props{optionsTypeId} = $form->options_type_id if $params->form eq 'Series';
                $props{optionsTypeId} = $form->options_type_id if $params->form eq 'Work';
                $props{optionsTypeId} = $form->options_type_id if $params->form eq 'Artist';
                $props{optionsTypeId} = $form->options_type_id if $params->form eq 'Event';
                $props{optionsTypeId} = $form->options_type_id if $params->form eq 'Label';
                $props{optionsGenderId} = $form->options_gender_id if $params->form eq 'Artist';
                $props{optionsPrimaryTypeId} = $form->options_primary_type_id if $params->form eq 'ReleaseGroup';
                $props{optionsSecondaryTypeIds} = $form->options_secondary_type_ids if $params->form eq 'ReleaseGroup';
                $props{optionsOrderingTypeId} = $form->options_ordering_type_id if $params->form eq 'Series';
                $props{usedByTracks} = $form->used_by_tracks if $params->form eq 'Recording::Standalone';
            }
        );
    };
};

1;
