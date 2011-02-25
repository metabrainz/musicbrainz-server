package MusicBrainz::Server::WebService::Representation::2::XML::ISRCList;
use Moose;

with 'MusicBrainz::Server::WebService::Representation::2::XML::Serializer';

sub serialize_resource {
    my ($self, $isrcs) = @_;
    $self->xml->isrc_list(
        { count => scalar(@$isrcs) },
        map { $self->serialize($_) } @$isrcs
    )
}

1;
