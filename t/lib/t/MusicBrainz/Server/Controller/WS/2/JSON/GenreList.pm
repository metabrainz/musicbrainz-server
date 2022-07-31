package t::MusicBrainz::Server::Controller::WS::2::JSON::GenreList;
use Test::Routine;

use MusicBrainz::Server::Test::WS qw( ws2_test_json );

with 't::Mechanize', 't::Context';

use utf8;

=head2 Test description

This test ensures the full genre list at genre/all is working as intended
for fmt=json.

=cut

test 'Genre list is returned as expected' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws2_test_json 'genre list', '/genre/all' => {
        'genre-count' => 10,
        'genre-offset' => 0,
        'genres' => [
            {
                id => 'aac07ae0-8acf-4249-b5c0-2762b53947a2',
                name => 'big beat',
                disambiguation => '',
            },
            {
                id => '1b50083b-1afa-4778-82c8-548b309af783',
                name => 'dubstep',
                disambiguation => '',
            },
            {
                id => '89255676-1f14-4dd8-bbad-fca839d6aff4',
                name => 'electronic',
                disambiguation => '',
            },
            {
                id => '53a3cea3-17af-4421-a07a-5824b540aeb5',
                name => 'electronica',
                disambiguation => '',
            },
            {
                id => '18b010d7-7d85-4445-a4a8-1889a4688308',
                name => 'glitch',
                disambiguation => '',
            },
            {
                id => '51cfaac4-6696-480b-8f1b-27cfc789109c',
                name => 'grime',
                disambiguation => 'stuff',
            },
            {
                id => 'a2782cb6-1cd0-477c-a61d-b3f8b42dd1b3',
                name => 'house',
                disambiguation => '',
            },
            {
                id => 'eba7715e-ee26-4989-8d49-9db382955419',
                name => 'j-pop',
                disambiguation => '',
            },
            {
                id => 'b74b3b6c-0700-46b1-aa55-1f2869a3bd1a',
                name => 'k-pop',
                disambiguation => '',
            },
            {
                id => '911c7bbb-172d-4df8-9478-dbff4296e791',
                name => 'pop',
                disambiguation => '',
            },
        ],
    };
};

test 'Test genre list includes' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database(
      $c,
      '+webservice_annotation',
    );

    ws2_test_json 'genre list', '/genre/all?inc=aliases+annotation' => {
        'genre-count' => 10,
        'genre-offset' => 0,
        'genres' => [
            {
                id => 'aac07ae0-8acf-4249-b5c0-2762b53947a2',
                name => 'big beat',
                disambiguation => '',
                annotation => JSON::null,
                aliases => [],
            },
            {
                id => '1b50083b-1afa-4778-82c8-548b309af783',
                name => 'dubstep',
                disambiguation => '',
                annotation => JSON::null,
                aliases => [],
            },
            {
                id => '89255676-1f14-4dd8-bbad-fca839d6aff4',
                name => 'electronic',
                disambiguation => '',
                annotation => JSON::null,
                aliases => [],
            },
            {
                id => '53a3cea3-17af-4421-a07a-5824b540aeb5',
                name => 'electronica',
                disambiguation => '',
                annotation => JSON::null,
                aliases => [],
            },
            {
                id => '18b010d7-7d85-4445-a4a8-1889a4688308',
                name => 'glitch',
                disambiguation => '',
                annotation => JSON::null,
                aliases => [],
            },
            {
                id => '51cfaac4-6696-480b-8f1b-27cfc789109c',
                name => 'grime',
                disambiguation => 'stuff',
                annotation => 'this is a genre annotation',
                aliases => [
                    {
                        end => JSON::null,
                        name => 'dirt',
                        primary => JSON::false,
                        locale => 'en',
                        begin => JSON::null,
                        ended => JSON::false,
                        'sort-name' => 'dirt',
                        'type-id' => JSON::null,
                        type => JSON::null
                    }
                ],
            },
            {
                id => 'a2782cb6-1cd0-477c-a61d-b3f8b42dd1b3',
                name => 'house',
                disambiguation => '',
                annotation => JSON::null,
                aliases => [],
            },
            {
                id => 'eba7715e-ee26-4989-8d49-9db382955419',
                name => 'j-pop',
                disambiguation => '',
                annotation => JSON::null,
                aliases => [],
            },
            {
                id => 'b74b3b6c-0700-46b1-aa55-1f2869a3bd1a',
                name => 'k-pop',
                disambiguation => '',
                annotation => JSON::null,
                aliases => [],
            },
            {
                id => '911c7bbb-172d-4df8-9478-dbff4296e791',
                name => 'pop',
                disambiguation => '',
                annotation => JSON::null,
                aliases => [],
            },
        ],
    };
};

1;
