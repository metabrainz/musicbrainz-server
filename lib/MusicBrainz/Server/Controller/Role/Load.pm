package MusicBrainz::Server::Controller::Role::Load;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';
use MusicBrainz::Server::Data::Utils 'model_to_type';
use MusicBrainz::Server::Validation qw( is_guid );
use MusicBrainz::Server::Constants qw( %ENTITIES );

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
            # This will detach for us
            $self->not_found($c, @args);
        }

        # First stash is more convenient for the actual controller
        $c->stash( $entity_name => $entity )
          if $entity_name && !$c->stash->{$entity_name};

        # Second is useful to roles or other places that need introspection
        $c->stash( entity       => $entity );

        $c->stash( entity_properties => $ENTITIES{ model_to_type($model) } );
    };

    method _load => sub
    {
        my ($self, $c, $id) = @_;

        if (is_guid($id)) {
            return $c->model($model)->get_by_gid($id);
        }
        else {
            # This will detach for us
            $self->invalid_mbid($c, $id);
        }
    };
};

1;
