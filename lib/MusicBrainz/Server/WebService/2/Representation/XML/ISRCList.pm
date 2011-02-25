package MusicBrainz::Server::WebService::2::Representation::XML::ISRCList;
use Moose;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

sub element { 'isrc-list' }

sub attributes {
    my ($self, $isrcs) = @_;
    return { count => scalar(@$isrcs) };
}

sub serialize_inner {
    my ($self, $isrcs) = @_;
    return map { $self->serialize($_) } @$isrcs;
}

1;
