package MusicBrainz::WebService::Representation::JSON;
use Moose;

with 'Sloth::Representation';

use JSON::Any;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Label;

sub content_type { 'application/json' }

sub serialize {
    my ($self, $label) = @_;

    return JSON::Any->new( utf8 => 1)->objToJson({
        MusicBrainz::Server::WebService::Serializer::JSON::2::Label->new->serialize($label)
    });
}

1;
