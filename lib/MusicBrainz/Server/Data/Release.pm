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
    return 'release.id, gid, name.name, release.artist_credit AS artist_credit_id,
            release_group, status, packaging, date_year, date_month, date_day,
            country, comment, editpending, barcode, script, language';
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
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Release';
}

sub load
{
    my ($self, @objs) = @_;
    return load_subobjects($self, 'release', @objs);
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = release.artist_credit
                 WHERE acn.artist = ?
                 ORDER BY date_year, date_month, date_day, name.name
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $artist_id, $offset || 0);
}

sub find_by_release_group
{
    my ($self, $release_group_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE release_group = ?
                 ORDER BY date_year, date_month, date_day, name.name
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $release_group_id, $offset || 0);
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
                 ORDER BY date_year, date_month, date_day, name.name
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $artist_id, $offset || 0);
}

sub find_by_recording
{
    my ($self, $recording_id) = @_;
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE release.id IN (
                    SELECT release FROM medium
                      JOIN track ON track.tracklist = medium.tracklist
                      JOIN recording ON recording.id = track.recording
                     WHERE recording.id = ?
                )';
    return query_to_list($self->c->dbh, sub { $self->_new_from_row(@_) },
                         $query, $recording_id);
}

sub find_by_medium
{
    my ($self, $medium_id, $limit, $offset) = @_;
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE release.id IN (
                    SELECT release FROM medium
                     WHERE medium.id = ?
                )';
    return query_to_list_limited($self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
                                 $query, $medium_id);
}

sub find_by_collection
{
    my ($self, $collection_id, $limit, $offset, $order) = @_;

    my $extra_join = "";
    my $order_by = order_by($order, "date", {
        "date"   => "date_year, date_month, date_day, name.name",
        "title"  => "name.name, date_year, date_month, date_day, name.name",
        "artist" => sub {
            $extra_join = "JOIN artist_name ac_name ON ac_name.id=release.artist_credit";
            return "ac_name.name, date_year, date_month, date_day, name.name";
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
    my $sql = Sql->new($self->c->mb->dbh);
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
    my $sql = Sql->new($self->c->mb->dbh);
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
    my $sql = Sql->new($self->c->mb->dbh);
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
