package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupEvent;
use utf8;
use strict;
use warnings;

use JSON;
use Test::Routine;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic event lookup' => sub {

    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws_test_json 'basic event lookup',
    '/event/eb668bdc-a928-49a1-beb7-8e37db2a5b65' =>
        {
            id => 'eb668bdc-a928-49a1-beb7-8e37db2a5b65',
            name => 'Cool Festival',
            disambiguation => '',
            type => 'Festival',
            'type-id' => 'b6ded574-b592-3f0e-b56e-5b5f06aa0678',
            time => '',
            setlist => '',
            cancelled => JSON::false,
            'life-span' => {
                begin => JSON::null,
                end => JSON::null,
                ended => JSON::false
            },
        };
};

test 'basic event lookup, inc=aliases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic event lookup, inc=aliases',
    '/event/eb668bdc-a928-49a1-beb7-8e37db2a5b65?inc=aliases' =>
        {
            id => 'eb668bdc-a928-49a1-beb7-8e37db2a5b65',
            name => 'Cool Festival',
            disambiguation => '',
            type => 'Festival',
            'type-id' => 'b6ded574-b592-3f0e-b56e-5b5f06aa0678',
            time => '',
            setlist => '',
            cancelled => JSON::false,
            'life-span' => {
                begin => JSON::null,
                end => JSON::null,
                ended => JSON::false
            },
            aliases => [
                {
                    name => 'El Festival Cool',
                    'sort-name' => 'Festival Cool, El',
                    locale => JSON::null,
                    primary => JSON::null,
                    type => JSON::null,
                    'type-id' => JSON::null,
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                },
                {
                    name => 'Warm Festival',
                    'sort-name' => 'Warm Festival',
                    locale => JSON::null,
                    primary => JSON::null,
                    type => JSON::null,
                    'type-id' => JSON::null,
                    begin => JSON::null,
                    end => JSON::null,
                    ended => JSON::false,
                },
            ],
        };
};
