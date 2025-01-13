package t::MusicBrainz::Server::Controller::WS::2::JSON::BrowseGenres;
use utf8;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2,
};
use MusicBrainz::Server::Test::WS qw(
    ws2_test_json_forbidden
    ws2_test_json_unauthorized
);

with 't::Mechanize', 't::Context';

test 'browse genres via collection' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse genres via public collection',
    '/genre?collection=7749c811-d77c-4ea5-9a9e-e2a4e7ae0d1a' =>
        {
            'genre-offset' => 0,
            'genre-count' => 1,
            genres => [
                {
                    id => '51cfaac4-6696-480b-8f1b-27cfc789109c',
                    name => 'grime',
                    disambiguation => 'stuff',
                }],
        };

    ws_test_json 'browse genres via private collection',
    '/genre?collection=7749c811-d77c-4ea5-9a9e-e2a4e7ae0d1b' =>
        {
            'genre-offset' => 0,
            'genre-count' => 1,
            genres => [
                {
                    id => '51cfaac4-6696-480b-8f1b-27cfc789109c',
                    name => 'grime',
                    disambiguation => 'stuff',
                }],
        },
    { username => 'the-anti-kuno', password => 'notreally' };


    ws2_test_json_forbidden 'browse genres via private collection, no credentials',
    '/genre?collection=7749c811-d77c-4ea5-9a9e-e2a4e7ae0d1b';

    ws2_test_json_unauthorized 'browse genres via private collection, bad credentials',
    '/genre?collection=7749c811-d77c-4ea5-9a9e-e2a4e7ae0d1b',
    { username => 'the-anti-kuno', password => 'idk' };

};

1;
