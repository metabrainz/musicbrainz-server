package MusicBrainz::Server::Facade::CdToc;

use strict;
use warnings;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw{
    cdtoc
    disc_id
    duration
    first_track
    freedb_id
    last_track
    tracks
});

sub entity_type { 'cdtoc' }

sub new_from_cdtoc
{
    my ($class, $cdtoc) = @_;

    my $tracks = [];

    my $offsets = $cdtoc->GetTrackOffsets;
    my $lengths = $cdtoc->GetTrackLengths;

    for my $n ($cdtoc->GetFirstTrack .. $cdtoc->GetLastTrack)
    {
        my $start  = $offsets->[$n-1];
        my $length = $lengths->[$n-1];

        push @{$tracks}, {
            'number'   => $n,
            start => {
                'time'    => _fmt($start),
                'sectors' => $start,
            },
            length => {
                'time'    => _fmt($length),
                'sectors' => $length,
            },
            end => {
                'time'    => _fmt($start + $length),
                'sectors' => $start + $length,
            },
        };
    }

    return $class->new({
        cdtoc       => $cdtoc->GetTOC,
        disc_id     => $cdtoc->GetDiscID, 
        duration    => MusicBrainz::Server::Track::FormatTrackLength($cdtoc->GetLeadoutOffset / 75 * 1000),
        first_track => $cdtoc->GetFirstTrack,
        freedb_id   => $cdtoc->GetFreeDBID,
        last_track  => $cdtoc->GetLastTrack,
        tracks      => $tracks,
    });
}

sub _fmt
{
    MusicBrainz::Server::Track::FormatTrackLength($_[0]/75*1000)
};

1;
