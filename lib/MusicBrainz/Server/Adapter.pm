package MusicBrainz::Server::Adapter;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT_OK = qw( LoadEntity EntityUrl );

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

    if (MusicBrainz::Server::Validation::IsGUID($mbid))
    {
        $entity->SetMBId($mbid);
    }
    else
    {
        if (MusicBrainz::Server::Validation::IsNonNegInteger($mbid))
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

=head2 EntityUrl $c, $entity, $action, [\%query_params]

Generates the URL for viewing a specific entity page. Entity pages are
defined to be pages that are for a certain entity (ie, the tags page
for the artist 'Led Zeppelin').

C<$c> is a reference to the current Catalyst context, which is used to
generate the URI.

C<$entity> should be a reference to the MusicBrainz entity, C<$action>
is a string of which page to view.

The optional C<\%query_params> argument can be used to provide query
parameters for the end of the URL.

=cut

sub EntityUrl
{
    my ($c, $entity, $action, $query_params) = @_;

    my $url = '';

    my $controller = $c->controller($entity->{link_type})
        or die "Not a valid type";

    my $catalyst_action = $controller->action_for($action)
        or die "$action is not a valid action (for $entity->{link_type})";
 
    return $c->uri_for($catalyst_action, [ $entity->{mbid} ], $query_params);
}

1;
