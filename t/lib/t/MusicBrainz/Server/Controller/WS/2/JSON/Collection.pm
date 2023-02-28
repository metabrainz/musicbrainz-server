package t::MusicBrainz::Server::Controller::WS::2::JSON::Collection;
use utf8;
use strict;
use warnings;

use JSON;
use Test::Routine;
use MusicBrainz::Server::Test::WS qw(
    ws2_test_json
    ws2_test_json_forbidden
    ws2_test_json_unauthorized
);

with 't::Mechanize', 't::Context';

test 'collection lookup' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws2_test_json 'collection lookup',
        '/collection/05febe0a-a9df-414a-a2c9-7dc366b0de9b' => {
            'event-count' => 1,
            'id' => '05febe0a-a9df-414a-a2c9-7dc366b0de9b',
            'type' => 'Event',
            'type-id' => 'c205b6b3-0613-35ff-9cfa-40a299ad812a',
            'editor' => 'the-anti-kuno',
            'name' => 'public event collection',
            'entity-type' => 'event'
        }, { username => 'new_editor', password => 'password' };

    ws2_test_json 'collections lookup',
        '/collection/' => {
            'collection-count' => 22,
            'collection-offset' => 0,
            'collections' => [
                {
                    'event-count' => 1,
                    'id' => '05febe0a-a9df-414a-a2c9-7dc366b0de9b',
                    'type' => 'Event',
                    'type-id' => 'c205b6b3-0613-35ff-9cfa-40a299ad812a',
                    'editor' => 'the-anti-kuno',
                    'name' => 'public event collection',
                    'entity-type' => 'event'
                },
                {
                    'entity-type' => 'event',
                    'name' => 'private event collection',
                    'type' => 'Event',
                    'type-id' => 'c205b6b3-0613-35ff-9cfa-40a299ad812a',
                    'editor' => 'the-anti-kuno',
                    'id' => '13b1d199-a79e-40fe-bd7c-0ecc3ca52d73',
                    'event-count' => 1
                },
                {
                    'editor' => 'the-anti-kuno',
                    'type' => 'Release',
                    'type-id' => 'd94659b2-4ce5-3a98-b4b8-da1131cf33ee',
                    'entity-type' => 'release',
                    'name' => 'private release collection',
                    'id' => '1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5',
                    'release-count' => 1
                },
                {
                    'entity-type' => 'work',
                    'name' => 'public work collection',
                    'type' => 'Work',
                    'type-id' => '918a5dfb-dc15-3251-b57f-25fbdfe019ca',
                    'editor' => 'the-anti-kuno',
                    'id' => '3529acda-c0c1-4b13-9761-a4a8dedb64be',
                    'work-count' => 1
                },
                {
                    'type' => 'Recording',
                    'type-id' => 'dda5c90e-4b0b-3482-a6a9-090844e0860e',
                    'editor' => 'the-anti-kuno',
                    'entity-type' => 'recording',
                    'recording-count' => 1,
                    'name' => 'public recording collection',
                    'id' => '38a6a0ec-f4a9-4424-80fd-bd4f9eb2e880'
                },
                {
                    'id' => '5adf966d-d82f-4ae9-a9a3-e5e187ed2c34',
                    'series-count' => 1,
                    'entity-type' => 'series',
                    'name' => 'public series collection',
                    'editor' => 'the-anti-kuno',
                    'type' => 'Series',
                    'type-id' => '39115bd2-dc2a-3576-9fc6-f609ea9061a0',
                },
                {
                    'name' => 'private artist collection',
                    'entity-type' => 'artist',
                    'type' => 'Artist',
                    'type-id' => 'b21ef166-d652-3e15-958d-1ff7ad3412ab',
                    'artist-count' => 1,
                    'editor' => 'the-anti-kuno',
                    'id' => '5f0831af-c84c-44a3-849d-abdf0a18cdd9'
                },
                {
                    'editor' => 'the-anti-kuno',
                    'type' => 'Place',
                    'type-id' => 'b69e09f2-4f95-3359-b739-4435b0ce02f7',
                    'place-count' => 1,
                    'entity-type' => 'place',
                    'name' => 'private place collection',
                    'id' => '65e18c7a-0958-4066-9c3e-7c1474c623d1'
                },
                {
                    'id' => '7749c811-d77c-4ea5-9a9e-e2a4e7ae0d1f',
                    'entity-type' => 'instrument',
                    'name' => 'public instrument collection',
                    'type' => 'Instrument',
                    'type-id' => '6929e090-d881-33b1-bbb0-575282633628',
                    'editor' => 'the-anti-kuno',
                    'instrument-count' => 1
                },
                {
                    'id' => '870dbdcf-e047-4da5-9c80-c39e964da96f',
                    'series-count' => 1,
                    'entity-type' => 'series',
                    'name' => 'private series collection',
                    'editor' => 'the-anti-kuno',
                    'type' => 'Series',
                    'type-id' => '39115bd2-dc2a-3576-9fc6-f609ea9061a0',
                },
                {
                    'entity-type' => 'artist',
                    'name' => 'public artist collection',
                    'editor' => 'the-anti-kuno',
                    'artist-count' => 1,
                    'type' => 'Artist',
                    'type-id' => 'b21ef166-d652-3e15-958d-1ff7ad3412ab',
                    'id' => '9c782444-f9f4-4a4f-93cb-92d132c79887'
                },
                {
                    'id' => '9ece2fbd-3f4e-431d-9424-da8af38374e0',
                    'name' => 'private area collection',
                    'entity-type' => 'area',
                    'editor' => 'the-anti-kuno',
                    'type' => 'Area',
                    'type-id' => 'ad024f25-ca93-32f5-a7bd-1055dff79f3c',
                    'area-count' => 1
                },
                {
                    'type' => 'Release group',
                    'type-id' => '8b6a6897-2ab8-3e18-84ae-e4b7b3791d65',
                    'editor' => 'the-anti-kuno',
                    'name' => 'private release group collection',
                    'entity-type' => 'release_group',
                    'release-group-count' => 1,
                    'id' => 'b0f09ccf-a777-4c17-a917-28e01b0e66a3'
                },
                {
                    'type' => 'Label',
                    'type-id' => 'c7ec7b39-c34b-3ab2-9b68-ea42dceff6f5',
                    'editor' => 'the-anti-kuno',
                    'entity-type' => 'label',
                    'name' => 'private label collection',
                    'id' => 'b0f57375-7009-47ab-a631-469aaba34885',
                    'label-count' => 1
                },
                {
                    'editor' => 'the-anti-kuno',
                    'type' => 'Recording',
                    'type-id' => 'dda5c90e-4b0b-3482-a6a9-090844e0860e',
                    'recording-count' => 1,
                    'name' => 'private recording collection',
                    'entity-type' => 'recording',
                    'id' => 'b5486110-906e-4c0c-a6e6-e16baf4e18e2'
                },
                {
                    'id' => 'b69030b0-911e-4f7d-aa59-c488b2c8fe8e',
                    'work-count' => 1,
                    'name' => 'private work collection',
                    'entity-type' => 'work',
                    'type' => 'Work',
                    'type-id' => '918a5dfb-dc15-3251-b57f-25fbdfe019ca',
                    'editor' => 'the-anti-kuno'
                },
                {
                    'id' => 'cc8cd8ee-6477-47d5-a16d-adac11ed9f30',
                    'type' => 'Area',
                    'type-id' => 'ad024f25-ca93-32f5-a7bd-1055dff79f3c',
                    'area-count' => 1,
                    'editor' => 'the-anti-kuno',
                    'entity-type' => 'area',
                    'name' => 'public area collection'
                },
                {
                    'id' => 'cdef54c4-2798-4d39-a0c9-5074191f9b6e',
                    'type' => 'Instrument',
                    'type-id' => '6929e090-d881-33b1-bbb0-575282633628',
                    'instrument-count' => 1,
                    'editor' => 'the-anti-kuno',
                    'name' => 'private instrument collection',
                    'entity-type' => 'instrument'
                },
                {
                    'id' => 'd8c9f799-9255-45ca-93fa-88f7c438d0d8',
                    'label-count' => 1,
                    'type' => 'Label',
                    'type-id' => 'c7ec7b39-c34b-3ab2-9b68-ea42dceff6f5',
                    'editor' => 'the-anti-kuno',
                    'entity-type' => 'label',
                    'name' => 'public label collection'
                },
                {
                    'release-group-count' => 1,
                    'id' => 'dadae81b-ff9e-464e-8c38-51156557bc36',
                    'editor' => 'the-anti-kuno',
                    'type' => 'Release group',
                    'type-id' => '8b6a6897-2ab8-3e18-84ae-e4b7b3791d65',
                    'entity-type' => 'release_group',
                    'name' => 'public release group collection'
                },
                {
                    'id' => 'dd07ea8b-0ec3-4b2d-85cf-80e523de4902',
                    'release-count' => 1,
                    'editor' => 'the-anti-kuno',
                    'type' => 'Release',
                    'type-id' => 'd94659b2-4ce5-3a98-b4b8-da1131cf33ee',
                    'entity-type' => 'release',
                    'name' => 'public release collection'
                },
                {
                    'id' => 'e6fac30e-28c9-46ed-9cbc-5aabce8170e8',
                    'type' => 'Place',
                    'type-id' => 'b69e09f2-4f95-3359-b739-4435b0ce02f7',
                    'place-count' => 1,
                    'editor' => 'the-anti-kuno',
                    'entity-type' => 'place',
                    'name' => 'public place collection'
                }
            ]
        }, { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_json 'collection releases lookup',
        '/collection/1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5/releases/' =>
            {
                id => '1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5',
                name => 'private release collection',
                editor => 'the-anti-kuno',
                type => 'Release',
                'type-id' => 'd94659b2-4ce5-3a98-b4b8-da1131cf33ee',
                'entity-type' => 'release',
                'release-count' => 1,
                releases => [
                    {
                        id => 'b3b7e934-445b-4c68-a097-730c6a6d47e6',
                        title => 'Summer Reggae! Rainbow',
                        status => 'Pseudo-Release',
                        'status-id' => '41121bb9-3413-3818-8a9a-9742318349aa',
                        quality => 'high',
                        'text-representation' => {
                            language => 'jpn',
                            script => 'Latn',
                        },
                        date => '2001-07-04',
                        country => 'JP',
                        'release-events' => [{
                            date => '2001-07-04',
                            'area' => {
                                disambiguation => '',
                                'id' => '2db42837-c832-3c27-b4a3-08198f75693c',
                                'name' => 'Japan',
                                'sort-name' => 'Japan',
                                'iso-3166-1-codes' => ['JP'],
                                'type' => JSON::null,
                                'type-id' => JSON::null,
                            },
                        }],
                        barcode => '4942463511227',
                        disambiguation => '',
                        packaging => JSON::null,
                        'packaging-id' => JSON::null,
                    }]
            }, { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_json 'collection release-count (MBS-8776)',
        '/collection/1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5/releases/?limit=1&offset=1' =>
            {
                id => '1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5',
                name => 'private release collection',
                editor => 'the-anti-kuno',
                type => 'Release',
                'type-id' => 'd94659b2-4ce5-3a98-b4b8-da1131cf33ee',
                'entity-type' => 'release',
                'release-count' => 1,
            }, { username => 'the-anti-kuno', password => 'notreally' };
};


test 'browsing by area' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws2_test_json 'browse by area',
        '/collection/?area=106e0bec-b638-3b37-b731-f53d507dc00e' => {
            'collection-count' => 1,
            'collection-offset' => 0,
            'collections' => [
                {
                    'area-count' => 1,
                    'id' => 'cc8cd8ee-6477-47d5-a16d-adac11ed9f30',
                    'type' => 'Area',
                    'type-id' => 'ad024f25-ca93-32f5-a7bd-1055dff79f3c',
                    'editor' => 'the-anti-kuno',
                    'name' => 'public area collection',
                    'entity-type' => 'area'
                },
            ],
        };

    ws2_test_json 'browse by area, no public collections',
        '/collection/?area=85752fda-13c4-31a3-bee5-0e5cb1f51dad' => {
            'collection-count' => 0,
            'collection-offset' => 0,
            'collections' => [],
        }, { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_json 'browse by area, inc=user-collections',
        '/collection/?area=85752fda-13c4-31a3-bee5-0e5cb1f51dad&inc=user-collections' => {
            'collection-count' => 1,
            'collection-offset' => 0,
            'collections' => [
                {
                    'area-count' => 1,
                    'id' => '9ece2fbd-3f4e-431d-9424-da8af38374e0',
                    'type' => 'Area',
                    'type-id' => 'ad024f25-ca93-32f5-a7bd-1055dff79f3c',
                    'editor' => 'the-anti-kuno',
                    'name' => 'private area collection',
                    'entity-type' => 'area'
                },
            ],
        }, { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_json_forbidden 'browse by area, inc=user-collections, no credentials',
        '/collection/?area=85752fda-13c4-31a3-bee5-0e5cb1f51dad&inc=user-collections';

    ws2_test_json_unauthorized 'browse by area, inc=user-collections, bad credentials',
        '/collection/?area=85752fda-13c4-31a3-bee5-0e5cb1f51dad&inc=user-collections',
        { username => 'the-anti-kuno', password => 'wrong_password' };
};

test 'browsing by release' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws2_test_json 'browse by release',
        '/collection/?release=0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e' => {
            'collection-count' => 1,
            'collection-offset' => 0,
            'collections' => [
                {
                    'release-count' => 1,
                    'id' => 'dd07ea8b-0ec3-4b2d-85cf-80e523de4902',
                    'type' => 'Release',
                    'type-id' => 'd94659b2-4ce5-3a98-b4b8-da1131cf33ee',
                    'editor' => 'the-anti-kuno',
                    'name' => 'public release collection',
                    'entity-type' => 'release'
                },
            ],
        };

    ws2_test_json 'browse by release, no public collections',
        '/collection/?release=b3b7e934-445b-4c68-a097-730c6a6d47e6' => {
            'collection-count' => 0,
            'collection-offset' => 0,
            'collections' => [],
        }, { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_json 'browse by release, inc=user-collections',
        '/collection/?release=b3b7e934-445b-4c68-a097-730c6a6d47e6&inc=user-collections' => {
            'collection-count' => 1,
            'collection-offset' => 0,
            'collections' => [
                {
                    'release-count' => 1,
                    'id' => '1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5',
                    'type' => 'Release',
                    'type-id' => 'd94659b2-4ce5-3a98-b4b8-da1131cf33ee',
                    'editor' => 'the-anti-kuno',
                    'name' => 'private release collection',
                    'entity-type' => 'release'
                },
            ],
        }, { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_json_forbidden 'browse by release, inc=user-collections, no credentials',
        '/collection/?release=b3b7e934-445b-4c68-a097-730c6a6d47e6&inc=user-collections';

    ws2_test_json_unauthorized 'browse by release, inc=user-collections, bad credentials',
        '/collection/?release=b3b7e934-445b-4c68-a097-730c6a6d47e6&inc=user-collections',
        { username => 'the-anti-kuno', password => 'wrong_password' };
};

test 'browsing by release group' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws2_test_json 'browse by release group',
        '/collection/?release-group=b84625af-6229-305f-9f1b-59c0185df016' => {
            'collection-count' => 1,
            'collection-offset' => 0,
            'collections' => [
                {
                    'release-group-count' => 1,
                    'id' => 'dadae81b-ff9e-464e-8c38-51156557bc36',
                    'type' => 'Release group',
                    'type-id' => '8b6a6897-2ab8-3e18-84ae-e4b7b3791d65',
                    'editor' => 'the-anti-kuno',
                    'name' => 'public release group collection',
                    'entity-type' => 'release_group'
                },
            ],
        };

    ws2_test_json 'browse by release group, no public collections',
        '/collection/?release-group=202cad78-a2e1-3fa7-b8bc-77c1f737e3da' => {
            'collection-count' => 0,
            'collection-offset' => 0,
            'collections' => [],
        }, { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_json 'browse by release group, inc=user-collections',
        '/collection/?release-group=202cad78-a2e1-3fa7-b8bc-77c1f737e3da&inc=user-collections' => {
            'collection-count' => 1,
            'collection-offset' => 0,
            'collections' => [
                {
                    'release-group-count' => 1,
                    'id' => 'b0f09ccf-a777-4c17-a917-28e01b0e66a3',
                    'type' => 'Release group',
                    'type-id' => '8b6a6897-2ab8-3e18-84ae-e4b7b3791d65',
                    'editor' => 'the-anti-kuno',
                    'name' => 'private release group collection',
                    'entity-type' => 'release_group'
                },
            ],
        }, { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_json_forbidden 'browse by releasegroup, inc=user-collections, no credentials',
        '/collection/?release-group=202cad78-a2e1-3fa7-b8bc-77c1f737e3da&inc=user-collections';

    ws2_test_json_unauthorized 'browse by release group, inc=user-collections, bad credentials',
        '/collection/?release-group=202cad78-a2e1-3fa7-b8bc-77c1f737e3da&inc=user-collections',
        { username => 'the-anti-kuno', password => 'wrong_password' };
};

1;
