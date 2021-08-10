package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupPlace;

use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic place lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic place lookup', '/place/df9269dd-0470-4ea2-97e8-c11e46080edd' => {
        'address' => 'An Address',
        'area' => {
            'disambiguation' => '',
            'id' => '89a675c2-3e37-3518-b83c-418bad59a85a',
            'iso-3166-1-codes' => ['XE'],
            'name' => 'Europe',
            'sort-name' => 'Europe',
            'type' => JSON::null,
            'type-id' => JSON::null,
        },
        'coordinates' => {
            'latitude' => 0.323,
            'longitude' => 1.234,
        },
        'disambiguation' => 'A PLACE!',
        'id' => 'df9269dd-0470-4ea2-97e8-c11e46080edd',
        'life-span' => {
            'begin' => '2013',
            'end' => JSON::null,
            'ended' => JSON::false,
        },
        'name' => 'A Test Place',
        'type' => 'Venue',
        'type-id' => 'cd92781a-a73f-30e8-a430-55d7521338db',
    }, {
        content_cb => sub {
            my $content = shift;

            like $content, qr{"longitude":\s*1.234},
                'longitude is outputted as a float';

            like $content, qr{"latitude":\s*0.323},
                'latitude is outputted as a float';
        },
        extra_plan => 2,
    };
};

1;
