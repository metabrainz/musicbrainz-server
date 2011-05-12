package MusicBrainz::Server::WebService::Serializer::XML::1::Role::Rating;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw( list_of );

around 'serialize' => sub
{
    my ($orig, $self, $entity, $inc, $data) = @_;
    my @body = $self->$orig($entity, $inc, $data);

    push @body, ( $self->gen->rating({ 'votes-count' => $entity->rating_count }, int($entity->rating / 20) ) )
        if $inc && $inc->ratings;

    push @body, ( $self->gen->user_rating(int($entity->user_rating / 20)) )
        if $entity->user_rating && $inc && $inc->user_ratings;

    return @body;
};

1;
