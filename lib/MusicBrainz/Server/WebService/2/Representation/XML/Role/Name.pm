package MusicBrainz::Server::WebService::2::Representation::XML::Role::Name;
use Moose::Role;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

around serialize_inner => sub {
    my ($inner, $self, $entity, @args) = @_;
    return (
        $self->xml->name($entity->name),
        $self->$inner($entity, @args)
    );
};

1;
