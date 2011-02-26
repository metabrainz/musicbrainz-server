package MusicBrainz::Server::WebService::2::Representation::XML::Role::ArtistCredit;
use Moose::Role;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

around serialize_inner => sub {
    my ($inner, $self, $entity, @args) = @_;
    return (
        $self->serialize($entity->artist_credit),
        $self->$inner($entity, @args)
    );
};

1;
