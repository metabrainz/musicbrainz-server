package MusicBrainz::Server::Controller::Role::Delete;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';

parameter 'edit_type' => (
    isa => 'Int',
    required => 1
);

role {
    my $params = shift;
    my %extra = @_;

    $extra{consumer}->name->config(
        action => {
            delete => { Chained => 'load', Edit => undef }
        }
    );

    after 'show' => sub {
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
        if ($c->model($self->{model})->can_delete($edit_entity->id)) {
            $c->stash( can_delete => 1 );
            $self->edit_action($c,
                form        => 'Confirm',
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
        }
    };
};

1;
