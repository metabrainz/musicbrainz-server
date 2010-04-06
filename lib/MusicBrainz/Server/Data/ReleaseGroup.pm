package MusicBrainz::Server::Data::ReleaseGroup;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

use MusicBrainz::Server::Entity::ReleaseGroup;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Utils qw(
    check_in_use
    hash_to_row
    partial_date_from_row
    placeholders
    query_to_list_limited
    query_to_list
);
use MusicBrainz::Schema qw( schema raw_schema );

extends 'MusicBrainz::Server::Data::FeyEntity';

with
    'MusicBrainz::Server::Data::Role::Name',
    'MusicBrainz::Server::Data::Role::Subobject',
    'MusicBrainz::Server::Data::Role::Gid' => {
        redirect_table     => schema->table('release_group_gid_redirect') },
    'MusicBrainz::Server::Data::Role::LoadMeta' => {
        metadata_table     => schema->table('release_group_meta') },
    'MusicBrainz::Server::Data::Role::Annotation' => {
        annotation_table   => schema->table('release_group_annotation') },
    'MusicBrainz::Server::Data::Role::Editable',
    'MusicBrainz::Server::Data::Role::Rating' => {
        rating_table       => raw_schema->table('release_group_rating_raw')
    },
    'MusicBrainz::Server::Data::Role::Tag' => {
        tag_table          => schema->table('release_group_tag'),
        raw_tag_table      => raw_schema->table('release_group_tag_raw')
    },
    'MusicBrainz::Server::Data::Role::BrowseVA',
    'MusicBrainz::Server::Data::Role::LinksToEdit';

sub _build_table  { schema->table('release_group') }
sub _entity_class { 'MusicBrainz::Server::Entity::ReleaseGroup' }

sub _column_mapping
{
    return {
        id               => 'id',
        gid              => 'gid',
        name             => 'name',
        type_id          => 'type',
        artist_credit_id => 'artist_credit',
        comment          => 'comment',
        edits_pending    => 'editpending'
    };
}

method _find_by_artist_query ($artist_id, $limit, $offset)
{
    my $acn = schema->table('artist_credit_name');

    # XXX Fey should be able to cope with this
    my $work_acn = Fey::FK->new(
        source_columns => [ $self->table->column('artist_credit') ],
        target_columns => [ $acn->column('artist_credit') ]);

    return $self->_select_with_meta
        ->from($self->table, $acn, $work_acn)
        ->where($acn->column('artist'), '=', $artist_id)
        ->order_by(
            (map {
                $self->metadata_table->column("firstreleasedate_$_")
            } qw( year month day )),
            $self->name_columns->{name},
        )
        ->limit(undef, $offset || 0);
}

method find_by_artist ($artist_id, $limit, $offset)
{
    my $query = $self->_find_by_artist_query($artist_id, $limit, $offset);
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub {
            my $row = $_[0];
            my $rg = $self->_new_from_row($row);
            $rg->rating($row->{rating}) if defined $row->{rating};
            $rg->rating_count($row->{ratingcount}) if defined $row->{ratingcount};
            $rg->first_release_date(partial_date_from_row($row, 'firstreleasedate_'));
            $rg->release_count($row->{releasecount} || 0);
            return $rg;
        },
        $query->sql($self->sql->dbh), $query->bind_params);
}

method find_by_track_artist ($artist_id, $limit, $offset)
{
    my $acn = schema->table('artist_credit_name');
    my $release = $self->c->model('Release')->table;
    my $medium = $self->c->model('Medium')->table;
    my $track = $self->c->model('Track')->table;

    # XXX Fey should be able to cope with this
    my $medium_track = Fey::FK->new(
        source_columns => [ $medium->column('tracklist') ],
        target_columns => [ $track->column('tracklist') ]);

    my $track_acn = Fey::FK->new(
        source_columns => [ $track->column('artist_credit') ],
        target_columns => [ $acn->column('artist_credit') ]);

    my $tracks_subq = Fey::SQL->new_select
        ->select($release->column('release_group'))
        ->from($release)
        ->from($release, $medium)
        ->from($medium, $track, $medium_track)
        ->from($track, $acn, $track_acn)
        ->where($acn->column('artist'), '=', $artist_id);

    my $query = $self->_select_with_meta
        ->where($self->table->column('id'), 'IN', $tracks_subq)
        ->order_by(
            (map {
                $self->metadata_table->column("firstreleasedate_$_")
            } qw( year month day )),
            $self->name_columns->{name},
        )
        ->limit(undef, $offset || 0);

    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub {
            my $row = $_[0];
            my $rg = $self->_new_from_row($row);
            $rg->rating($row->{rating}) if defined $row->{rating};
            $rg->rating_count($row->{ratingcount}) if defined $row->{ratingcount};
            $rg->first_release_date(partial_date_from_row($row, 'firstreleasedate_'));
            $rg->release_count($row->{releasecount} || 0);
            return $rg;
        },
        $query->sql($self->sql->dbh), $query->bind_params);
}

# This could be wrapped into find_by_artist, but it still needs to support filtering on VA releases
method filter_by_artist ($artist_id, $type)
{
    my $query = $self->_find_by_artist_query
        ->where($self->table->column('type'), '=', $type);

    return query_to_list(
        $self->c->dbh, sub {
            my $row = $_[0];
            my $rg = $self->_new_from_row($row);
            $rg->rating($row->{rating}) if defined $row->{rating};
            $rg->rating_count($row->{ratingcount}) if defined $row->{ratingcount};
            $rg->first_release_date(partial_date_from_row($row, 'firstreleasedate_'));
            $rg->release_count($row->{releasecount} || 0);
            return $rg;
        },
        $query->sql($self->sql->dbh), $query->bind_params);
}

method in_use ($release_group_id)
{
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

method can_delete ($release_group_id)
{
    my $release_table = $self->c->model('Release')->table;
    my $query = Fey::SQL->new_select
        ->select(1)->from($release_table)
        ->where($release_table->column('release_group'), '=', $release_group_id)
        ->limit(1);

    return !defined $self->sql->select_single_value(
        $query->sql($self->sql->dbh), $query->bind_params);
}

before merge => sub
{
    my ($self, $new_id, @old_ids) = @_;

    # Move releases to the new release group
    my $release_table = $self->c->model('Release')->table;
    my $query = Fey::SQL->new_update
        ->update($release_table)
        ->set($release_table->column('release_group'), $new_id)
        ->where($release_table->column('release_group'), 'IN', @old_ids);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
};

sub _hash_to_row
{
    my ($self, $group, $names) = @_;
    return hash_to_row($group, {
        artist_credit => 'artist_credit',
        comment       => 'comment',
        type          => 'type_id',
        name          => 'name'
    });
}

__PACKAGE__->meta->make_immutable;

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
