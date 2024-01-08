package MusicBrainz::Server::Data::CoverArt;

use Moose;
use MusicBrainz::Server::Entity::Release;
use MusicBrainz::Server::Data::Utils qw(
    object_to_ids
    placeholders
);

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Art',
     'MusicBrainz::Server::Data::Role::PendingEdits' => {
         table => 'cover_art_archive.cover_art',
     };

sub art_archive_model { shift->c->model('CoverArtArchive') }

sub _entity_class
{
    my ($self, $row) = @_;
    if (defined $row && exists $row->{release_group}) {
        return 'MusicBrainz::Server::Entity::ReleaseGroupArt';
    } else {
        return 'MusicBrainz::Server::Entity::ReleaseArt';
    }
}

sub find_by_release
{
    my ($self, @releases) = @_;

    return $self->find_by_entity(\@releases);
}

sub find_front_cover_by_release
{
    my ($self, @releases) = @_;

    return $self->find_front_artwork_by_entity(\@releases);
}

sub find_count_by_release
{
    my ($self, $release_id) = @_;

    return $self->find_count_by_entity($release_id);
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
