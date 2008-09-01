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

sub get_cdtoc { shift->{_toc}; }

sub entity_type { 'cdtoc' }

sub new_from_cdtoc
{
    my ($class, $cdtoc) = @_;

    my $tracks = [];

    my $offsets = $cdtoc->track_offsets;
    my $lengths = $cdtoc->track_lengths;

    for my $n ($cdtoc->first_track .. $cdtoc->last_track)
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
        cdtoc       => $cdtoc->toc,
        disc_id     => $cdtoc->disc_id, 
        duration    => MusicBrainz::Server::Track::FormatTrackLength($cdtoc->leadout_offset / 75 * 1000),
        first_track => $cdtoc->first_track,
        freedb_id   => $cdtoc->freedb_id,
        last_track  => $cdtoc->last_track,
        tracks      => $tracks,

        _toc        => $cdtoc,
    });
}

sub _fmt
{
    MusicBrainz::Server::Track::FormatTrackLength($_[0]/75*1000)
};

1;
