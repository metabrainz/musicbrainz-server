package MusicBrainz::Server::Facade::Track;

use strict;
use warnings;

use base 'Class::Accessor';

use MusicBrainz::Server::Track;

__PACKAGE__->mk_accessors(qw{
    artist_id
    duration
    id
    number
    name
    mbid
    puid_count
    release_id
});

sub entity_type { 'track' }

sub get_track { shift->{_t}; }

sub new_from_track
{
    my ($class, $track) = @_;

    $class->new({
        artist_id  => $track->artist,
        duration   => MusicBrainz::Server::Track::FormatTrackLength($track->GetLength),
        id         => $track->GetId,
        number     => $track->GetSequence,
        name       => $track->GetName,
        mbid       => $track->GetMBId,
        puid_count => 0,
        release_id => $track->release,

        _t   => $track,
    });
}

1;
