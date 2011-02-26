package MusicBrainz::Server::WebService::2::Representation::XML::Role::Comment;
use Moose::Role;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

around serialize_inner => sub {
    my ($inner, $self, $entity, @args) = @_;
    return (
        $entity->comment ? $self->xml->disambiguation($entity->comment) : (),
        $self->$inner($entity, @args)
    );
};

1;
