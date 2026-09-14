package MusicBrainz::Server::Data::Role::Noindex;

use Moose::Role;
use namespace::autoclean;

use DBDefs;
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( non_empty );

requires '_main_table', 'c', 'get_by_ids', 'sql';

# The `artist_noindex` table currently only exists in production pending a
# schema change release (32) for mirror and standalone servers.
# The `ACTIVE_SCHEMA_SEQUENCE` flag is set to 32 in production to gate these
# features.
sub _schema_32 { DBDefs->ACTIVE_SCHEMA_SEQUENCE >= 32 }

sub _has_noindex_table {
    my $self = shift;
    return (
        $self->_schema_32 &&
        $ENTITIES{ $self->_main_table }{noindex_table}
    );
}

sub load_noindex_status {
    my ($self, @entities) = @_;

    return unless $self->_schema_32;

    my @ids = map { $_->id } @entities;
    return unless @ids;

    my $table = $self->_main_table;
    my $has_noindex_table = $self->_has_noindex_table;
    my $query = '';
    my @params;

    if ($has_noindex_table) {
        $query = <<~"SQL";
            SELECT $table
              FROM ${table}_noindex
             WHERE $table = any(?)
            SQL
        push @params, \@ids;
    }

    if (
        $table eq 'recording' ||
        $table eq 'release' ||
        $table eq 'release_group'
    ) {
        $query .= ' UNION ' if $has_noindex_table;
        $query .= <<~"SQL";
            SELECT DISTINCT r.id
              FROM $table r
              JOIN artist_credit_name acn ON acn.artist_credit = r.artist_credit
              JOIN artist_noindex an ON an.artist = acn.artist
             WHERE r.id = any(?)
            SQL
        push @params, \@ids;
    }

    die "Entity type is not supported by load_noindex_status: $table"
        unless non_empty($query);

    my %noindex_ids = map { $_ => 1 } @{
        $self->c->sql->select_single_column_array($query, @params);
    };

    for my $entity (@entities) {
        $entity->noindex(exists $noindex_ids{ $entity->id });
    }
    return;
}

sub find_noindexed_entities {
    my ($self) = @_;

    return () unless $self->_has_noindex_table;

    my $table = $self->_main_table;
    my $rows = $self->sql->select_list_of_hashes(<<~"SQL");
        SELECT $table, editor
          FROM ${table}_noindex
        SQL

    my $entities = $self->get_by_ids(map { $_->{$table} } @$rows);
    my $editors = $self->c->model('Editor')->get_by_ids(
        map { $_->{editor} } @$rows,
    );

    return map +{
        entity => $entities->{ $_->{$table} },
        editor => $editors->{ $_->{editor} },
    }, @$rows;
}

sub add_noindex_status {
    my ($self, $editor_id, @ids) = @_;

    return unless $self->_has_noindex_table && @ids;

    my $table = $self->_main_table;
    $self->sql->do(<<~"SQL", $editor_id, \@ids);
        INSERT INTO ${table}_noindex ($table, editor)
             SELECT id, ?
               FROM unnest(?::INTEGER[]) AS entity (id)
        ON CONFLICT ($table) DO NOTHING
        SQL
    return;
}

sub remove_noindex_status {
    my ($self, @ids) = @_;

    return unless $self->_has_noindex_table && @ids;

    my $table = $self->_main_table;
    $self->sql->do(<<~"SQL", \@ids);
        DELETE FROM ${table}_noindex
              WHERE $table = any(?)
        SQL
    return;
}

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
