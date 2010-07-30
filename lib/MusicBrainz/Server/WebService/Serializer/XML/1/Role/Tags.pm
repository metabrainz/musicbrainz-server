package MusicBrainz::Server::WebService::Serializer::XML::1::Role::Tags;
use Moose::Role;
use namespace::autoclean;

use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::List';

before 'serialize' => sub
{
    my ($self, $entity, $inc, $data) = @_;

    $self->add( List->new->serialize($data->{tags}) )
        if $inc && $inc->tags;
};

1;
