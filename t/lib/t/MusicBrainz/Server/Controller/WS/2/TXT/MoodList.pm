package t::MusicBrainz::Server::Controller::WS::2::TXT::MoodList;
use Test::Routine;

use MusicBrainz::Server::Test::WS qw( ws2_test_txt );

with 't::Mechanize', 't::Context';

use utf8;

=head2 Test description

This test ensures the full mood names list at mood/all is working for the
txt format.

=cut

test 'Test mood names list is returned as expected' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    my $mood_names = join "\n", (
        'happy',
        'sad',
        'supercalifragilisticexpialidocious',
    );

    ws2_test_txt 'mood names list using accept header',
        '/mood/all' => $mood_names;

    ws2_test_txt 'mood names list with fmt=txt',
        '/mood/all?fmt=txt' => $mood_names;
};

1;
