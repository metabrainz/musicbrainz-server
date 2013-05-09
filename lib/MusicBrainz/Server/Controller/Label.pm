package MusicBrainz::Server::Controller::Label;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'Label',
    entity_name => 'label',
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Cleanup';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::IPI';
with 'MusicBrainz::Server::Controller::Role::ISNI';
with 'MusicBrainz::Server::Controller::Role::Relationship';
with 'MusicBrainz::Server::Controller::Role::Rating';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::Subscribe';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';

use MusicBrainz::Server::Constants qw( $DLABEL_ID $EDIT_LABEL_CREATE $EDIT_LABEL_DELETE $EDIT_LABEL_EDIT $EDIT_LABEL_MERGE );
use MusicBrainz::Server::ControllerUtils::Release qw( load_release_events );
use Data::Page;

use MusicBrainz::Server::Form::Confirm;
use MusicBrainz::Server::Form::Label;
use Sql;

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
    $c->model('Area')->load($c->stash->{label});
    $c->model('Area')->load_codes($label->area);
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

    my $releases = $self->_load_paged($c, sub {
            $c->model('Release')->find_by_label($c->stash->{label}->id, shift, shift);
        });

    $c->model('ArtistCredit')->load(@$releases);
    load_release_events($c, @$releases);
    $c->model('Medium')->load_for_releases(@$releases);
    $c->model('MediumFormat')->load(map { $_->all_mediums } @$releases);
    $c->model('ReleaseLabel')->load(@$releases);
    $c->stash(
        template => 'label/index.tt',
        releases => $releases,
    );
}

=head2 WRITE METHODS

=cut

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_LABEL_MERGE,
    confirmation_template => 'label/merge_confirm.tt',
    search_template       => 'label/merge_search.tt',
};

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Label',
    edit_type => $EDIT_LABEL_CREATE,
};

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form           => 'Label',
    edit_type      => $EDIT_LABEL_EDIT,
};

with 'MusicBrainz::Server::Controller::Role::Delete' => {
    edit_type      => $EDIT_LABEL_DELETE,
};

1;
