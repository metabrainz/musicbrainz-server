package MusicBrainz::Script::SubscriptionEmails;
use Moose;
use namespace::autoclean;

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
    warn $self->dry_run;

    my @editors = $self->c->model('Editor')->editors_with_subscriptions;
    for my $editor (@editors) {
        my @artist_subscriptions = $self->c->model('Artist')->subscription
            ->get_subscriptions($editor->id);

        use Devel::Dwarn;
        Dwarn \@artist_subscriptions;
    }
}

1;
