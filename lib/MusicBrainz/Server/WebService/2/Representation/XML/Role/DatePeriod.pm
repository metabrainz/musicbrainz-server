package MusicBrainz::Server::WebService::2::Representation::XML::Role::DatePeriod;
use Moose::Role;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

around serialize_inner => sub {
    my ($inner, $self, $entity, @args) = @_;
    return (
        $self->serialize(bless [
            $entity->begin_date, $entity->end_date
        ], 'MusicBrainz::Server::Entity::DateSpan'),
        $self->$inner($entity, @args)
    );
};

1;
