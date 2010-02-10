package MusicBrainz::Server::Controller::Role::Annotation;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

use MusicBrainz::Server::Constants qw( :annotation );
use MusicBrainz::Server::Data::Utils qw( model_to_type );

requires 'load', 'show';

my %model_to_edit_type = (
    Artist => $EDIT_ARTIST_ADD_ANNOTATION,
    Label => $EDIT_LABEL_ADD_ANNOTATION,
    Recording => $EDIT_RECORDING_ADD_ANNOTATION,
    Release => $EDIT_RELEASE_ADD_ANNOTATION,
    ReleaseGroup => $EDIT_RELEASEGROUP_ADD_ANNOTATION,
    Work => $EDIT_WORK_ADD_ANNOTATION,
);

sub latest_annotation : Chained('load') PathPart('annotation')
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{entity};
    my $annotation = $c->model($self->{model})->annotation->get_latest($entity->id);

    $c->stash(
        annotation => $annotation,
        type       => model_to_type($self->{model}),
        template   => $self->action_namespace . '/annotation_revision.tt'
    );
}

sub annotation_revision : Chained('load') PathPart('annotation') Args(1)
{
    my ($self, $c, $id) = @_;

    my $entity = $c->stash->{entity};
    my $annotation = $c->model($self->{model})->annotation->get_by_id($id)
        or $c->detach('/error_404');

    $c->stash(
        annotation => $annotation,
        gid        => $entity->gid,
        type       => model_to_type($self->{model}),
    );
}

after 'show' => sub
{
    my ($self, $c) = @_;
    my $entity = $c->stash->{entity};
    my $type = $self->{model};

    $c->stash->{type} = model_to_type($type);
    $c->model($type)->annotation->load_latest($entity);
};

sub edit_annotation : Chained('load') PathPart RequireAuth
{
    my ($self, $c) = @_;
    my $model = $self->{model};
    my $entity = $c->stash->{entity};
    $c->model($model)->annotation->load_latest($entity);

    $self->edit_action($c,
        form => 'Annotation',
        item => $entity->latest_annotation,
        type => $model_to_edit_type{$model},
        edit_args => {
            entity_id => $entity->id,
        },
        on_creation => sub {
            my $show = $self->action_for('show');
            $c->response->redirect($c->uri_for_action($show, [ $entity->gid ]));
            $c->detach;
        }
    );
}

sub annotation_history : Chained('load') PathPart
{
    my ($self, $c) = @_;
    $c->detach('/error_404');
}

no Moose::Role;
1;

