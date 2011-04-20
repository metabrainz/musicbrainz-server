package MusicBrainz::Server::WebService::Serializer::XML::1::Role::Rating;
use Moose::Role;
use namespace::autoclean;

use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::List';

before 'serialize' => sub
{
    my ($self, $entity, $inc, $data) = @_;

    $self->add( $self->gen->rating({ 'votes-count' => $entity->rating_count }, int($entity->rating / 20) ) )
        if $inc && $inc->ratings;

    $self->add( $self->gen->user_rating(int($entity->user_rating / 20)) )
        if $entity->user_rating && $inc && $inc->user_ratings;
};

1;
