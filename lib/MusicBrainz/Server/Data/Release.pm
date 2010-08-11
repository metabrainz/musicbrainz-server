package MusicBrainz::Server::Data::Release;

use Moose;
use MusicBrainz::Server::Entity::Release;
use MusicBrainz::Server::Data::Utils qw(
    defined_hash
    generate_gid
    load_subobjects
    partial_date_from_row
    placeholders
    query_to_list_limited
    query_to_list
    order_by
);

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'release' };
with 'MusicBrainz::Server::Data::Role::Name' => { name_table => 'release_name' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'release' };
with 'MusicBrainz::Server::Data::Role::BrowseVA';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'release' };

sub _table
{
    return 'release JOIN release_name name ON release.name=name.id';
}

sub _columns
{
    return 'release.id, release.gid, name.name, release.artist_credit AS artist_credit_id,
            release_group, release.status, release.packaging, date_year, date_month, date_day,
            release.country, release.comment, release.editpending, release.barcode,
            release.script, release.language, release.quality';
}

sub _id_column
{
    return 'release.id';
}

sub _gid_redirect_table
{
    return 'release_gid_redirect';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        artist_credit_id => 'artist_credit_id',
        release_group_id => 'release_group',
        status_id => 'status',
        packaging_id => 'packaging',
        country_id => 'country',
        date => sub { partial_date_from_row(shift, shift() . 'date_') },
        edits_pending => 'editpending',
        comment => 'comment',
        barcode => 'barcode',
        script_id => 'script',
        language_id => 'language',
        quality => 'quality'
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Release';
}

sub _where_status_in
{
    my @statuses = @_;

    return '' unless @statuses;

    return 'AND status IN ('.placeholders(@statuses).')';
}

sub _where_type_in
{
    my @types = @_;

    return ('', '') unless @types;

    return (
        'JOIN release_group ON release.release_group = release_group.id',
        'AND release_group.type in ('.placeholders(@types).')'
        );
}

sub load
{
    my ($self, @objs) = @_;
    return load_subobjects($self, 'release', @objs);
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset, $statuses, $types) = @_;

    my $where_statuses = _where_status_in (@$statuses);
    my ($join_types, $where_types) = _where_type_in (@$types);

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = release.artist_credit
                     $join_types
                 WHERE acn.artist = ?
                 $where_statuses
                 $where_types
                 ORDER BY date_year, date_month, date_day, musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $artist_id, @$statuses, @$types, $offset || 0);
}

sub find_by_label
{
    my ($self, $label_id, $limit, $offset, $statuses, $types) = @_;

    my $where_statuses = _where_status_in (@$statuses);
    my ($join_types, $where_types) = _where_type_in (@$types);

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN release_label
                         ON release_label.release = release.id
                     $join_types
                 WHERE release_label.label = ?
                 $where_statuses
                 $where_types
                 ORDER BY date_year, date_month, date_day, musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $label_id, $offset || 0);
}

sub find_by_release_group
{
    my ($self, $ids, $limit, $offset, $statuses) = @_;
    my @ids = ref $ids ? @$ids : ( $ids );

    my $where_statuses = _where_status_in (@$statuses);

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE release_group IN (" . placeholders(@ids) . ")
                 $where_statuses
                 ORDER BY date_year, date_month, date_day, musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, @ids, @$statuses, $offset || 0);
}

sub find_by_track_artist
{
    my ($self, $artist_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE release.id IN (
                     SELECT release FROM medium
                         JOIN track tr
                         ON tr.tracklist = medium.tracklist
                         JOIN artist_credit_name acn
                         ON acn.artist_credit = tr.artist_credit
                     WHERE acn.artist = ?)
                 ORDER BY date_year, date_month, date_day, musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $artist_id, $offset || 0);
}

sub find_for_various_artists
{
    my ($self, $artist_id, $limit, $offset, $statuses, $types) = @_;

    my $where_statuses = _where_status_in (@$statuses);
    my ($join_types, $where_types) = _where_type_in (@$types);

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = release.artist_credit
                     $join_types
                 WHERE acn.artist != ?
                 AND release.id IN (
                     SELECT release FROM medium
                         JOIN track tr
                         ON tr.tracklist = medium.tracklist
                         JOIN artist_credit_name acn
                         ON acn.artist_credit = tr.artist_credit
                     WHERE acn.artist = ?)
                 $where_statuses
                 $where_types
                 ORDER BY date_year, date_month, date_day, musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $artist_id, $artist_id, @$statuses, @$types, $offset || 0);
}

sub find_by_recording
{
    my ($self, $ids, $limit, $offset, $statuses, $types) = @_;

    my $where_statuses = _where_status_in (@$statuses);
    my ($join_types, $where_types) = _where_type_in (@$types);

    my @ids = ref $ids ? @$ids : ( $ids );
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     $join_types
                 WHERE release.id IN (
                    SELECT release FROM medium
                        JOIN track ON track.tracklist = medium.tracklist
                        JOIN recording ON recording.id = track.recording
                     WHERE recording.id IN (" . placeholders(@ids) . "))
                 $where_statuses
                 $where_types
                 ORDER BY date_year, date_month, date_day, musicbrainz_collate(name.name), release.id
                 OFFSET ?";

    return query_to_list_limited(
        $self->c->dbh, $offset, $limit || 25, sub { $self->_new_from_row(@_) },
        $query, @ids, @$statuses, @$types, $offset || 0);
}

sub load_with_tracklist_for_recording
{
    my ($self, $recording_id, $limit, $offset, $statuses, $types) = @_;

    my $where_statuses = _where_status_in (@$statuses);
    my ($join_types, $where_types) = _where_type_in (@$types);

    my $query = "
        SELECT
            release.id AS r_id, release.gid AS r_gid, release_name.name AS r_name,
                release.artist_credit AS r_artist_credit_id,
                release.date_year AS r_date_year,
                release.date_month AS r_date_month,
                release.date_day AS r_date_day,
                release.country AS r_country, release.status AS r_status,
                release.packaging AS r_packaging,
            medium.id AS m_id, medium.format AS m_format,
                medium.position AS m_position, medium.name AS m_name,
                medium.tracklist AS m_tracklist,
                tracklist.trackcount AS m_trackcount,
            track.id AS t_id, track_name.name AS t_name,
                track.tracklist AS t_tracklist, track.position AS t_position,
                track.length AS t_length, track.artist_credit AS t_artist_credit
        FROM
            track
            JOIN tracklist ON tracklist.id = track.tracklist
            JOIN medium ON medium.tracklist = tracklist.id
            JOIN release ON release.id = medium.release
            JOIN release_name ON release.name = release_name.id
            JOIN track_name ON track.name = track_name.id
            $join_types
        WHERE track.recording = ?
            $where_statuses
            $where_types
       ORDER BY date_year, date_month, date_day, musicbrainz_collate(release_name.name)
       OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub {
            my $row = shift;
            my $track = MusicBrainz::Server::Data::Track->_new_from_row($row, 't_');
            my $medium = MusicBrainz::Server::Data::Medium->_new_from_row($row, 'm_');
            my $tracklist = $medium->tracklist;
            my $release = $self->_new_from_row($row, 'r_');

            push @{ $release->mediums }, $medium;
            push @{ $tracklist->tracks }, $track;

            return $release;
        },
        $query, $recording_id, @$statuses, @$types, $offset || 0);
}


sub find_by_puid
{
    my ($self, $ids) = @_;
    my @ids = ref $ids ? @$ids : ( $ids );
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE release.id IN (
                    SELECT release FROM medium
                      JOIN track ON track.tracklist = medium.tracklist
                      JOIN recording ON recording.id = track.recording
                      JOIN recording_puid ON recording_puid.recording = recording.id
                      JOIN puid ON puid.id = recording_puid.puid
                     WHERE puid.puid IN (' . placeholders(@ids) . ')
                )';
    return query_to_list($self->c->dbh, sub { $self->_new_from_row(@_) },
                         $query, @{ids});
}

sub find_by_medium
{
    my ($self, $ids, $limit, $offset) = @_;
    my @ids = ref $ids ? @$ids : ( $ids );
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE release.id IN (
                    SELECT release FROM medium
                     WHERE medium.id IN (' . placeholders(@ids) . ')
                )
                OFFSET ?';
    return query_to_list($self->c->dbh, sub { $self->_new_from_row(@_) },
                         $query, @{ids}, $offset || 0);
}

sub find_by_collection
{
    my ($self, $collection_id, $limit, $offset, $order) = @_;

    my $extra_join = "";
    my $order_by = order_by($order, "date", {
        "date"   => "date_year, date_month, date_day, musicbrainz_collate(name.name)",
        "title"  => "musicbrainz_collate(name.name), date_year, date_month, date_day",
        "artist" => sub {
            $extra_join = "JOIN artist_name ac_name ON ac_name.id=release.artist_credit";
            return "musicbrainz_collate(ac_name.name), date_year, date_month, date_day, musicbrainz_collate(name.name)";
        },
    });

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_collection_release c
                        ON release.id = c.release
                    $extra_join
                 WHERE c.collection = ?
                 ORDER BY $order_by
                 OFFSET ?";

    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $collection_id, $offset || 0);
}

sub insert
{
    my ($self, @releases) = @_;
    my $sql = Sql->new($self->c->dbh);
    my @created;
    my %names = $self->find_or_insert_names(map { $_->{name} } @releases);
    my $class = $self->_entity_class;
    for my $release (@releases)
    {
        my $row = $self->_hash_to_row($release, \%names);
        $row->{gid} = $release->{gid} || generate_gid();
        push @created, $class->new(
            id => $sql->insert_row('release', $row, 'id'),
            gid => $row->{gid},
        );
    }
    return @releases > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $release_id, $update) = @_;
    my $sql = Sql->new($self->c->dbh);
    my %names = $self->find_or_insert_names($update->{name});
    my $row = $self->_hash_to_row($update, \%names);
    $sql->update_row('release', $row, { id => $release_id });
}

sub delete
{
    my ($self, @releases) = @_;
    my @release_ids = map { $_->id } @releases;
    $self->c->model('Collection')->delete_releases(@release_ids);
    $self->c->model('Relationship')->delete_entities('release', @release_ids);
    $self->annotation->delete(@release_ids);
    $self->remove_gid_redirects(@release_ids);
    my $sql = Sql->new($self->c->dbh);
    $sql->do('DELETE FROM release WHERE id IN (' . placeholders(@release_ids) . ')',
        @release_ids);
    return;
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;

    $self->annotation->merge($new_id, @old_ids);
    $self->c->model('Collection')->merge_releases($new_id, @old_ids);
    $self->c->model('ReleaseLabel')->merge_releases($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('release', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('release', $new_id, @old_ids);

    # XXX merge release attributes

    # XXX allow actual tracklists/mediums merging
    my $sql = Sql->new($self->c->dbh);
    my $pos = $sql->select_single_value('
        SELECT max(position) FROM medium WHERE release=?', $new_id) || 0;
    foreach my $old_id (@old_ids) {
        my $medium_ids = $sql->select_single_column_array('
            SELECT id FROM medium WHERE release=?
            ORDER BY position', $old_id);
        foreach my $medium_id (@$medium_ids) {
            $sql->do('UPDATE medium SET release=?, position=? WHERE id=?',
                     $new_id, ++$pos, $medium_id);
        }
    }

    $self->_delete_and_redirect_gids('release', $new_id, @old_ids);
    return 1;
}

sub _hash_to_row
{
    my ($self, $release, $names) = @_;
    my %row = (
        artist_credit => $release->{artist_credit},
        release_group => $release->{release_group_id},
        status => $release->{status_id},
        packaging => $release->{packaging_id},
        date_year => $release->{date}->{year},
        date_month => $release->{date}->{month},
        date_day => $release->{date}->{day},
        barcode => $release->{barcode},
        comment => $release->{comment},
        country => $release->{country_id},
        script => $release->{script_id},
        language => $release->{language_id},
        quality => $release->{quality}
    );

    if ($release->{name})
    {
        $row{name} = $names->{$release->{name}};
    }

    return { defined_hash(%row) };
}

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, "release_meta", sub {
        my ($obj, $row) = @_;
        $obj->last_update_date($row->{lastupdate}) if defined $row->{lastupdate};
        $obj->cover_art_url($row->{coverarturl}) if defined $row->{coverarturl};
        $obj->info_url($row->{infourl}) if defined $row->{infourl};
        $obj->amazon_asin($row->{amazonasin}) if defined $row->{amazonasin};
        $obj->amazon_store($row->{amazonstore}) if defined $row->{amazonstore};
    }, @_);
}

sub find_ids_by_track_ids
{
    my ($self, @ids) = @_;
    my $query = 'SELECT release
                   FROM medium
                  WHERE tracklist IN (
                            SELECT tracklist FROM track
                             WHERE id IN (' . placeholders(@ids) . ')
                        )';
    my $sql = Sql->new($self->c->dbh);
    return $sql->select_single_column_array($query, @ids);
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::Release

=head1 METHODS

=head2 find_by_artist ($artist_id, $limit, [$offset])

Finds releases by the specified artist, and returns an array containing
a reference to the array of releases and the total number of found releases.
The $limit parameter is used to limit the number of returned releass.

=head2 find_by_release_group ($release_group_id, $limit, [$offset])

Finds releases by the specified release group, and returns an array containing
a reference to the array of releases and the total number of found releases.
The $limit parameter is used to limit the number of returned releass.

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
