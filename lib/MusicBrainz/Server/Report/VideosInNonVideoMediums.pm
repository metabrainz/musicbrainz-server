package MusicBrainz::Server::Report::VideosInNonVideoMediums;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

my $NON_VIDEO_FORMATS = join(',', (
    1, # CD
    3, # SACD
    6, # MiniDisc
    7, # Vinyl
    8, # Cassette
    10, # Reel-to-reel
    14, # Wax Cylinder
    15, # Piano Roll
    16, # DCC
    25, # HDCD
    29, # 7" Vinyl
    30, # 10" Vinyl
    31, # 12" Vinyl
    34, # 8cm CD
    36, # SHM-CD
    37, # HQCD
    38, # Hybrid SACD
    42, # Enhanced CD
    44, # DTS CD
    50, # Edison Diamond Disc
    51, # Flexi-disc
    52, # 7" Flexi-disc
    53, # Shellac
    54, # 10" Shellac
    55, # 12" Shellac
    56, # 7" Shellac
    57, # SHM-SACD
    58, # Pathé disc
    61, # Copy Control CD
    63, # Hybrid SACD (CD layer)
    64, # Hybrid SACD (SACD layer)
    67, # DualDisc (CD side)
    70, # DVDplus (CD side)
    73, # Phonograph record
    74, # PlayTape
    75, # HiPac
    81, # VinylDisc (Vinyl side)
    82, # VinylDisc (CD side)
    83, # Microcassette
    84, # SACD (2 channels)
    85, # SACD (multichannel)
    86, # Hybrid SACD (SACD layer, multichannel)
    87, # Hybrid SACD (SACD layer, 2 channels)
    88, # SHM-SACD (multichannel)
    89, # SHM-SACD (2 channels)
    90, # Tefifon
    128, # DataPlay
    129, # Mixed Mode CD
));

sub query {<<~"SQL"}
    SELECT
        q.id AS recording_ID,
        row_number() OVER (ORDER BY q.aname COLLATE musicbrainz, q.rname COLLATE musicbrainz)
    FROM (
        SELECT DISTINCT
            r.id,
            ac.name AS aname,
            r.name AS rname
        FROM
            recording r
            JOIN artist_credit ac ON r.artist_credit = ac.id
            JOIN track t ON t.recording = r.id
            JOIN medium m ON t.medium = m.id
        WHERE
            r.video IS TRUE
            AND t.is_data_track IS FALSE
            AND m.format IN ($NON_VIDEO_FORMATS)
    ) AS q
    SQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
