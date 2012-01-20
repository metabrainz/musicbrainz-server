package MusicBrainz::Server::Controller::Role::Load;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';
use MusicBrainz::Server::Data::Utils 'model_to_type';

parameter 'model' => (
    isa => 'Str',
    required => 1
);

parameter 'entity_name' => (
    isa => 'Str',
);

parameter 'arg_count' => (
    isa => 'Int',
    default => 1
);

role
{
    my $params = shift;
    my %extra = @_;

    my $model = $params->model;
    my $entity_name = $params->entity_name || model_to_type($model);

    requires 'not_found', 'invalid_mbid';

    $extra{consumer}->name->config(
        action => {
            load => { Chained => 'base', PathPart => '', CaptureArgs => $params->arg_count }
        },
        model => $model,
        entity_name => $entity_name,
    );

    method load => sub
    {
        my ($self, $c, @args) = @_;

        my $entity = $self->_load($c, @args);

        if (!defined $entity) {
            $self->not_found($c, @args);
            $c->detach;
            return;
        }

        # First stash is more convenient for the actual controller
        $c->stash( $entity_name => $entity ) if $entity_name;

        # Second is useful to roles or other places that need introspection
        $c->stash( entity       => $entity );
    };

    method _load => sub
    {
        my ($self, $c, $id) = @_;

        if (MusicBrainz::Server::Validation::IsGUID($id)) {
            return $c->model($model)->get_by_gid($id);
        }
        else {
            $self->invalid_mbid($c, $id);
            $c->detach;
        }
    };
};

1;
