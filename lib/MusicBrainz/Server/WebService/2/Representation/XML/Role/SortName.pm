package MusicBrainz::Server::WebService::2::Representation::XML::Role::SortName;
use Moose::Role;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

around serialize_inner => sub {
    my ($inner, $self, $entity, @args) = @_;
    return (
        $self->xml->sort_name($entity->name),
        $self->$inner($entity, @args)
    );
};

1;
