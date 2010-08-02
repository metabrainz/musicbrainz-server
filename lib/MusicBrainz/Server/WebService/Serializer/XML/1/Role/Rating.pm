package MusicBrainz::Server::WebService::Serializer::XML::1::Role::Rating;
use Moose::Role;
use namespace::autoclean;

use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::List';

before 'serialize' => sub
{
    my ($self, $entity, $inc, $data) = @_;

    $self->add( $self->gen->rating({ 'votes-count' => $entity->rating_count }, $entity->rating ) )
        if $inc && $inc->ratings;
};

1;
