package MusicBrainz::Server::Data::ReleaseGroup;

use Moose;
use MusicBrainz::Server::Entity::ReleaseGroup;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Utils qw(
    check_in_use
    generate_gid
    hash_to_row
    load_subobjects
    merge_table_attributes
    partial_date_from_row
    placeholders
    query_to_list
    query_to_list_limited
);

use MusicBrainz::Server::Constants '$VARTIST_ID';

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'release_group' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'release_group' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'release_group' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'release_group' };
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'release_group' };

sub _table
{
    return 'release_group rg JOIN release_name name ON rg.name=name.id';
}

sub _columns
{
    return 'rg.id, rg.gid, rg.type AS type_id, name.name,
            rg.artist_credit AS artist_credit_id,
            rg.comment, rg.edits_pending, rg.last_updated';
}

sub _id_column
{
    return 'rg.id';
}

sub _gid_redirect_table
{
    return 'release_group_gid_redirect';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::ReleaseGroup';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'release_group', @objs);
}

sub find_by_name_prefix
{
    my ($self, $prefix, $limit, $offset, $conditions, @bind) = @_;

    my $query = "SELECT " . $self->_columns . ",
                    rgm.release_count,
                    rgm.rating_count,
                    rgm.rating
                 FROM " . $self->_table . "
                    JOIN release_group_meta rgm
                        ON rgm.id = rg.id
                    JOIN artist_credit_name acn
                        ON acn.artist_credit = rg.artist_credit
                 WHERE page_index(name.name)
                 BETWEEN page_index(?) AND page_index_max(?)";

    $query .= " AND ($conditions)" if $conditions;
    $query .= ' ORDER BY name.name OFFSET ?';

    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub {
            my $row = $_[0];
            my $rg = $self->_new_from_row(@_);
            $rg->rating($row->{rating}) if defined $row->{rating};
            $rg->rating_count($row->{rating_count}) if defined $row->{rating_count};
            $rg->release_count($row->{release_count} || 0);
            return $rg;
        },
        $query, $prefix, $prefix, @bind, $offset || 0);
}

sub find_by_name_prefix_va
{
    my ($self, $prefix, $limit, $offset) = @_;
    return $self->find_by_name_prefix(
        $prefix, $limit, $offset,
        'rg.artist_credit IN (SELECT artist_credit FROM artist_credit_name ' .
        'JOIN artist_credit ac ON ac.id = artist_credit ' .
        'WHERE artist = ? AND artist_count = 1)',
        $VARTIST_ID
    );
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset, $types) = @_;

    my $where_types = $types ? 'AND type IN ('.placeholders(@$types).')' : '';

    my $query = "SELECT DISTINCT " . $self->_columns . ",
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    rgm.release_count,
                    rgm.rating_count,
                    rgm.rating,
                    musicbrainz_collate(name.name) AS name_collate
                 FROM " . $self->_table . "
                    JOIN release_group_meta rgm
                        ON rgm.id = rg.id
                    JOIN artist_credit_name acn
                        ON acn.artist_credit = rg.artist_credit
                 WHERE acn.artist = ?
                    $where_types
                 ORDER BY
                    rg.type,
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub {
            my $row = $_[0];
            my $rg = $self->_new_from_row($row);
            $rg->rating($row->{rating}) if defined $row->{rating};
            $rg->rating_count($row->{rating_count}) if defined $row->{rating_count};
            $rg->first_release_date(partial_date_from_row($row, 'first_release_date_'));
            $rg->release_count($row->{release_count} || 0);
            return $rg;
        },
        $query, $artist_id, @$types, $offset || 0);
}

sub find_by_track_artist
{
    my ($self, $artist_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . ",
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    rgm.release_count,
                    rgm.rating_count,
                    rgm.rating
                 FROM " . $self->_table . "
                    JOIN release_group_meta rgm
                        ON rgm.id = rg.id
                    JOIN artist_credit_name acn
                        ON acn.artist_credit = rg.artist_credit
                 WHERE rg.id IN (
                     SELECT release_group FROM release
                         JOIN medium
                         ON medium.release = release.id
                         JOIN track tr
                         ON tr.tracklist = medium.tracklist
                         JOIN artist_credit_name acn
                         ON acn.artist_credit = tr.artist_credit
                     WHERE acn.artist = ?
                 )
                   AND rg.id NOT IN (
                     SELECT id FROM release_group
                       JOIN artist_credit_name acn
                         ON release_group.artist_credit = acn.artist_credit
                      WHERE acn.artist = ?)
                 ORDER BY
                    rg.type,
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub {
            my $row = $_[0];
            my $rg = $self->_new_from_row($row);
            $rg->rating($row->{rating}) if defined $row->{rating};
            $rg->rating_count($row->{rating_count}) if defined $row->{rating_count};
            $rg->first_release_date(partial_date_from_row($row, 'first_release_date_'));
            $rg->release_count($row->{release_count} || 0);
            return $rg;
        },
        $query, $artist_id, $artist_id, $offset || 0);
}

# This could be wrapped into find_by_artist, but it still needs to support filtering on VA releases
sub filter_by_artist
{
    my ($self, $artist_id, $type) = @_;
    my $query = "SELECT DISTINCT " . $self->_columns . ",
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    rgm.release_count,
                    rgm.rating_count,
                    rgm.rating,
                    musicbrainz_collate(name.name)
                 FROM " . $self->_table . "
                    JOIN release_group_meta rgm
                        ON rgm.id = rg.id
                    JOIN artist_credit_name acn
                        ON acn.artist_credit = rg.artist_credit
                 WHERE acn.artist = ?" .
                     ($type ? " AND type = ? " : "") .
                "ORDER BY
                    rg.type,
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    musicbrainz_collate(name.name)";
    return query_to_list(
        $self->c->sql, sub {
            my $row = $_[0];
            my $rg = $self->_new_from_row($row);
            $rg->rating($row->{rating}) if defined $row->{rating};
            $rg->rating_count($row->{rating_count}) if defined $row->{rating_count};
            $rg->first_release_date(partial_date_from_row($row, 'first_release_date_'));
            $rg->release_count($row->{release_count} || 0);
            return $rg;
        },
        $query, $artist_id, $type ? ($type) : ());
}

sub filter_by_track_artist
{
    my ($self, $artist_id, $type) = @_;
    my $query = "SELECT " . $self->_columns . ",
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    rgm.release_count,
                    rgm.rating_count,
                    rgm.rating
                 FROM " . $self->_table . "
                    JOIN release_group_meta rgm
                        ON rgm.id = rg.id
                    JOIN artist_credit_name acn
                        ON acn.artist_credit = rg.artist_credit
                 WHERE rg.id IN (
                     SELECT release_group FROM release
                         JOIN medium
                         ON medium.release = release.id
                         JOIN track tr
                         ON tr.tracklist = medium.tracklist
                         JOIN artist_credit_name acn
                         ON acn.artist_credit = tr.artist_credit
                     WHERE acn.artist = ?
                 ) " .
                     ($type ? " AND type = ? " : "") .
                 "ORDER BY
                    rg.type,
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    musicbrainz_collate(name.name)";
    return query_to_list(
        $self->c->sql, sub {
            my $row = $_[0];
            my $rg = $self->_new_from_row($row);
            $rg->rating($row->{rating}) if defined $row->{rating};
            $rg->rating_count($row->{rating_count}) if defined $row->{rating_count};
            $rg->first_release_date(partial_date_from_row($row, 'first_release_date_'));
            $rg->release_count($row->{release_count} || 0);
            return $rg;
        },
        $query, $artist_id, $type ? ($type) : ());
}

sub find_by_release
{
    my ($self, $release_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . ",
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day
                 FROM " . $self->_table . "
                    JOIN release ON release.release_group = rg.id
                    JOIN release_group_meta rgm ON rgm.id = rg.id
                 WHERE release.id = ?
                 ORDER BY
                    rg.type,
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub {
            my $row = $_[0];
            my $rg = $self->_new_from_row($row);
            $rg->first_release_date(partial_date_from_row($row, 'first_release_date_'));
            return $rg;
        },
        $query, $release_id, $offset || 0);
}

sub find_by_release_gids
{
    my ($self, @release_gids) = @_;
    my $query = "SELECT " . $self->_columns . ",
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day
                 FROM " . $self->_table . "
                    JOIN release ON release.release_group = rg.id
                    JOIN release_group_meta rgm ON rgm.id = rg.id
                 WHERE release.gid IN (" . placeholders (@release_gids) . ")
                 ORDER BY
                    rg.type,
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    musicbrainz_collate(name.name)";
    return query_to_list(
        $self->c->sql, sub {
            my $row = $_[0];
            my $rg = $self->_new_from_row($row);
            $rg->first_release_date(partial_date_from_row($row, 'first_release_date_'));
            return $rg;
        },
        $query, @release_gids);
}

sub find_by_recording
{
    my ($self, $recording) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN release ON release.release_group = rg.id
                    JOIN medium ON medium.release = release.id
                    JOIN track ON track.tracklist = medium.tracklist
                    JOIN recording ON recording.id = track.recording
                 WHERE recording.id = ?
                 ORDER BY
                    rg.type,
                    musicbrainz_collate(name.name)";

    return query_to_list(
        $self->c->sql, sub {
            my $row = $_[0];
            return $self->_new_from_row($row);
        },
        $query, $recording);
}

sub insert
{
    my ($self, @groups) = @_;
    my @created;
    my $release_data = MusicBrainz::Server::Data::Release->new(c => $self->c);
    my %names = $release_data->find_or_insert_names(map { $_->{name} } @groups);
    my $class = $self->_entity_class;
    for my $group (@groups)
    {
        my $row = $self->_hash_to_row($group, \%names);
        $row->{gid} = $group->{gid} || generate_gid();
        push @created, $class->new(
            id => $self->sql->insert_row('release_group', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @groups > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $group_id, $update) = @_;
    my $release_data = MusicBrainz::Server::Data::Release->new(c => $self->c);
    my %names = $release_data->find_or_insert_names($update->{name});
    my $row = $self->_hash_to_row($update, \%names);
    $self->sql->update_row('release_group', $row, { id => $group_id });
}

sub in_use
{
    my ($self, $release_group_id) = @_;
    return check_in_use($self->sql,
        'release                    WHERE release_group = ?' => [ $release_group_id ],
        'l_artist_release_group     WHERE entity1 = ?' => [ $release_group_id ],
        'l_label_release_group      WHERE entity1 = ?' => [ $release_group_id ],
        'l_recording_release_group  WHERE entity1 = ?' => [ $release_group_id ],
        'l_release_release_group    WHERE entity1 = ?' => [ $release_group_id ],
        'l_release_group_url        WHERE entity0 = ?' => [ $release_group_id ],
        'l_release_group_work       WHERE entity0 = ?' => [ $release_group_id ],
        'l_release_group_release_group WHERE entity0 = ? OR entity1 = ?' => [ $release_group_id, $release_group_id ],
    );
}

sub can_delete
{
    my ($self, $release_group_id) = @_;

    my $refcount = $self->sql->select_single_column_array('SELECT 1 FROM release WHERE release_group = ?', $release_group_id);
    return @$refcount == 0;
}

sub delete
{
    my ($self, @group_ids) = @_;
    @group_ids = grep { !$self->in_use($_) } @group_ids;

    $self->c->model('Relationship')->delete_entities('release_group', @group_ids);
    $self->annotation->delete(@group_ids);
    $self->tags->delete(@group_ids);
    $self->rating->delete(@group_ids);
    $self->remove_gid_redirects(@group_ids);
    $self->sql->do('DELETE FROM release_group WHERE id IN (' . placeholders(@group_ids) . ')', @group_ids);
    return;
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;

    $self->annotation->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('release_group', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('release_group', $new_id, @old_ids);

    merge_table_attributes(
        $self->sql => (
            table => 'release_group',
            columns => [ qw( type comment ) ],
            old_ids => \@old_ids,
            new_id => $new_id
        )
    );

    # Move releases to the new release group
    $self->sql->do('UPDATE release SET release_group = ?
              WHERE release_group IN ('.placeholders(@old_ids).')', $new_id, @old_ids);

    $self->_delete_and_redirect_gids('release_group', $new_id, @old_ids);
    return 1;
}

sub _hash_to_row
{
    my ($self, $group, $names) = @_;
    my $row = hash_to_row($group, {
        type => 'type_id',
        map { $_ => $_ } qw( artist_credit comment )
    });

    $row->{name} = $names->{$group->{name}}
        if (exists $group->{name});

    return $row;
}

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, "release_group_meta", sub {
        my ($obj, $row) = @_;
        $obj->rating($row->{rating}) if defined $row->{rating};
        $obj->rating_count($row->{rating_count}) if defined $row->{rating_count};
        $obj->release_count($row->{release_count});
    }, @_);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::ReleaseGroup

=head1 METHODS

=head2 load (@releases)

Loads and sets release groups for the specified releases.

=head2 find_by_artist ($artist_id, $limit, [$offset])

Finds release groups by the specified artist, and returns an array containing
a reference to the array of release groups and the total number of found
release groups. The $limit parameter is used to limit the number of returned
release groups.

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
