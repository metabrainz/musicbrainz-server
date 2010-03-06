package MusicBrainz::Server::CoverArt;
use Moose;

has 'image_uri' => (
    isa => 'Str',
    is  => 'ro',
);

has 'provider' => (
    isa => 'MusicBrainz::Server::CoverArt::Provider',
    is  => 'ro',
);

has 'information_uri' => (
    isa => 'Str',
    is  => 'rw',
);

sub cache_data
{
    my $self = shift;
    return {
        coverarturl => $self->image_uri,
        infourl     => $self->information_uri
    }
}

1;
