package MusicBrainz::Server::Edit::Release::AddCoverArt;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_COVER_ART );

use aliased 'Net::Amazon::S3::Request::CreateBucket';
use aliased 'Net::Amazon::S3::Request::DeleteObject';
use aliased 'Net::Amazon::S3::Request::PutObject';

use Net::CoverArtArchive;

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';

sub edit_name { 'Add cover art' }
sub edit_type { $EDIT_RELEASE_ADD_COVER_ART }
sub release_ids { shift->data->{entity}{id} }

has '+data' => (
    isa => Dict[
        entity => Dict[
            id   => Int,
            name => Str,
            mbid => Str
        ],
        cover_art_type => Str,
        cover_art_page => Int,
        cover_art_url  => Str
    ]
);

sub lwp { shift->c->lwp }
sub s3 { shift->c->model('CoverArtArchive')->s3 }

has bucket_name => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return 'mbid-' . $self->data->{entity}{mbid};
    }
);

sub initialize {
    my ($self, %opts) = @_;
    my $release = $opts{release} or die 'Release missing';

    $self->data({
        entity => {
            id => $release->id,
            name => $release->name,
            mbid => $release->gid
        },
        cover_art_url => $opts{cover_art_url},
        cover_art_type => $opts{cover_art_type},
        cover_art_page => $opts{cover_art_page},
    });
}

sub accept {
    my $self = shift;

    my $target_url = join(
        '-',
        'mbid',
        $self->data->{entity}{mbid},
        $self->data->{cover_art_type},
        $self->data->{cover_art_page}
    ) . '.jpg';

    my $edit_id = $self->id;

    # Remove the existing image
    my $res = $self->lwp->request(
        DeleteObject->new(
            s3     => $self->s3,
            bucket => $self->bucket_name,
            key    => $target_url
        )->http_request
    );

    # Move this cover art to replace it
    $res = $self->lwp->request(
        PutObject->new(
            s3      => $self->s3,
            bucket  => $self->bucket_name,
            key     => $target_url,
            headers => {
                'x-amz-copy-source' => '/' . $self->bucket_name . '/' . $self->data->{cover_art_url}
            },
            value => ''
        )->http_request
    );

    # Remove the pending stuff
    $self->cleanup;
}

sub reject {
    shift->cleanup;
}

sub cleanup {
    my $self = shift;

    # Remove the pending stuff
    $self->lwp->request(
        DeleteObject->new(
            s3     => $self->s3,
            bucket => $self->bucket_name,
            key    => $self->data->{cover_art_url}
        )->http_request
    );
}

sub foreign_keys {
    my ($self) = @_;
    return {
        Release => {
            $self->data->{entity}{id} => [ 'ArtistCredit' ]
        }
    };
}

sub build_display_data {
    my ($self, $loaded) = @_;
    return {
        release => $loaded->{Release}{ $self->data->{entity}{id} }
            || Release->new( name => $self->data->{entity}{name} ),
        artwork => Net::CoverArtArchive->new->find_artwork(
            $self->data->{entity}{mbid},
            $self->data->{cover_art_type},
            $self->data->{cover_art_page}
        )
    };
}

1;
