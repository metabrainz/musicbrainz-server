package MusicBrainz::Server::Data::CoverArtArchive;
use Moose;
use namespace::autoclean;
use DBDefs;

with 'MusicBrainz::Server::Data::Role::ArtArchive';

sub art_archive_name { 'cover' }
sub art_archive_entity { 'release' }
sub art_archive_type_booleans { qw( is_front is_back ) }
sub art_model_name { 'CoverArt' }
sub download_prefix { DBDefs->COVER_ART_ARCHIVE_DOWNLOAD_PREFIX }

sub get_stats_for_releases { shift->get_stats_for_entities(@_) }

sub insert_cover_art { shift->insert_art(@_) }

sub update_cover_art { shift->update_art(@_) }

sub reorder_cover_art { shift->reorder_art(@_) }

sub merge_releases {
    my ($self, $new_release, @old_releases) = @_;

    $self->merge_entities($new_release, @old_releases);
}

sub merge_release_groups {
    my ($self, $new_release_group_id, @old_release_groups) = @_;

    my $all_ids = [ $new_release_group_id, @old_release_groups ];
    $self->sql->do('
      DELETE FROM cover_art_archive.release_group_cover_art
      WHERE release_group = any(?) AND release_group NOT IN (
        SELECT release_group
        FROM cover_art_archive.release_group_cover_art
        WHERE release_group = any(?)
        ORDER BY (release_group = ?) DESC
        LIMIT 1
      )',
        $all_ids,
        $all_ids,
        $new_release_group_id,
    );

    $self->sql->do('
        UPDATE cover_art_archive.release_group_cover_art SET release_group = ?
        WHERE release_group = any(?)',
        $new_release_group_id, $all_ids,
    );
}

sub exists_for_release_gid {
    my ($self, $release_gid) = @_;

    $self->exists_for_entity_gid($release_gid);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011,2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
