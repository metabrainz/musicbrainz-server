package MusicBrainz::Server::Controller::WS::1::Role::Serializer;
use Moose::Role;
use namespace::autoclean;

use aliased 'MusicBrainz::Server::WebService::XMLSerializerV1';

has 'serializer' => (
    is => 'ro',
    default => sub { XMLSerializerV1->new }
);

1;
