package MusicBrainz::Script::Role::IncrementalDump;

use strict;
use warnings;

use Data::Dumper;
use DBDefs;
use Moose::Role;
use MusicBrainz::Script::Utils qw( log );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Replication qw( REPLICATION_ACCESS_URI );
use Parallel::ForkManager 0.7.6;
use Sql;
use Try::Tiny;

with 'MusicBrainz::Server::Role::FollowForeignKeys';

requires qw(
    database
    dump_schema
    dumped_entity_types
    get_changed_documents
    handle_update_path
    post_replication_sequence
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

        my $total_changed = 0;
        my $fetch_document = sub {
            my ($item, %extra_args) = @_;

            # What $item is is up to the consumer of this role and
            # its implementation of get_changed_documents. For
            # sitemaps, it's a single row; for the json dumps, it's
            # an array of row IDs.
            my $changed = $self->get_changed_documents(
                $new_c, $pk_table, $item, $update, %extra_args);
            $total_changed += $changed;
            return $changed;
        };

        try {
            my $entity_rows = $self->get_linked_entities(
                $new_c, $pk_table, $update, $joins);

            if (@{$entity_rows}) {
                $self->handle_update_path(
                    $new_c, $pk_table, $entity_rows, $fetch_document);

                if ($total_changed) {
                    $exit_code = 0;
                    shift @args;
                    $shared_data = \@args;
                }
            } else {
                log('No more linked entities found for sequence ID ' .
                    $update->{sequence_id} . " in table $pk_table");
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

sub get_linked_entities($$$$) {
    my ($self, $c, $entity_type, $update, $joins) = @_;

    my $dump_schema = $self->dump_schema;

    my ($src_schema, $src_table, $src_column, $src_value, $replication_sequence) =
        @{$update}{qw(schema table column value replication_sequence)};

    my $first_join;
    my $last_join;

    if (@$joins) {
        $first_join = $joins->[0];
        $last_join = $joins->[scalar(@$joins) - 1];

        # The target entity table we're selecting from should always be the
        # RHS of the first join. Conversely, the source table - i.e., where
        # the change originated - should always be the LHS of the final join.
        # These values are still passed through via @_ and $update, because
        # there sometimes aren't any joins. In that case, the source and
        # target tables should be equal.
        die ('Bad join: ' . Dumper($joins)) unless (
            $first_join->{rhs}{schema} eq 'musicbrainz' &&
            $first_join->{rhs}{table}  eq $entity_type  &&

            $last_join->{lhs}{schema}  eq $src_schema   &&
            $last_join->{lhs}{table}   eq $src_table
        );
    } else {
        die 'Bad join' unless (
            $src_schema eq 'musicbrainz' &&
            $src_table  eq $entity_type
        );
    }

    my $table = "musicbrainz.$entity_type";
    my $joins_string = '';
    my $src_alias;

    if (@$joins) {
        my $aliases = {
            $table => 'entity_table',
        };
        $joins_string = stringify_joins($joins, $aliases);
        $src_alias = $aliases->{"$src_schema.$src_table"};
    } else {
        $src_alias = 'entity_table';
    }

    Sql::run_in_transaction(sub {
        $c->sql->do("LOCK TABLE $dump_schema.tmp_checked_entities IN SHARE ROW EXCLUSIVE MODE");

        my $entity_rows = $c->sql->select_list_of_hashes(
            "SELECT DISTINCT entity_table.id, entity_table.gid
               FROM $table entity_table
               $joins_string
              WHERE ($src_alias.$src_column = $src_value)
                AND NOT EXISTS (
                    SELECT 1 FROM $dump_schema.tmp_checked_entities ce
                     WHERE ce.entity_type = '$entity_type'
                       AND ce.id = entity_table.id
                )"
        );

        my @entity_rows = @{$entity_rows};
        if (@entity_rows) {
            $c->sql->do(
                "INSERT INTO $dump_schema.tmp_checked_entities (id, entity_type) " .
                'VALUES ' . (join ', ', ("(?, '$entity_type')") x scalar(@entity_rows)),
                map { $_->{id} } @entity_rows,
            );
        }

        $entity_rows;
    }, $c->sql);
}

no Moose::Role;

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
