package MusicBrainz::Server::WebService::Representation::2::XML::Recording;
use Moose;

with 'MusicBrainz::Server::WebService::Representation::2::XML::Serializer';

sub serialize_resource {
    my ($self, $recording, %extra) = @_;
    return $self->xml->recording(
        { id => $recording->gid },
        $self->xml->name( $recording->name ),
        $self->serialize($recording->artist_credit),
        map { $self->serialize($_) } @{ $extra{inline} || [] }
    );
}

1;
