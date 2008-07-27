package MusicBrainz::Server::Model::Annotation;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use MusicBrainz::Server::Facade::Annotation;

sub load_latest_annotation
{
    my ($self, $entity) = @_;

    my $annotation = MusicBrainz::Server::Annotation->new($self->dbh);
    $annotation->SetEntity($entity->entity_type, $entity->id);

    $annotation->GetLatestAnnotation
        or return;

    return MusicBrainz::Server::Facade::Annotation->new_from_annotation($annotation);
}

1;
