package MusicBrainz::Server::WebService::2::Representation::XML::ISRC;
use Moose;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

sub element { 'isrc' }

sub serialize_inner {
    my ($self, $isrc, %extra) = @_;
    return $isrc->isrc;
}

1;
