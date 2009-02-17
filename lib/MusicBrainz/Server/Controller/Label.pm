package MusicBrainz::Server::Controller::Label;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

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

sub label : Chained('load') PathPart('') CaptureArgs(0)
{
    my ($self, $c) = @_;
    
    if ($self->entity->id == ModDefs::DLABEL_ID)
    {
        $c->detach('/error_404');
    }

	if ($c->user_exists)
	{
    	$c->stash->{subscribed} = $c->model('Subscription')->
        	is_user_subscribed_to_entity($c->user, $self->entity);
	}
}

=head2 perma

Display details about a permanant link to this label.

=cut

sub perma : Chained('label') { }

=head2 aliases

Display all aliases for a label

=cut

sub aliases : Chained('label')
{
    my ($self, $c) = @_;
    my $label = $self->entity;

    $c->stash->{aliases}  = $c->model('Alias')->load_for_entity($label);
}

=head2 tags

Display a tag-cloud of tags for a label

=cut

sub tags : Chained('label')
{
    my ($self, $c) = @_;
    $c->forward('/tags/entity', [ $self->entity ]);
}

=head2 google

Redirect to Google and search for this label (using MusicBrainz colours).

=cut

sub google : Chained('label')
{
    my ($self, $c) = @_;
    my $label = $self->entity;

    $c->response->redirect(Google($label->name));
}

=head2 relations

Show all relations to this label

=cut

sub relations : Chained('label')
{
    my ($self, $c) = @_;
    $c->stash->{relations} = $c->model('Relation')->load_relations($self->entity);
}

=head2 show

Show this label to a user, including a summary of ARs, and the releases
that have been released through this label

=cut

sub show : PathPart('') Chained('label')
{
    my ($self, $c) = @_;

    my $label    = $self->entity;
    my $releases = $c->model('Release')->load_for_label($label);

    my $id = $c->user_exists ? $c->user->id : 0;
    $c->stash->{show_ratings} = $id ? $c->user->preferences->get("show_ratings") : 1;
    if ($c->stash->{show_ratings})
    {
        MusicBrainz::Server::Rating::LoadUserRatingForEntities("release", $releases, $id);
        $c->stash->{rating} = $c->model('Rating')->get_rating({
            entity_type => 'label', 
            entity_id   => $label->id, 
            user_id     => $id
        });
    }

    $c->stash->{releases}  = $releases;
    $c->stash->{relations} = $c->model('Relation')->load_relations($label);
	$c->stash->{annotation} = $c->model('Annotation')->load_revision($label);
}

=head2 details

Display detailed information about a given label

=cut

sub details : Chained('label') { }

=head2 WRITE METHODS

=cut

sub merge : Chained('label')
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

sub merge_into : Chained('label') PathPart('into') Args(1) Form('Label::Merge')
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

sub edit : Chained('label') Form
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

sub create : Local Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $form = $self->form;

    return unless $self->submit_and_validate($c);

    my $created_label = $form->create;

    if (defined $created_label)
    {
        $c->response->redirect($c->entity_url($created_label, 'show'));
    }
}

=head2 subscribe

Allow a moderator to subscribe to this label

=cut

sub subscribe : Chained('label')
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

sub unsubscribe : Chained('label')
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

sub subscriptions : Chained('label')
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

sub add_alias : Chained('label') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $form = $self->form;

    return unless $self->submit_and_validate($c);

    my $label = $self->entity;

    $form->create_for($label);

    $c->response->redirect($c->entity_url($label, 'aliases'));
}

sub edit_alias : Chained('label') Args(1) Form
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

sub remove_alias : Chained('label') Args(1) Form
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
