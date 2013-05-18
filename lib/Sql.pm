package Sql;
use Moose;

use DBDefs;
use Carp qw( cluck croak carp );
use Try::Tiny;
use utf8 ();

has 'debug' => (
    isa => 'Bool',
    is => 'rw',
    default => sub { exists $ENV{SQL_DEBUG} && $ENV{SQL_DEBUG} }
);

has 'conn' => (
    is => 'ro',
    isa => 'DBIx::Connector',
    required => 1,
    handles => [qw( dbh )],
);

has 'quiet' => (
    isa => 'Bool',
    is => 'rw',
    default => 0,
);

has '_auto_commit' => (
    isa => 'Bool',
    is => 'rw',
    default => 0
);

has 'sth' => (
    is => 'rw',
    handles => {
        row_count => 'rows',
        next_row => 'fetchrow_array',
        next_row_ref => 'fetch',
        next_row_hash_ref => 'fetchrow_hashref',
    },
    clearer => 'clear_sth'
);

sub finish
{
    my ($self) = @_;
    if (my $sth = $self->sth) {
        $sth->finish;
        $self->clear_sth;
    }
}

sub BUILDARGS
{
    my ($self, $conn) = @_;
   croak "Missing required argument 'conn'" unless defined $conn;
    return { conn => $conn };
}

sub auto_commit
{
    my $self = shift;
    return if $self->is_in_transaction;
    $self->_auto_commit(1);
}

sub is_in_transaction
{
    my $self = shift;
    return !$self->dbh->{AutoCommit};
}

sub select
{
    my ($self, $query, @params) = @_;
    my $prepare_method = (@params ? "prepare_cached" : "prepare");

    return try {
        my $tt = Sql::Timer->new($query, \@params) if $self->debug;

        $self->sth( $self->dbh->$prepare_method($query) );
        $self->sth->execute(@params);
        return $self->sth->rows;
    }
    catch {
        my $err = $_;
        confess "Failed query:\n\t'$query'\n\t(@params)\n$err\n" unless $self->quiet;
        $self->finish;
    };
}

sub do
{
    my ($self, $query, @params) = @_;

    if ($self->_auto_commit == 0 && !$self->is_in_transaction) {
        croak 'do called while not in transaction, or marked to auto commit';
    }

    my $prepare_method = (@params ? "prepare_cached" : "prepare");

    $self->_auto_commit(0) if $self->_auto_commit;
    return try {
        my $tt = Sql::Timer->new($query, \@params) if $self->debug;
        my $sth = $self->dbh->$prepare_method($query);
        my $rows = $sth->execute(@params);
        $sth->finish;
        return $rows;
    }
    catch {
        my $err = $_;
        confess "Failed query:\n\t'$query'\n\t(@params)\n$err\n" unless $self->quiet;
    };
}

# Insert a single row into a table, $tab; $row is a hash reference, where the
# keys are the column names and the values are the values of the columns.
# Anything which isn't a plain data value (e.g. "NOW()") can be specified by
# making the value a reference to a SQL fragment (e.g. datecolumn =>
# \"NOW()").  In non-void context, returns the ID of the row just inserted
# using ->GetLastInsertId.  If the table has no auto-id field, call this in
# void context.

sub insert_row
{
    my ($self, $table, $row, $returning) = @_;

    unless (ref($row) eq 'HASH' && %$row) {
        croak 'Cannot insert a missing or empty row';
    }

    my (@columns, @expressions, @values);
    while (my ($col, $val) = each %$row) {
        push @columns, $col;
        if (ref $val eq 'SCALAR') {
            push(@expressions, $$val);
        }
        else {
            push @expressions, "?";
            push @values, $val;
        }
    }

    my $query = "INSERT INTO $table (" . join(',', @columns) .') VALUES (' .
                join(',', @expressions) . ')';

    if ($returning) {
        $query .= " RETURNING $returning";
        return $self->select_single_value($query, @values);
    }
    else {
        $self->do($query, @values);
    }
}

sub insert_many {
    my ($self, $table, @insertions) = @_;
    return unless @insertions;

    my %pivot;
    for my $insertion (@insertions) {
        my %row = %$insertion;
        for my $key (keys %row) {
            push @{ $pivot{$key} //= [] }, $row{$key};
        }
    }

    my @keys = keys %pivot or return;
    scalar(@{$pivot{$_}}) == scalar(@{$pivot{$keys[0]}}) or die "Inconsist row list"
        for @keys ;

    my $query = "INSERT INTO $table (" . join(', ', @keys) . ') VALUES ' .
        join(', ', map { '(' . join(', ', ('?') x @keys) . ')' } @insertions);

    $self->do($query,
             map {
                 my $i = $_;
                 map { $pivot{$_}->[$i] } @keys
             } (0..$#insertions));
}

sub update_row
{
    my ($self, $table, $update, $conditions) = @_;
    my @update_columns = keys %$update;
    my @condition_columns = keys %$conditions;

    croak 'update_row called with no columns to update' unless @update_columns;
    croak 'update_row called with no where clause' unless @condition_columns;

    my $query = "UPDATE $table SET " . join(', ', map { "$_ = ?" } @update_columns) .
                ' WHERE ' . join(' AND ', map { "$_ = ?" } @condition_columns);

    $self->do($query,
        (map { $update->{$_} } @update_columns),
        (map { $conditions->{$_} } @condition_columns));
}

sub delete_row
{
    my ($self, $table, $conditions) = @_;
    my @condition_columns = keys %$conditions;

    croak 'delete_row called with no where clause' unless @condition_columns;

    my $query = "DELETE FROM $table WHERE " . join(' AND ', map { "$_ = ?" } @condition_columns);

    $self->do($query, (map { $conditions->{$_} } @condition_columns));
}

has 'transaction_depth' => (
    isa => 'Int',
    is => 'ro',
    default => 0,
    traits => [ 'Counter' ],
    handles => {
        inc_transaction_depth => 'inc',
        dec_transaction_depth => 'dec'
    }
);

sub begin
{
    my $self = shift;
    $self->dbh->{AutoCommit} = 0;
    $self->inc_transaction_depth;
    if ($self->transaction_depth == 1) {
        my $tt = Sql::Timer->new('BEGIN', []) if $self->debug;
    }
}

sub commit
{
    my $self = shift;
    croak 'commit called without begin' unless $self->is_in_transaction;
    $self->dec_transaction_depth;
    return unless $self->transaction_depth == 0;

    croak "Cannot commit, in readonly mode!" if DBDefs->DB_READ_ONLY;

    return try {
        my $tt = Sql::Timer->new('COMMIT', []) if $self->debug;
        my $rv = $self->dbh->commit;
        cluck "Commit failed" if ($rv eq '' && !$self->quiet);
        $self->dbh->{AutoCommit} = 1;
        return $rv;
    }
    catch {
        my $err = $_;
        $self->dbh->{AutoCommit} = 1;
        cluck $err unless ($self->quiet);
        eval { $self->rollback };
        croak $err;
    }
}

sub rollback
{
    my $self = shift;
    croak 'rollback called without begin' unless $self->is_in_transaction;
    $self->dec_transaction_depth;

    return unless $self->transaction_depth == 0;

    return try {
        my $tt = Sql::Timer->new('ROLLBACK', []) if $self->debug;
        my $rv = $self->dbh->rollback;
        cluck "Rollback failed" if ($rv eq '' && !$self->quiet);
        $self->dbh->{AutoCommit} = 1;
        return $rv;
    }
    catch {
        my $err = $_;
        $self->dbh->{AutoCommit} = 1;
        cluck $err unless $self->quiet;
        croak $err;
    }
}

# AutoTransaction: call back the given code reference,
# automatically applying a Begin/Commit/Rollback around it
# if required (i.e. if we are not already in a transaction).
# Calling context is preserved.     Exceptions may be thrown.

sub auto_transaction
{
    my ($self, $sub) = @_;

    # If we're already in a transaction, just run the code.
    return &$sub if $self->is_in_transaction;

    # Otherwise, do a normal auto-transaction
    _auto_transaction($sub, $self);
}

sub _auto_transaction {
    my ($sub, @sql) = @_;

    $_->begin for @sql;
    my $w = wantarray;
    return try {
        my (@r, $r);

        @r = &$sub() if $w;
        $r = &$sub() if defined $w and not $w;
        &$sub() if not defined $w;

        $_->commit for @sql;

        return $w ? @r : $r;
    }
    catch {
        my $err = $_;
        for my $sql (@sql) {
            eval { $sql->rollback };
        }
        croak $err;
    }
}

sub _run_in_transaction_one
{
    my ($sub, $sql) = @_;
    return _auto_transaction($sub, $sql);
}

# XXX use two-phase commit
sub _run_in_transaction_two
{
    my ($sub, $sql_1, $sql_2) = @_;
    return _auto_transaction($sub, $sql_1, $sql_2);
}

sub run_in_transaction
{
    my ($sub, $sql_1, $sql_2) = @_;

    if (!defined $sql_2 || $sql_1 == $sql_2) {
        return _run_in_transaction_one($sub, $sql_1);
    }
    else {
        return _run_in_transaction_two($sub, $sql_1, $sql_2);
    }
}

# Given an error message possibly thrown by DBI, does it represent a query
# timeout?
sub is_timeout
{
    my ($self, $error) = @_;
    return $error =~ /(?:Query was cancelled|canceling query|statement timeout)/i;
}

# The "Select*" methods.  All these methods accept ($query, @args) parameters,
# run the given SELECT query using prepare_cached, retrieve the required data,
# and then "finish" the statement handle.

sub _select_single_row
{
    my ($self, $query, $params, $type) = @_;

    my $method = "fetchrow_$type";
    my @params = @$params;

    return try {
        my $tt = Sql::Timer->new($query, $params) if $self->debug;

        $self->sth( $self->dbh->prepare_cached($query) );
        my $rv  = $self->sth->execute(@params) or croak 'Could not execute query';

        my $first_row = $self->sth->$method;
        my $next_row  = $self->sth->$method if $first_row;

        $self->finish;

        croak 'Query returned more than one row (expected 1 row)' if $next_row;

        return $first_row;
    }
    catch {
        my $err = $_;
        confess "Failed query:\n\t'$query'\n\t(@params)\n$err\n"
            unless $self->quiet;
    };
}

sub select_single_row_hash
{
    my ($self, $query, @params) = @_;
    return $self->_select_single_row($query, \@params, 'hashref');
}


sub select_single_row_array
{
    my ($self, $query, @params) = @_;
    return $self->_select_single_row($query, \@params, 'arrayref');
}

# Run a SELECT query.  Depending on the number of resulting columns:
# >1 column (and at least one row): raise an error.
# otherwise: return a reference to an array containing the column data.
sub select_single_column_array
{
    my ($self, $query, @params) = @_;

    my $rows = $self->select_list_of_lists($query, @params);
    return [] unless @$rows;

    croak 'Query returned multiple columns' if @{ $rows->[0] } > 1;

    return [ map { $_->[0] } @$rows ];
}

# Run a SELECT query.  Must return either no data (return "undef"), or exactly
# one row, one column (return that value).

sub select_single_value
{
    my ($self, $query, @params) = @_;

    my $row = $self->select_single_column_array($query, @params);
    return unless $row;
    return $row->[0];
}

sub _select_list
{
    my ($self, $query, $params, $type, $form_row) = @_;
    $form_row ||= sub { shift };

    my $method = "fetchrow_$type";
    my @params = @$params;

    try {
        my $tt = Sql::Timer->new($query, $params) if $self->debug;

        $self->sth( $self->dbh->prepare_cached($query) );
        my $rv  = $self->sth->execute(@params) or croak 'Could not execute query';

        my @vals;
        while(my $row = $self->sth->$method) {
            push @vals, $form_row->($row);
        }

        $self->finish;

        return \@vals;
    }
    catch {
        my $err = $_;
        cluck "Failed query:\n\t'$query'\n\t(@params)\n$err\n"
            unless $self->quiet;
        confess $err;
    };
}


# Run a SELECT query.  Return a reference to an array of rows, where each row
# is a reference to an array of columns.

sub select_list_of_lists
{
    my ($self, $query, @params) = @_;

    # http://search.cpan.org/~timb/DBI-1.609/DBI.pm#fetchrow_arrayref
    # "Note that the same array reference is returned for each fetch"
    # -- we need different arary refs! (aCiD2)
    my $form_row = sub {
        my $row = shift;
        return [ @$row ];
    };

    $self->_select_list($query, \@params, 'arrayref', $form_row);
}

# Run a SELECT query.  Return a reference to an array of rows, where each row
# is a reference to a hash of the column data.

sub select_list_of_hashes
{
    my ($self, $query, @params) = @_;
    $self->_select_list($query, \@params, 'hashref');
}

################################################################################

package Sql::Timer;
use Moose;

use Time::HiRes qw( gettimeofday tv_interval );

has 'sql' => (
    isa => 'Str',
    is => 'rw'
);

has 'args' => (
    is => 'ro'
);

has 'file' => (
    isa => 'Str',
    is => 'ro',
);

has 'line_number' => (
    isa => 'Num',
    is => 'ro'
);

has 't0' => (
    isa => 'ArrayRef',
    is => 'ro'
);

sub BUILDARGS
{
    my ($self, $sql, $args) = @_;

    my $i = 0;
    my $c;
    while($i < 10) {
        $c = [ (caller(++$i)) ];
        last unless $c->[1] eq __FILE__;
    }

    return {
        sql => $sql,
        args => $args,
        file => $c->[1],
        line_number => $c->[2],
        t0 => [ gettimeofday ],
    };
}

sub DEMOLISH
{
    my $self = shift;
    my $t = tv_interval($self->t0);
    my $sql = $self->sql;
    $sql =~ s/\s+/ /sg;

    # Uncomment this if you're only interested in queries which take longer
    # than $somelimit
    #return if $t < 0.1;

    local $" = ", ";
    my $msg = sprintf "SQL: %8.4fs \"%s\" (%s)", $t,
        $sql, join(", ", @{ $self->args });

    printf STDERR "sql: %s at %s line %d\n", $msg, $self->file, $self->line_number;
}

1;

=head1 LICENSE

Copyright (C) 2001 Robert Kaye
Copyright (C) 2009 Oliver Charles

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
