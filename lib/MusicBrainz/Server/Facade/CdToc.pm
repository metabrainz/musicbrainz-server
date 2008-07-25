package MusicBrainz::Server::Facade::CdToc;

use strict;
use warnings;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw{
    disc_id
    duration
});

sub entity_type { 'cdtoc' }

sub new_from_cdtoc
{
    my ($class, $cdtoc) = @_;

    return $class->new({
        disc_id   => $cdtoc->GetDiscID, 
        duration  => MusicBrainz::Server::Track::FormatTrackLength($cdtoc->GetLeadoutOffset / 75 * 1000),
    });
}

1;
