package MusicBrainz::Script::Role::IncrementalDump;

use strict;
use warnings;

use Moose::Role;
use MusicBrainz::Server::Replication qw( REPLICATION_ACCESS_URI );
use Parallel::ForkManager 0.7.6;

with 'MusicBrainz::Server::Role::FollowForeignKeys';

requires qw(
    database
    dump_schema
    dumped_entity_types
    should_follow_table
);

has replication_access_uri => (
    is => 'ro',
    isa => 'Str',
    default => REPLICATION_ACCESS_URI,
    traits => ['Getopt'],
    cmd_flag => 'replication-access-uri',
    documentation => 'URI to request replication packets from (default: https://metabrainz.org/api/musicbrainz)',
);

has worker_count => (
    is => 'ro',
    isa => 'Int',
    default => 1,
    traits => ['Getopt'],
    cmd_flag => 'worker-count',
    documentation => 'number of worker processes to use (default: 1)',
);

has pm => (
    is => 'ro',
    isa => 'Parallel::ForkManager',
    lazy => 1,
    default => sub {
        Parallel::ForkManager->new(shift->worker_count);
    },
    traits => ['NoGetopt'],
);

sub should_fetch_document($$) {
    my ($self, $schema, $table) = @_;

    return $schema eq 'musicbrainz' &&
        (grep { $_ eq $table } @{ $self->dumped_entity_types });
}

sub should_follow_primary_key($) {
    my $pk = shift;

    # Nothing in mbserver should update an artist_credit row on its own; we
    # treat them as immutable using a find_or_insert method. (It's possible
    # an upgrade script changed them, but that's unlikely.)
    return 0 if $pk eq 'musicbrainz.artist_credit.id';

    # Useless joins.
    return 0 if $pk eq 'musicbrainz.artist_credit_name.position';
    return 0 if $pk eq 'musicbrainz.release_country.country';
    return 0 if $pk eq 'musicbrainz.release_group_secondary_type_join.secondary_type';
    return 0 if $pk eq 'musicbrainz.work_language.language';
    return 0 if $pk eq 'musicbrainz.medium.format';

    return 1;
}

around should_follow_foreign_key => sub {
    my ($orig, $self, $direction, $pk, $fk, $joins) = @_;

    return 0 unless $self->$orig($direction, $pk, $fk, $joins);

    return 0 unless $self->should_follow_table($fk->{schema} . '.' . $fk->{table});

    return 0 if $self->has_join($pk, $fk, $joins);

    $pk = get_ident($pk);
    $fk = get_ident($fk);

    # Modifications to a release_label don't affect the label.
    return 0 if $pk eq 'musicbrainz.release_label.label' && $fk eq 'musicbrainz.label.id';

    # Modifications to a track shouldn't affect a recording's JSON-LD.
    return 0 if $pk eq 'musicbrainz.track.recording' && $fk eq 'musicbrainz.recording.id';

    # Modifications to artist credits don't affect the linked artists.
    if ($fk eq 'musicbrainz.artist_credit.id') {
        return 0 if $pk eq 'musicbrainz.alternative_release.artist_credit';
        return 0 if $pk eq 'musicbrainz.alternative_track.artist_credit';
        return 0 if $pk eq 'musicbrainz.recording.artist_credit';
        return 0 if $pk eq 'musicbrainz.release.artist_credit';
        return 0 if $pk eq 'musicbrainz.release_group.artist_credit';
        return 0 if $pk eq 'musicbrainz.track.artist_credit';
    }

    return 1;
};

no Moose::Role;

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
