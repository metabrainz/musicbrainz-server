package MusicBrainz::Server::Role::FollowForeignKeys;

use Data::Compare qw( Compare );
use Data::Dumper;
use List::AllUtils qw( any );
use Moose::Role;
use MusicBrainz::Script::Utils qw( retry );

requires qw( follow_primary_key );

has _foreign_keys_cache => (
    isa => 'HashRef',
    is => 'ro',
    default => sub { +{} },
);

has _primary_keys_cache => (
    isa => 'HashRef',
    is => 'ro',
    default => sub { +{} },
);

sub get_ident($) {
    my $args = shift;

    return $args unless ref($args) eq 'HASH';

    my ($schema, $table, $column) = @{$args}{qw(schema table column)};
    return "$schema.$table.$column";
}

sub stringify_joins($) {
    my ($joins, $aliases) = @_;

    my $index = 1;
    my $prev_lhs_table;

    join ' ', map {
        my ($lhs, $rhs) = @{$_}{qw(lhs rhs)};

        my $lhs_table = $lhs->{schema} . q(.) . $lhs->{table};
        my $rhs_table = $rhs->{schema} . q(.) . $rhs->{table};

        if ($prev_lhs_table) {
            die ('Bad join: ' . Dumper($joins))
                unless $prev_lhs_table eq $rhs_table;
        }
        $prev_lhs_table = $lhs_table;

        my $rhs_alias = $aliases->{$rhs_table} // 't0';
        my $lhs_alias = $aliases->{$lhs_table} // ('t' . $index);
        $aliases->{$lhs_table} = $lhs_alias;
        ++$index;

        my $lhs_ident = $lhs_alias . q(.) . $lhs->{column};
        my $rhs_ident = $rhs_alias . q(.) . $rhs->{column};

        "JOIN $lhs_table $lhs_alias ON $lhs_ident = $rhs_ident"
    } @{$joins};
}

sub should_follow_foreign_key {
    my ($self, $direction, $pk, $fk, $joins) = @_;

    # For purposes of comparison here, the `lhs` inside each join is the
    # primary key, and the `rhs` is the foreign key to be followed.
    if (@$joins) {
        # Going from e.g. (artist.id -> artist_meta.id) to
        # (artist_meta.id -> artist.id) should be ignored.
        my $last_join = $joins->[0];
        return 0 if (Compare($last_join->{lhs}, $fk) &&
                     Compare($last_join->{rhs}, $pk));
    }

    return 1;
}

sub has_join {
    my ($self, $pk, $fk, $joins) = @_;

    any {
        my ($lhs, $rhs) = @{$_}{qw(lhs rhs)};

        (ref($lhs) eq 'HASH' && Compare($lhs, $pk))
        ||
        (ref($rhs) eq 'HASH' && Compare($rhs, $fk))
    } @{$joins};
}

sub _get_foreign_keys {
    my ($self, $c, $direction, $schema, $table) = @_;

    my $cache_key = "$direction\t$schema\t$table";
    if (exists $self->_foreign_keys_cache->{$cache_key}) {
        return $self->_foreign_keys_cache->{$cache_key};
    }

    my $foreign_keys = [];
    my ($sth, $all_keys);

    if ($direction == 1) {
        # Get FK columns in other tables that refer to PK columns in $table.
        $sth = $c->sql->dbh->foreign_key_info(undef, $schema, $table, (undef) x 3);
        if (defined $sth) {
            $all_keys = $sth->fetchall_arrayref;
        }
    } elsif ($direction == 2) {
        # Get FK columns in $table that refer to PK columns in other tables.
        $sth = $c->sql->dbh->foreign_key_info((undef) x 4, $schema, $table);
        if (defined $sth) {
            $all_keys = $sth->fetchall_arrayref;
        }
    }

    if (defined $all_keys) {
        for my $info (@{$all_keys}) {
            my ($pk_schema, $pk_table, $pk_column);
            my ($fk_schema, $fk_table, $fk_column);

            if ($direction == 1) {
                ($pk_schema, $pk_table, $pk_column) = @{$info}[1..3];
                ($fk_schema, $fk_table, $fk_column) = @{$info}[5..7];
            } elsif ($direction == 2) {
                ($fk_schema, $fk_table, $fk_column) = @{$info}[1..3];
                ($pk_schema, $pk_table, $pk_column) = @{$info}[5..7];
            }

            if ($schema eq $pk_schema && $table eq $pk_table) {
                push @{$foreign_keys}, {
                    pk_column => $pk_column,
                    fk_schema => $fk_schema,
                    fk_table => $fk_table,
                    fk_column => $fk_column,
                };
            }
        }
    }

    $self->_foreign_keys_cache->{$cache_key} = $foreign_keys;
    return $foreign_keys;
}

sub follow_foreign_keys($$$$$$);

sub follow_foreign_keys($$$$$$) {
    my ($self, $c, $direction, $pk_schema, $pk_table, $update, $joins) = @_;

    my @primary_keys = (
        [$pk_schema, $pk_table, $joins],
    );
    # Continue traversing the schemas until we stop finding changes.
    while (@primary_keys) {
        ($pk_schema, $pk_table, $joins) = @{ pop(@primary_keys) };

        # retry: "server closed the connection unexpectedly" has happened here.
        my $foreign_keys = retry(
            sub { $self->_get_foreign_keys($c, $direction, $pk_schema, $pk_table) },
            reason => 'getting foreign keys',
        );
        next unless @{$foreign_keys};

        for my $info (@{$foreign_keys}) {
            my ($pk_column, $fk_schema, $fk_table, $fk_column) =
                @{$info}{qw(pk_column fk_schema fk_table fk_column)};

            my $lhs = {schema => $pk_schema, table => $pk_table, column => $pk_column};
            my $rhs = {schema => $fk_schema, table => $fk_table, column => $fk_column};

            next unless $self->should_follow_foreign_key($direction, $lhs, $rhs, $joins);

            my $new_joins = [{lhs => $lhs, rhs => $rhs}, @{$joins}];

            my $continue = $self->follow_primary_key(
                $c,
                $direction,
                $fk_schema,
                $fk_table,
                $update,
                $new_joins,
            );

            push @primary_keys, [$fk_schema, $fk_table, $new_joins] if $continue;
        }
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
