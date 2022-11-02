package MusicBrainz::Script::RemoveExpiredSessions;

=head1 DESCRIPTION

This is a cleanup script related to MBS-8692. It removes all Catalyst
"expires" session keys for which the expire time (stored as the value) is in
the past. For the other session sub-keys used by Catalyst, namely "session"
and "flash", cleanup is not necessary because they already had their Redis
expire time set correctly.

The base issue for "expires" keys is now also fixed, so it should not be
necessary to re-run this script.

=cut

use Moose;
use namespace::autoclean;

use English;
use POSIX qw( ceil );

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
    traits => [ 'Getopt' ],
    cmd_flag => 'dry-run',
);

has 'batch_size' => (
    isa => 'Int',
    is => 'ro',
    default => 10000,
    traits => [ 'Getopt' ],
    cmd_flag => 'batch-size',
);

sub run {
    my ($self, @args) = @_;
    die "Usage error ($PROGRAM_NAME takes no arguments)" if @args;

    my $store = $self->c->store;
    my $r = $store->_connection;
    my $now = time + 5; # five seconds grace period for server differences

    printf qq(Fetching entries from database; prefix used is "%s".\n), $store->_namespace if $self->verbose;
    my @keys = $r->_connection->keys($store->_namespace . 'expires:*');
        # KEYS is very heavy, but our current Redis doesn't have SCAN
    my $considered = scalar @keys;
    if ($considered == 0) {
        print "WARNING: No sessions found.\n";
        return 0;
    }
    printf "Retrieved %d keys.\n", $considered if $self->verbose;

    unless ($considered < $self->batch_size) {
        printf "Processing in %d batches.\n\n", ceil($considered/$self->batch_size) if $self->verbose;
    }

    my $total_expired = 0;

    while (scalar @keys) {
        my @batch_keys = splice @keys, 0, $self->batch_size;
        my $size = scalar @batch_keys;

        my @values = $r->_connection->mget(@batch_keys);
        printf "Retrieved %d values.\n", scalar @values if $self->verbose;

        scalar @values == $size or die 'Number of values from the database does not match keys';

        my @remove;
        while (my $key = shift @batch_keys) {
            my $expire_time = shift @values;
            push @remove, $key
                if $expire_time < $now;
        }
        my $expired = scalar @remove;
        $total_expired += $expired;

        if ($expired && !$self->dry_run) {
            print 'Deleting expired entries ...' if $self->verbose;
            my $deleted = $r->_connection->del(@remove);
            printf " deleted %d entries.\n", $deleted if $self->verbose;
            $deleted == $expired
                or printf "WARNING: Wanted to delete %d entries, but actually deleted %d!\n",
                          $expired, $deleted;
            print "\n" if $self->verbose;
        }
    }

    printf "Found %d of %d entries to be expired (%.2f %%).\n",
            $total_expired, $considered, (100 * $total_expired / $considered)
        if $self->verbose;

    print "Finished.\n" if $self->verbose;
    return 0;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 Ulrich Klauer

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
