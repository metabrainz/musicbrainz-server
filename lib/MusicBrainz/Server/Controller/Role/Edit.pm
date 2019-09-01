package MusicBrainz::Server::Controller::Role::Edit;
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;

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

parameter 'dialog_template_react' => (
    isa => 'Str'
);

role {
    my $params = shift;
    my %extra = @_;

    $extra{consumer}->name->config(
        action => {
            edit => { Chained => 'load', Edit => undef }
        },
        edit_edit_type => $params->edit_type
    );

    method 'edit' => sub {
        my ($self, $c) = @_;

        my $entity_name = $self->{entity_name};
        my $edit_entity = $c->stash->{ $entity_name };

        my %props;
        $props{editEntity} = $edit_entity;

        if ($params->dialog_template_react) {
            $c->stash(
                component_path => $params->dialog_template_react,
                component_props => \%props,
                current_view => 'Node'
            )
        } else {
            $c->stash->{template} = 'entity/edit.tt';
        }

        return $self->edit_action($c,
            form        => $params->form,
            type        => $params->edit_type,
            item        => $edit_entity,
            edit_args   => { to_edit => $edit_entity },
            edit_rels   => 1,
            redirect    => sub {
                $c->response->redirect(
                    $c->uri_for_action($self->action_for('show'), [ $edit_entity->gid ]));
            },
            $params->edit_arguments->($self, $c, $edit_entity),
            pre_validation => sub {
                my $form = shift;
                $props{form} = $form;
                $props{optionsTypeID} = $form->options_type_id if $params->form eq 'Place';
                $props{optionsTypeId} = $form->options_type_id if $params->form eq 'Series';
                $props{optionsTypeId} = $form->options_type_id if $params->form eq 'ArtistEdit';
                $props{optionsTypeId} = $form->options_type_id if $params->form eq 'Event';
                $props{optionsTypeId} = $form->options_type_id if $params->form eq 'Label';
                $props{optionsGenderId} = $form->options_gender_id if $params->form eq 'ArtistEdit';
                $props{optionsPrimaryTypeId} = $form->options_primary_type_id if $params->form eq 'ReleaseGroup';
                $props{optionsSecondaryTypeIds} = $form->options_secondary_type_ids if $params->form eq 'ReleaseGroup';
                $props{optionsOrderingTypeId} = $form->options_ordering_type_id if $params->form eq 'Series';
                $props{usedByTracks} = $form->used_by_tracks if $params->form eq 'Recording';
            }
        );
    };
};

1;
