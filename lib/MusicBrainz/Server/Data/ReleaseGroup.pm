package MusicBrainz::Server::Data::ReleaseGroup;
use Moose;
use namespace::autoclean;

use List::UtilsBy qw( partition_by );
use MusicBrainz::Server::Entity::ReleaseGroup;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Utils qw(
    hash_to_row
    load_subobjects
    merge_table_attributes
    order_by
    placeholders
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );

use MusicBrainz::Server::Constants qw( $STATUS_OPEN $VARTIST_ID );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'release_group' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::DeleteAndLog' => { type => 'release_group' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'release_group' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'release_group' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'release_group' };
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'release_group' };
with 'MusicBrainz::Server::Data::Role::Merge';
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'release_group' };
with 'MusicBrainz::Server::Data::Role::Collection';

sub _type { 'release_group' }

sub _table
{
    my $self = shift;
    return $self->_main_table . ' rg
            JOIN release_group_meta rgm ON rgm.id = rg.id';
}

sub _columns
{
    return 'rg.id, rg.gid, rg.type AS primary_type_id, rg.name,
            rg.artist_credit AS artist_credit_id,
            rg.comment, rg.edits_pending, rg.last_updated,
            rgm.first_release_date_year,
            rgm.first_release_date_month,
            rgm.first_release_date_day';
}

sub _column_mapping {
    return {
        id => 'id',
        gid => 'gid',
        primary_type_id => 'primary_type_id',
        name => 'name',
        artist_credit_id => 'artist_credit_id',
        comment => 'comment',
        edits_pending => 'edits_pending',
        last_updated => 'last_updated',
        first_release_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, 'first_release_date_') }
    }
}

sub _id_column
{
    return 'rg.id';
}

sub _where_filter
{
    my ($filter) = @_;

    my (@query, @joins, @params);

    if (defined $filter) {
        if (exists $filter->{name}) {
            push @query, "(mb_simple_tsvector(rg.name) @@ plainto_tsquery('mb_simple', mb_lower(?)) OR rg.name = ?)";
            push @params, $filter->{name}, $filter->{name};
        }
        if (exists $filter->{artist_credit_id}) {
            push @query, "rg.artist_credit = ?";
            push @params, $filter->{artist_credit_id};
        }
        if (exists $filter->{type_id}) {
            push @query, "rg.type = ?";
            push @params, $filter->{type_id};
        }
        if (exists $filter->{type} && $filter->{type}) {
            my @types = ref($filter->{type}) ? @{ $filter->{type} } : ( $filter->{type} );
            my %partitioned_types = partition_by {
                "$_" =~ /^st:/ ? 'secondary' : 'primary'
            } @types;

            if (my $primary = $partitioned_types{primary}) {
                push @query, 'rg.type = any(?)';
                push @params, $primary;
            }

            if (my $secondary = $partitioned_types{secondary}) {
                push @query, 'st.secondary_type = any(?)';
                push @params, [ map { substr($_, 3) } @$secondary ];
                push @joins, 'JOIN release_group_secondary_type_join st ON rg.id = st.release_group';
            }
        }
    }

    return (\@query, \@joins, \@params);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'release_group', @objs);
}

sub find_artist_credits_by_artist
{
    my ($self, $artist_id) = @_;

    my $query = "SELECT DISTINCT rel.artist_credit
                 FROM release_group rel
                 JOIN artist_credit_name acn
                     ON acn.artist_credit = rel.artist_credit
                 WHERE acn.artist = ?";
    my $ids = $self->sql->select_single_column_array($query, $artist_id);
    return $self->c->model('ArtistCredit')->find_by_ids($ids);
}

sub find_by_artist
{
    my ($self, $artist_id, $show_all, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "acn.artist = ?";
    # Show only RGs with official releases by default, plus all-status-less ones so people fix the status
    unless ($show_all) {
        push @$conditions, "(EXISTS (SELECT 1 FROM release where release.release_group = rg.id AND release.status = '1') OR
                            NOT EXISTS (SELECT 1 FROM release where release.release_group = rg.id AND release.status IS NOT NULL))";
       }
    push @$params, $artist_id;

    my $query = "SELECT DISTINCT " . $self->_columns . ",
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    rgm.release_count,
                    rgm.rating_count,
                    rgm.rating,
                    rg.name COLLATE musicbrainz AS name_collate,
                    array(
                      SELECT name FROM release_group_secondary_type rgst
                      JOIN release_group_secondary_type_join rgstj
                        ON rgstj.secondary_type = rgst.id
                      WHERE rgstj.release_group = rg.id
                      ORDER BY name ASC
                    ) secondary_types
                 FROM " . $self->_table . "
                    JOIN artist_credit_name acn
                        ON acn.artist_credit = rg.artist_credit
                     " . join(' ', @$extra_joins) . "
                 WHERE " . join(" AND ", @$conditions) . "
                 ORDER BY
                    rg.type, secondary_types,
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    rg.name COLLATE musicbrainz";
    $self->query_to_list_limited(
        $query,
        $params,
        $limit,
        $offset,
        sub {
            my ($model, $row) = @_;
            my $rg = $model->_new_from_row($row);
            $rg->rating($row->{rating}) if defined $row->{rating};
            $rg->rating_count($row->{rating_count}) if defined $row->{rating_count};
            $rg->first_release_date(MusicBrainz::Server::Entity::PartialDate->new_from_row($row, 'first_release_date_'));
            $rg->release_count($row->{release_count} || 0);
            return $rg;
        },
    );
}

sub find_by_track_artist
{
    my ($self, $artist_id, $show_all, $limit, $offset) = @_;

    my $extra_conditions = '';
    # Show only RGs with official releases by default, plus all-status-less ones so people fix the status
    unless ($show_all) {
        $extra_conditions = " AND (EXISTS (SELECT 1 FROM release where release.release_group = rg.id AND release.status = '1') OR
                            NOT EXISTS (SELECT 1 FROM release where release.release_group = rg.id AND release.status IS NOT NULL)) ";
       }

    my $query = "SELECT DISTINCT " . $self->_columns . ",
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    rgm.release_count,
                    rgm.rating_count,
                    rgm.rating,
                    rg.name COLLATE musicbrainz,
                    array(
                      SELECT name FROM release_group_secondary_type rgst
                      JOIN release_group_secondary_type_join rgstj
                        ON rgstj.secondary_type = rgst.id
                      WHERE rgstj.release_group = rg.id
                      ORDER BY name ASC
                    ) secondary_types
                 FROM " . $self->_table . "
                    JOIN artist_credit_name acn
                        ON acn.artist_credit = rg.artist_credit
                 WHERE rg.id IN (
                     SELECT release_group FROM release
                         JOIN medium
                         ON medium.release = release.id
                         JOIN track tr
                         ON tr.medium = medium.id
                         JOIN artist_credit_name acn
                         ON acn.artist_credit = tr.artist_credit
                     WHERE acn.artist = ?
                 )
                   AND rg.id NOT IN (
                     SELECT id FROM release_group
                       JOIN artist_credit_name acn
                         ON release_group.artist_credit = acn.artist_credit
                      WHERE acn.artist = ?)
                   $extra_conditions
                 ORDER BY
                    rg.type, secondary_types,
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    rg.name COLLATE musicbrainz";
    $self->query_to_list_limited(
        $query,
        [$artist_id, $artist_id],
        $limit,
        $offset,
        sub {
            my ($model, $row) = @_;
            my $rg = $model->_new_from_row($row);
            $rg->rating($row->{rating}) if defined $row->{rating};
            $rg->rating_count($row->{rating_count}) if defined $row->{rating_count};
            $rg->first_release_date(MusicBrainz::Server::Entity::PartialDate->new_from_row($row, 'first_release_date_'));
            $rg->release_count($row->{release_count} || 0);
            return $rg;
        },
    );
}

sub find_by_artist_credit
{
    my ($self, $artist_credit_id, $limit, $offset) = @_;

    my $query = "SELECT " . $self->_columns . ",
                    rg.name COLLATE musicbrainz AS name_collate
                 FROM " . $self->_table . "
                 WHERE rg.artist_credit = ?
                 ORDER BY rg.name COLLATE musicbrainz";
    $self->query_to_list_limited($query, [$artist_credit_id], $limit, $offset);
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
                 WHERE release.id = ?
                 ORDER BY
                    rg.type,
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    rg.name COLLATE musicbrainz";
    $self->query_to_list_limited($query, [$release_id], $limit, $offset, sub {
        my ($model, $row) = @_;
        my $rg = $model->_new_from_row($row);
        $rg->first_release_date(MusicBrainz::Server::Entity::PartialDate->new_from_row($row, 'first_release_date_'));
        return $rg;
    });
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
                 WHERE release.gid IN (" . placeholders (@release_gids) . ")
                 ORDER BY
                    rg.type,
                    rgm.first_release_date_year,
                    rgm.first_release_date_month,
                    rgm.first_release_date_day,
                    rg.name COLLATE musicbrainz";
    $self->query_to_list($query, \@release_gids, sub {
        my ($model, $row) = @_;
        my $rg = $model->_new_from_row($row);
        $rg->first_release_date(MusicBrainz::Server::Entity::PartialDate->new_from_row($row, 'first_release_date_'));
        return $rg;
    });
}

sub find_by_recording
{
    my ($self, $recording) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN release ON release.release_group = rg.id
                    JOIN medium ON medium.release = release.id
                    JOIN track ON track.medium = medium.id
                    JOIN recording ON recording.id = track.recording
                 WHERE recording.id = ?
                 ORDER BY
                    rg.type,
                    rg.name COLLATE musicbrainz";

    $self->query_to_list($query, [$recording]);
}

sub _order_by {
    my ($self, $order) = @_;

    my $extra_join = "";
    my $also_select = "";

    my $order_by = order_by($order, "name", {
        "name" => sub {
            return "name COLLATE musicbrainz"
        },
        "artist" => sub {
            $extra_join = "JOIN artist_credit ac ON ac.id = rg.artist_credit";
            $also_select = "ac.name AS ac_name";
            return "ac_name COLLATE musicbrainz, release_group.name COLLATE musicbrainz";
        },
        "primary_type" => sub {
            return "primary_type_id, name COLLATE musicbrainz"
        },
        "year" => sub {
            return "first_release_date_year, name COLLATE musicbrainz"
        }
    });

    my $inner_order_by = $order_by
        =~ s/ac_name/ac.name/r;

    return ($order_by, $extra_join, $also_select, $inner_order_by);
}

sub _insert_hook_after_each {
    my ($self, $created, $rg) = @_;
    $self->c->model('ReleaseGroupSecondaryType')->set_types($created->{id}, $rg->{secondary_type_ids});
}

sub update {
    my ($self, $group_id, $update) = @_;
    my $release_data = MusicBrainz::Server::Data::Release->new(c => $self->c);
    my $row = $self->_hash_to_row($update);
    $self->sql->update_row('release_group', $row, { id => $group_id }) if %$row;
    $self->c->model('ReleaseGroupSecondaryType')->set_types($group_id, $update->{secondary_type_ids})
        if exists $update->{secondary_type_ids};

    if ($update->{name}) {
        $self->c->model('Series')->reorder_for_entities('release_group', $group_id);
    }
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
    @group_ids = grep { $self->can_delete($_) } @group_ids
        or return;

    $self->c->model('Collection')->delete_entities('release_group', @group_ids);
    $self->c->model('Relationship')->delete_entities('release_group', @group_ids);
    $self->alias->delete_entities(@group_ids);
    $self->annotation->delete(@group_ids);
    $self->tags->delete(@group_ids);
    $self->rating->delete(@group_ids);
    $self->remove_gid_redirects(@group_ids);
    $self->c->model('ReleaseGroupSecondaryType')->delete_entities(@group_ids);
    $self->delete_returning_gids(@group_ids);
    return;
}

sub clear_empty_release_groups {
    my ($self, @group_ids) = @_;
    return unless @group_ids;

    @group_ids = @{
        $self->sql->select_single_column_array(
            'SELECT id FROM release_group outer_rg
             WHERE edits_pending = 0 AND id = any(?)
             AND NOT EXISTS (
               SELECT TRUE FROM l_area_release_group WHERE entity1 = outer_rg.id
               UNION ALL
               SELECT TRUE FROM l_artist_release_group WHERE entity1 = outer_rg.id
               UNION ALL
               SELECT TRUE FROM l_instrument_release_group WHERE entity1 = outer_rg.id
               UNION ALL
               SELECT TRUE FROM l_label_release_group WHERE entity1 = outer_rg.id
               UNION ALL
               SELECT TRUE FROM l_place_release_group WHERE entity1 = outer_rg.id
               UNION ALL
               SELECT TRUE FROM l_recording_release_group WHERE entity1 = outer_rg.id
               UNION ALL
               SELECT TRUE FROM l_release_release_group WHERE entity1 = outer_rg.id
               UNION ALL
               SELECT TRUE FROM l_release_group_release_group WHERE entity0 = outer_rg.id OR entity1 = outer_rg.id
               UNION ALL
               SELECT TRUE FROM l_release_group_work WHERE entity0 = outer_rg.id
               UNION ALL
               SELECT TRUE FROM l_release_group_url WHERE entity0 = outer_rg.id
         )',
            \@group_ids
        )
    };

    $self->delete(@group_ids);
}

sub _merge_impl
{
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->c->model('Collection')->merge_entities('release_group', $new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('release_group', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('release_group', $new_id, \@old_ids);
    $self->c->model('ReleaseGroupSecondaryType')->merge_entities($new_id, @old_ids);
    $self->c->model('CoverArtArchive')->merge_release_groups($new_id, @old_ids);

    merge_table_attributes(
        $self->sql => (
            table => 'release_group',
            columns => [ qw( type ) ],
            old_ids => \@old_ids,
            new_id => $new_id
        )
    );

    # Move releases to the new release group
    my $release_ids = $self->sql->select_single_column_array('UPDATE release SET release_group = ?
              WHERE release_group IN ('.placeholders(@old_ids).') RETURNING id', $new_id, @old_ids);
    $self->c->model('Release')->_delete_from_cache(@$release_ids);

    $self->_delete_and_redirect_gids('release_group', $new_id, @old_ids);
    return 1;
}

sub _hash_to_row
{
    my ($self, $group) = @_;
    my $row = hash_to_row($group, {
        type => 'primary_type_id',
        map { $_ => $_ } qw( artist_credit comment edits_pending name )
    });

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
        $obj->first_release_date(MusicBrainz::Server::Entity::PartialDate->new_from_row($row, 'first_release_date_'));
    }, @_);
}

sub has_cover_art_set
{
    my ($self, $rg_id) = @_;

    my $query = "SELECT release
            FROM cover_art_archive.release_group_cover_art
            WHERE release_group = ?";

    return $self->sql->select_single_value($query, $rg_id);
}

sub set_cover_art {
    my ($self, $rg_id, $release_id) = @_;

    $self->sql->do("
        UPDATE cover_art_archive.release_group_cover_art
        SET release = ? WHERE release_group = ?;
        INSERT INTO cover_art_archive.release_group_cover_art (release_group, release)
        (SELECT ? AS release_group, ? AS release WHERE NOT EXISTS
            (SELECT 1 FROM cover_art_archive.release_group_cover_art
             WHERE release_group = ?));",
        $release_id, $rg_id, $rg_id, $release_id, $rg_id);
}

sub unset_cover_art {
    my ($self, $rg_id) = @_;

    $self->sql->do("DELETE FROM cover_art_archive.release_group_cover_art
                    WHERE release_group = ?", $rg_id);
}

sub merge_releases {
    my ($self, $new_id, @old_ids) = @_;

    my $rg_ids = $self->c->sql->select_list_of_hashes(
        "SELECT release_group, id FROM release WHERE id IN ("
        . placeholders ($new_id, @old_ids) . ")", $new_id, @old_ids);

    my %release_rg;
    my %release_group_ids;
    for my $row (@$rg_ids) {
        $release_rg{$row->{id}} = $row->{release_group};
        $release_group_ids{$row->{release_group}} = 1;
    };

    my @release_group_ids = keys %release_group_ids;
    my $rg_cover_art = $self->c->sql->select_list_of_hashes(
        "SELECT release_group, release
         FROM cover_art_archive.release_group_cover_art
         WHERE release_group IN (" . placeholders (@release_group_ids) . ")",
        @release_group_ids);

    my %has_cover_art = map { $_->{release_group} => $_->{release} } @$rg_cover_art;

    my $new_rg = $release_rg{$new_id};
    for my $old_id (@old_ids)
    {
        my $old_rg = $release_rg{$old_id};

        if ($new_rg == $old_rg)
        {
            # The new release group is the same as the old release group
            # - if the release group cover art is set to one of the old ids,
            #   move it to the new id.
            $self->set_cover_art($new_rg, $new_id)
                if ($has_cover_art{$new_rg} // 0) == $old_id;
        }
        else
        {
            # The new release group is different from the old release group
            # - if the old release group cover art is set to the id being moved,
            #   unset the old cover art
            $self->unset_cover_art($old_rg)
                if ($has_cover_art{$old_rg} // 0) == $old_id;

            # Do not change the new release group cover art, regardless of
            # whether it is set or not.
        }
    }
}

sub is_empty {
    my ($self, $release_group_id) = @_;

    my $used_in_relationship =
        used_in_relationship($self->c, release_group => 'release_group_row.id');

    return $self->sql->select_single_value(<<EOSQL, $release_group_id, $STATUS_OPEN);
        SELECT TRUE
        FROM release_group release_group_row
        WHERE id = ?
        AND edits_pending = 0
        AND NOT (
          EXISTS (
            SELECT TRUE FROM edit_release_group
            JOIN edit ON edit.id = edit_release_group.edit
            WHERE status = ? AND release_group = release_group_row.id
          ) OR
          EXISTS (
            SELECT TRUE FROM release
            WHERE release.release_group = release_group_row.id
            LIMIT 1
          ) OR
          $used_in_relationship
        )
EOSQL
}

sub series_ordering {
    my ($self, $a, $b) = @_;

    return $a->entity0->first_release_date <=> $b->entity0->first_release_date;
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
