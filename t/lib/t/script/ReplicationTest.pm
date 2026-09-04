package t::script::ReplicationTest;

use strict;
use warnings;

use File::Spec;
use File::Temp qw( tempdir );
use Moose;

use DBDefs;
use MusicBrainz::Server::Context;
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';

has master_c => (
    isa => 'MusicBrainz::Server::Context',
    is => 'ro',
    lazy => 1,
    default => sub {
        MusicBrainz::Server::Context->create_script_context(
            database => 'TEST_MASTER',
        );
    },
);

has mirror_c => (
    isa => 'MusicBrainz::Server::Context',
    is => 'ro',
    lazy => 1,
    default => sub {
        MusicBrainz::Server::Context->create_script_context(
            database => 'TEST_MIRROR',
        );
    },
);

has output_dir => (
    isa => 'Str',
    is => 'ro',
    lazy => 1,
    default => sub {
        tempdir('t-dbmirror2-XXXXXXXX', DIR => '/tmp', CLEANUP => 1);
    },
);

sub BUILD {
    my ($self) = @_;

    my $root = DBDefs->MB_SERVER_ROOT;

    $ENV{REPLICATION_TYPE} = 1;
    system(
        File::Spec->catfile($root, 'script/create_test_db.sh'),
        'TEST_MASTER',
    );

    $ENV{REPLICATION_TYPE} = 2;
    system(
        File::Spec->catfile($root, 'script/create_test_db.sh'),
        'TEST_MIRROR',
    );

    delete $ENV{REPLICATION_TYPE};

    my $schema_seq = DBDefs->DB_SCHEMA_SEQUENCE;
    my $replication_control_query = <<~"SQL";
        BEGIN;
        INSERT INTO replication_control
                (current_schema_sequence,
                 current_replication_sequence,
                 last_replication_date)
             VALUES ($schema_seq, 1, '2021-10-01 01:01:01.123456+00');
        TRUNCATE dbmirror_pending CASCADE;
        TRUNCATE dbmirror_pendingdata CASCADE;
        TRUNCATE dbmirror2.pending_keys CASCADE;
        TRUNCATE dbmirror2.pending_data CASCADE;
        TRUNCATE dbmirror2.pending_ts CASCADE;
        COMMIT;
        SQL
    $self->master_c->sql->auto_commit;
    $self->master_c->sql->do($replication_control_query);
    $self->mirror_c->sql->auto_commit;
    $self->mirror_c->sql->do($replication_control_query);
}

sub export_all_tables {
    my ($self, @args) = @_;
    system (
        File::Spec->catfile(DBDefs->MB_SERVER_ROOT, 'admin/ExportAllTables'),
        '--output-dir', $self->output_dir,
        '--database', 'TEST_MASTER',
        '--compress',
        @args,
    );
    my $current_replication_sequence =
        $self->master_c->sql->select_single_value(<<~'SQL');
            SELECT current_replication_sequence FROM replication_control;
            SQL
    open(my $fh, '>',
         File::Spec->catfile($self->output_dir, 'replication-info'));
    print $fh <<~"JSON";
        {"last_packet": "replication-$current_replication_sequence.tar.bz2"}
        JSON
    close $fh;
}

sub load_replication_changes {
    my ($self, @args) = @_;
    system (
        File::Spec->catfile(
            DBDefs->MB_SERVER_ROOT,
            'admin/replication/LoadReplicationChanges',
        ),
        '--base-uri', 'file://' . $self->output_dir,
        '--database', 'TEST_MIRROR',
        '--lockfile', '/tmp/.mb-LoadReplicationChanges-TEST_MIRROR',
        @args,
    );
}

no Moose;

1;
