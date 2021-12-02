package MusicBrainz::Script::DatabaseDump;

use Encode qw( encode );
use Fcntl qw( LOCK_EX );
use List::AllUtils qw( natatime );
use Moose;
use MusicBrainz::Script::Utils qw( log );
use Time::HiRes qw( gettimeofday tv_interval );

extends 'MusicBrainz::Script::MBDump';

has c => (
    handles => ['sql', 'dbh'],
    is => 'ro',
    isa => 'MusicBrainz::Server::Context',
    required => 1,
);

has row_counts => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);

has table_file_mapping => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);

has total_tables => (
    traits => ['Counter'],
    is => 'ro',
    isa => 'Int',
    default => 0,
    handles => {
        inc_total_tables => 'inc',
    },
);

has total_rows => (
    traits => ['Counter'],
    is => 'ro',
    isa => 'Int',
    default => 0,
    handles => {
        inc_total_rows => 'inc',
    },
);

has start_time => (
    is => 'rw',
    isa => 'Int',
);

has lock_fh => (
    is => 'rw',
    isa => 'Maybe[FileHandle]',
);

has isolation_level => (
    is => 'ro',
    isa => 'Str',
    default => 'SERIALIZABLE',
);

around begin_dump => sub {
    my ($orig, $self) = @_;

    $self->start_time(gettimeofday);

    # A quick discussion of the "Can't serialize access due to concurrent
    # update" problem. See "transaction-iso.html" in the Postgres
    # documentation. Basically the problem is this: export "A" starts; export
    # "B" starts; export "B" updates replication_control; export "A" then
    # can't update replication_control, failing with the above error. The
    # solution is to get a lock (outside of the database) before we start the
    # serializable transaction.
    open(my $lock_fh, '>>' . $self->tmp_dir . '/.mb-export-lock') or die $!;
    flock($lock_fh, LOCK_EX) or die $!;
    $self->lock_fh($lock_fh);

    my $sql = $self->sql;
    $sql->auto_commit;
    $sql->do(q{SET SESSION CHARACTERISTICS
               AS TRANSACTION ISOLATION LEVEL } . $self->isolation_level);
    $sql->begin;

    $self->$orig;

    $| = 1;
    printf "%-30.30s %9s %4s %9s\n", qw(Table Rows est% rows/sec);
};

around make_tar => sub {
    my ($orig, $self, $tar_file, @tables) = @_;

    @tables =
        map { 'mbdump/' . ($self->table_file_mapping->{$_} // $_) }
        grep { $self->row_counts->{$_} }
        @tables;

    $self->$orig($tar_file, @tables);
};

sub table_rowcount {
    my ($self, $table) = @_;

    $table =~ s/_sanitised$//;
    $table =~ s/.*\.//;

    $self->sql->select_single_value(
        'SELECT reltuples FROM pg_class WHERE relname = ? LIMIT 1',
        $table,
    );
}

sub _open_table_file {
    my ($self, $table, $mode) = @_;

    my $table_file = $self->table_file_mapping->{$table} // $table;
    my $table_file_path = $self->export_dir . "/mbdump/$table_file";
    my $table_file_is_new = !-e $table_file_path;
    open(my $dump_fh, "${mode}${table_file_path}") or die $!;

    return ($dump_fh, $table_file_path, $table_file_is_new);
}

sub dump_table {
    my ($self, $table) = @_;

    my ($dump_fh, $table_file_path) = $self->_open_table_file($table, '>');

    my $rows_estimate = $self->row_counts->{$table} //
        $self->table_rowcount($table) // 1;

    my $t1 = [gettimeofday];
    my $interval;
    my $rows = 0;

    my $progress = sub {
        my ($pre, $post) = @_;
        $interval = tv_interval($t1);
        no integer;
        printf $pre . '%-30.30s %9d %3d%% %9d' . $post,
               $table, $rows, int(100 * $rows / ($rows_estimate || 1)),
               ($rows / $interval)
            if -t STDOUT;
    };

    $progress->('', '', 0);

    my $dbh = $self->dbh; # issues a ping, must be done before COPY
    $self->sql->do("COPY $table TO stdout");

    my $buffer;
    while ($dbh->pg_getcopydata($buffer) >= 0) {
        print $dump_fh encode('utf-8', $buffer) or die $!;

        ++$rows;
        unless ($rows & 0xFFF) {
            $progress->("\r", '', $rows);
        }
    }

    close $dump_fh or die $!;

    $progress->((-t STDOUT ? "\r" : ''),
                sprintf(" %.2f sec\n", $interval),
                $rows);

    $self->inc_total_tables;
    $self->inc_total_rows($rows);
    $self->row_counts->{$table} = $rows;

    $table_file_path;
}

sub dump_rows {
    my ($self, $schema, $table, $rows) = @_;

    my ($dump_fh, $table_file_path, $table_file_is_new) =
        $self->_open_table_file($table, '>>');

    my @ordered_columns = $self->sql->get_ordered_columns("$schema.$table");

    my $it = natatime 1000, @{$rows};
    while (my @next_rows = $it->()) {
        my @values = map {
            my $row = $_;
            (map { $row->{$_} } @ordered_columns)
        } @next_rows;

        my $qs = '(' . (join q(, ), (('?') x @ordered_columns)) . ')';
        my $values_placeholders = 'VALUES ' . (join q(, ), (($qs) x scalar @next_rows));

        my $dbh = $self->dbh; # issues a ping, must be done before COPY
        $self->sql->do("COPY ($values_placeholders) TO stdout", @values);

        my $buffer;
        while ($dbh->pg_getcopydata($buffer) >= 0) {
            print $dump_fh encode('utf-8', $buffer) or die $!;
        }
    }

    close $dump_fh or die $!;

    if ($table_file_is_new) {
        $self->inc_total_tables;
    }
    my $row_count = scalar @{$rows};
    $self->inc_total_rows($row_count);
    $self->row_counts->{$table} += $row_count;

    $table_file_path;
}

sub end_dump {
    my ($self) = @_;

    # Make sure our replication data is safe before we commit its removal from
    # the database.
    system '/bin/sync';
    $? == 0 or die "sync failed (rc=$?)";
    $self->sql->commit;

    log(sprintf "Dumped %d tables (%d rows) in %d seconds\n",
        $self->total_tables,
        $self->total_rows,
        tv_interval([$self->start_time]));

    # We can release the lock, allowing other exports to run if they wish.
    close $self->lock_fh;
    $self->lock_fh(undef);
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;
