package MusicBrainz::Server::CoverArt;
use Moose;
use namespace::autoclean;

use MooseX::Types::URI qw( Uri );

has 'image_uri' => (
    isa => Uri,
    is  => 'ro',
    coerce => 1
);

has 'provider' => (
    isa => 'MusicBrainz::Server::CoverArt::Provider',
    is  => 'ro',
);

has 'information_uri' => (
    isa => Uri,
    is  => 'rw',
    coerce => 1,
);

sub cache_data
{
    my $self = shift;
    return {
        info_url     => $self->information_uri
    }
}

1;
