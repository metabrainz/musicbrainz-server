package MusicBrainz::Server::WebService::2::Representation::XML::Role::GID;
use Moose::Role;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

around attributes => sub {
    my ($attr, $self, $entity) = @_;
    use Carp;
    Carp::confess('Undef') unless $entity;
    return (
        id => $entity->gid,
        $self->$attr($entity)
    );
};

1;
