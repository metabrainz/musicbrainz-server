package MusicBrainz::Server::Data::CoverArt;

use Moose;
use MusicBrainz::Server::Entity::Release;
use MusicBrainz::Server::Data::Utils qw(
    object_to_ids
    placeholders
);
use MusicBrainz::Server::Validation qw( is_database_bigint_id );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::PendingEdits' => {
    table => 'cover_art_archive.cover_art',
};

sub _table
{
    return 'cover_art_archive.cover_art ' .
        'JOIN cover_art_archive.image_type USING (mime_type)';
}

sub _columns
{
    return 'cover_art_archive.cover_art.id,
            cover_art_archive.cover_art.release,
            cover_art_archive.cover_art.comment,
            cover_art_archive.cover_art.edit,
            cover_art_archive.cover_art.ordering,
            cover_art_archive.cover_art.edits_pending,
            cover_art_archive.cover_art.mime_type,
            cover_art_archive.image_type.suffix';
}

sub _id_column
{
    return 'cover_art_archive.cover_art.id';
}

sub is_valid_id {
    (undef, my $id) = @_;
    is_database_bigint_id($id);
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
        suffix => 'suffix',
        mime_type => 'mime_type',
    };
}

sub _entity_class
{
    my ($self, $row) = @_;
    if (exists $row->{release_group}) {
        return 'MusicBrainz::Server::Entity::Artwork::ReleaseGroup';
    } else {
        return 'MusicBrainz::Server::Entity::Artwork';
    }
}

sub find_by_release
{
    my ($self, @releases) = @_;
    my %id_to_release = object_to_ids(@releases);
    my @ids = keys %id_to_release;

    return unless @ids; # nothing to do
    my $query = 'SELECT
            cover_art_archive.index_listing.id,
            cover_art_archive.index_listing.release,
            cover_art_archive.index_listing.comment,
            cover_art_archive.index_listing.edit,
            cover_art_archive.index_listing.ordering,
            cover_art_archive.cover_art.edits_pending,
            cover_art_archive.index_listing.approved,
            cover_art_archive.index_listing.is_front,
            cover_art_archive.index_listing.is_back,
            cover_art_archive.image_type.mime_type,
            cover_art_archive.image_type.suffix
        FROM cover_art_archive.index_listing
        JOIN cover_art_archive.cover_art
        ON cover_art_archive.cover_art.id = cover_art_archive.index_listing.id
        JOIN cover_art_archive.image_type
        ON cover_art_archive.index_listing.mime_type = cover_art_archive.image_type.mime_type
        WHERE cover_art_archive.index_listing.release
        IN (' . placeholders(@ids) . ')
        ORDER BY cover_art_archive.index_listing.ordering';

    my @artwork = $self->query_to_list($query, \@ids);
    for my $image (@artwork) {
        $image->release($id_to_release{$image->release_id}->[0]);
    }

    return \@artwork;
}

sub find_front_cover_by_release
{
    my ($self, @releases) = @_;
    my %id_to_release = object_to_ids(@releases);
    my @ids = keys %id_to_release;

    return unless @ids; # nothing to do
    my $query = 'SELECT
            cover_art_archive.index_listing.id,
            cover_art_archive.index_listing.release,
            cover_art_archive.index_listing.comment,
            cover_art_archive.index_listing.edit,
            cover_art_archive.index_listing.ordering,
            cover_art_archive.cover_art.edits_pending,
            cover_art_archive.index_listing.approved,
            cover_art_archive.index_listing.is_front,
            cover_art_archive.index_listing.is_back,
            cover_art_archive.image_type.mime_type,
            cover_art_archive.image_type.suffix
        FROM cover_art_archive.index_listing
        JOIN cover_art_archive.cover_art
        ON cover_art_archive.cover_art.id = cover_art_archive.index_listing.id
        JOIN musicbrainz.release
        ON cover_art_archive.index_listing.release = musicbrainz.release.id
        JOIN cover_art_archive.image_type
        ON cover_art_archive.index_listing.mime_type = cover_art_archive.image_type.mime_type
        WHERE cover_art_archive.index_listing.release
        IN (' . placeholders(@ids) . ')
        AND is_front = true';

    my @artwork = $self->query_to_list($query, \@ids);
    foreach my $image (@artwork) {
        foreach my $release (@{ $id_to_release{$image->release_id} })
        {
            $image->release($release);
        }
    }

    return \@artwork;
}

sub find_count_by_release
{
    my ($self, $release_id) = @_;

    return unless $release_id; # nothing to do
    my $query = 'SELECT count(*)
        FROM cover_art_archive.index_listing
        WHERE cover_art_archive.index_listing.release = ?';

    return $self->sql->select_single_value($query, $release_id);
}

sub load_for_release_groups
{
    my ($self, @release_groups) = @_;
    my %id_to_rg = object_to_ids(@release_groups);
    my @ids = keys %id_to_rg;

    return unless @ids; # nothing to do
    my $query = 'SELECT
            DISTINCT ON (release.release_group)
            cover_art_archive.index_listing.id,
            cover_art_archive.index_listing.release,
            cover_art_archive.index_listing.comment,
            cover_art_archive.index_listing.edit,
            cover_art_archive.index_listing.ordering,
            cover_art_archive.index_listing.approved,
            cover_art_archive.index_listing.is_front,
            cover_art_archive.index_listing.is_back,
            cover_art_archive.image_type.mime_type,
            cover_art_archive.image_type.suffix,
            musicbrainz.release.release_group,
            musicbrainz.release.gid AS release_gid
        FROM cover_art_archive.index_listing
        JOIN musicbrainz.release
          ON musicbrainz.release.id = cover_art_archive.index_listing.release
        JOIN musicbrainz.release_meta
          ON musicbrainz.release_meta.id = musicbrainz.release.id
        LEFT JOIN (
          SELECT release, date_year, date_month, date_day
          FROM release_country
          UNION ALL
          SELECT release, date_year, date_month, date_day
          FROM release_unknown_country
        ) release_event ON (release_event.release = release.id)
        FULL OUTER JOIN cover_art_archive.release_group_cover_art
        ON release_group_cover_art.release = musicbrainz.release.id
        JOIN cover_art_archive.image_type
        ON cover_art_archive.index_listing.mime_type = cover_art_archive.image_type.mime_type
        WHERE release.release_group IN (' . placeholders(@ids) . q{)
        AND is_front = true
        AND cover_art_presence != 'darkened'
        ORDER BY release.release_group, release_group_cover_art.release,
          (CASE WHEN 'Raw/Unedited' = any(cover_art_archive.index_listing.types)
           THEN 1 ELSE 0 END),
          release_event.date_year, release_event.date_month,
          release_event.date_day};

    for my $row (@{ $self->sql->select_list_of_hashes($query, @ids) }) {
        my $artwork = $self->_new_from_row($row);

        $artwork->release(
            MusicBrainz::Server::Entity::Release->new(
                id => $row->{release},
                gid => $row->{release_gid},
                release_group_id => $row->{release_group}));
        $artwork->release_group($id_to_rg{ $row->{release_group} }->[0]);

        $id_to_rg{ $row->{release_group} }->[0]->cover_art($artwork);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012,2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
