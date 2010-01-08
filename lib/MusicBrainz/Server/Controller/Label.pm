package MusicBrainz::Server::Controller::Label;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Annotation';
with 'MusicBrainz::Server::Controller::Alias';
with 'MusicBrainz::Server::Controller::DetailsRole';
with 'MusicBrainz::Server::Controller::RelationshipRole';
with 'MusicBrainz::Server::Controller::RatingRole';
with 'MusicBrainz::Server::Controller::TagRole';
with 'MusicBrainz::Server::Controller::EditListingRole';

use MusicBrainz::Server::Constants qw( $DLABEL_ID $EDIT_LABEL_CREATE $EDIT_LABEL_DELETE $EDIT_LABEL_EDIT $EDIT_LABEL_MERGE );
use Data::Page;

use MusicBrainz::Server::Form::Confirm;
use MusicBrainz::Server::Form::Label;
use Sql;

__PACKAGE__->config(
    model       => 'Label',
    entity_name => 'label',
);

=head1 NAME

MusicBrainz::Server::Controller::Label

=head1 DESCRIPTION

Handles user interaction with label entities

=head1 METHODS

=head2 base

Base action to specify that all actions live in the C<label>
namespace

=cut

sub base : Chained('/') PathPart('label') CaptureArgs(0) { }

after 'load' => sub
{
    my ($self, $c) = @_;

    my $label = $c->stash->{label};
    if ($label->id == $DLABEL_ID)
    {
        $c->detach('/error_404');
    }

    my $label_model = $c->model('Label');
    $label_model->load_meta($label);
    if ($c->user_exists) {
        $label_model->rating->load_user_ratings($c->user->id, $label);

        $c->stash->{subscribed} = $label_model->subscription->check_subscription(
            $c->user->id, $label->id);
    }
    $c->model('LabelType')->load($label);
};

=head2 relations

Show all relations to this label

=cut

sub relations : Chained('load')
{
    my ($self, $c) = @_;
    $c->stash->{relations} = $c->model('Relation')->load_relations($self->entity);
}

=head2 show

Show this label to a user, including a summary of ARs, and the releases
that have been released through this label

=cut

sub show : PathPart('') Chained('load')
{
    my  ($self, $c) = @_;

    my $release_labels = $self->_load_paged($c, sub {
            $c->model('ReleaseLabel')->find_by_label($c->stash->{label}->id, shift, shift);
        });

    my @releases = map { $_->release } @$release_labels;

    $c->model('Country')->load($c->stash->{label}, @releases);
    $c->model('ArtistCredit')->load(@releases);

    $c->stash(
        template => 'label/index.tt',
        releases => $release_labels,
    );
}

=head2 WRITE METHODS

=cut

sub merge : Chained('load') RequireAuth
{
    my ($self, $c) = @_;
    my $old_label = $c->stash->{label};

    my $new_label;
    unless($new_label = $c->model('Label')->get_by_gid($c->req->query_params->{gid}))
    {
        $c->stash( template => 'label/merge_search.tt' );
        $new_label = $c->controller('Search')->filter($c, 'label', 'Label');
    }

    $c->stash(
        template => 'label/merge_confirm.tt',
        new_label => $new_label,
        old_label => $old_label
    );

    $self->edit_action($c,
        form => 'Confirm',
        type => $EDIT_LABEL_MERGE,
        edit_args => {
            old_label_id => $old_label->id,
            new_label_id => $new_label->id,
        },
        on_creation => sub {
            $c->response->redirect(
                $c->uri_for_action('/label/show', [ $new_label->gid ]));
        }
    );
}

sub edit : Chained('load') RequireAuth
{
    my ($self, $c) = @_;
    my $label = $c->stash->{label};
    $self->edit_action($c,
        form => 'Label',
        item => $label,
        type => $EDIT_LABEL_EDIT,
        edit_args => { label => $label },
        on_creation => sub {
            $c->response->redirect(
                $c->uri_for_action('/label/show', [ $label->gid ]));
        }
    );
}

sub create : Local RequireAuth
{
    my ($self, $c) = @_;
    $self->edit_action($c,
        form => 'Label',
        type => $EDIT_LABEL_CREATE,
        on_creation => sub {
            my $edit = shift;
            $c->response->redirect(
                $c->uri_for_action('/label/show', [ $edit->label->gid ]));
        }
    );
}

sub delete : Chained('load') PathPart RequireAuth
{
    my ($self, $c) = @_;

    my $label = $c->stash->{label};
    return unless $c->model('Label')->can_delete($label->id);

    $self->edit_action($c,
        form => 'Confirm',
        type => $EDIT_LABEL_DELETE,
        edit_args => { label => $label },
        on_creation => sub {
            my $edit = shift;
            my $url = $edit->is_open ? $c->uri_for_action('/label/show', [ $label->gid ])
                : $c->uri_for_action('/search');
            $c->response->redirect($url);
        }
    );
}

1;
