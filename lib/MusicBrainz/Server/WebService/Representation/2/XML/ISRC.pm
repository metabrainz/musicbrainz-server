package MusicBrainz::Server::WebService::Representation::2::XML::ISRC;
use Moose;

with 'MusicBrainz::Server::WebService::Representation::2::XML::Serializer';

sub serialize_resource {
    my ($self, $isrc, %extra) = @_;
    $self->xml->isrc(
        $isrc->isrc
    );
}

1;
