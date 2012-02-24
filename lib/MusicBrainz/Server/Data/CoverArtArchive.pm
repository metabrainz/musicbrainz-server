package MusicBrainz::Server::Data::CoverArtArchive;
use Moose;

with 'MusicBrainz::Server::Data::Role::Sql';

use DBDefs;
use Net::Amazon::S3;
use Net::CoverArtArchive qw( find_available_artwork find_artwork );
use XML::XPath;
use Time::HiRes qw( time );
use Try::Tiny;

use aliased 'Net::Amazon::S3::Request::DeleteBucket';
use aliased 'Net::Amazon::S3::Request::DeleteObject';
use aliased 'Net::Amazon::S3::Request::PutObject';

has s3 => (
    is => 'ro',
    lazy => 1,
    default => sub {
        Net::Amazon::S3->new(
            aws_access_key_id     => DBDefs::COVER_ART_ARCHIVE_ID,
            aws_secret_access_key => DBDefs::COVER_ART_ARCHIVE_KEY,
        )
    }
);

my $caa = Net::CoverArtArchive->new (cover_art_archive_prefix => &DBDefs::COVER_ART_ARCHIVE_DOWNLOAD_PREFIX);

sub find_artwork { shift; return $caa->find_artwork(@_); };
sub find_available_artwork { shift; return $caa->find_available_artwork(@_); };

sub delete_releases {
    my ($self, @mbids) = @_;
    for my $mbid (@mbids) {
        my $bucket = "mbid-$mbid";
        my $res = $self->c->lwp->get(&DBDefs::COVER_ART_ARCHIVE_UPLOAD_PREFIX."/release/$mbid/");
        if ($res->is_success) {
            my $xp = XML::XPath->new( xml => $res->content );
            for my $artwork ($xp->find('/ListBucketResult/Contents')->get_nodelist) {
                my $key = $xp->find('Key', $artwork);

                my $req = DeleteObject->new(
                        s3     => $self->s3,
                        bucket => $bucket,
                        key    => $key->string_value
                    )->http_request;

                $res = $self->c->lwp->request(
                    $req
                );
            }

            $res = $self->c->lwp->request(
                DeleteBucket->new(
                    s3     => $self->s3,
                    bucket => $bucket
                )->http_request
            );
        }
    }
}


=method initialize_release

Create the bucket for this MBID.

=cut

sub initialize_release
{
    my ($self, $mbid) = @_;

    my $bucket = "mbid-$mbid";

    try {
        $self->s3->add_bucket ({ bucket => $bucket, acl_short => 'public-read' });
    };

    return $bucket;
}

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

    use Net::Amazon::S3::Policy qw( starts_with );
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

sub merge_releases {
    my ($self, $target_mbid, @source_mbids) = @_;
    for my $source (@source_mbids) {
        my %artwork = $caa->find_available_artwork($source);
        for my $artwork (map { @$_ } values %artwork) {
            my $source_file = join('-', 'mbid', $source, $artwork->type,
                                   $artwork->page) . '.jpg';
            my $source_bucket = "mbid-$source";

            # If the target does not have it, copy it
            unless ($caa->find_artwork($target_mbid, $artwork->id)) {
                $self->c->lwp->request(
                    PutObject->new(
                        s3      => $self->s3,
                        bucket  => "mbid-$target_mbid",
                        key     => join('-', 'mbid', $target_mbid,
                                        $artwork->id) . '.jpg',
                        headers => {
                            'x-amz-copy-source' => "/$source_bucket/$source_file",
                            'x-amz-acl' => 'public-read'
                        },
                        value => ''
                    )->http_request
                )
            }

            # Delete this image
            $self->c->lwp->request(
                DeleteObject->new(
                    s3     => $self->s3,
                    bucket => $source_bucket,
                    key    => $source_file
                )->http_request
            );
        }

        # Delete the bucket
    }

    # Update the target release_meta
    my %gid_map = %{ $self->c->model('Release')->get_by_gids($target_mbid, @source_mbids) };
    $self->c->model('Release')->load_meta(values %gid_map);

    my %states;
    $states{$_} = $_ for map { $_->cover_art_presence } values %gid_map;

    $self->sql->do(
        'UPDATE release_meta SET cover_art_presence = ? WHERE id = ?',
        $states{darkened} || $states{present} || 'absent',
        $gid_map{$target_mbid}->id
    );
}

sub update_cover_art_presence {
    my ($self, $release_id, $present) = @_;
    $self->sql->do(
        'UPDATE release_meta SET cover_art_presence = ?
         WHERE release_id = ? cover_art_presence != ?',
        $present ? 'present' : 'absent',
        $release_id,
        'darkened'
    );
}

sub insert_cover_art {
    my ($self, $release_id, $id, $edit) = @_;
    $self->sql->do(
        'INSERT INTO cover_art_archive.cover_art (release, edit, ordering, id)
         VALUES (?, ?, ?, ?)',
        $release_id, $edit, int(time()), $id
    );
}

1;

=head1 COPYRIGHT

Copyright (C) 2011 MetaBrainz Foundation

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
