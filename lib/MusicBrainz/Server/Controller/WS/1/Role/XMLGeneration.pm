package MusicBrainz::Server::Controller::WS::1::Role::XMLGeneration;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::XML::Generator;

has 'gen' => (
    is => 'ro',
    default => sub { MusicBrainz::XML::Generator->new }
);

1;
