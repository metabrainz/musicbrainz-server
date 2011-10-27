package MusicBrainz::Server::Data::CoverArtArchive;
use Moose;

with 'MusicBrainz::Server::Data::Role::Context';

use DBDefs;
use Net::Amazon::S3;
use Net::CoverArtArchive qw( find_available_artwork find_artwork );
use XML::XPath;

use aliased 'Net::Amazon::S3::Request::DeleteBucket';
use aliased 'Net::Amazon::S3::Request::DeleteObject';
use aliased 'Net::Amazon::S3::Request::PutObject';

has s3 => (
    is => 'ro',
    lazy => 1,
    default => sub {
        Net::Amazon::S3->new(
            aws_access_key_id     => DBDefs::INTERNET_ARCHIVE_ID,
            aws_secret_access_key => DBDefs::INTERNET_ARCHIVE_KEY,
        )
    }
);

my $caa = Net::CoverArtArchive->new;

sub delete_releases {
    my ($self, @mbids) = @_;
    for my $mbid (@mbids) {
        my $bucket = "mbid-$mbid";
        my $res = $self->c->lwp->get("http://s3.amazonaws.com/$bucket");
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
    }
    catch {
        warn "bucket $bucket exists\n";
    }

    return $bucket;
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
            unless ($caa->find_artwork($target_mbid, $artwork->type, $artwork->page)) {
                $self->c->lwp->request(
                    PutObject->new(
                        s3      => $self->s3,
                        bucket  => "mbid-$target_mbid",
                        key     => join('-', 'mbid', $target_mbid,
                                        $artwork->type, $artwork->page) . '.jpg',
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
}

1;
