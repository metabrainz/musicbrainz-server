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
    is (format_track_length (23 * $seconds), "00:23");
    is (format_track_length (59 * $minutes), "59:00");
    is (format_track_length (60 * $minutes), "01:00:00");
    is (format_track_length (14 * $hours + 15 * $minutes + 16 * $seconds), "14:15:16");

    is (unformat_track_length ("23 ms"), 23);
    is (unformat_track_length ("00:23"), 23 * $seconds);
    is (unformat_track_length ("59:00"), 59 * $minutes);
    is (unformat_track_length ("01:00:00"), 60 * $minutes);
    is (unformat_track_length ("14:15:16"), 14 * $hours + 15 * $minutes + 16 * $seconds);
};

1;
