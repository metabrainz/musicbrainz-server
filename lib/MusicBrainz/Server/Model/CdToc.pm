package MusicBrainz::Server::Model::CdToc;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

use Carp;
use MusicBrainz::Server::CDTOC;

sub load_for_release
{
    my ($self, $release) = @_;

    my $disc_ids = $release->GetDiscIDs;

    return [ map { $_->GetCDTOC } @$disc_ids ];
}

sub load
{
    my ($self, $id) = @_;

    my $cdtoc = MusicBrainz::Server::CDTOC->newFromId($self->dbh, $id);

    return $cdtoc;
}

sub get_attached_release_ids
{
    my ($self, $cdtoc) = @_;

    my $all_cdtocs = $cdtoc->release_cdtocs;
    return [ map { $_->release_id } @{$all_cdtocs} ];
}

1;
