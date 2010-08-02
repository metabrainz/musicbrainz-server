package MusicBrainz::Server::WebService::Serializer::XML::1::Role::ArtistCredit;
use Moose::Role;
use namespace::autoclean;

use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::ArtistCredit';

before serialize => sub
{
    my ($self, $entity, $inc, $opts) = @_;

    $self->add( ArtistCredit->new->serialize($entity->artist_credit)  )
        if $entity->artist_credit;
};

1;
