package MusicBrainz::Server::Controller::Role::Load;
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;
use MusicBrainz::Server::Data::Utils 'model_to_type';
use MusicBrainz::Server::Validation qw( is_guid is_positive_integer );
use MusicBrainz::Server::Constants qw( %ENTITIES );

no if $] >= 5.018, warnings => "experimental::smartmatch";

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

parameter 'relationships' => (
    isa => 'HashRef',
    required => 0,
    default => sub { {} }
);

parameter 'allow_multiple' => (
    isa => 'CodeRef',
    required => 0,
    default => sub { sub { 0 } },
);

parameter 'allow_integer_ids' => (
    isa => 'Bool',
    required => 0,
    default => sub { 1 },
);

role
{
    my $params = shift;
    my %extra = @_;

    my $model = $params->model;
    my $entity_type = model_to_type($model);
    # defaulting to something non-undef silences a warning
    my $entity_properties = $ENTITIES{ $entity_type // 0 };
    my $entity_name = $params->entity_name || $entity_type;
    my $allows_integer_ids = $params->allow_integer_ids;

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

        my @entities = $self->_load($c, @args);

        $c->detach('not_found') unless @entities;

        if (exists $entity_properties->{mbid} && $entity_properties->{mbid}{relatable}) {
            my $action = $c->action->name;
            my $relationships = $params->relationships;

            if ($action ~~ $relationships->{all}) {
                $c->model('Relationship')->load(@entities);
            } elsif ($action ~~ $relationships->{cardinal}) {
                $c->model('Relationship')->load_cardinal(@entities);
            } else {
                my $types = $relationships->{subset}->{$action} // $relationships->{default};

                if ($types) {
                    $c->model('Relationship')->load_subset($types, @entities);
                }
            }
        }

        my $entity = @entities == 1 ? $entities[0] : \@entities;

        # First stash is more convenient for the actual controller
        $c->stash( $entity_name => $entity )
            if $entity_name && !$c->stash->{$entity_name};

        # Second is useful to roles or other places that need introspection
        $c->stash( entity => $entity, entity_type => $entity_type );

        $c->stash( entity_properties => $entity_properties );
    };

    method _load => sub
    {
        my ($self, $c, $id) = @_;

        my (@gids, @ids, @unknown_ids);

        @unknown_ids = $id;
        if ($params->allow_multiple->($c)) {
            @unknown_ids = split /\+/, $id;
        }

        $self->too_many_ids($c)
            if @unknown_ids > 100;

        my @entities;
        my $entity_model = $c->model($model);
        my $can_get_by_gid = $entity_model->can('get_by_gid');

        for my $uid (@unknown_ids) {
            if ($can_get_by_gid && is_guid($uid)) {
                push @gids, $uid;
            } elsif ($allows_integer_ids && is_positive_integer($uid)) {
                push @ids, $uid;
            } else {
                $self->invalid_mbid($c, $uid);
            }
        }

        if (@gids && @ids) {
            $self->invalid_mbid($c, $id);
        }

        if (@gids) {
            push @entities, values %{ $entity_model->get_by_gids(@gids) };
        } elsif (@ids) {
            push @entities, values %{ $entity_model->get_by_ids(@ids) };
        }

        if (@entities) {
            $entity_model->load_gid_redirects(@entities)
                if exists $entity_properties->{mbid} &&
                          $entity_properties->{mbid}{multiple};
            return @entities;
        }

        return;
    };
};

1;
