package MusicBrainz::Server::Edit::Release::RemoveCoverArt;
use Moose;

use DBDefs;

use LWP::UserAgent;
use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_REMOVE_COVER_ART );

use Net::Amazon::S3;
use aliased 'Net::Amazon::S3::Request::DeleteObject';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';

sub edit_name { 'Remove cover art' }
sub edit_type { $EDIT_RELEASE_REMOVE_COVER_ART }
sub release_ids { shift->data->{entity}{id} }

has '+data' => (
    isa => Dict[
        entity => Dict[
            id   => Int,
            name => Str,
            mbid => Str
        ],
        cover_art_url  => Str
    ]
);

has s3 => (
    is => 'ro',
    lazy => 1,
    default => sub {
        Net::Amazon::S3->new(
            aws_access_key_id     => DBDefs::CA_PUBLIC,
            aws_secret_access_key => DBDefs::CA_PRIVATE,
        )
    }
);

has lwp => (
    is => 'ro',
    default => sub {
        return LWP::UserAgent->new;
    }
);

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
    });
}

sub accept {
    my $self = shift;

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
            || Release->new( name => $self->data->{entity}{name} )
    };
}


1;
