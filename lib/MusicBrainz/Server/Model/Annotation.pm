package MusicBrainz::Server::Model::Annotation;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

use MusicBrainz::Server::Annotation;

sub load_latest
{
    my ($self, $entity) = @_;

    my $annotation = MusicBrainz::Server::Annotation->new($self->dbh);
    $annotation->entity_id($entity->entity_type, $entity->id);

    $annotation->GetLatestAnnotation
        or return undef;

    return $annotation;
}

sub load_revision
{
    my ($self, $entity, $revision) = @_;

    my $annotation = MusicBrainz::Server::Annotation->new($self->dbh);
    $annotation->entity_id($entity->entity_type, $entity->id);

    if ($revision)
    {
        $annotation->id($revision);
        $annotation->LoadFromId
            or return undef;
    }
    else
    {
        $annotation->GetLatestAnnotation
            or return undef;
    }

    return $annotation;
}

sub load_all
{
    my ($self, $entity) = @_;

    my $annotation = MusicBrainz::Server::Annotation->new($self->dbh);
    $annotation->entity_id($entity->entity_type, $entity->id);

    return [ map {
        my $annotation = MusicBrainz::Server::Annotation->new($self->dbh);
        $annotation->id($_);
        $annotation->LoadFromId;

        $annotation;
    } @{ $annotation->GetAnnotationIDs } ];
}

sub update_annotation
{
    my ($self, $entity, $new_annotation, $change_log, $edit_note) = @_;

    my %opts = (
        text      => $new_annotation,
        changelog => $change_log,
    );
    
    use Switch;
    switch ($entity->entity_type)
    {
        case ('artist') {
            $opts{type    } = ModDefs::MOD_ADD_ARTIST_ANNOTATION;
            $opts{artistid} = $entity->id;
        }

        case ('label') {
            $opts{type   } = ModDefs::MOD_ADD_LABEL_ANNOTATION;
            $opts{labelid} = $entity->id;
        }

        case ('release') {
            $opts{type    } = ModDefs::MOD_ADD_RELEASE_ANNOTATION;
            $opts{albumid } = $entity->id;
            $opts{artistid} = $entity->artist;
        }

        case ('track') {
            $opts{type    } = ModDefs::MOD_ADD_TRACK_ANNOTATION;
            $opts{trackid }  = $entity->id;
            $opts{artistid} = $entity->artist;
        }
    }

    $self->context->model('Moderation')->insert($edit_note, %opts);
}

1;
