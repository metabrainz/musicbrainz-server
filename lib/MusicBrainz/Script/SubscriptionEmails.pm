package MusicBrainz::Script::SubscriptionEmails;
use Moose;
use namespace::autoclean;

use English;
use Readonly;
use Moose::Util qw( does_role );
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::Translation qw( get_collator );

use aliased 'MusicBrainz::Server::Email';
use aliased 'MusicBrainz::Server::Entity::Subscription::Artist' => 'ArtistSubscription';
use aliased 'MusicBrainz::Server::Entity::CollectionSubscription';
use aliased 'MusicBrainz::Server::Entity::EditorSubscription';
use aliased 'MusicBrainz::Server::Entity::Subscription::Label' => 'LabelSubscription';
use aliased 'MusicBrainz::Server::Entity::Subscription::Series' => 'SeriesSubscription';

use aliased 'MusicBrainz::Server::Entity::Subscription::Active' => 'ActiveRole';
use aliased 'MusicBrainz::Server::Entity::Subscription::Deleted' => 'DeleteRole';

with 'MooseX::Runnable';
with 'MooseX::Getopt';
with 'MusicBrainz::Script::Role::Context';

Readonly our $BATCH_SIZE => 1000;

has 'verbose' => (
    isa => 'Bool',
    is => 'ro',
    default => sub { -t },
);

has 'dry_run' => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
    traits => [ 'Getopt' ],
    cmd_flag => 'dry-run',
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
        cached => 'exists',
        cached_edits => 'get',
        cache_edits => 'set',
        remove_from_cache => 'delete',
    }
);

has cache_usage => (
    is => 'ro',
    default => sub { {} },
    traits => [ 'Hash', 'NoGetopt' ],
    handles => {
        used_again => 'delete',
        not_reused_cache_items => 'keys',
        reset_cache_usage => 'clear',
    }
);

sub first_used {
    my ($self, $key) = @_;
    ${ $self->cache_usage }{$key} = 1;
}

sub _build_emailer {
    my $self = shift;
    return Email->new(c => $self->c);
}

sub run {
    my ($self, @args) = @_;
    die "Usage error ($PROGRAM_NAME takes no arguments)" if @args;

    my $collator = get_collator('root');
        # plain UCA without language-specific tailoring

    my $max = $self->c->model('Edit')->get_max_id;
    my $seen = 0;
    my $count;
    do {
        my @editors = $self->c->model('Editor')->editors_with_subscriptions($seen, $BATCH_SIZE);
        $count = @editors;
        printf "Starting batch with %d editors\n\n", $count if $self->verbose;

        while (my $editor = shift @editors) {
            $seen = $editor->id;
            my $period = $editor->preferences->subscriptions_email_period;
            printf "Processing subscriptions for '%s' (%s)\n", $editor->name, $period
                if $self->verbose;

            next if $period eq 'weekly' && !$self->weekly;

            unless ($period eq 'never') {
                my @subscriptions = $self->c->model('EditorSubscriptions')
                    ->get_all_subscriptions($editor->id);
                printf "... found %d subscriptions\n", scalar @subscriptions if $self->verbose;


                if (my $data = $self->extract_subscription_data(@subscriptions)) {
                    if ($editor->has_confirmed_email_address) {
                        unless ($self->dry_run) {
                            printf "... sending email\n" if $self->verbose;
                            $self->emailer->send_subscriptions_digest(
                                editor => $editor,
                                collator => $collator,
                                %$data
                            );
                        } else { printf "... not sending email (dry run)\n" if $self->verbose; }
                    } else { printf "... no verified email address, not sending\n" if $self->verbose; }
                } else { printf "... no current edits found\n" if $self->verbose; }

            }

            unless ($self->dry_run) {
                printf "... updating subscriptions\n" if $self->verbose;
                $self->c->model('EditorSubscriptions')
                    ->update_subscriptions($max, $editor->id);
            }

            printf "\n" if $self->verbose;
        }

        if ($self->verbose) {
            printf "End of batch: removing %d entities from the cache (out of %d)\n\n",
                scalar $self->not_reused_cache_items, scalar keys %{ $self->edit_cache };
        }
        $self->remove_from_cache($self->not_reused_cache_items);
        $self->reset_cache_usage;
    } while ($count == $BATCH_SIZE);

    printf "Completed.\n" if $self->verbose;
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
        if (has_edits($sub)) {
            my $filter;
            $filter = sub { $_->editor_id != $sub->editor_id }
                unless $sub->isa(EditorSubscription);
            my @edits = $self->_edits_for_subscription($sub, $filter);

            next unless @edits;

            my @open = grep { $_->is_open } @edits;
            my @applied = grep { $_->status == $STATUS_APPLIED } @edits;

            $self->load_subscription($sub);

            push @{ $edits{ $sub->type } }, {
                open => \@open,
                applied => \@applied,
                subscription => $sub
            };
        }
        else {
            push @deletions, $sub;
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
    elsif ($subscription->isa(SeriesSubscription)) {
        $self->c->model('Series')->load($subscription);
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

sub has_edits
{
    my $sub = shift;
    return (
        does_role($sub, ActiveRole) ||
        ($sub->isa(CollectionSubscription) && $sub->available)
    );
}

sub _edits_for_subscription {
    my ($self, $sub, $filter) = @_;

    my $cache_key = ref($sub) . ': ' .
        join(', ', $sub->target_id, $sub->last_edit_sent);

    my @edits;
    if ($self->cached($cache_key)) {
        @edits = @{ $self->cached_edits($cache_key) };
        $self->used_again($cache_key);
    } else {
        @edits = $self->c->model('Edit')->find_for_subscription($sub);
        $self->cache_edits($cache_key => \@edits);
        $self->first_used($cache_key);
    }

    return @edits unless $filter;
    return grep { $filter->($_) } @edits;
}

1;
