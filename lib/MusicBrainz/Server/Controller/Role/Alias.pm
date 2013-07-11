package MusicBrainz::Server::Controller::Role::Alias;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

requires 'load';

use MusicBrainz::Server::Constants qw(
    $EDIT_ARTIST_ADD_ALIAS $EDIT_ARTIST_DELETE_ALIAS $EDIT_ARTIST_EDIT_ALIAS
    $EDIT_AREA_ADD_ALIAS $EDIT_AREA_DELETE_ALIAS $EDIT_AREA_EDIT_ALIAS
    $EDIT_LABEL_ADD_ALIAS $EDIT_LABEL_DELETE_ALIAS $EDIT_LABEL_EDIT_ALIAS
    $EDIT_WORK_ADD_ALIAS $EDIT_WORK_DELETE_ALIAS $EDIT_WORK_EDIT_ALIAS
);

my %model_to_edit_type = (
    add => {
        Artist => $EDIT_ARTIST_ADD_ALIAS,
        Area => $EDIT_AREA_ADD_ALIAS,
        Label  => $EDIT_LABEL_ADD_ALIAS,
        Work   => $EDIT_WORK_ADD_ALIAS,
    },
    delete => {
        Artist => $EDIT_ARTIST_DELETE_ALIAS,
        Area => $EDIT_AREA_DELETE_ALIAS,
        Label  => $EDIT_LABEL_DELETE_ALIAS,
        Work   => $EDIT_WORK_DELETE_ALIAS,
    },
    edit => {
        Artist => $EDIT_ARTIST_EDIT_ALIAS,
        Area => $EDIT_AREA_EDIT_ALIAS,
        Label  => $EDIT_LABEL_EDIT_ALIAS,
        Work   => $EDIT_WORK_EDIT_ALIAS,
    }
);

my %model_to_search_hint_type_id = (
    Artist => 3,
    Area => 3,
    Label => 2,
    Work => 2
);

sub aliases : Chained('load') PathPart('aliases')
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my $m = $c->model($self->{model});
    my $aliases = $m->alias->find_by_entity_id($entity->id);
    $m->alias_type->load(@$aliases);
    $c->stash(
        aliases => $aliases,
    );
}

sub alias : Chained('load') PathPart('alias') CaptureArgs(1)
{
    my ($self, $c, $alias_id) = @_;
    my $alias = $c->model($self->{model})->alias->get_by_id($alias_id)
        or $c->detach('/error_404');
    $c->stash( alias => $alias );
}

sub add_alias : Chained('load') PathPart('add-alias') RequireAuth Edit
{
    my ($self, $c) = @_;
    my $type = $self->{entity_name};
    my $entity = $c->stash->{ $type };
    my $alias_model = $c->model( $self->{model} )->alias;
    $self->edit_action($c,
        form => 'Alias',
        form_args => {
            parent_id => $entity->id,
            alias_model => $alias_model,
            search_hint_type_id => $model_to_search_hint_type_id{ $self->{model} }
        },
        type => $model_to_edit_type{add}->{ $self->{model} },
        edit_args => {
            entity => $entity
        },
        item => {
            name => $entity->name,
            id => $entity->id
        },
        on_creation => sub { $self->_redir_to_aliases($c) }
    );
}

sub delete_alias : Chained('alias') PathPart('delete') RequireAuth Edit
{
    my ($self, $c) = @_;
    my $alias = $c->stash->{alias};
    $self->edit_action($c,
        form => 'Confirm',
        type => $model_to_edit_type{delete}->{ $self->{model} },
        edit_args => {
            alias  => $alias,
            entity => $c->stash->{ $self->{entity_name} }
        },
        on_creation => sub { $self->_redir_to_aliases($c) }
    );
}

sub edit_alias : Chained('alias') PathPart('edit') RequireAuth Edit
{
    my ($self, $c) = @_;
    my $alias = $c->stash->{alias};
    my $type = $self->{entity_name};
    my $entity = $c->stash->{ $type };
    my $alias_model = $c->model( $self->{model} )->alias;
    $self->edit_action($c,
        form => 'Alias',
        form_args => {
            parent_id => $entity->id,
            alias_model => $alias_model,
            id => $alias->id,
            search_hint_type_id => $model_to_search_hint_type_id{ $self->{model} }
        },
        item => $alias,
        type => $model_to_edit_type{edit}->{ $self->{model} },
        edit_args => {
            alias  => $alias,
            entity => $c->stash->{ $self->{entity_name} }
        },
        on_creation => sub { $self->_redir_to_aliases($c) }
    );
}

sub _redir_to_aliases
{
    my ($self, $c) = @_;
    my $action = $c->controller->action_for('aliases');
    my $entity = $c->stash->{ $self->{entity_name} };
    $c->response->redirect($c->uri_for($action, [ $entity->gid ]));
}

no Moose::Role;
1;
