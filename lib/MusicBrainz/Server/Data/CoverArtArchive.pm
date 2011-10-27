package MusicBrainz::Server::Data::CoverArtArchive;
use Moose;

with 'MusicBrainz::Server::Data::Role::Context';

use DBDefs;
use Net::Amazon::S3;
use XML::XPath;

use aliased 'Net::Amazon::S3::Request::DeleteBucket';
use aliased 'Net::Amazon::S3::Request::DeleteObject';

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

1;
