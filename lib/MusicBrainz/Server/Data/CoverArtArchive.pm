package MusicBrainz::Server::Data::CoverArtArchive;
use Moose;

with 'MusicBrainz::Server::Data::Role::Sql';
use DBDefs;
use Digest::HMAC_SHA1;
use JSON;
use MIME::Base64 qw( encode_base64 );
use Time::HiRes qw( time );

sub get_stats_for_releases {
    my ($self, @release_ids) = @_;
    my $stats = $self->sql->select_list_of_hashes(
    'SELECT release,
            COUNT(*) total,
            bool_or(is_front) front,
            bool_or(is_back) back
     FROM cover_art_archive.index_listing
     WHERE release = any(?)
     GROUP BY release',
     \@release_ids);
    return {
        map {
            my $release = delete $_->{release};
            ($release => $_)
        } @$stats
    };
}

sub fresh_id {
    return int((time() - 1327528905) * 100);
}

=method post_fields

Generate the policy and form values to upload cover art.

=cut

sub post_fields {
    my ($self, $bucket, $mbid, $id, $opts) = @_;

    my $mime_type = $opts->{mime_type} // "image/jpeg";
    my $redirect = $opts->{redirect};
    my $suffix = $self->c->model('CoverArt')->image_type_suffix($mime_type);

    my $access_key = $opts->{access_key} // DBDefs->COVER_ART_ARCHIVE_ACCESS_KEY;
    my $secret_key = $opts->{secret_key} // DBDefs->COVER_ART_ARCHIVE_SECRET_KEY;
    my $filename = "mbid-$mbid-$id.$suffix";

    my %extra_fields = (
        "x-archive-auto-make-bucket" => '1',
        "x-archive-meta-collection" => 'coverartarchive',
        "x-archive-meta-mediatype" => 'image',
        "x-archive-meta-noindex" => 'true',
    );

    my $policy = {
        expiration => $opts->{expiration},
        conditions => [
            {bucket => $bucket},
            {acl => 'public-read'},
            ($redirect ? {success_action_redirect => $redirect} : ()),
            ['eq', '$key', $filename],
            ['starts-with', '$content-type', $mime_type],
            (map { ['eq', "\$$_", $extra_fields{$_}] } sort keys %extra_fields),
        ]
    };

    my $policy_base64 = encode_base64(JSON->new->canonical->utf8->encode($policy), '');
    my $policy_signature_base64 = encode_base64(Digest::HMAC_SHA1::hmac_sha1($policy_base64, $secret_key), '');

    my $ret = {
        AWSAccessKeyId => $access_key,
        policy => $policy_base64,
        signature => $policy_signature_base64,
        key => $filename,
        acl => 'public-read',
        "content-type" => $mime_type,
        %extra_fields
    };

    $ret->{success_action_redirect} = $redirect if $redirect;

    return $ret;
}

sub insert_cover_art {
    my ($self, $release_id, $edit, $cover_art_id, $position, $types, $comment,
        $mime_type) = @_;

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011,2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
