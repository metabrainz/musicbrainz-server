package MusicBrainz::Server::Controller::Role::Load;

use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;
use MusicBrainz::Server::Data::Utils 'model_to_type';
use MusicBrainz::Server::Validation qw( is_guid is_positive_integer );
use MusicBrainz::Server::Constants qw( :direction %ENTITIES );
use Readonly;
use aliased 'MusicBrainz::Server::Entity::RelationshipLinkTypeGroup';

no if $] >= 5.018, warnings => 'experimental::smartmatch';

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

parameter 'allow_integer_ids' => (
    isa => 'Bool',
    required => 0,
    default => sub { 1 },
);

Readonly our $RELATIONSHIP_PAGE_SIZE => 250;

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

        my $entity = $self->_load($c, @args);

        $c->detach('not_found') unless defined $entity;

        if (exists $entity_properties->{mbid} && $entity_properties->{mbid}{relatable}) {
            my $action = $c->action->name;
            my $relationships = $params->relationships;
            my $loaded = 0;

            if ($action ~~ $relationships->{all}) {
                $c->model('Relationship')->load($entity);
                $loaded = 1;
            } elsif ($action ~~ $relationships->{cardinal}) {
                $c->model('Relationship')->load_cardinal($entity);
                $loaded = 1;
            }

            my $paged_types = $relationships->{paged_subset}{$action};
            if ($paged_types) {
                my $params = $c->req->query_params;
                my $link_type_id = $params->{link_type_id};
                my $pager;
                my %opts;

                if (is_positive_integer($link_type_id)) {
                    $opts{link_type_id} = $link_type_id;
                    $opts{limit} = $RELATIONSHIP_PAGE_SIZE;

                    my $direction = $params->{direction};
                    if (
                        is_positive_integer($direction) &&
                        ($direction == $DIRECTION_FORWARD ||
                            $direction == $DIRECTION_BACKWARD)
                    ) {
                        $opts{direction} = $direction;
                    }

                    my $page = is_positive_integer($params->{page})
                        ? $params->{page} : 1;
                    $opts{offset} = ($page - 1) * $RELATIONSHIP_PAGE_SIZE;

                    $pager = Data::Page->new;
                    $pager->entries_per_page($RELATIONSHIP_PAGE_SIZE);
                    $pager->current_page($page);
                }

                my $lt_groups = $c->model('Relationship')->load_paged(
                    $entity,
                    $paged_types,
                    %opts,
                );

                if (defined $pager) {
                    if (scalar @$lt_groups > 1) {
                        die 'Expected only one link type group';
                    }

                    my $lt_group;
                    if (!scalar @$lt_groups) {
                        $lt_group = RelationshipLinkTypeGroup->new(
                            link_type_id => $link_type_id,
                        );
                    } else {
                        $lt_group = $lt_groups->[0];
                    }

                    $pager->total_entries($lt_group->total_relationships);
                    $c->stash->{pager} = $pager;
                    $c->stash->{paged_link_type_group} = $lt_group;
                }

                $loaded = 1;
            }

            if (defined $c->stash->{paged_link_type_group}) {
                # Still load URL rels since we want them for the sidebar
                $c->model('Relationship')->load_subset(['url'], $entity);
            } else {
                my $types = $relationships->{subset}{$action};
                if (!defined $types && !$loaded) {
                    $types = $relationships->{default};
                }
                if ($types) {
                    $c->model('Relationship')->load_subset($types, $entity);
                }
            }
        }

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

        my $entity;
        my $id_is_guid = is_guid($id) && $c->model($model)->can('get_by_gid');

        if ($id_is_guid) {
            $entity = $c->model($model)->get_by_gid($id);
        } elsif ($allows_integer_ids && is_positive_integer($id)) {
            $entity = $c->model($model)->get_by_id($id);
        } else {
            # This will detach for us
            $self->invalid_mbid($c, $id);
        }

        if ($entity) {
            if ($id_is_guid && $entity->gid ne $id) {
                my @captures = @{ $c->req->captures };
                $captures[0] = $entity->gid;
                $c->res->redirect($c->uri_for($c->action, \@captures, $c->req->params), 301);
            }
            $c->model($model)->load_gid_redirects($entity) if exists $entity_properties->{mbid} && $entity_properties->{mbid}{multiple};
            return $entity;
        }

        return undef;
    };
};

1;
