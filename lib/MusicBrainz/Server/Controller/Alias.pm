package MusicBrainz::Server::Controller::Alias;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

requires 'load';

use MusicBrainz::Server::Constants qw(
    $EDIT_ARTIST_ADD_ALIAS $EDIT_LABEL_ADD_ALIAS $EDIT_ARTIST_EDIT_ALIAS
    $EDIT_ARTIST_DELETE_ALIAS $EDIT_LABEL_DELETE_ALIAS $EDIT_LABEL_EDIT_ALIAS
);

my %model_to_edit_type = (
    add => {
        Artist => $EDIT_ARTIST_ADD_ALIAS,
        Label  => $EDIT_LABEL_ADD_ALIAS,
    },
    delete => {
        Artist => $EDIT_ARTIST_DELETE_ALIAS,
        Label  => $EDIT_LABEL_DELETE_ALIAS,
    },
    edit => {
        Artist => $EDIT_ARTIST_EDIT_ALIAS,
        Label  => $EDIT_LABEL_EDIT_ALIAS,
    }
);

sub aliases : Chained('load') PathPart('aliases')
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my $aliases = $c->model($self->{model})->alias->find_by_entity_id($entity->id);
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

sub add_alias : Chained('load') PathPart('add-alias') RequireAuth
{
    my ($self, $c) = @_;
    my $form = $c->form( form => 'Alias' );
    my $type = $self->{entity_name};
    my $entity = $c->stash->{ $type };
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $edit = $c->model('Edit')->create(
            edit_type => $model_to_edit_type{add}->{ $self->{model} },
            editor_id => $c->user->id,
            alias => $form->field('alias')->value,
            $type.'_id' => $entity->id,
        );

        $self->_redir_to_aliases($c);
    }
}

sub delete_alias : Chained('alias') PathPart('delete') RequireAuth
{
    my ($self, $c, $alias_id) = @_;
    my $alias = $c->stash->{alias};
    my $form = $c->form( form => 'Confirm' );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $edit = $c->model('Edit')->create(
            edit_type => $model_to_edit_type{delete}->{ $self->{model} },
            editor_id => $c->user->id,
            alias     => $alias,
            entity_id => $c->stash->{ $self->{entity_name} }->id,
        );

        $self->_redir_to_aliases($c);
    }
}

sub edit_alias : Chained('alias') PathPart('edit') RequireAuth
{
    my ($self, $c) = @_;
    my $alias = $c->stash->{alias};
    my $form = $c->form( form => 'Alias', item => $alias );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $edit = $c->model('Edit')->create(
            edit_type => $model_to_edit_type{edit}->{ $self->{model} },
            editor_id => $c->user->id,
            alias     => $alias,
            entity_id => $c->stash->{ $self->{entity_name} }->id,
            name      => $form->field('alias')->value
        );

        $self->_redir_to_aliases($c);
    }
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
