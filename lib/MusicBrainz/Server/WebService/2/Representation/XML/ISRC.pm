package MusicBrainz::Server::WebService::2::Representation::XML::ISRC;
use Moose;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

sub serialize_resource {
    my ($self, $isrc, %extra) = @_;
    $self->xml->isrc(
        $isrc->isrc
    );
}

1;
