package MusicBrainz::Server::Data::CoverArtArchive;
use Moose;

with 'MusicBrainz::Server::Data::Role::Sql';
use DBDefs;
use Net::Amazon::S3::Policy qw( starts_with );
use Net::CoverArtArchive qw( find_available_artwork );
use Net::CoverArtArchive::CoverArt;
use Time::HiRes qw( time );

my $caa = Net::CoverArtArchive->new (cover_art_archive_prefix => DBDefs->COVER_ART_ARCHIVE_DOWNLOAD_PREFIX);

sub find_available_artwork {
    my ($self, $mbid) = @_;

    my $prefix = DBDefs->COVER_ART_ARCHIVE_DOWNLOAD_PREFIX."/release/$mbid";

    return [
        map {
            Net::CoverArtArchive::CoverArt->new(
                %$_,
                image => sprintf('%s/%s.jpg', $prefix, $_->{id}),
                large_thumbnail => sprintf('%s/%s-500.jpg', $prefix, $_->{id}),
                small_thumbnail => sprintf('%s/%s-250.jpg', $prefix, $_->{id}),
            );
        } @{ $self->sql->select_list_of_hashes(
            'SELECT index_listing.*, release.gid
             FROM cover_art_archive.index_listing
             JOIN musicbrainz.release ON index_listing.release = release.id
             WHERE release.gid = ? ORDER BY ordering',
            $mbid
        ) }
    ];
};

sub get_stats_for_release {
    my ($self, $release_id) = @_;
    my $stats = $self->sql->select_list_of_hashes(
    'SELECT COUNT(*) total,
            bool_or(is_front) front,
            bool_or(is_back) back
     FROM cover_art_archive.index_listing
     WHERE release = ?',
     $release_id);
    return $stats->[0];
}

sub fresh_id {
    return int((time() - 1327528905) * 100);
}

=method post_fields

Generate the policy and form values to upload cover art.

=cut

sub post_fields
{
    my ($self, $bucket, $mbid, $id, $opts) = @_;

    my $mime_type = $opts->{mime_type} // "image/jpeg";
    my $redirect = $opts->{redirect};
    my $suffix = $self->c->model('CoverArt')->image_type_suffix ($mime_type);

    my $access_key = DBDefs->COVER_ART_ARCHIVE_ACCESS_KEY;
    my $secret_key = DBDefs->COVER_ART_ARCHIVE_SECRET_KEY;

    my $policy = Net::Amazon::S3::Policy->new(expiration => int(time()) + 3600);
    my $filename = "mbid-$mbid-$id.$suffix";

    my %extra_fields = (
        "x-archive-auto-make-bucket" => 1,
        "x-archive-meta-collection" => 'coverartarchive',
        "x-archive-meta-mediatype" => 'image',
    );

    $policy->add ({'bucket' => $bucket});
    $policy->add ({'acl' => 'public-read'});
    $policy->add ({'success_action_redirect' => $redirect }) if $redirect;
    $policy->add ('$key eq '.$filename);
    $policy->add ('$content-type starts-with '.$mime_type);

    for my $field (keys %extra_fields) {
        $policy->add("$field eq " . $extra_fields{$field});
    }

    return {
        AWSAccessKeyId => $access_key,
        policy => $policy->base64(),
        signature => $policy->signature_base64($secret_key),
        key => $filename,
        acl => 'public-read',
        "content-type" => $mime_type,
        success_action_redirect => $redirect,
        %extra_fields
    };
}

sub insert_cover_art {
    my ($self, $release_id, $edit, $cover_art_id, $position, $types, $comment, $mime_type) = @_;

    # make sure the $cover_art_position slot is available.
    $self->sql->do(
        ' UPDATE cover_art_archive.cover_art
             SET ordering = ordering + 1
           WHERE release = ? and ordering >= ?;',
        $release_id, $position);

    $self->sql->do(
        'INSERT INTO cover_art_archive.cover_art (release, mime_type, edit, ordering, id, comment)
         VALUES (?, ?, ?, ?, ?, ?)',
        $release_id, $mime_type, $edit, $position, $cover_art_id, $comment);

    for my $type_id (@$types)
    {
        $self->sql->do(
            'INSERT INTO cover_art_archive.cover_art_type (id, type_id) VALUES (?, ?)',
            $cover_art_id, $type_id);
    };
}

sub update_cover_art {
    my ($self, $release_id, $cover_art_id, $types, $comment) = @_;


    if (defined $comment)
    {
        $self->sql->do(
            'UPDATE cover_art_archive.cover_art SET comment = ? WHERE id = ?',
            $comment, $cover_art_id);
    }

    if (defined $types)
    {
        $self->sql->do(
            'DELETE FROM cover_art_archive.cover_art_type WHERE id = ?',
            $cover_art_id);

        for my $type_id (@$types)
        {
            $self->sql->do(
                'INSERT INTO cover_art_archive.cover_art_type (id, type_id) VALUES (?, ?)',
                $cover_art_id, $type_id);
        };
    }
}

sub reorder_cover_art {
    my ($self, $release_id, $positions) = @_;

    $self->sql->do(
        'UPDATE cover_art_archive.cover_art SET ordering = position.ordering ' .
        'FROM (VALUES '. (join ", ", (("(?::bigint, ?::integer)") x (keys %$positions))) . ') ' .
        'AS position (id, ordering) WHERE cover_art.id = position.id', %$positions);
}

sub delete {
    my ($self, $id) = @_;
    $self->sql->do('DELETE FROM cover_art_archive.cover_art WHERE id = ?', $id);
}

sub merge_releases {
    my ($self, $new_release, @old_releases) = @_;

    # cover_art_presence enum has 'darkened' as max, and 'absent' as min,
    # so we always want the highest value to be preserved
    $self->sql->do(
        "UPDATE release_meta SET cover_art_presence = (SELECT max(cover_art_presence)
           FROM release_meta WHERE id = any(?))
           WHERE id = ?", [ $new_release, @old_releases ], $new_release);

    for my $old_release (@old_releases) {
        $self->sql->do(
            'UPDATE cover_art_archive.cover_art
             SET release = ?,
               ordering = ordering +
                 coalesce((SELECT max(ordering)
                   FROM cover_art_archive.cover_art
                   WHERE release = ?), 0)
             WHERE release = ?',
            $new_release,
            $new_release,
            $old_release);
    }
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
        $new_release_group_id
    );

    $self->sql->do('
        UPDATE cover_art_archive.release_group_cover_art SET release_group = ?
        WHERE release_group = any(?)',
        $new_release_group_id, $all_ids
    );
}

sub exists {
    my ($self, $id) = @_;
    my $row = $self->c->sql->select_single_value(
        'SELECT TRUE FROM cover_art_archive.cover_art WHERE id = ?', $id
    ) or return undef;
}

1;

=head1 COPYRIGHT

Copyright (C) 2011,2012 MetaBrainz Foundation

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
