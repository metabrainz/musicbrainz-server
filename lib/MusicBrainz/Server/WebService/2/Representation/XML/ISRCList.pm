package MusicBrainz::Server::WebService::2::Representation::XML::ISRCList;
use Moose;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

sub serialize_resource {
    my ($self, $isrcs) = @_;
    $self->xml->isrc_list(
        { count => scalar(@$isrcs) },
        map { $self->serialize($_) } @$isrcs
    )
}

1;
