package MusicBrainz::Server::WebService::Serializer::XML::1::Role::Tags;
use Moose::Role;
use namespace::autoclean;

use List::UtilsBy 'sort_by';
use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw( list_of );

around serialize => sub
{
    my ($orig, $self, $entity, $inc, $data) = @_;
    my @body = $self->$orig($entity, $inc, $data);

    push @body, (
        list_of([ sort_by { $_->tag->name } @{ $data->{tags} } ])
    )
        if $inc && $inc->tags;

    push @body, (
        list_of([ sort_by { $_->tag->name } @{ $data->{user_tags} } ])
    )
        if $inc && $inc->user_tags;

    return @body
};

1;
