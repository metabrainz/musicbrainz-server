package MusicBrainz::Server::Controller::Track;

use strict;
use warnings;

use parent 'Catalyst::Controller';

use MusicBrainz::Server::Adapter;
use MusicBrainz::Server::Adapter::Relations;
use MusicBrainz::Server::Track;

=head1 NAME

MusicBrainz::Server::Controller::Track

=head1 DESCRIPTION

Handles user interaction with C<MusicBrainz::Server::Track> entities.

=head1 METHODS

=head2 relations

Shows all relations to a given track

=cut

sub relations : Local Args(1)
{
    my ($self, $c, $mbid) = @_;

    my $entity = MusicBrainz::Server::Track->new($c->mb->{DBH});
    MusicBrainz::Server::Adapter::LoadEntity($entity, $mbid);

    my $link = MusicBrainz::Server::Link->new($c->mb->{DBH});
    my @links = $link->FindLinkedEntities($entity->GetId, 'track');

    MusicBrainz::Server::Adapter::Relations::NormaliseLinkDirections (\@links, $entity->GetId, 'track');
    @links = MusicBrainz::Server::Adapter::Relations::SortLinks (\@links);
    $c->stash->{relations} = MusicBrainz::Server::Adapter::Relations::ExportLinks (\@links);

    $c->stash->{track} = $entity->ExportStash;
    $c->stash->{template} = 'track/relations.tt';
}

1;
