package t::MusicBrainz::Server::Track;
use Test::Routine;
use Test::More;

use utf8;

use MusicBrainz::Server::Track qw( format_track_length unformat_track_length );

test 'Format Track Length' => sub {
    my $seconds = 1000;
    my $minutes = 60 * $seconds;
    my $hours = 60 * $minutes;

    is (format_track_length (23), "23 ms");
    is (format_track_length (23 * $seconds), "0:23");
    is (format_track_length (59 * $minutes), "59:00");
    is (format_track_length (60 * $minutes), "1:00:00");
    is (format_track_length (14 * $hours + 15 * $minutes + 16 * $seconds), "14:15:16");

    is (format_track_length (undef), '?:??', 'Undefined track');
    is (format_track_length ('432'), '432 ms', 'Short track');
    is (format_track_length ('9000'), '0:09', 'Short track');
    is (format_track_length ('1820000'), '30:20', 'Medium track');
    is (format_track_length ('181100000'), '50:18:20', 'Long track');

    is (format_track_length (59 * $seconds + 501), '1:00', 'Correctly rounds up to a minute');
};

test 'Unformat Track Length' => sub {
    my $seconds = 1000;
    my $minutes = 60 * $seconds;
    my $hours = 60 * $minutes;

    is (unformat_track_length ("23 ms"), 23);
    is (unformat_track_length ("00:23"), 23 * $seconds);
    is (unformat_track_length ("59:00"), 59 * $minutes);
    is (unformat_track_length ("1:00:00"), 60 * $minutes);
    is (unformat_track_length ("14:15:16"), 14 * $hours + 15 * $minutes + 16 * $seconds);

    is (unformat_track_length ('9000:20'), 540020000, 'Absurdly long track lengths');
    is (unformat_track_length ('933 ms'), 933, 'Millisecond track lengths');
    is (unformat_track_length ('20:30'), 1230000, 'Reasonable track lengths');
    is (unformat_track_length ('?:??'), undef, 'Undefined track lengths');
};

1;
