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
            date => "2001-07-04",
            country => "JP",
            barcode => "4942463511227",
            asin => "B00005LA6G",
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
            date => "2001-07-04",
            country => "JP",
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
        "INSERT INTO editor (id, name, password) VALUES (15412, 'editor', 'mb'); " .
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
            date => "2001-07-04",
            country => "JP",
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
                            { "sort-name" => "m-flow", name => "m-flow" },
                            { "sort-name" => "mediarite-flow crew", name => "mediarite-flow crew" },
                            { "sort-name" => "meteorite-flow crew", name => "meteorite-flow crew" },
                            { "sort-name" => "mflo", name => "mflo" },
                            { "sort-name" => "えむふろう", name => "えむふろう" },
                            { "sort-name" => "エムフロウ", name => "エムフロウ" },
                            ]
                    }
                }],
            date => "2004-03-17",
            country => "JP",
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
            date => "2004-03-17",
            country => "JP",
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
                    "track-offset" => 0,
                    "track-count" => 3,
                    tracks => [
                        {
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
            date => "2004-03-17",
            country => "JP",
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
            date => "2001-07-04",
            country => "JP",
            barcode => "4942463511227",
            asin => "B00005LA6G",
            disambiguation => "",
            packaging => JSON::null,
            media => [
                {
                    format => "CD",
                    title => JSON::null,
                    discids => [ { id => "W01Qvrvwkaz2Cm.IQm55_RHoRxs-", sectors => 60295 } ],
                    "track-count" => 3,
                    "track-offset" => 0,
                    tracks => [
                        {
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
            date => "1999-09-23",
            country => "US",
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
            date => "1999-09-13",
            country => "GB",
            barcode => "",
            asin => JSON::null,
            disambiguation => "",
            packaging => JSON::null,
        });
};

1;
