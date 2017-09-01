package MusicBrainz::Script::Role::IncrementalDump;

use strict;
use warnings;

use DBDefs;
use Moose::Role;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Replication qw( REPLICATION_ACCESS_URI );
use Parallel::ForkManager 0.7.6;
use Try::Tiny;

with 'MusicBrainz::Server::Role::FollowForeignKeys';

requires qw(
    build_and_check_urls
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

# Declaration silences "called too early to check prototype" from recursive call.
sub follow_foreign_key($$$$$$);

sub follow_foreign_key($$$$$$) {
    my $self = shift;

    my ($c, $direction, $pk_schema, $pk_table, $update, $joins) = @_;

    if ($self->should_fetch_document($pk_schema, $pk_table)) {
        $self->pm->start and return;

        # This should be refreshed for each new worker, as internal DBI handles
        # would otherwise be shared across processes (and are not advertized as
        # MPSAFE).
        my $new_c = MusicBrainz::Server::Context->create_script_context(
            database => $self->database,
            fresh_connector => 1,
        );
        $new_c->lwp->timeout(DBDefs->DETERMINE_MAX_REQUEST_TIME // 60);

        my ($exit_code, $shared_data, @args) = (1, undef, @_);
        try {
            # Returns 1 if any updates occurred.
            if ($self->build_and_check_urls($new_c, $pk_schema, $pk_table, $update, $joins)) {
                $exit_code = 0;
                shift @args;
                $shared_data = \@args;
            }
        } catch {
            $exit_code = 2;
            $shared_data = {error => "$_"};
        };

        $new_c->connector->disconnect;
        $self->pm->finish($exit_code, $shared_data);
    } else {
        $self->follow_foreign_keys(@_);
    }
}

no Moose::Role;

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
