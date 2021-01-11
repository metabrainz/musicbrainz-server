package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupISRC;

use JSON;
use Test::Routine;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic isrc lookup' => sub {
    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic isrc lookup', '/isrc/GBAAA9900303' => {
        isrc => 'GBAAA9900303',
        recordings => [
            {
                disambiguation => '',
                id => 'bf7845cc-eac3-48a3-8b06-543b4b7ba117',
                length => 289946,
                title => 'Hey Boy Hey Girl',
                video => JSON::false,
                "first-release-date" => '1999-06-21',
            },
        ],
    };
};
