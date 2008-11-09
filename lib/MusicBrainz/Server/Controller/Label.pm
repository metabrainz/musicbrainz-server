package MusicBrainz::Server::Controller::Label;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller::Entity';

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

=head2 perma

Display details about a permanant link to this label.

=cut

sub perma : Chained('load') { }

=head2 aliases

Display all aliases for a label

=cut

sub aliases : Chained('load')
{
    my ($self, $c) = @_;
    my $label = $self->entity;

    $c->stash->{aliases}  = $c->model('Alias')->load_for_entity($label);
}

=head2 tags

Display a tag-cloud of tags for a label

=cut

sub tags : Chained('load')
{
    my ($self, $c) = @_;
    my $label = $self->entity;

    $c->stash->{tagcloud} = $c->model('Tag')->generate_tag_cloud($label);
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
    my $label = $c->stash->{_label};

    $c->stash->{relations} = load_relations($label);
}

=head2 show

Show this label to a user, including a summary of ARs, and the releases
that have been released through this label

=cut

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    my $label    = $self->entity;
    my $releases = $c->model('Release')->load_for_label($label);

    $c->stash->{releases}  = $releases;
    $c->stash->{relations} = $c->model('Relation')->load_relations($label);
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

sub merge_into : Chained('load') PathPart('into') Args(1)
{
    my ($self, $c, $new_mbid) = @_;

    $c->forward('/user/login');

    my $label     = $self->entity;
    my $new_label = $c->model('Label')->load($new_mbid);
    $c->stash->{new_label} = $new_label;

    my $form = $c->form($label, 'Label::Merge');
    $form->context($c);

    $c->stash->{template} = 'label/merge.tt';

    return unless $c->form_posted && $form->validate($c->req->params);

    my @mods = $form->insert($new_label);

    $c->flash->{ok} = "Thanks, your label edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($new_label, 'show'));
}

sub edit : Chained('load')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $label = $self->entity;

    my $form = $c->form($label, 'Label::Edit');
    $form->context($c);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->insert;

    $c->flash->{ok} = "Thanks, your label edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($label, 'show'));
}

sub create : Local
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $form = $c->form(undef, 'Label::Create');
    $form->context($c);

    return unless $c->form_posted && $form->validate($c->req->params);

    my @mods = $form->insert;

    # Make sure that the moderation did go through, and redirect to
    # the new artist
    my @add_mods = grep { $_->type eq ModDefs::MOD_ADD_LABEL } @mods;

    die "Label could not be created"
        unless @add_mods;

    # we can't use entity_url because that would require loading the new artist
    # or creating a mock artist - both are messier than this slightly
    # hacky solution
    $c->response->redirect($c->uri_for('/label', $add_mods[0]->row_id));
}

=head2 subscribe

Allow a moderator to subscribe to this label

=cut

sub subscribe : Chained('load')
{
    my ($self, $c) = @_;
    my $label = $self->entity;

    $c->forward('/user/login');

    my $us = UserSubscription->new($c->mb->{DBH});
    $us->SetUser($c->user->id);
    $us->SubscribeLabels($label);

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

    my $us = UserSubscription->new($c->mb->{DBH});
    $us->SetUser($c->user->id);
    $us->UnsubscribeLabels($label);

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

    my @all_users = $label->GetSubscribers;

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

sub add_alias : Chained('load')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $label = $self->entity;

    my $form = $c->form($label, 'Label::AddAlias');
    $form->context($c);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->insert;

    $c->response->redirect($c->entity_url($label, 'aliases'));
}

sub edit_alias : Chained('load') Args(1)
{
    my ($self, $c, $alias_id) = @_;

    $c->forward('/user/login');

    my $label = $self->entity;
    my $alias = $c->model('Alias')->load($label, $alias_id);

    my $form = $c->form($alias, 'Label::EditAlias');
    $form->context($c);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->insert($label);

    $c->response->redirect($c->entity_url($label, 'aliases'));
}

sub remove_alias : Chained('load') Args(1)
{
    my ($self, $c, $alias_id) = @_;

    $c->forward('/user/login');

    my $label = $self->entity;
    my $alias = $c->model('Alias')->load($label, $alias_id);

    my $form = $c->form($label, 'Label::RemoveAlias');
    $form->context($c);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->insert($alias);

    $c->response->redirect($c->entity_url($label, 'aliases'));
}

1;
