package MusicBrainz::Script::JSONDump::Full;

use strict;
use warnings;

use DBDefs;
use File::Spec::Functions qw( catfile );
use List::AllUtils qw( min );
use Moose;
use Parallel::ForkManager 0.7.6;
use POSIX qw( :signal_h :errno_h :sys_wait_h ceil );

use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Log qw( log_info );
use Sql;

extends 'MusicBrainz::Script::JSONDump';

with 'MooseX::Runnable';

has force_update_entity_types => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub { [] },
    traits => ['Array', 'Getopt'],
    cmd_flag => 'force-update',
    documentation => ('force-update entities of this type in its ' .
                      'json_dump.${entity}_json table; by default, ' .
                      q(entities are only inserted where they don't ) .
                      'exist, and updates are done by the incremental ' .
                      'dump only. can specify multiple of this flag ' .
                      '(default: no force-updates)'),
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

our $TMP_EXPORT_DIR = $MusicBrainz::Script::JSONDump::TMP_EXPORT_DIR;

our $WORKER_BATCH_SIZE = 10000;

sub do_batch {
    my ($self, $c, $entity_type, $batch_number, $max_id,
        $replication_sequence) = @_;

    my $dump_fpath = catfile(
        $TMP_EXPORT_DIR, $ENTITIES{$entity_type}{url});

    my $entities_json_callback = sub {
        my ($entities_json) = @_;

        $self->write_json($dump_fpath, [values %{$entities_json}]);
    };

    my $gt_id = ($WORKER_BATCH_SIZE * $batch_number);
    my $lte_id = min $max_id, ($WORKER_BATCH_SIZE * ($batch_number + 1));

    return if $lte_id <= $gt_id;

    my %extra_options = (
        is_full_dump => 1,
        gt_id => $gt_id,
        lte_id => $lte_id,
        force_update => $self->force_update_entity_types,
    );

    $self->fetch_entities_json(
        $c, $entity_type, $replication_sequence, undef,
        $entities_json_callback, %extra_options);
}

sub run_impl {
    my ($self, $c) = @_;

    my $dump_replication_sequence;
    my %entity_max_ids;

    my @dumped_entity_types = @{ $self->dumped_entity_types };
    @dumped_entity_types = sort @dumped_entity_types;

    $self->with_incremental_dump_lock(sub {
        my $control = $c->sql->select_single_row_hash(
            'SELECT * FROM json_dump.control LIMIT 1'
        );

        if ($control) {
            $dump_replication_sequence = $control->{last_processed_replication_sequence};
        } else {
            $c->sql->auto_commit(1);
            $c->sql->do('INSERT INTO json_dump.control VALUES (NULL)');
        }

        unless (defined $dump_replication_sequence) {
            my $replication_control = $c->sql->select_single_row_hash(
                'SELECT * FROM replication_control LIMIT 1'
            );
            $dump_replication_sequence = $replication_control->{current_replication_sequence};
        }

        unless (defined $dump_replication_sequence) {
            die q(Couldn't determine which replication sequence to dump. ) .
                'Is the replication_control table empty?';
        }

        # We can't dump entities with row IDs that exceed the current max ID,
        # because they'll logically be from a later replication sequence. Get
        # these values while we have the incremental dump lock and know
        # replication is paused.
        for my $entity_type (@dumped_entity_types) {
            $entity_max_ids{$entity_type} = $c->sql->select_single_value(
                'SELECT max(id) FROM ' . $entity_type) // 0;
        }
    });

    log_info { 'Clearing the entity cache' };
    $c->cache->clear;

    log_info { 'Dumping JSON for the following entity types: ' .
               join(', ', @dumped_entity_types) };

    for my $entity_type (@dumped_entity_types) {
        log_info { "Dumping $entity_type JSON" };

        my $max_id = $entity_max_ids{$entity_type};
        my $batch_count = ceil($max_id / $WORKER_BATCH_SIZE) + 1;

        for (my $i = 0; $i < $batch_count; $i++) {
            $self->pm->start and next;

            my $new_c = MusicBrainz::Server::Context->create_script_context(
                database => $self->database,
                fresh_connector => 1,
            );

            $self->do_batch($new_c, $entity_type, $i, $max_id,
                            $dump_replication_sequence);

            $new_c->connector->disconnect;

            log_info { 'Dumped batch ' . ($i + 1) . "/$batch_count" };
            $self->pm->finish; # The child exits here.
        }

        $self->pm->wait_all_children;

        $self->create_json_dump(
            $c,
            $entity_type,
            replication_sequence => $dump_replication_sequence,
        );
    }

    if ($self->compression_enabled) {
        log_info { 'Writing checksum files' };
        MusicBrainz::Script::MBDump::write_checksum_files('xz', $self->output_dir);
    }

    log_info { 'Updating full_json_dump_replication_sequence to ' .
               $dump_replication_sequence };
    $c->sql->auto_commit(1);
    $c->sql->do(<<'SQL', $dump_replication_sequence);
        UPDATE json_dump.control
           SET full_json_dump_replication_sequence = ?
SQL

    log_info { 'Deleting JSON for deleted entities' };
    for my $entity_type (@dumped_entity_types) {
        Sql::run_in_transaction(sub {
            $c->sql->do(qq{
                DELETE FROM json_dump.${entity_type}_json
                 WHERE id IN (SELECT id
                                FROM json_dump.deleted_entities
                               WHERE entity_type = ?
                                 AND replication_sequence <= ?)
            }, $entity_type, $dump_replication_sequence);

            $c->sql->do(q{
                DELETE FROM json_dump.deleted_entities
                 WHERE entity_type = ?
                   AND replication_sequence <= ?
            }, $entity_type, $dump_replication_sequence);
        }, $c->sql);
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
