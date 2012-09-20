package MusicBrainz::Server::Data::CoverArtArchive;
use Moose;

with 'MusicBrainz::Server::Data::Role::Sql';
use DBDefs;
use Net::Amazon::S3::Policy qw( starts_with );
use Net::CoverArtArchive qw( find_available_artwork );
use Net::CoverArtArchive::CoverArt;
use Time::HiRes qw( time );

my $caa = Net::CoverArtArchive->new (cover_art_archive_prefix => &DBDefs::COVER_ART_ARCHIVE_DOWNLOAD_PREFIX);

sub find_available_artwork {
    my ($self, $mbid) = @_;

    my $prefix = DBDefs::COVER_ART_ARCHIVE_DOWNLOAD_PREFIX."/release/$mbid";

    my $types = { map { $_->name => $_ } $self->c->model('CoverArtType')->get_all() };

    return [
        map {
            Net::CoverArtArchive::CoverArt->new(
                %$_,
                image => sprintf('%s/%s.jpg', $prefix, $_->{id}),
                large_thumbnail => sprintf('%s/%s-500.jpg', $prefix, $_->{id}),
                small_thumbnail => sprintf('%s/%s-250.jpg', $prefix, $_->{id}),
            );
        } map {
            $_->{types} = [ map { $types->{$_}->l_name } @{ $_->{types} } ];
            $_;
        }
        @{ $self->sql->select_list_of_hashes(
            'SELECT index_listing.*, release.gid
             FROM cover_art_archive.index_listing
             JOIN musicbrainz.release ON index_listing.release = release.id
             WHERE release.gid = ? ORDER BY ordering',
            $mbid
        ) }
    ];
};

sub fresh_id {
    return int((time() - 1327528905) * 100);
}

=method post_fields

Generate the policy and form values to upload cover art.

=cut

sub post_fields
{
    my ($self, $bucket, $mbid, $id, $redirect) = @_;

    my $aws_id = &DBDefs::COVER_ART_ARCHIVE_ID;
    my $aws_key = &DBDefs::COVER_ART_ARCHIVE_KEY;

    my $policy = Net::Amazon::S3::Policy->new(expiration => int(time()) + 3600);
    my $filename = "mbid-$mbid-" . $id . '.jpg';

    $policy->add ({'bucket' => $bucket});
    $policy->add ({'acl' => 'public-read'});
    $policy->add ({'success_action_redirect' => $redirect});
    $policy->add ('$key eq '.$filename);
    $policy->add ('$content-type starts-with image/jpeg');
    $policy->add ('x-archive-auto-make-bucket eq 1');
    $policy->add ('x-archive-meta-collection eq coverartarchive');
    $policy->add ('x-archive-meta-mediatype eq images');

    return {
        AWSAccessKeyId => $aws_id,
        policy => $policy->base64(),
        signature => $policy->signature_base64($aws_key),
        key => $filename,
        acl => 'public-read',
        "content-type" => 'image/jpeg',
        success_action_redirect => $redirect,
        "x-archive-auto-make-bucket" => 1,
        "x-archive-meta-collection" => 'coverartarchive',
        "x-archive-meta-mediatype" => 'images',
    };
}

sub insert_cover_art {
    my ($self, $release_id, $edit, $cover_art_id, $position, $types, $comment) = @_;

    # make sure the $cover_art_position slot is available.
    $self->sql->do(
        ' UPDATE cover_art_archive.cover_art
             SET ordering = ordering + 1
           WHERE release = ? and ordering >= ?;',
        $release_id, $position);

    $self->sql->do(
        'INSERT INTO cover_art_archive.cover_art (release, edit, ordering, id, comment)
         VALUES (?, ?, ?, ?, ?)',
        $release_id, $edit, $position, $cover_art_id, $comment);

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
