package MusicBrainz::Server::Adapter;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT_OK = qw( LoadEntity EntityUrl Google );

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

=head2 Google $query.

Form a Google search URL, with the MusicBrainz colours.

=cut

sub Google
{
    my $query = shift;

    my $google_domain = "google.com";

    return sprintf "http://%s/custom?q=%s&sa=%s&cof=%s&domains=%s&ie=%s&oe=%s",
        $google_domain, $query, "Google+Search", 
        "GIMP%3A%23b78242%3BT%3A%23000000%3BLW%3A604%3BALC%3A%2300FFFF%3BL%3A"
        . "http%3A%2F%2Fwww.musicbrainz.org%2Fimages%2Fgoogle%2Epng%3BGFNT%3A"
        . "%23CCCCC%3BLC%3A%23736DAB%3BLH%3A89%3BBGC%3A%23FFFFFF%3BAH%3Acenter"
        . "%3BVLC%3A%23734D8B%3BGALT%3A%23b78242%3BAWFID%3Af7ac0473f1a88aef%3B",
        "musicbrainz.org", "utf-8", "utf-8";
}

1;
