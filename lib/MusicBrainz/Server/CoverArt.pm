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

1;
