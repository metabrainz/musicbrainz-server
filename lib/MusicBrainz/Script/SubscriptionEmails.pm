package MusicBrainz::Script::SubscriptionEmails;
use Moose;
use namespace::autoclean;

use List::Util qw( max );
use Moose::Util qw( does_role );
use MusicBrainz::Server::Constants qw( :edit_status );

use aliased 'MusicBrainz::Server::Email';
use aliased 'MusicBrainz::Server::Entity::ArtistSubscription';
use aliased 'MusicBrainz::Server::Entity::CollectionSubscription';
use aliased 'MusicBrainz::Server::Entity::EditorSubscription';
use aliased 'MusicBrainz::Server::Entity::LabelSubscription';
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

has 'weekly' => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
);

has 'emailer' => (
    is => 'ro',
    required => 1,
    lazy_build => 1,
    traits   => [ 'NoGetopt' ],
);

has edit_cache => (
    is => 'ro',
    default => sub { {} },
    traits => [ 'Hash', 'NoGetopt' ],
    handles => {
        cached_edits => 'get',
        cache_edits => 'set'
    }
);

sub _build_emailer {
    my $self = shift;
    return Email->new(c => $self->c);
}

sub run {
    my ($self, @args) = @_;
    die "Usage error ($0 takes no arguments)" if @args;

    my $max = $self->c->model('Edit')->get_max_id;
    my @editors = $self->c->model('Editor')->editors_with_subscriptions();

    for my $editor (@editors) {
        my $period = $editor->preferences->subscriptions_email_period;
        printf "Processing subscriptions for '%s' (%s)\n", $editor->name, $period
            if $self->verbose;

        next if $period eq 'weekly' and !$self->weekly;

        unless ($period eq 'never') {

            my @subscriptions = $self->c->model('EditorSubscriptions')
                ->get_all_subscriptions($editor->id);

            if (my $data = $self->extract_subscription_data(@subscriptions)) {
                unless ($self->dry_run) {
                    if ($editor->has_confirmed_email_address) {
                        printf "... sending email\n" if $self->verbose;
                        $self->emailer->send_subscriptions_digest(
                            editor => $editor,
                            %$data
                        );
                    }
                }
            }

        }

        unless ($self->dry_run) {
            printf "... updating subscriptions\n" if $self->verbose;
            $self->c->model('EditorSubscriptions')
                ->update_subscriptions($max, $editor->id);
        }

        printf "\n" if $self->verbose;
    }

    return 0;
}

=head2 extract_subscription_data

Extract the data from subscriptions into a form that can be used by
a template.

=cut

sub extract_subscription_data
{
    my ($self, @subscriptions) = @_;
    my (@deletions, %edits);
    for my $sub (@subscriptions) {
        if (deleted($sub)) {
            push @deletions, $sub;
        }
        else {
            my $filter;
            $filter = sub { $_->editor_id != $sub->editor_id }
                unless $sub->isa(EditorSubscription);
            my @edits = $self->_edits_for_subscription($sub, $filter);

            next unless @edits;

            my @open = grep { $_->is_open } @edits;
            my @applied = grep { $_->status == $STATUS_APPLIED } @edits;

            $self->load_subscription($sub);

            $edits{ $sub->type } ||= [];
            push @{ $edits{ $sub->type } }, {
                open => \@open,
                applied => \@applied,
                subscription => $sub
            };
        }
    }

    my %data;
    $data{deletes} = \@deletions if @deletions;
    $data{edits} = \%edits if %edits;

    return %data ? \%data : undef;
}

sub load_subscription
{
    my ($self, $subscription) = @_;
    if ($subscription->isa(ArtistSubscription)) {
        $self->c->model('Artist')->load($subscription);
    }
    elsif ($subscription->isa(LabelSubscription)) {
        $self->c->model('Label')->load($subscription);
    }
    elsif ($subscription->isa(CollectionSubscription)) {
        $self->c->model('Collection')->load($subscription);
    }
    elsif ($subscription->isa(EditorSubscription)) {
        $subscription->subscribed_editor(
            $self->c->model('Editor')->get_by_id(
                $subscription->subscribed_editor_id));
    }
}

sub deleted
{
    my $sub = shift;
    return (does_role($sub, DeleteRole) && $sub->deleted_by_edit) ||
           (does_role($sub, MergeRole) && $sub->merged_by_edit) ||
           ($sub->isa(CollectionSubscription) && !$sub->available);
}

sub _edits_for_subscription {
    my ($self, $sub, $filter) = @_;
    my $cache_key = ref($sub) . ': ' .
        join(', ', $sub->target_id, $sub->last_edit_sent);
    return grep { $filter ? $filter->($_) : 1 } @{
        $self->cached_edits($cache_key) ||
        do {
            $self->cache_edits(
                $cache_key => [
                    $self->c->model('Edit')->find_for_subscription($sub)
                ]
            );
        }
    };
}

1;
