package MusicBrainz::Server::Controller::Role::Alias;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use MusicBrainz::Server::ControllerUtils::Delete qw( cancel_or_action );

requires 'load';

use MusicBrainz::Server::Constants qw( :alias entities_with );

my %model_to_edit_type = (
    add => { entities_with('aliases',
        take => sub {
            my (undef, $info) = @_;
            return ($info->{model} => $info->{aliases}{add_edit_type} )
        }
    ) },
    delete => { entities_with('aliases',
        take => sub {
            my (undef, $info) = @_;
            return ($info->{model} => $info->{aliases}{delete_edit_type} )
        }
    ) },
    edit => { entities_with('aliases',
        take => sub {
            my (undef, $info) = @_;
            return ($info->{model} => $info->{aliases}{edit_edit_type} )
        }
    ) }
);

my %model_to_search_hint_type_id = entities_with('aliases',
    take => sub {
        my (undef, $info) = @_;
        return ($info->{model} => $info->{aliases}{search_hint_type} )
    }
);

sub aliases : Chained('load') PathPart('aliases')
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my $m = $c->model($self->{model});
    my $aliases = $m->alias->find_by_entity_id($entity->id);
    $m->alias_type->load(@$aliases);
    $c->stash(
        # "aliases" needs to remain here even after migration for JSON-LD serialization
        aliases => $aliases,
    );

    if ($entity->entity_type eq 'release_group') {
        my %props = (
            aliases => $aliases,
            entity => $entity,
        );

        $c->stash(
            component_path => 'entity/Aliases.js',
            component_props => \%props,
            current_view => 'Node',
        );
    }
}

sub alias : Chained('load') PathPart('alias') CaptureArgs(1)
{
    my ($self, $c, $alias_id) = @_;
    my $alias = $c->model($self->{model})->alias->get_by_id($alias_id)
        or $c->detach('/error_404');
    $c->stash( alias => $alias );
}

sub add_alias : Chained('load') PathPart('add-alias') Edit
{
    my ($self, $c) = @_;
    my $type = $self->{entity_name};
    my $entity = $c->stash->{ $type };
    my $alias_model = $c->model( $self->{model} )->alias;
    $c->stash( template => 'entity/alias/add.tt' );
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

sub delete_alias : Chained('alias') PathPart('delete') Edit
{
    my ($self, $c) = @_;
    my $alias = $c->stash->{alias};
    my $edit = $c->model('Edit')->find_creation_edit($model_to_edit_type{add}->{ $self->{model} }, $alias->id, id_field => 'alias_id');
    $c->stash( template => 'entity/alias/delete.tt' );
    cancel_or_action($c, $edit, $self->_aliases_url($c), sub {
        $self->edit_action($c,
            form => 'Confirm',
            form_args => { requires_edit_note => 1 },
            type => $model_to_edit_type{delete}->{ $self->{model} },
            edit_args => {
                alias  => $alias,
                entity => $c->stash->{ $self->{entity_name} }
            },
            on_creation => sub { $self->_redir_to_aliases($c) }
        );
    });
}

sub edit_alias : Chained('alias') PathPart('edit') Edit
{
    my ($self, $c) = @_;
    my $alias = $c->stash->{alias};
    my $type = $self->{entity_name};
    my $entity = $c->stash->{ $type };
    my $alias_model = $c->model( $self->{model} )->alias;
    $c->stash( template => 'entity/alias/edit.tt' );
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

sub _aliases_url
{
    my ($self, $c) = @_;
    my $action = $c->controller->action_for('aliases');
    my $entity = $c->stash->{ $self->{entity_name} };
    return $c->uri_for($action, [ $entity->gid ]);
}

sub _redir_to_aliases
{
    my ($self, $c) = @_;
    my $action = $c->controller->action_for('aliases');
    my $entity = $c->stash->{ $self->{entity_name} };
    $c->response->redirect($self->_aliases_url($c));
}

no Moose::Role;
1;
