package MusicBrainz::Script::JSONDump::Incremental;

use strict;
use warnings;
use feature 'state';

use DBDefs;
use File::Spec::Functions qw( catdir catfile );
use JSON::XS;
use Moose;

use MusicBrainz::Script::Utils qw( log );
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Context;

extends 'MusicBrainz::Script::JSONDump';

with 'MooseX::Runnable';

with 'MusicBrainz::Script::Role::IncrementalDump';

our $TMP_EXPORT_DIR = $MusicBrainz::Script::JSONDump::TMP_EXPORT_DIR;

sub dump_schema { 'json_dump' }

sub get_changed_documents {
    my ($self, $c, $entity_type, $ids, $update) = @_;

    my ($last_modified, $replication_sequence) =
        @{$update}{qw( last_modified replication_sequence )};

    my $total_changed = 0;

    my $entities_json_callback = sub {
        my ($entities_json) = @_;

        my $table = "json_dump.${entity_type}_json";
        # Get entities which have different JSON from the previous
        # replication sequence, or which didn't exist at that sequence.
        my $query = <<"SQL";
            SELECT t1.id
              FROM $table t1
              LEFT JOIN $table t2
                     ON (t2.id = t1.id
                         AND t2.replication_sequence = (\$1 - 1))
             WHERE t1.id = any(\$2)
               AND t1.replication_sequence = \$1
               AND (t2.json IS NULL OR t1.json != t2.json)
            ORDER BY t1.id ASC
SQL

        my @ids = keys %{$entities_json};
        my $changed_ids = $c->sql->select_single_column_array(
            $query, $replication_sequence, \@ids);
        my $changed = scalar @{$changed_ids};

        log("Found $changed new or changed entities for replication " .
            "sequence $replication_sequence in table $entity_type");

        if ($changed) {
            $total_changed += $changed;
            my @changed_documents = map { $entities_json->{$_} } @{$changed_ids};
            my $dump_path = catfile(
                $TMP_EXPORT_DIR, $ENTITIES{$entity_type}{url});
            $self->write_json($dump_path, \@changed_documents);
        }
    };

    $self->fetch_entities_json(
        $c, $entity_type, $replication_sequence, $last_modified,
        $entities_json_callback, ids => $ids, is_full_dump => 0);

    return $total_changed;
}

sub handle_update_path($$$$) {
    my ($self, $c, $entity_type, $entity_rows, $fetch) = @_;

    my @ids = map { $_->{id} } @{$entity_rows};
    $fetch->(\@ids);
    return;
}

sub should_follow_table($) {
    my ($self, $table) = @_;

    return 0 if $table eq 'musicbrainz.area_type';
    return 0 if $table eq 'musicbrainz.artist_type';
    return 0 if $table eq 'musicbrainz.cdtoc';
    return 0 if $table eq 'musicbrainz.instrument_type';
    return 0 if $table eq 'musicbrainz.label_type';
    return 0 if $table eq 'musicbrainz.language';
    return 0 if $table eq 'musicbrainz.link_type';
    return 0 if $table eq 'musicbrainz.medium_index';
    return 0 if $table eq 'musicbrainz.place_type';
    return 0 if $table eq 'musicbrainz.release_group_primary_type';
    return 0 if $table eq 'musicbrainz.release_group_secondary_type';
    return 0 if $table eq 'musicbrainz.script';
    return 0 if $table eq 'musicbrainz.series_type';
    return 0 if $table eq 'musicbrainz.work_type';
    return 0 if $table eq 'musicbrainz.release_packaging';
    return 0 if $table eq 'musicbrainz.release_status';

    return 0 if $table =~ /_alias_type$/;
    return 0 if $table =~ /_attribute_type$/;
    return 0 if $table =~ /_gid_redirect$/;

    return 1;
}

sub post_replication_sequence { }

sub pre_key_traversal {
    my ($self, $c, $change, $data, $replication_sequence,
        $last_modified) = @_;

    return unless $self->should_fetch_document(
        $change->{schema}, $change->{table});

    if ($change->{operation} eq 'i') {
        $self->insert_entities_json(
            $c,
            $change->{table},
            $replication_sequence,
            $last_modified,
            [$data->{id}],
        );
    } elsif ($change->{operation} eq 'd') {
        $c->sql->auto_commit(1);
        $c->sql->do(<<"SQL", $data->{id}, $change->{table}, $replication_sequence);
            INSERT INTO json_dump.delete_entities
                (id, entity_type, replication_sequence)
            VALUES (?, ?, ?)
            ON CONFLICT DO NOTHING
SQL
    }
}

sub run_impl {
    my ($self, $c) = @_;

    my $full_replication_sequence = $c->sql->select_single_value(
        'SELECT full_json_dump_replication_sequence FROM json_dump.control');

    die q(The incremental script can't run until a full dump has run at least once.)
        unless defined $full_replication_sequence;

    $self->packet_limit(1);

    my $load_replication_changes = catfile(
        DBDefs->MB_SERVER_ROOT,
        'admin', 'replication', 'LoadReplicationChanges');

    while (1) {
        my $start_sequence;
        my $did_update_anything;

        $self->with_incremental_dump_lock(sub {
            $start_sequence = $c->sql->select_single_value(
                'SELECT last_processed_replication_sequence FROM json_dump.control');
            unless (defined $start_sequence) {
                $start_sequence = $full_replication_sequence;
            }
            $start_sequence++;

            my $current_replication_sequence = $c->sql->select_single_value(
                'SELECT current_replication_sequence FROM replication_control');

            if ($start_sequence == ($current_replication_sequence + 1)) {
                my @replicate_args = (
                    $load_replication_changes,
                   '--database', $self->database,
                   '--limit', '1'
                );

                if ($ENV{MUSICBRAINZ_RUNNING_TESTS}) {
                    push @replicate_args, (
                        '--lockfile',
                        '/tmp/.mb-LoadReplicationChanges-' . $self->database,
                    );
                }

                my $replication_uri = $self->replication_access_uri;
                if ($replication_uri) {
                    push @replicate_args, '--base-uri', $replication_uri;
                }

                if ($ENV{PERL_CARTON_PATH}) {
                    @replicate_args = (qw( carton exec -- ), @replicate_args);
                }

                system(@replicate_args) == 0
                    or die "Replication failed (exit code $?)";

                $current_replication_sequence = $c->sql->select_single_value(
                    'SELECT current_replication_sequence FROM replication_control');

                if ($start_sequence != $current_replication_sequence) {
                    log('Already reached the latest available packet');
                    return;
                }
            }

            die (
                'The next replication sequence to process does not equal ' .
                'the current_replication_sequence in the ' .
                'replication_control table.'
            ) if ($start_sequence != $current_replication_sequence);

            log('Clearing the entity cache');
            $c->cache->clear;

            log('Creating incremental JSON dumps for the following ' .
                'entity types: ' .
                join(', ', @{ $self->dumped_entity_types }));

            $did_update_anything = $self->run_incremental_dump(
                $c, $start_sequence);
        });

        if ($did_update_anything) {
            # Output each replication sequence in its own dir.
            my $output_dir = catdir(
                $self->output_dir, "json-dump-$start_sequence");

            for my $entity_type (@{ $self->dumped_entity_types }) {
                $self->create_json_dump(
                    $c,
                    $entity_type,
                    output_dir => $output_dir,
                    replication_sequence => $start_sequence,
                );
            }

            if ($self->compression_enabled) {
                log('Writing checksum files');
                MusicBrainz::Script::MBDump::write_checksum_files('xz', $output_dir);
            }
        } else {
            last;
        }
    }

    return 0;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
