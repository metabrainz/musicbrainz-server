package MusicBrainz::Server::Controller::Role::Create;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';

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
        }
    );

    method 'create' => sub {
        my ($self, $c) = @_;
        $self->edit_action($c,
            form        => $params->form,
            type        => $params->edit_type,
            on_creation => sub {
                my $edit = shift;

                my $entity = $c->model( $self->config->{model} )->get_by_id($edit->entity_id);
                $c->response->redirect(
                    $c->uri_for_action($self->action_for('show'), [ $entity->gid ]))
            },
            $params->edit_arguments->($self, $c)
        );
    };
};

1;
