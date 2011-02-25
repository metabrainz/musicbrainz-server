package MusicBrainz::Server::WebService::2::Representation::XML::Recording;
use Moose;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

sub element { 'recording' }

sub attributes {
    my ($self, $recording) = @_;
    { id => $recording->gid };
}

sub serialize_inner {
    my ($self, $recording, %extra) = @_;
    return (
        $self->xml->name( $recording->name ),
        $self->serialize($recording->artist_credit),
        map { $self->serialize($_) } @{ $extra{inline} || [] }
    );
}

1;
