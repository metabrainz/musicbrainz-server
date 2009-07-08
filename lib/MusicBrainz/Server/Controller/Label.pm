package MusicBrainz::Server::Controller::Label;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Annotation';
with 'MusicBrainz::Server::Controller::Alias';
with 'MusicBrainz::Server::Controller::RelationshipRole';

use MusicBrainz::Server::Constants qw( $DLABEL_ID $EDIT_LABEL_CREATE $EDIT_LABEL_DELETE );
use Data::Page;

use MusicBrainz::Server::Edit::Label::Create;
use MusicBrainz::Server::Edit::Label::Delete;
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
    
    if ($c->stash->{label}->id == $DLABEL_ID)
    {
        $c->detach('/error_404');
    }

	$c->model('LabelType')->load($c->stash->{label});
};

=head2 perma

Display details about a permanant link to this label.

=cut

sub perma : Chained('load') { }

=head2 tags

Display a tag-cloud of tags for a label

=cut

sub tags : Chained('load')
{
    my ($self, $c) = @_;
    $c->forward('/tags/entity', [ $self->entity ]);
}

=head2 google

Redirect to Google and search for this label (using MusicBrainz colours).

=cut

sub google : Chained('load')
{
    my ($self, $c) = @_;
    my $label = $self->entity;

    $c->response->redirect(Google($label->name));
}

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

=head2 details

Display detailed information about a given label

=cut

sub details : Chained('load') { }

=head2 WRITE METHODS

=cut

sub merge : Chained('load')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');
    $c->forward('/search/filter_label');

    $c->stash->{template} = 'label/merge_search.tt';

    my $result = $c->stash->{search_result};
    if (defined $result)
    {
        my $label = $self->entity;
	$c->response->redirect($c->entity_url($label, 'merge_into',
					      $result->id));
    }
}

sub merge_into : Chained('load') PathPart('into') Args(1) Form('Label::Merge')
{
    my ($self, $c, $new_mbid) = @_;

    $c->forward('/user/login');

    my $label     = $self->entity;
    my $new_label = $c->model('Label')->load($new_mbid);
    $c->stash->{new_label} = $new_label;

    my $form = $self->form;
    $form->init($label);

    $c->stash->{template} = 'label/merge.tt';

    return unless $self->submit_and_validate($c);

    $form->merge_into($new_label);

    $c->flash->{ok} = "Thanks, your label edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($new_label, 'show'));
}

sub edit : Chained('load') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $label = $self->entity;

    my $form = $self->form;
    $form->init($label);

    return unless $self->submit_and_validate($c);

    $form->edit;

    $c->flash->{ok} = "Thanks, your label edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($label, 'show'));
}

sub create : Local RequireAuth
{
    my ($self, $c) = @_;

    my $form = $c->form( form => 'Label' );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params))
    {
        my %edit = map { $_ => $form->field($_)->value }
            qw( name sort_name type_id label_code country_id begin_date end_date comment );

        my $edit = $c->model('Edit')->create(
            edit_type => $EDIT_LABEL_CREATE,
            editor_id => $c->user->id,
            %edit
        );

        if ($edit->label)
        {
            $c->response->redirect($c->uri_for_action('/label/show', [ $edit->label->gid ]));
            $c->detach;
        }
    }
}

sub delete : Chained('load') PathPart RequireAuth
{
    my ($self, $c) = @_;

    my $label = $c->stash->{label};
    my $can_delete = 1;
    return unless $can_delete;

    my $form = $c->form( form => 'Confirm' );
    $c->stash( can_delete => $can_delete );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params))
    {
        my $edit = $c->model('Edit')->create(
            editor_id => $c->user->id,
            edit_type => $EDIT_LABEL_DELETE,
            label_id => $label->id
        );

        $c->response->redirect($c->uri_for_action('/label/show', [ $label->gid ]));
        $c->detach;
    }
}

=head2 subscribe

Allow a moderator to subscribe to this label

=cut

sub subscribe : Chained('load')
{
    my ($self, $c) = @_;
    my $label = $self->entity;

    $c->forward('/user/login');

    my $us = UserSubscription->new($c->mb->{dbh});
    $us->SetUser($c->user->id);
    $us->SubscribeLabels($label);
    $c->stash->{subscribed} = 1;

    $c->forward('subscriptions');
}

=head2 unsubscribe

Unsubscribe from a label

=cut

sub unsubscribe : Chained('load')
{
    my ($self, $c) = @_;
    my $label = $self->entity;

    $c->forward('/user/login');

    my $us = UserSubscription->new($c->mb->{dbh});
    $us->SetUser($c->user->id);
    $us->UnsubscribeLabels($label);
    $c->stash->{subscribed} = undef;

    $c->forward('subscriptions');
}

=head2 show_subscriptions

Show all users who are subscribed to this label, and have stated they
wish their subscriptions to be public

=cut

sub subscriptions : Chained('load')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $label = $self->entity;

    my @all_users = $label->subscribers;

    my @public_users;
    my $anonymous_subscribers;

    for my $uid (@all_users)
    {
        my $user = $c->model('User')->load({ id => $uid });

        my $public = UserPreference::get_for_user("subscriptions_public", $user);
        my $is_me  = $c->user_exists && $c->user->id == $user->id;

        if ($is_me) { $c->stash->{user_subscribed} = $is_me; }

        if ($public || $is_me)
        {
            push @public_users, $user;
        }
        else
        {
            $anonymous_subscribers++;
        }
    }

    $c->stash->{subscribers          } = \@public_users;
    $c->stash->{anonymous_subscribers} = $anonymous_subscribers;

    $c->stash->{template} = 'label/subscriptions.tt';
}

sub add_alias : Chained('load') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $form = $self->form;

    return unless $self->submit_and_validate($c);

    my $label = $self->entity;

    $form->create_for($label);

    $c->response->redirect($c->entity_url($label, 'aliases'));
}

sub edit_alias : Chained('load') Args(1) Form
{
    my ($self, $c, $alias_id) = @_;

    $c->forward('/user/login');

    my $label = $self->entity;
    my $alias = $c->model('Alias')->load($label, $alias_id);

    my $form = $self->form;
    $form->init($alias);

    return unless $self->submit_and_validate($c);

    $form->edit_for($label);

    $c->response->redirect($c->entity_url($label, 'aliases'));
}

sub remove_alias : Chained('load') Args(1) Form
{
    my ($self, $c, $alias_id) = @_;

    $c->forward('/user/login');

    my $label = $self->entity;
    my $alias = $c->model('Alias')->load($label, $alias_id);

    my $form = $self->form;
    $form->init($alias);

    return unless $self->submit_and_validate($c);

    $form->remove_from($label);

    $c->response->redirect($c->entity_url($label, 'aliases'));
}

1;
