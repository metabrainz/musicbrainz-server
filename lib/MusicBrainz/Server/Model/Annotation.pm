package MusicBrainz::Server::Model::Annotation;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

use MusicBrainz::Server::Annotation;

sub load_latest_annotation
{
    my ($self, $entity) = @_;

    my $annotation = MusicBrainz::Server::Annotation->new($self->dbh);
    $annotation->entity_id($entity->entity_type, $entity->id);

    $annotation->GetLatestAnnotation
        or return undef;

    return $annotation;
}

1;
