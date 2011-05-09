package MusicBrainz::Server::Controller::WS::1::Role::XMLGeneration;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::XML;

has 'gen' => (
    is => 'ro',
    default => sub { MusicBrainz::XML->new }
);

1;
