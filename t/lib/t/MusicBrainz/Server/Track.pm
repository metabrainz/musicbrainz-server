package t::MusicBrainz::Server::Track;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Track;

test 'Check UnformatTrackLength' => sub {
    is (MusicBrainz::Server::Track::UnformatTrackLength('9000:20'),
        540020000, 'Absurdly long track lengths');
    is (MusicBrainz::Server::Track::UnformatTrackLength('933 ms'),
        933, 'Millisecond track lengths');
    is (MusicBrainz::Server::Track::UnformatTrackLength('20:30'),
        1230000, 'Reasonable track lengths');
    is (MusicBrainz::Server::Track::UnformatTrackLength('?:??'),
        undef, 'Undefined track lengths');
};

test 'Check FormatTrackLength' => sub {
    is (MusicBrainz::Server::Track::FormatTrackLength(undef),
        '?:??', 'Undefined track');
    is (MusicBrainz::Server::Track::FormatTrackLength('432'),
        '432 ms', 'Short track');
    is (MusicBrainz::Server::Track::FormatTrackLength('9000'),
        '0:09', 'Short track');
    is (MusicBrainz::Server::Track::FormatTrackLength('1820000'),
        '30:20', 'Medium track');
    is (MusicBrainz::Server::Track::FormatTrackLength('181100000'),
        '3018:20', 'Long track');
};

1;
