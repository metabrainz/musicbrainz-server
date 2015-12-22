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

sub run {
    my ($self, @args) = @_;
    die "Usage error ($0 takes no arguments)" if @args;

    my $r = $self->c->redis;
    my $now = time + 5; # five seconds grace period for server differences

    printf "Fetching entries from database; prefix used is \"%s\".\n", $r->prefix if $self->verbose;
    my @keys = $r->_connection->keys($r->prefix . "expires:*");
        # KEYS is very heavy, but our current Redis doesn't have SCAN
    my $considered = scalar @keys;
    if ($considered == 0) {
        print "WARNING: No sessions found.\n";
        return 0;
    }
    printf 'Retrieved %d keys,', $considered if $self->verbose;
    my @values = $r->_connection->mget(@keys);
    printf " %d values.\n", scalar @values if $self->verbose;

    scalar @values == $considered or die 'Number of values from the database does not match keys';

    my @remove;
    while (my $key = shift @keys) {
        my $expire_time = shift @values;
        push @remove, $key
            if $expire_time < $now;
    }
    my $to_be_removed = scalar @remove;
    printf "Found %d of the entries to be expired (%.2f %%).\n",
            $to_be_removed, (100 * $to_be_removed / $considered)
        if $self->verbose;

    if ($to_be_removed && !$self->dry_run) {
        print 'Deleting expired entries ...' if $self->verbose;
        my $deleted = $r->_connection->del(@remove);
        printf " deleted %d entries.\n", $deleted if $self->verbose;
        $deleted == $to_be_removed
            or printf "WARNING: Wanted to delete %d entries, but actually deleted %d!\n", $to_be_removed, $deleted;
    }

    print "Finished.\n" if $self->verbose;
    return 0;
}

1;

=head1 COPYRIGHT

Copyright (C) 2015 Ulrich Klauer

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
MA 02110-1301, USA.

=cut
