package MusicBrainz::Server::Model::Annotation;

use strict;
use warnings;

use base 'Catalyst::Model';

use MusicBrainz::Server::Facade::Annotation;

sub ACCEPT_CONTEXT
{
    my ($self, $c) = @_;
    bless { _dbh => $c->mb->{DBH} }, ref $self;
}

sub load_latest_annotation
{
    my ($self, $entity) = @_;

    my $annotation = MusicBrainz::Server::Annotation->new($self->{_dbh});
    $annotation->SetEntity($entity->entity_type, $entity->id);

    $annotation->GetLatestAnnotation
        or return;

    return MusicBrainz::Server::Facade::Annotation->new_from_annotation($annotation);
}

1;
