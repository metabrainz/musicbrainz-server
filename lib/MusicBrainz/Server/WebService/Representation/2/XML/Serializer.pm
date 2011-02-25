package MusicBrainz::Server::WebService::Representation::2::XML::Serializer;
use Moose::Role;

use MusicBrainz::XML::Generator;

has xml => (
    is => 'ro',
    default => sub {
        MusicBrainz::XML::Generator->new;
    }
);

has parent => (
    is => 'ro',
    handles => {
        serialize => 'serialize_resource'
    }
);

requires 'serialize_resource';

1;
