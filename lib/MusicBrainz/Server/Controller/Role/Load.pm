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

role
{
    my $params = shift;
    my %extra = @_;
    
    my $model = $params->model;
    my $entity_name = $params->entity_name || model_to_type($model);

    requires 'not_found', 'invalid_mbid';

    $extra{consumer}->name->config(
        action => {
            load => { Chained => 'base', PathPart => '', CaptureArgs => 1 }
        },
        model => $model,
        entity_name => $entity_name,
    );

    method load => sub
    {
        my ($self, $c, $gid) = @_;

        my $entity = $self->_load($c, $gid);

        if (!defined $entity) {
            $self->not_found($c, $gid);
            $c->detach;
            return;
        }

        $c->stash(
            # First stash is more convenient for the actual controller
            # Second is useful to roles or other places that need introspection
            $entity_name => $entity,
            entity       => $entity
        );
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
