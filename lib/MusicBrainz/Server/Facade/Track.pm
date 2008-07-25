package MusicBrainz::Server::Facade::Track;

use strict;
use warnings;

use base 'Class::Accessor';

use MusicBrainz::Server::Track;

__PACKAGE__->mk_accessors(qw{
    duration
    id
    number
    name
    mbid
    puid_count
});

sub entity_type { 'track' }

sub new_from_track
{
    my ($class, $track) = @_;

    $class->new({
        duration   => MusicBrainz::Server::Track::FormatTrackLength($track->GetLength),
        id         => $track->GetId,
        number     => $track->GetSequence,
        name       => $track->GetName,
        mbid       => $track->GetMBId,
        puid_count => 0,

        _t   => $track,
    });
}

1;
