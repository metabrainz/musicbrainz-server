package MusicBrainz::Server::Model::CdToc;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use Carp;
use MusicBrainz::Server::CDTOC;
use MusicBrainz::Server::Facade::CdToc;

sub load_for_release
{
    my ($self, $release) = @_;

    my $disc_ids = $release->get_release->GetDiscIDs;

    [ map {
        MusicBrainz::Server::Facade::CdToc->new_from_cdtoc($_->GetCDTOC)
    } @$disc_ids ];
}

sub load
{
    my ($self, $id) = @_;

    my $cdtoc = MusicBrainz::Server::CDTOC->newFromId($self->dbh, $id)
        or croak "Could not load CDTOC with id $id";

    return MusicBrainz::Server::Facade::CdToc->new_from_cdtoc($cdtoc);
}

sub get_attached_release_ids
{
    my ($self, $cdtoc) = @_;

    my $all_cdtocs = $cdtoc->get_cdtoc->release_cdtocs;
    return [ map { $_->release_id } @{$all_cdtocs} ];
}

1;
