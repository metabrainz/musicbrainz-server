package MusicBrainz::Script::SubscriptionEmails;
use Moose;
use namespace::autoclean;

use List::Util qw( max );
use Moose::Util qw( does_role );
use MusicBrainz::Server::Types qw( :edit_status );

use aliased 'MusicBrainz::Server::Entity::Role::Subscription::Delete' => 'DeleteRole';
use aliased 'MusicBrainz::Server::Entity::Role::Subscription::Merge' => 'MergeRole';

with 'MooseX::Runnable';
with 'MooseX::Getopt';
with 'MusicBrainz::Script::Role::Context';

has 'verbose' => (
    isa => 'Bool',
    is => 'ro',
    default => sub { -t },
);

has 'dry_run' => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
);

sub run {
    my ($self, @args) = @_;
    die "Usage error ($0 takes no arguments)" if @args;

    my @editors = $self->c->model('Editor')->editors_with_subscriptions;
    for my $editor (@editors) {
        my @artist_subscriptions = $self->c->model('Artist')->subscription
            ->get_subscriptions($editor->id);
        
        my @label_subscriptions = $self->c->model('Label')->subscription
            ->get_subscriptions($editor->id);

        my @editor_subscriptions = $self->c->model('Editor')->subscription
            ->get_subscriptions($editor->id);

        my @subscriptions = (
            @artist_subscriptions,
            @label_subscriptions,
            @editor_subscriptions
        );

        next unless @subscriptions;

        unless ($editor->has_confirmed_email_address) {
            # Instead of returning here, we just empty the list of subscriptions.
            # Thus we don't go to all the trouble of looking for edits, and
            # we don't send an e-mail, but we *do* update the "lastmodsent" values
            # for this user.

            @artist_subscriptions =
            @label_subscriptions =
            @editor_subscriptions = ();
        }

        my (%deletions, %merges, %edits);
        for my $sub (@subscriptions) {
            if (deleted($sub)) {
                $deletions{ $sub->type } ||= [];
                push @{ $deletions{ $sub->type } }, $sub;
                $self->c->model('Artist')->subscriptions->delete($sub->id);
            }
            elsif (merged($sub)) {
                $merges{ $sub->type } ||= [];
                push @{ $merges{ $sub->type } }, $sub;
                $self->c->model('Artist')->subscriptions->delete($sub->id);
            }
            else {
                my @edits = $self->c->model('Edit')->find_for_subscription($sub);
                next unless @edits;

                my $open_count = grep { $_->is_open } @edits;
                my $applied_count = grep { $_->status == $STATUS_APPLIED } @edits;

                my $latest_edit = max map { $_->id } @edits;
                $self->c->model('Artist')->subscription->update_last_edit_sent(
                    $editor->id, $sub->artist_id, $latest_edit);

                $edits{ $sub->type } ||= [];
                push @{ $edits{ $sub->type } }, {
                    open => $open_count,
                    applied => $applied_count
                };
            }
        }
    }
}

sub deleted
{
    my $sub = shift;
    return does_role($sub, DeleteRole) && $sub->deleted_by_edit;
}

sub merged
{
    my $sub = shift;
    return does_role($sub, MergeRole) && $sub->merged_by_edit;
}

1;
