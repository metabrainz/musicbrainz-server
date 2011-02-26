package MusicBrainz::Server::WebService::2::Representation::XML::Role::List;
use Moose::Role;

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

around attributes => sub {
    my ($attr, $self, $entities) = @_;
    return (
        count => scalar(@$entities),
        $self->$attr($entities)
    );
};

around serialize_inner => sub {
    my ($inner, $self, $entities, @args) = @_;
    return map {
        $self->serialize($_)
    } @$entities;
};

1;
