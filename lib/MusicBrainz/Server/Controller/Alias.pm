package MusicBrainz::Server::Controller::Alias;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

requires 'load';

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_ADD_ALIAS $EDIT_LABEL_ADD_ALIAS );
use MusicBrainz::Server::Edit::Artist::AddAlias;
use MusicBrainz::Server::Edit::Label::AddAlias;

my %model_to_edit_type = (
    Artist => $EDIT_ARTIST_ADD_ALIAS,
    Label  => $EDIT_LABEL_ADD_ALIAS,
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

sub add_alias : Chained('load') PathPart('add-alias') RequireAuth
{
    my ($self, $c) = @_;
    my $form = $c->form( form => 'Alias' );
    my $type = $self->{entity_name};
    my $entity = $c->stash->{ $type };
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $edit = $c->model('Edit')->create(
            edit_type => $model_to_edit_type{ $self->{model} },
            editor_id => $c->user->id,
            alias => $form->field('alias')->value,
            $type.'_id' => $entity->id,
        );

        my $action = $c->controller->action_for('aliases');
        $c->response->redirect($c->uri_for($action, [ $entity->gid ]));
    }
}


no Moose::Role;
1;
