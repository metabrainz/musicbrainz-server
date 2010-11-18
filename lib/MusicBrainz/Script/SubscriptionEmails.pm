package MusicBrainz::Script::SubscriptionEmails;
use Moose;
use namespace::autoclean;

use List::Util qw( max );
use Moose::Util qw( does_role );
use MusicBrainz::Server::Types qw( :edit_status );

use aliased 'MusicBrainz::Server::Email';
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

has 'emailer' => (
    is => 'ro',
    required => 1,
    lazy_build => 1
);

sub _build_emailer { 
    my $self = shift;
    return Email->new(c => $self->c);
}

sub run {
    my ($self, @args) = @_;
    die "Usage error ($0 takes no arguments)" if @args;

    my $max = $self->c->model('Edit')->get_max_id;
    my @editors = $self->c->model('Editor')->editors_with_subscriptions;

    for my $editor (@editors) {
        printf "Processing subscriptions for '%s'\n", $editor->name
            if $self->verbose;

        my @subscriptions = $self->c->model('EditorSubscriptions')
            ->get_all_subscriptions($editor->id) or next;

        if ($editor->has_confirmed_email_address) {
            printf "... sending email\n" if $self->verbose;
            if(my $data = $self->extract_subscription_data(@subscriptions)) {
                $self->emailer->send_subscriptions_digest(
                    to => $editor,
                    %$data
                );
            }
        }

        unless ($self->dry_run) {
            printf "... updating subscriptions\n" if $self->verbose;
            $self->c->model('EditorSubscriptions')
                ->update_subscriptions($max, $editor->id);

            my @delete = grep { deleted($_) || merged($_) } @subscriptions;
            $self->c->model('EditorSubscriptions') ->delete(@delete) if @delete;
        }

        printf "\n";
    }
}

=head2 extract_subscription_data

Extract the data from subscriptions into a form that can be used by
a template.

=cut

sub extract_subscription_data
{
    my ($self, @subscriptions) = @_;
    my (%deletions, %merges, %edits);
    for my $sub (@subscriptions) {
        if (deleted($sub)) {
            $deletions{ $sub->type } ||= [];
            push @{ $deletions{ $sub->type } }, $sub;
        }
        elsif (merged($sub)) {
            $merges{ $sub->type } ||= [];
            push @{ $merges{ $sub->type } }, $sub;
        }
        else {
            my @edits = $self->c->model('Edit')->find_for_subscription($sub);
            next unless @edits;

            my @open = grep { $_->is_open } @edits;
            my @applied = grep { $_->status == $STATUS_APPLIED } @edits;

            $edits{ $sub->type } ||= [];
            push @{ $edits{ $sub->type } }, {
                open => \@open,
                applied => \@applied,
                subscription => $sub
            };
        }
    }

    my %data;
    $data{deletes} = \%deletions if %deletions;
    $data{merges} = \%merges if %merges;
    $data{edits} = \%edits if %edits;

    return %data ? \%data : undef;
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
