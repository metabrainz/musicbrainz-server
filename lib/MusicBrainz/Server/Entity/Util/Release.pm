package MusicBrainz::Server::Entity::Util::Release;

use strict;
use warnings;

use Sub::Exporter -setup => { exports => [qw(
    group_by_release_status
    group_by_release_status_nested
)] };

use List::AllUtils qw( nsort_by partition_by );

=func group_by_release_status_nested

Given a list, and a function to extract MusicBrainz::Server::Entity::Release
objects from each element in the list, return the list sorted by release status
ID ascending, with entries where the release has no status at the tail of the
list.

=cut

sub group_by_release_status_nested (&@) {
    my ($accessor, @releases) = @_;
    my %grouped = partition_by { $accessor->($_)->status_name // '' } @releases;
    return [
        nsort_by { $accessor->($_->[0])->status_id || '100' } values %grouped
    ]
}

=func group_by_release_status

Given a list of releases, return a list of releases, sorted by release status ID
ascending, with releases that have no status at the tail of the list.

=cut

sub group_by_release_status {
    group_by_release_status_nested { shift } @_;
}

1;
