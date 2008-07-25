package MusicBrainz::Server::Model::CdToc;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use MusicBrainz::Server::Facade::CdToc;

sub load_for_release
{
    my ($self, $release) = @_;

    my $disc_ids = $release->get_release->GetDiscIDs;

    [ map {
        MusicBrainz::Server::Facade::CdToc->new_from_cdtoc($_->GetCDTOC)
    } @$disc_ids ];
}

1;
