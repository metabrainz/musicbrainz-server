package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupRelease;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic release lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic release lookup',
    '/release/b3b7e934-445b-4c68-a097-730c6a6d47e6' => encode_json (
        {
            id => "b3b7e934-445b-4c68-a097-730c6a6d47e6",
            title => "Summer Reggae! Rainbow",
            status => "Pseudo-Release",
            quality => "normal",
            "text-representation" => {
                language => "jpn",
                script => "Latn",
            },
            "cover-art-archive" => {
                artwork => JSON::false,
                count => 0,
                front => JSON::false,
                back => JSON::false,
                darkened => JSON::false,
            },
            date => "2001-07-04",
            country => "JP",
            "release-events" => [{
                date => "2001-07-04",
                "area" => {
                    "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                    "name" => "Japan",
                    "sort-name" => "Japan",
                    "iso_3166_1_codes" => ["JP"],
                    "iso_3166_2_codes" => [],
                    "iso_3166_3_codes" => []},
            }],
            barcode => "4942463511227",
            asin => "B00005LA6G",
            disambiguation => "",
            packaging => JSON::null,
        });
};

test 'basic release lookup, inc=annotation' => sub {

    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

    ws_test_json 'basic release lookup, inc=annotation',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?inc=annotation' => encode_json (
        {
            id => "adcf7b48-086e-48ee-b420-1001f88d672f",
            title => "My Demons",
            status => "Official",
            quality => "normal",
            "text-representation" => {
                language => "eng",
                script => "Latn",
            },
            "cover-art-archive" => {
                artwork => JSON::false,
                count => 0,
                front => JSON::false,
                back => JSON::false,
                darkened => JSON::false,
            },
            date => "2007-01-29",
            country => "GB",
            "release-events" => [{
                date => "2007-01-29",
                "area" => {
                    "id" => "8a754a16-0027-3a29-b6d7-2b40ea0481ed",
                    "name" => "United Kingdom",
                    "sort-name" => "United Kingdom",
                    "iso_3166_1_codes" => ["GB"],
                    "iso_3166_2_codes" => [],
                    "iso_3166_3_codes" => []},
            }],
            barcode => "600116817020",
            asin => "B000KJTG6K",
            annotation => "this is a release annotation",
            disambiguation => "",
            packaging => JSON::null,
        });
};

test 'basic release with tags' => sub {

    my $c = shift->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database(
        $c, "INSERT INTO release_tag (count, release, tag) VALUES (1, 123054, 114);");

    ws_test_json 'basic release with tags',
    '/release/b3b7e934-445b-4c68-a097-730c6a6d47e6?inc=tags' => encode_json (
        {
            id => "b3b7e934-445b-4c68-a097-730c6a6d47e6",
            title => "Summer Reggae! Rainbow",
            status => "Pseudo-Release",
            quality => "normal",
            "text-representation" => {
                language => "jpn",
                script => "Latn",
            },
            "cover-art-archive" => {
                artwork => JSON::false,
                count => 0,
                front => JSON::false,
                back => JSON::false,
                darkened => JSON::false,
            },
            date => "2001-07-04",
            country => "JP",
            "release-events" => [{
                date => "2001-07-04",
                "area" => {
                    "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                    "name" => "Japan",
                    "sort-name" => "Japan",
                    "iso_3166_1_codes" => ["JP"],
                    "iso_3166_2_codes" => [],
                    "iso_3166_3_codes" => []},
            }],
            barcode => "4942463511227",
            asin => "B00005LA6G",
            disambiguation => "",
            packaging => JSON::null,
            tags => [ { count => 1, name => "hello project" } ]
        });
};

test 'basic release with collections' => sub {

    my $c = shift->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        "INSERT INTO release_tag (count, release, tag) VALUES (1, 123054, 114); " .
        "INSERT INTO editor (id, name, password, ha1) VALUES (15412, 'editor', '{CLEARTEXT}mb', 'be88da857f697a78656b1307f89f90ab'); " .
        "INSERT INTO editor_collection (id, gid, editor, name, public) VALUES (14933, 'f34c079d-374e-4436-9448-da92dedef3cd', 15412, 'My Collection', TRUE); " .
        "INSERT INTO editor_collection_release (collection, release) VALUES (14933, 123054); ");

    ws_test_json 'basic release with collections',
    '/release/b3b7e934-445b-4c68-a097-730c6a6d47e6?inc=collections' => encode_json (
        {
            id => "b3b7e934-445b-4c68-a097-730c6a6d47e6",
            title => "Summer Reggae! Rainbow",
            status => "Pseudo-Release",
            quality => "normal",
            "text-representation" => {
                language => "jpn",
                script => "Latn",
            },
            "cover-art-archive" => {
                artwork => JSON::false,
                count => 0,
                front => JSON::false,
                back => JSON::false,
                darkened => JSON::false,
            },
            date => "2001-07-04",
            country => "JP",
            "release-events" => [{
                date => "2001-07-04",
                "area" => {
                    "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                    "name" => "Japan",
                    "sort-name" => "Japan",
                    "iso_3166_1_codes" => ["JP"],
                    "iso_3166_2_codes" => [],
                    "iso_3166_3_codes" => []},
            }],
            barcode => "4942463511227",
            asin => "B00005LA6G",
            disambiguation => "",
            packaging => JSON::null,
            collections => [
                {
                    id => "f34c079d-374e-4436-9448-da92dedef3cd",
                    name => "My Collection",
                    editor => "editor",
                    "release-count" => 1
                }]
        });
};

test 'release lookup with artists + aliases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release lookup with artists + aliases',
    '/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=artists+aliases' => encode_json (
        {
            id => "aff4a693-5970-4e2e-bd46-e2ee49c22de7",
            title => "the Love Bug",
            status => "Official",
            quality => "normal",
            disambiguation => "",
            packaging => JSON::null,
            "text-representation" => { language => "eng", script => "Latn" },
            "cover-art-archive" => {
                artwork => JSON::true,
                count => 1,
                front => JSON::true,
                back => JSON::false,
                darkened => JSON::false,
            },
            "artist-credit" => [
                {
                    name => "m-flo",
                    joinphrase => "",
                    artist => {
                        id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
                        name => "m-flo",
                        "sort-name" => "m-flo",
                        disambiguation => "",
                        aliases => [
                            { "sort-name" => "m-flow", name => "m-flow", locale => JSON::null, primary => JSON::null, type => JSON::null },
                            { "sort-name" => "mediarite-flow crew", name => "mediarite-flow crew", locale => JSON::null, primary => JSON::null, type => JSON::null  },
                            { "sort-name" => "meteorite-flow crew", name => "meteorite-flow crew", locale => JSON::null, primary => JSON::null, type => JSON::null  },
                            { "sort-name" => "mflo", name => "mflo", locale => JSON::null, primary => JSON::null, type => JSON::null  },
                            { "sort-name" => "えむふろう", name => "えむふろう", locale => JSON::null, primary => JSON::null, type => JSON::null  },
                            { "sort-name" => "エムフロウ", name => "エムフロウ", locale => JSON::null, primary => JSON::null, type => JSON::null  },
                            ],
                    }
                }],
            date => "2004-03-17",
            country => "JP",
            "release-events" => [{
                date => "2004-03-17",
                "area" => {
                    "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                    "name" => "Japan",
                    "sort-name" => "Japan",
                    "iso_3166_1_codes" => ["JP"],
                    "iso_3166_2_codes" => [],
                    "iso_3166_3_codes" => []},
            }],
            barcode => "4988064451180",
            asin => "B0001FAD2O",
        });
};

test 'release lookup with labels and recordings' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release lookup with labels and recordings',
    '/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=labels+recordings' => encode_json (
        {
            id => "aff4a693-5970-4e2e-bd46-e2ee49c22de7",
            title => "the Love Bug",
            status => "Official",
            quality => "normal",
            disambiguation => "",
            packaging => JSON::null,
            "text-representation" => { language => "eng", script => "Latn" },
            "cover-art-archive" => {
                artwork => JSON::true,
                count => 1,
                front => JSON::true,
                back => JSON::false,
                darkened => JSON::false,
            },
            date => "2004-03-17",
            country => "JP",
            "release-events" => [{
                date => "2004-03-17",
                "area" => {
                    "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                    "name" => "Japan",
                    "sort-name" => "Japan",
                    "iso_3166_1_codes" => ["JP"],
                    "iso_3166_2_codes" => [],
                    "iso_3166_3_codes" => []},
            }],
            barcode => "4988064451180",
            asin => "B0001FAD2O",
            "label-info" => [
                {
                    "catalog-number" => "RZCD-45118",
                    label => {
                        id => "72a46579-e9a0-405a-8ee1-e6e6b63b8212",
                        name => "rhythm zone",
                        "sort-name" => "rhythm zone",
                        disambiguation => "",
                        "label-code" => JSON::null,
                    }
                }],
            media => [
                {
                    format => JSON::null,
                    title => JSON::null,
                    position => 1,
                    "track-offset" => 0,
                    "track-count" => 3,
                    tracks => [
                        {
                            id => "ec60f5e2-ed8a-391d-90cd-bf119c50f6a0",
                            number => "1",
                            title => "the Love Bug",
                            length => 243000,
                            recording => {
                                id => "0cf3008f-e246-428f-abc1-35f87d584d60",
                                title => "the Love Bug",
                                length => 242226,
                                disambiguation => "",
                            }
                        },
                        {
                            id => "2519283c-93d9-30de-a0ba-75f99ca25604",
                            number => "2",
                            length => 222000,
                            title => "the Love Bug (Big Bug NYC remix)",
                            recording => {
                                id => "84c98ebf-5d40-4a29-b7b2-0e9c26d9061d",
                                title => "the Love Bug (Big Bug NYC remix)",
                                length => 222000,
                                disambiguation => "",
                            }
                        },
                        {
                            id => "4ffc18f0-96cc-3e1f-8192-cf0d0c489beb",
                            number => "3",
                            length => 333000,
                            title => "the Love Bug (cover)",
                            recording => {
                                id => "3f33fc37-43d0-44dc-bfd6-60efd38810c5",
                                title => "the Love Bug (cover)",
                                length => 333000,
                                disambiguation => "",
                            }
                        }]
                }],
        });
};

test 'release lookup with release-groups' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release lookup with release-groups',
    '/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=artist-credits+release-groups' => encode_json (
        {
            id => "aff4a693-5970-4e2e-bd46-e2ee49c22de7",
            title => "the Love Bug",
            status => "Official",
            quality => "normal",
            disambiguation => "",
            packaging => JSON::null,
            "text-representation" => { language => "eng", script => "Latn" },
            "cover-art-archive" => {
                artwork => JSON::true,
                count => 1,
                front => JSON::true,
                back => JSON::false,
                darkened => JSON::false,
            },
            date => "2004-03-17",
            country => "JP",
            "release-events" => [{
                date => "2004-03-17",
                "area" => {
                    "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                    "name" => "Japan",
                    "sort-name" => "Japan",
                    "iso_3166_1_codes" => ["JP"],
                    "iso_3166_2_codes" => [],
                    "iso_3166_3_codes" => []},
            }],
            barcode => "4988064451180",
            asin => "B0001FAD2O",
            "artist-credit" => [
                {
                   name => "m-flo",
                   artist => {
                      id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
                      name => "m-flo",
                      "sort-name" => "m-flo",
                      disambiguation => "",
                   },
                   joinphrase => '',
                }
            ],
            "release-group" => {
                id => "153f0a09-fead-3370-9b17-379ebd09446b",
                title => "the Love Bug",
                disambiguation => "",
                "first-release-date" => "2004-03-17",
                "primary-type" => "Single",
                "secondary-types" => [],
                "artist-credit" => [
                    {
                       name => "m-flo",
                       artist => {
                          id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
                          name => "m-flo",
                          "sort-name" => "m-flo",
                          disambiguation => "",
                       },
                       joinphrase => "",
                    }
                ],
            }
        });
};

test 'release lookup with discids and puids' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release lookup with discids and puids',
    '/release/b3b7e934-445b-4c68-a097-730c6a6d47e6?inc=discids+puids+recordings' => encode_json (
        {
            id => "b3b7e934-445b-4c68-a097-730c6a6d47e6",
            title => "Summer Reggae! Rainbow",
            status => "Pseudo-Release",
            quality => "normal",
            "text-representation" => {
                language => "jpn",
                script => "Latn",
            },
            "cover-art-archive" => {
                artwork => JSON::false,
                count => 0,
                front => JSON::false,
                back => JSON::false,
                darkened => JSON::false,
            },
            date => "2001-07-04",
            country => "JP",
            "release-events" => [{
                date => "2001-07-04",
                "area" => {
                    "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                    "name" => "Japan",
                    "sort-name" => "Japan",
                    "iso_3166_1_codes" => ["JP"],
                    "iso_3166_2_codes" => [],
                    "iso_3166_3_codes" => []},
            }],
            barcode => "4942463511227",
            asin => "B00005LA6G",
            disambiguation => "",
            packaging => JSON::null,
            media => [
                {
                    format => "CD",
                    title => JSON::null,
                    position => 1,
                    discs => [ { id => "W01Qvrvwkaz2Cm.IQm55_RHoRxs-", sectors => 60295 } ],
                    "track-count" => 3,
                    "track-offset" => 0,
                    tracks => [
                        {
                            id => "3b9d0128-ed86-3c2c-af24-c331a3798875",
                            number => "1",
                            title => "Summer Reggae! Rainbow",
                            length => 296026,
                            recording => {
                                id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
                                title => "サマーれげぇ!レインボー",
                                length => 296026,
                                disambiguation => "",
                                puids => [ "cdec3fe2-0473-073c-3cbb-bfb0c01a87ff" ],
                            }
                        },
                        {
                            id => "c7c21691-6f85-3ec7-9b08-e431c3b310a5",
                            number => "2",
                            title => "Hello! Mata Aou Ne (7nin Matsuri version)",
                            length => 213106,
                            recording => {
                                id => "487cac92-eed5-4efa-8563-c9a818079b9a",
                                title => "HELLO! また会おうね (7人祭 version)",
                                length => 213106,
                                disambiguation => "",
                                puids => [ "251bd265-84c7-ed8f-aecf-1d9918582399" ],
                            }
                        },
                        {
                            id => "e436c057-ca19-36c6-9f1e-dc4ada2604b0",
                            number => "3",
                            title => "Summer Reggae! Rainbow (Instrumental)",
                            length => 292800,
                            recording => {
                                id => "eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e",
                                title => "サマーれげぇ!レインボー (instrumental)",
                                length => 292800,
                                disambiguation => "",
                                puids => [ "7b8a868f-1e67-852b-5141-ad1edfb1e492" ],
                            }
                        }]
                }]
        });
};

test 'release lookup, barcode is NULL' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release lookup, barcode is NULL',
    '/release/fbe4eb72-0f24-3875-942e-f581589713d4' => encode_json (
        {
            id => "fbe4eb72-0f24-3875-942e-f581589713d4",
            title => "For Beginner Piano",
            status => "Official",
            quality => "normal",
            "text-representation" => {
                language => "eng",
                script => "Latn",
            },
            "cover-art-archive" => {
                artwork => JSON::false,
                count => 0,
                front => JSON::false,
                back => JSON::false,
                darkened => JSON::false,
            },
            date => "1999-09-23",
            country => "US",
            "release-events" => [{
                date => "1999-09-23",
                "area" => {
                    "id" => "489ce91b-6658-3307-9877-795b68554c98",
                    "name" => "United States",
                    "sort-name" => "United States",
                    "iso_3166_1_codes" => ["US"],
                    "iso_3166_2_codes" => [],
                    "iso_3166_3_codes" => []},
            }],
            barcode => JSON::null,
            asin => "B00001IVAI",
            disambiguation => "",
            packaging => JSON::null,
        });
};

test 'release lookup, barcode is  empty string' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release lookup, barcode is empty string',
    '/release/dd66bfdd-6097-32e3-91b6-67f47ba25d4c' => encode_json (
        {
            id => "dd66bfdd-6097-32e3-91b6-67f47ba25d4c",
            title => "For Beginner Piano",
            status => "Official",
            quality => "normal",
            "text-representation" => {
                language => "eng",
                script => "Latn",
            },
            "cover-art-archive" => {
                artwork => JSON::false,
                count => 0,
                front => JSON::false,
                back => JSON::false,
                darkened => JSON::false,
            },
            date => "1999-09-13",
            country => "GB",
            "release-events" => [{
                date => "1999-09-13",
                "area" => {
                    "id" => "8a754a16-0027-3a29-b6d7-2b40ea0481ed",
                    "name" => "United Kingdom",
                    "sort-name" => "United Kingdom",
                    "iso_3166_1_codes" => ["GB"],
                    "iso_3166_2_codes" => [],
                    "iso_3166_3_codes" => []},
            }],
            barcode => "",
            asin => JSON::null,
            disambiguation => "",
            packaging => JSON::null,
        });
};

test 'release lookup, relation attributes' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release lookup, relation attributes',
    '/release/757a1723-3769-4298-89cd-48d31177852a?inc=release-rels+artist-rels' => encode_json (
        {
            id => "757a1723-3769-4298-89cd-48d31177852a",
            title => "LOVE & HONESTY",
            "cover-art-archive" => {
                artwork => JSON::false,
                count => 0,
                front => JSON::false,
                back => JSON::false,
                darkened => JSON::false,
            },
            date => "2004-01-15",
            country => "JP",
            'release-events' => [
                {
                "area" => {
                    "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                    "name" => "Japan",
                    "sort-name" => "Japan",
                    "iso_3166_1_codes" => ["JP"],
                    "iso_3166_2_codes" => [],
                    "iso_3166_3_codes" => []},
                date => '2004-01-15'
                }
            ],
            barcode => JSON::null,
            asin => "B0000YGBSG",
            disambiguation => "",
            packaging => JSON::null,
            relations => [
                {
                    attributes => [ 'transliterated' ],
                    begin => JSON::null,
                    end => JSON::null,
                    direction => 'backward',
                    ended => JSON::false,
                    release => {
                        id => '28fc2337-985b-3da9-ac40-ad6f28ff0d8e',
                        title => 'LOVE & HONESTY',
                        barcode => '4988064173891',
                        country => JSON::null,
                        date => '2004-01-15',
                        'release-events' => [
                            {
                            "area" => undef,
                            date => '2004-01-15'
                            }
                        ],
                        disambiguation => '',
                        'text-representation' => {
                            language => JSON::null,
                            script => JSON::null,
                        },
                        status => JSON::null,
                        packaging => JSON::null,
                        quality => 'normal',
                    },
                    type => 'transl-tracklisting',
                    'type-id' => 'fc399d47-23a7-4c28-bfcf-0607a562b644',
                },
                {
                    attributes => [ 'transliterated' ],
                    begin => JSON::null,
                    end => JSON::null,
                    direction => 'backward',
                    ended => JSON::false,
                    release => {
                        id => 'cacc586f-c2f2-49db-8534-6f44b55196f2',
                        title => 'LOVE & HONESTY',
                        barcode => '4988064173907',
                        country => JSON::null,
                        date => '2004-01-15',
                        'release-events' => [
                            {
                            "area" => undef,
                            date => '2004-01-15'
                            }
                        ],
                        disambiguation => '',
                        'text-representation' => {
                            language => JSON::null,
                            script => JSON::null,
                        },
                        status => JSON::null,
                        packaging => JSON::null,
                        quality => 'normal',
                    },
                    type => 'transl-tracklisting',
                    'type-id' => 'fc399d47-23a7-4c28-bfcf-0607a562b644',
                }
            ],
            status => "Pseudo-Release",
            quality => "normal",
            "text-representation" => {
                language => "jpn",
                script => "Latn",
            },
        });
};

test 'release lookup, track artists have no tags' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release lookup, track artists have no tags',
    '/release/4f5a6b97-a09b-4893-80d1-eae1f3bfa221?inc=artists+recordings+tags+artist-rels+recording-level-rels'
    => encode_json ({
        'artist-credit' => [ {
            artist => {
                disambiguation => '',
                id => '3088b672-fba9-4b4b-8ae0-dce13babfbb4',
                name => 'Plone',
                relations => [],
                'sort-name' => 'Plone'
            },
            joinphrase => '',
            name => 'Plone'
        } ],
        asin => 'B00001IVAI',
        barcode => '5021603064126',
        country => 'GB',
        'cover-art-archive' => {
            artwork => JSON::false,
            back => JSON::false,
            count => 0,
            darkened => JSON::false,
            front => JSON::false
        },
        date => '1999-09-13',
        disambiguation => '',
        id => '4f5a6b97-a09b-4893-80d1-eae1f3bfa221',
        media => [ {
            format => undef,
            title => undef,
            'track-count' => 10,
            'track-offset' => 0,
            position => 1,
            tracks => [
                {
                    id => '9b9a84b5-0a41-38f6-859f-36cb22ac813c',
                    length => 267560,
                    number => '1',
                    recording => {
                            disambiguation => '',
                            id => '44704dda-b877-4551-a2a8-c1f764476e65',
                            length => 267560,
                            relations => [
                                {
                                    artist => {
                                        disambiguation => '',
                                        id => '3088b672-fba9-4b4b-8ae0-dce13babfbb4',
                                        name => 'Plone',
                                        'sort-name' => 'Plone'
                                    },
                                    attributes => [],
                                    begin => undef,
                                    direction => 'backward',
                                    end => undef,
                                    ended => JSON::false,
                                type => 'producer',
                                'type-id' => '5c0ceac3-feb4-41f0-868d-dc06f6e27fc0'
                            }
                        ],
                        title => 'On My Bus'
                    },
                    title => 'On My Bus'
                },
                {
                    id => 'f38b8e31-a10d-3973-8c1f-10923ee61adc',
                    length => 230506,
                    number => '2',
                    recording => {
                        disambiguation => '',
                        id => '8920288e-7541-48a7-b23b-f80447c8b1ab',
                        length => 230506,
                        relations => [ {
                                artist => {
                                    disambiguation => '',
                                    id => '3088b672-fba9-4b4b-8ae0-dce13babfbb4',
                                    name => 'Plone',
                                    'sort-name' => 'Plone'
                                },
                                attributes => [],
                                begin => undef,
                                direction => 'backward',
                                end => undef,
                                ended => JSON::false,
                                type => 'producer',
                                'type-id' => '5c0ceac3-feb4-41f0-868d-dc06f6e27fc0'
                        } ],
                        title => 'Top & Low Rent'
                    },
                    title => 'Top & Low Rent'
                },
                {
                    id => 'd17bed32-940a-3fcc-9210-a5d7c516b4bb',
                    length => 237133,
                    number => '3',
                    recording => {
                        disambiguation => '',
                        id => '6e89c516-b0b6-4735-a758-38e31855dcb6',
                        length => 237133,
                        relations => [ {
                            artist => {
                                disambiguation => '',
                                id => '3088b672-fba9-4b4b-8ae0-dce13babfbb4',
                                name => 'Plone',
                                'sort-name' => 'Plone'
                            },
                            attributes => [],
                            begin => undef,
                            direction => 'backward',
                            end => undef,
                            ended => JSON::false,
                            type => 'producer',
                            'type-id' => '5c0ceac3-feb4-41f0-868d-dc06f6e27fc0'
                        } ],
                        title => 'Plock'
                    },
                    title => 'Plock'
                },
                {
                    id => '001bc675-ba25-32bc-9914-d5d9e22c3c44',
                    length => 229826,
                    number => '4',
                    recording => {
                        disambiguation => '',
                        id => '791d9b27-ae1a-4295-8943-ded4284f2122',
                        length => 229826,
                        relations => [ {
                            artist => {
                                disambiguation => '',
                                id => '3088b672-fba9-4b4b-8ae0-dce13babfbb4',
                                name => 'Plone',
                                'sort-name' => 'Plone'
                            },
                            attributes => [],
                            begin => undef,
                            direction => 'backward',
                            end => undef,
                            ended => JSON::false,
                            type => 'producer',
                            'type-id' => '5c0ceac3-feb4-41f0-868d-dc06f6e27fc0'
                        } ],
                        title => 'Marbles'
                    },
                    title => 'Marbles'
                },
                {
                    id => 'c009176f-ff26-3f5f-bd16-46cede30ebe6',
                    length => 217440,
                    number => '5',
                    recording => {
                        disambiguation => '',
                        id => '4f392ffb-d3df-4f8a-ba74-fdecbb1be877',
                        length => 217440,
                        relations => [ {
                            artist => {
                                disambiguation => '',
                                id => '3088b672-fba9-4b4b-8ae0-dce13babfbb4',
                                name => 'Plone',
                                'sort-name' => 'Plone'
                            },
                            attributes => [],
                            begin => undef,
                            direction => 'backward',
                            end => undef,
                            ended => JSON::false,
                            type => 'producer',
                            'type-id' => '5c0ceac3-feb4-41f0-868d-dc06f6e27fc0'
                        } ],
                        title => 'Busy Working'
                    },
                    title => 'Busy Working'
                },
                {
                    id => '70454e43-b39b-3ca7-8c50-ae235b5ef358',
                    length => 227293,
                    number => '6',
                    recording => {
                        disambiguation => '',
                        id => 'dc891eca-bf42-4103-8682-86068fe732a5',
                        length => 227293,
                        relations => [ {
                            artist => {
                                disambiguation => '',
                                id => '3088b672-fba9-4b4b-8ae0-dce13babfbb4',
                                name => 'Plone',
                                'sort-name' => 'Plone'
                            },
                            attributes => [],
                            begin => undef,
                            direction => 'backward',
                            end => undef,
                            ended => JSON::false,
                            type => 'producer',
                            'type-id' => '5c0ceac3-feb4-41f0-868d-dc06f6e27fc0'
                        } ],
                        title => 'The Greek Alphabet'
                    },
                    title => 'The Greek Alphabet'
                },
                {
                    id => '1b5da50c-e20f-3762-839c-5a0eea89d6a5',
                    length => 244506,
                    number => '7',
                    recording => {
                        disambiguation => '',
                        id => '25e9ae0f-8b7d-4230-9cde-9a07f7680e4a',
                        length => 244506,
                        relations => [ {
                            artist => {
                                disambiguation => '',
                                id => '3088b672-fba9-4b4b-8ae0-dce13babfbb4',
                                name => 'Plone',
                                'sort-name' => 'Plone'
                            },
                            attributes => [],
                            begin => undef,
                            direction => 'backward',
                            end => undef,
                            ended => JSON::false,
                            type => 'producer',
                            'type-id' => '5c0ceac3-feb4-41f0-868d-dc06f6e27fc0'
                        } ],
                        title => 'Press a Key'
                    },
                    title => 'Press a Key'
                },
                {
                    id => 'f1b5bd23-ad01-3c0c-a49a-cf8e99088369',
                    length => 173960,
                    number => '8',
                    recording => {
                        disambiguation => '',
                        id => '6f9c8c32-3aae-4dad-b023-56389361cf6b',
                        length => 173960,
                        relations => [ {
                            artist => {
                                disambiguation => '',
                                id => '3088b672-fba9-4b4b-8ae0-dce13babfbb4',
                                name => 'Plone',
                                'sort-name' => 'Plone'
                            },
                            attributes => [],
                            begin => undef,
                            direction => 'backward',
                            end => undef,
                            ended => JSON::false,
                            type => 'producer',
                            'type-id' => '5c0ceac3-feb4-41f0-868d-dc06f6e27fc0'
                        } ],
                        title => 'Bibi Plone'
                    },
                    title => 'Bibi Plone'
                },
                {
                    id => '928f2274-5694-35f9-92da-a1fc565867cf',
                    length => 208706,
                    number => '9',
                    recording => {
                        disambiguation => '',
                        id => '7e379a1d-f2bc-47b8-964e-00723df34c8a',
                        length => 208706,
                        relations => [ {
                            artist => {
                                disambiguation => '',
                                id => '3088b672-fba9-4b4b-8ae0-dce13babfbb4',
                                name => 'Plone',
                                'sort-name' => 'Plone'
                            },
                            attributes => [],
                            begin => undef,
                            direction => 'backward',
                            end => undef,
                            ended => JSON::false,
                            type => 'producer',
                            'type-id' => '5c0ceac3-feb4-41f0-868d-dc06f6e27fc0'
                        } ],
                        title => 'Be Rude to Your School'
                    },
                    title => 'Be Rude to Your School'
                },
                {
                    id => '40727388-237d-34b2-8a3a-288878e5c883',
                    length => 320067,
                    number => '10',
                    recording => {
                        disambiguation => '',
                        id => 'a8614bda-42dc-43c7-ac5f-4067acb6f1c5',
                        length => 320067,
                        relations => [ {
                            artist => {
                                disambiguation => '',
                                id => '3088b672-fba9-4b4b-8ae0-dce13babfbb4',
                                name => 'Plone',
                                'sort-name' => 'Plone'
                            },
                            attributes => [],
                            begin => undef,
                            direction => 'backward',
                            end => undef,
                            ended => JSON::false,
                            type => 'producer',
                            'type-id' => '5c0ceac3-feb4-41f0-868d-dc06f6e27fc0'
                        } ],
                        title => 'Summer Plays Out'
                    },
                    title => 'Summer Plays Out'
                }
            ]
        } ],
        packaging => undef,
        quality => 'normal',
        relations => [ {
            artist => {
                disambiguation => '',
                id => '3088b672-fba9-4b4b-8ae0-dce13babfbb4',
                name => 'Plone',
                'sort-name' => 'Plone'
            },
            attributes => [],
            begin => undef,
            direction => 'backward',
            end => undef,
            ended => JSON::false,
            type => 'design/illustration',
            'type-id' => '307e95dd-88b5-419b-8223-b146d4a0d439'
        } ],
        'release-events' => [ {
            area => {
                id => '8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                iso_3166_1_codes => [ 'GB' ],
                iso_3166_2_codes => [],
                iso_3166_3_codes => [],
                name => 'United Kingdom',
                'sort-name' => 'United Kingdom'
            },
            date => '1999-09-13'
        } ],
        status => 'Official',
        tags => [],
        'text-representation' => {
            language => 'eng',
            script => 'Latn'
        },
        title => 'For Beginner Piano'
    });
};

1;
