package t::MusicBrainz::Server::Controller::WS::2::JSON::MoodList;
use Test::Routine;

use MusicBrainz::Server::Test::WS qw( ws2_test_json );

with 't::Mechanize', 't::Context';

use utf8;

=head2 Test description

This test ensures the full mood list at mood/all is working as intended
for fmt=json.

=cut

test 'Test mood list is returned as expected' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws2_test_json 'mood list', '/mood/all' => {
        'mood-count' => 3,
        'mood-offset' => 0,
        'moods' => [
            {
                id => '1f6e3b62-33d6-4ac0-a9dc-f5424af3e6a4',
                name => 'happy',
                disambiguation => '',
            },
            {
                id => '186a6a89-24de-4a3a-a92f-b7744dc7b051',
                name => 'sad',
                disambiguation => '',
            },
            {
                id => 'e1a39f19-5f05-4944-ba2b-b037706cf586',
                name => 'supercalifragilisticexpialidocious',
                disambiguation => 'stuff',
            },
        ],
    };
};

test 'Mood list inc parameters work as expected' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database(
      $c,
      '+webservice_annotation',
    );

    ws2_test_json 'mood list', '/mood/all?inc=aliases+annotation' => {
        'mood-count' => 3,
        'mood-offset' => 0,
        'moods' => [
            {
                id => '1f6e3b62-33d6-4ac0-a9dc-f5424af3e6a4',
                name => 'happy',
                disambiguation => '',
                annotation => JSON::null,
                aliases => [],
            },
            {
                id => '186a6a89-24de-4a3a-a92f-b7744dc7b051',
                name => 'sad',
                disambiguation => '',
                annotation => JSON::null,
                aliases => [],
            },
            {
                id => 'e1a39f19-5f05-4944-ba2b-b037706cf586',
                name => 'supercalifragilisticexpialidocious',
                disambiguation => 'stuff',
                annotation => 'this is a mood annotation',
                aliases => [
                    {
                        end => JSON::null,
                        name => 'supercalifragilistic',
                        primary => JSON::false,
                        locale => 'en',
                        begin => JSON::null,
                        ended => JSON::false,
                        'sort-name' => 'supercalifragilistic',
                        'type-id' => JSON::null,
                        type => JSON::null
                    }
                ],
            },
        ],
    };
};

1;
