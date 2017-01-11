package MusicBrainz::Server::Role::FollowForeignKeys;

use Data::Compare qw( Compare );
use List::AllUtils qw( any );
use Moose::Role;

requires qw( follow_foreign_key );

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
    join ' ', map {
        my ($lhs, $rhs) = @{$_}{qw(lhs rhs)};

        my ($schema, $table) = @{$lhs}{qw(schema table)};

        "JOIN $schema.$table ON " . get_ident($lhs) . ' = ' . get_ident($rhs);
    } @{$_[0]};
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

sub get_foreign_keys {
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

    # Continue traversing the schemas until we stop finding changes.
    my $foreign_keys = $self->get_foreign_keys($c, $direction, $pk_schema, $pk_table);
    return unless @{$foreign_keys};

    for my $info (@{$foreign_keys}) {
        my ($pk_column, $fk_schema, $fk_table, $fk_column) =
            @{$info}{qw(pk_column fk_schema fk_table fk_column)};

        my $lhs = {schema => $pk_schema, table => $pk_table, column => $pk_column};
        my $rhs = {schema => $fk_schema, table => $fk_table, column => $fk_column};

        next unless $self->should_follow_foreign_key($direction, $lhs, $rhs, $joins);

        $self->follow_foreign_key(
            $c,
            $direction,
            $fk_schema,
            $fk_table,
            $update,
            [{lhs => $lhs, rhs => $rhs}, @{$joins}],
        );
    }
}

sub get_primary_keys($$$) {
    my ($self, $c, $schema, $table) = @_;

    my $cache = ($self->_primary_keys_cache->{$schema} //= {});
    if (defined $cache->{$table}) {
        return @{ $cache->{$table} };
    }

    my @keys = map {
        # Some columns are wrapped in quotes, others aren't...
        s/^"(.*?)"$/$1/r
    } $c->sql->dbh->primary_key(undef, $schema, $table);
    $cache->{$table} = \@keys;
    return @keys;
}

1;
