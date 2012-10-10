package MusicBrainz::Server::Data::Artwork;

use Moose;
use MusicBrainz::Server::Entity::Release;
use MusicBrainz::Server::Data::Utils qw(
    object_to_ids
    placeholders
    query_to_list
);

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Editable' => {
    table => 'cover_art_archive.cover_art'
};

sub _table
{
    return 'cover_art_archive.cover_art';
}

sub _columns
{
    return 'cover_art_archive.cover_art.id,
            cover_art_archive.cover_art.release,
            cover_art_archive.cover_art.comment,
            cover_art_archive.cover_art.edit,
            cover_art_archive.cover_art.ordering,
            cover_art_archive.cover_art.edits_pending';
}

sub _id_column
{
    return 'cover_art_archive.cover_art.id';
}

sub _column_mapping
{
    return {
        id => 'id',
        release_id => 'release',
        comment => 'comment',
        edit_id => 'edit',
        ordering => 'ordering',
        edits_pending => 'edits_pending',
        is_front => 'is_front',
        is_back => 'is_back',
        approved => 'approved',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Artwork';
}

sub find_by_release
{
    my ($self, @releases) = @_;
    my %id_to_release = object_to_ids (@releases);
    my @ids = keys %id_to_release;

    return unless @ids; # nothing to do
    my $query = "SELECT
            cover_art_archive.index_listing.id,
            cover_art_archive.index_listing.release,
            cover_art_archive.index_listing.comment,
            cover_art_archive.index_listing.edit,
            cover_art_archive.index_listing.ordering,
            cover_art_archive.cover_art.edits_pending,
            cover_art_archive.index_listing.approved,
            cover_art_archive.index_listing.is_front,
            cover_art_archive.index_listing.is_back
        FROM cover_art_archive.index_listing
        JOIN cover_art_archive.cover_art
        ON cover_art_archive.cover_art.id = cover_art_archive.index_listing.id
        WHERE cover_art_archive.index_listing.release
        IN (" . placeholders(@ids) . ")
        ORDER BY cover_art_archive.index_listing.ordering";

    my @artwork = query_to_list($self->c->sql, sub { $self->_new_from_row(@_) },
                                $query, @ids);
    foreach my $image (@artwork) {
        foreach my $release (@{ $id_to_release{$image->release_id} })
        {
            $image->release ($release);
        }
    }

    return \@artwork;
}

sub find_front_cover_by_release
{
    my ($self, @releases) = @_;
    my %id_to_release = object_to_ids (@releases);
    my @ids = keys %id_to_release;

    return unless @ids; # nothing to do
    my $query = "SELECT
            cover_art_archive.index_listing.id,
            cover_art_archive.index_listing.release,
            cover_art_archive.index_listing.comment,
            cover_art_archive.index_listing.edit,
            cover_art_archive.index_listing.ordering,
            cover_art_archive.cover_art.edits_pending,
            cover_art_archive.index_listing.approved,
            cover_art_archive.index_listing.is_front,
            cover_art_archive.index_listing.is_back
        FROM cover_art_archive.index_listing
        JOIN cover_art_archive.cover_art
        ON cover_art_archive.cover_art.id = cover_art_archive.index_listing.id
        WHERE cover_art_archive.index_listing.release
        IN (" . placeholders(@ids) . ")
        AND is_front = true
        ORDER BY cover_art_archive.index_listing.ordering";

    my @artwork = query_to_list($self->c->sql, sub { $self->_new_from_row(@_) },
                                $query, @ids);
    foreach my $image (@artwork) {
        foreach my $release (@{ $id_to_release{$image->release_id} })
        {
            $image->release ($release);
        }
    }

    return \@artwork;
}

sub load_for_release_groups
{
    my ($self, @release_groups) = @_;
    my %id_to_rg = object_to_ids (@release_groups);
    my @ids = keys %id_to_rg;

    return unless @ids; # nothing to do
    my $query = "SELECT
            DISTINCT ON (release.release_group)
            cover_art_archive.index_listing.id,
            cover_art_archive.index_listing.release,
            cover_art_archive.index_listing.comment,
            cover_art_archive.index_listing.edit,
            cover_art_archive.index_listing.ordering,
            cover_art_archive.index_listing.approved,
            cover_art_archive.index_listing.is_front,
            cover_art_archive.index_listing.is_back,
            musicbrainz.release.release_group,
            musicbrainz.release.gid AS release_gid
        FROM cover_art_archive.index_listing
        JOIN musicbrainz.release
        ON musicbrainz.release.id = cover_art_archive.index_listing.release
        FULL OUTER JOIN cover_art_archive.release_group_cover_art
        ON release_group_cover_art.release = musicbrainz.release.id
        WHERE release.release_group IN (" . placeholders(@ids) . ")
        AND is_front = true
        ORDER BY release.release_group, release_group_cover_art.release,
                 release.date_year, release.date_month, release.date_day";

    $self->sql->select($query, @ids);
    while (my $row = $self->sql->next_row_hash_ref) {

        my $artwork = $self->_new_from_row ($row);
        $artwork->release (
            MusicBrainz::Server::Entity::Release->new (
                id => $row->{release},
                gid => $row->{release_gid},
                release_group_id => $row->{release_group}));

        $id_to_rg{ $row->{release_group} }->[0]->cover_art ($artwork);
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
