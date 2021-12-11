package MusicBrainz::Server::Controller::Role::Annotation;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

use MusicBrainz::Server::Constants qw( :annotation entities_with );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_positive_integer is_nat );

requires 'load', 'show';

my %model_to_edit_type = entities_with('annotations', take => sub {
    my ($type, $properties) = @_;
    return ($properties->{model} => $properties->{annotations}{edit_type});
});

after 'load' => sub
{
    my ($self, $c) = @_;
    my $entity = $c->stash->{entity};
    my $model = $self->{model};

    $c->model($model)->annotation->load_latest($entity);
};

sub latest_annotation : Chained('load') PathPart('annotation')
{
    my ($self, $c) = @_;
    my $entity = $c->stash->{entity};
    my $model = $self->{model};

    my $annotation = $c->model($self->{model})->annotation->get_latest($entity->id);

    $c->model('Editor')->load($annotation);

    my $annotation_model = $c->model($model)->annotation;
    my $annotations = $self->_load_paged(
        $c, sub {
            $annotation_model->get_history($entity->id, @_);
        }
    );

    $c->stash(
        annotation => $annotation,
        number_of_revisions => scalar @$annotations,
        template   => 'annotation/revision.tt'
    );
}

sub annotation_revision : Chained('load') PathPart('annotation') Args(1)
{
    my ($self, $c, $id) = @_;
    my $entity = $c->stash->{entity};
    my $model = $self->{model};

    if (!is_nat($id)) {
        $c->stash(
            message => l('The annotation revision ID must be a positive integer')
        );
        $c->detach('/error_400')
    }

    my $annotation = $c->model($self->{model})->annotation->get_by_id($id)
        or $c->detach('/error_404');

    $c->model('Editor')->load($annotation);

    my $annotation_model = $c->model($model)->annotation;
    my $annotations = $self->_load_paged(
        $c, sub {
            $annotation_model->get_history($entity->id, @_);
        }
    );

    $c->stash(
        annotation => $annotation,
        number_of_revisions => scalar @$annotations,
        template   => 'annotation/revision.tt'
    );
}

before 'show' => sub
{
    my ($self, $c) = @_;

    my $annotation = $c->stash->{entity}{latest_annotation};
    $c->model('Editor')->load($annotation);
};

after 'load' => sub {
    my ($self, $c) = @_;

    my (undef, $no) = $c->model($self->{model})->annotation
        ->get_history($c->stash->{entity}->id, 50, 0);


    $c->stash(
        number_of_revisions => $no,
    );
};

sub edit_annotation : Chained('load') PathPart Edit
{
    my ($self, $c) = @_;
    my $model = $self->{model};
    my $entity = $c->stash->{entity};
    my $annotation_model = $c->model($model)->annotation;
    $annotation_model->load_latest($entity);

    $c->stash(
        template   => 'annotation/edit.tt',
    );

    $self->edit_action($c,
        form        => 'Annotation',
        form_args   => { annotation_model => $annotation_model, entity_id => $entity->id },
        type        => $model_to_edit_type{$model},
        item        => $entity->latest_annotation,
        edit_args   => { entity => $entity },
        redirect    => sub {
            my $redirect = $c->req->params->{returnto} ||
              $c->uri_for_action($self->action_for('show'), [ $entity->gid ]);

            $c->response->redirect($redirect);
        },
        pre_creation => sub {
            my $form = shift;

            if ($form->field('preview')->input) {
                $c->stash(show_preview => 1, preview => $form->field('text')->value);
                return 0;
            }
            return 1;
        }
    );
}

sub annotation_history : Chained('load') PathPart('annotations') RequireAuth
{
    my ($self, $c) = @_;

    my $model            = $self->{model};
    my $entity           = $c->stash->{entity};
    my $annotation_model = $c->model($model)->annotation;

    my $annotations = $self->_load_paged(
        $c, sub {
            $annotation_model->get_history($entity->id, @_);
        }
    );

    $c->model('Editor')->load(@$annotations);
    $c->stash(
        template => 'annotation/history.tt',
        annotations => $annotations
    );
}

sub annotation_diff : Chained('load') PathPart('annotations-differences') RequireAuth
{
    my ($self, $c) = @_;

    my $model            = $self->{model};
    my $annotation_model = $c->model($model)->annotation;

    my $old = $c->req->query_params->{old};
    my $new = $c->req->query_params->{new};

    unless (is_positive_integer($old) &&
            is_positive_integer($new) &&
            $old != $new) {
        $c->stash(
            message => l('The old and new annotation ids must be unique, positive integers.')
        );
        $c->detach('/error_400')
    }

    my $old_annotation = $annotation_model->get_by_id($old);
    my $new_annotation = $annotation_model->get_by_id($new);

    $c->model('Editor')->load($new_annotation);
    $c->model('Editor')->load($old_annotation);

    $c->stash(
        template => 'annotation/diff.tt',
        old => $old_annotation,
        new => $new_annotation
    );
}

no Moose::Role;
1;

