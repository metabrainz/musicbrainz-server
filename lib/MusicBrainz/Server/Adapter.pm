package MusicBrainz::Server::Adapter;

use strict;
use warnings;

use Carp;
use MusicBrainz::Server::Artist;
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Track;
use MusicBrainz::Server::URL;
use MusicBrainz::Server::Validation;

=head1 NAME

MusicBrainz::Server::Adapter - General Catalyst helper functions

=head1 DESCRIPTION

This contains general helper functions that are used over many Catalyst
routines in different packages (such as loading by either row ID or MBID)

=head1 METHODS

=head2 LoadEntity $mbid, $entity

Load an entity from either an MBID or row ID - and die on invalid data.

$mbid is the mbid/row id of the $entity. $entity is an instance of the
entity type - with a database handle.

=cut

sub LoadEntity
{
    my ($entity, $mbid) = @_;

    croak "No entity given"
        unless defined $entity and ref $entity;

    if(MusicBrainz::Server::Validation::IsGUID($mbid))
    {
        $entity->SetMBId($mbid);
    }
    else
    {
        if(MusicBrainz::Server::Validation::IsNonNegInteger($mbid))
        {
            $entity->SetId($mbid);
        }
        else
        {
            croak "$mbid is not a valid MBID or row ID";
        }
    }

    $entity->LoadFromId(1)
        or croak "Could not load entity";
}

1;
