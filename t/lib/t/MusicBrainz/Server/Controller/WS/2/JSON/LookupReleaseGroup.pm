package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupReleaseGroup;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic release group lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic release group lookup',
    '/release-group/b84625af-6229-305f-9f1b-59c0185df016' => encode_json (
        {
            id => "b84625af-6229-305f-9f1b-59c0185df016",
            title => "サマーれげぇ!レインボー",
            disambiguation => JSON::null,
            "first-release-date" => "2001-07-04",
            "primary-type" => "Single",
            "secondary-types" => [],
        });
};

1;
